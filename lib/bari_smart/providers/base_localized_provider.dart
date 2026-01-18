import '../bari_models.dart';
import 'bari_provider.dart';

/// Базовый класс для провайдеров с поддержкой локализации
/// 
/// Предоставляет методы для получения локализованных строк
/// без необходимости BuildContext
abstract class BaseLocalizedProvider implements BariProvider {
  /// Извлекает язык из localeTag (ru_RU -> ru)
  String extractLocale(String localeTag) {
    if (localeTag.startsWith('ru')) return 'ru';
    if (localeTag.startsWith('en')) return 'en';
    if (localeTag.startsWith('de')) return 'de';
    return 'ru'; // fallback
  }
  
  /// Получает локализованную строку по ключу и языку
  /// 
  /// ВАЖНО: Это временное решение. В будущем нужно использовать
  /// AppLocalizations через callback или сервис локализации.
  /// 
  /// Пока использует паттерн _getText для получения строк по языку.
  String getLocalizedString(
    String localeTag,
    String Function(String locale) getter,
  ) {
    final locale = extractLocale(localeTag);
    return getter(locale);
  }
  
  /// Получает локализованную строку с параметрами
  String getLocalizedStringWithParams(
    String localeTag,
    String Function(String locale, Map<String, dynamic> params) getter,
    Map<String, dynamic> params,
  ) {
    final locale = extractLocale(localeTag);
    return getter(locale, params);
  }
  
  /// Создаёт BariAction с локализованным label
  BariAction createLocalizedAction({
    required BariActionType type,
    required String localeTag,
    required String Function(String locale) getLabel,
    String? payload,
  }) {
    final locale = extractLocale(localeTag);
    return BariAction(
      type: type,
      label: getLabel(locale),
      payload: payload,
    );
  }
}
