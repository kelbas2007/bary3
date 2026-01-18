import '../bari_context.dart';
import '../bari_models.dart';
import 'bari_provider.dart';

/// Финансовый коуч — отвечает на типичные вопросы о деньгах.
/// Значительно расширен для умных офлайн-ответов.
class FinanceCoachProvider implements BariProvider {
  @override
  Future<BariResponse?> tryRespond(
    String message,
    BariContext ctx, {
    bool forceOnline = false,
  }) async {
    final m = message.toLowerCase().trim();
    
    // === МОЖНО ЛИ КУПИТЬ ===
    final buyMatch = RegExp(
      r'(можно ли купить|хватит ли|могу ли купить|хватает ли).{0,30}(\d+(?:[.,]\d+)?)',
    ).firstMatch(m);
    
    if (buyMatch != null) {
      final raw = buyMatch.group(2)!.replaceAll(',', '.');
      final price = double.tryParse(raw) ?? 0;
      final priceCents = (price * 100).round();
      final ok = ctx.walletBalanceCents >= priceCents;
      final balanceFormatted = (ctx.walletBalanceCents / 100).toStringAsFixed(2);
      
      if (ok) {
        final remaining = ctx.walletBalanceCents - priceCents;
        final remainingFormatted = (remaining / 100).toStringAsFixed(2);
        return BariResponse(
          meaning: 'Да, в кошельке $balanceFormatted${_symbol(ctx)} — хватит на $price${_symbol(ctx)}!',
          advice: 'После покупки останется $remainingFormatted${_symbol(ctx)}. Это "нужно" или "хочу"? Если "хочу" — подумай 24 часа.',
          actions: const [
            BariAction(type: BariActionType.openCalculator, label: 'Правило 24 часа', payload: '24h_rule'),
            BariAction(type: BariActionType.openScreen, label: 'Баланс', payload: 'balance'),
            BariAction(type: BariActionType.explainSimpler, label: 'Объясни проще'),
          ],
          confidence: 0.92,
        );
      } else {
        final needed = priceCents - ctx.walletBalanceCents;
        final neededFormatted = (needed / 100).toStringAsFixed(2);
        return BariResponse(
          meaning: 'Пока не хватает. В кошельке $balanceFormatted${_symbol(ctx)}, нужно ещё $neededFormatted${_symbol(ctx)}.',
          advice: 'Создай копилку на эту цель и откладывай понемногу. Через сколько хочешь купить?',
          actions: const [
            BariAction(type: BariActionType.openScreen, label: 'Создать копилку', payload: 'piggy_banks'),
            BariAction(type: BariActionType.openCalculator, label: 'Когда достигну цели', payload: 'goal_date'),
            BariAction(type: BariActionType.explainSimpler, label: 'Объясни проще'),
          ],
          confidence: 0.92,
        );
      }
    }
    
    // === СТОИТ ЛИ ПОКУПАТЬ ===
    if (_matchesPattern(m, ['стоит ли покупать', 'стоит ли купить', 'покупать или нет', 'брать или нет'])) {
      return const BariResponse(
        meaning: 'Хороший вопрос! Задай себе 3 вопроса перед покупкой:',
        advice: '1. Это "нужно" или "хочу"? 2. Могу ли подождать неделю? 3. Не мешает ли это моим целям?',
        actions: [
          BariAction(type: BariActionType.openCalculator, label: 'Правило 24 часа', payload: '24h_rule'),
          BariAction(type: BariActionType.openCalculator, label: 'Можно ли купить?', payload: 'can_i_buy'),
          BariAction(type: BariActionType.explainSimpler, label: 'Объясни проще'),
        ],
        confidence: 0.85,
      );
    }
    
    // === КУДА УХОДЯТ ДЕНЬГИ ===
    if (_matchesPattern(m, ['куда уходят деньги', 'куда деваются деньги', 'куда тратятся', 'не понимаю куда'])) {
      return const BariResponse(
        meaning: 'Деньги часто "утекают" на мелочи: сладости, подписки, случайные покупки.',
        advice: 'Попробуй неделю записывать ВСЕ траты. Даже 50 центов на жвачку. Увидишь, куда уходит больше всего!',
        actions: [
          BariAction(type: BariActionType.openScreen, label: 'Баланс', payload: 'balance'),
          BariAction(type: BariActionType.openCalculator, label: 'Калькулятор подписок', payload: 'subscriptions'),
        ],
        confidence: 0.88,
      );
    }
    
    // === КАК ЗАРАБОТАТЬ ===
    if (_matchesPattern(m, ['как заработать', 'где взять деньги', 'как получить деньги', 'как добыть денег'])) {
      return const BariResponse(
        meaning: 'Есть несколько честных способов заработать:',
        advice: '1. Помощь по дому (за награду). 2. Продажа ненужных вещей. 3. Услуги соседям (полив цветов, выгул собак). 4. Творческие проекты (рисунки, поделки).',
        actions: [
          BariAction(type: BariActionType.openScreen, label: 'Календарь', payload: 'calendar'),
          BariAction(type: BariActionType.createPlan, label: 'Создать план'),
        ],
        confidence: 0.85,
      );
    }
    
    // === СКИДКА / РАСПРОДАЖА ===
    if (_matchesPattern(m, ['скидка', 'распродажа', 'акция', 'выгодно ли', 'стоит ли брать со скидкой'])) {
      return const BariResponse(
        meaning: 'Скидка — не всегда выгода!',
        advice: 'Вопрос не "сколько сэкономлю", а "нужна ли эта вещь вообще". Если нет — экономия = 100%, потому что ты ничего не тратишь!',
        actions: [
          BariAction(type: BariActionType.openCalculator, label: 'Сравнение цен', payload: 'price_comparison'),
          BariAction(type: BariActionType.openCalculator, label: 'Правило 24 часа', payload: '24h_rule'),
        ],
        confidence: 0.85,
      );
    }
    
    // === ПОДПИСКИ ===
    if (_matchesPattern(m, ['подписки', 'подписка', 'ежемесячная плата', 'платная подписка'])) {
      return const BariResponse(
        meaning: 'Подписки — тихие "воришки" денег!',
        advice: 'Даже 5€/месяц = 60€/год. Посчитай все подписки и реши: какие реально нужны, а какие — привычка.',
        actions: [
          BariAction(type: BariActionType.openCalculator, label: 'Калькулятор подписок', payload: 'subscriptions'),
        ],
        confidence: 0.88,
      );
    }
    
    // === НАКОПИТЬ НА... ===
    final saveForMatch = RegExp(
      r'(?:как )?(?:накопить|собрать|насобирать)\s+(?:на|денег на)\s+(.+)',
    ).firstMatch(m);
    
    if (saveForMatch != null) {
      final goal = saveForMatch.group(1)!.trim();
      return BariResponse(
        meaning: 'Хочешь накопить на "$goal"? Отличная цель!',
        advice: '1. Узнай точную цену. 2. Создай копилку. 3. Реши, сколько откладывать в неделю. 4. Начни сегодня!',
        actions: const [
          BariAction(type: BariActionType.openScreen, label: 'Создать копилку', payload: 'piggy_banks'),
          BariAction(type: BariActionType.openCalculator, label: 'Когда достигну цели', payload: 'goal_date'),
        ],
        confidence: 0.88,
      );
    }
    
    // === ДОЛГ / ЗАНЯТЬ ===
    if (_matchesPattern(m, ['занять', 'одолжить', 'взять в долг', 'дать в долг', 'друг просит денег'])) {
      return const BariResponse(
        meaning: 'Долг — это обещание вернуть деньги.',
        advice: 'Правило: не давай в долг больше, чем готов потерять. И сам старайся не брать — лучше накопить.',
        actions: [
          BariAction(type: BariActionType.openScreen, label: 'Копилки', payload: 'piggy_banks'),
          BariAction(type: BariActionType.explainSimpler, label: 'Объясни проще'),
        ],
        confidence: 0.82,
      );
    }
    
    // === КАРМАННЫЕ ДЕНЬГИ ===
    if (_matchesPattern(m, ['карманные деньги', 'карманные', 'сколько давать', 'сколько просить'])) {
      return const BariResponse(
        meaning: 'Карманные деньги — первый способ научиться управлять финансами!',
        advice: 'Главное не сумма, а регулярность. Лучше 5€ каждую неделю, чем 50€ раз в два месяца.',
        actions: [
          BariAction(type: BariActionType.openScreen, label: 'Баланс', payload: 'balance'),
          BariAction(type: BariActionType.openCalculator, label: '50/30/20', payload: 'budget_50_30_20'),
        ],
        confidence: 0.85,
      );
    }
    
    // === ДОРОГО / ДЁШЕВО ===
    if (_matchesPattern(m, ['это дорого', 'слишком дорого', 'дёшево', 'нормальная цена', 'адекватная цена'])) {
      return const BariResponse(
        meaning: '"Дорого" — понятие относительное!',
        advice: 'Сравни цену с тем, сколько ты зарабатываешь/получаешь. Если вещь стоит больше недельного дохода — это большая покупка, требующая планирования.',
        actions: [
          BariAction(type: BariActionType.openCalculator, label: 'Сравнение цен', payload: 'price_comparison'),
          BariAction(type: BariActionType.openCalculator, label: 'Можно ли купить?', payload: 'can_i_buy'),
        ],
        confidence: 0.8,
      );
    }
    
    // === ИНВЕСТИЦИИ (для детей) ===
    if (_matchesPattern(m, ['инвестиции', 'инвестировать', 'куда вложить', 'как приумножить'])) {
      return const BariResponse(
        meaning: 'Инвестиции — это когда деньги "работают" и приносят ещё деньги.',
        advice: 'Для начала твоя лучшая "инвестиция" — это знания! Проходи уроки, учись копить. Настоящие инвестиции — когда подрастёшь.',
        actions: [
          BariAction(type: BariActionType.openScreen, label: 'Уроки', payload: 'lessons'),
          BariAction(type: BariActionType.openScreen, label: 'Копилки', payload: 'piggy_banks'),
        ],
        confidence: 0.82,
      );
    }
    
    // === БАНК / СЧЁТ ===
    if (_matchesPattern(m, ['что такое банк', 'зачем банк', 'банковский счёт', 'открыть счёт'])) {
      return const BariResponse(
        meaning: 'Банк — это как большая копилка для всех людей.',
        advice: 'Банк хранит деньги и иногда платит "проценты" за это. Но для начала научись копить в своих копилках!',
        actions: [
          BariAction(type: BariActionType.openScreen, label: 'Копилки', payload: 'piggy_banks'),
          BariAction(type: BariActionType.openScreen, label: 'Уроки', payload: 'lessons'),
        ],
        confidence: 0.8,
      );
    }
    
    // === НАЛОГИ ===
    if (_matchesPattern(m, ['налоги', 'налог', 'зачем налоги', 'куда идут налоги'])) {
      return const BariResponse(
        meaning: 'Налоги — это часть денег, которую люди платят государству.',
        advice: 'На налоги строят школы, больницы, дороги. Это как "взнос" в общую копилку страны.',
        actions: [
          BariAction(type: BariActionType.openScreen, label: 'Уроки', payload: 'lessons'),
          BariAction(type: BariActionType.explainSimpler, label: 'Объясни проще'),
        ],
        confidence: 0.8,
      );
    }
    
    // === КРИПТОВАЛЮТА ===
    if (_matchesPattern(m, ['криптовалюта', 'биткоин', 'крипта', 'bitcoin', 'crypto'])) {
      return const BariResponse(
        meaning: 'Криптовалюта — это цифровые деньги в интернете.',
        advice: 'Это очень рискованно! Цена может упасть в 10 раз за день. Для детей и подростков лучше обычные накопления.',
        actions: [
          BariAction(type: BariActionType.openScreen, label: 'Уроки', payload: 'lessons'),
          BariAction(type: BariActionType.explainSimpler, label: 'Объясни проще'),
        ],
        confidence: 0.8,
      );
    }
    
    // === БЛАГОТВОРИТЕЛЬНОСТЬ ===
    if (_matchesPattern(m, ['благотворительность', 'пожертвование', 'помочь бедным', 'отдать деньги'])) {
      return const BariResponse(
        meaning: 'Благотворительность — это помощь тем, кому трудно.',
        advice: 'Круто, что думаешь об этом! Можно выделить небольшую часть (5-10%) на добрые дела. Но сначала убедись, что твои цели в порядке.',
        actions: [
          BariAction(type: BariActionType.openScreen, label: 'Копилки', payload: 'piggy_banks'),
          BariAction(type: BariActionType.openCalculator, label: '50/30/20', payload: 'budget_50_30_20'),
        ],
        confidence: 0.82,
      );
    }
    
    // === РАБОТА / ЗАРПЛАТА ===
    if (_matchesPattern(m, ['зарплата', 'сколько платят', 'какая зарплата', 'сколько зарабатывают'])) {
      return const BariResponse(
        meaning: 'Зарплата зависит от профессии, опыта и страны.',
        advice: 'Главное — не только сколько зарабатываешь, но и как управляешь деньгами. Можно много получать и всё тратить!',
        actions: [
          BariAction(type: BariActionType.openScreen, label: 'Уроки', payload: 'lessons'),
          BariAction(type: BariActionType.openCalculator, label: '50/30/20', payload: 'budget_50_30_20'),
        ],
        confidence: 0.75,
      );
    }
    
    // === РОДИТЕЛИ НЕ ДАЮТ ДЕНЕГ ===
    if (_matchesPattern(m, ['родители не дают', 'мало дают', 'не хватает денег', 'хочу больше денег'])) {
      return const BariResponse(
        meaning: 'Понимаю, это бывает обидно.',
        advice: 'Попробуй: 1. Поговорить спокойно о своих целях. 2. Предложить заработать на домашних делах. 3. Показать, что умеешь копить и планировать.',
        actions: [
          BariAction(type: BariActionType.openScreen, label: 'Копилки', payload: 'piggy_banks'),
          BariAction(type: BariActionType.openScreen, label: 'Календарь', payload: 'calendar'),
        ],
        confidence: 0.8,
      );
    }
    
    // === ХОЧУ ВСЁ И СРАЗУ ===
    if (_matchesPattern(m, ['хочу всё', 'хочу много', 'хочу сразу', 'почему нельзя всё'])) {
      return const BariResponse(
        meaning: 'Это нормальное желание! Но ресурсы всегда ограничены.',
        advice: 'Секрет: выбирай ОДНУ главную цель и иди к ней. Потом — следующую. Так ты получишь больше, чем если распыляться на всё.',
        actions: [
          BariAction(type: BariActionType.openScreen, label: 'Копилки', payload: 'piggy_banks'),
          BariAction(type: BariActionType.explainSimpler, label: 'Объясни проще'),
        ],
        confidence: 0.85,
      );
    }
    
    // === ЗАВИДУЮ ДРУГИМ ===
    if (_matchesPattern(m, ['завидую', 'у других больше', 'у друга есть', 'хочу как у'])) {
      return const BariResponse(
        meaning: 'Сравнение с другими — ловушка для настроения.',
        advice: 'У каждого свой путь. Сосредоточься на СВОИХ целях и прогрессе. Ты молодец, что учишься управлять деньгами!',
        actions: [
          BariAction(type: BariActionType.openScreen, label: 'Копилки', payload: 'piggy_banks'),
          BariAction(type: BariActionType.openScreen, label: 'Уроки', payload: 'lessons'),
        ],
        confidence: 0.82,
      );
    }
    
    // === СТРАХ ПОТЕРЯТЬ ДЕНЬГИ ===
    if (_matchesPattern(m, ['боюсь тратить', 'жалко денег', 'страшно потерять', 'не хочу тратить'])) {
      return const BariResponse(
        meaning: 'Экономность — это хорошо, но крайности вредят.',
        advice: 'Деньги — инструмент. Их задача — помогать жить лучше. Трать на "нужно" спокойно, копи на "хочу" с радостью!',
        actions: [
          BariAction(type: BariActionType.openCalculator, label: '50/30/20', payload: 'budget_50_30_20'),
          BariAction(type: BariActionType.openScreen, label: 'Копилки', payload: 'piggy_banks'),
        ],
        confidence: 0.8,
      );
    }
    
    return null;
  }
  
  bool _matchesPattern(String message, List<String> patterns) {
    return patterns.any((p) => message.contains(p));
  }
  
  String _symbol(BariContext ctx) {
    switch (ctx.currencyCode.toUpperCase()) {
      case 'EUR': return '€';
      case 'USD': return '\$';
      case 'RUB': return '₽';
      case 'CHF': return 'CHF';
      case 'GBP': return '£';
      default: return ctx.currencyCode;
    }
  }
}
