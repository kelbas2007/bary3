package com.example.bary3

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import org.json.JSONObject

/**
 * Обработчик для интеграции с Gemini Extensions
 * Позволяет системному Gemini обращаться к данным приложения через @Bary3
 */
class GeminiExtensionHandler(private val context: Context) {
    
    companion object {
        private const val TAG = "GeminiExtensionHandler"
    }
    
    /**
     * Обрабатывает запрос от Gemini через @Bary3
     * Позволяет Gemini обращаться к данным приложения
     */
    fun handleGeminiQuery(query: String, contextData: JSONObject? = null): String {
        return try {
            Log.d(TAG, "Handling Gemini query: $query")
            
            val lowerQuery = query.lowercase()
            
            // Определяем тип запроса и выполняем действие
            when {
                // Запросы на открытие экранов
                lowerQuery.contains("баланс", ignoreCase = true) || 
                lowerQuery.contains("balance", ignoreCase = true) -> {
                    openScreen("balance")
                    "Открыл баланс в приложении Бари"
                }
                
                lowerQuery.contains("копилк", ignoreCase = true) || 
                lowerQuery.contains("piggy", ignoreCase = true) -> {
                    openScreen("piggy_banks")
                    "Открыл копилки в приложении Бари"
                }
                
                lowerQuery.contains("календар", ignoreCase = true) || 
                lowerQuery.contains("calendar", ignoreCase = true) -> {
                    openScreen("calendar")
                    "Открыл календарь в приложении Бари"
                }
                
                lowerQuery.contains("заметк", ignoreCase = true) || 
                lowerQuery.contains("note", ignoreCase = true) -> {
                    openScreen("notes")
                    "Открыл заметки в приложении Бари"
                }
                
                // Запросы на создание
                lowerQuery.contains("создай заметку", ignoreCase = true) || 
                lowerQuery.contains("create note", ignoreCase = true) -> {
                    createNote()
                    "Создаю новую заметку в Бари"
                }
                
                lowerQuery.contains("создай событие", ignoreCase = true) || 
                lowerQuery.contains("create event", ignoreCase = true) -> {
                    createEvent()
                    "Создаю новое событие в Бари"
                }
                
                // Запросы на получение данных
                lowerQuery.contains("транзакц", ignoreCase = true) || 
                lowerQuery.contains("transaction", ignoreCase = true) -> {
                    getTransactionData(contextData)
                }
                
                lowerQuery.contains("сколько денег", ignoreCase = true) || 
                lowerQuery.contains("how much money", ignoreCase = true) -> {
                    getBalanceData(contextData)
                }
                
                lowerQuery.contains("калькулятор", ignoreCase = true) || 
                lowerQuery.contains("calculator", ignoreCase = true) -> {
                    openCalculator()
                    "Открыл калькуляторы в Бари"
                }
                
                // Вопросы к Бари
                lowerQuery.contains("спроси бари", ignoreCase = true) || 
                lowerQuery.contains("ask bari", ignoreCase = true) -> {
                    val question = extractQuestion(query)
                    askBari(question)
                    "Задал вопрос Бари: $question"
                }
                
                else -> {
                    // Если запрос не распознан, возвращаем подсказку
                    "Не понял запрос. Попробуйте: 'покажи баланс', 'открой копилки', 'создай заметку', 'спроси Бари'"
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error handling Gemini query", e)
            "Произошла ошибка при обработке запроса. Попробуйте еще раз."
        }
    }
    
    /**
     * Парсит намерение из запроса Gemini и создает Intent
     */
    private fun parseGeminiIntent(query: String, contextData: JSONObject?): Intent {
        val intent = Intent(Intent.ACTION_VIEW)
        val lowerQuery = query.lowercase()
        
        when {
            lowerQuery.contains("покажи", ignoreCase = true) || 
            lowerQuery.contains("show", ignoreCase = true) -> {
                when {
                    lowerQuery.contains("баланс", ignoreCase = true) -> 
                        intent.data = Uri.parse("bary3://screen?screen=balance")
                    lowerQuery.contains("копилк", ignoreCase = true) -> 
                        intent.data = Uri.parse("bary3://screen?screen=piggy_banks")
                    lowerQuery.contains("календар", ignoreCase = true) -> 
                        intent.data = Uri.parse("bary3://screen?screen=calendar")
                    lowerQuery.contains("заметк", ignoreCase = true) -> 
                        intent.data = Uri.parse("bary3://screen?screen=notes")
                }
            }
            
            lowerQuery.contains("создай", ignoreCase = true) || 
            lowerQuery.contains("create", ignoreCase = true) -> {
                when {
                    lowerQuery.contains("заметк", ignoreCase = true) -> 
                        intent.data = Uri.parse("bary3://note/create")
                    lowerQuery.contains("событи", ignoreCase = true) -> 
                        intent.data = Uri.parse("bary3://event/create")
                }
            }
        }
        
        return intent
    }
    
    /**
     * Открывает экран приложения через deep link
     */
    private fun openScreen(screen: String) {
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("bary3://screen?screen=$screen")).apply {
            setPackage(context.packageName)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            addCategory(Intent.CATEGORY_DEFAULT)
            addCategory(Intent.CATEGORY_BROWSABLE)
        }
        
        try {
            context.startActivity(intent)
        } catch (e: Exception) {
            Log.e(TAG, "Error opening screen: $screen", e)
        }
    }
    
    /**
     * Создает новую заметку
     */
    private fun createNote() {
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("bary3://note/create")).apply {
            setPackage(context.packageName)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
            addCategory(Intent.CATEGORY_DEFAULT)
            addCategory(Intent.CATEGORY_BROWSABLE)
        }
        
        try {
            context.startActivity(intent)
        } catch (e: Exception) {
            Log.e(TAG, "Error creating note", e)
        }
    }
    
