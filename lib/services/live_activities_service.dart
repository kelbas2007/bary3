import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Сервис для Live Activities и интерактивных уведомлений
/// Позволяет показывать статус работы Бари на заблокированном экране
/// и выполнять действия без открытия приложения (Zero-UI опыт)
class LiveActivitiesService {
  static const MethodChannel _channel = MethodChannel('com.bary3/live_activities');
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  static bool _initialized = false;
  
  /// Инициализирует сервис Live Activities
  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // Инициализируем уведомления для Live Activities
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
      _initialized = true;
      
      if (kDebugMode) {
        debugPrint('[LiveActivitiesService] Initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LiveActivitiesService] Error initializing: $e');
      }
    }
  }
  
  /// Показывает статус работы Бари на заблокированном экране
  /// 
  /// [status] - Текст статуса
  /// [title] - Заголовок (опционально)
  /// [actions] - Список действий, которые можно выполнить (опционально)
  static Future<void> showBariStatus({
    required String status,
    String? title,
    List<LiveActivityAction>? actions,
  }) async {
    if (!_initialized) {
      await initialize();
    }
    
    try {
      // На Android используем persistent notification
      const androidDetails = AndroidNotificationDetails(
        'bari_live_activity',
        'Бари - Live Activity',
        channelDescription: 'Показывает статус работы Бари',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        showWhen: false,
      );
      
      const notificationDetails = NotificationDetails(android: androidDetails);
      
      await _notifications.show(
        1001,
        title ?? 'Бари',
        status,
        notificationDetails,
      );
      
      // На iOS используем Live Activities через нативный код
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _channel.invokeMethod('startLiveActivity', {
          'title': title ?? 'Бари',
          'status': status,
          'actions': actions?.map((a) => {
            'id': a.id,
            'title': a.title,
            'deepLink': a.deepLink,
          }).toList(),
        });
      }
      
      if (kDebugMode) {
        debugPrint('[LiveActivitiesService] Status shown: $status');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LiveActivitiesService] Error showing status: $e');
      }
    }
  }
  
  /// Обновляет статус Live Activity
  /// 
  /// [status] - Новый текст статуса
  static Future<void> updateBariStatus(String status) async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _channel.invokeMethod('updateLiveActivity', {'status': status});
      } else {
        // На Android обновляем уведомление
        const androidDetails = AndroidNotificationDetails(
          'bari_live_activity',
          'Бари - Live Activity',
          channelDescription: 'Показывает статус работы Бари',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          showWhen: false,
        );
        
        const notificationDetails = NotificationDetails(android: androidDetails);
        
        await _notifications.show(
          1001,
          'Бари',
          status,
          notificationDetails,
        );
      }
      
      if (kDebugMode) {
        debugPrint('[LiveActivitiesService] Status updated: $status');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LiveActivitiesService] Error updating status: $e');
      }
    }
  }
  
  /// Останавливает Live Activity
  static Future<void> stopBariStatus() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _channel.invokeMethod('stopLiveActivity');
      } else {
        // На Android удаляем уведомление
        await _notifications.cancel(1001);
      }
      
      if (kDebugMode) {
        debugPrint('[LiveActivitiesService] Status stopped');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LiveActivitiesService] Error stopping status: $e');
      }
    }
  }
  
  /// Показывает интерактивное уведомление с действиями
  /// 
  /// [title] - Заголовок уведомления
  /// [body] - Текст уведомления
  /// [actions] - Список действий
  static Future<void> showInteractiveNotification({
    required String title,
    required String body,
    required List<LiveActivityAction> actions,
  }) async {
    if (!_initialized) {
      await initialize();
    }
    
    try {
      // На Android используем расширенные уведомления
      const androidDetails = AndroidNotificationDetails(
        'bari_interactive',
        'Бари - Интерактивные уведомления',
        channelDescription: 'Уведомления с действиями от Бари',
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.message,
      );
      
      const notificationDetails = NotificationDetails(android: androidDetails);
      
      await _notifications.show(
        1002,
        title,
        body,
        notificationDetails,
      );
      
      if (kDebugMode) {
        debugPrint('[LiveActivitiesService] Interactive notification shown');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LiveActivitiesService] Error showing interactive notification: $e');
      }
    }
  }
  
  /// Обработчик нажатия на уведомление
  static void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      debugPrint('[LiveActivitiesService] Notification tapped: ${response.id}');
    }
    
    // Обрабатываем действие, если оно было нажато
    if (response.actionId != null && response.actionId != 'default') {
      // Открываем deep link из действия
      // Это будет обработано через DeepLinkService
    }
  }
}

/// Модель действия для Live Activity
class LiveActivityAction {
  final String id;
  final String title;
  final String deepLink;
  
  const LiveActivityAction({
    required this.id,
    required this.title,
    required this.deepLink,
  });
}
