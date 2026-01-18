/// Утилита для умного сопоставления слов с учётом синонимов и вариаций.
/// Работает полностью офлайн.
class SynonymMatcher {
  // Синонимы и связанные слова для финансовых терминов
  static const Map<String, List<String>> _synonymGroups = {
    // Деньги
    'деньги': ['деньги', 'денег', 'деньжат', 'бабки', 'бабло', 'капуста', 'средства', 'финансы', 'кэш', 'валюта'],
    
    // Копить
    'копить': ['копить', 'накопить', 'откладывать', 'сберегать', 'собирать', 'насобирать', 'экономить'],
    
    // Тратить
    'тратить': ['тратить', 'потратить', 'расходовать', 'платить', 'оплатить', 'покупать', 'купить'],
    
    // Цель
    'цель': ['цель', 'мечта', 'желание', 'хотелка', 'план', 'задача'],
    
    // Копилка
    'копилка': ['копилка', 'сбережения', 'накопления', 'заначка', 'кубышка'],
    
    // Баланс
    'баланс': ['баланс', 'остаток', 'кошелёк', 'кошелек', 'счёт', 'счет'],
    
    // Доход
    'доход': ['доход', 'заработок', 'приход', 'получка', 'карманные', 'зарплата'],
    
    // Расход
    'расход': ['расход', 'трата', 'покупка', 'плата', 'оплата'],
    
    // Дорого/дёшево
    'дорого': ['дорого', 'дороговато', 'много стоит', 'не по карману', 'кусается цена'],
    'дёшево': ['дёшево', 'дешево', 'недорого', 'выгодно', 'по карману', 'доступно'],
    
    // Нужно/хочу
    'нужно': ['нужно', 'надо', 'необходимо', 'требуется', 'обязательно'],
    'хочу': ['хочу', 'желаю', 'мечтаю', 'хотелось бы', 'было бы классно'],
    
    // Помощь
    'помощь': ['помоги', 'помощь', 'подскажи', 'посоветуй', 'объясни', 'расскажи'],
    
    // Проценты
    'проценты': ['проценты', 'процент', '%', 'доля', 'часть'],
    
    // Скидка
    'скидка': ['скидка', 'акция', 'распродажа', 'sale', 'сейл', 'дешевле'],
    
    // Подписка
    'подписка': ['подписка', 'ежемесячно', 'каждый месяц', 'регулярный платёж', 'автоплатёж'],
    
    // Банк
    'банк': ['банк', 'банковский', 'счёт', 'вклад', 'депозит'],
    
    // Долг
    'долг': ['долг', 'занять', 'одолжить', 'кредит', 'должен'],
    
    // Инфляция
    'инфляция': ['инфляция', 'подорожание', 'рост цен', 'обесценивание'],
    
    // Бюджет
    'бюджет': ['бюджет', 'план расходов', 'финплан', 'распределение'],
    
    // Инвестиции
    'инвестиции': ['инвестиции', 'вложения', 'инвестировать', 'вложить', 'приумножить'],
  };

  // Вопросительные слова и их вариации
  static const Map<String, List<String>> _questionWords = {
    'как': ['как', 'каким образом', 'каким способом'],
    'что': ['что', 'чё', 'что такое', 'что значит', 'что означает'],
    'почему': ['почему', 'отчего', 'зачем', 'для чего', 'по какой причине'],
    'сколько': ['сколько', 'скоко', 'какой размер', 'какая сумма', 'какое количество'],
    'когда': ['когда', 'в какой момент', 'к какому времени', 'через сколько'],
    'где': ['где', 'куда', 'в каком месте', 'откуда'],
    'можно ли': ['можно ли', 'могу ли', 'получится ли', 'реально ли', 'есть ли возможность'],
  };

  /// Находит все синонимы для слова
  static Set<String> getSynonyms(String word) {
    final normalized = word.toLowerCase().trim();
    final result = <String>{normalized};
    
    for (final group in _synonymGroups.values) {
      if (group.any((s) => normalized.contains(s) || s.contains(normalized))) {
        result.addAll(group);
      }
    }
    
    return result;
  }

