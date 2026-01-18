import '../bari_context.dart';
import '../bari_models.dart';
import '../bari_localization_service.dart';
import 'bari_provider.dart';

/// Персонализированный советник по копилкам и целям.
/// Анализирует данные пользователя и даёт умные рекомендации.
class GoalAdvisorProvider implements BariProvider {
  @override
  Future<BariResponse?> tryRespond(
    String message,
    BariContext ctx, {
    bool forceOnline = false,
  }) async {
    final m = message.toLowerCase().trim();
    
    // === МОИ КОПИЛКИ / КАК ДЕЛА С ЦЕЛЯМИ ===
    if (_matchesPattern(m, [
      'мои копилки', 'мои цели', 'как копилки', 'как дела с целями',
      'прогресс копил', 'статус копил', 'покажи копилки',
      'сколько накопил', 'сколько в копилках',
    ])) {
      return _buildPiggyBanksSummary(ctx);
    }
    
    // === КАКУЮ КОПИЛКУ ПОПОЛНИТЬ ===
    if (_matchesPattern(m, [
      'какую копилку', 'куда положить', 'куда отложить',
      'какую пополнить', 'что пополнить', 'куда лучше',
    ])) {
      return _buildWhichPiggyBankAdvice(ctx);
    }
    
    // === ХВАТИТ ЛИ МНЕ НА... (персонализировано) ===
    if (_matchesPattern(m, ['хватит ли мне', 'смогу ли я', 'достаточно ли'])) {
      return _buildAffordabilityAdvice(ctx);
    }
    
    // === УСПЕЮ ЛИ НАКОПИТЬ К... ===
    final deadlineMatch = RegExp(
      r'(?:успею|смогу|получится)\s*(?:ли)?\s*(?:накопить|собрать)\s*(?:на\s+)?(\d+(?:[.,]\d+)?)\s*(?:€|евро|руб\w*|\$)?\s*(?:к|до|за|через)\s*(.+)',
    ).firstMatch(m);
    
    if (deadlineMatch != null) {
      final target = _parseNumber(deadlineMatch.group(1)!);
      final deadlineText = deadlineMatch.group(2)!;
      return _buildDeadlineAdvice(ctx, target, deadlineText);
    }
    
    // === СОВЕТ ПО НАКОПЛЕНИЯМ ===
    if (_matchesPattern(m, [
      'как копить', 'научи копить', 'совет по накопл',
      'помоги накопить', 'как откладывать', 'как начать копить',
    ])) {
      return _buildSavingAdvice(ctx);
    }
    
    // === ПОЧЕМУ НЕ ПОЛУЧАЕТСЯ КОПИТЬ ===
    if (_matchesPattern(m, [
      'не получается копить', 'не могу накопить', 'трудно копить',
      'забываю откладывать', 'деньги кончаются',
    ])) {
      return _buildTroubleshootingAdvice(ctx);
    }
    
    // === СКОЛЬКО ОТКЛАДЫВАТЬ В МЕСЯЦ ===
    if (_matchesPattern(m, [
      'сколько откладывать', 'сколько копить в месяц',
      'какой процент откладывать', 'норма накоплений',
    ])) {
      return _buildHowMuchToSaveAdvice(ctx);
    }
    
    return null;
  }
  
  bool _matchesPattern(String message, List<String> patterns) {
    return patterns.any((p) => message.contains(p));
  }
  
  double _parseNumber(String s) {
    return double.tryParse(s.replaceAll(',', '.')) ?? 0;
  }
  
