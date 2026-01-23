import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

/// Кэш промптов для ускорения работы LLM
///
/// Сохраняет промпты и ответы локально, чтобы избежать повторной генерации
/// одинаковых промптов для одинаковых входных данных
class PromptCache {
  static final PromptCache _instance = PromptCache._internal();
  factory PromptCache() => _instance;
  PromptCache._internal();

  static const String _cacheFileName = 'prompt_cache.json';
  static const int _maxCacheSize =
      100; // Максимальное количество записей в кэше
  static const Duration _defaultTTL = Duration(days: 7); // Время жизни записей

  Map<String, CacheEntry> _cache = {};
  bool _initialized = false;

  /// Инициализировать кэш
  Future<void> init() async {
    if (_initialized) return;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final cacheFile = File('${appDir.path}/$_cacheFileName');

      if (await cacheFile.exists()) {
        final content = await cacheFile.readAsString();
        final decoded = json.decode(content) as Map<String, dynamic>;

        _cache = decoded.map((key, value) {
          final entry = CacheEntry.fromJson(value);
          return MapEntry(key, entry);
        });

        // Удаляем просроченные записи
        _cleanExpiredEntries();
      } else {
        _cache = {};
      }

      _initialized = true;
      if (kDebugMode) {
        debugPrint('[PromptCache] Initialized with ${_cache.length} entries');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PromptCache] Error initializing cache: $e');
      }
      _cache = {};
      _initialized = true;
    }
  }

  /// Получить кэшированный ответ для промпта
  Future<String?> getCachedResponse(
    String prompt, {
    String? contextHash,
  }) async {
    await init();

    final key = _generateCacheKey(prompt, contextHash);
    final entry = _cache[key];

    if (entry == null) {
      return null;
    }

    // Проверяем не истек ли срок жизни
    if (entry.isExpired) {
      _cache.remove(key);
      await _saveCache();
      return null;
    }

    // Обновляем время последнего использования
    entry.lastUsed = DateTime.now();
    await _saveCache();

    return entry.response;
  }

  /// Сохранить ответ в кэш
  Future<void> cacheResponse(
    String prompt,
    String response, {
    String? contextHash,
    Duration? ttl,
  }) async {
    await init();

    final key = _generateCacheKey(prompt, contextHash);
    final entry = CacheEntry(
      prompt: prompt,
      response: response,
      contextHash: contextHash,
      createdAt: DateTime.now(),
      ttl: ttl ?? _defaultTTL,
    );

    _cache[key] = entry;

    // Ограничиваем размер кэша
    if (_cache.length > _maxCacheSize) {
      _trimCache();
    }

    await _saveCache();
  }

  /// Очистить кэш
  Future<void> clear() async {
    _cache.clear();
    await _saveCache();

    if (kDebugMode) {
      debugPrint('[PromptCache] Cache cleared');
    }
  }

  /// Получить статистику кэша
  Future<CacheStats> getStats() async {
    await init();

    int expiredCount = 0;
    int validCount = 0;
    int totalSize = 0;

    for (final entry in _cache.values) {
      totalSize += entry.response.length + (entry.prompt?.length ?? 0);
      if (entry.isExpired) {
        expiredCount++;
      } else {
        validCount++;
      }
    }

    return CacheStats(
      totalEntries: _cache.length,
      validEntries: validCount,
      expiredEntries: expiredCount,
      totalSize: totalSize,
      maxSize: _maxCacheSize,
    );
  }

  /// Удалить просроченные записи
  Future<void> cleanExpired() async {
    await init();
    _cleanExpiredEntries();
    await _saveCache();
  }

  /// Генерация ключа кэша на основе промпта и контекста
  String _generateCacheKey(String prompt, String? contextHash) {
    final input = contextHash != null ? '$prompt::$contextHash' : prompt;
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Очистка просроченных записей
  void _cleanExpiredEntries() {
    final keysToRemove = <String>[];

    for (final entry in _cache.entries) {
      if (entry.value.isExpired) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _cache.remove(key);
    }

    if (kDebugMode && keysToRemove.isNotEmpty) {
      debugPrint(
        '[PromptCache] Removed ${keysToRemove.length} expired entries',
      );
    }
  }

  /// Обрезка кэша до максимального размера
  void _trimCache() {
    // Сортируем записи по времени последнего использования (старые сначала)
    final sortedEntries = _cache.entries.toList()
      ..sort((a, b) => a.value.lastUsed.compareTo(b.value.lastUsed));

    final entriesToRemove = sortedEntries.length - _maxCacheSize;
    if (entriesToRemove > 0) {
      for (int i = 0; i < entriesToRemove; i++) {
        _cache.remove(sortedEntries[i].key);
      }

      if (kDebugMode) {
        debugPrint('[PromptCache] Trimmed $entriesToRemove entries');
      }
    }
  }

  /// Сохранить кэш на диск
  Future<void> _saveCache() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final cacheFile = File('${appDir.path}/$_cacheFileName');

      final jsonMap = _cache.map((key, entry) => MapEntry(key, entry.toJson()));

      final jsonString = json.encode(jsonMap);
      await cacheFile.writeAsString(jsonString);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PromptCache] Error saving cache: $e');
      }
    }
  }
}

