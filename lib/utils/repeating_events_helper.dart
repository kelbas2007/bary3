import '../models/planned_event.dart';

/// Утилиты для работы с повторяющимися событиями
class RepeatingEventsHelper {
  /// Определить базовый ID для повторяющегося события
  /// 
  /// Базовый ID - это ID без суффикса "_timestamp".
  /// Например:
  /// - "12345" -> "12345" (базовое событие)
  /// - "12345_1699123456789" -> "12345" (производное событие)
  /// 
  /// Возвращает null, если eventId пустой или null
  static String? getBaseEventId(String? eventId) {
    if (eventId == null || eventId.isEmpty) return null;
    
    final underscoreIndex = eventId.indexOf('_');
    if (underscoreIndex == -1) {
      // Нет подчеркивания - это базовое событие
      return eventId;
    } else if (underscoreIndex > 0) {
      // Есть подчеркивание не в начале - берем часть до него
      return eventId.substring(0, underscoreIndex);
    } else {
      // Подчеркивание в начале (маловероятно, но обрабатываем)
      return eventId;
    }
  }

  /// Проверить, является ли событие частью повторяющейся серии
  /// 
  /// Возвращает true, если событие имеет суффикс "_timestamp" в ID
  /// (является производным событием повторяющейся серии)
  static bool isRepeatingInstance(PlannedEvent event) {
    return event.id.contains('_');
  }

  /// Проверить, является ли событие частью повторяющейся серии
  /// (включая базовое событие с настройкой повторения)
  static bool isRepeatingSeries(PlannedEvent event) {
    return event.repeat != RepeatType.none;
  }

  /// Проверить, является ли событие базовым в повторяющейся серии
  /// (имеет настройку повторения и не имеет суффикса "_timestamp")
  static bool isBaseRepeatingEvent(PlannedEvent event) {
    return event.repeat != RepeatType.none && !event.id.contains('_');
  }

  /// Найти все связанные события по базовому ID
  /// 
  /// Связанные события - это базовое событие и все его производные
  /// (с ID вида "baseId_timestamp")
  static List<PlannedEvent> findRelatedEvents(
    List<PlannedEvent> allEvents,
    String? baseId,
  ) {
    if (baseId == null || baseId.isEmpty) return [];
    
    return allEvents.where((e) {
      if (e.id == baseId) return true;
      if (e.id.startsWith('${baseId}_')) return true;
      return false;
    }).toList();
  }

  /// Проверить, связаны ли два события (имеют один базовый ID)
  static bool areRelated(PlannedEvent event1, PlannedEvent event2) {
    final baseId1 = getBaseEventId(event1.id);
    final baseId2 = getBaseEventId(event2.id);
    return baseId1 != null && baseId1 == baseId2;
  }
}
