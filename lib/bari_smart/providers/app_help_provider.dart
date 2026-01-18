import '../bari_context.dart';
import '../bari_models.dart';
import 'bari_provider.dart';

class AppHelpProvider implements BariProvider {
  /// Извлекает язык из localeTag (ru_RU -> ru)
  String _extractLocale(String localeTag) {
    if (localeTag.startsWith('ru')) return 'ru';
    if (localeTag.startsWith('en')) return 'en';
    if (localeTag.startsWith('de')) return 'de';
    return 'ru'; // fallback
  }

  @override
  Future<BariResponse?> tryRespond(String message, BariContext ctx, {bool forceOnline = false}) async {
    final locale = _extractLocale(ctx.localeTag);
    final m = message.toLowerCase();

    // Локализованные паттерны
    final patterns = _getPatterns(locale);

    // Копилки и баланс
    if (_matchesPattern(m, patterns['piggy_balance']!)) {
      return _getPiggyBalanceResponse(locale);
    }

    // Лаборатория заработка
    if (_matchesPattern(m, patterns['earnings_lab']!)) {
      if (_matchesPattern(m, patterns['earnings_plan']!)) {
        return _getEarningsLabPlanResponse(locale);
      }
    }

    return null;
  }

  bool _matchesPattern(String message, List<String> patterns) {
    for (final pattern in patterns) {
      if (message.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  Map<String, List<String>> _getPatterns(String locale) {
    final patterns = {
      'ru': {
        'piggy_balance': ['копил', 'баланс', 'кошел'],
        'earnings_lab': ['лабол', 'заработ'],
        'earnings_plan': ['заплан', 'выполн'],
      },
      'en': {
        'piggy_balance': ['piggy', 'balance', 'wallet'],
        'earnings_lab': ['earnings', 'lab'],
        'earnings_plan': ['plan', 'complet'],
      },
      'de': {
        'piggy_balance': ['sparschwein', 'kontostand', 'geldbörse'],
        'earnings_lab': ['verdienst', 'labor'],
        'earnings_plan': ['plan', 'abgeschlossen'],
      },
    };
    return patterns[locale] ?? patterns['ru']!;
  }

  BariResponse _getPiggyBalanceResponse(String locale) {
    final responses = {
      'ru': const BariResponse(
        meaning: 'Баланс — это деньги в кошельке. Копилки считаются отдельно, чтобы видеть прогресс целей.',
        advice: 'Открой "Копилки", выбери цель и смотри, сколько уже накоплено.',
        actions: [
          BariAction(type: BariActionType.openScreen, label: 'Копилки', payload: 'piggy_banks'),
          BariAction(type: BariActionType.openScreen, label: 'Баланс', payload: 'balance'),
          BariAction(type: BariActionType.explainSimpler, label: 'Объясни проще'),
        ],
        confidence: 0.9,
      ),
      'en': const BariResponse(
        meaning: 'Balance is money in the wallet. Piggy banks are counted separately to see goal progress.',
        advice: 'Open "Piggy Banks", choose a goal and see how much you\'ve saved.',
        actions: [
          BariAction(type: BariActionType.openScreen, label: 'Piggy Banks', payload: 'piggy_banks'),
          BariAction(type: BariActionType.openScreen, label: 'Balance', payload: 'balance'),
          BariAction(type: BariActionType.explainSimpler, label: 'Explain simpler'),
        ],
        confidence: 0.9,
      ),
      'de': const BariResponse(
        meaning: 'Kontostand ist Geld in der Geldbörse. Sparschweine werden separat gezählt, um den Zielfortschritt zu sehen.',
        advice: 'Öffne "Sparschweine", wähle ein Ziel und sieh, wie viel du gespart hast.',
        actions: [
          BariAction(type: BariActionType.openScreen, label: 'Sparschweine', payload: 'piggy_banks'),
          BariAction(type: BariActionType.openScreen, label: 'Kontostand', payload: 'balance'),
          BariAction(type: BariActionType.explainSimpler, label: 'Einfacher erklären'),
        ],
        confidence: 0.9,
      ),
    };
    return responses[locale] ?? responses['ru']!;
  }

  BariResponse _getEarningsLabPlanResponse(String locale) {
    final responses = {
      'ru': const BariResponse(
        meaning: 'В лаборатории главное — "Запланировать". "Выполнено" выбирается через календарь, когда реально сделал.',
        advice: 'Сначала запланируй (когда сделаешь), потом отметь "Выполнено" в календаре.',
        actions: [
          BariAction(type: BariActionType.openScreen, label: 'Календарь', payload: 'calendar'),
          BariAction(type: BariActionType.openScreen, label: 'Лаборатория', payload: 'earnings_lab'),
          BariAction(type: BariActionType.explainSimpler, label: 'Объясни проще'),
        ],
        confidence: 0.88,
      ),
      'en': const BariResponse(
        meaning: 'In the lab, the main thing is "Plan". "Completed" is selected through the calendar when you actually did it.',
        advice: 'First plan (when you\'ll do it), then mark "Completed" in the calendar.',
        actions: [
          BariAction(type: BariActionType.openScreen, label: 'Calendar', payload: 'calendar'),
          BariAction(type: BariActionType.openScreen, label: 'Earnings Lab', payload: 'earnings_lab'),
          BariAction(type: BariActionType.explainSimpler, label: 'Explain simpler'),
        ],
        confidence: 0.88,
      ),
      'de': const BariResponse(
        meaning: 'Im Labor ist das Wichtigste "Planen". "Abgeschlossen" wird über den Kalender ausgewählt, wenn du es tatsächlich gemacht hast.',
        advice: 'Zuerst plane (wann du es machst), dann markiere "Abgeschlossen" im Kalender.',
        actions: [
          BariAction(type: BariActionType.openScreen, label: 'Kalender', payload: 'calendar'),
          BariAction(type: BariActionType.openScreen, label: 'Verdienstlabor', payload: 'earnings_lab'),
          BariAction(type: BariActionType.explainSimpler, label: 'Einfacher erklären'),
        ],
        confidence: 0.88,
      ),
    };
    return responses[locale] ?? responses['ru']!;
  }
}






