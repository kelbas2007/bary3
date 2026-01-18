package com.example.bary3

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL_NAME = "com.bary3/gemini_nano"
    private lateinit var geminiNanoHandler: GeminiNanoHandler
    private lateinit var systemAssistantHandler: SystemAssistantHandler
    private lateinit var appShortcutsManager: AppShortcutsManager
    private lateinit var geminiExtensionHandler: GeminiExtensionHandler
    private var initialDeepLink: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Инициализируем обработчик Gemini Nano
        geminiNanoHandler = GeminiNanoHandler(this)
        
        // Настраиваем MethodChannel
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
        geminiNanoHandler.setupMethodChannel(channel, flutterEngine.dartExecutor.binaryMessenger)
        
        // Инициализируем обработчик системного ассистента
        systemAssistantHandler = SystemAssistantHandler(this)
        systemAssistantHandler.setMainActivity(this)
        systemAssistantHandler.setupChannel(flutterEngine)
        
        // Инициализируем менеджер App Shortcuts
        appShortcutsManager = AppShortcutsManager(this)
        appShortcutsManager.registerShortcuts()
        
        // Инициализируем обработчик Gemini Extensions
        geminiExtensionHandler = GeminiExtensionHandler(this)
        
        // Сохраняем начальный deep link, если есть
        intent.data?.let { data ->
            if ("bary3" == data.scheme) {
                initialDeepLink = data.toString()
            }
        }
    }
    
    override fun onResume() {
        super.onResume()
        // Обновляем shortcuts при возврате в приложение
        // Это позволяет Google Assistant видеть актуальные действия
        if (::appShortcutsManager.isInitialized) {
            appShortcutsManager.registerShortcuts()
        }
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        // Обрабатываем deep links от App Actions
        handleIntent(intent)
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Обрабатываем deep links при запуске
        handleIntent(intent)
    }
    
    private fun handleIntent(intent: Intent) {
        val data = intent.data
        if (data != null && "bary3" == data.scheme) {
            val deepLinkUri = data.toString()
            // Сохраняем для getInitialLink
            initialDeepLink = deepLinkUri
            // Deep link обрабатывается через SystemAssistantHandler
            if (::systemAssistantHandler.isInitialized) {
                systemAssistantHandler.handleDeepLink(deepLinkUri) { success ->
                    // Deep link обработан
                }
            }
        }
    }
    
    fun getInitialDeepLink(): String? = initialDeepLink
}
