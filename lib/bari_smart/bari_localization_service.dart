import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Сервис локализации для провайдеров Бари
/// 
/// Позволяет получать локализованные строки без BuildContext
/// Использует lookupAppLocalizations для получения локализации
class BariLocalizationService {
  /// Получает локализованную строку по ключу и языку
  /// 
  /// Использует lookupAppLocalizations для получения локализации
  /// без BuildContext
  static String? getString(String localeTag, String Function(AppLocalizations l10n) getter) {
    try {
      // Извлекаем язык из localeTag (ru_RU -> ru)
      final locale = _extractLocale(localeTag);
      final localeObj = Locale(locale);
      
      // Используем lookupAppLocalizations для получения локализации
      final l10n = lookupAppLocalizations(localeObj);
      return getter(l10n);
    } catch (e) {
      // Если не удалось получить локализацию, возвращаем null
      debugPrint('[BariLocalizationService] Error getting localization: $e');
    }
    return null;
  }
  
  /// Извлекает язык из localeTag
  static String _extractLocale(String localeTag) {
    if (localeTag.startsWith('ru')) return 'ru';
    if (localeTag.startsWith('en')) return 'en';
    if (localeTag.startsWith('de')) return 'de';
    return 'ru'; // fallback
  }
  
  /// Получает локализованную строку с fallback
  static String getStringWithFallback(
    String localeTag,
    String Function(AppLocalizations l10n) getter,
    String fallback,
  ) {
    final result = getString(localeTag, getter);
    return result ?? fallback;
  }
}
