import '../bari_context.dart';
import '../bari_models.dart';
import 'bari_provider.dart';

/// Провайдер, который знает все функции приложения и может их использовать
/// Предлагает функции, рассказывает о возможностях и выполняет действия
class AppFeaturesProvider implements BariProvider {
  /// Извлекает язык из localeTag (ru_RU -> ru)
  String _extractLocale(String localeTag) {
    if (localeTag.startsWith('ru')) return 'ru';
    if (localeTag.startsWith('en')) return 'en';
    if (localeTag.startsWith('de')) return 'de';
    return 'ru';
  }

  @override
  Future<BariResponse?> tryRespond(
    String message,
    BariContext ctx, {
    bool forceOnline = false,
  }) async {
    final locale = _extractLocale(ctx.localeTag);
    final m = message.toLowerCase().trim();

    // Определяем intent
    final intent = _detectIntent(m, locale);

    switch (intent) {
      case FeatureIntent.showFeatures:
        return _buildFeaturesListResponse(ctx, locale);
      
      case FeatureIntent.openFeature:
        return _buildOpenFeatureResponse(m, ctx, locale);
      
      case FeatureIntent.explainFeature:
        return _buildExplainFeatureResponse(m, ctx, locale);
      
      case FeatureIntent.suggestFeature:
        return _buildSuggestFeatureResponse(ctx, locale);
      
      case FeatureIntent.createNote:
        return _buildCreateNoteResponse(ctx, locale);
      
      case FeatureIntent.openCalculator:
        return _buildOpenCalculatorResponse(m, ctx, locale);
      
      case FeatureIntent.openTools:
        return _buildOpenToolsResponse(ctx, locale);
      
      case FeatureIntent.createEvent:
        return _buildCreateEventResponse(ctx, locale);
      
      case FeatureIntent.showProgress:
        return _buildShowProgressResponse(ctx, locale);
      
      case FeatureIntent.unknown:
        return null;
    }
  }

  FeatureIntent _detectIntent(String message, String locale) {
    // Показать все функции
    if (_matchesAny(message, _getPatterns(locale, 'show_features'))) {
      return FeatureIntent.showFeatures;
    }
    
    // Открыть конкретную функцию
    if (_matchesAny(message, _getPatterns(locale, 'open_feature'))) {
      return FeatureIntent.openFeature;
    }
    
    // Объяснить функцию
    if (_matchesAny(message, _getPatterns(locale, 'explain_feature'))) {
      return FeatureIntent.explainFeature;
    }
    
    // Предложить функцию
    if (_matchesAny(message, _getPatterns(locale, 'suggest_feature'))) {
      return FeatureIntent.suggestFeature;
    }
    
    // Создать заметку
    if (_matchesAny(message, _getPatterns(locale, 'create_note'))) {
      return FeatureIntent.createNote;
    }
    
    // Открыть калькулятор
    if (_matchesAny(message, _getPatterns(locale, 'open_calculator'))) {
      return FeatureIntent.openCalculator;
    }
    
    // Открыть инструменты
    if (_matchesAny(message, _getPatterns(locale, 'open_tools'))) {
      return FeatureIntent.openTools;
    }
    
    // Создать событие
    if (_matchesAny(message, _getPatterns(locale, 'create_event'))) {
      return FeatureIntent.createEvent;
    }
    
    // Показать прогресс
    if (_matchesAny(message, _getPatterns(locale, 'show_progress'))) {
      return FeatureIntent.showProgress;
    }
    
    return FeatureIntent.unknown;
  }

  bool _matchesAny(String message, List<String> patterns) {
    return patterns.any((pattern) => message.contains(pattern));
  }

  List<String> _getPatterns(String locale, String category) {
    final allPatterns = {
      'ru': {
        'show_features': [
          'что умеешь', 'что можешь', 'какие функции', 'что есть',
          'возможности', 'функции', 'что в приложении',
        ],
        'open_feature': [
          'открой', 'покажи', 'перейди', 'открыть',
        ],
        'explain_feature': [
          'что такое', 'как работает', 'объясни', 'расскажи про',
          'что делает', 'для чего',
        ],
        'suggest_feature': [
          'что посоветуешь', 'что сделать', 'что попробовать',
          'что интересного', 'что нового',
        ],
        'create_note': [
          'создать заметку', 'записать', 'заметка', 'запиши',
        ],
        'open_calculator': [
          'калькулятор', 'посчитай', 'вычисли',
        ],
        'open_tools': [
          'инструменты', 'центр инструментов', 'tools hub',
        ],
        'create_event': [
          'запланировать', 'создать событие', 'добавить событие',
        ],
        'show_progress': [
          'прогресс', 'как дела', 'что достиг', 'достижения',
        ],
      },
      'en': {
        'show_features': [
          'what can you', 'what features', 'what is available',
          'capabilities', 'functions', 'what in app',
        ],
        'open_feature': [
          'open', 'show', 'go to', 'navigate',
        ],
        'explain_feature': [
          'what is', 'how does', 'explain', 'tell about',
          'what does', 'what for',
        ],
        'suggest_feature': [
          'what do you suggest', 'what to do', 'what to try',
          'what interesting', 'what new',
        ],
        'create_note': [
          'create note', 'write', 'note', 'record',
        ],
        'open_calculator': [
          'calculator', 'calculate', 'compute',
        ],
        'open_tools': [
          'tools', 'tools hub', 'center',
        ],
        'create_event': [
          'plan', 'create event', 'add event',
        ],
        'show_progress': [
          'progress', 'how am i', 'what achieved', 'achievements',
        ],
      },
      'de': {
        'show_features': [
          'was kannst du', 'welche funktionen', 'was gibt es',
          'fähigkeiten', 'funktionen', 'was in app',
        ],
        'open_feature': [
          'öffne', 'zeige', 'gehe zu', 'navigiere',
        ],
        'explain_feature': [
          'was ist', 'wie funktioniert', 'erkläre', 'erzähle über',
          'was macht', 'wofür',
        ],
        'suggest_feature': [
          'was schlägst du vor', 'was zu tun', 'was zu versuchen',
          'was interessant', 'was neu',
        ],
        'create_note': [
          'notiz erstellen', 'schreibe', 'notiz', 'aufzeichnen',
        ],
        'open_calculator': [
          'rechner', 'berechnen', 'rechnen',
        ],
        'open_tools': [
          'werkzeuge', 'tools hub', 'zentrum',
        ],
        'create_event': [
          'planen', 'ereignis erstellen', 'ereignis hinzufügen',
        ],
        'show_progress': [
          'fortschritt', 'wie geht es', 'was erreicht', 'erfolge',
        ],
      },
    };
    
    return allPatterns[locale]?[category] ?? [];
  }