  BariResponse _buildPiggyBanksSummary(BariContext ctx) {
    final banks = ctx.piggyBanks ?? [];
    
    if (banks.isEmpty) {
      final meaning = BariLocalizationService.getStringWithFallback(
        ctx.localeTag,
        (l10n) => l10n.bari_goal_noPiggyBanks,
        'У тебя пока нет копилок.',
      );
      final advice = BariLocalizationService.getStringWithFallback(
        ctx.localeTag,
        (l10n) => l10n.bari_goal_noPiggyBanksAdvice,
        'Создай первую копилку с целью — это главный шаг к накоплениям! Что хочешь купить?',
      );
      final createLabel = BariLocalizationService.getStringWithFallback(
        ctx.localeTag,
        (l10n) => l10n.bari_goal_createPiggyBank,
        'Создать копилку',
      );
      final whenLabel = BariLocalizationService.getStringWithFallback(
        ctx.localeTag,
        (l10n) => l10n.bari_goal_whenWillReach,
        'Когда достигну цели',
      );
      
      return BariResponse(
        meaning: meaning,
        advice: advice,
        actions: [
          BariAction(
            type: BariActionType.openScreen,
            label: createLabel,
            payload: 'piggy_banks',
          ),
          BariAction(
            type: BariActionType.openCalculator,
            label: whenLabel,
            payload: 'goal_date',
          ),
        ],
        confidence: 0.9,
      );
    }
    
    final totalSaved = ctx.totalPiggyBanksSaved;
    final totalSavedFormatted = _formatMoney(totalSaved / 100, ctx);
    
    // Найдём копилку с лучшим прогрессом
    double bestProgress = 0;
    String? bestName;
    double worstProgress = 100;
    String? worstName;
    
    for (final bank in banks) {
      final current = (bank['currentAmount'] as int?) ?? 0;
      final target = (bank['targetAmount'] as int?) ?? 1;
      final progress = current / target * 100;
      
      if (progress > bestProgress) {
        bestProgress = progress;
        bestName = bank['name'] as String?;
      }
      if (progress < worstProgress && target > 0) {
        worstProgress = progress;
        worstName = bank['name'] as String?;
      }
    }
    
    String statusText;
    if (banks.length == 1) {
      statusText = BariLocalizationService.getStringWithFallback(
        ctx.localeTag,
        (l10n) => l10n.bari_goal_onePiggyBank(_formatMoney(totalSaved / 100, ctx)),
        'У тебя 1 копилка с ${_formatMoney(totalSaved / 100, ctx)} внутри.',
      );
    } else {
      statusText = BariLocalizationService.getStringWithFallback(
        ctx.localeTag,
        (l10n) => l10n.bari_goal_multiplePiggyBanks(banks.length, totalSavedFormatted),
        'У тебя ${banks.length} копилок, всего накоплено $totalSavedFormatted.',
      );
    }
    
    // Rule-based анализ: проверяем дедлайны и давность пополнений
    final String? deadlineAdvice = _checkDeadlines(banks, ctx);
    final String? inactiveAdvice = _checkInactivePiggyBanks(banks, ctx);
    
    String adviceText = '';
    if (deadlineAdvice != null) {
      adviceText = deadlineAdvice;
    } else if (inactiveAdvice != null) {
      adviceText = inactiveAdvice;
    } else if (bestProgress >= 80 && bestName != null) {
      adviceText = BariLocalizationService.getStringWithFallback(
        ctx.localeTag,
        (l10n) => l10n.bari_goal_almostFull(bestName!, bestProgress.round()),
        'Копилка "$bestName" почти заполнена (${bestProgress.round()}%)! 🎉 Скоро цель!',
      );
    } else if (worstProgress < 20 && worstName != null) {
      adviceText = BariLocalizationService.getStringWithFallback(
        ctx.localeTag,
        (l10n) => l10n.bari_goal_justStarted(worstName!, worstProgress.round()),
        'Копилка "$worstName" только начата (${worstProgress.round()}%). Пора пополнить!',
      );
    } else {
      adviceText = BariLocalizationService.getStringWithFallback(
        ctx.localeTag,
        (l10n) => l10n.bari_goal_goodProgress,
        'Хороший прогресс! Продолжай откладывать регулярно.',
      );
    }
    
    return BariResponse(
      meaning: statusText,
      advice: adviceText,
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
      confidence: 0.92,
    );
  }
  
