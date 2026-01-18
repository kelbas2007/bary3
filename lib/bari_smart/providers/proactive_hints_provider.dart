import '../bari_context.dart';
import '../bari_models.dart';

/// Провайдер проактивных подсказок Бари
/// 
/// Анализирует контекст пользователя и предлагает умные действия:
/// - Учитывает недавние действия пользователя
/// - Не повторяет одни и те же подсказки
/// - Предлагает разнообразные действия
/// - Использует систему приоритетов
class ProactiveHintsProvider {
  const ProactiveHintsProvider();

  /// Главный метод: возвращает 0 или 1 подсказку на основе контекста
  /// Учитывает недавние действия и избегает повторений
  Future<BariResponse?> getHint(BariContext ctx) async {
    // Собираем все возможные подсказки с приоритетами
    final hints = <_HintCandidate>[];
    
    // Правило 1: Низкий баланс, но есть запланированные расходы (высокий приоритет)
    if (_shouldSuggestEarnings(ctx)) {
      hints.add(_HintCandidate(
        priority: 9,
        hintType: 'earnings_lab',
        response: _buildEarningsHint(ctx),
        checkRecent: () => !_hasRecentAction(ctx, 'earnings_lab', hours: 12),
      ));
    }
    
    // Правило 2: Много трат за 7 дней, мало доходов
    if (_shouldSuggestExpenses(ctx)) {
      hints.add(_HintCandidate(
        priority: 8,
        hintType: 'expenses',
        response: _buildExpensesHint(ctx),
        checkRecent: () => !_hasRecentAction(ctx, 'parent_stats', hours: 24),
      ));
    }
    
    // Правило 3: Застывшие копилки
    final piggyHint = _shouldSuggestPiggyTopUp(ctx);
    if (piggyHint != null) {
      hints.add(_HintCandidate(
        priority: 7,
        hintType: 'piggy_topup',
        response: piggyHint,
        checkRecent: () => !_hasRecentAction(ctx, 'earnings_lab', hours: 48) &&
                           !_hasRecentPiggyTopUp(ctx, hours: 48),
      ));
    }
    
    // Правило 4: Много доходов, но нет целей (копилок)
    if (_shouldSuggestCreatePiggy(ctx)) {
      hints.add(_HintCandidate(
        priority: 7,
        hintType: 'create_piggy',
        response: _buildCreatePiggyHint(ctx),
        checkRecent: () => !_hasRecentAction(ctx, 'piggy_banks', hours: 24),
      ));
    }
    
    // Правило 5: Уроки - ТОЛЬКО если не было урока сегодня
    if (_shouldSuggestLesson(ctx)) {
      hints.add(_HintCandidate(
        priority: 6,
        hintType: 'lesson',
        response: _buildLessonHint(ctx),
        checkRecent: () => !_hasRecentLessonToday(ctx) &&
                           !_hasRecentAction(ctx, 'lessons', hours: 24),
      ));
    }
    
    // Правило 6: Часто траты на одну категорию → предложить калькулятор бюджета
    final budgetHint = _shouldSuggestBudget(ctx);
    if (budgetHint != null) {
      hints.add(_HintCandidate(
        priority: 5,
        hintType: 'budget',
        response: budgetHint,
        checkRecent: () => !_hasRecentAction(ctx, 'monthly_budget', hours: 72),
      ));
    }
    
    // Правило 7: Нет запланированных событий → предложить планирование
    if (_shouldSuggestPlanning(ctx)) {
      hints.add(_HintCandidate(
        priority: 4,
        hintType: 'planning',
        response: _buildPlanningHint(ctx),
        checkRecent: () => !_hasRecentAction(ctx, 'plan', hours: 24),
      ));
    }
    
    // Фильтруем по недавним действиям и недавно показанным подсказкам
    final validHints = hints
        .where((h) => h.checkRecent() && !_wasHintShownRecently(ctx, h.hintType))
        .toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));
    
    // Выбираем случайный из топ-3 для разнообразия
    if (validHints.isNotEmpty) {
      final topHints = validHints.take(3).toList();
      final randomIndex = DateTime.now().millisecond % topHints.length;
      return topHints[randomIndex].response;
    }
    
    return null; // Нет подходящей подсказки
  }
  
  // Проверка: был ли урок пройден сегодня
  bool _hasRecentLessonToday(BariContext ctx) {
    final lastLesson = ctx.lastLessonCompletedAt;
    if (lastLesson == null) return false;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lessonDate = DateTime(lastLesson.year, lastLesson.month, lastLesson.day);
    
    return lessonDate.isAtSameMomentAs(today);
  }
  
  // Проверка: было ли недавно действие
  bool _hasRecentAction(BariContext ctx, String actionType, {required int hours}) {
    if (ctx.recentActions == null) return false;
    
    final cutoff = DateTime.now().subtract(Duration(hours: hours));
    
    return ctx.recentActions!.any((action) {
      final timestamp = DateTime.tryParse(action['timestamp'] as String? ?? '');
      if (timestamp == null || timestamp.isBefore(cutoff)) return false;
      
      // Проверяем тип действия или payload
      final type = action['type']?.toString() ?? '';
      final payload = action['payload']?.toString() ?? '';
      
      return type.contains(actionType) || payload.contains(actionType);
    });
  }
  
  // Проверка: было ли недавно пополнение копилки
  bool _hasRecentPiggyTopUp(BariContext ctx, {required int hours}) {
    final lastTopUp = ctx.lastPiggyTopUpAt;
    if (lastTopUp == null) return false;
    
    final cutoff = DateTime.now().subtract(Duration(hours: hours));
    return lastTopUp.isAfter(cutoff);
  }
  
  // Проверка: была ли недавно показана подсказка этого типа
  bool _wasHintShownRecently(BariContext ctx, String hintType) {
    if (ctx.recentHintTypes == null) return false;
    
    // Проверяем последние 3 подсказки
    final recentHints = ctx.recentHintTypes!.take(3).toList();
    return recentHints.contains(hintType);
  }
  
  // Проверки условий для подсказок
  bool _shouldSuggestEarnings(BariContext ctx) {
    return ctx.walletBalanceCents < 1000 && 
           ctx.calendarEvents != null && 
           ctx.calendarEvents!.isNotEmpty;
  }
  
  bool _shouldSuggestExpenses(BariContext ctx) {
    final income7 = ctx.getIncomeLastDays(7);
    final expense7 = ctx.getExpensesLastDays(7);
    return expense7 > 0 && income7 > 0 && expense7 > income7 * 0.7;
  }
  
  BariResponse? _shouldSuggestPiggyTopUp(BariContext ctx) {
    if (ctx.piggyBanks == null || ctx.piggyBanks!.isEmpty) return null;
    
    bool hasStalledPiggy = false;
    String? stalledPiggyName;
    
    for (final piggy in ctx.piggyBanks!) {
      final currentAmount = (piggy['currentAmount'] as int?) ?? 0;
      final targetAmount = (piggy['targetAmount'] as int?) ?? 0;
      final progress = (piggy['progress'] as double?) ?? 0.0;
      
      // Если копилка не пустая, но не полная, и прогресс < 50%
      if (currentAmount > 0 && progress < 0.5 && targetAmount > 0) {
        final hasRecentTopUp = _hasRecentPiggyTopUp(ctx, hours: 14);
        if (!hasRecentTopUp) {
          hasStalledPiggy = true;
          stalledPiggyName = piggy['name'] as String?;
          break;
        }
      }
    }
    
    if (hasStalledPiggy) {
      return _buildPiggyHint(ctx, stalledPiggyName);
    }
    
    return null;
  }
  
  bool _shouldSuggestCreatePiggy(BariContext ctx) {
    final income7 = ctx.getIncomeLastDays(7);
    return income7 > 5000 && (ctx.piggyBanks == null || ctx.piggyBanks!.isEmpty);
  }
  
  bool _shouldSuggestLesson(BariContext ctx) {
    // Проверяем, есть ли непройденные уроки
    // Пока используем простую проверку: если уроков меньше ожидаемого для уровня
    final expectedLessons = ctx.playerLevel * 2;
    return ctx.lessonsCompletedCount < expectedLessons;
  }
  
  BariResponse? _shouldSuggestBudget(BariContext ctx) {
    if (ctx.recentTransactions == null || ctx.recentTransactions!.isEmpty) {
      return null;
    }
    
    final categoryCounts = <String, int>{};
    for (final t in ctx.recentTransactions!) {
      final category = t['category'] as String? ?? '';
      if (category.isNotEmpty) {
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      }
    }
    
    final maxCategory = categoryCounts.entries
        .where((e) => e.value >= 3)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    if (maxCategory.isNotEmpty) {
      return _buildBudgetHint(ctx, maxCategory.first.key);
    }
    
    return null;
  }
  
  bool _shouldSuggestPlanning(BariContext ctx) {
    return ctx.calendarEvents == null || ctx.calendarEvents!.isEmpty;
  }
  
  // Построение подсказок с разнообразием
  BariResponse _buildEarningsHint(BariContext ctx) {
    final messages = [
      _getText(ctx.localeTag,
        ru: 'Баланс низкий, а скоро запланированы расходы.',
        en: 'Balance is low, and expenses are coming up.',
        de: 'Kontostand ist niedrig, und Ausgaben stehen bevor.',
      ),
      _getText(ctx.localeTag,
        ru: 'Мало денег, но есть планы на траты.',
        en: 'Low balance, but you have spending plans.',
        de: 'Niedriger Kontostand, aber du hast Ausgabenpläne.',
      ),
    ];
    
    final advices = [
      _getText(ctx.localeTag,
        ru: 'Можешь заработать в Лаборатории заработка или посмотреть план.',
        en: 'You can earn in the Earnings Lab or check your plan.',
        de: 'Du kannst im Verdienst-Labor verdienen oder deinen Plan prüfen.',
      ),
      _getText(ctx.localeTag,
        ru: 'Попробуй выполнить задание в Лаборатории заработка!',
        en: 'Try completing a task in the Earnings Lab!',
        de: 'Versuche eine Aufgabe im Verdienst-Labor zu erledigen!',
      ),
    ];
    
    final randomMessage = messages[DateTime.now().millisecond % messages.length];
    final randomAdvice = advices[DateTime.now().millisecond % advices.length];
    
    return _buildHint(
      locale: _extractLocale(ctx.localeTag),
      meaning: randomMessage,
      advice: randomAdvice,
      action: const BariAction(
        type: BariActionType.openScreen,
        label: 'Лаборатория заработка',
        payload: 'earnings_lab',
      ),
    );
  }
  
  BariResponse _buildExpensesHint(BariContext ctx) {
    final messages = [
      _getText(ctx.localeTag,
        ru: 'За последнюю неделю у тебя много расходов.',
        en: 'You have a lot of expenses this week.',
        de: 'Du hast diese Woche viele Ausgaben.',
      ),
      _getText(ctx.localeTag,
        ru: 'Траты за неделю довольно большие.',
        en: 'Weekly spending is quite high.',
        de: 'Die wöchentlichen Ausgaben sind ziemlich hoch.',
      ),
    ];
    
    final advices = [
      _getText(ctx.localeTag,
        ru: 'Давай посмотрим, куда больше всего уходит денег.',
        en: 'Let\'s see where most of your money goes.',
        de: 'Lass uns sehen, wohin das meiste Geld geht.',
      ),
      _getText(ctx.localeTag,
        ru: 'Проверь статистику трат, чтобы понять, на что уходит больше всего.',
        en: 'Check your spending statistics to see where most money goes.',
        de: 'Prüfe deine Ausgabenstatistik, um zu sehen, wohin das meiste Geld geht.',
      ),
    ];
    
    final randomMessage = messages[DateTime.now().millisecond % messages.length];
    final randomAdvice = advices[DateTime.now().millisecond % advices.length];
    
    return _buildHint(
      locale: _extractLocale(ctx.localeTag),
      meaning: randomMessage,
      advice: randomAdvice,
      action: const BariAction(
        type: BariActionType.openScreen,
        label: 'Основные траты',
        payload: 'parent_stats',
      ),
    );
  }
  
  BariResponse _buildPiggyHint(BariContext ctx, String? piggyName) {
    final messages = [
      _getText(ctx.localeTag,
        ru: piggyName != null 
            ? 'Копилка "$piggyName" давно не пополнялась.'
            : 'Копилки немного "застыли".',
        en: piggyName != null
            ? 'Piggy bank "$piggyName" hasn\'t been topped up in a while.'
            : 'Piggy banks are a bit "stalled".',
        de: piggyName != null
            ? 'Das Sparschwein "$piggyName" wurde lange nicht aufgefüllt.'
            : 'Die Sparschweine sind etwas "eingefroren".',
      ),
      _getText(ctx.localeTag,
        ru: 'Копилка нуждается в пополнении.',
        en: 'Piggy bank needs a top-up.',
        de: 'Das Sparschwein braucht eine Auffüllung.',
      ),
    ];
    
    final advices = [
      _getText(ctx.localeTag,
        ru: 'Могу помочь придумать задание в Лаборатории заработка.',
        en: 'I can help you come up with a task in the Earnings Lab.',
        de: 'Ich kann dir helfen, eine Aufgabe im Verdienst-Labor zu finden.',
      ),
      _getText(ctx.localeTag,
        ru: 'Попробуй выполнить задание и пополнить копилку!',
        en: 'Try completing a task and topping up your piggy bank!',
        de: 'Versuche eine Aufgabe zu erledigen und dein Sparschwein aufzufüllen!',
      ),
    ];
    
    final randomMessage = messages[DateTime.now().millisecond % messages.length];
    final randomAdvice = advices[DateTime.now().millisecond % advices.length];
    
    return _buildHint(
      locale: _extractLocale(ctx.localeTag),
      meaning: randomMessage,
      advice: randomAdvice,
      action: const BariAction(
        type: BariActionType.openScreen,
        label: 'Лаборатория заработка',
        payload: 'earnings_lab',
      ),
    );
  }
  
  BariResponse _buildCreatePiggyHint(BariContext ctx) {
    final messages = [
      _getText(ctx.localeTag,
        ru: 'У тебя хорошие доходы, но нет целей для накопления.',
        en: 'You have good income, but no savings goals.',
        de: 'Du hast gutes Einkommen, aber keine Sparziele.',
      ),
      _getText(ctx.localeTag,
        ru: 'Ты хорошо зарабатываешь! Пора создать цель для накопления.',
        en: 'You\'re earning well! Time to create a savings goal.',
        de: 'Du verdienst gut! Zeit, ein Sparziel zu erstellen.',
      ),
    ];
    
    final advices = [
      _getText(ctx.localeTag,
        ru: 'Создай копилку для важной покупки!',
        en: 'Create a piggy bank for an important purchase!',
        de: 'Erstelle ein Sparschwein für einen wichtigen Kauf!',
      ),
      _getText(ctx.localeTag,
        ru: 'Поставь финансовую цель и начни копить!',
        en: 'Set a financial goal and start saving!',
        de: 'Setze ein finanzielles Ziel und fange an zu sparen!',
      ),
    ];
    
    final randomMessage = messages[DateTime.now().millisecond % messages.length];
    final randomAdvice = advices[DateTime.now().millisecond % advices.length];
    
    return _buildHint(
      locale: _extractLocale(ctx.localeTag),
      meaning: randomMessage,
      advice: randomAdvice,
      action: const BariAction(
        type: BariActionType.openScreen,
        label: 'Копилки',
        payload: 'piggy_banks',
      ),
    );
  }
  
  BariResponse _buildLessonHint(BariContext ctx) {
    final messages = [
      _getText(ctx.localeTag,
        ru: 'Есть новые уроки, которые помогут тебе стать финансово грамотнее!',
        en: 'There are new lessons that will help you become financially literate!',
        de: 'Es gibt neue Lektionen, die dir helfen werden, finanziell gebildet zu werden!',
      ),
      _getText(ctx.localeTag,
        ru: 'Хочешь узнать что-то новое? Открой уроки!',
        en: 'Want to learn something new? Open lessons!',
        de: 'Möchtest du etwas Neues lernen? Öffne die Lektionen!',
      ),
      _getText(ctx.localeTag,
        ru: 'Продолжай учиться! Новые знания ждут тебя.',
        en: 'Keep learning! New knowledge awaits you.',
        de: 'Lerne weiter! Neues Wissen wartet auf dich.',
      ),
      _getText(ctx.localeTag,
        ru: 'Ты уже прошёл ${ctx.lessonsCompletedCount} уроков! Продолжай в том же духе.',
        en: 'You\'ve already completed ${ctx.lessonsCompletedCount} lessons! Keep it up.',
        de: 'Du hast bereits ${ctx.lessonsCompletedCount} Lektionen abgeschlossen! Weiter so.',
      ),
    ];
    
    final advices = [
      _getText(ctx.localeTag,
        ru: 'Каждый урок занимает всего 3-5 минут.',
        en: 'Each lesson takes only 3-5 minutes.',
        de: 'Jede Lektion dauert nur 3-5 Minuten.',
      ),
      _getText(ctx.localeTag,
        ru: 'Уроки помогут тебе лучше управлять деньгами.',
        en: 'Lessons will help you manage money better.',
        de: 'Lektionen helfen dir, Geld besser zu verwalten.',
      ),
    ];
    
    final randomMessage = messages[DateTime.now().millisecond % messages.length];
    final randomAdvice = advices[DateTime.now().millisecond % advices.length];
    
    return _buildHint(
      locale: _extractLocale(ctx.localeTag),
      meaning: randomMessage,
      advice: randomAdvice,
      action: const BariAction(
        type: BariActionType.openScreen,
        label: 'Уроки',
        payload: 'lessons',
      ),
    );
  }
  
  BariResponse _buildBudgetHint(BariContext ctx, String category) {
    final messages = [
      _getText(ctx.localeTag,
        ru: 'Много трат на "$category".',
        en: 'A lot of spending on "$category".',
        de: 'Viele Ausgaben für "$category".',
      ),
      _getText(ctx.localeTag,
        ru: 'Большая часть трат уходит на "$category".',
        en: 'Most of your spending goes to "$category".',
        de: 'Der größte Teil deiner Ausgaben geht für "$category".',
      ),
    ];
    
    final advices = [
      _getText(ctx.localeTag,
        ru: 'Проверь, не превышаешь ли ты бюджет. Открой калькулятор бюджета.',
        en: 'Check if you\'re exceeding your budget. Open the budget calculator.',
        de: 'Prüfe, ob du dein Budget überschreitest. Öffne den Budget-Rechner.',
      ),
      _getText(ctx.localeTag,
        ru: 'Используй калькулятор бюджета, чтобы контролировать траты.',
        en: 'Use the budget calculator to control your spending.',
        de: 'Verwende den Budget-Rechner, um deine Ausgaben zu kontrollieren.',
      ),
    ];
    
    final randomMessage = messages[DateTime.now().millisecond % messages.length];
    final randomAdvice = advices[DateTime.now().millisecond % advices.length];
    
    return _buildHint(
      locale: _extractLocale(ctx.localeTag),
      meaning: randomMessage,
      advice: randomAdvice,
      action: const BariAction(
        type: BariActionType.openCalculator,
        label: 'Калькулятор бюджета',
        payload: 'monthly_budget',
      ),
    );
  }
  
  BariResponse _buildPlanningHint(BariContext ctx) {
    final messages = [
      _getText(ctx.localeTag,
        ru: 'Нет запланированных событий.',
        en: 'No planned events.',
        de: 'Keine geplanten Ereignisse.',
      ),
      _getText(ctx.localeTag,
        ru: 'Календарь пуст.',
        en: 'Calendar is empty.',
        de: 'Kalender ist leer.',
      ),
    ];
    
    final advices = [
      _getText(ctx.localeTag,
        ru: 'Запланируй доходы и расходы, чтобы лучше управлять деньгами.',
        en: 'Plan your income and expenses to better manage money.',
        de: 'Plane deine Einnahmen und Ausgaben, um Geld besser zu verwalten.',
      ),
      _getText(ctx.localeTag,
        ru: 'Создай план на будущее, чтобы контролировать финансы.',
        en: 'Create a plan for the future to control your finances.',
        de: 'Erstelle einen Plan für die Zukunft, um deine Finanzen zu kontrollieren.',
      ),
    ];
    
    final randomMessage = messages[DateTime.now().millisecond % messages.length];
    final randomAdvice = advices[DateTime.now().millisecond % advices.length];
    
    return _buildHint(
      locale: _extractLocale(ctx.localeTag),
      meaning: randomMessage,
      advice: randomAdvice,
      action: const BariAction(
        type: BariActionType.createPlan,
        label: 'Создать план',
        payload: 'plan',
      ),
    );
  }

  BariResponse _buildHint({
    required String locale,
    required String meaning,
    required String advice,
    required BariAction action,
  }) {
    return BariResponse(
      meaning: meaning,
      advice: advice,
      actions: [action],
      confidence: 0.8,
    );
  }

  String _extractLocale(String localeTag) {
    if (localeTag.startsWith('ru')) return 'ru';
    if (localeTag.startsWith('en')) return 'en';
    if (localeTag.startsWith('de')) return 'de';
    return 'ru';
  }

  String _getText(String localeTag, {required String ru, required String en, required String de}) {
    final locale = _extractLocale(localeTag);
    switch (locale) {
      case 'en':
        return en;
      case 'de':
        return de;
      default:
        return ru;
    }
  }
}

/// Вспомогательный класс для кандидатов подсказок
class _HintCandidate {
  final int priority;
  final String hintType;
  final BariResponse response;
  final bool Function() checkRecent;
  
  _HintCandidate({
    required this.priority,
    required this.hintType,
    required this.response,
    required this.checkRecent,
  });
}