    /**
     * Создает новое событие
     */
    private fun createEvent() {
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("bary3://event/create")).apply {
            setPackage(context.packageName)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
            addCategory(Intent.CATEGORY_DEFAULT)
            addCategory(Intent.CATEGORY_BROWSABLE)
        }
        
        try {
            context.startActivity(intent)
        } catch (e: Exception) {
            Log.e(TAG, "Error creating event", e)
        }
    }
    
    /**
     * Открывает калькуляторы
     */
    private fun openCalculator() {
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("bary3://calculator")).apply {
            setPackage(context.packageName)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
            addCategory(Intent.CATEGORY_DEFAULT)
            addCategory(Intent.CATEGORY_BROWSABLE)
        }
        
        try {
            context.startActivity(intent)
        } catch (e: Exception) {
            Log.e(TAG, "Error opening calculator", e)
        }
    }
    
    /**
     * Задает вопрос Бари
     */
    private fun askBari(question: String) {
        val encodedQuestion = Uri.encode(question)
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("bary3://bari/ask?question=$encodedQuestion")).apply {
            setPackage(context.packageName)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
            addCategory(Intent.CATEGORY_DEFAULT)
            addCategory(Intent.CATEGORY_BROWSABLE)
        }
        
        try {
            context.startActivity(intent)
        } catch (e: Exception) {
            Log.e(TAG, "Error asking Bari", e)
        }
    }
    
    /**
     * Извлекает вопрос из запроса
     */
    private fun extractQuestion(query: String): String {
        val patterns = listOf(
            "спроси бари",
            "ask bari",
            "бари, ",
            "bari, "
        )
        
        var question = query
        patterns.forEach { pattern ->
            if (question.contains(pattern, ignoreCase = true)) {
                question = question.substringAfter(pattern, "").trim()
            }
        }
        
        return if (question.isNotEmpty()) question else "Как дела?"
    }
    
    /**
     * Получает данные о транзакциях
     * В реальности нужно обращаться к Flutter через Method Channel
     */
    private fun getTransactionData(contextData: JSONObject?): String {
        // TODO: Реализовать получение данных через Method Channel
        // Пока возвращаем заглушку
        return "Для получения данных о транзакциях откройте приложение Бари"
    }
    
    /**
     * Получает данные о балансе
     */
    private fun getBalanceData(contextData: JSONObject?): String {
        // TODO: Реализовать получение данных через Method Channel
        // Пока возвращаем заглушку
        return "Для просмотра баланса откройте приложение Бари"
    }
}