  BariResponse _buildWhichPiggyBankAdvice(BariContext ctx) {
    final banks = ctx.piggyBanks ?? [];
    
    if (banks.isEmpty) {
      return BariResponse(
        meaning: BariLocalizationService.getStringWithFallback(
          ctx.localeTag,
          (l10n) => l10n.bari_goal_createFirst,
          'У тебя пока нет копилок — создай первую!',
        ),
        advice: BariLocalizationService.getStringWithFallback(
          ctx.localeTag,
          (l10n) => l10n.bari_goal_createFirstAdvice,
          'Выбери цель: игрушка, гаджет, подарок. И начни с маленьких взносов.',
        ),
        actions: [
          BariAction(
            type: BariActionType.openScreen,
            label: BariLocalizationService.getStringWithFallback(
              ctx.localeTag,
              (l10n) => l10n.bari_goal_createPiggyBank,
              'Создать копилку',
            ),
            payload: 'piggy_banks',
          ),
        ],
        confidence: 0.9,
      );
    }
    
    // Найдём копилку, которой осталось меньше всего до цели (в %)
    double closestProgress = 0;
    String? closestName;
    int closestRemaining = 0;
    
    // Или ту, у которой скоро дедлайн
    DateTime? soonestDeadline;
    String? soonestName;
    
    for (final bank in banks) {
      final current = (bank['currentAmount'] as int?) ?? 0;
      final target = (bank['targetAmount'] as int?) ?? 1;
      final progress = current / target * 100;
      
      if (progress > closestProgress && progress < 100) {
        closestProgress = progress;
        closestName = bank['name'] as String?;
        closestRemaining = target - current;
      }
      
      // Проверяем дедлайн, если есть
      final deadlineStr = bank['targetDate'] as String?;
      if (deadlineStr != null) {
        final deadline = DateTime.tryParse(deadlineStr);
        if (deadline != null && deadline.isAfter(DateTime.now())) {
          if (soonestDeadline == null || deadline.isBefore(soonestDeadline)) {
            soonestDeadline = deadline;
            soonestName = bank['name'] as String?;
          }
        }
      }
    }
    
    String recommendation;
    if (soonestName != null && soonestDeadline != null) {
      final daysLeft = soonestDeadline.difference(DateTime.now()).inDays;
      recommendation = BariLocalizationService.getStringWithFallback(
        ctx.localeTag,
        (l10n) => l10n.bari_goal_deadlineSoon(soonestName!, daysLeft),
        'Пополни "$soonestName" — до дедлайна осталось $daysLeft дней!',
      );
    } else if (closestName != null) {
      recommendation = BariLocalizationService.getStringWithFallback(
        ctx.localeTag,
        (l10n) => l10n.bari_goal_closeToGoal(
          closestName!,
          closestProgress.round(),
          _formatMoney(closestRemaining / 100, ctx),
        ),
        'Советую пополнить "$closestName" (${closestProgress.round()}%) — осталось ${_formatMoney(closestRemaining / 100, ctx)}, ты близко к цели!',
      );
    } else {
      recommendation = BariLocalizationService.getStringWithFallback(
        ctx.localeTag,
        (l10n) => l10n.bari_goal_allFullOrEmpty,
        'Все копилки полные или пустые. Создай новую цель!',
      );
    }
    
    return BariResponse(
      meaning: recommendation,
      advice: BariLocalizationService.getStringWithFallback(
        ctx.localeTag,
        (l10n) => l10n.bari_goal_whichPiggyBankAdvice,
        'Лучше пополнять ту копилку, которая ближе к цели или у которой скоро дедлайн.',
      ),
      actions: const [
        BariAction(
          type: BariActionType.openScreen,
          label: 'Копилки',
          payload: 'piggy_banks',
        ),
      ],
      confidence: 0.88,
    );
  }
  
  BariResponse _buildAffordabilityAdvice(BariContext ctx) {
    final balance = ctx.walletBalanceCents;
    final balanceFormatted = _formatMoney(balance / 100, ctx);
    
    String advice;
    if (balance < 100) {
      advice = 'Сейчас в кошельке почти пусто ($balanceFormatted). Время подкопить!';
    } else if (balance < 1000) {
      advice = 'В кошельке $balanceFormatted — хватит на мелочи. Для большего нужен план.';
    } else if (balance < 5000) {
      advice = 'В кошельке $balanceFormatted — неплохо! Но помни про цели в копилках.';
    } else {
      advice = 'В кошельке $balanceFormatted — отлично! Подумай, стоит ли часть перевести в копилку.';
    }
    
    return BariResponse(
      meaning: 'Сейчас в кошельке $balanceFormatted',
      advice: advice,
      actions: const [
        BariAction(
          type: BariActionType.openCalculator,
          label: 'Можно ли купить?',
          payload: 'can_i_buy',
        ),
        BariAction(
          type: BariActionType.openScreen,
          label: 'Баланс',
          payload: 'balance',
        ),
      ],
      confidence: 0.85,
    );
  }
  
