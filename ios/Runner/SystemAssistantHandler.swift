import Foundation
import Flutter
import Intents
import IntentsUI
import Speech

@objc class SystemAssistantHandler: NSObject {
    static let shared = SystemAssistantHandler()
    private var voiceEventSink: FlutterEventSink?
    private var initialDeepLink: String?
    
    func setupChannel(binaryMessenger: FlutterBinaryMessenger) {
        // Method Channel для запросов к Siri
        let channel = FlutterMethodChannel(
            name: "com.bary3/system_assistant",
            binaryMessenger: binaryMessenger
        )
        
        channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "querySiri":
                self.querySiri(call: call, result: result)
            case "startVoiceRecognition":
                self.startVoiceRecognition(result: result)
            case "handleDeepLink":
                if let args = call.arguments as? [String: Any],
                   let uri = args["uri"] as? String {
                    self.handleDeepLink(uri: uri, result: result)
                } else {
                    result(false)
                }
            case "donateShortcuts":
                self.donateShortcuts()
                result(true)
            case "getInitialLink":
                // Получаем начальный deep link (если приложение запущено через deep link)
                result(initialDeepLink)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        // Event Channel для голосовых команд
        let eventChannel = FlutterEventChannel(
            name: "com.bary3/voice_commands",
            binaryMessenger: binaryMessenger
        )
        
        eventChannel.setStreamHandler(self)
    }
    
    private func querySiri(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let query = args["query"] as? String,
              let locale = args["locale"] as? String else {
            result(FlutterError(
                code: "INVALID_ARGS",
                message: "Invalid arguments",
                details: nil
            ))
            return
        }
        
        // Обрабатываем запрос и создаём deep link
        let deepLink = processQueryToDeepLink(query: query)
        
        if let deepLink = deepLink {
            // Отправляем deep link в Flutter
            voiceEventSink?([
                "type": "deep_link",
                "uri": deepLink
            ])
        }
        
        let response: [String: Any] = [
            "response": query,
            "suggestion": "Обрабатываю запрос через Siri...",
            "confidence": 0.8,
            "source": "Siri",
            "actions": []
        ]
        
        result(response)
    }
    
    private func processQueryToDeepLink(query: String) -> String? {
        let lowerQuery = query.lowercased()
        
        // Определяем тип запроса и создаём deep link
        if lowerQuery.contains("баланс") || lowerQuery.contains("balance") {
            return "bary3://screen?screen=balance"
        } else if lowerQuery.contains("копилк") || lowerQuery.contains("piggy") {
            return "bary3://screen?screen=piggy_banks"
        } else if lowerQuery.contains("календар") || lowerQuery.contains("calendar") {
            return "bary3://screen?screen=calendar"
        } else if lowerQuery.contains("заметк") || lowerQuery.contains("note") {
            return "bary3://screen?screen=notes"
        } else if lowerQuery.contains("калькулятор") || lowerQuery.contains("calculator") {
            return "bary3://calculator"
        } else if lowerQuery.contains("создать заметку") || lowerQuery.contains("create note") {
            return "bary3://note/create"
        } else if lowerQuery.contains("запланировать") || lowerQuery.contains("plan event") {
            return "bary3://event/create"
        } else if lowerQuery.contains("спроси бари") || lowerQuery.contains("ask bari") {
            let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return "bary3://bari/ask?question=\(encodedQuery)"
        }
        
        return nil
    }
    
    private func startVoiceRecognition(result: @escaping FlutterResult) {
        // Запрос разрешения на распознавание речи
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    result("Голосовая команда распознана")
                case .denied, .restricted, .notDetermined:
                    result(FlutterError(
                        code: "PERMISSION_DENIED",
                        message: "Разрешение на распознавание речи не предоставлено",
                        details: nil
                    ))
                @unknown default:
                    result(FlutterError(
                        code: "UNKNOWN_ERROR",
                        message: "Неизвестная ошибка",
                        details: nil
                    ))
                }
            }
        }
    }
    
    func handleDeepLink(uri: String, result: ((Bool) -> Void)? = nil) {
        guard let url = URL(string: uri) else {
            result?(false)
            return
        }
        
        // Сохраняем для getInitialLink
        if initialDeepLink == nil {
            initialDeepLink = uri
        }
        
        // Отправляем deep link в Flutter через Event Channel
        voiceEventSink?([
            "type": "deep_link",
            "uri": uri,
            "scheme": url.scheme ?? "",
            "host": url.host ?? "",
            "path": url.path
        ])
        
        result?(true)
    }
    
    private func handleDeepLink(uri: String, result: @escaping FlutterResult) {
        handleDeepLink(uri: uri) { success in
            result(success)
        }
    }
    
    private func donateShortcuts() {
        // Регистрируем Shortcuts для Siri
        // Это позволяет Siri предлагать действия пользователю
        
        // OpenScreen Intent
        if #available(iOS 12.0, *) {
            let openScreenIntent = INIntent()
            // Настройка intent'а для регистрации в Siri
            let interaction = INInteraction(intent: openScreenIntent, response: nil)
            interaction.identifier = "com.example.bary3.openScreen"
            interaction.donate { error in
                if let error = error {
                    print("Error donating shortcut: \(error)")
                }
            }
        }
    }
}

// MARK: - FlutterStreamHandler
extension SystemAssistantHandler: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        voiceEventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        voiceEventSink = nil
        return nil
    }
}
