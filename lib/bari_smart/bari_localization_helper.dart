import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Хелпер для локализации ответов Бари без BuildContext
/// 
/// Используется в провайдерах для получения локализованных строк
/// на основе localeTag из BariContext
/// 
/// Использует AppLocalizations через lookupAppLocalizations
/// для получения локализации без BuildContext
class BariLocalizationHelper {
  /// Извлекает язык из localeTag (ru_RU -> ru)
  static String extractLocale(String localeTag) {
    if (localeTag.startsWith('ru')) return 'ru';
    if (localeTag.startsWith('en')) return 'en';
    if (localeTag.startsWith('de')) return 'de';
    return 'ru'; // fallback
  }
  
  /// Получает локализованную строку через AppLocalizations
  /// 
  /// Использует lookupAppLocalizations для получения локализации
  /// без BuildContext. Принимает функцию-геттер для получения строки
  /// из AppLocalizations.
  /// 
  /// Пример использования:
  /// ```dart
  /// BariLocalizationHelper.getString(
  ///   localeTag,
  ///   (l10n) => l10n.common_save,
  /// );
  /// ```
  static String? getString(
    String localeTag,
    String Function(AppLocalizations l10n) getter,
  ) {
    try {
      final locale = extractLocale(localeTag);
      final localeObj = Locale(locale);
      
      // Используем lookupAppLocalizations для получения локализации
      final l10n = lookupAppLocalizations(localeObj);
      return getter(l10n);
    } catch (e) {
      // Если не удалось получить локализацию, возвращаем null
      debugPrint('[BariLocalizationHelper] Error getting localization: $e');
      return null;
    }
  }
  
  /// Получает локализованную строку с параметрами через AppLocalizations
  /// 
  /// Использует lookupAppLocalizations для получения локализации
  /// без BuildContext. Принимает функцию-геттер для получения строки
  /// с параметрами из AppLocalizations.
  /// 
  /// Пример использования:
  /// ```dart
  /// BariLocalizationHelper.getStringWithParams(
  ///   localeTag,
  ///   (l10n) => l10n.someMessage(param1, param2),
  ///   {'param1': value1, 'param2': value2},
  /// );
  /// ```
  static String? getStringWithParams(
    String localeTag,
    String Function(AppLocalizations l10n) getter,
  ) {
    // Используем тот же метод getString, так как параметры
    // уже передаются через функцию-геттер
    return getString(localeTag, getter);
  }
  
  /// Получает локализованную строку с fallback
  /// 
  /// Если локализация не найдена, возвращает fallback значение
  static String getStringWithFallback(
    String localeTag,
    String Function(AppLocalizations l10n) getter,
    String fallback,
  ) {
    final result = getString(localeTag, getter);
    return result ?? fallback;
  }
}