  Future<BariResponse> _buildFeaturesListResponse(
    BariContext ctx,
    String locale,
  ) async {
    final features = await _getAllFeatures(ctx, locale);
    
    final responses = {
      'ru': BariResponse(
        meaning: 'Вот все функции, которые я умею!',
        advice: 'Спроси меня про любую функцию, и я расскажу подробнее или открою её.',
        actions: features,
        confidence: 0.95,
      ),
      'en': BariResponse(
        meaning: 'Here are all the features I can do!',
        advice: 'Ask me about any feature, and I\'ll tell you more or open it.',
        actions: features,
        confidence: 0.95,
      ),
      'de': BariResponse(
        meaning: 'Hier sind alle Funktionen, die ich kann!',
        advice: 'Frage mich nach einer Funktion, und ich erzähle dir mehr oder öffne sie.',
        actions: features,
        confidence: 0.95,
      ),
    };
    
    return responses[locale] ?? responses['ru']!;
  }

  Future<List<BariAction>> _getAllFeatures(
    BariContext ctx,
    String locale,
  ) async {
    final features = <BariAction>[];
    
    // Основные экраны
    features.addAll(_getScreenActions(locale));
    
    // Калькуляторы
    features.addAll(_getCalculatorActions(locale));
    
    // Инструменты
    features.addAll(_getToolsActions(locale));
    
    // Действия
    features.addAll(_getActionActions(locale));
    
    return features;
  }

  List<BariAction> _getScreenActions(String locale) {
    final screens = {
      'ru': [
        const BariAction(type: BariActionType.openScreen, label: '💰 Баланс', payload: 'balance'),
        const BariAction(type: BariActionType.openScreen, label: '🐷 Копилки', payload: 'piggy_banks'),
        const BariAction(type: BariActionType.openScreen, label: '📅 Календарь', payload: 'calendar'),
        const BariAction(type: BariActionType.openScreen, label: '📚 Уроки', payload: 'lessons'),
        const BariAction(type: BariActionType.openScreen, label: '⚙️ Настройки', payload: 'settings'),
        const BariAction(type: BariActionType.openScreen, label: '💼 Лаборатория заработка', payload: 'earnings_lab'),
        const BariAction(type: BariActionType.openScreen, label: '📝 Заметки', payload: 'notes'),
        const BariAction(type: BariActionType.openScreen, label: '🛠️ Инструменты', payload: 'tools'),
      ],
      'en': [
        const BariAction(type: BariActionType.openScreen, label: '💰 Balance', payload: 'balance'),
        const BariAction(type: BariActionType.openScreen, label: '🐷 Piggy Banks', payload: 'piggy_banks'),
        const BariAction(type: BariActionType.openScreen, label: '📅 Calendar', payload: 'calendar'),
        const BariAction(type: BariActionType.openScreen, label: '📚 Lessons', payload: 'lessons'),
        const BariAction(type: BariActionType.openScreen, label: '⚙️ Settings', payload: 'settings'),
        const BariAction(type: BariActionType.openScreen, label: '💼 Earnings Lab', payload: 'earnings_lab'),
        const BariAction(type: BariActionType.openScreen, label: '📝 Notes', payload: 'notes'),
        const BariAction(type: BariActionType.openScreen, label: '🛠️ Tools', payload: 'tools'),
      ],
      'de': [
        const BariAction(type: BariActionType.openScreen, label: '💰 Kontostand', payload: 'balance'),
        const BariAction(type: BariActionType.openScreen, label: '🐷 Sparschweine', payload: 'piggy_banks'),
        const BariAction(type: BariActionType.openScreen, label: '📅 Kalender', payload: 'calendar'),
        const BariAction(type: BariActionType.openScreen, label: '📚 Lektionen', payload: 'lessons'),
        const BariAction(type: BariActionType.openScreen, label: '⚙️ Einstellungen', payload: 'settings'),
        const BariAction(type: BariActionType.openScreen, label: '💼 Verdienstlabor', payload: 'earnings_lab'),
        const BariAction(type: BariActionType.openScreen, label: '📝 Notizen', payload: 'notes'),
        const BariAction(type: BariActionType.openScreen, label: '🛠️ Werkzeuge', payload: 'tools'),
      ],
    };
    
    return screens[locale] ?? screens['ru']!;
  }

