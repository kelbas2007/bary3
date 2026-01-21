import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import 'notification_service.dart';

/// Сервис для управления умными напоминаниями Бари
class BariNotificationService {
  /// Планирует все умные напоминания Бари
  static Future<void> scheduleSmartReminders() async {
    // Проверяем, включены ли уведомления вообще
    final notificationsEnabled = await StorageService.getNotificationsEnabled();
    if (!notificationsEnabled) {
      return;
    }

    // Проверяем настройки для каждого типа напоминаний
    final dailyReminderEnabled = await StorageService.getDailyExpenseReminderEnabled();
    final weeklyReviewEnabled = await StorageService.getWeeklyReviewEnabled();

    // Планируем ежедневное напоминание
    if (dailyReminderEnabled) {
      try {
        await NotificationService.scheduleDailyExpenseReminder();
      } catch (e) {
        debugPrint('[BariNotificationService] Error scheduling daily reminder: $e');
      }
    } else {
      // Отменяем, если отключено
      await NotificationService.cancel(1001);
    }

    // Планируем еженедельный обзор
    if (weeklyReviewEnabled) {
      try {
        await NotificationService.scheduleWeeklyReview();
      } catch (e) {
        debugPrint('[BariNotificationService] Error scheduling weekly review: $e');
      }
    } else {
      // Отменяем, если отключено
      await NotificationService.cancel(1002);
    }
  }
}
