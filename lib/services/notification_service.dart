import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/planned_event.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';
import '../services/money_formatter.dart';
import '../screens/main_screen.dart';

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
    final id = response.id;
    if (id == null) return;

    // ID 1001 - ежедневное напоминание о расходах
    // ID 1002 - еженедельный обзор
    // ID 2000+ - повышение уровня
    // Все эти уведомления открывают экран баланса
    debugPrint('[NotificationService] Notification tapped: id=$id');
    
    // Используем tabNotifier для переключения на экран баланса
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        MainScreen.tabNotifier.value = 0; // 0 = баланс
      } catch (e) {
        debugPrint('[NotificationService] Error navigating: $e');
      }
    });
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

  /// Отменить конкретное уведомление по ID
  static Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> scheduleAllEvents() async {
    // Загружаем все запланированные события и создаём уведомления
    final events = await StorageService.getPlannedEvents();
    for (var event in events) {
      if (event.notificationEnabled && 
          event.status == PlannedEventStatus.planned &&
          event.dateTime.isAfter(DateTime.now())) {
        await scheduleEventNotification(event);
      }
    }
  }

  /// Ежедневное напоминание о записи расходов (вечером в 20:00)
  static Future<void> scheduleDailyExpenseReminder() async {
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, 20, 0);
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(Duration(days: 1));
    }

    // Получаем язык для локализации
    final language = await StorageService.getLanguage();
    final locale = language;
    
    // Локализованные строки
    final title = _getLocalizedString('notifications_dailyReminderTitle', locale);
    final body = _getLocalizedString('notifications_dailyReminderBody', locale);
    final channelName = _getLocalizedString('notifications_channelName', locale);
    final channelDescription = _getLocalizedString('notifications_channelDescription', locale);

    await _notifications.zonedSchedule(
      1001, // ID для ежедневных напоминаний
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'bari_reminders',
          channelName,
          channelDescription: channelDescription,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Еженедельный обзор (воскресенье в 18:00)
  static Future<void> scheduleWeeklyReview() async {
    final now = DateTime.now();
    // Находим следующее воскресенье
    var scheduledTime = DateTime(now.year, now.month, now.day, 18, 0);
    final daysUntilSunday = (7 - now.weekday) % 7;
    if (daysUntilSunday == 0 && scheduledTime.isBefore(now)) {
      // Если сегодня воскресенье, но время прошло, планируем на следующее
      scheduledTime = scheduledTime.add(Duration(days: 7));
    } else {
      scheduledTime = scheduledTime.add(Duration(days: daysUntilSunday == 0 ? 7 : daysUntilSunday));
    }

    // Получаем язык для локализации
    final language = await StorageService.getLanguage();
    final locale = language;
    
    // Локализованные строки
    final title = _getLocalizedString('notifications_weeklyReviewTitle', locale);
    final body = _getLocalizedString('notifications_weeklyReviewBody', locale);
    final channelName = _getLocalizedString('notifications_channelName', locale);
    final channelDescription = _getLocalizedString('notifications_channelDescription', locale);

    await _notifications.zonedSchedule(
      1002, // ID для еженедельных обзоров
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'bari_reminders',
          channelName,
          channelDescription: channelDescription,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Уведомление о повышении уровня
  static Future<void> scheduleLevelUpNotification(int newLevel) async {
    // Получаем язык для локализации
    final language = await StorageService.getLanguage();
    final locale = language;
    
    // Локализованные строки
    final title = _getLocalizedString('notifications_levelUpTitle', locale);
    final body = _getLocalizedString('notifications_levelUpBody', locale).replaceAll('{level}', newLevel.toString());
    final channelName = _getLocalizedString('notifications_levelUpChannelName', locale);
    final channelDescription = _getLocalizedString('notifications_levelUpChannelDescription', locale);

    await _notifications.show(
      2000 + newLevel,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'level_up',
          channelName,
          channelDescription: channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  /// Получает локализованную строку по ключу и языку
  static String _getLocalizedString(String key, String locale) {
    final localeMap = {
      'ru': {
        'notifications_dailyReminderTitle': 'Бари напоминает',
        'notifications_dailyReminderBody': 'Не забудь записать сегодняшние расходы! 💰',
        'notifications_weeklyReviewTitle': 'Бари напоминает',
        'notifications_weeklyReviewBody': 'Пора подвести итоги недели! Посмотри, сколько ты сэкономил 📊',
        'notifications_levelUpTitle': '🎉 Новый уровень!',
        'notifications_levelUpBody': 'Поздравляю! Ты достиг уровня {level}',
        'notifications_channelName': 'Напоминания Бари',
        'notifications_channelDescription': 'Персональные напоминания от Бари',
        'notifications_levelUpChannelName': 'Повышение уровня',
        'notifications_levelUpChannelDescription': 'Уведомления о повышении уровня',
      },
      'en': {
        'notifications_dailyReminderTitle': 'Bari reminds',
        'notifications_dailyReminderBody': 'Don\'t forget to log today\'s expenses! 💰',
        'notifications_weeklyReviewTitle': 'Bari reminds',
        'notifications_weeklyReviewBody': 'Time to review the week! See how much you saved 📊',
        'notifications_levelUpTitle': '🎉 New level!',
        'notifications_levelUpBody': 'Congratulations! You reached level {level}',
        'notifications_channelName': 'Bari Reminders',
        'notifications_channelDescription': 'Personal reminders from Bari',
        'notifications_levelUpChannelName': 'Level Up',
        'notifications_levelUpChannelDescription': 'Level up notifications',
      },
      'de': {
        'notifications_dailyReminderTitle': 'Bari erinnert',
        'notifications_dailyReminderBody': 'Vergiss nicht, die heutigen Ausgaben zu erfassen! 💰',
        'notifications_weeklyReviewTitle': 'Bari erinnert',
        'notifications_weeklyReviewBody': 'Zeit für die Wochenübersicht! Sieh, wie viel du gespart hast 📊',
        'notifications_levelUpTitle': '🎉 Neues Level!',
        'notifications_levelUpBody': 'Glückwunsch! Du hast Level {level} erreicht',
        'notifications_channelName': 'Bari Erinnerungen',
        'notifications_channelDescription': 'Persönliche Erinnerungen von Bari',
        'notifications_levelUpChannelName': 'Level-Up',
        'notifications_levelUpChannelDescription': 'Level-Up-Benachrichtigungen',
      },
    };
    
    final lang = locale.startsWith('ru') ? 'ru' : locale.startsWith('en') ? 'en' : locale.startsWith('de') ? 'de' : 'ru';
    return localeMap[lang]?[key] ?? localeMap['ru']![key]!;
  }
}
