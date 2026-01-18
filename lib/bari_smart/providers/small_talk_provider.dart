import '../bari_context.dart';
import '../bari_models.dart';
import '../storage/bari_settings_store.dart';
import 'bari_provider.dart';

class SmallTalkProvider implements BariProvider {
  final BariSettingsStore? settings;

  SmallTalkProvider({this.settings});

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
    
    // Проверяем, включена ли болтовня
    if (settings != null && !settings!.smallTalkEnabled) {
      return _getDisabledResponse(locale);
    }

    final m = message.trim().toLowerCase();

    // Локализованные паттерны
    final patterns = _getPatterns(locale);
    final responses = _getResponses(locale);

    // Приветствия
    for (final pattern in patterns['greetings']!) {
      if (m.contains(pattern)) {
        return responses['greetings']!;
      }
    }

    // Как дела
    for (final pattern in patterns['how_are_you']!) {
      if (m.contains(pattern)) {
        return responses['how_are_you']!;
      }
    }

    // Благодарность
    for (final pattern in patterns['thanks']!) {
      if (m.contains(pattern)) {
        return responses['thanks']!;
      }
    }

    // Прощание
    for (final pattern in patterns['goodbye']!) {
      if (m.contains(pattern)) {
        return responses['goodbye']!;
      }
    }

    // Кто ты / что умеешь
    for (final pattern in patterns['who_are_you']!) {
      if (m.contains(pattern)) {
        return responses['who_are_you']!;
      }
    }

    // Скучно / устал
    for (final pattern in patterns['bored']!) {
      if (m.contains(pattern)) {
        return responses['bored']!;
      }
    }

    // Помоги (общий запрос)
    for (final pattern in patterns['help']!) {
      if (m.contains(pattern) && !m.contains('купить') && !m.contains('копить')) {
        return responses['help']!;
      }
    }

    // Я хочу купить
    for (final pattern in patterns['want_to_buy']!) {
      if (m.contains(pattern)) {
        return responses['want_to_buy']!;
      }
    }

    // Защита от негатива
    for (final pattern in patterns['negative']!) {
      if (m.contains(pattern)) {
        return responses['negative']!;
      }
    }