  List<BariAction> _getCalculatorActions(String locale) {
    final calculators = {
      'ru': [
        const BariAction(type: BariActionType.openCalculator, label: '📊 План копилки', payload: 'piggy_plan'),
        const BariAction(type: BariActionType.openCalculator, label: '📅 Дата цели', payload: 'goal_date'),
        const BariAction(type: BariActionType.openCalculator, label: '💰 Месячный бюджет', payload: 'monthly_budget'),
        const BariAction(type: BariActionType.openCalculator, label: '📱 Подписки', payload: 'subscriptions'),
        const BariAction(type: BariActionType.openCalculator, label: '🛒 Можно ли купить?', payload: 'can_i_buy'),
        const BariAction(type: BariActionType.openCalculator, label: '⚖️ Сравнение цен', payload: 'price_comparison'),
        const BariAction(type: BariActionType.openCalculator, label: '⏰ Правило 24 часов', payload: '24h_rule'),
        const BariAction(type: BariActionType.openCalculator, label: '📈 Бюджет 50/30/20', payload: '50_30_20'),
        const BariAction(type: BariActionType.openCalculator, label: '🔮 Прогноз календаря', payload: 'calendar_forecast'),
      ],
      'en': [
        const BariAction(type: BariActionType.openCalculator, label: '📊 Piggy Plan', payload: 'piggy_plan'),
        const BariAction(type: BariActionType.openCalculator, label: '📅 Goal Date', payload: 'goal_date'),
        const BariAction(type: BariActionType.openCalculator, label: '💰 Monthly Budget', payload: 'monthly_budget'),
        const BariAction(type: BariActionType.openCalculator, label: '📱 Subscriptions', payload: 'subscriptions'),
        const BariAction(type: BariActionType.openCalculator, label: '🛒 Can I Buy?', payload: 'can_i_buy'),
        const BariAction(type: BariActionType.openCalculator, label: '⚖️ Price Comparison', payload: 'price_comparison'),
        const BariAction(type: BariActionType.openCalculator, label: '⏰ 24h Rule', payload: '24h_rule'),
        const BariAction(type: BariActionType.openCalculator, label: '📈 50/30/20 Budget', payload: '50_30_20'),
        const BariAction(type: BariActionType.openCalculator, label: '🔮 Calendar Forecast', payload: 'calendar_forecast'),
      ],
      'de': [
        const BariAction(type: BariActionType.openCalculator, label: '📊 Sparschwein Plan', payload: 'piggy_plan'),
        const BariAction(type: BariActionType.openCalculator, label: '📅 Ziel Datum', payload: 'goal_date'),
        const BariAction(type: BariActionType.openCalculator, label: '💰 Monatsbudget', payload: 'monthly_budget'),
        const BariAction(type: BariActionType.openCalculator, label: '📱 Abonnements', payload: 'subscriptions'),
        const BariAction(type: BariActionType.openCalculator, label: '🛒 Kann ich kaufen?', payload: 'can_i_buy'),
        const BariAction(type: BariActionType.openCalculator, label: '⚖️ Preisvergleich', payload: 'price_comparison'),
        const BariAction(type: BariActionType.openCalculator, label: '⏰ 24h Regel', payload: '24h_rule'),
        const BariAction(type: BariActionType.openCalculator, label: '📈 50/30/20 Budget', payload: '50_30_20'),
        const BariAction(type: BariActionType.openCalculator, label: '🔮 Kalender Prognose', payload: 'calendar_forecast'),
      ],
    };
    
    return calculators[locale] ?? calculators['ru']!;
  }

  List<BariAction> _getToolsActions(String locale) {
    final tools = {
      'ru': [
        const BariAction(type: BariActionType.openScreen, label: '🔮 Прогноз календаря', payload: 'calendar_forecast'),
        const BariAction(type: BariActionType.openScreen, label: '💼 Лаборатория заработка', payload: 'earnings_lab'),
        const BariAction(type: BariActionType.openScreen, label: '⏱️ Мини-тренажеры', payload: 'mini_trainers'),
        const BariAction(type: BariActionType.openScreen, label: '💡 Рекомендации Бари', payload: 'bari_recommendations'),
        const BariAction(type: BariActionType.openScreen, label: '📝 Заметки', payload: 'notes'),
      ],
      'en': [
        const BariAction(type: BariActionType.openScreen, label: '🔮 Calendar Forecast', payload: 'calendar_forecast'),
        const BariAction(type: BariActionType.openScreen, label: '💼 Earnings Lab', payload: 'earnings_lab'),
        const BariAction(type: BariActionType.openScreen, label: '⏱️ Mini Trainers', payload: 'mini_trainers'),
        const BariAction(type: BariActionType.openScreen, label: '💡 Bari Recommendations', payload: 'bari_recommendations'),
        const BariAction(type: BariActionType.openScreen, label: '📝 Notes', payload: 'notes'),
      ],
      'de': [
        const BariAction(type: BariActionType.openScreen, label: '🔮 Kalender Prognose', payload: 'calendar_forecast'),
        const BariAction(type: BariActionType.openScreen, label: '💼 Verdienstlabor', payload: 'earnings_lab'),
        const BariAction(type: BariActionType.openScreen, label: '⏱️ Mini Trainer', payload: 'mini_trainers'),
        const BariAction(type: BariActionType.openScreen, label: '💡 Bari Empfehlungen', payload: 'bari_recommendations'),
        const BariAction(type: BariActionType.openScreen, label: '📝 Notizen', payload: 'notes'),
      ],
    };
    
    return tools[locale] ?? tools['ru']!;
  }

