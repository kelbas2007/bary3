import '../bari_context.dart';
import '../bari_models.dart';
import 'bari_provider.dart';

/// Провайдер, который даёт умные ответы на основе контекста пользователя:
/// текущего экрана, баланса, времени дня, прогресса и т.д.
class ContextAwareProvider implements BariProvider {
  /// Извлекает язык из localeTag (ru_RU -> ru)
  String _extractLocale(String localeTag) {
    if (localeTag.startsWith('ru')) return 'ru';
    if (localeTag.startsWith('en')) return 'en';
    if (localeTag.startsWith('de')) return 'de';
    return 'ru'; // fallback
  }

  @override
  Future<BariResponse?> tryRespond(
    String message,
    BariContext ctx, {
    bool forceOnline = false,
  }) async {
    final locale = _extractLocale(ctx.localeTag);
    final m = message.toLowerCase().trim();
    
    // Локализованные паттерны
    final patterns = _getPatterns(locale);
    
    // === ЧТО МНЕ ДЕЛАТЬ / ЧТО ДАЛЬШЕ ===
    if (_matchesPattern(m, patterns['what_to_do']!)) {
      return _buildContextualAdvice(ctx, locale);
    }
    
    // === МОЙ ПРОГРЕСС / КАК Я ===
    if (_matchesPattern(m, patterns['progress']!)) {
      return _buildProgressSummary(ctx, locale);
    }
    
    // === СКОЛЬКО У МЕНЯ ДЕНЕГ ===
    if (_matchesPattern(m, patterns['balance']!)) {
      return _buildBalanceSummary(ctx, locale);
    }
    
    // === ЧТО ПРОИСХОДИТ / СОБЫТИЯ ===
    if (_matchesPattern(m, patterns['events']!)) {
      return _buildEventsSummary(ctx, locale);
    }
    
    // === ФИНАНСОВОЕ ЗДОРОВЬЕ ===
    if (_matchesPattern(m, patterns['financial_health']!)) {
      return _buildFinancialHealthCheck(ctx, locale);
    }
    
    // === МОТИВАЦИЯ ===
    if (_matchesPattern(m, patterns['motivation']!)) {
      return _buildMotivation(ctx, locale);
    }
    
    // === УТРЕННЕЕ / ВЕЧЕРНЕЕ ПРИВЕТСТВИЕ ===
    final hour = DateTime.now().hour;
    if (_matchesPattern(m, patterns['greetings']!)) {
      return _buildTimeBasedGreeting(ctx, hour, locale);
    }
    
    return null;
  }
  
  bool _matchesPattern(String message, List<String> patterns) {
    return patterns.any((p) => message.contains(p));
  }

  Map<String, List<String>> _getPatterns(String locale) {
    final patterns = {
      'ru': {
        'what_to_do': ['что делать', 'что дальше', 'что мне делать', 'с чего начать', 'куда идти', 'что посоветуешь', 'подскажи', 'помоги разобраться'],
        'progress': ['мой прогресс', 'как у меня', 'мои достижения', 'сколько я заработал', 'мой уровень', 'мой xp'],
        'balance': ['сколько у меня', 'сколько денег', 'мой баланс', 'что в кошельке', 'покажи баланс'],
        'events': ['что запланировано', 'мои планы', 'что в календаре', 'ближайшие события', 'что скоро'],
        'financial_health': ['финансовое здоровье', 'как мои финансы', 'оценка финансов', 'анализ', 'диагностика'],
        'motivation': ['мотивация', 'мотивируй', 'поддержи', 'не хочется', 'лень копить', 'зачем это всё'],
        'greetings': ['доброе утро', 'добрый день', 'добрый вечер', 'доброй ночи'],
      },
      'en': {
        'what_to_do': ['what to do', 'what next', 'what should i do', 'where to start', 'where to go', 'what do you suggest', 'help me understand'],
        'progress': ['my progress', 'how am i', 'my achievements', 'how much i earned', 'my level', 'my xp'],
        'balance': ['how much do i have', 'how much money', 'my balance', 'what in wallet', 'show balance'],
        'events': ['what planned', 'my plans', 'what in calendar', 'upcoming events', 'what soon'],
        'financial_health': ['financial health', 'how my finances', 'financial assessment', 'analysis', 'diagnosis'],
        'motivation': ['motivation', 'motivate', 'support', 'don\'t want', 'lazy to save', 'why all this'],
        'greetings': ['good morning', 'good day', 'good evening', 'good night'],
      },
      'de': {
        'what_to_do': ['was tun', 'was weiter', 'was soll ich tun', 'wo anfangen', 'wohin gehen', 'was schlägst du vor', 'hilf mir verstehen'],
        'progress': ['mein fortschritt', 'wie geht es mir', 'meine erreichte', 'wie viel ich verdient', 'mein level', 'mein xp'],
        'balance': ['wie viel habe ich', 'wie viel geld', 'mein kontostand', 'was in geldbörse', 'kontostand zeigen'],
        'events': ['was geplant', 'meine pläne', 'was im kalender', 'kommende ereignisse', 'was bald'],
        'financial_health': ['finanzielle gesundheit', 'wie meine finanzen', 'finanzbewertung', 'analyse', 'diagnose'],
        'motivation': ['motivation', 'motiviere', 'unterstütze', 'will nicht', 'faul zu sparen', 'warum das alles'],
        'greetings': ['guten morgen', 'guten tag', 'guten abend', 'gute nacht'],
      },
    };
    return patterns[locale] ?? patterns['ru']!;
  }
  
