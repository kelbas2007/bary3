package com.example.bary3

import android.content.Context
import android.content.Intent
import android.content.pm.ShortcutInfo
import android.content.pm.ShortcutManager
import android.graphics.drawable.Icon
import android.net.Uri
import android.os.Build

/**
 * Менеджер для регистрации App Shortcuts в Google Assistant
 * Позволяет Google Assistant видеть и предлагать действия приложения
 */
class AppShortcutsManager(private val context: Context) {
    
    companion object {
        private const val MAX_SHORTCUTS = 6 // Максимум shortcuts для Google Assistant
    }
    
    /**
     * Регистрирует все shortcuts для Google Assistant
     * Вызывается при запуске приложения и при обновлении данных
     */
    fun registerShortcuts() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N_MR1) {
            return // Shortcuts API доступен только с API 25+
        }
        
        val shortcutManager = context.getSystemService(ShortcutManager::class.java)
            ?: return
        
        val shortcuts = buildShortcuts()
        
        try {
            // Устанавливаем динамические shortcuts
            shortcutManager.dynamicShortcuts = shortcuts
            
            // "Жертвуем" shortcuts для Google Assistant
            // Это позволяет Assistant видеть действия приложения
            shortcutManager.setDynamicShortcuts(shortcuts)
        } catch (e: Exception) {
            android.util.Log.e("AppShortcutsManager", "Error registering shortcuts", e)
        }
    }
    
    /**
     * Создает список shortcuts для основных действий приложения
     */
    private fun buildShortcuts(): List<ShortcutInfo> {
        val shortcuts = mutableListOf<ShortcutInfo>()
        
        // Основные экраны приложения
        shortcuts.add(
            createShortcut(
                id = "open_balance",
                shortLabel = "Баланс",
                longLabel = "Показать баланс в Бари",
                deepLink = "bary3://screen?screen=balance",
                iconRes = android.R.drawable.ic_menu_recent_history
            )
        )
        
        shortcuts.add(
            createShortcut(
                id = "open_piggy_banks",
                shortLabel = "Копилки",
                longLabel = "Открыть копилки в Бари",
                deepLink = "bary3://screen?screen=piggy_banks",
                iconRes = android.R.drawable.ic_menu_save
            )
        )
        
        shortcuts.add(
            createShortcut(
                id = "open_calendar",
                shortLabel = "Календарь",
                longLabel = "Открыть календарь в Бари",
                deepLink = "bary3://screen?screen=calendar",
                iconRes = android.R.drawable.ic_menu_my_calendar
            )
        )
        
        shortcuts.add(
            createShortcut(
                id = "open_notes",
                shortLabel = "Заметки",
                longLabel = "Открыть заметки в Бари",
                deepLink = "bary3://screen?screen=notes",
                iconRes = android.R.drawable.ic_menu_edit
            )
        )
        
        shortcuts.add(
            createShortcut(
                id = "create_note",
                shortLabel = "Создать заметку",
                longLabel = "Создать новую заметку в Бари",
                deepLink = "bary3://note/create",
                iconRes = android.R.drawable.ic_menu_add
            )
        )
        
        shortcuts.add(
            createShortcut(
                id = "open_calculator",
                shortLabel = "Калькулятор",
                longLabel = "Открыть калькуляторы в Бари",
                deepLink = "bary3://calculator",
                iconRes = android.R.drawable.ic_menu_compass
            )
        )
        
        return shortcuts.take(MAX_SHORTCUTS)
    }
    
    /**
     * Создает ShortcutInfo для конкретного действия
     */
    private fun createShortcut(
        id: String,
        shortLabel: String,
        longLabel: String,
        deepLink: String,
        iconRes: Int
    ): ShortcutInfo {
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(deepLink)).apply {
            setPackage(context.packageName)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            // Добавляем категорию для App Actions
            addCategory(Intent.CATEGORY_DEFAULT)
            addCategory(Intent.CATEGORY_BROWSABLE)
        }
        
        return ShortcutInfo.Builder(context, id)
            .setShortLabel(shortLabel)
            .setLongLabel(longLabel)
            .setIntent(intent)
            .setIcon(Icon.createWithResource(context, iconRes))
            .build()
    }
    
    /**
     * Обновляет существующий shortcut
     */
    fun updateShortcut(id: String, newLabel: String) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N_MR1) {
            return
        }
        
        val shortcutManager = context.getSystemService(ShortcutManager::class.java)
            ?: return
        
        val existingShortcut = shortcutManager.dynamicShortcuts.find { it.id == id }
        
        if (existingShortcut != null) {
            // Создаем новый shortcut с обновленным лейблом
            // Используем те же параметры, что и при создании
            val deepLink = when (id) {
                "open_balance" -> "bary3://screen?screen=balance"
                "open_piggy_banks" -> "bary3://screen?screen=piggy_banks"
                "open_calendar" -> "bary3://screen?screen=calendar"
                "open_notes" -> "bary3://screen?screen=notes"
                "create_note" -> "bary3://note/create"
                "open_calculator" -> "bary3://calculator"
                else -> "bary3://screen?screen=balance"
            }
            
            val iconRes = when (id) {
                "open_balance" -> android.R.drawable.ic_menu_recent_history
                "open_piggy_banks" -> android.R.drawable.ic_menu_save
                "open_calendar" -> android.R.drawable.ic_menu_my_calendar
                "open_notes" -> android.R.drawable.ic_menu_edit
                "create_note" -> android.R.drawable.ic_menu_add
                "open_calculator" -> android.R.drawable.ic_menu_compass
                else -> android.R.drawable.ic_menu_my_calendar
            }
            
            val shortLabel = existingShortcut.shortLabel?.toString() ?: ""
            val updated = createShortcut(id, shortLabel, newLabel, deepLink, iconRes)
            
            try {
                shortcutManager.updateShortcuts(listOf(updated))
            } catch (e: Exception) {
                android.util.Log.e("AppShortcutsManager", "Error updating shortcut", e)
            }
        }
    }
    
    /**
     * Добавляет контекстный shortcut на основе данных пользователя
     * Например, если есть активная копилка, добавляем shortcut для неё
     */
    fun addContextualShortcut(
        id: String,
        shortLabel: String,
        longLabel: String,
        deepLink: String,
        iconRes: Int = android.R.drawable.ic_menu_my_calendar
    ) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N_MR1) {
            return
        }
        
        val shortcutManager = context.getSystemService(ShortcutManager::class.java)
            ?: return
        
        val shortcut = createShortcut(id, shortLabel, longLabel, deepLink, iconRes)
        
        try {
            // Добавляем shortcut к существующим
            val currentShortcuts = shortcutManager.dynamicShortcuts.toMutableList()
            // Удаляем старый shortcut с таким же ID, если есть
            currentShortcuts.removeAll { it.id == id }
            currentShortcuts.add(shortcut)
            
            // Ограничиваем количество shortcuts
            shortcutManager.dynamicShortcuts = currentShortcuts.take(MAX_SHORTCUTS)
        } catch (e: Exception) {
            android.util.Log.e("AppShortcutsManager", "Error adding contextual shortcut", e)
        }
    }
    
    /**
     * Удаляет shortcut
     */
    fun removeShortcut(id: String) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N_MR1) {
            return
        }
        
        val shortcutManager = context.getSystemService(ShortcutManager::class.java)
            ?: return
        
        try {
            shortcutManager.removeDynamicShortcuts(listOf(id))
        } catch (e: Exception) {
            android.util.Log.e("AppShortcutsManager", "Error removing shortcut", e)
        }
    }
    
    /**
     * Получает список всех зарегистрированных shortcuts
     */
    fun getRegisteredShortcuts(): List<String> {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N_MR1) {
            return emptyList()
        }
        
        val shortcutManager = context.getSystemService(ShortcutManager::class.java)
            ?: return emptyList()
        
        return shortcutManager.dynamicShortcuts.map { it.id }
    }
}