  List<BariAction> _getActionActions(String locale) {
    final actions = {
      'ru': [
        const BariAction(type: BariActionType.createPlan, label: '📅 Запланировать событие'),
        const BariAction(type: BariActionType.openScreen, label: '📝 Создать заметку', payload: 'notes'),
        const BariAction(type: BariActionType.openScreen, label: '💼 Добавить задание', payload: 'earnings_lab'),
      ],
      'en': [
        const BariAction(type: BariActionType.createPlan, label: '📅 Plan Event'),
        const BariAction(type: BariActionType.openScreen, label: '📝 Create Note', payload: 'notes'),
        const BariAction(type: BariActionType.openScreen, label: '💼 Add Task', payload: 'earnings_lab'),
      ],
      'de': [
        const BariAction(type: BariActionType.createPlan, label: '📅 Ereignis planen'),
        const BariAction(type: BariActionType.openScreen, label: '📝 Notiz erstellen', payload: 'notes'),
        const BariAction(type: BariActionType.openScreen, label: '💼 Aufgabe hinzufügen', payload: 'earnings_lab'),
      ],
    };
    
    return actions[locale] ?? actions['ru']!;
  }

  Future<BariResponse> _buildOpenFeatureResponse(
    String message,
    BariContext ctx,
    String locale,
  ) async {
    // Определяем, какую функцию хочет открыть пользователь
    final feature = _detectFeatureFromMessage(message, locale);
    
    if (feature != null) {
      return BariResponse(
        meaning: 'Открываю $feature',
        advice: 'Сейчас открою эту функцию для тебя!',
        actions: [feature],
        confidence: 0.9,
      );
    }
    
    // Если не определили, предлагаем список
    return _buildFeaturesListResponse(ctx, locale);
  }

  BariAction? _detectFeatureFromMessage(String message, String locale) {
    // Определяем функцию по ключевым словам
    final featureMap = _getFeatureMap(locale);
    
    for (var entry in featureMap.entries) {
      if (message.contains(entry.key)) {
        return entry.value;
      }
    }
    
    return null;
  }

  Map<String, BariAction> _getFeatureMap(String locale) {
    final maps = {
      'ru': {
        'баланс': const BariAction(type: BariActionType.openScreen, label: 'Баланс', payload: 'balance'),
        'копилк': const BariAction(type: BariActionType.openScreen, label: 'Копилки', payload: 'piggy_banks'),
        'календар': const BariAction(type: BariActionType.openScreen, label: 'Календарь', payload: 'calendar'),
        'урок': const BariAction(type: BariActionType.openScreen, label: 'Уроки', payload: 'lessons'),
        'настройк': const BariAction(type: BariActionType.openScreen, label: 'Настройки', payload: 'settings'),
        'лаборатор': const BariAction(type: BariActionType.openScreen, label: 'Лаборатория', payload: 'earnings_lab'),
        'заметк': const BariAction(type: BariActionType.openScreen, label: 'Заметки', payload: 'notes'),
        'инструмент': const BariAction(type: BariActionType.openScreen, label: 'Инструменты', payload: 'tools'),
        'калькулятор': const BariAction(type: BariActionType.openCalculator, label: 'Калькуляторы'),
      },
      'en': {
        'balance': const BariAction(type: BariActionType.openScreen, label: 'Balance', payload: 'balance'),
        'piggy': const BariAction(type: BariActionType.openScreen, label: 'Piggy Banks', payload: 'piggy_banks'),
        'calendar': const BariAction(type: BariActionType.openScreen, label: 'Calendar', payload: 'calendar'),
        'lesson': const BariAction(type: BariActionType.openScreen, label: 'Lessons', payload: 'lessons'),
        'setting': const BariAction(type: BariActionType.openScreen, label: 'Settings', payload: 'settings'),
        'earnings': const BariAction(type: BariActionType.openScreen, label: 'Earnings Lab', payload: 'earnings_lab'),
        'note': const BariAction(type: BariActionType.openScreen, label: 'Notes', payload: 'notes'),
        'tool': const BariAction(type: BariActionType.openScreen, label: 'Tools', payload: 'tools'),
        'calculator': const BariAction(type: BariActionType.openCalculator, label: 'Calculators'),
      },
      'de': {
        'kontostand': const BariAction(type: BariActionType.openScreen, label: 'Kontostand', payload: 'balance'),
        'sparschwein': const BariAction(type: BariActionType.openScreen, label: 'Sparschweine', payload: 'piggy_banks'),
        'kalender': const BariAction(type: BariActionType.openScreen, label: 'Kalender', payload: 'calendar'),
        'lektion': const BariAction(type: BariActionType.openScreen, label: 'Lektionen', payload: 'lessons'),
        'einstellung': const BariAction(type: BariActionType.openScreen, label: 'Einstellungen', payload: 'settings'),
        'verdienst': const BariAction(type: BariActionType.openScreen, label: 'Verdienstlabor', payload: 'earnings_lab'),
        'notiz': const BariAction(type: BariActionType.openScreen, label: 'Notizen', payload: 'notes'),
        'werkzeug': const BariAction(type: BariActionType.openScreen, label: 'Werkzeuge', payload: 'tools'),
        'rechner': const BariAction(type: BariActionType.openCalculator, label: 'Rechner'),
      },
    };
    
    return maps[locale] ?? maps['ru']!;
  }