  BariResponse _buildContextualAdvice(BariContext ctx, String locale) {
    final List<String> recommendations = [];
    final List<BariAction> actions = [];
    
    // Анализируем контекст и даём персональные советы
    
    final labels = _getLabels(locale);
    
    // 1. Проверяем копилки
    final banks = ctx.piggyBanks ?? [];
    if (banks.isEmpty) {
      recommendations.add(labels['create_first_piggy']!);
      actions.add(BariAction(
        type: BariActionType.openScreen,
        label: labels['create_piggy']!,
        payload: 'piggy_banks',
      ));
    } else {
      // Ищем копилку, близкую к цели
      for (final bank in banks) {
        final current = (bank['currentAmount'] as int?) ?? 0;
        final target = (bank['targetAmount'] as int?) ?? 1;
        final progress = current / target * 100;
        if (progress >= 80 && progress < 100) {
          recommendations.add('${labels['piggy_almost_full']!} "${bank['name']}" ${labels['add_more']!}');
          break;
        }
      }
    }
    
    // 2. Проверяем уроки - ТОЛЬКО если не было урока сегодня
    final hasRecentLessonToday = ctx.lastLessonCompletedAt != null &&
        DateTime.now().difference(ctx.lastLessonCompletedAt!).inDays == 0;
    
    if (ctx.lessonsCompleted < 10 && !hasRecentLessonToday) {
      // Разнообразие в предложениях
      final lessonMessages = [
        labels['complete_more_lessons']!,
        'Есть новые уроки, которые помогут тебе стать финансово грамотнее!',
        'Хочешь узнать что-то новое? Открой уроки!',
        'Продолжай учиться! Новые знания ждут тебя.',
      ];
      
      final randomMessage = lessonMessages[DateTime.now().millisecond % lessonMessages.length];
      recommendations.add(randomMessage);
      actions.add(BariAction(
        type: BariActionType.openScreen,
        label: labels['lessons']!,
        payload: 'lessons',
      ));
    } else if (ctx.lessonsCompleted > 0 && hasRecentLessonToday) {
      // Если урок уже пройден сегодня, хвалим
      recommendations.add('Отлично! Ты уже прошёл урок сегодня! 🎉');
    }
    
    // 3. Проверяем события в календаре
    final events = ctx.calendarEvents ?? [];
    if (events.isEmpty) {
      recommendations.add(labels['plan_in_calendar']!);
      actions.add(BariAction(
        type: BariActionType.openScreen,
        label: labels['calendar']!,
        payload: 'calendar',
      ));
    }
    
    // 4. Проверяем баланс
    final balance = ctx.walletBalanceCents;
    if (balance > 5000 && banks.isNotEmpty) {
      recommendations.add(labels['top_up_piggy']!);
    }
    
    // Если ничего конкретного не нашли
    if (recommendations.isEmpty) {
      recommendations.add(labels['everything_good']!);
    }
    
    // Добавляем стандартные действия, если список короткий
    if (actions.isEmpty) {
      actions.addAll([
        BariAction(type: BariActionType.openScreen, label: labels['balance']!, payload: 'balance'),
        BariAction(type: BariActionType.openScreen, label: labels['piggy_banks']!, payload: 'piggy_banks'),
      ]);
    }
    
    return BariResponse(
      meaning: labels['advice_title']!,
      advice: recommendations.take(2).join(' '),
      actions: actions.take(4).toList(),
      confidence: 0.88,
    );
  }
  