  BariResponse _buildDeadlineAdvice(BariContext ctx, double target, String deadlineText) {
    final balance = ctx.walletBalanceCents / 100;
    final totalSaved = ctx.totalPiggyBanksSaved / 100;
    final available = balance + totalSaved;
    
    // Простая эвристика для парсинга времени
    int? months;
    if (deadlineText.contains('месяц')) {
      months = int.tryParse(RegExp(r'\d+').firstMatch(deadlineText)?.group(0) ?? '1') ?? 1;
    } else if (deadlineText.contains('недел')) {
      final weeks = int.tryParse(RegExp(r'\d+').firstMatch(deadlineText)?.group(0) ?? '4') ?? 4;
      months = (weeks / 4).ceil();
    } else if (deadlineText.contains('год')) {
      months = 12;
    } else {
      months = 3; // По умолчанию 3 месяца
    }
    
    if (available >= target) {
      return BariResponse(
        meaning: BariLocalizationService.getStringWithFallback(
          ctx.localeTag,
          (l10n) => l10n.bari_goal_alreadyEnough,
          'Да, у тебя уже достаточно денег! 🎉',
        ),
        advice: BariLocalizationService.getStringWithFallback(
          ctx.localeTag,
          (l10n) => l10n.bari_goal_alreadyEnoughAdvice(
            _formatMoney(available, ctx),
            _formatMoney(target, ctx),
          ),
          'Всего есть ${_formatMoney(available, ctx)} (кошелёк + копилки), а нужно ${_formatMoney(target, ctx)}.',
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
        confidence: 0.9,
      );
    }
    
    final needed = target - available;
    final perMonth = needed / months;
    
    return BariResponse(
      meaning: BariLocalizationService.getStringWithFallback(
        ctx.localeTag,
        (l10n) => l10n.bari_goal_needToSave(_formatMoney(needed, ctx)),
        'Нужно накопить ещё ${_formatMoney(needed, ctx)}',
      ),
      advice: BariLocalizationService.getStringWithFallback(
        ctx.localeTag,
        (l10n) => l10n.bari_goal_savePerMonth(_formatMoney(perMonth, ctx)),
        'Если откладывать по ${_formatMoney(perMonth, ctx)} в месяц, успеешь! Создай копилку с целью.',
      ),
      actions: [
        BariAction(
          type: BariActionType.openScreen,
          label: BariLocalizationService.getStringWithFallback(
            ctx.localeTag,
            (l10n) => l10n.bari_goal_createPiggyBank,
            'Создать копилку',
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
      confidence: 0.85,
    );
  }
  
  BariResponse _buildSavingAdvice(BariContext ctx) {
    final banks = ctx.piggyBanks ?? [];
    final lessonsCompleted = ctx.lessonsCompleted;
    
    final List<String> tips = [];
    
    if (banks.isEmpty) {
      tips.add('Создай первую копилку — цель мотивирует откладывать.');
    }
    
    if (lessonsCompleted < 5) {
      tips.add('Пройди уроки — там много полезных лайфхаков по накоплениям.');
    }
    
    tips.addAll([
      'Правило "Сначала себе" — откладывай сразу после получения денег.',
      'Маленькие суммы регулярно лучше больших редко.',
      'Используй правило 24 часов перед импульсными покупками.',
    ]);
    
    return BariResponse(
      meaning: 'Главный секрет накоплений — регулярность!',
      advice: tips.take(2).join(' '),
      actions: const [
        BariAction(
          type: BariActionType.openScreen,
          label: 'Копилки',
          payload: 'piggy_banks',
        ),
        BariAction(
          type: BariActionType.openScreen,
          label: 'Уроки',
          payload: 'lessons',
        ),
        BariAction(
          type: BariActionType.openCalculator,
          label: '50/30/20',
          payload: 'budget_50_30_20',
        ),
      ],
      confidence: 0.9,
    );
  }
  
  BariResponse _buildTroubleshootingAdvice(BariContext ctx) {
    final banks = ctx.piggyBanks ?? [];
    
    String specificAdvice;
    if (banks.isEmpty) {
      specificAdvice = 'Начни с маленькой цели — это проще психологически.';
    } else {
      specificAdvice = 'Попробуй откладывать меньше, но чаще — хоть по 1€ в неделю.';
    }
    
    return BariResponse(
      meaning: 'Копить сложно, когда нет привычки — это нормально!',
      advice: '$specificAdvice Используй календарь для напоминаний.',
      actions: const [
        BariAction(
          type: BariActionType.openScreen,
          label: 'Календарь',
          payload: 'calendar',
        ),
        BariAction(
          type: BariActionType.openScreen,
          label: 'Копилки',
          payload: 'piggy_banks',
        ),
        BariAction(
          type: BariActionType.openScreen,
          label: 'Уроки',
          payload: 'lessons',
        ),
      ],
      confidence: 0.88,
    );
  }
  
  BariResponse _buildHowMuchToSaveAdvice(BariContext ctx) {
    final balance = ctx.walletBalanceCents / 100;
    
    // Рекомендуем 10-20% от "дохода" (примерно = баланс)
    final recommended10 = balance * 0.1;
    final recommended20 = balance * 0.2;
    
    String advice;
    if (balance < 10) {
      advice = 'При любом доходе откладывай хотя бы 10%. Даже 50 центов — это старт!';
    } else {
      advice = 'Попробуй откладывать 10-20% от дохода. Например, ${_formatMoney(recommended10, ctx)}-${_formatMoney(recommended20, ctx)} от текущего баланса.';
    }
    
    return BariResponse(
      meaning: 'Оптимально откладывать 10-20% от каждого дохода.',
      advice: advice,
      actions: const [
        BariAction(
          type: BariActionType.openCalculator,
          label: '50/30/20',
          payload: 'budget_50_30_20',
        ),
        BariAction(
          type: BariActionType.openScreen,
          label: 'Копилки',
          payload: 'piggy_banks',
        ),
      ],
      confidence: 0.85,
    );
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
  
  /// Rule-based проверка: цели с близким дедлайном и низким прогрессом
  String? _checkDeadlines(List<Map<String, dynamic>> banks, BariContext ctx) {
    final now = DateTime.now();
    
    for (final bank in banks) {
      final deadlineStr = bank['targetDate'] as String?;
      if (deadlineStr == null) continue;
      
      final deadline = DateTime.tryParse(deadlineStr);
      if (deadline == null) continue;
      
      final current = (bank['currentAmount'] as int?) ?? 0;
      final target = (bank['targetAmount'] as int?) ?? 1;
      final progress = target > 0 ? (current / target) : 0.0;
      final daysLeft = deadline.difference(now).inDays;
      
      // Если до дедлайна меньше 14 дней, а прогресс меньше 50%
      if (daysLeft >= 0 && daysLeft < 14 && progress < 0.5) {
        final bankName = bank['name'] as String? ?? 'цель';
        return 'До цели "$bankName" осталось $daysLeft ${_pluralDays(daysLeft)}, а накоплено меньше половины. Подумай, можешь ли увеличить взнос или перенести дату.';
      }
    }
    
    return null;
  }
  
  /// Rule-based проверка: копилки, которые давно не пополнялись
  String? _checkInactivePiggyBanks(List<Map<String, dynamic>> banks, BariContext ctx) {
    // Используем recentTransactions для определения последнего пополнения
    // Если у копилки прогресс < 10% и нет недавних транзакций в копилку, напоминаем
    final recentTransactions = ctx.recentTransactions ?? [];
    final now = DateTime.now();
    final twoWeeksAgo = now.subtract(const Duration(days: 14));
    
    // Проверяем, есть ли недавние транзакции в копилки
    bool hasRecentPiggyActivity = false;
    for (final t in recentTransactions) {
      final dateStr = t['date'] as String?;
      if (dateStr == null) continue;
      final date = DateTime.tryParse(dateStr);
      if (date == null || date.isBefore(twoWeeksAgo)) continue;
      
      final note = (t['note'] as String? ?? '').toLowerCase();
      if (note.contains('копил') || note.contains('piggy') || note.contains('цель')) {
        hasRecentPiggyActivity = true;
        break;
      }
    }
    
    // Если нет активности и есть копилки с низким прогрессом
    if (!hasRecentPiggyActivity) {
      for (final bank in banks) {
        final current = (bank['currentAmount'] as int?) ?? 0;
        final target = (bank['targetAmount'] as int?) ?? 1;
        final progress = target > 0 ? (current / target) : 0.0;
        
        if (progress < 0.1 && target > 0) {
          final bankName = bank['name'] as String? ?? 'копилка';
          return 'Ты давно не пополнял(а) "$bankName". Если цель всё ещё важна, попробуй отложить хотя бы небольшую сумму сегодня.';
        }
      }
    }
    
    return null;
  }
  
  String _pluralDays(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'день';
    if (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20)) return 'дня';
    return 'дней';
  }
}
