import '../bari_context.dart';
import '../bari_models.dart';
import '../bari_localization_service.dart';
import 'bari_provider.dart';

/// Умный провайдер для расчётов: проценты, умножение, прогнозы, сравнения.
/// Работает полностью офлайн и не требует AI.
class SmartMathProvider implements BariProvider {
  @override
  Future<BariResponse?> tryRespond(
    String message,
    BariContext ctx, {
    bool forceOnline = false,
  }) async {
    final m = message.toLowerCase().trim();
    
    // === ПРОЦЕНТЫ ===
    // "10% от 100", "сколько 15 процентов от 200", "10 процентов от 50 евро"
    final percentMatch = RegExp(
      r'(\d+(?:[.,]\d+)?)\s*(?:%|процент[а-яё]*)\s*(?:от|из)?\s*(\d+(?:[.,]\d+)?)',
    ).firstMatch(m);
    
    if (percentMatch != null) {
      final percent = _parseNumber(percentMatch.group(1)!);
      final base = _parseNumber(percentMatch.group(2)!);
      final result = (base * percent / 100).toStringAsFixed(2);
      final resultClean = result.endsWith('.00') 
          ? result.replaceAll('.00', '') 
          : result;
      
      return BariResponse(
        meaning: BariLocalizationService.getStringWithFallback(
          ctx.localeTag,
          (l10n) => l10n.bari_math_percentOfResult('$percent%', base.toString(), resultClean),
          '$percent% от $base = $resultClean',
        ),
        advice: BariLocalizationService.getStringWithFallback(
          ctx.localeTag,
          (l10n) => l10n.bari_math_percentAdviceWithPercent('$percent%'),
          'Полезно знать: если откладывать $percent% от дохода, это поможет копить регулярно.',
        ),
        actions: [
          BariAction(
            type: BariActionType.openCalculator,
            label: BariLocalizationService.getStringWithFallback(
              ctx.localeTag,
              (l10n) => l10n.bari_math_calculator503020,
              'Калькулятор 50/30/20',
            ),
            payload: 'budget_50_30_20',
          ),
          BariAction(
            type: BariActionType.openScreen,
            label: BariLocalizationService.getStringWithFallback(
              ctx.localeTag,
              (l10n) => l10n.bari_goal_piggyBanks,
              'Копилки',
            ),
            payload: 'piggy_banks',
          ),
          BariAction(
            type: BariActionType.explainSimpler,
            label: BariLocalizationService.getStringWithFallback(
              ctx.localeTag,
              (l10n) => l10n.bari_math_explainSimpler,
              'Объясни проще',
            ),
          ),
        ],
        confidence: 0.95,
      );
    }
    
    // === СКОЛЬКО В ГОД / МЕСЯЦ ===
    // "сколько это в год", "5 евро в месяц это сколько в год"
    final yearlyMatch = RegExp(
      r'(\d+(?:[.,]\d+)?)\s*(?:€|евро|руб|рублей|долларов|\$)?\s*(?:в\s+)?(?:месяц|мес)\D*(?:сколько|это)\D*(?:в\s+)?(?:год|году)',
    ).firstMatch(m);
    
    if (yearlyMatch != null) {
      final monthly = _parseNumber(yearlyMatch.group(1)!);
      final yearly = monthly * 12;
      
      return BariResponse(
        meaning: BariLocalizationService.getStringWithFallback(
          ctx.localeTag,
          (l10n) => l10n.bari_math_monthlyToYearlyResult(
            _formatMoney(monthly, ctx),
            _formatMoney(yearly, ctx),
          ),
          '${_formatMoney(monthly, ctx)} в месяц = ${_formatMoney(yearly, ctx)} в год',
        ),
        advice: BariLocalizationService.getStringWithFallback(
          ctx.localeTag,
          (l10n) => l10n.bari_math_monthlyToYearlyAdvice,
          'Маленькие регулярные суммы накапливаются! Подписки тоже стоит считать за год.',
        ),
        actions: [
          BariAction(
            type: BariActionType.openCalculator,
            label: BariLocalizationService.getStringWithFallback(
              ctx.localeTag,
              (l10n) => l10n.bari_math_subscriptionsCalculator,
              'Калькулятор подписок',
            ),
            payload: 'subscriptions',
          ),
          BariAction(
            type: BariActionType.openScreen,
            label: BariLocalizationService.getStringWithFallback(
              ctx.localeTag,
              (l10n) => l10n.bari_goal_piggyBanks,
              'Копилки',
            ),
            payload: 'piggy_banks',
          ),
        ],
        confidence: 0.9,
      );
    }
    
    // Альтернативный паттерн: "сколько в год если откладывать по X"
    final saveYearlyMatch = RegExp(
      r'(?:сколько|скоко)\s*(?:будет|накоп\w*|выйдет)?\s*(?:в\s+)?(?:год|году)\s*(?:если)?\s*(?:откладыва\w*|копи\w*)?\s*(?:по\s+)?(\d+(?:[.,]\d+)?)',
    ).firstMatch(m);
    
    if (saveYearlyMatch != null) {
      final monthly = _parseNumber(saveYearlyMatch.group(1)!);
      final yearly = monthly * 12;
      
      return BariResponse(
        meaning: BariLocalizationService.getStringWithFallback(
          ctx.localeTag,
          (l10n) => l10n.bari_math_saveYearlyResult(
            _formatMoney(monthly, ctx),
            _formatMoney(yearly, ctx),
          ),
          'Если откладывать по ${_formatMoney(monthly, ctx)} в месяц, за год накопится ${_formatMoney(yearly, ctx)}',
        ),
        advice: BariLocalizationService.getStringWithFallback(
          ctx.localeTag,
          (l10n) => l10n.bari_math_saveYearlyAdvice,
          'Регулярность важнее суммы! Начни с маленького и увеличивай постепенно.',
        ),
        actions: [
          BariAction(
            type: BariActionType.openScreen,
            label: BariLocalizationService.getStringWithFallback(
              ctx.localeTag,
              (l10n) => l10n.bari_goal_piggyBanks,
              'Копилки',
            ),
            payload: 'piggy_banks',
          ),
          BariAction(
            type: BariActionType.openCalculator,
            label: BariLocalizationService.getStringWithFallback(
              ctx.localeTag,
              (l10n) => l10n.bari_goal_whenWillReach,
              'Когда достигну цели',
            ),
            payload: 'goal_date',
          ),
        ],
        confidence: 0.9,
      );
    }
    
    // === СКОЛЬКО НУЖНО ОТКЛАДЫВАТЬ ===
    // "сколько откладывать чтобы накопить 1000 за 5 месяцев"
    final savePerMonthMatch = RegExp(
      r'(?:сколько|скоко)\s*(?:нужно|надо)?\s*(?:откладыва\w*|копи\w*)\s*(?:чтобы|что\s*бы)?\s*(?:накопи\w*|собра\w*)?\s*(?:на\s+)?(\d+(?:[.,]\d+)?)\s*(?:€|евро|руб\w*|\$)?\s*(?:за|через)?\s*(\d+)\s*(?:месяц|мес|недел)',
    ).firstMatch(m);
    
    if (savePerMonthMatch != null) {
      final target = _parseNumber(savePerMonthMatch.group(1)!);
      final months = int.tryParse(savePerMonthMatch.group(2)!) ?? 1;
      final isWeeks = m.contains('недел');
      final periods = isWeeks ? months : months;
      final perPeriod = target / periods;
      final periodName = isWeeks ? 'неделю' : 'месяц';
      
      return BariResponse(
        meaning: BariLocalizationService.getStringWithFallback(
          ctx.localeTag,
          (l10n) => l10n.bari_math_savePerPeriodResult(
            _formatMoney(target, ctx),
            _formatMoney(perPeriod, ctx),
            periodName,
          ),
          'Чтобы накопить ${_formatMoney(target, ctx)}, нужно откладывать по ${_formatMoney(perPeriod, ctx)} в $periodName',
        ),
        advice: BariLocalizationService.getStringWithFallback(
          ctx.localeTag,
          (l10n) => l10n.bari_math_savePerPeriodAdvice,
          'Создай копилку с этой целью — так проще не забывать!',
        ),
        actions: [
          BariAction(
            type: BariActionType.openScreen,
            label: BariLocalizationService.getStringWithFallback(
              ctx.localeTag,
              (l10n) => l10n.bari_math_createPiggyBank,
              'Создать копилку',
            ),
            payload: 'piggy_banks',
          ),
          BariAction(
            type: BariActionType.openCalculator,
            label: BariLocalizationService.getStringWithFallback(
              ctx.localeTag,
              (l10n) => l10n.bari_math_whenWillReach,
              'Когда достигну цели',
            ),
            payload: 'goal_date',
          ),
        ],
        confidence: 0.88,
      );
    }
    
    // === СКОЛЬКО ЕЩЁ КОПИТЬ ===
    // "сколько копить если нужно 100 а есть 30"
    final remainingMatch = RegExp(
      r'(?:сколько|скоко)\s*(?:ещё|еще)?\s*(?:копи\w*|нужно|осталось)?\s*(?:если|нужно)?\s*(\d+(?:[.,]\d+)?)\s*(?:€|евро|руб\w*|\$)?\s*(?:а|и)?\s*(?:есть|накоп\w*|уже)?\s*(\d+(?:[.,]\d+)?)',
    ).firstMatch(m);
    
    if (remainingMatch != null) {
      final target = _parseNumber(remainingMatch.group(1)!);
      final current = _parseNumber(remainingMatch.group(2)!);
      final remaining = target - current;
      final percent = (current / target * 100).round();
      
      if (remaining <= 0) {
        return BariResponse(
          meaning: BariLocalizationService.getStringWithFallback(
            ctx.localeTag,
            (l10n) => l10n.bari_math_alreadyEnough,
            'Ты уже накопил(а) достаточно! 🎉',
          ),
          advice: BariLocalizationService.getStringWithFallback(
            ctx.localeTag,
            (l10n) => l10n.bari_math_alreadyEnoughAdvice,
            'Цель достигнута — можешь потратить или продолжить копить на что-то большее.',
          ),
          actions: [
            BariAction(
              type: BariActionType.openScreen,
              label: BariLocalizationService.getStringWithFallback(
                ctx.localeTag,
                (l10n) => l10n.bari_goal_piggyBanks,
                'Копилки',
              ),
              payload: 'piggy_banks',
            ),
          ],
          confidence: 0.95,
        );
      }
      
      return BariResponse(
        meaning: BariLocalizationService.getStringWithFallback(
          ctx.localeTag,
          (l10n) => l10n.bari_math_remainingToSaveResult(
            _formatMoney(remaining, ctx),
            percent,
          ),
          'Осталось накопить ${_formatMoney(remaining, ctx)} (уже $percent% от цели)',
        ),
        advice: BariLocalizationService.getStringWithFallback(
          ctx.localeTag,
          (l10n) => l10n.bari_math_remainingAdvice,
          'Ты на правильном пути! Продолжай в том же темпе.',
        ),
        actions: [
          BariAction(
            type: BariActionType.openScreen,
            label: BariLocalizationService.getStringWithFallback(
              ctx.localeTag,
              (l10n) => l10n.bari_goal_piggyBanks,
              'Копилки',
            ),
            payload: 'piggy_banks',
          ),
          BariAction(
            type: BariActionType.openCalculator,
            label: BariLocalizationService.getStringWithFallback(
              ctx.localeTag,
              (l10n) => l10n.bari_math_whenWillReach,
              'Когда достигну цели',
            ),
            payload: 'goal_date',
          ),
        ],
        confidence: 0.88,
      );
    }
    
    // === УМНОЖЕНИЕ / ДЕЛЕНИЕ ===
    // "сколько будет 5 умножить на 12", "100 разделить на 4"
    final mathMatch = RegExp(
      r'(\d+(?:[.,]\d+)?)\s*(?:умнож\w*|[*×x]|\sна\s)\s*(\d+(?:[.,]\d+)?)',
    ).firstMatch(m);
    
    if (mathMatch != null && (m.contains('умнож') || m.contains('сколько'))) {
      final a = _parseNumber(mathMatch.group(1)!);
      final b = _parseNumber(mathMatch.group(2)!);
      final result = a * b;
      
      return BariResponse(
        meaning: BariLocalizationService.getStringWithFallback(
          ctx.localeTag,
          (l10n) => l10n.bari_math_multiplyResult(
            a.toString(),
            b.toString(),
            _formatNumber(result),
          ),
          '$a × $b = ${_formatNumber(result)}',
        ),
        advice: BariLocalizationService.getStringWithFallback(
          ctx.localeTag,
          (l10n) => l10n.bari_math_multiplyAdvice,
          'Умножение помогает считать регулярные траты: ежедневные за месяц, месячные за год.',
        ),
        actions: [
          BariAction(
            type: BariActionType.openScreen,
            label: BariLocalizationService.getStringWithFallback(
              ctx.localeTag,
              (l10n) => l10n.bari_math_calculators,
              'Калькуляторы',
            ),
            payload: 'calculators',
          ),
        ],
        confidence: 0.85,
      );
    }
    
    final divideMatch = RegExp(
      r'(\d+(?:[.,]\d+)?)\s*(?:раздел\w*|поделить|[/÷])\s*(?:на\s+)?(\d+(?:[.,]\d+)?)',
    ).firstMatch(m);
    
    if (divideMatch != null) {
      final a = _parseNumber(divideMatch.group(1)!);
      final b = _parseNumber(divideMatch.group(2)!);
      if (b == 0) {
        return BariResponse(
          meaning: BariLocalizationService.getStringWithFallback(
            ctx.localeTag,
            (l10n) => l10n.bari_math_divideByZero,
            'На ноль делить нельзя!',
          ),
          advice: BariLocalizationService.getStringWithFallback(
            ctx.localeTag,
            (l10n) => l10n.bari_math_divideByZeroAdvice,
            'Это как делить пиццу между нулём друзей — некому есть.',
          ),
          actions: [
            BariAction(
              type: BariActionType.explainSimpler,
              label: BariLocalizationService.getStringWithFallback(
                ctx.localeTag,
                (l10n) => l10n.bari_math_explainSimpler,
                'Объясни проще',
              ),
            ),
          ],
          confidence: 0.9,
        );
      }
      final result = a / b;
      
      return BariResponse(
        meaning: BariLocalizationService.getStringWithFallback(
          ctx.localeTag,
          (l10n) => l10n.bari_math_divideResult(
            a.toString(),
            b.toString(),
            _formatNumber(result),
          ),
          '$a ÷ $b = ${_formatNumber(result)}',
        ),
        advice: BariLocalizationService.getStringWithFallback(
          ctx.localeTag,
          (l10n) => l10n.bari_math_divideAdvice,
          'Деление помогает понять, сколько откладывать в неделю/месяц для цели.',
        ),
        actions: [
          BariAction(
            type: BariActionType.openScreen,
            label: BariLocalizationService.getStringWithFallback(
              ctx.localeTag,
              (l10n) => l10n.bari_math_calculators,
              'Калькуляторы',
            ),
            payload: 'calculators',
          ),
        ],
        confidence: 0.85,
      );
    }
    
    // === СРАВНЕНИЕ ЦЕН ===
    // "что выгоднее 100г за 2 евро или 250г за 4.50"
    final compareMatch = RegExp(
      r'(\d+(?:[.,]\d+)?)\s*(?:г|гр|грамм|мл|шт|штук)?\s*(?:за|по|=)\s*(\d+(?:[.,]\d+)?)\s*(?:€|евро|руб\w*|\$)?\s*(?:или|или\s+же|vs)\s*(\d+(?:[.,]\d+)?)\s*(?:г|гр|грамм|мл|шт|штук)?\s*(?:за|по|=)\s*(\d+(?:[.,]\d+)?)',
    ).firstMatch(m);
    
    if (compareMatch != null) {
      final qty1 = _parseNumber(compareMatch.group(1)!);
      final price1 = _parseNumber(compareMatch.group(2)!);
      final qty2 = _parseNumber(compareMatch.group(3)!);
      final price2 = _parseNumber(compareMatch.group(4)!);
      
      final perUnit1 = price1 / qty1;
      final perUnit2 = price2 / qty2;
      
      final better = perUnit1 < perUnit2 ? 1 : 2;
      final savings = ((1 - (perUnit1 < perUnit2 ? perUnit1 : perUnit2) / 
                       (perUnit1 >= perUnit2 ? perUnit1 : perUnit2)) * 100).round();
      
      return BariResponse(
        meaning: BariLocalizationService.getStringWithFallback(
          ctx.localeTag,
          (l10n) => l10n.bari_math_priceComparisonResult(
            better,
            _formatNumber(perUnit1 < perUnit2 ? perUnit1 : perUnit2),
            _formatNumber(perUnit1 >= perUnit2 ? perUnit1 : perUnit2),
          ),
          'Вариант $better выгоднее! (${_formatNumber(perUnit1 < perUnit2 ? perUnit1 : perUnit2)} за единицу vs ${_formatNumber(perUnit1 >= perUnit2 ? perUnit1 : perUnit2)})',
        ),
        advice: BariLocalizationService.getStringWithFallback(
          ctx.localeTag,
          (l10n) => l10n.bari_math_priceComparisonAdviceWithSavings(savings),
          'Экономия ~$savings%. Но проверь: успеешь ли использовать большую упаковку?',
        ),
        actions: [
          BariAction(
            type: BariActionType.openCalculator,
            label: BariLocalizationService.getStringWithFallback(
              ctx.localeTag,
              (l10n) => l10n.bari_math_priceComparisonCalculator,
              'Сравнение цен',
            ),
            payload: 'price_comparison',
          ),
        ],
        confidence: 0.88,
      );
    }
    
    // === ПРАВИЛО 72 (сложные проценты) ===
    // "за сколько удвоится при 5%", "удвоение при 7 процентах"
    final rule72Match = RegExp(
      r'(?:удво\w*|×2|x2)\s*(?:при|за|если)?\s*(\d+(?:[.,]\d+)?)\s*(?:%|процент)',
    ).firstMatch(m);
    
    if (rule72Match != null) {
      final rate = _parseNumber(rule72Match.group(1)!);
      if (rate > 0) {
        final years = (72 / rate).round();
        
        return BariResponse(
          meaning: BariLocalizationService.getStringWithFallback(
            ctx.localeTag,
            (l10n) => l10n.bari_math_rule72Result('$rate%', '$years'),
            'При $rate% годовых деньги удвоятся примерно за $years лет',
          ),
          advice: BariLocalizationService.getStringWithFallback(
            ctx.localeTag,
            (l10n) => l10n.bari_math_rule72AdviceWithRate('$rate%'),
            'Это "Правило 72" — быстрый способ оценить рост накоплений. Чем выше %, тем быстрее рост, но и риск выше.',
          ),
          actions: [
            BariAction(
              type: BariActionType.openScreen,
              label: BariLocalizationService.getStringWithFallback(
                ctx.localeTag,
                (l10n) => l10n.bari_math_lessons,
                'Уроки',
              ),
              payload: 'lessons',
            ),
            BariAction(
              type: BariActionType.explainSimpler,
              label: BariLocalizationService.getStringWithFallback(
                ctx.localeTag,
                (l10n) => l10n.bari_math_explainSimpler,
                'Объясни проще',
              ),
            ),
          ],
          confidence: 0.85,
        );
      }
    }
    
    // === ИНФЛЯЦИЯ ===
    // "сколько будет 100 евро через 5 лет при инфляции 3%"
    final inflationMatch = RegExp(
      r'(\d+(?:[.,]\d+)?)\s*(?:€|евро|руб\w*|\$)?\s*(?:через|за)\s*(\d+)\s*(?:лет|год)\s*(?:при|если)?\s*(?:инфляц\w*)?\s*(\d+(?:[.,]\d+)?)\s*%',
    ).firstMatch(m);
    
    if (inflationMatch != null) {
      final amount = _parseNumber(inflationMatch.group(1)!);
      final years = int.tryParse(inflationMatch.group(2)!) ?? 1;
      final inflationRate = _parseNumber(inflationMatch.group(3)!) / 100;
      
      // Реальная покупательная способность
      final realValue = amount / (1 + inflationRate * years);
      
      return BariResponse(
        meaning: BariLocalizationService.getStringWithFallback(
          ctx.localeTag,
          (l10n) => l10n.bari_math_inflationResult(
            _formatMoney(amount, ctx),
            '$years',
            _formatMoney(realValue, ctx),
          ),
          '${_formatMoney(amount, ctx)} через $years лет будут "стоить" как ${_formatMoney(realValue, ctx)} сегодня',
        ),
        advice: BariLocalizationService.getStringWithFallback(
          ctx.localeTag,
          (l10n) => l10n.bari_math_inflationAdviceWithAmount(
            _formatMoney(amount, ctx),
            '$years',
          ),
          'Инфляция "съедает" деньги. Поэтому важно не только копить, но и учиться инвестировать (когда подрастёшь).',
        ),
        actions: [
          BariAction(
            type: BariActionType.openScreen,
            label: BariLocalizationService.getStringWithFallback(
              ctx.localeTag,
              (l10n) => l10n.bari_math_lessons,
              'Уроки',
            ),
            payload: 'lessons',
          ),
        ],
        confidence: 0.8,
      );
    }
    
    return null;
  }
  
  double _parseNumber(String s) {
    return double.tryParse(s.replaceAll(',', '.')) ?? 0;
  }
  
  String _formatNumber(double n) {
    if (n == n.roundToDouble()) {
      return n.round().toString();
    }
    return n.toStringAsFixed(2);
  }
  
  String _formatMoney(double amount, BariContext ctx) {
    final symbol = _getCurrencySymbol(ctx.currencyCode);
    if (amount == amount.roundToDouble()) {
      return '${amount.round()}$symbol';
    }
    return '${amount.toStringAsFixed(2)}$symbol';
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
}
