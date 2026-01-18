package com.example.bary3

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.speech.RecognizerIntent
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel

class SystemAssistantHandler(private val context: Context) {
    private val CHANNEL = "com.bary3/system_assistant"
    private val VOICE_CHANNEL = "com.bary3/voice_commands"
    private val APP_SHORTCUTS_CHANNEL = "com.bary3/app_shortcuts"
    private var voiceEventSink: EventChannel.EventSink? = null
    private var mainActivity: MainActivity? = null
    private lateinit var appShortcutsManager: AppShortcutsManager
    
    fun setMainActivity(activity: MainActivity) {
        mainActivity = activity
    }
    
    fun setupChannel(flutterEngine: FlutterEngine) {
        // Инициализируем AppShortcutsManager
        appShortcutsManager = AppShortcutsManager(context)
        
        // Method Channel для запросов к системному ассистенту
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "queryGoogleAssistant" -> {
                        val query = call.argument<String>("query")
                        val locale = call.argument<String>("locale")
                        val contextData = call.argument<Map<String, Any>>("context")
                        
                        queryGoogleAssistant(query, locale, contextData) { response ->
                            result.success(response)
                        }
                    }
                    "startVoiceRecognition" -> {
                        startVoiceRecognition { text ->
                            result.success(text)
                        }
                    }
                    "handleDeepLink" -> {
                        val uri = call.argument<String>("uri")
                        handleDeepLink(uri) { success ->
                            result.success(success)
                        }
                    }
                    "getInitialLink" -> {
                        // Получаем начальный deep link (если приложение запущено через deep link)
                        val initialLink = mainActivity?.getInitialDeepLink()
                        result.success(initialLink)
                    }
                    "donateShortcuts" -> {
                        donateShortcuts()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
        
        // Method Channel для управления App Shortcuts
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, APP_SHORTCUTS_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "registerShortcuts" -> {
                        appShortcutsManager.registerShortcuts()
                        result.success(true)
                    }
                    "updateShortcut" -> {
                        val id = call.argument<String>("id")
                        val label = call.argument<String>("label")
                        if (id != null && label != null) {
                            appShortcutsManager.updateShortcut(id, label)
                            result.success(true)
                        } else {
                            result.error("INVALID_ARGUMENT", "id and label are required", null)
                        }
                    }
                    "addContextualShortcut" -> {
                        val id = call.argument<String>("id")
                        val shortLabel = call.argument<String>("shortLabel")
                        val longLabel = call.argument<String>("longLabel")
                        val deepLink = call.argument<String>("deepLink")
                        val iconRes = call.argument<Int>("iconRes") ?: android.R.drawable.ic_menu_my_calendar
                        
                        if (id != null && shortLabel != null && longLabel != null && deepLink != null) {
                            appShortcutsManager.addContextualShortcut(id, shortLabel, longLabel, deepLink, iconRes)
                            result.success(true)
                        } else {
                            result.error("INVALID_ARGUMENT", "id, shortLabel, longLabel, and deepLink are required", null)
                        }
                    }
                    "removeShortcut" -> {
                        val id = call.argument<String>("id")
                        if (id != null) {
                            appShortcutsManager.removeShortcut(id)
                            result.success(true)
                        } else {
                            result.error("INVALID_ARGUMENT", "id is required", null)
                        }
                    }
                    "getRegisteredShortcuts" -> {
                        val shortcuts = appShortcutsManager.getRegisteredShortcuts()
                        result.success(shortcuts)
                    }
                    else -> result.notImplemented()
                }
            }
        
        // Event Channel для голосовых команд
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, VOICE_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    voiceEventSink = events
                }
                
                override fun onCancel(arguments: Any?) {
                    voiceEventSink = null
                }
            })
    }
    
    private fun queryGoogleAssistant(
        query: String?,
        locale: String?,
        contextData: Map<String, Any>?,
        callback: (Map<String, Any>) -> Unit
    ) {
        // Используем App Actions для интеграции с Google Assistant
        // App Actions автоматически обрабатываются системой на основе actions.xml
        
        // Если запрос содержит команду для приложения, обрабатываем через deep link
        val processedQuery = query ?: ""
        val deepLink = processQueryToDeepLink(processedQuery)
        
        if (deepLink != null) {
            // Отправляем deep link в Flutter
            voiceEventSink?.success(mapOf(
                "type" to "deep_link",
                "uri" to deepLink
            ))
        }
        
        // Возвращаем ответ для отображения пользователю
        val response = mapOf(
            "response" to processedQuery,
            "suggestion" to "Обрабатываю запрос через Google Assistant...",
            "confidence" to 0.8,
            "source" to "Google Assistant",
            "actions" to emptyList<Map<String, String>>()
        )
        
        callback(response)
    }
    
    private fun processQueryToDeepLink(query: String): String? {
        val lowerQuery = query.lowercase()
        
        // Определяем тип запроса и создаём deep link
        return when {
            lowerQuery.contains("баланс") || lowerQuery.contains("balance") -> 
                "bary3://screen?screen=balance"
            lowerQuery.contains("копилк") || lowerQuery.contains("piggy") -> 
                "bary3://screen?screen=piggy_banks"
            lowerQuery.contains("календар") || lowerQuery.contains("calendar") -> 
                "bary3://screen?screen=calendar"
            lowerQuery.contains("заметк") || lowerQuery.contains("note") -> 
                "bary3://screen?screen=notes"
            lowerQuery.contains("калькулятор") || lowerQuery.contains("calculator") -> 
                "bary3://calculator"
            lowerQuery.contains("создать заметку") || lowerQuery.contains("create note") -> 
                "bary3://note/create"
            lowerQuery.contains("запланировать") || lowerQuery.contains("plan event") -> 
                "bary3://event/create"
            lowerQuery.contains("спроси бари") || lowerQuery.contains("ask bari") -> 
                "bary3://bari/ask?question=${Uri.encode(query)}"
            else -> null
        }
    }
    
    private fun startVoiceRecognition(callback: (String?) -> Unit) {
        try {
            val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
                putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
                putExtra(RecognizerIntent.EXTRA_PROMPT, "Скажи команду для Бари")
                putExtra(RecognizerIntent.EXTRA_LANGUAGE, "ru-RU")
            }
            
            // Запускаем распознавание речи
            // В реальном приложении нужно использовать Activity для результата
            // Здесь возвращаем заглушку
            callback("Голосовая команда распознана")
        } catch (e: Exception) {
            callback(null)
        }
    }
    
    fun handleDeepLink(uri: String?, callback: (Boolean) -> Unit) {
        if (uri == null) {
            callback(false)
            return
        }
        
        try {
            val parsedUri = Uri.parse(uri)
            val scheme = parsedUri.scheme
            val host = parsedUri.host
            val path = parsedUri.path
            
            // Отправляем deep link в Flutter через Event Channel
            voiceEventSink?.success(mapOf(
                "type" to "deep_link",
                "uri" to uri,
                "scheme" to (scheme ?: ""),
                "host" to (host ?: ""),
                "path" to (path ?: "")
            ))
            
            callback(true)
        } catch (e: Exception) {
            callback(false)
        }
    }
    
    private fun donateShortcuts() {
        // Регистрируем Shortcuts для Google Assistant
        // Это позволяет Google Assistant предлагать действия пользователю
        appShortcutsManager.registerShortcuts()
    }
}
