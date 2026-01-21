// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get common_cancel => 'Отмена';

  @override
  String get common_save => 'Сохранить';

  @override
  String get common_create => 'Создать';

  @override
  String get common_delete => 'Удалить';

  @override
  String get common_done => 'Готово';

  @override
  String get common_understand => 'Понятно';

  @override
  String get common_planCreated => 'План успешно создан!';

  @override
  String get common_purchasePlanned => 'Покупка запланирована!';

  @override
  String get common_income => 'Доход';

  @override
  String get common_expense => 'Расход';

  @override
  String get common_plan => 'План';

  @override
  String get common_balance => 'Баланс';

  @override
  String get common_piggyBanks => 'Копилки';

  @override
  String get common_calendar => 'Календарь';

  @override
  String get common_lessons => 'Уроки';

  @override
  String get common_settings => 'Настройки';

  @override
  String get common_tools => 'Инструменты';

  @override
  String get common_continue => 'Продолжить';

  @override
  String get common_confirm => 'Подтвердить';

  @override
  String get common_error => 'Ошибка';

  @override
  String get common_tryAgain => 'Попробовать снова';

  @override
  String get balance => 'Баланс';

  @override
  String get search => 'Поиск';

  @override
  String get reset => 'Сбросить';

  @override
  String get done => 'Готово';

  @override
  String get moneyValidator_enterAmount => 'Напиши сумму';

  @override
  String get moneyValidator_notANumber => 'Не похоже на число';

  @override
  String get moneyValidator_mustBePositive => 'Сумма должна быть больше 0';

  @override
  String get moneyValidator_tooSmall => 'Сумма слишком маленькая';

  @override
  String get bariOverlay_tipOfDay => 'Подсказка дня';

  @override
  String get bariOverlay_defaultTip =>
      'Помни: каждая монета приближает тебя к цели!';

  @override
  String get bariOverlay_instructions =>
      'Нажми на Бари — открыть подсказку. Двойной тап — чат.';

  @override
  String get bariOverlay_openChat => 'Открыть чат';

  @override
  String get bariOverlay_moreTips => 'Ещё подсказку';

  @override
  String get bariAvatar_happy => '😄';

  @override
  String get bariAvatar_encouraging => '🤔';

  @override
  String get bariAvatar_neutral => '😌';

  @override
  String mainScreen_transferToPiggyBank(String bankName) {
    return 'Перевод в копилку \"$bankName\" (из дохода)';
  }

  @override
  String get bariTip_income => 'Отличный доход! Куда потратишь?';

  @override
  String get bariTip_expense => 'Потрачено. Это было в планах?';

  @override
  String get bariTip_planCreated =>
      'План создан! Следовать ему — ключ к успеху.';

  @override
  String get bariTip_planCompleted => 'План выполнен! Ты молодец!';

  @override
  String get bariTip_piggyBankCreated => 'Новая копилка! На что копим?';

  @override
  String get bariTip_piggyBankCompleted =>
      'Копилка заполнена! Поздравляю с достижением цели!';

  @override
  String get bariTip_lessonCompleted =>
      'Урок пройден! Новые знания — суперсила!';

  @override
  String get bariTip_levelUp => 'Новый уровень! Ты растешь как финансист!';

  @override
  String get period_day => 'День';

  @override
  String get period_week => 'Неделя';

  @override
  String get period_month => 'Месяц';

  @override
  String get period_inADay => 'в день';

  @override
  String get period_inAWeek => 'в неделю';

  @override
  String get period_inAMonth => 'в месяц';

  @override
  String get period_everyDay => 'Каждый день';

  @override
  String get period_onceAWeek => 'Раз в неделю';

  @override
  String get period_onceAMonth => 'Раз в месяц';

  @override
  String plural_days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'дней',
      many: 'дней',
      few: 'дня',
      one: 'день',
    );
    return '$_temp0';
  }

  @override
  String get monthlyBudgetCalculator_title => 'План расходов на месяц';

  @override
  String get monthlyBudgetCalculator_subtitle =>
      'Поставь лимит и посмотри остаток — деньги станет легче контролировать.';

  @override
  String get monthlyBudgetCalculator_step1 => 'Месяц';

  @override
  String get monthlyBudgetCalculator_step2 => 'Лимит';

  @override
  String get monthlyBudgetCalculator_step3 => 'Итог';

  @override
  String get monthlyBudgetCalculator_selectMonth => '1) Выбери месяц';

  @override
  String get monthlyBudgetCalculator_setLimit => '2) Поставь лимит';

  @override
  String get monthlyBudgetCalculator_limitForMonth => 'Лимит на месяц';

  @override
  String get monthlyBudgetCalculator_result => 'Итог';

  @override
  String get monthlyBudgetCalculator_spent => 'Потрачено';

  @override
  String get monthlyBudgetCalculator_remaining => 'Осталось';

  @override
  String get monthlyBudgetCalculator_warningAlmostLimit =>
      '⚠️ Почти достигнут лимит! Попробуй снизить траты в оставшиеся дни.';

  @override
  String monthlyBudgetCalculator_warningOverLimit(String amount) {
    return 'Ты вышел за лимит на $amount. Можно пересмотреть лимит или найти, где сэкономить.';
  }

  @override
  String get goalDateCalculator_title => 'Когда я достигну цели';

  @override
  String get goalDateCalculator_subtitle =>
      'Введи сумму взноса и частоту — я покажу примерную дату достижения.';

  @override
  String get goalDateCalculator_stepGoal => 'Цель';

  @override
  String get goalDateCalculator_stepContribution => 'Взнос';

  @override
  String get goalDateCalculator_stepFrequency => 'Частота';

  @override
  String get goalDateCalculator_headerGoal => '1) Цель';

  @override
  String get goalDateCalculator_piggyBankLabel => 'Копилка';

  @override
  String goalDateCalculator_remainingToGoal(String amount) {
    return 'Осталось: $amount';
  }

  @override
  String get goalDateCalculator_headerContribution => '2) Сколько откладываешь';

  @override
  String get goalDateCalculator_contributionAmountLabel => 'Сумма взноса';

  @override
  String get goalDateCalculator_headerFrequency => '3) Частота';

  @override
  String get goalDateCalculator_result => 'Результат';

  @override
  String get goalDateCalculator_goalAlreadyReached =>
      'Цель уже достигнута — можно поставить новую!';

  @override
  String goalDateCalculator_resultSummary(int count, String period) {
    return 'Примерно через $count взносов (каждый $period)';
  }

  @override
  String get goalDateCalculator_upcomingDates => 'Ближайшие даты:';

  @override
  String get goalDateCalculator_createPlanButton => 'Создать план взносов';

  @override
  String get goalDateCalculator_dialogTitle => 'Подтверждение';

  @override
  String get goalDateCalculator_dialogSubtitle =>
      'Создание запланированных событий';

  @override
  String goalDateCalculator_dialogContent(String goalName) {
    return 'Создать запланированные события для взносов в копилку \"$goalName\"?';
  }

  @override
  String get goalDateCalculator_defaultGoalName => 'цель';

  @override
  String goalDateCalculator_dialogContributionAmount(String amount) {
    return 'Сумма взноса: $amount';
  }

  @override
  String goalDateCalculator_dialogFrequency(String period) {
    return 'Периодичность: каждый $period';
  }

  @override
  String goalDateCalculator_eventName(String goalName) {
    return 'Взнос в копилку \"$goalName\"';
  }

  @override
  String get piggyPlanCalculator_title => 'Копилка-план';

  @override
  String get piggyPlanCalculator_subtitle =>
      'Подскажу, сколько и как часто откладывать, чтобы дойти до цели.';

  @override
  String get piggyPlanCalculator_stepGoal => 'Цель';

  @override
  String get piggyPlanCalculator_stepDate => 'Дата';

  @override
  String get piggyPlanCalculator_stepFrequency => 'Частота';

  @override
  String get piggyPlanCalculator_headerSelectGoal => '1) Выбери цель';

  @override
  String get piggyPlanCalculator_goalAmountLabel => 'Цель (сумма)';

  @override
  String get piggyPlanCalculator_currentAmountLabel => 'Уже есть';

  @override
  String get piggyPlanCalculator_headerTargetDate =>
      '2) Когда хочешь дойти до цели?';

  @override
  String get piggyPlanCalculator_selectDate => 'Выбери дату';

  @override
  String get piggyPlanCalculator_headerFrequency => '3) Как часто откладывать?';

  @override
  String get piggyPlanCalculator_result => 'Результат';

  @override
  String piggyPlanCalculator_resultSummary(
    String amount,
    String period,
    int count,
  ) {
    return 'Откладывай примерно $amount каждый $period (всего взносов: $count).';
  }

  @override
  String piggyPlanCalculator_planCreatedSnackbar(String amount, String period) {
    return 'План создан: $amount каждый $period';
  }

  @override
  String get piggyPlanCalculator_scheduleFirstContributionButton =>
      'Запланировать первый взнос';

  @override
  String piggyPlanCalculator_dialogContributionAmount(String amount) {
    return 'Сумма: $amount';
  }

  @override
  String get canIBuyCalculator_title => 'Можно ли купить?';

  @override
  String get canIBuyCalculator_subtitle =>
      'Проверим покупку прямо сейчас и с учётом планов на неделю.';

  @override
  String get canIBuyCalculator_stepPrice => 'Цена';

  @override
  String get canIBuyCalculator_stepMoney => 'Деньги';

  @override
  String get canIBuyCalculator_stepRules => 'Правила';

  @override
  String get canIBuyCalculator_headerPrice => '1) Цена покупки';

  @override
  String get canIBuyCalculator_priceLabel => 'Цена';

  @override
  String get canIBuyCalculator_headerAvailableMoney =>
      '2) Сколько денег доступно';

  @override
  String get canIBuyCalculator_walletBalanceLabel => 'В кошельке сейчас';

  @override
  String get canIBuyCalculator_headerRules => '3) Правила';

  @override
  String get canIBuyCalculator_ruleDontTouchPiggies => 'Не трогать копилки';

  @override
  String get canIBuyCalculator_ruleDontTouchPiggiesSubtitleEnabled =>
      'Считаем только кошелёк';

  @override
  String get canIBuyCalculator_ruleDontTouchPiggiesSubtitleDisabled =>
      'Можно использовать деньги из копилок как резерв';

  @override
  String get canIBuyCalculator_ruleConsiderPlans => 'Учитывать планы на 7 дней';

  @override
  String get canIBuyCalculator_ruleConsiderPlansSubtitle =>
      'Запланированные доходы/расходы из календаря';

  @override
  String get canIBuyCalculator_result => 'Результат';

  @override
  String get canIBuyCalculator_statusYes => 'Можно сейчас';

  @override
  String get canIBuyCalculator_statusYesBut =>
      'Можно сейчас, но планы на неделю могут помешать';

  @override
  String get canIBuyCalculator_statusMaybeWithPiggies =>
      'Можно, если взять часть из копилки';

  @override
  String get canIBuyCalculator_statusMaybeWithPlans =>
      'Пока не хватает, но планы/доходы на неделе могут помочь';

  @override
  String canIBuyCalculator_statusNo(String amount) {
    return 'Лучше подождать: не хватает $amount';
  }

  @override
  String get canIBuyCalculator_planPurchaseButton => 'Запланировать покупку';

  @override
  String get canIBuyCalculator_dialogTitle => 'Подтверждение';

  @override
  String get canIBuyCalculator_dialogSubtitle =>
      'Создание запланированного события';

  @override
  String get canIBuyCalculator_dialogContent =>
      'Создать запланированное событие для покупки?';

  @override
  String canIBuyCalculator_dialogAmount(String amount) {
    return 'Сумма: $amount';
  }

  @override
  String get canIBuyCalculator_dialogInfo =>
      'Событие будет создано на 7 дней вперед.';

  @override
  String get canIBuyCalculator_defaultEventName => 'Покупка';

  @override
  String get toolsHub_subtitle => 'Считай, планируй, прокачивайся';

  @override
  String get toolsHub_bariTipTitle => 'Совет Бари';

  @override
  String get toolsHub_tipCalculators =>
      'Калькуляторы помогут тебе планировать и считать. Попробуй начать с \"Копилка-план\"!';

  @override
  String get toolsHub_tipEarningsLab =>
      'В Лаборатории заработка ты можешь выполнять задания и зарабатывать. Начни с простых!';

  @override
  String get toolsHub_tipMiniTrainers =>
      '60-секундные тренажёры помогут быстро прокачать навыки. Регулярность важнее скорости!';

  @override
  String get toolsHub_tipBariRecommendations =>
      'Совет дня от Бари обновляется каждый день. Заходи почаще за новыми идеями!';

  @override
  String get toolsHub_calendarForecastTitle => 'Календарный прогноз';

  @override
  String get toolsHub_calendarForecastSubtitle =>
      'Будущий баланс и все запланированные события';

  @override
  String get toolsHub_calculatorsTitle => 'Калькуляторы';

  @override
  String get toolsHub_calculatorsSubtitle =>
      '8 полезных калькуляторов для финансов';

  @override
  String get toolsHub_earningsLabTitle => 'Лаборатория заработка';

  @override
  String get toolsHub_earningsLabSubtitle => 'Задания и миссии для заработка';

  @override
  String get toolsHub_miniTrainersTitle => '60 секунд';

  @override
  String get toolsHub_miniTrainersSubtitle => 'Микро-упражнения для тренировки';

  @override
  String get toolsHub_recommendationsTitle => 'Совет дня';

  @override
  String get toolsHub_recommendationsSubtitle =>
      'Подборка советов и объяснений от Бари';

  @override
  String get toolsHub_notesTitle => 'Заметки';

  @override
  String get toolsHub_notesSubtitle => 'Создавай и организуй свои заметки';

  @override
  String get toolsHub_tipNotes =>
      'Заметки помогут тебе не забыть важные мысли. Закрепляй самые важные!';

  @override
  String get piggyBanks_explanationSimple =>
      'Копилка — это отдельная цель. Деньги в ней не влияют на баланс.';

  @override
  String get piggyBanks_explanationPro =>
      'Копилка — это отдельная цель для накоплений. Деньги, которые ты кладёшь в копилку, не влияют на твой основной баланс. Это помогает видеть прогресс к конкретной цели.';

  @override
  String get piggyBanks_deleteConfirmTitle => 'Удалить копилку?';

  @override
  String piggyBanks_deleteConfirmMessage(String name) {
    return 'Вы уверены, что хотите удалить копилку \"$name\"? Все связанные с ней операции останутся в истории, но сама копилка будет удалена.';
  }

  @override
  String piggyBanks_deleteSuccess(String name) {
    return 'Копилка \"$name\" удалена';
  }

  @override
  String piggyBanks_deleteError(String error) {
    return 'Ошибка при удалении: $error';
  }

  @override
  String get piggyBanks_emptyStateTitle => 'Нет копилок';

  @override
  String get piggyBanks_createNewTooltip => 'Создать новую копилку';

  @override
  String get piggyBanks_createNewButton => 'Создать копилку';

  @override
  String get piggyBanks_addNewButton => 'Добавить новую копилку';

  @override
  String get piggyBanks_fabTooltip => 'Создать копилку';

  @override
  String get piggyBanks_card_statusEmojiCompleted => '🎉';

  @override
  String get piggyBanks_card_statusEmojiAlmost => '🔥';

  @override
  String get piggyBanks_card_statusEmojiHalfway => '💪';

  @override
  String get piggyBanks_card_statusEmojiQuarter => '🌱';

  @override
  String get piggyBanks_card_statusEmojiStarted => '🎯';

  @override
  String get piggyBanks_card_deleteTooltip => 'Удалить';

  @override
  String get piggyBanks_card_goalReached => '✓ Цель достигнута!';

  @override
  String piggyBanks_card_estimatedDate(String date) {
    return 'Достигнете к $date';
  }

  @override
  String get piggyBanks_progress_goalReached => 'Цель достигнута! 🎉';

  @override
  String piggyBanks_progress_almostThere(String amount) {
    return 'Почти у цели! Ещё $amount';
  }

  @override
  String get piggyBanks_progress_halfway => 'Больше половины! 💪';

  @override
  String piggyBanks_progress_quarter(String amount) {
    return 'Четверть пути. Ещё $amount';
  }

  @override
  String get piggyBanks_progress_started => 'Начало положено 🌱';

  @override
  String piggyBanks_progress_initialGoal(String amount) {
    return 'Цель — $amount';
  }

  @override
  String get piggyBanks_createSheet_title => 'Новая копилка';

  @override
  String get piggyBanks_createSheet_nameLabel => 'Название копилки';

  @override
  String get piggyBanks_createSheet_nameHint => 'Например: Новый телефон';

  @override
  String get piggyBanks_createSheet_targetLabel => 'Целевая сумма';

  @override
  String get piggyBanks_detail_deleteTooltip => 'Удалить копилку';

  @override
  String piggyBanks_detail_fromAmount(String amount) {
    return 'из $amount';
  }

  @override
  String get piggyBanks_detail_topUpButton => 'Пополнить';

  @override
  String get piggyBanks_detail_withdrawButton => 'Снять';

  @override
  String get piggyBanks_detail_autofillTitle => 'Автопополнение';

  @override
  String get piggyBanks_detail_autofillRuleLabel => 'Правило';

  @override
  String get piggyBanks_detail_autofillTypePercent => 'Процент';

  @override
  String get piggyBanks_detail_autofillTypeFixed => 'Фиксированная';

  @override
  String get piggyBanks_detail_autofillPercentLabel => 'Процент от дохода';

  @override
  String get piggyBanks_detail_autofillFixedLabel => 'Фиксированная сумма';

  @override
  String get piggyBanks_detail_autofillEnabledSnackbar =>
      'Автокопилка — это как невидимая привычка.';

  @override
  String get piggyBanks_detail_whenToReachGoalTitle => 'Когда достигну цель?';

  @override
  String get piggyBanks_detail_calculateButton => 'Рассчитать';

  @override
  String get piggyBanks_detail_goalExceededTitle => 'Цель будет превышена!';

  @override
  String piggyBanks_detail_goalExceededMessage(
    String name,
    String amount,
    String newAmount,
    String targetAmount,
  ) {
    return 'При пополнении копилки \"$name\" на $amount, новая сумма составит $newAmount, что превышает цель в $targetAmount. Продолжить?';
  }

  @override
  String piggyBanks_detail_topUpTransactionNote(String name) {
    return 'Пополнение копилки \"$name\"';
  }

  @override
  String get piggyBanks_detail_successAnimationGoalReached =>
      '🎉 Цель достигнута!';

  @override
  String piggyBanks_detail_successAnimationDaysCloser(
    String amount,
    int count,
    String days,
  ) {
    return '+$amount • Цель ближе на $count $days 🚀';
  }

  @override
  String piggyBanks_detail_successAnimationSimpleTopUp(String amount) {
    return 'Копилка пополнена на $amount';
  }

  @override
  String get piggyBanks_detail_noFundsError =>
      'В копилке нет средств для снятия.';

  @override
  String get piggyBanks_detail_noOtherPiggiesError =>
      'Нет других копилок для перевода.';

  @override
  String get piggyBanks_detail_insufficientFundsError =>
      'Недостаточно средств в копилке.';

  @override
  String piggyBanks_detail_withdrawToWalletNote(String name) {
    return 'Снятие из копилки \"$name\" → кошелёк';
  }

  @override
  String piggyBanks_detail_withdrawToWalletSnackbar(String amount) {
    return '$amount переведено в кошелёк';
  }

  @override
  String piggyBanks_detail_spendFromPiggyNote(String name) {
    return 'Покупка из копилки \"$name\"';
  }

  @override
  String piggyBanks_detail_spendFromPiggySnackbar(String amount) {
    return 'Потрачено $amount из копилки';
  }

  @override
  String piggyBanks_detail_transferNote(String fromBank, String toBank) {
    return 'Перевод между копилками: \"$fromBank\" → \"$toBank\"';
  }

  @override
  String piggyBanks_detail_transferSnackbar(String amount, String toBank) {
    return '$amount переведено в \"$toBank\"';
  }

  @override
  String get piggyBanks_operationSheet_addTitle => 'Пополнить копилку';

  @override
  String get piggyBanks_operationSheet_transferTitle =>
      'Перевести в другую копилку';

  @override
  String get piggyBanks_operationSheet_spendTitle => 'Потратить из копилки';

  @override
  String get piggyBanks_operationSheet_withdrawTitle => 'Снять в кошелёк';

  @override
  String get piggyBanks_operationSheet_amountLabel => 'Сумма';

  @override
  String piggyBanks_operationSheet_maxAmountHint(String amount) {
    return 'Максимум: $amount';
  }

  @override
  String get piggyBanks_operationSheet_enterAmountHint => 'Введите сумму';

  @override
  String get piggyBanks_operationSheet_categoryLabel => 'Категория';

  @override
  String get piggyBanks_operationSheet_categoryHint => 'Выберите категорию';

  @override
  String get piggyBanks_operationSheet_categoryFood => 'Еда';

  @override
  String get piggyBanks_operationSheet_categoryTransport => 'Транспорт';

  @override
  String get piggyBanks_operationSheet_categoryEntertainment => 'Развлечения';

  @override
  String get piggyBanks_operationSheet_categoryOther => 'Другое';

  @override
  String get piggyBanks_operationSheet_noteLabel =>
      'Название покупки (необязательно)';

  @override
  String get piggyBanks_operationSheet_noteHint => 'Введите название...';

  @override
  String get piggyBanks_operationSheet_errorTooMuch =>
      'Сумма превышает доступные средства';

  @override
  String get piggyBanks_operationSheet_errorInvalid =>
      'Введите корректную сумму';

  @override
  String get piggyBanks_withdrawMode_title => 'Что сделать с деньгами?';

  @override
  String get piggyBanks_withdrawMode_toWalletTitle => 'В кошелёк';

  @override
  String get piggyBanks_withdrawMode_toWalletSubtitle => 'Кошелёк +, Копилка −';

  @override
  String get piggyBanks_withdrawMode_spendTitle => 'Потратить сразу из копилки';

  @override
  String get piggyBanks_withdrawMode_spendSubtitle =>
      'Кошелёк не меняется, Копилка −';

  @override
  String get piggyBanks_withdrawMode_transferTitle =>
      'Перевести в другую копилку';

  @override
  String get piggyBanks_withdrawMode_transferSubtitle =>
      'Кошелёк не меняется, Копилка A −, Копилка B +';

  @override
  String get piggyBanks_picker_title => 'Выбери копилку для перевода';

  @override
  String get piggyBanks_picker_defaultTitle => 'Выбери копилку';

  @override
  String get balance_currentBalance => 'Текущий баланс';

  @override
  String get balance_forecast => 'Прогноз';

  @override
  String get balance_fact => 'Факт';

  @override
  String get balance_withPlannedExpenses => 'С учётом запланированных трат';

  @override
  String get balance_forecastForDay => 'Прогноз на день';

  @override
  String get balance_forecastForWeek => 'Прогноз на неделю';

  @override
  String get balance_forecastForMonth => 'Прогноз на месяц';

  @override
  String get balance_forecastFor3Months => 'Прогноз на 3 месяца';

  @override
  String balance_level(int level) {
    return 'Уровень $level';
  }

  @override
  String get balance_toolsDescription =>
      'Калькуляторы и инструменты для финансового планирования';

  @override
  String get balance_tools => 'Инструменты';

  @override
  String get balance_filterDay => 'День';

  @override
  String get balance_filterWeek => 'Неделя';

  @override
  String get balance_filterMonth => 'Месяц';

  @override
  String get balance_emptyStateIncome => 'Пока пусто. Добавьте доход!';

  @override
  String get balance_emptyStateNoTransactions =>
      'Нет транзакций за выбранный период';

  @override
  String get balance_addIncome => 'Добавить доход';

  @override
  String get balance_addExpense => 'Добавить расход';

  @override
  String get balance_amount => 'Сумма';

  @override
  String get balance_category => 'Категория';

  @override
  String get balance_selectCategory => 'Выберите категорию';

  @override
  String get balance_toPiggyBank => 'В копилку (необязательно)';

  @override
  String get balance_fromPiggyBank => 'Из копилки (необязательно)';

  @override
  String get balance_note => 'Заметка';

  @override
  String get balance_noteHint => 'Введите заметку...';

  @override
  String get balance_save => 'Сохранить';

  @override
  String get balance_categories_food => 'Еда';

  @override
  String get balance_categories_transport => 'Транспорт';

  @override
  String get balance_categories_games => 'Игры';

  @override
  String get balance_categories_clothing => 'Одежда';

  @override
  String get balance_categories_entertainment => 'Развлечения';

  @override
  String get balance_categories_other => 'Другое';

  @override
  String get balance_categories_pocketMoney => 'Карманные';

  @override
  String get balance_categories_gift => 'Подарок';

  @override
  String get balance_categories_sideJob => 'Подработка';

  @override
  String get settings_language => 'Язык';

  @override
  String get settings_selectCurrency => 'Выбери валюту';

  @override
  String get settings_appearance => 'Внешний вид';

  @override
  String get settings_theme => 'Тема';

  @override
  String get settings_themeBlue => 'Синяя';

  @override
  String get settings_themePurple => 'Фиолетовая';

  @override
  String get settings_themeGreen => 'Зелёная';

  @override
  String get settings_explanationMode => 'Режим объяснений';

  @override
  String get settings_howToExplain => 'Как объяснять';

  @override
  String get settings_uxSimple => 'Simple';

  @override
  String get settings_uxPro => 'Pro';

  @override
  String get settings_uxSimpleDescription => 'Простые объяснения';

  @override
  String get settings_uxProDescription => 'Подробные объяснения';

  @override
  String get settings_currency => 'Валюта';

  @override
  String get settings_notifications => 'Уведомления';

  @override
  String get settings_dailyExpenseReminder => 'Напоминания о записи расходов';

  @override
  String get settings_dailyExpenseReminderDescription =>
      'Ежедневные напоминания вечером о записи расходов';

  @override
  String get settings_weeklyReview => 'Еженедельные обзоры';

  @override
  String get settings_weeklyReviewDescription =>
      'Напоминания о подведении итогов недели';

  @override
  String get settings_levelUpNotifications => 'Уведомления о повышении уровня';

  @override
  String get settings_levelUpNotificationsDescription =>
      'Уведомления при достижении нового уровня';

  @override
  String get achievements_title => 'Достижения';

  @override
  String get achievements_empty => 'Нет достижений';

  @override
  String achievements_unlockedCount(int count) {
    return 'Разблокировано достижений: $count';
  }

  @override
  String achievements_unlockedAt(String date) {
    return 'Разблокировано: $date';
  }

  @override
  String get notifications_dailyReminderTitle => 'Бари напоминает';

  @override
  String get notifications_dailyReminderBody =>
      'Не забудь записать сегодняшние расходы! 💰';

  @override
  String get notifications_weeklyReviewTitle => 'Бари напоминает';

  @override
  String get notifications_weeklyReviewBody =>
      'Пора подвести итоги недели! Посмотри, сколько ты сэкономил 📊';

  @override
  String get notifications_levelUpTitle => '🎉 Новый уровень!';

  @override
  String notifications_levelUpBody(int level) {
    return 'Поздравляю! Ты достиг уровня $level';
  }

  @override
  String get notifications_channelName => 'Напоминания Бари';

  @override
  String get notifications_channelDescription =>
      'Персональные напоминания от Бари';

  @override
  String get notifications_levelUpChannelName => 'Повышение уровня';

  @override
  String get notifications_levelUpChannelDescription =>
      'Уведомления о повышении уровня';

  @override
  String get charts_expensesByCategory => 'Расходы по категориям';

  @override
  String get charts_incomeByCategory => 'Доходы по категориям';

  @override
  String get settings_bari => 'Bari Smart';

  @override
  String get settings_bariMode => 'Режим Bari';

  @override
  String get settings_bariModeOffline => 'Офлайн';

  @override
  String get settings_bariModeOnline => 'Онлайн';

  @override
  String get settings_bariModeHybrid => 'Гибридный';

  @override
  String get settings_showSources => 'Показывать источники';

  @override
  String get settings_showSourcesDescription => 'Показывать источники советов';

  @override
  String get settings_smallTalk => 'Небольшие разговоры';

  @override
  String get settings_smallTalkDescription =>
      'Разрешить небольшие разговоры с Bari';

  @override
  String get settings_parentZone => 'Родительская зона';

  @override
  String get settings_parentZoneDescription =>
      'Управление одобрениями и настройками';

  @override
  String get settings_tools => 'Инструменты';

  @override
  String get settings_toolsDescription => 'Калькуляторы и другие инструменты';

  @override
  String get settings_exportData => 'Экспорт данных';

  @override
  String get settings_importData => 'Импорт данных';

  @override
  String get settings_resetProgress => 'Сбросить прогресс';

  @override
  String get settings_resetProgressWarning =>
      'Вы уверены, что хотите сбросить весь прогресс? Это действие нельзя отменить.';

  @override
  String get settings_cancel => 'Отмена';

  @override
  String get settings_progressReset => 'Прогресс сброшен';

  @override
  String get settings_enterPinToConfirm => 'Введите PIN для подтверждения';

  @override
  String get settings_wrongPin => 'Неверный PIN';

  @override
  String get priceComparisonCalculator_factSaved => 'Факт сохранён';

  @override
  String get twentyFourHourRuleCalculator_enterItemName =>
      'Введите название предмета';

  @override
  String get twentyFourHourRuleCalculator_reminderSet =>
      'Напоминание установлено';

  @override
  String get twentyFourHourRuleCalculator_no => 'Нет';

  @override
  String get subscriptionsCalculator_no => 'Нет';

  @override
  String get subscriptionsCalculator_repeatDaily => 'Ежедневно';

  @override
  String get subscriptionsCalculator_repeatWeekly => 'Еженедельно';

  @override
  String get subscriptionsCalculator_repeatMonthly => 'Ежемесячно';

  @override
  String get subscriptionsCalculator_repeatYearly => 'Ежегодно';

  @override
  String get subscriptionsCalculator_enterSubscriptionName =>
      'Введите название подписки';

  @override
  String get calendar_completed => 'Выполнено';

  @override
  String get calendar_edit => 'Редактировать';

  @override
  String get calendar_reschedule => 'Перенести';

  @override
  String get calendar_completeNow => 'Выполнить сейчас';

  @override
  String get calendar_showTransaction => 'Показать транзакцию';

  @override
  String get calendar_restore => 'Восстановить';

  @override
  String get calendar_eventAlreadyCompleted => 'Событие уже выполнено';

  @override
  String get calendar_noPiggyBanks => 'Нет копилок';

  @override
  String get calendar_eventAlreadyCompletedWithTx =>
      'Событие уже выполнено. Транзакция создана.';

  @override
  String get calendar_sentToParentForApproval =>
      'Отправлено родителю на одобрение';

  @override
  String get calendar_addedToPiggyBank => 'добавлено в копилку';

  @override
  String calendar_eventCompletedWithAmount(String amount) {
    return 'Событие выполнено: $amount';
  }

  @override
  String get calendar_planContinues => 'План продолжается';

  @override
  String get calendar_cancelEvent => 'Отменить событие';

  @override
  String get calendar_cancelEventMessage =>
      'Вы уверены, что хотите отменить это событие?';

  @override
  String get calendar_no => 'Нет';

  @override
  String get calendar_yesCancel => 'Да, отменить';

  @override
  String get calendar_wantToReschedule => 'Хотите перенести событие?';

  @override
  String get calendar_eventRestored => 'Событие восстановлено';

  @override
  String get calendar_eventUpdated => 'Событие обновлено';

  @override
  String get calendar_deleteEventConfirm => 'Удалить событие?';

  @override
  String get calendar_deleteEventSeriesMessage => 'Удалить всю серию событий?';

  @override
  String get calendar_deleteAllRepeatingConfirm =>
      'Все повторяющиеся события будут удалены. Это действие нельзя отменить.';

  @override
  String get calendar_undo => 'Отменить';

  @override
  String get calendar_editScopeTitle => 'Что редактировать?';

  @override
  String get calendar_editScopeSubtitle =>
      'Выберите область применения изменений';

  @override
  String get calendar_editThisEventOnly => 'Только это событие';

  @override
  String get calendar_editThisEventOnlyDesc =>
      'Изменения коснутся только выбранного события';

  @override
  String get calendar_editAllRepeating => 'Все повторения';

  @override
  String get calendar_editAllRepeatingDesc =>
      'Изменения применятся ко всем событиям в серии';

  @override
  String get calendar_deleteScopeTitle => 'Что удалить?';

  @override
  String get calendar_deleteScopeSubtitle => 'Выберите область удаления';

  @override
  String get calendar_deleteAllRepeatingDesc =>
      'Удалены будут все события в серии';

  @override
  String get calendar_cancel => 'Отмена';

  @override
  String get calendar_transactionNotFound => 'Транзакция не найдена';

  @override
  String get calendar_transaction => 'Транзакция';

  @override
  String get calendar_transactionAmount => 'Сумма';

  @override
  String get calendar_transactionDate => 'Дата';

  @override
  String get calendar_transactionCategory => 'Категория';

  @override
  String get calendar_transactionNote => 'Заметка';

  @override
  String get deletedEvents_title => 'Удаленные события';

  @override
  String get deletedEvents_empty => 'Корзина пуста';

  @override
  String deletedEvents_count(int count) {
    return '$count событий';
  }

  @override
  String get deletedEvents_restore => 'Восстановить';

  @override
  String get deletedEvents_deletePermanent => 'Удалить навсегда';

  @override
  String get deletedEvents_deletedAt => 'Удалено:';

  @override
  String get deletedEvents_restored => 'Событие восстановлено';

  @override
  String get deletedEvents_deleted => 'Событие удалено навсегда';

  @override
  String get deletedEvents_permanentDeleteTitle => 'Удалить навсегда?';

  @override
  String get deletedEvents_permanentDeleteMessage =>
      'Это действие нельзя отменить. Событие будет удалено без возможности восстановления.';

  @override
  String get deletedEvents_clearOld => 'Очистить старые';

  @override
  String get deletedEvents_clearOldTitle => 'Очистить старые события?';

  @override
  String get deletedEvents_clearOldMessage =>
      'Удалить события, которые находятся в корзине более 30 дней?';

  @override
  String deletedEvents_clearedCount(int count) {
    return 'Удалено $count событий';
  }

  @override
  String get deletedEvents_restoreScopeTitle => 'Что восстановить?';

  @override
  String get deletedEvents_restoreScopeMessage =>
      'Выберите область восстановления';

  @override
  String get subscriptions_filter => 'Фильтр';

  @override
  String get subscriptions_all => 'Все';

  @override
  String get subscriptions_income => 'Доходы';

  @override
  String get subscriptions_expense => 'Расходы';

  @override
  String get subscriptions_type => 'Тип';

  @override
  String get bariChat_title => 'Чат с Бари';

  @override
  String get bariChat_welcomeDefault =>
      'Привет! Я Бари, твой помощник в финансовой грамотности. Чем могу помочь?';

  @override
  String get bariChat_welcomeCalculator =>
      'Привет! Ты используешь калькулятор. Нужна помощь с расчётами?';

  @override
  String get bariChat_welcomePiggyBank =>
      'Привет! Говорим про копилку? Расскажи, что хочешь узнать!';

  @override
  String get bariChat_welcomePlannedEvent =>
      'Привет! У тебя запланированное событие. Вопросы по планированию?';

  @override
  String get bariChat_welcomeLesson =>
      'Привет! Ты проходишь урок. Что-то непонятно? Спрашивай!';

  @override
  String bariChat_welcomeTask(String title) {
    return 'Привет! Поговорим про задание \"$title\"? Могу помочь разобраться с наградой, временем или сложностью.';
  }

  @override
  String get bariChat_fallbackResponse =>
      'Извини, не понял. Попробуй переформулировать вопрос.';

  @override
  String get bariChat_source => 'Источник';

  @override
  String get bariChat_close => 'Закрыть';

  @override
  String get bariChat_inputHint => 'Напиши сообщение...';

  @override
  String get bariChat_thinking => 'Думаю...';

  @override
  String get bariChat_task => 'задание';

  @override
  String get calculatorsList_title => 'Калькуляторы';

  @override
  String get calculatorsList_piggyPlan => 'Копилка-план';

  @override
  String get calculatorsList_piggyPlanDesc => 'Сколько откладывать для цели';

  @override
  String get calculatorsList_goalDate => 'Когда достигну цель';

  @override
  String get calculatorsList_goalDateDesc =>
      'Дата достижения по регулярным взносам';

  @override
  String get calculatorsList_monthlyBudget => 'План расходов на месяц';

  @override
  String get calculatorsList_monthlyBudgetDesc => 'Лимит и остаток на месяц';

  @override
  String get calculatorsList_subscriptions => 'Подписки и регулярки';

  @override
  String get calculatorsList_subscriptionsDesc =>
      'Сколько съедают регулярные траты';

  @override
  String get calculatorsList_canIBuy => 'Хочу купить — можно ли сейчас?';

  @override
  String get calculatorsList_canIBuyDesc => 'Проверка доступности покупки';

  @override
  String get calculatorsList_priceComparison => 'Сравнение цен';

  @override
  String get calculatorsList_priceComparisonDesc => 'Что выгоднее купить';

  @override
  String get calculatorsList_24hRule => 'Правило 24 часов';

  @override
  String get calculatorsList_24hRuleDesc => 'Отложить импульсную покупку';

  @override
  String get calculatorsList_budget503020 => 'Бюджет 50/30/20';

  @override
  String get calculatorsList_budget503020Desc => 'Распределение дохода';

  @override
  String get earningsLab_title => 'Лаборатория заработка';

  @override
  String get earningsLab_explanationSimple =>
      'Запланируй задание → выполни его в календаре → получи награду.';

  @override
  String get earningsLab_explanationPro =>
      'Лаборатория заработка: сначала запланируй задание на дату, затем отметь его выполненным в календаре. Награда будет зачислена автоматически. Планирование помогает не забывать о важных делах.';

  @override
  String get earningsLab_taskAdded => 'Задание добавлено!';

  @override
  String get earningsLab_tabQuick => 'Быстрые';

  @override
  String get earningsLab_tabHome => 'Домашние';

  @override
  String get earningsLab_tabProjects => 'Проекты';

  @override
  String get earningsLab_helpAtHome => 'Помочь по дому';

  @override
  String get earningsLab_helpAtHomeDesc =>
      'Выбери одно дело: посуда / мусор / пыль / пол / стол. Сделай 10–15 минут и доведи до результата.';

  @override
  String get earningsLab_learnPoem => 'Выучить стих';

  @override
  String get earningsLab_learnPoemDesc =>
      'Прочитай 3 раза, выучи по строчкам, потом расскажи без подсказок.';

  @override
  String get earningsLab_cleanRoom => 'Убрать комнату';

  @override
  String get earningsLab_cleanRoomDesc =>
      'Наведи порядок 10–15 минут: игрушки на место, стол чистый, мусор выброшен.';

  @override
  String get earningsLab_readBook => 'Прочитать книгу';

  @override
  String get earningsLab_readBookDesc =>
      'Прочитай главу из интересной книги. Чтение развивает воображение и словарный запас.';

  @override
  String get earningsLab_helpCooking => 'Помочь с готовкой';

  @override
  String get earningsLab_helpCookingDesc =>
      'Помоги родителям приготовить обед или ужин. Научишься готовить простые блюда!';

  @override
  String get earningsLab_homework => 'Выполнить домашнее задание';

  @override
  String get earningsLab_homeworkDesc =>
      'Сделай все домашние задания аккуратно и вовремя. Это твоя главная работа!';

  @override
  String get earningsLab_helpShopping => 'Помочь с покупками';

  @override
  String get earningsLab_helpShoppingDesc =>
      'Сходи с родителями в магазин и помоги нести покупки. Учишься планировать расходы!';

  @override
  String get earningsLab_tagLearning => 'обучение';

  @override
  String get earningsLab_tagHelp => 'помощь';

  @override
  String get earningsLab_tagCreativity => 'творчество';

  @override
  String get rule24h_title => 'Правило 24 часов';

  @override
  String get rule24h_subtitle =>
      'Помогает не делать импульсные покупки: отложи решение на сутки и проверь себя ещё раз.';

  @override
  String get rule24h_step1 => 'Хочу';

  @override
  String get rule24h_step2 => 'Цена';

  @override
  String get rule24h_step3 => 'Пауза';

  @override
  String get rule24h_wantToBuy => 'Хочу купить';

  @override
  String get rule24h_example => 'Например: наушники';

  @override
  String get rule24h_price => 'Цена';

  @override
  String get rule24h_explanation =>
      'Если через 24 часа всё ещё хочешь — покупка более осознанная. Если нет — ты сэкономил и прокачал самоконтроль.';

  @override
  String get rule24h_postpone => 'Отложить на 24 часа';

  @override
  String get rule24h_reminderSet =>
      'Напоминание установлено. Через 24 часа вернись и проверь желание ещё раз.';

  @override
  String get rule24h_checkAgain => 'Проверить снова';

  @override
  String get rule24h_dialogTitle => 'Подтверждение';

  @override
  String get rule24h_dialogSubtitle => 'Создание напоминания';

  @override
  String rule24h_dialogContent(String itemName) {
    return 'Создать напоминание через 24 часа для проверки желания купить \"$itemName\"?';
  }

  @override
  String get rule24h_reminderIn24h => 'Напоминание придет через 24 часа';

  @override
  String rule24h_eventName(String itemName) {
    return 'Проверка желания: $itemName';
  }

  @override
  String get rule24h_checkTitle => 'Проверка желания';

  @override
  String get rule24h_checkSubtitle => 'Прошло 24 часа';

  @override
  String get rule24h_stillWant => 'Хочешь ещё купить это?';

  @override
  String get rule24h_yes => 'Да';

  @override
  String get budget503020_title => 'Бюджет 50/30/20';

  @override
  String get budget503020_subtitle =>
      'Раздели доход на 3 части: нужное, желания и накопления.';

  @override
  String get budget503020_step1 => 'Доход';

  @override
  String get budget503020_step2 => 'Распределение';

  @override
  String get budget503020_step3 => 'Копилки';

  @override
  String get budget503020_incomeLabel => 'Мой доход за месяц';

  @override
  String get budget503020_needs50 => 'Нужное (50%)';

  @override
  String get budget503020_wants30 => 'Желания (30%)';

  @override
  String get budget503020_savings20 => 'Коплю (20%)';

  @override
  String get budget503020_tip =>
      'Совет: если хочешь быстрее копить — попробуй начать с 10% в накопления и постепенно увеличивать.';

  @override
  String get budget503020_createPiggyBanks => 'Создать 3 копилки';

  @override
  String get budget503020_dialogTitle => 'Подтверждение';

  @override
  String get budget503020_dialogSubtitle =>
      'Создание копилок по правилу 50/30/20';

  @override
  String get priceComparison_title => 'Сравнение цен';

  @override
  String get priceComparison_subtitle =>
      'Сравни два варианта и узнай, какой выгоднее по цене за единицу.';

  @override
  String get priceComparison_step1 => 'Вариант A';

  @override
  String get priceComparison_step2 => 'Вариант B';

  @override
  String get priceComparison_step3 => 'Итог';

  @override
  String get priceComparison_priceA => 'Цена A';

  @override
  String get priceComparison_quantityA => 'Количество / вес A';

  @override
  String get priceComparison_priceB => 'Цена B';

  @override
  String get priceComparison_quantityB => 'Количество / вес B';

  @override
  String get priceComparison_result => 'Итог';

  @override
  String get priceComparison_pricePerUnitA => 'Цена за 1 единицу A';

  @override
  String get priceComparison_pricePerUnitB => 'Цена за 1 единицу B';

  @override
  String priceComparison_betterOption(String option, String percent) {
    return 'Выгоднее: вариант $option (экономия ~$percent%)';
  }

  @override
  String get priceComparison_saveForBari => 'Сохранить вывод для Бари';

  @override
  String get subscriptions_title => 'Подписки и регулярки';

  @override
  String get subscriptions_regular => 'Регулярка';

  @override
  String get calendar_today => 'Сегодня';

  @override
  String get calendar_noEvents => 'Нет событий';

  @override
  String calendar_eventsCount(int count, String events) {
    return '$count $events';
  }

  @override
  String get calendar_event => 'событие';

  @override
  String get calendar_events234 => 'события';

  @override
  String get calendar_events5plus => 'событий';

  @override
  String get calendar_freeDay => 'Свободный день';

  @override
  String get calendar_noEventsOnDay =>
      'На этот день ничего не запланировано.\nМожет, самое время что-то добавить?';

  @override
  String get calendar_startPlanning => 'Начни планировать! 🚀';

  @override
  String get calendar_createFirstEvent =>
      'Создай первое событие — так проще копить и не забывать о важном';

  @override
  String get calendar_createFirstPlan => 'Создать первый план';

  @override
  String get calendar_addEvent => 'Добавить событие';

  @override
  String get calendar_income => 'Доходы';

  @override
  String get calendar_expense => 'Расходы';

  @override
  String get calendar_done => 'Выполнено';

  @override
  String get calendar_confirmCompletion => 'Подтвердить выполнение';

  @override
  String get calendar_amount => 'Сумма';

  @override
  String get calendar_confirm => 'Подтвердить';

  @override
  String get calendar_rescheduleEvent => 'Перенести событие';

  @override
  String get calendar_dateAndTime => 'Дата и время';

  @override
  String get calendar_notification => 'Уведомление';

  @override
  String get calendar_move => 'Перенести';

  @override
  String calendar_whereToAdd(String amount) {
    return 'Куда добавить $amount?';
  }

  @override
  String get calendar_toWallet => 'В кошелёк';

  @override
  String get calendar_availableForSpending => 'Доступно для трат';

  @override
  String get calendar_toPiggyBank => 'В копилку';

  @override
  String get calendar_forGoal => 'На цель';

  @override
  String get calendar_selectPiggyBank => 'Выбери копилку';

  @override
  String get calendar_eventCompleted => 'Событие выполнено! +15 XP';

  @override
  String get calendar_eventCancelled => 'Событие отменено';

  @override
  String get calendar_eventDeleted => 'Событие удалено';

  @override
  String get calendar_eventCompletedXp => 'Событие выполнено! +15 XP';

  @override
  String get calendar_invalidAmount => 'Введите корректную сумму';

  @override
  String get calendar_date => 'Дата';

  @override
  String get calendar_time => 'Время';

  @override
  String get calendar_everyDay => 'Каждый день';

  @override
  String get calendar_everyWeek => 'Каждую неделю';

  @override
  String get calendar_everyMonth => 'Каждый месяц';

  @override
  String get calendar_everyYear => 'Каждый год';

  @override
  String get calendar_repeat => 'Повтор';

  @override
  String get calendar_noRepeat => 'Нет';

  @override
  String get calendar_deleteAction => 'Это действие нельзя отменить.';

  @override
  String get calendar_week => 'Неделя';

  @override
  String get calendar_month => 'Месяц';

  @override
  String get parentZone_title => 'Родительская зона';

  @override
  String get parentZone_approvals => 'Ожидают одобрения';

  @override
  String get parentZone_statistics => 'Статистика';

  @override
  String get parentZone_settings => 'Настройки';

  @override
  String get parentZone_pinMustBe4Digits => 'PIN должен содержать 4 цифры';

  @override
  String get parentZone_wrongPin => 'Неверный PIN';

  @override
  String get parentZone_pinChanged => 'PIN изменён';

  @override
  String get parentZone_premiumUnlocked => 'Премиум разблокирован';

  @override
  String get parentZone_resetData => 'Сброс данных';

  @override
  String get parentZone_resetWarning =>
      'ВНИМАНИЕ! Это действие удалит ВСЕ данные приложения.';

  @override
  String get parentZone_enterPinToConfirm => 'Введите PIN для подтверждения:';

  @override
  String get parentZone_pin => 'PIN';

  @override
  String get parentZone_reset => 'Сбросить';

  @override
  String get parentZone_allDataDeleted => 'Все данные удалены';

  @override
  String parentZone_resetError(String error) {
    return 'Ошибка сброса: $error';
  }

  @override
  String get parentZone_login => 'Войти';

  @override
  String get parentZone_unlockPremium => 'Разблокировать премиум';

  @override
  String get parentZone_edit => 'Изменить';

  @override
  String get parentZone_close => 'Закрыть';

  @override
  String get parentZone_aiSummaryTitle => 'AI-саммари для родителей';

  @override
  String get parentZone_modelNotAvailable =>
      'Локальная модель недоступна. Скачайте модель в настройках.';

  @override
  String get parentZone_summaryGenerationFailed =>
      'Не удалось сгенерировать саммари. Попробуйте позже.';

  @override
  String get parentZone_earningsApproved => 'Заработок одобрен';

  @override
  String get parentZone_earningsRejected => 'Заработок отклонён';

  @override
  String get exportImport_title => 'Экспорт/Импорт';

  @override
  String get exportImport_exportData => 'Экспорт данных';

  @override
  String get exportImport_exportDescription =>
      'Сохранить все данные в JSON файл';

  @override
  String get exportImport_export => 'Экспортировать';

  @override
  String get exportImport_importData => 'Импорт данных';

  @override
  String get exportImport_importDescription => 'Загрузить данные из JSON файла';

  @override
  String get exportImport_import => 'Импортировать';

  @override
  String get exportImport_dataCopied => 'Данные скопированы в буфер обмена';

  @override
  String exportImport_exportError(String error) {
    return 'Ошибка экспорта: $error';
  }

  @override
  String get exportImport_importSuccess => 'Данные успешно импортированы';

  @override
  String get exportImport_importError => 'Ошибка импорта';

  @override
  String exportImport_importErrorDetails(String error) {
    return 'Не удалось импортировать данные:\n$error';
  }

  @override
  String get exportImport_pasteJson => 'Вставьте JSON данные';

  @override
  String get minitrainers_result => 'Результат';

  @override
  String minitrainers_correctAnswers(int score, int total, int xp) {
    return 'Правильных ответов: $score/$total\n+$xp XP';
  }

  @override
  String get minitrainers_great => 'Отлично!';

  @override
  String get minitrainers_findExtraPurchase => 'Найди лишнюю покупку';

  @override
  String get minitrainers_answer => 'Ответить';

  @override
  String minitrainers_xpEarned(int xp) {
    return '+$xp XP';
  }

  @override
  String get minitrainers_buildBudget => 'Собери бюджет';

  @override
  String get minitrainers_check => 'Проверить';

  @override
  String get minitrainers_wellDone => 'Молодец!';

  @override
  String get minitrainers_xp15 => '+15 XP';

  @override
  String get minitrainers_discountOrTrap => 'Скидка или ловушка?';

  @override
  String get minitrainers_yes => 'Да';

  @override
  String get minitrainers_no => 'Нет';

  @override
  String get minitrainers_correct => 'Правильно!';

  @override
  String get minitrainers_goodTry => 'Хорошая попытка';

  @override
  String get calculators_3PiggyBanksCreated => '3 копилки созданы';

  @override
  String get rule24h_xp50 => '🎉 +50 XP за самоконтроль!';

  @override
  String get subscriptions_frequency => 'Частота';

  @override
  String get statistics_title => 'Статистика';

  @override
  String get calculators_nDaysSavings => 'Накопления за N дней';

  @override
  String get calculators_weeklySavings => 'Накопления по неделям';

  @override
  String get calculators_piggyGoal => 'Цель копилки';

  @override
  String get earningsLab_schedule => 'Запланировать';

  @override
  String get recommendations_newTip => 'Новый совет';

  @override
  String get earningsHistory_title => 'История заработка';

  @override
  String get earningsHistory_all => 'Всё';

  @override
  String get calendarForecast_7days => '7 дн';

  @override
  String get calendarForecast_30days => '30 дн';

  @override
  String get calendarForecast_90days => '90 дн';

  @override
  String get calendarForecast_year => 'Год';

  @override
  String get calendarForecast_summary => 'Сводка';

  @override
  String get calendarForecast_categories => 'Категории';

  @override
  String get calendarForecast_dates => 'Даты';

  @override
  String get calendarForecast_month => 'Месяц';

  @override
  String get calendarForecast_all => 'Все';

  @override
  String get calendarForecast_income => 'Доходы';

  @override
  String get calendarForecast_expenses => 'Расходы';

  @override
  String get calendarForecast_large => 'Крупные';

  @override
  String get planEvent_amount => 'Сумма';

  @override
  String get planEvent_nameOptional => 'Название (необязательно)';

  @override
  String get planEvent_category => 'Категория';

  @override
  String get planEvent_date => 'Дата';

  @override
  String get planEvent_time => 'Время';

  @override
  String get planEvent_repeat => 'Повтор';

  @override
  String get planEvent_notification => 'Уведомление';

  @override
  String get planEvent_remindBefore => 'Напомнить за';

  @override
  String get planEvent_atMoment => 'В момент';

  @override
  String get planEvent_15minutes => 'За 15 минут';

  @override
  String get planEvent_30minutes => 'За 30 минут';

  @override
  String get planEvent_1hour => 'За 1 час';

  @override
  String get planEvent_1day => 'За 1 день';

  @override
  String get planEvent_eventChanged => 'Событие изменено';

  @override
  String get planEvent_repeatingEventWarning => 'Повторяющееся событие';

  @override
  String get planEvent_repeatingEventDescription =>
      'Это событие является частью повторяющейся серии. Изменения применятся ко всем будущим событиям.';

  @override
  String get calendar_editEvent => 'Изменить событие';

  @override
  String get calendar_planEvent => 'Запланировать событие';

  @override
  String get planEvent_eventType => 'Тип события';

  @override
  String get transaction_income => 'Доход';

  @override
  String get transaction_expense => 'Расход';

  @override
  String get category_food => 'Еда';

  @override
  String get category_transport => 'Транспорт';

  @override
  String get category_entertainment => 'Развлечения';

  @override
  String get category_other => 'Другое';

  @override
  String get minitrainers_60seconds => '60 секунд';

  @override
  String get earningsLab_wrongPin => 'Неверный PIN. Нужно одобрение родителя.';

  @override
  String get earningsLab_noPiggyBanks => 'Нет копилок. Сначала создай копилку.';

  @override
  String get earningsLab_sentForApproval => 'Отправлено родителю на одобрение';

  @override
  String get earningsLab_amountCannotBeNegative =>
      'Сумма не может быть отрицательной';

  @override
  String get earningsLab_wallet => 'Кошелёк';

  @override
  String get earningsLab_piggyBank => 'Копилка';

  @override
  String get earningsLab_no => 'Нет';

  @override
  String get earningsLab_daily => 'Ежедневно';

  @override
  String get earningsLab_weekly => 'Еженедельно';

  @override
  String get earningsLab_reminder => 'Напоминание';

  @override
  String get earningsLab_selectPiggyForReward => 'Выбери копилку для награды';

  @override
  String get earningsLab_createPlan => 'Создать план';

  @override
  String get earningsLab_discussWithBari => 'Обсудить с Бари';

  @override
  String get earningsLab_parentApprovalRequired => 'Нужно одобрение родителя';

  @override
  String get earningsLab_fillRequiredFields => 'Заполните обязательные поля';

  @override
  String earningsLab_completed(String title) {
    return 'Выполнено: $title';
  }

  @override
  String get earningsLab_howMuchEarned => 'Сколько получил?';

  @override
  String get earningsLab_whatWasDifficult => 'Что было сложным?';

  @override
  String get earningsLab_addCustomTask => 'Добавить своё задание';

  @override
  String get earningsLab_canRepeat => 'Можно повторять';

  @override
  String get earningsLab_requiresParent => 'Нужен родитель';

  @override
  String get earningsLab_taskName => 'Название задания *';

  @override
  String get earningsLab_taskNameHint => 'Например: Помочь бабушке';

  @override
  String get earningsLab_description => 'Описание';

  @override
  String get earningsLab_descriptionHint => 'Что нужно сделать?';

  @override
  String get earningsLab_descriptionOptional => 'Описание (необязательно)';

  @override
  String get earningsLab_descriptionOptionalHint =>
      'Например: что именно нужно сделать';

  @override
  String get earningsLab_time => 'Время *';

  @override
  String get earningsLab_timeHint => 'Например: 30 мин';

  @override
  String get earningsLab_reward => 'Награда';

  @override
  String get earningsLab_xp => 'XP';

  @override
  String get earningsLab_difficulty => 'Сложность';

  @override
  String get earningsLab_repeat => 'Повтор';

  @override
  String get earningsLab_rewardMustBePositive =>
      'Награда должна быть больше нуля';

  @override
  String get earningsLab_taskDescription => 'Описание не задано';

  @override
  String get earningsLab_rewardHelper => 'Сколько ты получишь за выполнение';

  @override
  String get earningsLab_taskNameRequired => 'Напиши название';

  @override
  String get bari_goal_noPiggyBanks => 'У тебя пока нет копилок.';

  @override
  String get bari_goal_noPiggyBanksAdvice =>
      'Создай первую копилку с целью — это главный шаг к накоплениям! Что хочешь купить?';

  @override
  String get bari_goal_createPiggyBank => 'Создать копилку';

  @override
  String get bari_goal_whenWillReach => 'Когда достигну цели';

  @override
  String bari_goal_onePiggyBank(String amount) {
    return 'У тебя 1 копилка с $amount внутри.';
  }

  @override
  String bari_goal_multiplePiggyBanks(int count, String total) {
    return 'У тебя $count копилок, всего накоплено $total.';
  }

  @override
  String bari_goal_almostFull(String name, int percent) {
    return 'Копилка \"$name\" почти заполнена ($percent%)! 🎉 Скоро цель!';
  }

  @override
  String bari_goal_justStarted(String name, int percent) {
    return 'Копилка \"$name\" только начата ($percent%). Пора пополнить!';
  }

  @override
  String get bari_goal_goodProgress =>
      'Хороший прогресс! Продолжай откладывать регулярно.';

  @override
  String get bari_goal_piggyBanks => 'Копилки';

  @override
  String get bari_goal_createFirst =>
      'У тебя пока нет копилок — создай первую!';

  @override
  String get bari_goal_createFirstAdvice =>
      'Выбери цель: игрушка, гаджет, подарок. И начни с маленьких взносов.';

  @override
  String bari_goal_topUpSoonest(String name, int days) {
    return 'Пополни \"$name\" — до дедлайна осталось $days дней!';
  }

  @override
  String bari_goal_topUpClosest(String name, int progress, String remaining) {
    return 'Советую пополнить \"$name\" ($progress%) — осталось $remaining, ты близко к цели!';
  }

  @override
  String get bari_goal_allFullOrEmpty =>
      'Все копилки полные или пустые. Создай новую цель!';

  @override
  String get bari_goal_topUpAdvice =>
      'Лучше пополнять ту копилку, которая ближе к цели или у которой скоро дедлайн.';

  @override
  String bari_goal_walletAlmostEmpty(String balance) {
    return 'Сейчас в кошельке почти пусто ($balance). Время подкопить!';
  }

  @override
  String bari_goal_walletEnoughForSmall(String balance) {
    return 'В кошельке $balance — хватит на мелочи. Для большего нужен план.';
  }

  @override
  String bari_goal_walletGood(String balance) {
    return 'В кошельке $balance — неплохо! Но помни про цели в копилках.';
  }

  @override
  String bari_goal_walletExcellent(String balance) {
    return 'В кошельке $balance — отлично! Подумай, стоит ли часть перевести в копилку.';
  }

  @override
  String bari_goal_walletBalance(String balance) {
    return 'Сейчас в кошельке $balance';
  }

  @override
  String get bari_goal_canIBuy => 'Можно ли купить?';

  @override
  String get bari_goal_balance => 'Баланс';

  @override
  String get bari_goal_enoughMoney => 'Да, у тебя уже достаточно денег! 🎉';

  @override
  String bari_goal_enoughMoneyAdvice(String available, String target) {
    return 'Всего есть $available (кошелёк + копилки), а нужно $target.';
  }

  @override
  String bari_goal_needToSave(String needed) {
    return 'Нужно накопить ещё $needed';
  }

  @override
  String bari_goal_needToSaveAdvice(String perMonth) {
    return 'Если откладывать по $perMonth в месяц, успеешь! Создай копилку с целью.';
  }

  @override
  String get bari_goal_savingSecret =>
      'Главный секрет накоплений — регулярность!';

  @override
  String get bari_goal_hardToSave =>
      'Копить сложно, когда нет привычки — это нормально!';

  @override
  String get bari_goal_optimalPercent =>
      'Оптимально откладывать 10-20% от каждого дохода.';

  @override
  String get bari_goal_createFirstPiggy =>
      'Создай первую копилку — цель мотивирует откладывать.';

  @override
  String get bari_hint_highSpending =>
      'За последнюю неделю у тебя много расходов.';

  @override
  String get bari_hint_highSpendingAdvice =>
      'Давай посмотрим, куда больше всего уходит денег.';

  @override
  String get bari_hint_mainExpenses => 'Основные траты';

  @override
  String bari_hint_stalledPiggy(String name) {
    return 'Копилка \"$name\" давно не пополнялась.';
  }

  @override
  String get bari_hint_stalledPiggies => 'Копилки немного \"застыли\".';

  @override
  String get bari_hint_stalledAdvice =>
      'Могу помочь придумать задание в Лаборатории заработка.';

  @override
  String get bari_hint_earningsLab => 'Лаборатория заработка';

  @override
  String get bari_hint_noLessons => 'Уроки давно не открывали.';

  @override
  String get bari_hint_noLessonsAdvice => 'Хочешь короткий урок на 3–5 минут?';

  @override
  String get bari_hint_lessons => 'Уроки';

  @override
  String get bari_hint_noLessonsYet => 'Ещё не проходили уроки?';

  @override
  String get bari_hint_noLessonsYetAdvice =>
      'Пройди первый урок — это займёт всего 3 минуты!';

  @override
  String get bari_hint_lowBalance =>
      'Баланс низкий, а скоро запланированы расходы.';

  @override
  String get bari_hint_lowBalanceAdvice =>
      'Можешь заработать в Лаборатории заработка или посмотреть план.';

  @override
  String get bari_hint_calendar => 'Календарь';

  @override
  String get bari_hint_highIncomeNoGoals =>
      'У тебя хорошие доходы, но нет целей для накопления.';

  @override
  String get bari_hint_highIncomeNoGoalsAdvice =>
      'Создай копилку для важной покупки!';

  @override
  String bari_hint_manySpendingCategory(String category) {
    return 'Много трат на \"$category\".';
  }

  @override
  String get bari_hint_manySpendingCategoryAdvice =>
      'Проверь, не превышаешь ли ты бюджет. Открой калькулятор бюджета.';

  @override
  String get bari_hint_budgetCalculator => 'Калькулятор бюджета';

  @override
  String get bari_hint_noPlannedEvents => 'Нет запланированных событий.';

  @override
  String get bari_hint_noPlannedEventsAdvice =>
      'Запланируй доходы и расходы, чтобы лучше управлять деньгами.';

  @override
  String get bari_hint_createPlan => 'Создать план';

  @override
  String get bari_hint_tipTitle => 'Подсказка Бари';

  @override
  String get bari_emptyMessage => 'Напиши вопрос 🙂';

  @override
  String get bari_emptyMessageAdvice =>
      'Например: \"можно ли купить за 20€\" или \"что такое инфляция\"';

  @override
  String get bari_balance => 'Баланс';

  @override
  String get bari_piggyBanks => 'Копилки';

  @override
  String bari_math_percentOf(String percent, String base, String result) {
    return '$percent% от $base = $result';
  }

  @override
  String bari_math_percentAdvice(String percent) {
    return 'Полезно знать: если откладывать $percent% от дохода, это поможет копить регулярно.';
  }

  @override
  String get bari_math_calculator503020 => 'Калькулятор 50/30/20';

  @override
  String get bari_math_explainSimpler => 'Объясни проще';

  @override
  String bari_math_monthlyToYearly(String monthly, String yearly) {
    return '$monthly в месяц = $yearly в год';
  }

  @override
  String get bari_math_monthlyToYearlyAdvice =>
      'Маленькие регулярные суммы накапливаются! Подписки тоже стоит считать за год.';

  @override
  String get bari_math_subscriptionsCalculator => 'Калькулятор подписок';

  @override
  String bari_math_saveYearly(String monthly, String yearly) {
    return 'Если откладывать по $monthly в месяц, за год накопится $yearly';
  }

  @override
  String get bari_math_saveYearlyAdvice =>
      'Регулярность важнее суммы! Начни с маленького и увеличивай постепенно.';

  @override
  String bari_math_savePerPeriod(
    String target,
    String perPeriod,
    String period,
  ) {
    return 'Чтобы накопить $target, нужно откладывать по $perPeriod в $period';
  }

  @override
  String get bari_math_savePerPeriodAdvice =>
      'Создай копилку с этой целью — так проще не забывать!';

  @override
  String get bari_math_alreadyEnough => 'Ты уже накопил(а) достаточно! 🎉';

  @override
  String get bari_math_alreadyEnoughAdvice =>
      'Цель достигнута — можешь потратить или продолжить копить на что-то большее.';

  @override
  String bari_math_remainingToSave(String remaining, int percent) {
    return 'Осталось накопить $remaining (уже $percent% от цели)';
  }

  @override
  String get bari_math_remainingAdvice =>
      'Ты на правильном пути! Продолжай в том же темпе.';

  @override
  String bari_math_multiply(String a, String b, String result) {
    return '$a × $b = $result';
  }

  @override
  String get bari_math_multiplyAdvice =>
      'Умножение помогает считать регулярные траты: ежедневные за месяц, месячные за год.';

  @override
  String get bari_math_calculators => 'Калькуляторы';

  @override
  String get bari_math_divideByZero => 'На ноль делить нельзя!';

  @override
  String get bari_math_divideByZeroAdvice =>
      'Это как делить пиццу между нулём друзей — некому есть.';

  @override
  String bari_math_divide(String a, String b, String result) {
    return '$a ÷ $b = $result';
  }

  @override
  String get bari_math_divideAdvice =>
      'Деление помогает понять, сколько откладывать в неделю/месяц для цели.';

  @override
  String bari_math_priceComparison(int better, String price1, String price2) {
    return 'Вариант $better выгоднее! ($price1 за единицу vs $price2)';
  }

  @override
  String bari_math_priceComparisonAdvice(int savings) {
    return 'Экономия ~$savings%. Но проверь: успеешь ли использовать большую упаковку?';
  }

  @override
  String get bari_math_priceComparisonCalculator => 'Сравнение цен';

  @override
  String bari_math_rule72(String rate, String years) {
    return 'При $rate% годовых деньги удвоятся примерно за $years лет';
  }

  @override
  String bari_math_rule72Advice(String rate) {
    return 'Это \"Правило 72\" — быстрый способ оценить рост накоплений. Чем выше %, тем быстрее рост, но и риск выше.';
  }

  @override
  String get bari_math_lessons => 'Уроки';

  @override
  String bari_math_inflation(String amount, String years, String realValue) {
    return '$amount через $years лет будут \"стоить\" как $realValue сегодня';
  }

  @override
  String bari_math_inflationAdvice(String amount, String years) {
    return 'Инфляция \"съедает\" деньги. Поэтому важно не только копить, но и учиться инвестировать (когда подрастёшь).';
  }

  @override
  String get bari_spending_noData =>
      'Пока мало данных о твоих доходах и расходах.';

  @override
  String get bari_spending_noDataAdvice =>
      'Продолжай записывать операции — тогда я смогу подсказать больше.';

  @override
  String bari_goal_deadlineSoon(String name, int days) {
    return 'Пополни \"$name\" — до дедлайна осталось $days дней!';
  }

  @override
  String bari_goal_closeToGoal(String name, int progress, String remaining) {
    return 'Советую пополнить \"$name\" ($progress%) — осталось $remaining, ты близко к цели!';
  }

  @override
  String get bari_goal_whichPiggyBankAdvice =>
      'Лучше пополнять ту копилку, которая ближе к цели или у которой скоро дедлайн.';

  @override
  String get bari_goal_alreadyEnough => 'Да, у тебя уже достаточно денег! 🎉';

  @override
  String bari_goal_alreadyEnoughAdvice(String available, String target) {
    return 'Всего есть $available (кошелёк + копилки), а нужно $target.';
  }

  @override
  String bari_goal_savePerMonth(String perMonth) {
    return 'Если откладывать по $perMonth в месяц, успеешь! Создай копилку с целью.';
  }

  @override
  String bari_goal_emptyWallet(String balance) {
    return 'Сейчас в кошельке почти пусто ($balance). Время подкопить!';
  }

  @override
  String bari_goal_lowBalance(String balance) {
    return 'В кошельке $balance — можно пополнить копилку или оставить на расходы.';
  }

  @override
  String bari_goal_goodBalance(String balance) {
    return 'В кошельке $balance — отличный баланс! Можно пополнить копилки.';
  }

  @override
  String get bari_goal_createFirstPiggyBank =>
      'Создай первую копилку — цель мотивирует откладывать.';

  @override
  String get bari_goal_setDeadline =>
      'Установи дедлайн для копилки — так проще планировать.';

  @override
  String get bari_goal_regularTopUps =>
      'Пополняй копилки регулярно, даже маленькими суммами.';

  @override
  String get bari_goal_checkProgress =>
      'Проверяй прогресс копилок — это мотивирует!';

  @override
  String get bari_goal_completeLessons =>
      'Пройди уроки о накоплениях — узнаешь полезные советы.';

  @override
  String bari_math_percentOfResult(String percent, String base, String result) {
    return '$percent% от $base = $result';
  }

  @override
  String bari_math_percentAdviceWithPercent(String percent) {
    return 'Полезно знать: если откладывать $percent% от дохода, это поможет копить регулярно.';
  }

  @override
  String bari_math_monthlyToYearlyResult(String monthly, String yearly) {
    return '$monthly в месяц = $yearly в год';
  }

  @override
  String bari_math_saveYearlyResult(String monthly, String yearly) {
    return 'Если откладывать по $monthly в месяц, за год накопится $yearly';
  }

  @override
  String bari_math_savePerPeriodResult(
    String target,
    String perPeriod,
    String period,
  ) {
    return 'Чтобы накопить $target, нужно откладывать по $perPeriod в $period';
  }

  @override
  String get bari_math_createPiggyBank => 'Создать копилку';

  @override
  String get bari_math_whenWillReach => 'Когда достигну цели';

  @override
  String bari_math_remainingToSaveResult(String remaining, int percent) {
    return 'Осталось накопить $remaining (уже $percent% от цели)';
  }

  @override
  String bari_math_multiplyResult(String a, String b, String result) {
    return '$a × $b = $result';
  }

  @override
  String bari_math_divideResult(String a, String b, String result) {
    return '$a ÷ $b = $result';
  }

  @override
  String bari_math_priceComparisonResult(
    int better,
    String price1,
    String price2,
  ) {
    return 'Вариант $better выгоднее! ($price1 за единицу vs $price2)';
  }

  @override
  String bari_math_priceComparisonAdviceWithSavings(int savings) {
    return 'Экономия ~$savings%. Но проверь: успеешь ли использовать большую упаковку?';
  }

  @override
  String bari_math_rule72Result(String rate, String years) {
    return 'При $rate% годовых деньги удвоятся примерно за $years лет';
  }

  @override
  String bari_math_rule72AdviceWithRate(String rate) {
    return 'Это \"Правило 72\" — быстрый способ оценить рост накоплений. Чем выше %, тем быстрее рост, но и риск выше.';
  }

  @override
  String bari_math_inflationResult(
    String amount,
    String years,
    String realValue,
  ) {
    return '$amount через $years лет будут \"стоить\" как $realValue сегодня';
  }

  @override
  String bari_math_inflationAdviceWithAmount(String amount, String years) {
    return 'Инфляция \"съедает\" деньги. Поэтому важно не только копить, но и учиться инвестировать (когда подрастёшь).';
  }

  @override
  String get earningsLab_piggyBankNotFound => 'Копилка не найдена';

  @override
  String get earningsLab_noTransactions => 'По этой копилке ещё нет операций';

  @override
  String get earningsLab_transactionHistory => 'История по этой копилке';

  @override
  String get earningsLab_topUp => 'Пополнение копилки';

  @override
  String get earningsLab_withdrawal => 'Снятие из копилки';

  @override
  String get earningsLab_goalReached => 'Цель достигнута 🎉';

  @override
  String get earningsLab_goalReachedSubtitle =>
      'Молодец! Можешь создать новую цель или перенести деньги в кошелёк.';

  @override
  String get earningsLab_almostThere => 'Осталось совсем чуть-чуть';

  @override
  String get earningsLab_almostThereSubtitle =>
      'Подумай, как сделать ещё 1–2 пополнения — и цель будет закрыта.';

  @override
  String get earningsLab_halfway => 'Половина пути пройдена';

  @override
  String get earningsLab_halfwaySubtitle =>
      'Если будешь пополнять копилку регулярно, достигнешь цели гораздо быстрее.';

  @override
  String get earningsLab_goodStart => 'Хорошее начало';

  @override
  String get earningsLab_goodStartSubtitle =>
      'Попробуй настроить автопополнение или добавить задание в Лаборатории заработка специально под эту цель.';

  @override
  String get notes_title => 'Заметки';

  @override
  String get notes_listView => 'Список';

  @override
  String get notes_gridView => 'Сетка';

  @override
  String get notes_searchHint => 'Поиск заметок...';

  @override
  String get notes_all => 'Все';

  @override
  String get notes_pinned => 'Закреплённые';

  @override
  String get notes_archived => 'Архив';

  @override
  String get notes_linked => 'Связанные';

  @override
  String get notes_errorLoading => 'Ошибка загрузки заметок';

  @override
  String get notes_emptyArchived => 'Архив пуст';

  @override
  String get notes_emptyPinned => 'Нет закреплённых заметок';

  @override
  String get notes_empty => 'Нет заметок';

  @override
  String get notes_emptySubtitle =>
      'Создайте первую заметку, чтобы сохранить важные мысли';

  @override
  String get notes_createFirst => 'Создать первую заметку';

  @override
  String get notes_deleteConfirm => 'Удалить заметку?';

  @override
  String notes_deleteMessage(String noteTitle) {
    return 'Вы уверены, что хотите удалить заметку \"$noteTitle\"?';
  }

  @override
  String get notes_unpin => 'Открепить';

  @override
  String get notes_pin => 'Закрепить';

  @override
  String get notes_unarchive => 'Вернуть из архива';

  @override
  String get notes_archive => 'В архив';

  @override
  String get notes_copy => 'Копировать';

  @override
  String get notes_share => 'Поделиться';

  @override
  String get notes_copied => 'Заметка скопирована';

  @override
  String get notes_shareNotAvailable => 'Функция шаринга временно недоступна';

  @override
  String get notes_edit => 'Редактировать заметку';

  @override
  String get notes_create => 'Новая заметка';

  @override
  String get notes_changeColor => 'Изменить цвет';

  @override
  String get notes_editTags => 'Редактировать теги';

  @override
  String get notes_selectColor => 'Выберите цвет';

  @override
  String get notes_clearColor => 'Очистить цвет';

  @override
  String get notes_tagHint => 'Добавить тег...';

  @override
  String get notes_titleRequired => 'Введите заголовок заметки';

  @override
  String get notes_titleHint => 'Заголовок заметки...';

  @override
  String get notes_contentHint => 'Начните писать здесь...';

  @override
  String get notes_save => 'Сохранить заметку';

  @override
  String get notes_today => 'Сегодня';

  @override
  String get notes_yesterday => 'Вчера';

  @override
  String notes_daysAgo(int days) {
    return '$days дн.';
  }

  @override
  String get notes_templates => 'Шаблоны';

  @override
  String get notes_templateExpense => 'Планирование расходов';

  @override
  String get notes_templateGoal => 'Цель';

  @override
  String get notes_templateIdea => 'Идея';

  @override
  String get notes_templateMeeting => 'Встреча';

  @override
  String get notes_templateLearning => 'Обучение';

  @override
  String get notes_templateExpenseDesc => 'Запланируй свои расходы';

  @override
  String get notes_templateGoalDesc => 'Запиши свою цель';

  @override
  String get notes_templateIdeaDesc => 'Сохрани свою идею';

  @override
  String get notes_templateMeetingDesc => 'Заметки к встрече';

  @override
  String get notes_templateLearningDesc => 'Заметки к уроку';

  @override
  String get notes_linkToEvent => 'Привязать к событию';

  @override
  String get notes_linkedToEvent => 'Привязано к событию';

  @override
  String get notes_unlinkFromEvent => 'Отвязать от события';

  @override
  String get notes_selectEvent => 'Выберите событие';

  @override
  String get notes_noEvents => 'Нет доступных событий';

  @override
  String get notes_bariTip => 'Совет от Бари';

  @override
  String get notes_quickNote => 'Быстрая заметка';

  @override
  String get notes_autoSave => 'Автосохранение';

  @override
  String get notes_preview => 'Предпросмотр';

  @override
  String get notes_swipeToArchive => 'Смахните влево для архива';

  @override
  String get notes_swipeToDelete => 'Смахните вправо для удаления';

  @override
  String get notes_templateShoppingList => 'Список покупок';

  @override
  String get notes_templateShoppingListDesc => 'Организуй свои покупки';

  @override
  String get notes_templateReflection => 'Размышления';

  @override
  String get notes_templateReflectionDesc => 'Запиши свои мысли';

  @override
  String get notes_templateGratitude => 'Благодарность';

  @override
  String get notes_templateGratitudeDesc => 'За что я благодарен';

  @override
  String get notes_templateParentReport => 'Отчет для родителей';

  @override
  String get notes_templateParentReportDesc => 'Автоматический отчет за период';

  @override
  String get calendarSync_title => 'Синхронизация с календарём';

  @override
  String get calendarSync_enable => 'Включить синхронизацию';

  @override
  String get calendarSync_syncToCalendar =>
      'Синхронизировать события в календарь';

  @override
  String get calendarSync_syncFromCalendar =>
      'Импортировать события из календаря';

  @override
  String get calendarSync_selectCalendars => 'Выбрать календари';

  @override
  String get calendarSync_noCalendars => 'Нет доступных календарей';

  @override
  String get calendarSync_requestPermissions => 'Запросить разрешения';

  @override
  String get calendarSync_permissionsGranted => 'Разрешения предоставлены';

  @override
  String get calendarSync_permissionsDenied => 'Разрешения не предоставлены';

  @override
  String get calendarSync_syncNow => 'Синхронизировать сейчас';

  @override
  String get calendarSync_lastSync => 'Последняя синхронизация';

  @override
  String get calendarSync_never => 'Никогда';

  @override
  String get calendarSync_conflictResolution => 'Разрешение конфликтов';

  @override
  String get calendarSync_appWins => 'Приложение имеет приоритет';

  @override
  String get calendarSync_calendarWins => 'Календарь имеет приоритет';

  @override
  String get calendarSync_askUser => 'Спрашивать пользователя';

  @override
  String get calendarSync_merge => 'Объединять';

  @override
  String get calendarSync_syncInterval => 'Интервал синхронизации (часы)';

  @override
  String get calendarSync_showNotifications => 'Показывать уведомления';

  @override
  String get calendarSync_syncNotesAsEvents =>
      'Синхронизировать заметки как события';

  @override
  String get calendarSync_statistics => 'Статистика';

  @override
  String get calendarSync_totalEvents => 'Всего событий';

  @override
  String get calendarSync_syncedEvents => 'Синхронизировано';

  @override
  String get calendarSync_localEvents => 'Локальные';

  @override
  String get calendarSync_errorEvents => 'Ошибки';

  @override
  String get calendarSync_successRate => 'Успешность';

  @override
  String get calendarSync_syncInProgress => 'Синхронизация...';

  @override
  String get modelLoader_title => 'Загрузка модели ИИ';

  @override
  String get modelLoader_loading => 'Загрузка модели из приложения...';

  @override
  String get modelLoader_preparing =>
      'Модель загружена, подготовка к распаковке...';

  @override
  String get modelLoader_decompressing =>
      'Распаковка модели (это может занять минуту)...';

  @override
  String modelLoader_saving(String percent) {
    return 'Сохранение... $percent%';
  }

  @override
  String get modelLoader_complete => 'Модель готова!';

  @override
  String get modelLoader_error => 'Ошибка загрузки модели';

  @override
  String get modelLoader_errorMessage =>
      'Не удалось загрузить модель ИИ. Пожалуйста, попробуйте снова или обратитесь в поддержку.';

  @override
  String get modelLoader_retry => 'Повторить';

  @override
  String get modelLoader_cancel => 'Отмена';
}
