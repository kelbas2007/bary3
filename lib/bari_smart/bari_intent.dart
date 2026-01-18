enum BariIntent {
  smallTalk,
  appHelp,
  finance,
  knowledge,
  onlineReference,
  unknown,
}

class BariIntentDetector {
  static BariIntent detect(String msg) {
    final t = msg.trim().toLowerCase();

    // 1) small talk
    const small = [
      'как дела',
      'привет',
      'здарова',
      'пока',
      'спасибо',
      'кто ты',
      'что ты умеешь',
      'хай',
      'добрый день',
      'добрый вечер',
      'доброе утро',
      'скучно',
      'я устал',
      'помоги',
      'ты тупой',
      'ты глупый',
      'что нового',
      'как ты',
    ];
    if (small.any((k) => t.contains(k))) return BariIntent.smallTalk;

    // 2) app help keywords
    const app = [
      'баланс',
      'кошелёк',
      'копилк',
      'календар',
      'одобр',
      'родител',
      'задани',
      'лаборатор',
      'earnings lab',
      'где баланс',
      'где копилк',
      'где календар',
      'почему копилка не в балансе',
      'что такое одобрение',
      'родительское одобрение',
    ];
    if (app.any((k) => t.contains(k))) return BariIntent.appHelp;

    // 3) finance keywords
    const fin = [
      'инфляц',
      'процент',
      'цель',
      'бюджет',
      'хочу',
      'нужно',
      'долг',
      'подушка',
      'накоп',
      'можно ли купить',
      'потяну ли',
      'хватит ли',
      'депозит',
      'кредит',
      'доход',
      'расход',
      'валют',
      'курс',
      'цена',
      'скидк',
      'подписк',
      'план',
      'хочу и нужно',
      'нужды и желания',
    ];
    if (fin.any((k) => t.contains(k))) return BariIntent.finance;

    // 3.5) online reference intent (короткие справочные запросы)
    const online = [
      'что такое',
      'что значит',
      'объясни',
      'определи',
      'определение',
      'курс',
      'инфляц',
      'википед',
      'wiki',
      'wikipedia',
      'wiktionary',
    ];
    if (online.any((k) => t.contains(k))) return BariIntent.onlineReference;

    // 4) knowledge keywords (общие вопросы "что такое", "что значит")
    if (t.startsWith('что такое') ||
        t.startsWith('что значит') ||
        t.startsWith('объясни') ||
        t.startsWith('расскажи про')) {
      return BariIntent.knowledge;
    }

    // fallback
    return BariIntent.unknown;
  }
}