    return null;
  }

  BariResponse _getDisabledResponse(String locale) {
    final responses = {
      'ru': const BariResponse(
        meaning: 'Давай про деньги и приложение!',
        advice: 'Спроси про баланс, копилки, календарь или финансовые понятия.',
        actions: [
          BariAction(type: BariActionType.openScreen, label: 'Баланс', payload: 'balance'),
          BariAction(type: BariActionType.openScreen, label: 'Копилки', payload: 'piggy_banks'),
          BariAction(type: BariActionType.openScreen, label: 'Калькуляторы', payload: 'calculators'),
        ],
      ),
      'en': const BariResponse(
        meaning: 'Let\'s talk about money and the app!',
        advice: 'Ask about balance, piggy banks, calendar, or financial concepts.',
        actions: [
          BariAction(type: BariActionType.openScreen, label: 'Balance', payload: 'balance'),
          BariAction(type: BariActionType.openScreen, label: 'Piggy Banks', payload: 'piggy_banks'),
          BariAction(type: BariActionType.openScreen, label: 'Calculators', payload: 'calculators'),
        ],
      ),
      'de': const BariResponse(
        meaning: 'Lass uns über Geld und die App sprechen!',
        advice: 'Frage nach Kontostand, Sparschweinen, Kalender oder Finanzkonzepten.',
        actions: [
          BariAction(type: BariActionType.openScreen, label: 'Kontostand', payload: 'balance'),
          BariAction(type: BariActionType.openScreen, label: 'Sparschweine', payload: 'piggy_banks'),
          BariAction(type: BariActionType.openScreen, label: 'Rechner', payload: 'calculators'),
        ],
      ),
    };
    return responses[locale] ?? responses['ru']!;
  }

  Map<String, List<String>> _getPatterns(String locale) {
    final patterns = {
      'ru': {
        'greetings': ['привет', 'хай', 'здаров', 'добрый день', 'добрый вечер', 'доброе утро'],
        'how_are_you': ['как дела', 'как ты', 'что нового'],
        'thanks': ['спасибо', 'спс', 'благодарю'],
        'goodbye': ['пока', 'до свидания', 'увидимся'],
        'who_are_you': ['кто ты', 'что ты умеешь', 'что ты за'],
        'bored': ['скучно', 'я устал', 'устал'],
        'help': ['помоги'],
        'want_to_buy': ['я хочу купить', 'хочу купить'],
        'negative': ['ты тупой', 'ты глупый', 'ты не понимаешь'],
      },
      'en': {
        'greetings': ['hi', 'hello', 'hey', 'good morning', 'good afternoon', 'good evening'],
        'how_are_you': ['how are you', 'how\'s it going', 'what\'s up'],
        'thanks': ['thanks', 'thank you', 'thx'],
        'goodbye': ['bye', 'goodbye', 'see you'],
        'who_are_you': ['who are you', 'what can you do', 'what are you'],
        'bored': ['bored', 'i\'m tired', 'tired'],
        'help': ['help'],
        'want_to_buy': ['i want to buy', 'want to buy'],
        'negative': ['you\'re stupid', 'you\'re dumb', 'you don\'t understand'],
      },
      'de': {
        'greetings': ['hallo', 'hi', 'guten tag', 'guten morgen', 'guten abend'],
        'how_are_you': ['wie geht es dir', 'wie geht\'s', 'was geht'],
        'thanks': ['danke', 'danke schön', 'vielen dank'],
        'goodbye': ['tschüss', 'auf wiedersehen', 'bis später'],
        'who_are_you': ['wer bist du', 'was kannst du', 'was bist du'],
        'bored': ['langweilig', 'ich bin müde', 'müde'],
        'help': ['hilf'],
        'want_to_buy': ['ich will kaufen', 'will kaufen'],
        'negative': ['du bist dumm', 'du verstehst nicht'],
      },
    };
    return patterns[locale] ?? patterns['ru']!;
  }

  Map<String, BariResponse> _getResponses(String locale) {
    final responses = {
      'ru': {
        'greetings': const BariResponse(
          meaning: 'Привет! Я в порядке и рядом.',
          advice: 'Спроси, что ты хочешь сделать: потратить, накопить или запланировать.',
          actions: [
            BariAction(type: BariActionType.openScreen, label: 'Баланс', payload: 'balance'),
            BariAction(type: BariActionType.openScreen, label: 'Копилки', payload: 'piggy_banks'),
            BariAction(type: BariActionType.openScreen, label: 'Календарь', payload: 'calendar'),
            BariAction(type: BariActionType.openScreen, label: 'Калькуляторы', payload: 'calculators'),
          ],
          confidence: 0.95,
        ),
        'how_are_you': const BariResponse(
          meaning: 'У меня всё отлично — я на дежурстве у твоих денег 🙂',
          advice: 'Хочешь — подскажу, как лучше копить или проверить, куда уходят деньги.',
          actions: [
            BariAction(type: BariActionType.openScreen, label: 'Баланс', payload: 'balance'),
            BariAction(type: BariActionType.openScreen, label: 'Калькуляторы', payload: 'calculators'),
            BariAction(type: BariActionType.openScreen, label: 'Копилки', payload: 'piggy_banks'),
          ],
          confidence: 0.95,
        ),
        'thanks': const BariResponse(
          meaning: 'Пожалуйста! Мне нравится, когда деньги ведут себя прилично 😄',
          advice: 'Если хочешь — сделаем план цели или проверим баланс.',
          actions: [
            BariAction(type: BariActionType.openScreen, label: 'Копилки', payload: 'piggy_banks'),
            BariAction(type: BariActionType.openScreen, label: 'Баланс', payload: 'balance'),
            BariAction(type: BariActionType.createPlan, label: 'Сделать план'),
          ],
          confidence: 0.95,
        ),
        'goodbye': const BariResponse(
          meaning: 'До встречи! Удачи с деньгами 💰',
          advice: 'Не забывай про цели и регулярные взносы.',
          actions: [
            BariAction(type: BariActionType.openScreen, label: 'Копилки', payload: 'piggy_banks'),
          ],
          confidence: 0.9,
        ),
        'who_are_you': const BariResponse(
          meaning: 'Я Бари — помощник по деньгам и по этому приложению.',
          advice: 'Спроси про баланс, копилки, календарь или как копить на цель.',
          actions: [
            BariAction(type: BariActionType.openScreen, label: 'Баланс', payload: 'balance'),
            BariAction(type: BariActionType.explainSimpler, label: 'Объясни проще'),
          ],
          confidence: 0.95,
        ),
        'bored': const BariResponse(
          meaning: 'Понимаю. Иногда полезно отвлечься на что-то практичное.',
          advice: 'Хочешь — проверим баланс или сделаем план на неделю?',
          actions: [
            BariAction(type: BariActionType.openScreen, label: 'Баланс', payload: 'balance'),
            BariAction(type: BariActionType.openScreen, label: 'Калькуляторы', payload: 'calculators'),
            BariAction(type: BariActionType.createPlan, label: 'Сделать план'),
          ],
          confidence: 0.85,
        ),
        'help': const BariResponse(
          meaning: 'Конечно! С чем именно нужна помощь?',
          advice: 'Могу помочь с балансом, копилками, календарём или финансовыми понятиями.',
          actions: [
            BariAction(type: BariActionType.openScreen, label: 'Баланс', payload: 'balance'),
            BariAction(type: BariActionType.openScreen, label: 'Копилки', payload: 'piggy_banks'),
            BariAction(type: BariActionType.openScreen, label: 'Калькуляторы', payload: 'calculators'),
          ],
          confidence: 0.9,
        ),
        'want_to_buy': const BariResponse(
          meaning: 'Отлично! Давай проверим, можно ли купить сейчас.',
          advice: 'Открой калькулятор "Можно ли купить сейчас?" и введи цену.',
          actions: [
            BariAction(type: BariActionType.openCalculator, label: 'Калькулятор покупки'),
            BariAction(type: BariActionType.openScreen, label: 'Баланс', payload: 'balance'),
          ],
          confidence: 0.9,
        ),
        'negative': const BariResponse(
          meaning: 'Понимаю, что-то не так. Давай попробуем по-другому.',
          advice: 'Спроси про баланс, копилки или калькуляторы — там точно помогу.',
          actions: [
            BariAction(type: BariActionType.openScreen, label: 'Баланс', payload: 'balance'),
            BariAction(type: BariActionType.openScreen, label: 'Копилки', payload: 'piggy_banks'),
            BariAction(type: BariActionType.explainSimpler, label: 'Объясни проще'),
          ],
        ),
      },
      'en': {
        'greetings': const BariResponse(
          meaning: 'Hello! I\'m fine and here.',
          advice: 'Ask what you want to do: spend, save, or plan.',
          actions: [
            BariAction(type: BariActionType.openScreen, label: 'Balance', payload: 'balance'),
            BariAction(type: BariActionType.openScreen, label: 'Piggy Banks', payload: 'piggy_banks'),
            BariAction(type: BariActionType.openScreen, label: 'Calendar', payload: 'calendar'),
            BariAction(type: BariActionType.openScreen, label: 'Calculators', payload: 'calculators'),
          ],
          confidence: 0.95,
        ),
        'how_are_you': const BariResponse(
          meaning: 'I\'m great — I\'m on duty with your money 🙂',
          advice: 'Want me to suggest how to save better or check where money goes?',
          actions: [
            BariAction(type: BariActionType.openScreen, label: 'Balance', payload: 'balance'),
            BariAction(type: BariActionType.openScreen, label: 'Calculators', payload: 'calculators'),
            BariAction(type: BariActionType.openScreen, label: 'Piggy Banks', payload: 'piggy_banks'),
          ],
          confidence: 0.95,
        ),
        'thanks': const BariResponse(
          meaning: 'You\'re welcome! I like it when money behaves well 😄',
          advice: 'If you want — let\'s make a goal plan or check the balance.',
          actions: [
            BariAction(type: BariActionType.openScreen, label: 'Piggy Banks', payload: 'piggy_banks'),
            BariAction(type: BariActionType.openScreen, label: 'Balance', payload: 'balance'),
            BariAction(type: BariActionType.createPlan, label: 'Make a plan'),
          ],
          confidence: 0.95,
        ),
        'goodbye': const BariResponse(
          meaning: 'See you! Good luck with money 💰',
          advice: 'Don\'t forget about goals and regular deposits.',
          actions: [
            BariAction(type: BariActionType.openScreen, label: 'Piggy Banks', payload: 'piggy_banks'),
          ],
          confidence: 0.9,
        ),
        'who_are_you': const BariResponse(
          meaning: 'I\'m Bari — a money and app assistant.',
          advice: 'Ask about balance, piggy banks, calendar, or how to save for a goal.',
          actions: [
            BariAction(type: BariActionType.openScreen, label: 'Balance', payload: 'balance'),
            BariAction(type: BariActionType.explainSimpler, label: 'Explain simpler'),
          ],
          confidence: 0.95,
        ),
        'bored': const BariResponse(
          meaning: 'I understand. Sometimes it\'s useful to focus on something practical.',
          advice: 'Want to check the balance or make a weekly plan?',
          actions: [
            BariAction(type: BariActionType.openScreen, label: 'Balance', payload: 'balance'),
            BariAction(type: BariActionType.openScreen, label: 'Calculators', payload: 'calculators'),
            BariAction(type: BariActionType.createPlan, label: 'Make a plan'),
          ],
          confidence: 0.85,
        ),
        'help': const BariResponse(
          meaning: 'Of course! What exactly do you need help with?',
          advice: 'I can help with balance, piggy banks, calendar, or financial concepts.',
          actions: [
            BariAction(type: BariActionType.openScreen, label: 'Balance', payload: 'balance'),
            BariAction(type: BariActionType.openScreen, label: 'Piggy Banks', payload: 'piggy_banks'),
            BariAction(type: BariActionType.openScreen, label: 'Calculators', payload: 'calculators'),
          ],
          confidence: 0.9,
        ),
        'want_to_buy': const BariResponse(
          meaning: 'Great! Let\'s check if you can buy it now.',
          advice: 'Open the "Can I buy now?" calculator and enter the price.',
          actions: [
            BariAction(type: BariActionType.openCalculator, label: 'Purchase calculator'),
            BariAction(type: BariActionType.openScreen, label: 'Balance', payload: 'balance'),
          ],
          confidence: 0.9,
        ),
        'negative': const BariResponse(
          meaning: 'I understand something\'s wrong. Let\'s try differently.',
          advice: 'Ask about balance, piggy banks, or calculators — I\'ll definitely help there.',
          actions: [
            BariAction(type: BariActionType.openScreen, label: 'Balance', payload: 'balance'),
            BariAction(type: BariActionType.openScreen, label: 'Piggy Banks', payload: 'piggy_banks'),
            BariAction(type: BariActionType.explainSimpler, label: 'Explain simpler'),
          ],
        ),
      },
      'de': {
        'greetings': const BariResponse(
          meaning: 'Hallo! Mir geht es gut und ich bin hier.',
          advice: 'Frage, was du tun möchtest: ausgeben, sparen oder planen.',
          actions: [
            BariAction(type: BariActionType.openScreen, label: 'Kontostand', payload: 'balance'),
            BariAction(type: BariActionType.openScreen, label: 'Sparschweine', payload: 'piggy_banks'),
            BariAction(type: BariActionType.openScreen, label: 'Kalender', payload: 'calendar'),
            BariAction(type: BariActionType.openScreen, label: 'Rechner', payload: 'calculators'),
          ],
          confidence: 0.95,
        ),
        'how_are_you': const BariResponse(
          meaning: 'Mir geht es großartig — ich bin im Dienst mit deinem Geld 🙂',
          advice: 'Soll ich vorschlagen, wie man besser spart oder prüfen, wohin das Geld geht?',
          actions: [
            BariAction(type: BariActionType.openScreen, label: 'Kontostand', payload: 'balance'),
            BariAction(type: BariActionType.openScreen, label: 'Rechner', payload: 'calculators'),
            BariAction(type: BariActionType.openScreen, label: 'Sparschweine', payload: 'piggy_banks'),
          ],
          confidence: 0.95,
        ),
        'thanks': const BariResponse(
          meaning: 'Bitte! Ich mag es, wenn Geld sich gut benimmt 😄',
          advice: 'Wenn du willst — lass uns einen Zielplan machen oder den Kontostand prüfen.',
          actions: [
            BariAction(type: BariActionType.openScreen, label: 'Sparschweine', payload: 'piggy_banks'),
            BariAction(type: BariActionType.openScreen, label: 'Kontostand', payload: 'balance'),
            BariAction(type: BariActionType.createPlan, label: 'Plan erstellen'),
          ],
          confidence: 0.95,
        ),
        'goodbye': const BariResponse(
          meaning: 'Bis später! Viel Glück mit dem Geld 💰',
          advice: 'Vergiss nicht die Ziele und regelmäßige Einzahlungen.',
          actions: [
            BariAction(type: BariActionType.openScreen, label: 'Sparschweine', payload: 'piggy_banks'),
          ],
          confidence: 0.9,
        ),
        'who_are_you': const BariResponse(
          meaning: 'Ich bin Bari — ein Geld- und App-Assistent.',
          advice: 'Frage nach Kontostand, Sparschweinen, Kalender oder wie man für ein Ziel spart.',
          actions: [
            BariAction(type: BariActionType.openScreen, label: 'Kontostand', payload: 'balance'),
            BariAction(type: BariActionType.explainSimpler, label: 'Einfacher erklären'),
          ],
          confidence: 0.95,
        ),
        'bored': const BariResponse(
          meaning: 'Ich verstehe. Manchmal ist es nützlich, sich auf etwas Praktisches zu konzentrieren.',
          advice: 'Möchtest du den Kontostand prüfen oder einen Wochenplan erstellen?',
          actions: [
            BariAction(type: BariActionType.openScreen, label: 'Kontostand', payload: 'balance'),
            BariAction(type: BariActionType.openScreen, label: 'Rechner', payload: 'calculators'),
            BariAction(type: BariActionType.createPlan, label: 'Plan erstellen'),
          ],
          confidence: 0.85,
        ),
        'help': const BariResponse(
          meaning: 'Natürlich! Wobei genau brauchst du Hilfe?',
          advice: 'Ich kann bei Kontostand, Sparschweinen, Kalender oder Finanzkonzepten helfen.',
          actions: [
            BariAction(type: BariActionType.openScreen, label: 'Kontostand', payload: 'balance'),
            BariAction(type: BariActionType.openScreen, label: 'Sparschweine', payload: 'piggy_banks'),
            BariAction(type: BariActionType.openScreen, label: 'Rechner', payload: 'calculators'),
          ],
          confidence: 0.9,
        ),
        'want_to_buy': const BariResponse(
          meaning: 'Großartig! Lass uns prüfen, ob du es jetzt kaufen kannst.',
          advice: 'Öffne den "Kann ich jetzt kaufen?" Rechner und gib den Preis ein.',
          actions: [
            BariAction(type: BariActionType.openCalculator, label: 'Kaufrechner'),
            BariAction(type: BariActionType.openScreen, label: 'Kontostand', payload: 'balance'),
          ],
          confidence: 0.9,
        ),
        'negative': const BariResponse(
          meaning: 'Ich verstehe, etwas stimmt nicht. Lass uns es anders versuchen.',
          advice: 'Frage nach Kontostand, Sparschweinen oder Rechnern — dort helfe ich definitiv.',
          actions: [
            BariAction(type: BariActionType.openScreen, label: 'Kontostand', payload: 'balance'),
            BariAction(type: BariActionType.openScreen, label: 'Sparschweine', payload: 'piggy_banks'),
            BariAction(type: BariActionType.explainSimpler, label: 'Einfacher erklären'),
          ],
        ),
      },
    };
    return responses[locale] ?? responses['ru']!;
  }
}






