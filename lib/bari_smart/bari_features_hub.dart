import 'bari_models.dart';

/// Централизованный хаб для всех функций Бари
/// Группирует функции по категориям для удобного доступа
class BariFeaturesHub {
  /// Получить все функции по категориям
  static Map<String, List<BariAction>> getFeaturesByCategory(String locale) {
    return {
      'finance': _getFinanceFeatures(locale),
      'learning': _getLearningFeatures(locale),
      'analytics': _getAnalyticsFeatures(locale),
      'achievements': _getAchievementsFeatures(locale),
      'calculators': _getCalculatorFeatures(locale),
    };
  }

  /// Получить описание функции по ID
  static String? getFeatureDescription(String featureId, String locale) {
    final descriptions = _getFeatureDescriptions(locale);
    return descriptions[featureId];
  }

  /// Финансовые функции
  static List<BariAction> _getFinanceFeatures(String locale) {
    return [
      const BariAction(
        type: BariActionType.openScreen,
        label: '💰 Баланс',
        payload: 'balance',
      ),
      const BariAction(
        type: BariActionType.openScreen,
        label: '🐷 Копилки',
        payload: 'piggy_banks',
      ),
      const BariAction(
        type: BariActionType.openScreen,
        label: '📅 Календарь',
        payload: 'calendar',
      ),
    ];
  }

  /// Обучение
  static List<BariAction> _getLearningFeatures(String locale) {
    return [
      const BariAction(
        type: BariActionType.openScreen,
        label: '📚 Уроки',
        payload: 'lessons',
      ),
    ];
  }

  /// Аналитика
  static List<BariAction> _getAnalyticsFeatures(String locale) {
    return [
      const BariAction(
        type: BariActionType.openScreen,
        label: '📊 Прогноз',
        payload: 'calendar_forecast',
      ),
    ];
  }

  /// Достижения
  static List<BariAction> _getAchievementsFeatures(String locale) {
    return [
      const BariAction(
        type: BariActionType.openScreen,
        label: '🏆 Достижения',
        payload: 'achievements',
      ),
    ];
  }

  /// Калькуляторы
  static List<BariAction> _getCalculatorFeatures(String locale) {
    return [
      const BariAction(
        type: BariActionType.openScreen,
        label: '🧮 Калькуляторы',
        payload: 'calculators',
      ),
    ];
  }

  /// Описания функций
  static Map<String, String> _getFeatureDescriptions(String locale) {
    return {
      'balance': locale == 'ru'
          ? 'Просмотр баланса и транзакций'
          : locale == 'en'
              ? 'View balance and transactions'
              : 'Kontostand und Transaktionen anzeigen',
      'piggy_banks': locale == 'ru'
          ? 'Управление копилками и целями'
          : locale == 'en'
              ? 'Manage piggy banks and goals'
              : 'Sparschweine und Ziele verwalten',
      'calendar': locale == 'ru'
          ? 'Планирование доходов и расходов'
          : locale == 'en'
              ? 'Plan income and expenses'
              : 'Einnahmen und Ausgaben planen',
      'lessons': locale == 'ru'
          ? 'Обучение финансовой грамотности'
          : locale == 'en'
              ? 'Learn financial literacy'
              : 'Finanzkompetenz lernen',
      'achievements': locale == 'ru'
          ? 'Просмотр достижений и прогресса'
          : locale == 'en'
              ? 'View achievements and progress'
              : 'Erfolge und Fortschritt anzeigen',
      'calculators': locale == 'ru'
          ? 'Финансовые калькуляторы'
          : locale == 'en'
              ? 'Financial calculators'
              : 'Finanzrechner',
    };
  }
}