  Future<BariResponse> _buildExplainFeatureResponse(
    String message,
    BariContext ctx,
    String locale,
  ) async {
    // Определяем, о какой функции спрашивают
    final feature = _detectFeatureFromMessage(message, locale);
    
    if (feature != null) {
      final explanation = _getFeatureExplanation(feature.payload ?? feature.label, locale);
      return BariResponse(
        meaning: explanation['meaning'] ?? 'Объяснение функции',
        advice: explanation['advice'] ?? 'Попробуй использовать эту функцию!',
        actions: [feature],
        confidence: 0.9,
      );
    }
    
    return _buildFeaturesListResponse(ctx, locale);
  }

  Map<String, String> _getFeatureExplanation(String featureId, String locale) {
    final explanations = {
      'ru': {
        'balance': {
          'meaning': 'Баланс — это твой кошелёк. Здесь ты видишь все деньги, которые можешь потратить.',
          'advice': 'Добавляй доходы и расходы, чтобы видеть, сколько у тебя денег.',
        },
        'piggy_banks': {
          'meaning': 'Копилки — это цели, на которые ты копишь деньги. Они не входят в баланс, чтобы видеть прогресс.',
          'advice': 'Создай копилку для цели, пополняй её и следи за прогрессом!',
        },
        'calendar': {
          'meaning': 'Календарь показывает запланированные доходы и расходы. Ты можешь планировать будущие траты.',
          'advice': 'Запланируй событие, чтобы не забыть о важной покупке или доходе.',
        },
        'earnings_lab': {
          'meaning': 'Лаборатория заработка — это место, где ты можешь запланировать задания для заработка денег.',
          'advice': 'Запланируй задание, выполни его и получи деньги после одобрения родителями.',
        },
        'notes': {
          'meaning': 'Заметки помогают записывать мысли, планы и идеи. Можно использовать шаблоны для быстрого создания.',
          'advice': 'Создай заметку с шаблоном или напиши свою. Можно привязать к событию или дате.',
        },
        'tools': {
          'meaning': 'Центр инструментов — это место, где собраны все полезные функции: калькуляторы, прогнозы, рекомендации.',
          'advice': 'Используй калькуляторы для планирования, смотри прогнозы и следуй рекомендациям Бари.',
        },
      },
      'en': {
        'balance': {
          'meaning': 'Balance is your wallet. Here you see all the money you can spend.',
          'advice': 'Add income and expenses to see how much money you have.',
        },
        'piggy_banks': {
          'meaning': 'Piggy banks are goals you save money for. They are not included in balance to see progress.',
          'advice': 'Create a piggy bank for a goal, top it up and track progress!',
        },
        'calendar': {
          'meaning': 'Calendar shows planned income and expenses. You can plan future spending.',
          'advice': 'Plan an event so you don\'t forget about an important purchase or income.',
        },
        'earnings_lab': {
          'meaning': 'Earnings Lab is where you can plan tasks to earn money.',
          'advice': 'Plan a task, complete it and get money after parent approval.',
        },
        'notes': {
          'meaning': 'Notes help record thoughts, plans and ideas. You can use templates for quick creation.',
          'advice': 'Create a note with a template or write your own. Can be linked to an event or date.',
        },
        'tools': {
          'meaning': 'Tools Hub is where all useful features are collected: calculators, forecasts, recommendations.',
          'advice': 'Use calculators for planning, view forecasts and follow Bari\'s recommendations.',
        },
      },
      'de': {
        'balance': {
          'meaning': 'Kontostand ist deine Geldbörse. Hier siehst du alles Geld, das du ausgeben kannst.',
          'advice': 'Füge Einnahmen und Ausgaben hinzu, um zu sehen, wie viel Geld du hast.',
        },
        'piggy_banks': {
          'meaning': 'Sparschweine sind Ziele, für die du Geld sparst. Sie sind nicht im Kontostand, um den Fortschritt zu sehen.',
          'advice': 'Erstelle ein Sparschwein für ein Ziel, fülle es auf und verfolge den Fortschritt!',
        },
        'calendar': {
          'meaning': 'Kalender zeigt geplante Einnahmen und Ausgaben. Du kannst zukünftige Ausgaben planen.',
          'advice': 'Plane ein Ereignis, damit du einen wichtigen Kauf oder Einnahmen nicht vergisst.',
        },
        'earnings_lab': {
          'meaning': 'Verdienstlabor ist der Ort, an dem du Aufgaben planen kannst, um Geld zu verdienen.',
          'advice': 'Plane eine Aufgabe, führe sie aus und erhalte Geld nach Genehmigung der Eltern.',
        },
        'notes': {
          'meaning': 'Notizen helfen, Gedanken, Pläne und Ideen aufzuzeichnen. Du kannst Vorlagen für die schnelle Erstellung verwenden.',
          'advice': 'Erstelle eine Notiz mit einer Vorlage oder schreibe deine eigene. Kann mit einem Ereignis oder Datum verknüpft werden.',
        },
        'tools': {
          'meaning': 'Werkzeuge-Zentrum ist der Ort, an dem alle nützlichen Funktionen gesammelt sind: Rechner, Prognosen, Empfehlungen.',
          'advice': 'Verwende Rechner für die Planung, sieh dir Prognosen an und folge Bari\'s Empfehlungen.',
        },
      },
    };
    
    final localeExplanations = explanations[locale] ?? explanations['ru']!;
    return localeExplanations[featureId] ?? {
      'meaning': 'Эта функция помогает управлять финансами.',
      'advice': 'Попробуй использовать её!',
    };
  }

