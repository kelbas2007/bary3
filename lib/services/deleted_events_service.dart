import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/planned_event.dart';
import '../utils/repeating_events_helper.dart';

class DeletedEventsService {
  static const String _key = 'deleted_events';
  static const String _keyDeletedAt = 'deleted_at';

  /// Получить все удаленные события
  static Future<List<PlannedEvent>> getDeletedEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_key);
      if (json == null) return [];

      try {
        final List<dynamic> decoded = jsonDecode(json);
        final events = <PlannedEvent>[];
        for (var j in decoded) {
          try {
            final event = PlannedEvent.fromJson(j as Map<String, dynamic>);
            events.add(event);
          } catch (e) {
            debugPrint('Error parsing individual event: $e');
            // Пропускаем некорректные события
          }
        }
        return events;
      } catch (e) {
        debugPrint('Error decoding deleted events JSON: $e');
        // Если данные повреждены, очищаем их
        await prefs.remove(_key);
        return [];
      }
    } catch (e) {
      debugPrint('Error accessing SharedPreferences: $e');
      return [];
    }
  }

  /// Переместить событие в корзину (не удалять полностью)
  static Future<void> moveToTrash(PlannedEvent event) async {
    try {
      final deletedEvents = await getDeletedEvents();

      // Проверяем, не удалено ли уже это событие
      if (deletedEvents.any((e) => e.id == event.id)) {
        return; // Уже в корзине
      }

      deletedEvents.add(event);
      await _saveDeletedEvents(deletedEvents);

      // Сохраняем время удаления отдельно для каждого события
      final deletedAtKey = '${_keyDeletedAt}_${event.id}';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(deletedAtKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Error moving event to trash: $e');
      // Не бросаем исключение дальше, чтобы не крашить приложение
    }
  }

  /// Переместить событие в корзину вместе со всеми связанными (для повторяющихся)
  static Future<void> moveToTrashWithRelated(
    PlannedEvent event,
    List<PlannedEvent> allEvents,
  ) async {
    debugPrint('moveToTrashWithRelated started for event: ${event.id}');

    try {
      // Определяем базовый ID с помощью RepeatingEventsHelper для надежности
      final baseId = RepeatingEventsHelper.getBaseEventId(event.id);
      debugPrint('moveToTrashWithRelated: baseId = $baseId');

      if (baseId == null || baseId.isEmpty) {
        debugPrint('Cannot determine baseId for event: ${event.id}');
        // Если не можем определить baseId, перемещаем только это событие
        await moveToTrash(event);
        return;
      }

      // Находим все связанные события
      final relatedEvents = allEvents.where((e) {
        if (e.id == baseId) return true;
        if (e.id.startsWith('${baseId}_')) return true;
        return false;
      }).toList();

      debugPrint(
        'moveToTrashWithRelated: found ${relatedEvents.length} related events',
      );

      // Перемещаем все в корзину, но ограничиваем количество параллельных операций
      // Используем ограниченное количество одновременных операций
      final batchSize = 5;
      for (var i = 0; i < relatedEvents.length; i += batchSize) {
        final batch = relatedEvents.sublist(
          i,
          i + batchSize > relatedEvents.length
              ? relatedEvents.length
              : i + batchSize,
        );

        // Выполняем операции последовательно в пределах батча
        for (var relatedEvent in batch) {
          try {
            debugPrint(
              'moveToTrashWithRelated: moving event ${relatedEvent.id}',
            );
            await moveToTrash(relatedEvent);
            debugPrint(
              'moveToTrashWithRelated: successfully moved event ${relatedEvent.id}',
            );
          } catch (e) {
            debugPrint(
              'Error moving related event ${relatedEvent.id} to trash: $e',
            );
            // Продолжаем с другими событиями
          }
        }

        // Небольшая задержка между батчами для предотвращения перегрузки
        if (i + batchSize < relatedEvents.length) {
          await Future.delayed(const Duration(milliseconds: 50));
        }
      }

      debugPrint('moveToTrashWithRelated completed successfully');
    } catch (e, stackTrace) {
      debugPrint('Error in moveToTrashWithRelated: $e');
      debugPrint('Stack trace: $stackTrace');
      // Не бросаем исключение дальше
    }
  }

  /// Восстановить событие из корзины
  static Future<PlannedEvent?> restoreEvent(String eventId) async {
    final deletedEvents = await getDeletedEvents();
    final eventIndex = deletedEvents.indexWhere((e) => e.id == eventId);
    if (eventIndex < 0) {
      debugPrint('Event not found in trash: $eventId');
      return null;
    }

    final event = deletedEvents[eventIndex];

    // Удаляем из корзины
    deletedEvents.removeAt(eventIndex);
    await _saveDeletedEvents(deletedEvents);

    // Удаляем метаданные о времени удаления
    final deletedAtKey = '${_keyDeletedAt}_$eventId';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(deletedAtKey);

    // Восстанавливаем статус (если был canceled, возвращаем planned)
    return event.copyWith(status: PlannedEventStatus.planned);
  }

  /// Восстановить все связанные события
  static Future<List<PlannedEvent>> restoreEventWithRelated(
    String eventId,
  ) async {
    final deletedEvents = await getDeletedEvents();
    final eventIndex = deletedEvents.indexWhere((e) => e.id == eventId);
    if (eventIndex < 0) {
      debugPrint('Event not found in trash: $eventId');
      return [];
    }

    final event = deletedEvents[eventIndex];

    // Определяем базовый ID
    final baseId = RepeatingEventsHelper.getBaseEventId(event.id);
    if (baseId == null || baseId.isEmpty) {
      debugPrint('Cannot determine baseId for event: ${event.id}');
      return [];
    }

    // Находим все связанные удаленные события
    final relatedEvents = deletedEvents.where((e) {
      if (e.id == baseId) return true;
      if (e.id.startsWith('${baseId}_')) return true;
      return false;
    }).toList();

    // Восстанавливаем все
    final restored = <PlannedEvent>[];
    for (var relatedEvent in relatedEvents) {
      final restoredEvent = await restoreEvent(relatedEvent.id);
      if (restoredEvent != null) {
        restored.add(restoredEvent);
      }
    }

    return restored;
  }

  /// Полностью удалить событие (без возможности восстановления)
  static Future<void> permanentlyDelete(String eventId) async {
    final deletedEvents = await getDeletedEvents();
    deletedEvents.removeWhere((e) => e.id == eventId);
    await _saveDeletedEvents(deletedEvents);

    // Удаляем метаданные
    final deletedAtKey = '${_keyDeletedAt}_$eventId';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(deletedAtKey);
  }

  /// Полностью удалить все связанные события
  static Future<void> permanentlyDeleteWithRelated(String eventId) async {
    final deletedEvents = await getDeletedEvents();
    final eventIndex = deletedEvents.indexWhere((e) => e.id == eventId);
    if (eventIndex < 0) {
      debugPrint('Event not found in trash: $eventId');
      return;
    }

    final event = deletedEvents[eventIndex];

    // Определяем базовый ID
    final baseId = RepeatingEventsHelper.getBaseEventId(event.id);
    if (baseId == null || baseId.isEmpty) {
      debugPrint('Cannot determine baseId for event: ${event.id}');
      return;
    }

    // Находим и удаляем все связанные
    final relatedIds = deletedEvents
        .where((e) {
          if (e.id == baseId) return true;
          if (e.id.startsWith('${baseId}_')) return true;
          return false;
        })
        .map((e) => e.id)
        .toList();

    for (var id in relatedIds) {
      await permanentlyDelete(id);
    }
  }

  /// Получить время удаления события
  static Future<DateTime?> getDeletedAt(String eventId) async {
    final deletedAtKey = '${_keyDeletedAt}_$eventId';
    final prefs = await SharedPreferences.getInstance();
    final deletedAtStr = prefs.getString(deletedAtKey);
    if (deletedAtStr == null) return null;
    try {
      return DateTime.parse(deletedAtStr);
    } catch (e) {
      return null;
    }
  }

  /// Очистить корзину (удалить все события старше N дней)
  static Future<int> clearOldEvents({int daysOld = 30}) async {
    final deletedEvents = await getDeletedEvents();
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    final toDelete = <String>[];

    for (var event in deletedEvents) {
      final deletedAt = await getDeletedAt(event.id);
      if (deletedAt != null && deletedAt.isBefore(cutoffDate)) {
        toDelete.add(event.id);
      }
    }

    for (var id in toDelete) {
      await permanentlyDelete(id);
    }

    return toDelete.length;
  }

  static Future<void> _saveDeletedEvents(List<PlannedEvent> events) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(events.map((e) => e.toJson()).toList());
      await prefs.setString(_key, json);
    } catch (e) {
      debugPrint('Error saving deleted events: $e');
      // Не бросаем исключение дальше
    }
  }

  /// Получить количество удаленных событий
  static Future<int> getDeletedEventsCount() async {
    final events = await getDeletedEvents();
    return events.length;
  }

  /// Проверить, удалено ли событие
  static Future<bool> isEventDeleted(String eventId) async {
    final deletedAtKey = '${_keyDeletedAt}_$eventId';
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(deletedAtKey);
  }

  /// Проверить, какие из событий удалены (батч-проверка)
  /// Возвращает Set с ID удаленных событий
  static Future<Set<String>> getDeletedEventIds(List<String> eventIds) async {
    if (eventIds.isEmpty) return {};

    final prefs = await SharedPreferences.getInstance();
    final deletedIds = <String>{};

    for (var eventId in eventIds) {
      final deletedAtKey = '${_keyDeletedAt}_$eventId';
      if (prefs.containsKey(deletedAtKey)) {
        deletedIds.add(eventId);
      }
    }

    return deletedIds;
  }
}