  BariResponse _buildProgressSummary(BariContext ctx, String locale) {
    final level = ctx.playerLevel;
    final xp = ctx.playerXp;
    final lessons = ctx.lessonsCompleted;
    final banks = ctx.piggyBanks?.length ?? 0;
    
    String levelEmoji;
    if (level <= 2) {
      levelEmoji = '🌱';
    } else if (level <= 5) {
      levelEmoji = '🌿';
    } else if (level <= 10) {
      levelEmoji = '🌳';
    } else {
      levelEmoji = '🏆';
    }
    
    final achievements = <String>[];
    if (lessons >= 5) achievements.add('5+ уроков');
    if (lessons >= 20) achievements.add('20+ уроков');
    if (banks >= 3) achievements.add('3+ копилки');
    if (xp >= 500) achievements.add('500+ XP');
    
    final String achievementText = achievements.isEmpty 
        ? 'Продолжай — скоро будут достижения!' 
        : 'Достижения: ${achievements.join(", ")}';
    
    final labels = _getLabels(locale);
    final lessonsLabel = labels['lessons']!;
    final piggyLabel = labels['piggy_banks']!;
    
    return BariResponse(
      meaning: '$levelEmoji ${labels['level']!} $level · $xp XP · $lessons $lessonsLabel · $banks $piggyLabel',
      advice: achievementText,
      actions: [
        BariAction(type: BariActionType.openScreen, label: lessonsLabel, payload: 'lessons'),
        BariAction(type: BariActionType.openScreen, label: piggyLabel, payload: 'piggy_banks'),
      ],
      confidence: 0.92,
    );
  }
  
  BariResponse _buildBalanceSummary(BariContext ctx, String locale) {
    final balance = ctx.walletBalanceCents / 100;
    final totalSaved = ctx.totalPiggyBanksSaved / 100;
    final total = balance + totalSaved;
    
    final symbol = _getCurrencySymbol(ctx.currencyCode);
    
    String statusEmoji;
    String statusAdvice;
    
    if (total < 10) {
      statusEmoji = '😅';
      statusAdvice = 'Время заработать или попросить карманные!';
    } else if (total < 50) {
      statusEmoji = '🙂';
      statusAdvice = 'Неплохое начало! Старайся откладывать регулярно.';
    } else if (total < 200) {
      statusEmoji = '😊';
      statusAdvice = 'Хороший прогресс! Продолжай копить на цели.';
    } else {
      statusEmoji = '🤑';
      statusAdvice = 'Отлично накопил! Подумай о новых целях.';
    }
    
    return BariResponse(
      meaning: '$statusEmoji Кошелёк: ${balance.toStringAsFixed(2)}$symbol · Копилки: ${totalSaved.toStringAsFixed(2)}$symbol · Всего: ${total.toStringAsFixed(2)}$symbol',
      advice: statusAdvice,
      actions: const [
        BariAction(type: BariActionType.openScreen, label: 'Баланс', payload: 'balance'),
        BariAction(type: BariActionType.openScreen, label: 'Копилки', payload: 'piggy_banks'),
      ],
      confidence: 0.95,
    );
  }
  
  BariResponse _buildEventsSummary(BariContext ctx, String locale) {
    final labels = _getLabels(locale);
    final events = ctx.calendarEvents ?? [];
    
    if (events.isEmpty) {
      return BariResponse(
        meaning: labels['calendar_empty'] ?? 'В календаре пока пусто.',
        advice: labels['plan_income_expense'] ?? 'Запланируй доход или расход — так проще контролировать финансы.',
        actions: [
          BariAction(type: BariActionType.openScreen, label: labels['calendar']!, payload: 'calendar'),
          BariAction(type: BariActionType.createPlan, label: labels['create_plan'] ?? 'Создать план'),
        ],
        confidence: 0.9,
      );
    }
    
    // Показываем ближайшие события
    final upcoming = events.take(3).map((e) {
      final title = e['title'] ?? 'Событие';
      final type = e['type'] == 'TransactionType.income' ? '+' : '-';
      final amount = ((e['amount'] as int?) ?? 0) / 100;
      return '$title ($type${amount.toStringAsFixed(0)}${_getCurrencySymbol(ctx.currencyCode)})';
    }).join(', ');
    
    return BariResponse(
      meaning: '${labels['upcoming_events'] ?? 'Ближайшие события:'} $upcoming',
      advice: labels['watch_calendar'] ?? 'Следи за календарём, чтобы не пропустить важное!',
      actions: [
        BariAction(type: BariActionType.openScreen, label: labels['calendar']!, payload: 'calendar'),
      ],
      confidence: 0.9,
    );
  }
  
