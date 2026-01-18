import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Инициализация обработчика системного ассистента
    if let controller = window?.rootViewController as? FlutterViewController {
      SystemAssistantHandler.shared.setupChannel(
        binaryMessenger: controller.binaryMessenger
      )
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Обработка Siri Shortcuts и Universal Links
  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    // Обрабатываем deep links от Siri
    if userActivity.activityType == "com.example.bary3.openScreen" ||
       userActivity.activityType == "com.example.bary3.createNote" ||
       userActivity.activityType == "com.example.bary3.createEvent" ||
       userActivity.activityType == "com.example.bary3.askBari" {
      if let url = userActivity.webpageURL {
        SystemAssistantHandler.shared.handleDeepLink(uri: url.absoluteString)
      } else if let urlString = userActivity.userInfo?["url"] as? String {
        SystemAssistantHandler.shared.handleDeepLink(uri: urlString)
      }
      return true
    }
    
    // Обрабатываем Universal Links
    if let url = userActivity.webpageURL, url.scheme == "bary3" {
      SystemAssistantHandler.shared.handleDeepLink(uri: url.absoluteString)
      return true
    }
    
    return false
  }
  
  // Обработка deep links при запуске приложения
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    if url.scheme == "bary3" {
      SystemAssistantHandler.shared.handleDeepLink(uri: url.absoluteString)
      return true
    }
    return false
  }
}