  Future<BariResponse> _buildSuggestFeatureResponse(
    BariContext ctx,
    String locale,
  ) async {
    // Анализируем контекст и предлагаем подходящие функции
    final suggestions = await _getContextualSuggestions(ctx, locale);
    
    final responses = {
      'ru': BariResponse(
        meaning: 'Вот что я предлагаю попробовать:',
        advice: 'Эти функции помогут тебе лучше управлять деньгами.',
        actions: suggestions,
        confidence: 0.9,
      ),
      'en': BariResponse(
        meaning: 'Here\'s what I suggest trying:',
        advice: 'These features will help you manage money better.',
        actions: suggestions,
        confidence: 0.9,
      ),
      'de': BariResponse(
        meaning: 'Hier ist, was ich vorschlage zu versuchen:',
        advice: 'Diese Funktionen helfen dir, Geld besser zu verwalten.',
        actions: suggestions,
        confidence: 0.9,
      ),
    };
    
    return responses[locale] ?? responses['ru']!;
  }

  Future<List<BariAction>> _getContextualSuggestions(
    BariContext ctx,
    String locale,
  ) async {
    final suggestions = <BariAction>[];
    
    // Если баланс низкий, предлагаем лабораторию заработка
    if (ctx.walletBalanceCents < 10000) { // меньше 100 руб
      suggestions.add(BariAction(
        type: BariActionType.openScreen,
        label: locale == 'ru' ? '💼 Лаборатория заработка' : '💼 Earnings Lab',
        payload: 'earnings_lab',
      ));
    }
    
    // Если есть копилки, предлагаем калькулятор плана копилки
    if (ctx.piggyBanksCount > 0) {
      suggestions.add(BariAction(
        type: BariActionType.openCalculator,
        label: locale == 'ru' ? '📊 План копилки' : '📊 Piggy Plan',
        payload: 'piggy_plan',
      ));
    }
    
    // Если есть запланированные события, предлагаем прогноз
    if (ctx.upcomingEventsCount > 0) {
      suggestions.add(BariAction(
        type: BariActionType.openScreen,
        label: locale == 'ru' ? '🔮 Прогноз календаря' : '🔮 Calendar Forecast',
        payload: 'calendar_forecast',
      ));
    }
    
    // Всегда предлагаем заметки
    suggestions.add(BariAction(
      type: BariActionType.openScreen,
      label: locale == 'ru' ? '📝 Заметки' : '📝 Notes',
      payload: 'notes',
    ));
    
    // Предлагаем калькуляторы
    suggestions.add(BariAction(
      type: BariActionType.openCalculator,
      label: locale == 'ru' ? '📊 Калькуляторы' : '📊 Calculators',
    ));
    
    return suggestions;
  }

  Future<BariResponse> _buildCreateNoteResponse(
    BariContext ctx,
    String locale,
  ) async {
    final responses = {
      'ru': const BariResponse(
        meaning: 'Открываю создание заметки!',
        advice: 'Ты можешь создать заметку с шаблоном или написать свою.',
        actions: [
          BariAction(type: BariActionType.openScreen, label: '📝 Заметки', payload: 'notes'),
        ],
        confidence: 0.95,
      ),
      'en': const BariResponse(
        meaning: 'Opening note creation!',
        advice: 'You can create a note with a template or write your own.',
        actions: [
          BariAction(type: BariActionType.openScreen, label: '📝 Notes', payload: 'notes'),
        ],
        confidence: 0.95,
      ),
      'de': const BariResponse(
        meaning: 'Öffne Notiz-Erstellung!',
        advice: 'Du kannst eine Notiz mit einer Vorlage erstellen oder deine eigene schreiben.',
        actions: [
          BariAction(type: BariActionType.openScreen, label: '📝 Notizen', payload: 'notes'),
        ],
        confidence: 0.95,
      ),
    };
    
    return responses[locale] ?? responses['ru']!;
  }