  BariResponse _buildFinancialHealthCheck(BariContext ctx, String locale) {
    int score = 0;
    final tips = <String>[];
    
    // Критерии здоровья
    final balance = ctx.walletBalanceCents;
    final banks = ctx.piggyBanks ?? [];
    final events = ctx.calendarEvents ?? [];
    final lessons = ctx.lessonsCompleted;
    final totalSaved = ctx.totalPiggyBanksSaved;
    
    // 1. Есть деньги в кошельке (+10)
    if (balance > 0) {
      score += 10;
    } else {
      tips.add('Пополни кошелёк');
    }
    
    // 2. Есть копилки (+20)
    if (banks.isNotEmpty) {
      score += 20;
    } else {
      tips.add('Создай копилку с целью');
    }
    
    // 3. Есть накопления (+20)
    if (totalSaved > 0) {
      score += 20;
    }
    
    // 4. Есть планы в календаре (+15)
    if (events.isNotEmpty) {
      score += 15;
    } else {
      tips.add('Планируй доходы и расходы');
    }
    
    // 5. Пройдены уроки (+15)
    if (lessons >= 5) {
      score += 15;
    } else {
      tips.add('Пройди больше уроков');
    }
    
    // 6. Накопления > 20% от общего (+20)
    final total = balance + totalSaved;
    if (total > 0 && totalSaved / total >= 0.2) {
      score += 20;
    }
    
    String emoji;
    String status;
    if (score >= 80) {
      emoji = '💚';
      status = 'Отличное';
    } else if (score >= 60) {
      emoji = '💛';
      status = 'Хорошее';
    } else if (score >= 40) {
      emoji = '🧡';
      status = 'Среднее';
    } else {
      emoji = '❤️';
      status = 'Нужна работа';
    }
    
    final adviceText = tips.isEmpty 
        ? 'Продолжай в том же духе!' 
        : 'Советы: ${tips.take(2).join(", ")}.';
    
    return BariResponse(
      meaning: '$emoji Финансовое здоровье: $status ($score/100)',
      advice: adviceText,
      actions: const [
        BariAction(type: BariActionType.openScreen, label: 'Копилки', payload: 'piggy_banks'),
        BariAction(type: BariActionType.openScreen, label: 'Уроки', payload: 'lessons'),
      ],
      confidence: 0.9,
    );
  }
  
  BariResponse _buildMotivation(BariContext ctx, String locale) {
    final motivations = [
      'Каждая монетка — это шаг к мечте! 🌟',
      'Ты уже умнее многих, потому что думаешь о деньгах заранее! 🧠',
      'Маленькие шаги — большие результаты! 🚀',
      'Сегодня откладываешь — завтра покупаешь мечту! 💫',
      'Финансовая грамотность — это суперсила! 💪',
      'Ты контролируешь деньги, а не они тебя! 👑',
    ];
    
    // Выбираем случайную мотивацию
    final random = DateTime.now().millisecond % motivations.length;
    final motivation = motivations[random];
    
    // Персонализируем на основе контекста
    String personalNote = '';
    if (ctx.playerLevel > 3) {
      personalNote = 'Ты уже уровень ${ctx.playerLevel} — круто!';
    } else if (ctx.lessonsCompleted > 0) {
      personalNote = 'Ты уже прошёл ${ctx.lessonsCompleted} уроков — молодец!';
    } else if ((ctx.piggyBanks?.length ?? 0) > 0) {
      personalNote = 'У тебя уже есть копилки — отличный старт!';
    }
    
    return BariResponse(
      meaning: motivation,
      advice: personalNote.isNotEmpty ? personalNote : 'Продолжай — у тебя получится!',
      actions: const [
        BariAction(type: BariActionType.openScreen, label: 'Копилки', payload: 'piggy_banks'),
        BariAction(type: BariActionType.openScreen, label: 'Уроки', payload: 'lessons'),
      ],
      confidence: 0.9,
    );
  }
  
