import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../bari_context.dart';
import '../bari_models.dart';
import 'bari_provider.dart';
import 'synonym_matcher.dart';

class KnowledgePackProvider implements BariProvider {
  final List<Map<String, dynamic>> _cards = [];
  bool _loaded = false;

  // Расширенный мини-глоссарий для быстрых ответов
  static const Map<String, Map<String, String>> _miniGlossary = {
    'экономика': {
      'meaning':
          'Экономика — это то, как люди, компании и государства зарабатывают, тратят и распределяют деньги и ресурсы.',
      'advice':
          'Пример: если у тебя есть 20€, экономика отвечает на вопрос — что выгоднее: потратить сейчас или накопить на цель.',
    },
    'рынок': {
      'meaning':
          'Рынок — это место (или система), где покупатели и продавцы обмениваются товарами и услугами, а цена зависит от спроса и предложения.',
      'advice':
          'Если много желающих купить, цена обычно растёт. Если товар никому не нужен — продавцы снижают цену.',
    },
    'инфляция': {
      'meaning':
          'Инфляция — это когда со временем на те же деньги можно купить меньше, потому что цены в среднем растут.',
      'advice':
          'Поэтому копить важно с целью: часть — на расходы, часть — на накопления.',
    },
    'процент': {
      'meaning': 'Процент — это доля от целого. 10% — это 10 из 100.',
      'advice':
          'Если откладывать 10% от каждого дохода, то с 20€ ты отложишь 2€.',
    },
    'бюджет': {
      'meaning':
          'Бюджет — это план денег: сколько придёт (доходы) и сколько уйдёт (расходы) за период.',
      'advice': 'Попробуй правило 50/30/20: нужды/хочу/накопления.',
    },
    'доход': {
      'meaning': 'Доход — это деньги, которые ты получаешь: карманные, подарки, заработок.',
      'advice': 'Записывай все доходы, чтобы знать, сколько у тебя есть.',
    },
    'расход': {
      'meaning': 'Расход — это деньги, которые ты тратишь на покупки и услуги.',
      'advice': 'Отслеживай расходы — так поймёшь, куда уходят деньги.',
    },
    'накопления': {
      'meaning': 'Накопления — деньги, которые ты откладываешь на будущие цели.',
      'advice': 'Откладывай хотя бы 10-20% от каждого дохода.',
    },
    'кредит': {
      'meaning': 'Кредит — это деньги, которые берёшь взаймы и должен вернуть с процентами.',
      'advice': 'Лучше копить, чем брать в долг. Кредит — крайняя мера.',
    },
    'депозит': {
      'meaning': 'Депозит — деньги, которые хранишь в банке и получаешь проценты.',
      'advice': 'Это способ заставить деньги "работать" на тебя.',
    },
    'капитал': {
      'meaning': 'Капитал — это деньги или имущество, которое можно использовать для заработка.',
      'advice': 'Сначала накопи, потом думай об инвестициях.',
    },
    'ликвидность': {
      'meaning': 'Ликвидность — насколько быстро можно превратить что-то в деньги.',
      'advice': 'Наличные — самые ликвидные. Квартира — менее ликвидна.',
    },
    'актив': {
      'meaning': 'Актив — то, что приносит деньги или растёт в цене.',
      'advice': 'Знания — тоже актив! Они помогают зарабатывать больше.',
    },
    'пассив': {
      'meaning': 'Пассив — то, что требует денег на содержание.',
      'advice': 'Машина — часто пассив (бензин, ремонт). Подумай, прежде чем покупать.',
    },
    'дивиденды': {
      'meaning': 'Дивиденды — часть прибыли компании, которую платят владельцам акций.',
      'advice': 'Это как "зарплата" за владение кусочком компании.',
    },
    'портфель': {
      'meaning': 'Инвестиционный портфель — набор разных вложений для снижения риска.',
      'advice': 'Не клади все яйца в одну корзину — диверсифицируй!',
    },
    'диверсификация': {
      'meaning': 'Диверсификация — распределение денег по разным вложениям.',
      'advice': 'Если одно падает, другое может расти — это защита.',
    },
  };

  Future<void> init() async {
    if (_loaded) return;
    // Загружаем русский по умолчанию (для обратной совместимости)
    await _loadKnowledge('ru');
    _loaded = true;
  }

