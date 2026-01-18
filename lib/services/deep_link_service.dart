import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Сервис для обработки deep links от системных ассистентов
class DeepLinkService {
  static const MethodChannel _channel = MethodChannel('com.bary3/system_assistant');
  static const EventChannel _eventChannel = EventChannel('com.bary3/voice_commands');
  
  static final DeepLinkService instance = DeepLinkService._();
  DeepLinkService._();
  
  StreamSubscription<dynamic>? _subscription;
  final _deepLinkController = StreamController<DeepLink>.broadcast();
  
  /// Stream для получения deep links
  Stream<DeepLink> get deepLinks => _deepLinkController.stream;
  
  /// Инициализация сервиса
  void initialize() {
    // Слушаем события от нативного кода
    _subscription = _eventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        if (event is Map) {
          final type = event['type'] as String?;
          if (type == 'deep_link') {
            final uri = event['uri'] as String?;
            if (uri != null) {
              _handleDeepLink(uri);
            }
          }
        }
      },
      onError: (error) {
        if (kDebugMode) {
          debugPrint('[DeepLinkService] Error: $error');
        }
      },
    );
  }
  
  /// Обработка deep link
  void _handleDeepLink(String uri) {
    try {
      final deepLink = DeepLink.fromUri(uri);
      _deepLinkController.add(deepLink);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DeepLinkService] Error parsing deep link: $e');
      }
    }
  }
  
  /// Обработка deep link вручную (например, при запуске приложения)
  Future<void> handleInitialLink() async {
    try {
      // Запрашиваем начальный deep link у нативного кода
      final uri = await _channel.invokeMethod<String>('getInitialLink');
      if (uri != null) {
        _handleDeepLink(uri);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DeepLinkService] Error getting initial link: $e');
      }
    }
  }
  
  void dispose() {
    _subscription?.cancel();
    _deepLinkController.close();
  }
}

/// Модель deep link
class DeepLink {
  final String scheme;
  final String? host;
  final String? path;
  final Map<String, String> parameters;
  
  DeepLink({
    required this.scheme,
    this.host,
    this.path,
    Map<String, String>? parameters,
  }) : parameters = parameters ?? {};
  
  factory DeepLink.fromUri(String uri) {
    final uriObj = Uri.parse(uri);
    final params = <String, String>{};
    
    uriObj.queryParameters.forEach((key, value) {
      params[key] = value;
    });
    
    return DeepLink(
      scheme: uriObj.scheme,
      host: uriObj.host,
      path: uriObj.path,
      parameters: params,
    );
  }
  
  /// Получить экран для навигации
  String? get screen {
    // Поддержка разных форматов: bary3://screen?screen=balance или bary3://balance
    if (path == '/screen' || host == 'screen') {
      return parameters['screen'];
    }
    // Прямой формат: bary3://balance
    if (host == 'balance' || host == 'piggy_banks' || host == 'calendar' || 
        host == 'lessons' || host == 'settings' || host == 'notes' || 
        host == 'tools' || host == 'earnings_lab' || host == 'calendar_forecast') {
      return host;
    }
    // Также проверяем path для прямых ссылок
    if (path != null && path!.isNotEmpty) {
      final pathWithoutSlash = path!.replaceFirst('/', '');
      if (pathWithoutSlash == 'balance' || pathWithoutSlash == 'piggy_banks' || 
          pathWithoutSlash == 'calendar' || pathWithoutSlash == 'lessons' || 
          pathWithoutSlash == 'settings' || pathWithoutSlash == 'notes' || 
          pathWithoutSlash == 'tools' || pathWithoutSlash == 'earnings_lab' ||
          pathWithoutSlash == 'calendar_forecast') {
        return pathWithoutSlash;
      }
    }
    return null;
  }
  
  /// Получить тип калькулятора
  String? get calculator {
    if (path == '/calculator' || host == 'calculator') {
      return parameters['type'];
    }
    // Прямой формат: bary3://calculator?type=piggy_plan
    if (host == null && path == null && parameters.containsKey('type')) {
      return parameters['type'];
    }
    return null;
  }
  
  /// Проверить, является ли это запросом к Бари
  bool get isBariQuery {
    return path == '/bari/ask' || 
           path?.startsWith('/bari') == true || 
           host == 'bari' ||
           (path != null && path!.contains('bari'));
  }
  
  /// Получить вопрос для Бари
  String? get bariQuestion {
    if (isBariQuery) {
      return parameters['question'];
    }
    return null;
  }
  
  /// Проверить, является ли это созданием заметки
  bool get isCreateNote {
    return path == '/note/create' || 
           path?.startsWith('/note') == true || 
           host == 'note' ||
           (path != null && path!.contains('note'));
  }
  
  /// Проверить, является ли это созданием события
  bool get isCreateEvent {
    return path == '/event/create' || 
           path?.startsWith('/event') == true || 
           host == 'event' ||
           (path != null && path!.contains('event'));
  }
  
  /// Проверить, является ли это импортом тестовых данных
  bool get isImportTestData {
    return path == '/import/test_data' || 
           path?.startsWith('/import') == true || 
           host == 'import' ||
           (path != null && path!.contains('import'));
  }
}
