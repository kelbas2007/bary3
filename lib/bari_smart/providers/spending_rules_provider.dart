import '../bari_context.dart';
import '../bari_models.dart';
import 'bari_provider.dart';

/// Rule-based провайдер для анализа трат и дачи советов по расходам.
/// Работает полностью офлайн на основе правил и шаблонов.
class SpendingRulesProvider implements BariProvider {
  @override
  Future<BariResponse?> tryRespond(
    String text,
    BariContext ctx, {
    bool forceOnline = false,
  }) async {
    final lower = text.toLowerCase();
    
    // Проверяем, относится ли вопрос к тратам/расходам
    if (!_matchesPattern(lower, [
      'трат', 'расход', 'spend', 'expense', 'куда уходят', 'где деньги',
      'почему нет денег', 'почему кончаются', 'анализ трат',
      'как трачу', 'на что трачу', 'куда делись',
    ])) {
      return null;
    }

    final locale = _extractLocale(ctx.localeTag);
    final income30 = ctx.getIncomeLastDays(30);
    final expense30 = ctx.getExpensesLastDays(30);

    // Если нет данных
    if (income30 <= 0 || expense30 <= 0) {
      return _buildNoDataResponse(ctx, locale);
    }

    final ratio = expense30 / income30;
    final symbol = _getCurrencySymbol(ctx.currencyCode);
    final incomeFormatted = (income30 / 100).toStringAsFixed(2);
    final expenseFormatted = (expense30 / 100).toStringAsFixed(2);

    // Анализируем соотношение трат к доходам
    if (ratio > 0.9) {
      return _buildHighSpendingResponse(ctx, locale, incomeFormatted, expenseFormatted, symbol);
    }

    if (ratio > 0.7) {
      return _buildModerateSpendingResponse(ctx, locale, incomeFormatted, expenseFormatted, symbol);
    }

    return _buildGoodSpendingResponse(ctx, locale, incomeFormatted, expenseFormatted, symbol);
  }

  bool _matchesPattern(String message, List<String> patterns) {
    return patterns.any((p) => message.contains(p));
  }

  String _extractLocale(String localeTag) {
    if (localeTag.startsWith('ru')) return 'ru';
    if (localeTag.startsWith('en')) return 'en';
    if (localeTag.startsWith('de')) return 'de';
    return 'ru';
  }

  String _getCurrencySymbol(String code) {
    switch (code.toUpperCase()) {
      case 'EUR': return '€';
      case 'USD': return '\$';
      case 'RUB': return '₽';
      case 'CHF': return 'CHF';
      case 'GBP': return '£';
      default: return code;
    }
  }

  BariResponse _buildNoDataResponse(BariContext ctx, String locale) {
    final responses = {
      'ru': const BariResponse(
        meaning: 'Пока мало данных о твоих доходах и расходах.',
        advice: 'Продолжай записывать операции — тогда я смогу подсказать больше.',
        actions: [
          BariAction(
            type: BariActionType.openScreen,
            label: 'Баланс',
            payload: 'balance',
          ),
        ],
        confidence: 0.8,
      ),
      'en': const BariResponse(
        meaning: 'Not enough data about your income and expenses yet.',
        advice: 'Keep recording transactions — then I can give better advice.',
        actions: [
          BariAction(
            type: BariActionType.openScreen,
            label: 'Balance',
            payload: 'balance',
          ),
        ],
        confidence: 0.8,
      ),
      'de': const BariResponse(
        meaning: 'Noch nicht genug Daten über deine Einnahmen und Ausgaben.',
        advice: 'Fahre fort, Transaktionen aufzuzeichnen — dann kann ich bessere Ratschläge geben.',
        actions: [
          BariAction(
            type: BariActionType.openScreen,
            label: 'Kontostand',
            payload: 'balance',
          ),
        ],
        confidence: 0.8,
      ),
    };
    return responses[locale] ?? responses['ru']!;
  }

  BariResponse _buildHighSpendingResponse(
    BariContext ctx,
    String locale,
    String incomeFormatted,
    String expenseFormatted,
    String symbol,
  ) {
    final responses = {
      'ru': BariResponse(
        meaning: 'Почти все деньги сразу уходят на траты. За месяц получил $incomeFormatted$symbol, потратил $expenseFormatted$symbol.',
        advice: 'Попробуй сначала откладывать хотя бы 10% дохода в копилку, а уже потом тратить.',
        actions: [
          const BariAction(
            type: BariActionType.openScreen,
            label: 'Копилки',
            payload: 'piggy_banks',
          ),
          const BariAction(
            type: BariActionType.openCalculator,
            label: '50/30/20',
            payload: 'budget_50_30_20',
          ),
        ],
        confidence: 0.9,
      ),
      'en': BariResponse(
        meaning: 'Almost all money goes to expenses immediately. This month you got $incomeFormatted$symbol, spent $expenseFormatted$symbol.',
        advice: 'Try saving at least 10% of income first, then spend the rest.',
        actions: [
          const BariAction(
            type: BariActionType.openScreen,
            label: 'Piggy Banks',
            payload: 'piggy_banks',
          ),
          const BariAction(
            type: BariActionType.openCalculator,
            label: '50/30/20',
            payload: 'budget_50_30_20',
          ),
        ],
        confidence: 0.9,
      ),
      'de': BariResponse(
        meaning: 'Fast alles Geld geht sofort für Ausgaben drauf. Diesen Monat hast du $incomeFormatted$symbol bekommen, $expenseFormatted$symbol ausgegeben.',
        advice: 'Versuche zuerst mindestens 10% des Einkommens zu sparen, dann den Rest auszugeben.',
        actions: [
          const BariAction(
            type: BariActionType.openScreen,
            label: 'Sparschweine',
            payload: 'piggy_banks',
          ),
          const BariAction(
            type: BariActionType.openCalculator,
            label: '50/30/20',
            payload: 'budget_50_30_20',
          ),
        ],
        confidence: 0.9,
      ),
    };
    return responses[locale] ?? responses['ru']!;
  }

