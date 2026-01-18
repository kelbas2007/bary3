import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/planned_event.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';
import '../services/money_formatter.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Обработка нажатия на уведомление
  }

  static Future<void> scheduleEventNotification(PlannedEvent event) async {
    if (!event.notificationEnabled) return;

    final notificationTime = event.dateTime.subtract(
      Duration(minutes: event.notificationMinutesBefore ?? 60),
    );

    // Не планируем уведомления в прошлом
    if (notificationTime.isBefore(DateTime.now())) return;

    String? amountText;
    if (event.amount > 0) {
      final currencyCode = await StorageService.getCurrencyCode();
      final language = await StorageService.getLanguage();
      final locale = language;
      amountText = formatMoney(
        amountMinor: event.amount,
        currencyCode: currencyCode,
        locale: locale,
      );
    }

    await _notifications.zonedSchedule(
      event.id.hashCode,
      event.name ?? (event.type == TransactionType.income ? 'Доход' : 'Расход'),
      amountText != null
          ? 'Запланировано: $amountText'
          : 'Запланировано событие',
      tz.TZDateTime.from(notificationTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'planned_events',
          'Запланированные события',
          channelDescription:
              'Уведомления о запланированных доходах и расходах',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelEventNotification(String eventId) async {
    try {
      // Добавляем задержку для предотвращения DeadObjectException
      await Future.delayed(const Duration(milliseconds: 50));

      // Пытаемся отменить уведомление с обработкой исключений
      await _notifications.cancel(eventId.hashCode);

      debugPrint(
        'NotificationService: successfully cancelled notification for event $eventId',
      );
    } catch (e, stackTrace) {
      // Логируем ошибку, но не бросаем исключение дальше
      debugPrint('Error cancelling notification for event $eventId: $e');
      debugPrint('Stack trace: $stackTrace');

      // Если это DeadObjectException, просто логируем и продолжаем
      if (e.toString().contains('DeadObjectException') ||
          e.toString().contains('Binder')) {
        debugPrint(
          'DeadObjectException caught for event $eventId, continuing...',
        );
      }
    }
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<void> scheduleAllEvents() async {
    // Загружаем все запланированные события и создаём уведомления
    // Это можно вызвать при запуске приложения
  }
}