  Future<BariResponse> _buildOpenCalculatorResponse(
    String message,
    BariContext ctx,
    String locale,
  ) async {
    // Определяем, какой калькулятор нужен
    final calculator = _detectCalculatorFromMessage(message, locale);
    
    if (calculator != null) {
      final responses = {
        'ru': BariResponse(
          meaning: 'Открываю калькулятор!',
          advice: 'Используй калькулятор для планирования и расчётов.',
          actions: [calculator],
          confidence: 0.9,
        ),
        'en': BariResponse(
          meaning: 'Opening calculator!',
          advice: 'Use the calculator for planning and calculations.',
          actions: [calculator],
          confidence: 0.9,
        ),
        'de': BariResponse(
          meaning: 'Öffne Rechner!',
          advice: 'Verwende den Rechner für Planung und Berechnungen.',
          actions: [calculator],
          confidence: 0.9,
        ),
      };
      
      return responses[locale] ?? responses['ru']!;
    }
    
    // Если не определили, открываем список калькуляторов
    return BariResponse(
      meaning: locale == 'ru' ? 'Открываю список калькуляторов!' : 'Opening calculators list!',
      advice: locale == 'ru' ? 'Выбери нужный калькулятор.' : 'Choose the calculator you need.',
      actions: [
        BariAction(type: BariActionType.openCalculator, label: locale == 'ru' ? '📊 Калькуляторы' : '📊 Calculators'),
      ],
      confidence: 0.9,
    );
  }

  BariAction? _detectCalculatorFromMessage(String message, String locale) {
    final calculatorMap = _getCalculatorMap(locale);
    
    for (var entry in calculatorMap.entries) {
      if (message.contains(entry.key)) {
        return entry.value;
      }
    }
    
    return null;
  }

  Map<String, BariAction> _getCalculatorMap(String locale) {
    final maps = {
      'ru': {
        'план копилк': const BariAction(type: BariActionType.openCalculator, label: 'План копилки', payload: 'piggy_plan'),
        'дата цели': const BariAction(type: BariActionType.openCalculator, label: 'Дата цели', payload: 'goal_date'),
        'месячный бюджет': const BariAction(type: BariActionType.openCalculator, label: 'Месячный бюджет', payload: 'monthly_budget'),
        'подписк': const BariAction(type: BariActionType.openCalculator, label: 'Подписки', payload: 'subscriptions'),
        'можно ли купить': const BariAction(type: BariActionType.openCalculator, label: 'Можно ли купить?', payload: 'can_i_buy'),
        'сравнение цен': const BariAction(type: BariActionType.openCalculator, label: 'Сравнение цен', payload: 'price_comparison'),
        'правило 24': const BariAction(type: BariActionType.openCalculator, label: 'Правило 24 часов', payload: '24h_rule'),
        '50/30/20': const BariAction(type: BariActionType.openCalculator, label: 'Бюджет 50/30/20', payload: '50_30_20'),
        'прогноз календар': const BariAction(type: BariActionType.openCalculator, label: 'Прогноз календаря', payload: 'calendar_forecast'),
      },
      'en': {
        'piggy plan': const BariAction(type: BariActionType.openCalculator, label: 'Piggy Plan', payload: 'piggy_plan'),
        'goal date': const BariAction(type: BariActionType.openCalculator, label: 'Goal Date', payload: 'goal_date'),
        'monthly budget': const BariAction(type: BariActionType.openCalculator, label: 'Monthly Budget', payload: 'monthly_budget'),
        'subscription': const BariAction(type: BariActionType.openCalculator, label: 'Subscriptions', payload: 'subscriptions'),
        'can i buy': const BariAction(type: BariActionType.openCalculator, label: 'Can I Buy?', payload: 'can_i_buy'),
        'price comparison': const BariAction(type: BariActionType.openCalculator, label: 'Price Comparison', payload: 'price_comparison'),
        '24h rule': const BariAction(type: BariActionType.openCalculator, label: '24h Rule', payload: '24h_rule'),
        '50/30/20': const BariAction(type: BariActionType.openCalculator, label: '50/30/20 Budget', payload: '50_30_20'),
        'calendar forecast': const BariAction(type: BariActionType.openCalculator, label: 'Calendar Forecast', payload: 'calendar_forecast'),
      },
      'de': {
        'sparschwein plan': const BariAction(type: BariActionType.openCalculator, label: 'Sparschwein Plan', payload: 'piggy_plan'),
        'ziel datum': const BariAction(type: BariActionType.openCalculator, label: 'Ziel Datum', payload: 'goal_date'),
        'monatsbudget': const BariAction(type: BariActionType.openCalculator, label: 'Monatsbudget', payload: 'monthly_budget'),
        'abonnement': const BariAction(type: BariActionType.openCalculator, label: 'Abonnements', payload: 'subscriptions'),
        'kann ich kaufen': const BariAction(type: BariActionType.openCalculator, label: 'Kann ich kaufen?', payload: 'can_i_buy'),
        'preisvergleich': const BariAction(type: BariActionType.openCalculator, label: 'Preisvergleich', payload: 'price_comparison'),
        '24h regel': const BariAction(type: BariActionType.openCalculator, label: '24h Regel', payload: '24h_rule'),
        '50/30/20': const BariAction(type: BariActionType.openCalculator, label: '50/30/20 Budget', payload: '50_30_20'),
        'kalender prognose': const BariAction(type: BariActionType.openCalculator, label: 'Kalender Prognose', payload: 'calendar_forecast'),
      },
    };
    
    return maps[locale] ?? maps['ru']!;
  }