  BariResponse _buildModerateSpendingResponse(
    BariContext ctx,
    String locale,
    String incomeFormatted,
    String expenseFormatted,
    String symbol,
  ) {
    final responses = {
      'ru': BariResponse(
        meaning: 'Ты тратишь большую часть дохода. За месяц получил $incomeFormatted$symbol, потратил $expenseFormatted$symbol.',
        advice: 'Посмотри категории, где можно чуть урезать траты и добавить в копилку.',
        actions: [
          const BariAction(
            type: BariActionType.openScreen,
            label: 'Баланс',
            payload: 'balance',
          ),
          const BariAction(
            type: BariActionType.openScreen,
            label: 'Копилки',
            payload: 'piggy_banks',
          ),
        ],
        confidence: 0.85,
      ),
      'en': BariResponse(
        meaning: 'You spend most of your income. This month you got $incomeFormatted$symbol, spent $expenseFormatted$symbol.',
        advice: 'Look at categories where you can cut expenses a bit and add to piggy bank.',
        actions: [
          const BariAction(
            type: BariActionType.openScreen,
            label: 'Balance',
            payload: 'balance',
          ),
          const BariAction(
            type: BariActionType.openScreen,
            label: 'Piggy Banks',
            payload: 'piggy_banks',
          ),
        ],
        confidence: 0.85,
      ),
      'de': BariResponse(
        meaning: 'Du gibst den größten Teil deines Einkommens aus. Diesen Monat hast du $incomeFormatted$symbol bekommen, $expenseFormatted$symbol ausgegeben.',
        advice: 'Schau dir Kategorien an, wo du Ausgaben etwas reduzieren und ins Sparschwein legen kannst.',
        actions: [
          const BariAction(
            type: BariActionType.openScreen,
            label: 'Kontostand',
            payload: 'balance',
          ),
          const BariAction(
            type: BariActionType.openScreen,
            label: 'Sparschweine',
            payload: 'piggy_banks',
          ),
        ],
        confidence: 0.85,
      ),
    };
    return responses[locale] ?? responses['ru']!;
  }

  BariResponse _buildGoodSpendingResponse(
    BariContext ctx,
    String locale,
    String incomeFormatted,
    String expenseFormatted,
    String symbol,
  ) {
    final responses = {
      'ru': BariResponse(
        meaning: 'У тебя остаётся заметная часть дохода после трат. За месяц получил $incomeFormatted$symbol, потратил $expenseFormatted$symbol.',
        advice: 'Отлично! Попробуй поставить новую цель и направить туда свободные деньги.',
        actions: [
          const BariAction(
            type: BariActionType.openScreen,
            label: 'Копилки',
            payload: 'piggy_banks',
          ),
          const BariAction(
            type: BariActionType.openCalculator,
            label: 'Когда достигну цели',
            payload: 'goal_date',
          ),
        ],
        confidence: 0.85,
      ),
      'en': BariResponse(
        meaning: 'You have a significant part of income left after expenses. This month you got $incomeFormatted$symbol, spent $expenseFormatted$symbol.',
        advice: 'Great! Try setting a new goal and directing free money there.',
        actions: [
          const BariAction(
            type: BariActionType.openScreen,
            label: 'Piggy Banks',
            payload: 'piggy_banks',
          ),
          const BariAction(
            type: BariActionType.openCalculator,
            label: 'Goal Date',
            payload: 'goal_date',
          ),
        ],
        confidence: 0.85,
      ),
      'de': BariResponse(
        meaning: 'Du hast einen bemerkenswerten Teil des Einkommens nach Ausgaben übrig. Diesen Monat hast du $incomeFormatted$symbol bekommen, $expenseFormatted$symbol ausgegeben.',
        advice: 'Großartig! Versuche ein neues Ziel zu setzen und freies Geld dorthin zu lenken.',
        actions: [
          const BariAction(
            type: BariActionType.openScreen,
            label: 'Sparschweine',
            payload: 'piggy_banks',
          ),
          const BariAction(
            type: BariActionType.openCalculator,
            label: 'Zieldatum',
            payload: 'goal_date',
          ),
        ],
        confidence: 0.85,
      ),
    };
    return responses[locale] ?? responses['ru']!;
  }
}