  /// Загружает базу знаний для указанного языка
  Future<void> _loadKnowledge(String locale) async {
    try {
      // Пробуем оба пути для совместимости
      String raw;
      try {
        raw = await rootBundle.loadString('assets/bari/knowledge_$locale.json');
      } catch (e) {
        try {
          raw = await rootBundle.loadString('assets/bari_knowledge/$locale.json');
        } catch (e2) {
          // Если файл для языка не найден, используем русский как fallback
          if (locale != 'ru') {
            return await _loadKnowledge('ru');
          }
          rethrow;
        }
      }
      final data = jsonDecode(raw) as List;
      _cards.clear();
      _cards.addAll(data.cast<Map<String, dynamic>>());
    } catch (e) {
      // Если файл не найден, продолжаем без карточек
      _cards.clear();
    }
  }

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
    if (!_loaded) await init();
    
    final locale = _extractLocale(ctx.localeTag);
    // Загружаем базу знаний для текущего языка
    await _loadKnowledge(locale);
    
    final q = message.toLowerCase().trim();
    if (q.length < 2) return null;

    // === УМНЫЙ ПОИСК В ГЛОССАРИИ ===
    // Получаем глоссарий для текущего языка
    final glossary = _getGlossary(locale);
    
    // 1. Сначала пробуем точное совпадение
    Map<String, String>? glossaryMatch = glossary[q];
    
    // 2. Если не нашли — ищем термин в вопросе "что такое X", "что значит X" и т.д.
    if (glossaryMatch == null) {
      final termMatch = RegExp(
        r'(?:что\s+такое|что\s+значит|что\s+означает|объясни|расскажи\s+(?:про|о)|как\s+понять)\s+(.+?)(?:\?|$)',
      ).firstMatch(q);
      
      if (termMatch != null) {
        final term = termMatch.group(1)!.trim();
        glossaryMatch = _miniGlossary[term];
        
        // Если точного совпадения нет, ищем частичное
        if (glossaryMatch == null) {
          for (final key in glossary.keys) {
            if (term.contains(key) || key.contains(term)) {
              glossaryMatch = glossary[key];
              break;
            }
          }
        }
      }
    }
    
    // 3. Если всё ещё не нашли — ищем любой термин глоссария в сообщении
    if (glossaryMatch == null) {
      for (final key in glossary.keys) {
        if (q.contains(key)) {
          glossaryMatch = glossary[key];
          break;
        }
      }
    }
    
    // Если нашли в глоссарии — возвращаем ответ
    if (glossaryMatch != null) {
      return BariResponse(
        meaning: glossaryMatch['meaning'] ?? '',
        advice: glossaryMatch['advice'] ?? '',
        actions: _getDefaultActions(locale),
        confidence: 0.75,
      );
    }

    // === ПОИСК В КАРТОЧКАХ ЗНАНИЙ ===
    if (_cards.isEmpty) return null;

    int bestScore = 0;
    Map<String, dynamic>? best;

    // Используем улучшенный матчер с синонимами
    for (final c in _cards) {
      final triggers = (c['triggers'] as List?)?.cast<String>() ?? const [];
      final keywords = (c['keywords'] as List?)?.cast<String>() ?? const [];
      final kws = triggers.isNotEmpty ? triggers : keywords;
      final tags = (c['tags'] as List?)?.cast<String>() ?? const [];

      final score = SynonymMatcher.calculateMatchScore(q, kws, tags);

      if (score > bestScore) {
        bestScore = score;
        best = c;
      }
    }

    if (best == null || bestScore < 2) return null;

    final meaning = (best['meaning'] ?? '').toString();
    final advice = (best['advice'] ?? best['whatToDo'] ?? best['todo'] ?? '').toString();
    if (meaning.isEmpty || advice.isEmpty) return null;

    final actionsJson = best['actions'];
    final actions = <BariAction>[];

    if (actionsJson is List) {
      for (final a in actionsJson) {
        if (a is Map<String, dynamic>) {
          try {
            final typeStr = (a['type'] as String?) ?? '';
            final type = BariActionType.values.firstWhere(
              (e) => e.name == typeStr,
              orElse: () => BariActionType.explainSimpler,
            );
            actions.add(
              BariAction(
                type: type,
                label: (a['label'] as String?) ?? '',
                payload: a['payload'] as String?,
              ),
            );
          } catch (e) {
            continue;
          }
        } else if (a is String) {
          final action = _mapOldAction(a, locale: locale);
          if (action != null) actions.add(action);
        }
      }
    }