/// Запись в кэше
class CacheEntry {
  final String? prompt;
  final String response;
  final String? contextHash;
  final DateTime createdAt;
  DateTime lastUsed;
  final Duration ttl;

  CacheEntry({
    this.prompt,
    required this.response,
    this.contextHash,
    required this.createdAt,
    DateTime? lastUsed,
    required this.ttl,
  }) : lastUsed = lastUsed ?? createdAt;

  /// Проверяет истек ли срок жизни записи
  bool get isExpired => DateTime.now().difference(createdAt) > ttl;

  /// Конвертировать в JSON
  Map<String, dynamic> toJson() {
    return {
      'prompt': prompt,
      'response': response,
      'contextHash': contextHash,
      'createdAt': createdAt.toIso8601String(),
      'lastUsed': lastUsed.toIso8601String(),
      'ttl': ttl.inSeconds,
    };
  }

  /// Создать из JSON
  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      prompt: json['prompt'],
      response: json['response'],
      contextHash: json['contextHash'],
      createdAt: DateTime.parse(json['createdAt']),
      lastUsed: DateTime.parse(json['lastUsed']),
      ttl: Duration(seconds: json['ttl']),
    );
  }
}

/// Статистика кэша
class CacheStats {
  final int totalEntries;
  final int validEntries;
  final int expiredEntries;
  final int totalSize;
  final int maxSize;

  CacheStats({
    required this.totalEntries,
    required this.validEntries,
    required this.expiredEntries,
    required this.totalSize,
    required this.maxSize,
  });

  /// Процент использования кэша
  double get usagePercentage => (totalEntries / maxSize) * 100;

  /// Средний размер записи
  double get averageEntrySize =>
      totalEntries > 0 ? totalSize / totalEntries : 0;

  @override
  String toString() {
    return 'CacheStats{total: $totalEntries, valid: $validEntries, '
        'expired: $expiredEntries, size: ${totalSize ~/ 1024}KB, '
        'usage: ${usagePercentage.toStringAsFixed(1)}%}';
  }
}

/// Декоратор для провайдера с кэшированием промптов
class CachedPromptProvider {
  final PromptCache _cache = PromptCache();
  final Future<String> Function(String prompt, {String? contextHash}) _provider;

  CachedPromptProvider(this._provider);

  /// Получить ответ с кэшированием
  Future<String> getResponse(
    String prompt, {
    String? contextHash,
    bool useCache = true,
    Duration? cacheTTL,
  }) async {
    // Если кэш отключен, просто вызываем провайдер
    if (!useCache) {
      return await _provider(prompt, contextHash: contextHash);
    }

    // Пытаемся получить из кэша
    final cachedResponse = await _cache.getCachedResponse(
      prompt,
      contextHash: contextHash,
    );
    if (cachedResponse != null) {
      if (kDebugMode) {
        debugPrint(
          '[CachedPromptProvider] Cache hit for prompt: ${prompt.substring(0, min(50, prompt.length))}...',
        );
      }
      return cachedResponse;
    }

    // Если нет в кэше, вызываем провайдер
    if (kDebugMode) {
      debugPrint(
        '[CachedPromptProvider] Cache miss for prompt: ${prompt.substring(0, min(50, prompt.length))}...',
      );
    }

    final response = await _provider(prompt, contextHash: contextHash);

    // Сохраняем в кэш
    await _cache.cacheResponse(
      prompt,
      response,
      contextHash: contextHash,
      ttl: cacheTTL,
    );

    return response;
  }

  /// Очистить кэш
  Future<void> clearCache() async {
    await _cache.clear();
  }

  /// Получить статистику кэша
  Future<CacheStats> getCacheStats() async {
    return await _cache.getStats();
  }

  /// Утилита для получения минимального значения
  int min(int a, int b) => a < b ? a : b;
}