  Future<BariResponse> _buildOpenToolsResponse(
    BariContext ctx,
    String locale,
  ) async {
    final responses = {
      'ru': const BariResponse(
        meaning: 'Открываю центр инструментов!',
        advice: 'Здесь собраны все полезные функции: калькуляторы, прогнозы, рекомендации и заметки.',
        actions: [
          BariAction(type: BariActionType.openScreen, label: '🛠️ Инструменты', payload: 'tools'),
        ],
        confidence: 0.95,
      ),
      'en': const BariResponse(
        meaning: 'Opening tools hub!',
        advice: 'Here are all useful features: calculators, forecasts, recommendations and notes.',
        actions: [
          BariAction(type: BariActionType.openScreen, label: '🛠️ Tools', payload: 'tools'),
        ],
        confidence: 0.95,
      ),
      'de': const BariResponse(
        meaning: 'Öffne Werkzeuge-Zentrum!',
        advice: 'Hier sind alle nützlichen Funktionen: Rechner, Prognosen, Empfehlungen und Notizen.',
        actions: [
          BariAction(type: BariActionType.openScreen, label: '🛠️ Werkzeuge', payload: 'tools'),
        ],
        confidence: 0.95,
      ),
    };
    
    return responses[locale] ?? responses['ru']!;
  }

  Future<BariResponse> _buildCreateEventResponse(
    BariContext ctx,
    String locale,
  ) async {
    final responses = {
      'ru': const BariResponse(
        meaning: 'Открываю планирование события!',
        advice: 'Запланируй доход или расход, чтобы не забыть о важной операции.',
        actions: [
          BariAction(type: BariActionType.createPlan, label: '📅 Запланировать'),
        ],
        confidence: 0.95,
      ),
      'en': const BariResponse(
        meaning: 'Opening event planning!',
        advice: 'Plan income or expense so you don\'t forget about an important transaction.',
        actions: [
          BariAction(type: BariActionType.createPlan, label: '📅 Plan'),
        ],
        confidence: 0.95,
      ),
      'de': const BariResponse(
        meaning: 'Öffne Ereignis-Planung!',
        advice: 'Plane Einnahmen oder Ausgaben, damit du eine wichtige Transaktion nicht vergisst.',
        actions: [
          BariAction(type: BariActionType.createPlan, label: '📅 Planen'),
        ],
        confidence: 0.95,
      ),
    };
    
    return responses[locale] ?? responses['ru']!;
  }

  Future<BariResponse> _buildShowProgressResponse(
    BariContext ctx,
    String locale,
  ) async {
    final balance = ctx.walletBalanceCents;
    final piggyCount = ctx.piggyBanksCount;
    final eventsCount = ctx.upcomingEventsCount;
    final lessonsCount = ctx.lessonsCompletedCount;
    
    final responses = {
      'ru': BariResponse(
        meaning: 'Вот твой прогресс:',
        advice: 'Баланс: ${(balance / 100).toStringAsFixed(0)} руб. | Копилок: $piggyCount | Событий: $eventsCount | Уроков: $lessonsCount',
        actions: [
          const BariAction(type: BariActionType.openScreen, label: '💰 Баланс', payload: 'balance'),
          const BariAction(type: BariActionType.openScreen, label: '🐷 Копилки', payload: 'piggy_banks'),
          const BariAction(type: BariActionType.openScreen, label: '📅 Календарь', payload: 'calendar'),
          const BariAction(type: BariActionType.openScreen, label: '📚 Уроки', payload: 'lessons'),
        ],
        confidence: 0.95,
      ),
      'en': BariResponse(
        meaning: 'Here\'s your progress:',
        advice: 'Balance: ${(balance / 100).toStringAsFixed(0)} | Piggy Banks: $piggyCount | Events: $eventsCount | Lessons: $lessonsCount',
        actions: [
          const BariAction(type: BariActionType.openScreen, label: '💰 Balance', payload: 'balance'),
          const BariAction(type: BariActionType.openScreen, label: '🐷 Piggy Banks', payload: 'piggy_banks'),
          const BariAction(type: BariActionType.openScreen, label: '📅 Calendar', payload: 'calendar'),
          const BariAction(type: BariActionType.openScreen, label: '📚 Lessons', payload: 'lessons'),
        ],
        confidence: 0.95,
      ),
      'de': BariResponse(
        meaning: 'Hier ist dein Fortschritt:',
        advice: 'Kontostand: ${(balance / 100).toStringAsFixed(0)} | Sparschweine: $piggyCount | Ereignisse: $eventsCount | Lektionen: $lessonsCount',
        actions: [
          const BariAction(type: BariActionType.openScreen, label: '💰 Kontostand', payload: 'balance'),
          const BariAction(type: BariActionType.openScreen, label: '🐷 Sparschweine', payload: 'piggy_banks'),
          const BariAction(type: BariActionType.openScreen, label: '📅 Kalender', payload: 'calendar'),
          const BariAction(type: BariActionType.openScreen, label: '📚 Lektionen', payload: 'lessons'),
        ],
        confidence: 0.95,
      ),
    };
    
    return responses[locale] ?? responses['ru']!;
  }
}

enum FeatureIntent {
  showFeatures,
  openFeature,
  explainFeature,
  suggestFeature,
  createNote,
  openCalculator,
  openTools,
  createEvent,
  showProgress,
  unknown,
}