  BariResponse _buildTimeBasedGreeting(BariContext ctx, int hour, String locale) {
    String greeting;
    String advice;
    
    if (hour >= 5 && hour < 12) {
      greeting = '☀️ Доброе утро!';
      advice = 'Отличное время посмотреть планы на день и проверить копилки.';
    } else if (hour >= 12 && hour < 17) {
      greeting = '🌤️ Добрый день!';
      advice = 'Как идут дела? Может, пора пополнить копилку?';
    } else if (hour >= 17 && hour < 22) {
      greeting = '🌅 Добрый вечер!';
      advice = 'Хорошее время подвести итоги дня и проверить баланс.';
    } else {
      greeting = '🌙 Доброй ночи!';
      advice = 'Отдыхай, а деньги подождут до утра. Хотя... можно пройти урок перед сном!';
    }
    
    return BariResponse(
      meaning: greeting,
      advice: advice,
      actions: const [
        BariAction(type: BariActionType.openScreen, label: 'Баланс', payload: 'balance'),
        BariAction(type: BariActionType.openScreen, label: 'Копилки', payload: 'piggy_banks'),
      ],
      confidence: 0.95,
    );
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

  /// Получает локализованные метки для указанного языка
  Map<String, String> _getLabels(String locale) {
    final labels = {
      'ru': {
        'create_first_piggy': 'Создай первую копилку — это твой первый шаг к накоплениям!',
        'create_piggy': 'Создать копилку',
        'piggy_almost_full': 'Копилка',
        'add_more': 'почти полная — добавь ещё немного!',
        'complete_more_lessons': 'Пройди ещё несколько уроков — узнаешь много полезного!',
        'lessons': 'Уроки',
        'plan_in_calendar': 'Запланируй что-нибудь в календаре — так проще не забывать.',
        'calendar': 'Календарь',
        'top_up_piggy': 'В кошельке много денег — может, пополнить копилку?',
        'everything_good': 'У тебя всё хорошо! Продолжай в том же духе.',
        'balance': 'Баланс',
        'piggy_banks': 'Копилки',
        'advice_title': 'Вот что я советую сделать:',
        'level': 'Уровень',
      },
      'en': {
        'create_first_piggy': 'Create your first piggy bank — it\'s your first step to savings!',
        'create_piggy': 'Create piggy bank',
        'piggy_almost_full': 'Piggy bank',
        'add_more': 'is almost full — add a bit more!',
        'complete_more_lessons': 'Complete a few more lessons — you\'ll learn a lot!',
        'lessons': 'Lessons',
        'plan_in_calendar': 'Plan something in the calendar — it\'s easier not to forget.',
        'calendar': 'Calendar',
        'top_up_piggy': 'You have a lot of money in wallet — maybe top up piggy bank?',
        'everything_good': 'Everything is good! Keep it up.',
        'balance': 'Balance',
        'piggy_banks': 'Piggy Banks',
        'advice_title': 'Here\'s what I suggest:',
        'level': 'Level',
      },
      'de': {
        'create_first_piggy': 'Erstelle dein erstes Sparschwein — es ist dein erster Schritt zum Sparen!',
        'create_piggy': 'Sparschwein erstellen',
        'piggy_almost_full': 'Sparschwein',
        'add_more': 'ist fast voll — füge noch etwas hinzu!',
        'complete_more_lessons': 'Absolviere noch ein paar Lektionen — du wirst viel lernen!',
        'lessons': 'Lektionen',
        'plan_in_calendar': 'Plane etwas im Kalender — so vergisst du es nicht.',
        'calendar': 'Kalender',
        'top_up_piggy': 'Du hast viel Geld in der Geldbörse — vielleicht Sparschwein aufladen?',
        'everything_good': 'Alles ist gut! Weiter so.',
        'balance': 'Kontostand',
        'piggy_banks': 'Sparschweine',
        'advice_title': 'Hier ist, was ich vorschlage:',
        'level': 'Level',
      },
    };
    return labels[locale] ?? labels['ru']!;
  }
}
