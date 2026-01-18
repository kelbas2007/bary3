import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Сервис для работы с Gemini Nano (ML Kit GenAI)
/// 
/// Примечание: ML Kit GenAI пока не имеет готового Flutter пакета.
/// Этот сервис использует platform channels для взаимодействия с нативным кодом.
/// Для полной реализации потребуется нативная интеграция на Android.
class GeminiNanoService {
  static final GeminiNanoService _instance = GeminiNanoService._internal();
  factory GeminiNanoService() => _instance;
  GeminiNanoService._internal();

  static const MethodChannel _channel = MethodChannel('com.bary3/gemini_nano');

  bool? _isAvailable;
  bool? _isDownloaded;
  bool _initialized = false;

  /// Проверяет доступность Gemini Nano на устройстве
  /// 
  /// Требования: Android 14+, поддерживаемое устройство (Pixel 8+, Samsung S24+, etc.)
  Future<bool> checkAvailability() async {
    if (_isAvailable != null) return _isAvailable!;
    
    try {
      // Пока используем заглушку - проверяем версию Android через platform channel
      final result = await _channel.invokeMethod<bool>('checkAvailability');
      _isAvailable = result ?? false;
      
      // Fallback: проверяем через device_info_plus если нужно
      if (!_isAvailable!) {
        // Можно добавить проверку версии Android
        _isAvailable = false;
      }
      
      return _isAvailable!;
    } catch (e) {
      debugPrint('[GeminiNano] Availability check error: $e');
      // Если platform channel не настроен, возвращаем false
      _isAvailable = false;
      return false;
    }
  }

  /// Проверяет, скачана ли модель
  Future<bool> checkDownloaded() async {
    if (_isDownloaded != null) return _isDownloaded!;
    
    try {
      final result = await _channel.invokeMethod<bool>('checkModelDownloaded');
      _isDownloaded = result ?? false;
      return _isDownloaded!;
    } catch (e) {
      debugPrint('[GeminiNano] Download check error: $e');
      // Проверяем через SharedPreferences как fallback
      _isDownloaded = false;
      return false;
    }
  }

  /// Скачивает модель Gemini Nano
  /// 
  /// [onProgress] - callback с прогрессом от 0.0 до 1.0
  Future<bool> downloadModel({
    required Function(double progress) onProgress,
  }) async {
    try {
      // Настраиваем отдельный канал для прогресса
      const progressChannel = MethodChannel('com.bary3/gemini_nano_progress');
      
      // Настраиваем listener для прогресса ДО запуска скачивания
      progressChannel.setMethodCallHandler((call) async {
        debugPrint('[GeminiNano] Progress call: ${call.method}, args: ${call.arguments}');
        if (call.method == 'downloadProgress') {
          final progress = call.arguments;
          if (progress is double) {
            debugPrint('[GeminiNano] Progress: $progress');
            onProgress(progress);
          } else if (progress is int) {
            debugPrint('[GeminiNano] Progress (int): $progress');
            onProgress(progress.toDouble());
          }
        }
      });

      debugPrint('[GeminiNano] Starting download...');
      
      // Запускаем скачивание (асинхронное, будет ждать завершения)
      final result = await _channel.invokeMethod<bool>('downloadModel');
      
      debugPrint('[GeminiNano] Download result: $result');
      
      _isDownloaded = result ?? false;
      
      if (_isDownloaded!) {
        _initialized = false; // Сброс инициализации для новой модели
      }
      
      return _isDownloaded!;
    } catch (e, stackTrace) {
      debugPrint('[GeminiNano] Download error: $e');
      debugPrint('[GeminiNano] Stack trace: $stackTrace');
      _isDownloaded = false;
      return false;
    }
  }

  /// Удаляет модель
  Future<bool> deleteModel() async {
    try {
      final result = await _channel.invokeMethod<bool>('deleteModel');
      if (result == true) {
        _isDownloaded = false;
        _initialized = false;
      }
      return result ?? false;
    } catch (e) {
      debugPrint('[GeminiNano] Delete error: $e');
      return false;
    }
  }

  /// Получает размер модели в GB
  Future<double> getModelSize() async {
    try {
      final sizeBytes = await _channel.invokeMethod<int>('getModelSize');
      if (sizeBytes != null) {
        return sizeBytes / (1024 * 1024 * 1024); // Конвертируем в GB
      }
      return 2.5; // Примерный размер по умолчанию
    } catch (e) {
      return 2.5; // Примерный размер по умолчанию
    }
  }

  /// Инициализирует сессию для генерации текста
  /// 
  /// [systemPrompt] - системный промпт для настройки поведения модели
  Future<bool> initializeSession(String systemPrompt) async {
    if (!await checkDownloaded()) {
      debugPrint('[GeminiNano] Cannot initialize: model not downloaded');
      return false;
    }
    
    if (_initialized) {
      return true; // Уже инициализирован
    }
    
    try {
      final result = await _channel.invokeMethod<bool>(
        'initializeSession',
        {'systemPrompt': systemPrompt},
      );
      _initialized = result ?? false;
      return _initialized;
    } catch (e) {
      debugPrint('[GeminiNano] Session init error: $e');
      return false;
    }
  }

  /// Генерирует ответ на основе промпта
  /// 
  /// [prompt] - пользовательский промпт
  /// [locale] - язык для локализации ответа ('ru', 'en', 'de')
  Future<String?> generateResponse(String prompt, String locale) async {
    if (!_initialized) {
      debugPrint('[GeminiNano] Cannot generate: session not initialized');
      return null;
    }
    
    try {
      final result = await _channel.invokeMethod<String>(
        'generateResponse',
        {
          'prompt': prompt,
          'locale': locale,
        },
      );
      return result;
    } catch (e) {
      debugPrint('[GeminiNano] Generate error: $e');
      return null;
    }
  }

  /// Сбрасывает кэш проверок
  void resetCache() {
    _isAvailable = null;
    _isDownloaded = null;
    _initialized = false;
  }

  /// Проверяет, инициализирована ли сессия
  bool get isInitialized => _initialized;
  
  /// Проверяет, доступен ли Gemini Nano
  bool get isAvailable => _isAvailable ?? false;
  
  /// Проверяет, скачана ли модель
  bool get isDownloaded => _isDownloaded ?? false;
}