    return BariResponse(
      meaning: meaning,
      advice: advice,
      actions: actions.isEmpty
          ? _getDefaultActions(locale)
          : actions.take(4).toList(),
      confidence: 0.72,
    );
  }

  /// Получает глоссарий для указанного языка
  Map<String, Map<String, String>> _getGlossary(String locale) {
    // Пока используем только русский глоссарий
    // В будущем можно добавить en и de версии
    return _miniGlossary;
  }

  /// Получает действия по умолчанию для указанного языка
  List<BariAction> _getDefaultActions(String locale) {
    final actions = {
      'ru': const [
        BariAction(
          type: BariActionType.openScreen,
          label: 'Калькуляторы',
          payload: 'calculators',
        ),
        BariAction(
          type: BariActionType.openScreen,
          label: 'Уроки',
          payload: 'lessons',
        ),
        BariAction(
          type: BariActionType.explainSimpler,
          label: 'Объясни проще',
        ),
      ],
      'en': const [
        BariAction(
          type: BariActionType.openScreen,
          label: 'Calculators',
          payload: 'calculators',
        ),
        BariAction(
          type: BariActionType.openScreen,
          label: 'Lessons',
          payload: 'lessons',
        ),
        BariAction(
          type: BariActionType.explainSimpler,
          label: 'Explain simpler',
        ),
      ],
      'de': const [
        BariAction(
          type: BariActionType.openScreen,
          label: 'Rechner',
          payload: 'calculators',
        ),
        BariAction(
          type: BariActionType.openScreen,
          label: 'Lektionen',
          payload: 'lessons',
        ),
        BariAction(
          type: BariActionType.explainSimpler,
          label: 'Einfacher erklären',
        ),
      ],
    };
    return actions[locale] ?? actions['ru']!;
  }

  BariAction? _mapOldAction(String actionStr, {String locale = 'ru'}) {
    final labels = _getActionLabels(locale);
    
    switch (actionStr) {
      case 'open_balance':
        return BariAction(
          type: BariActionType.openScreen,
          label: labels['balance']!,
          payload: 'balance',
        );
      case 'open_piggies':
        return BariAction(
          type: BariActionType.openScreen,
          label: labels['piggy_banks']!,
          payload: 'piggy_banks',
        );
      case 'open_calendar':
        return BariAction(
          type: BariActionType.openScreen,
          label: labels['calendar']!,
          payload: 'calendar',
        );
      case 'open_earnings_lab':
        return BariAction(
          type: BariActionType.openScreen,
          label: labels['earnings_lab']!,
          payload: 'earnings_lab',
        );
      case 'open_lessons':
        return BariAction(
          type: BariActionType.openScreen,
          label: labels['lessons']!,
          payload: 'lessons',
        );
      case 'open_settings':
        return BariAction(
          type: BariActionType.openScreen,
          label: labels['settings']!,
          payload: 'settings',
        );
      case 'open_calculators':
        return BariAction(
          type: BariActionType.openScreen,
          label: labels['calculators']!,
          payload: 'calculators',
        );
      case 'explain_simpler':
        return BariAction(
          type: BariActionType.explainSimpler,
          label: labels['explain_simpler']!,
        );
      default:
        return null;
    }
  }

  /// Получает локализованные метки для действий
  Map<String, String> _getActionLabels(String locale) {
    final labels = {
      'ru': {
        'balance': 'Баланс',
        'piggy_banks': 'Копилки',
        'calendar': 'Календарь',
        'earnings_lab': 'Лаборатория',
        'lessons': 'Уроки',
        'settings': 'Настройки',
        'calculators': 'Калькуляторы',
        'explain_simpler': 'Объясни проще',
      },
      'en': {
        'balance': 'Balance',
        'piggy_banks': 'Piggy Banks',
        'calendar': 'Calendar',
        'earnings_lab': 'Earnings Lab',
        'lessons': 'Lessons',
        'settings': 'Settings',
        'calculators': 'Calculators',
        'explain_simpler': 'Explain simpler',
      },
      'de': {
        'balance': 'Kontostand',
        'piggy_banks': 'Sparschweine',
        'calendar': 'Kalender',
        'earnings_lab': 'Verdienstlabor',
        'lessons': 'Lektionen',
        'settings': 'Einstellungen',
        'calculators': 'Rechner',
        'explain_simpler': 'Einfacher erklären',
      },
    };
    return labels[locale] ?? labels['ru']!;
  }
}
