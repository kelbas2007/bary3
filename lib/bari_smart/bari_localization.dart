import '../l10n/app_localizations.dart';

/// Утилита для локализации ответов Бари
/// 
/// Используется в провайдерах для получения локализованных строк
class BariLocalization {
  /// Получает локализованную строку из AppLocalizations
  /// 
  /// Используется в провайдерах, где нет прямого доступа к BuildContext
  /// Вместо этого передаётся функция для получения локализации
  static String getLocalizedString(
    String localeTag,
    String Function(AppLocalizations l10n) getter,
  ) {
    // Извлекаем язык из localeTag (ru_RU -> ru)
    _extractLocale(localeTag);
    
    // Создаём временный BuildContext через Localizations.override
    // Но это не работает без BuildContext, поэтому используем другой подход
    
    // Вместо этого, провайдеры должны получать локализацию через callback
    // или через специальный сервис локализации
    
    // Пока возвращаем fallback
    return '';
  }
  
  /// Извлекает язык из localeTag
  static String _extractLocale(String localeTag) {
    if (localeTag.startsWith('ru')) return 'ru';
    if (localeTag.startsWith('en')) return 'en';
    if (localeTag.startsWith('de')) return 'de';
    return 'ru'; // fallback
  }
  
  /// Получает локализованную строку по ключу и языку
  /// 
  /// Используется когда провайдеры работают без BuildContext
  /// и нужно получить строку по ключу локализации
  static String getString(String localeTag, String key) {
    _extractLocale(localeTag);
    
    // Это временное решение - в будущем нужно использовать
    // AppLocalizations напрямую через callback или сервис
    
    // Пока возвращаем пустую строку - будет реализовано через
    // передачу функции локализации в провайдеры
    return '';
  }
}