  /// Проверяет, содержит ли сообщение любой из синонимов
  static bool containsAny(String message, List<String> keywords) {
    final m = message.toLowerCase();
    
    for (final keyword in keywords) {
      // Прямое совпадение
      if (m.contains(keyword.toLowerCase())) return true;
      
      // Проверяем синонимы
      final synonyms = getSynonyms(keyword);
      if (synonyms.any((s) => m.contains(s))) return true;
    }
    
    return false;
  }

  /// Подсчитывает "вес" совпадения с учётом синонимов
  static int calculateMatchScore(String message, List<String> keywords, List<String> tags) {
    final m = message.toLowerCase();
    int score = 0;
    
    // Ключевые слова весят больше
    for (final keyword in keywords) {
      if (m.contains(keyword.toLowerCase())) {
        score += 3;
      } else {
        // Проверяем синонимы (меньший вес)
        final synonyms = getSynonyms(keyword);
        if (synonyms.any((s) => m.contains(s))) {
          score += 2;
        }
      }
    }
    
    // Теги весят меньше
    for (final tag in tags) {
      if (m.contains(tag.toLowerCase())) {
        score += 1;
      } else {
        final synonyms = getSynonyms(tag);
        if (synonyms.any((s) => m.contains(s))) {
          score += 1;
        }
      }
    }
    
    return score;
  }

  /// Определяет тип вопроса
  static String? detectQuestionType(String message) {
    final m = message.toLowerCase();
    
    for (final entry in _questionWords.entries) {
      if (entry.value.any((q) => m.startsWith(q) || m.contains(' $q '))) {
        return entry.key;
      }
    }
    
    // Проверяем вопросительный знак
    if (m.contains('?')) {
      // Пытаемся определить тип по контексту
      if (m.contains('сколько') || m.contains('скоко')) return 'сколько';
      if (m.contains('можно') || m.contains('могу')) return 'можно ли';
      if (m.contains('как')) return 'как';
      if (m.contains('что')) return 'что';
      if (m.contains('почему') || m.contains('зачем')) return 'почему';
      return 'общий вопрос';
    }
    
    return null;
  }

  /// Нормализует сообщение (убирает лишние пробелы, знаки препинания)
  static String normalize(String message) {
    return message
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\sа-яёА-ЯЁ€$₽%]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Извлекает числа из сообщения
  static List<double> extractNumbers(String message) {
    final matches = RegExp(r'(\d+(?:[.,]\d+)?)').allMatches(message);
    return matches
        .map((m) => double.tryParse(m.group(1)!.replaceAll(',', '.')) ?? 0)
        .where((n) => n > 0)
        .toList();
  }

  /// Определяет, упоминается ли валюта
  static String? detectCurrency(String message) {
    final m = message.toLowerCase();
    
    if (m.contains('€') || m.contains('евро') || m.contains('eur')) return 'EUR';
    if (m.contains('\$') || m.contains('доллар') || m.contains('usd')) return 'USD';
    if (m.contains('₽') || m.contains('рубл') || m.contains('rub')) return 'RUB';
    if (m.contains('chf') || m.contains('франк')) return 'CHF';
    if (m.contains('£') || m.contains('фунт') || m.contains('gbp')) return 'GBP';
    
    return null;
  }

  /// Проверяет, похоже ли сообщение на математический вопрос
  static bool isMathQuestion(String message) {
    final m = message.toLowerCase();
    
    return m.contains('%') ||
           m.contains('процент') ||
           m.contains('умножить') ||
           m.contains('разделить') ||
           m.contains('сложить') ||
           m.contains('вычесть') ||
           m.contains('сколько будет') ||
           RegExp(r'\d+\s*[+\-*/×÷]\s*\d+').hasMatch(m);
  }

  /// Проверяет, похоже ли сообщение на вопрос о покупке
  static bool isPurchaseQuestion(String message) {
    final m = message.toLowerCase();
    
    return containsAny(m, [
      'можно ли купить', 'хватит ли', 'могу ли купить',
      'стоит ли покупать', 'покупать или нет',
      'хочу купить', 'хочу взять', 'присмотрел',
    ]);
  }

  /// Проверяет, похоже ли сообщение на вопрос о накоплениях
  static bool isSavingsQuestion(String message) {
    final m = message.toLowerCase();
    
    return containsAny(m, [
      'как копить', 'как накопить', 'как откладывать',
      'сколько копить', 'когда накоплю', 'мои копилки',
      'помоги накопить', 'научи копить',
    ]);
  }
}
