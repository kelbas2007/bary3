import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Сервис для управления App Shortcuts в Google Assistant
/// Позволяет регистрировать, обновлять и удалять shortcuts динамически
class AppShortcutsService {
  static const MethodChannel _channel = MethodChannel('com.bary3/app_shortcuts');
  
  /// Регистрирует все shortcuts для Google Assistant
  /// Вызывается при запуске приложения
  static Future<void> registerShortcuts() async {
    try {
      await _channel.invokeMethod('registerShortcuts');
      if (kDebugMode) {
        debugPrint('[AppShortcutsService] Shortcuts registered successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AppShortcutsService] Error registering shortcuts: $e');
      }
    }
  }
  
  /// Обновляет существующий shortcut
  /// 
  /// [id] - ID shortcut для обновления
  /// [newLabel] - Новый текст для shortcut
  static Future<void> updateShortcut(String id, String newLabel) async {
    try {
      await _channel.invokeMethod('updateShortcut', {
        'id': id,
        'label': newLabel,
      });
      if (kDebugMode) {
        debugPrint('[AppShortcutsService] Shortcut $id updated');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AppShortcutsService] Error updating shortcut: $e');
      }
    }
  }
  
  /// Добавляет контекстный shortcut на основе данных пользователя
  /// Например, если есть активная копилка, добавляем shortcut для неё
  /// 
  /// [id] - Уникальный ID shortcut
  /// [shortLabel] - Короткая метка (до 10 символов)
  /// [longLabel] - Длинная метка (до 25 символов)
  /// [deepLink] - Deep link для открытия действия
  /// [iconRes] - Ресурс иконки (опционально)
  static Future<void> addContextualShortcut({
    required String id,
    required String shortLabel,
    required String longLabel,
    required String deepLink,
    int? iconRes,
  }) async {
    try {
      await _channel.invokeMethod('addContextualShortcut', {
        'id': id,
        'shortLabel': shortLabel,
        'longLabel': longLabel,
        'deepLink': deepLink,
        if (iconRes != null) 'iconRes': iconRes,
      });
      if (kDebugMode) {
        debugPrint('[AppShortcutsService] Contextual shortcut $id added');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AppShortcutsService] Error adding contextual shortcut: $e');
      }
    }
  }
  
  /// Удаляет shortcut
  /// 
  /// [id] - ID shortcut для удаления
  static Future<void> removeShortcut(String id) async {
    try {
      await _channel.invokeMethod('removeShortcut', {'id': id});
      if (kDebugMode) {
        debugPrint('[AppShortcutsService] Shortcut $id removed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AppShortcutsService] Error removing shortcut: $e');
      }
    }
  }
  
  /// Получает список всех зарегистрированных shortcuts
  /// 
  /// Возвращает список ID shortcuts
  static Future<List<String>> getRegisteredShortcuts() async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>('getRegisteredShortcuts');
      return result?.cast<String>() ?? [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AppShortcutsService] Error getting shortcuts: $e');
      }
      return [];
    }
  }
  
  /// Добавляет контекстные shortcuts на основе данных пользователя
  /// Например, shortcuts для активных копилок, ближайших событий и т.д.
  static Future<void> addUserContextShortcuts({
    List<String>? activePiggyBanks,
    List<String>? upcomingEvents,
  }) async {
    try {
      // Добавляем shortcuts для активных копилок
      if (activePiggyBanks != null && activePiggyBanks.isNotEmpty) {
        for (var i = 0; i < activePiggyBanks.length && i < 3; i++) {
          final piggyName = activePiggyBanks[i];
          await addContextualShortcut(
            id: 'piggy_$i',
            shortLabel: piggyName.length > 10 ? piggyName.substring(0, 10) : piggyName,
            longLabel: 'Открыть копилку "$piggyName"',
            deepLink: 'bary3://screen?screen=piggy_banks&id=$i',
          );
        }
      }
      
      // Добавляем shortcuts для ближайших событий
      if (upcomingEvents != null && upcomingEvents.isNotEmpty) {
        for (var i = 0; i < upcomingEvents.length && i < 2; i++) {
          final eventName = upcomingEvents[i];
          await addContextualShortcut(
            id: 'event_$i',
            shortLabel: eventName.length > 10 ? eventName.substring(0, 10) : eventName,
            longLabel: 'Открыть событие "$eventName"',
            deepLink: 'bary3://screen?screen=calendar&event=$i',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AppShortcutsService] Error adding user context shortcuts: $e');
      }
    }
  }
}
