import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @common_cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get common_cancel;

  /// No description provided for @common_save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get common_save;

  /// No description provided for @common_create.
  ///
  /// In ru, this message translates to:
  /// **'Создать'**
  String get common_create;

  /// No description provided for @common_delete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get common_delete;

  /// No description provided for @common_done.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get common_done;

  /// No description provided for @common_understand.
  ///
  /// In ru, this message translates to:
  /// **'Понятно'**
  String get common_understand;

  /// No description provided for @common_planCreated.
  ///
  /// In ru, this message translates to:
  /// **'План успешно создан!'**
  String get common_planCreated;

  /// No description provided for @common_purchasePlanned.
  ///
  /// In ru, this message translates to:
  /// **'Покупка запланирована!'**
  String get common_purchasePlanned;

  /// No description provided for @common_income.
  ///
  /// In ru, this message translates to:
  /// **'Доход'**
  String get common_income;

  /// No description provided for @common_expense.
  ///
  /// In ru, this message translates to:
  /// **'Расход'**
  String get common_expense;

  /// No description provided for @common_plan.
  ///
  /// In ru, this message translates to:
  /// **'План'**
  String get common_plan;

  /// No description provided for @common_balance.
  ///
  /// In ru, this message translates to:
  /// **'Баланс'**
  String get common_balance;

  /// No description provided for @common_piggyBanks.
  ///
  /// In ru, this message translates to:
  /// **'Копилки'**
  String get common_piggyBanks;

  /// No description provided for @common_calendar.
  ///
  /// In ru, this message translates to:
  /// **'Календарь'**
  String get common_calendar;

  /// No description provided for @common_lessons.
  ///
  /// In ru, this message translates to:
  /// **'Уроки'**
  String get common_lessons;

  /// No description provided for @common_settings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get common_settings;

  /// No description provided for @common_tools.
  ///
  /// In ru, this message translates to:
  /// **'Инструменты'**
  String get common_tools;

  /// No description provided for @common_continue.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get common_continue;

  /// No description provided for @common_confirm.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить'**
  String get common_confirm;

  /// No description provided for @common_error.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка'**
  String get common_error;

  /// No description provided for @common_tryAgain.
  ///
  /// In ru, this message translates to:
  /// **'Попробовать снова'**
  String get common_tryAgain;

  /// No description provided for @balance.
  ///
  /// In ru, this message translates to:
  /// **'Баланс'**
  String get balance;

  /// No description provided for @search.
  ///
  /// In ru, this message translates to:
  /// **'Поиск'**
  String get search;

  /// No description provided for @reset.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить'**
  String get reset;

  /// No description provided for @done.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get done;

  /// No description provided for @moneyValidator_enterAmount.
  ///
  /// In ru, this message translates to:
  /// **'Напиши сумму'**
  String get moneyValidator_enterAmount;

  /// No description provided for @moneyValidator_notANumber.
  ///
  /// In ru, this message translates to:
  /// **'Не похоже на число'**
  String get moneyValidator_notANumber;

  /// No description provided for @moneyValidator_mustBePositive.
  ///
  /// In ru, this message translates to:
  /// **'Сумма должна быть больше 0'**
  String get moneyValidator_mustBePositive;

  /// No description provided for @moneyValidator_tooSmall.
  ///
  /// In ru, this message translates to:
  /// **'Сумма слишком маленькая'**
  String get moneyValidator_tooSmall;

  /// No description provided for @bariOverlay_tipOfDay.
  ///
  /// In ru, this message translates to:
  /// **'Подсказка дня'**
  String get bariOverlay_tipOfDay;

  /// No description provided for @bariOverlay_defaultTip.
  ///
  /// In ru, this message translates to:
  /// **'Помни: каждая монета приближает тебя к цели!'**
  String get bariOverlay_defaultTip;

  /// No description provided for @bariOverlay_instructions.
  ///
  /// In ru, this message translates to:
  /// **'Нажми на Бари — открыть подсказку. Двойной тап — чат.'**
  String get bariOverlay_instructions;

  /// No description provided for @bariOverlay_openChat.
  ///
  /// In ru, this message translates to:
  /// **'Открыть чат'**
  String get bariOverlay_openChat;

  /// No description provided for @bariOverlay_moreTips.
  ///
  /// In ru, this message translates to:
  /// **'Ещё подсказку'**
  String get bariOverlay_moreTips;

  /// No description provided for @bariAvatar_happy.
  ///
  /// In ru, this message translates to:
  /// **'😄'**
  String get bariAvatar_happy;

  /// No description provided for @bariAvatar_encouraging.
  ///
  /// In ru, this message translates to:
  /// **'🤔'**
  String get bariAvatar_encouraging;

  /// No description provided for @bariAvatar_neutral.
  ///
  /// In ru, this message translates to:
  /// **'😌'**
  String get bariAvatar_neutral;

  /// No description provided for @mainScreen_transferToPiggyBank.
  ///
  /// In ru, this message translates to:
  /// **'Перевод в копилку \"{bankName}\" (из дохода)'**
  String mainScreen_transferToPiggyBank(String bankName);

  /// No description provided for @bariTip_income.
  ///
  /// In ru, this message translates to:
  /// **'Отличный доход! Куда потратишь?'**
  String get bariTip_income;

  /// No description provided for @bariTip_expense.
  ///
  /// In ru, this message translates to:
  /// **'Потрачено. Это было в планах?'**
  String get bariTip_expense;

  /// No description provided for @bariTip_planCreated.
  ///
  /// In ru, this message translates to:
  /// **'План создан! Следовать ему — ключ к успеху.'**
  String get bariTip_planCreated;

  /// No description provided for @bariTip_planCompleted.
  ///
  /// In ru, this message translates to:
  /// **'План выполнен! Ты молодец!'**
  String get bariTip_planCompleted;

  /// No description provided for @bariTip_piggyBankCreated.
  ///
  /// In ru, this message translates to:
  /// **'Новая копилка! На что копим?'**
  String get bariTip_piggyBankCreated;

  /// No description provided for @bariTip_piggyBankCompleted.
  ///
  /// In ru, this message translates to:
  /// **'Копилка заполнена! Поздравляю с достижением цели!'**
  String get bariTip_piggyBankCompleted;

  /// No description provided for @bariTip_lessonCompleted.
  ///
  /// In ru, this message translates to:
  /// **'Урок пройден! Новые знания — суперсила!'**
  String get bariTip_lessonCompleted;

  /// No description provided for @period_day.
  ///
  /// In ru, this message translates to:
  /// **'День'**
  String get period_day;

  /// No description provided for @period_week.
  ///
  /// In ru, this message translates to:
  /// **'Неделя'**
  String get period_week;

  /// No description provided for @period_month.
  ///
  /// In ru, this message translates to:
  /// **'Месяц'**
  String get period_month;

  /// No description provided for @period_inADay.
  ///
  /// In ru, this message translates to:
  /// **'в день'**
  String get period_inADay;

  /// No description provided for @period_inAWeek.
  ///
  /// In ru, this message translates to:
  /// **'в неделю'**
  String get period_inAWeek;

  /// No description provided for @period_inAMonth.
  ///
  /// In ru, this message translates to:
  /// **'в месяц'**
  String get period_inAMonth;

  /// No description provided for @period_everyDay.
  ///
  /// In ru, this message translates to:
  /// **'Каждый день'**
  String get period_everyDay;

  /// No description provided for @period_onceAWeek.
  ///
  /// In ru, this message translates to:
  /// **'Раз в неделю'**
  String get period_onceAWeek;

  /// No description provided for @period_onceAMonth.
  ///
  /// In ru, this message translates to:
  /// **'Раз в месяц'**
  String get period_onceAMonth;

  /// No description provided for @plural_days.
  ///
  /// In ru, this message translates to:
  /// **'{count,plural, =1{день} few{дня} many{дней} other{дней}}'**
  String plural_days(int count);

  /// No description provided for @monthlyBudgetCalculator_title.
  ///
  /// In ru, this message translates to:
  /// **'План расходов на месяц'**
  String get monthlyBudgetCalculator_title;

  /// No description provided for @monthlyBudgetCalculator_subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Поставь лимит и посмотри остаток — деньги станет легче контролировать.'**
  String get monthlyBudgetCalculator_subtitle;

  /// No description provided for @monthlyBudgetCalculator_step1.
  ///
  /// In ru, this message translates to:
  /// **'Месяц'**
  String get monthlyBudgetCalculator_step1;

  /// No description provided for @monthlyBudgetCalculator_step2.
  ///
  /// In ru, this message translates to:
  /// **'Лимит'**
  String get monthlyBudgetCalculator_step2;

  /// No description provided for @monthlyBudgetCalculator_step3.
  ///
  /// In ru, this message translates to:
  /// **'Итог'**
  String get monthlyBudgetCalculator_step3;

  /// No description provided for @monthlyBudgetCalculator_selectMonth.
  ///
  /// In ru, this message translates to:
  /// **'1) Выбери месяц'**
  String get monthlyBudgetCalculator_selectMonth;

  /// No description provided for @monthlyBudgetCalculator_setLimit.
  ///
  /// In ru, this message translates to:
  /// **'2) Поставь лимит'**
  String get monthlyBudgetCalculator_setLimit;

  /// No description provided for @monthlyBudgetCalculator_limitForMonth.
  ///
  /// In ru, this message translates to:
  /// **'Лимит на месяц'**
  String get monthlyBudgetCalculator_limitForMonth;

  /// No description provided for @monthlyBudgetCalculator_result.
  ///
  /// In ru, this message translates to:
  /// **'Итог'**
  String get monthlyBudgetCalculator_result;

  /// No description provided for @monthlyBudgetCalculator_spent.
  ///
  /// In ru, this message translates to:
  /// **'Потрачено'**
  String get monthlyBudgetCalculator_spent;

  /// No description provided for @monthlyBudgetCalculator_remaining.
  ///
  /// In ru, this message translates to:
  /// **'Осталось'**
  String get monthlyBudgetCalculator_remaining;

  /// No description provided for @monthlyBudgetCalculator_warningAlmostLimit.
  ///
  /// In ru, this message translates to:
  /// **'⚠️ Почти достигнут лимит! Попробуй снизить траты в оставшиеся дни.'**
  String get monthlyBudgetCalculator_warningAlmostLimit;

  /// No description provided for @monthlyBudgetCalculator_warningOverLimit.
  ///
  /// In ru, this message translates to:
  /// **'Ты вышел за лимит на {amount}. Можно пересмотреть лимит или найти, где сэкономить.'**
  String monthlyBudgetCalculator_warningOverLimit(String amount);

  /// No description provided for @goalDateCalculator_title.
  ///
  /// In ru, this message translates to:
  /// **'Когда я достигну цели'**
  String get goalDateCalculator_title;

  /// No description provided for @goalDateCalculator_subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Введи сумму взноса и частоту — я покажу примерную дату достижения.'**
  String get goalDateCalculator_subtitle;

  /// No description provided for @goalDateCalculator_stepGoal.
  ///
  /// In ru, this message translates to:
  /// **'Цель'**
  String get goalDateCalculator_stepGoal;

  /// No description provided for @goalDateCalculator_stepContribution.
  ///
  /// In ru, this message translates to:
  /// **'Взнос'**
  String get goalDateCalculator_stepContribution;

  /// No description provided for @goalDateCalculator_stepFrequency.
  ///
  /// In ru, this message translates to:
  /// **'Частота'**
  String get goalDateCalculator_stepFrequency;

  /// No description provided for @goalDateCalculator_headerGoal.
  ///
  /// In ru, this message translates to:
  /// **'1) Цель'**
  String get goalDateCalculator_headerGoal;

  /// No description provided for @goalDateCalculator_piggyBankLabel.
  ///
  /// In ru, this message translates to:
  /// **'Копилка'**
  String get goalDateCalculator_piggyBankLabel;

  /// No description provided for @goalDateCalculator_remainingToGoal.
  ///
  /// In ru, this message translates to:
  /// **'Осталось: {amount}'**
  String goalDateCalculator_remainingToGoal(String amount);

  /// No description provided for @goalDateCalculator_headerContribution.
  ///
  /// In ru, this message translates to:
  /// **'2) Сколько откладываешь'**
  String get goalDateCalculator_headerContribution;

  /// No description provided for @goalDateCalculator_contributionAmountLabel.
  ///
  /// In ru, this message translates to:
  /// **'Сумма взноса'**
  String get goalDateCalculator_contributionAmountLabel;

  /// No description provided for @goalDateCalculator_headerFrequency.
  ///
  /// In ru, this message translates to:
  /// **'3) Частота'**
  String get goalDateCalculator_headerFrequency;

  /// No description provided for @goalDateCalculator_result.
  ///
  /// In ru, this message translates to:
  /// **'Результат'**
  String get goalDateCalculator_result;

  /// No description provided for @goalDateCalculator_goalAlreadyReached.
  ///
  /// In ru, this message translates to:
  /// **'Цель уже достигнута — можно поставить новую!'**
  String get goalDateCalculator_goalAlreadyReached;

  /// No description provided for @goalDateCalculator_resultSummary.
  ///
  /// In ru, this message translates to:
  /// **'Примерно через {count} взносов (каждый {period})'**
  String goalDateCalculator_resultSummary(int count, String period);

  /// No description provided for @goalDateCalculator_upcomingDates.
  ///
  /// In ru, this message translates to:
  /// **'Ближайшие даты:'**
  String get goalDateCalculator_upcomingDates;

  /// No description provided for @goalDateCalculator_createPlanButton.
  ///
  /// In ru, this message translates to:
  /// **'Создать план взносов'**
  String get goalDateCalculator_createPlanButton;

  /// No description provided for @goalDateCalculator_dialogTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подтверждение'**
  String get goalDateCalculator_dialogTitle;

  /// No description provided for @goalDateCalculator_dialogSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Создание запланированных событий'**
  String get goalDateCalculator_dialogSubtitle;

  /// No description provided for @goalDateCalculator_dialogContent.
  ///
  /// In ru, this message translates to:
  /// **'Создать запланированные события для взносов в копилку \"{goalName}\"?'**
  String goalDateCalculator_dialogContent(String goalName);

  /// No description provided for @goalDateCalculator_defaultGoalName.
  ///
  /// In ru, this message translates to:
  /// **'цель'**
  String get goalDateCalculator_defaultGoalName;

  /// No description provided for @goalDateCalculator_dialogContributionAmount.
  ///
  /// In ru, this message translates to:
  /// **'Сумма взноса: {amount}'**
  String goalDateCalculator_dialogContributionAmount(String amount);

  /// No description provided for @goalDateCalculator_dialogFrequency.
  ///
  /// In ru, this message translates to:
  /// **'Периодичность: каждый {period}'**
  String goalDateCalculator_dialogFrequency(String period);

  /// No description provided for @goalDateCalculator_eventName.
  ///
  /// In ru, this message translates to:
  /// **'Взнос в копилку \"{goalName}\"'**
  String goalDateCalculator_eventName(String goalName);

  /// No description provided for @piggyPlanCalculator_title.
  ///
  /// In ru, this message translates to:
  /// **'Копилка-план'**
  String get piggyPlanCalculator_title;

  /// No description provided for @piggyPlanCalculator_subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Подскажу, сколько и как часто откладывать, чтобы дойти до цели.'**
  String get piggyPlanCalculator_subtitle;

  /// No description provided for @piggyPlanCalculator_stepGoal.
  ///
  /// In ru, this message translates to:
  /// **'Цель'**
  String get piggyPlanCalculator_stepGoal;

  /// No description provided for @piggyPlanCalculator_stepDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата'**
  String get piggyPlanCalculator_stepDate;

  /// No description provided for @piggyPlanCalculator_stepFrequency.
  ///
  /// In ru, this message translates to:
  /// **'Частота'**
  String get piggyPlanCalculator_stepFrequency;

  /// No description provided for @piggyPlanCalculator_headerSelectGoal.
  ///
  /// In ru, this message translates to:
  /// **'1) Выбери цель'**
  String get piggyPlanCalculator_headerSelectGoal;

  /// No description provided for @piggyPlanCalculator_goalAmountLabel.
  ///
  /// In ru, this message translates to:
  /// **'Цель (сумма)'**
  String get piggyPlanCalculator_goalAmountLabel;

  /// No description provided for @piggyPlanCalculator_currentAmountLabel.
  ///
  /// In ru, this message translates to:
  /// **'Уже есть'**
  String get piggyPlanCalculator_currentAmountLabel;

  /// No description provided for @piggyPlanCalculator_headerTargetDate.
  ///
  /// In ru, this message translates to:
  /// **'2) Когда хочешь дойти до цели?'**
  String get piggyPlanCalculator_headerTargetDate;

  /// No description provided for @piggyPlanCalculator_selectDate.
  ///
  /// In ru, this message translates to:
  /// **'Выбери дату'**
  String get piggyPlanCalculator_selectDate;

  /// No description provided for @piggyPlanCalculator_headerFrequency.
  ///
  /// In ru, this message translates to:
  /// **'3) Как часто откладывать?'**
  String get piggyPlanCalculator_headerFrequency;

  /// No description provided for @piggyPlanCalculator_result.
  ///
  /// In ru, this message translates to:
  /// **'Результат'**
  String get piggyPlanCalculator_result;

  /// No description provided for @piggyPlanCalculator_resultSummary.
  ///
  /// In ru, this message translates to:
  /// **'Откладывай примерно {amount} каждый {period} (всего взносов: {count}).'**
  String piggyPlanCalculator_resultSummary(
    String amount,
    String period,
    int count,
  );

  /// No description provided for @piggyPlanCalculator_planCreatedSnackbar.
  ///
  /// In ru, this message translates to:
  /// **'План создан: {amount} каждый {period}'**
  String piggyPlanCalculator_planCreatedSnackbar(String amount, String period);

  /// No description provided for @piggyPlanCalculator_scheduleFirstContributionButton.
  ///
  /// In ru, this message translates to:
  /// **'Запланировать первый взнос'**
  String get piggyPlanCalculator_scheduleFirstContributionButton;

  /// No description provided for @piggyPlanCalculator_dialogContributionAmount.
  ///
  /// In ru, this message translates to:
  /// **'Сумма: {amount}'**
  String piggyPlanCalculator_dialogContributionAmount(String amount);

  /// No description provided for @canIBuyCalculator_title.
  ///
  /// In ru, this message translates to:
  /// **'Можно ли купить?'**
  String get canIBuyCalculator_title;

  /// No description provided for @canIBuyCalculator_subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Проверим покупку прямо сейчас и с учётом планов на неделю.'**
  String get canIBuyCalculator_subtitle;

  /// No description provided for @canIBuyCalculator_stepPrice.
  ///
  /// In ru, this message translates to:
  /// **'Цена'**
  String get canIBuyCalculator_stepPrice;

  /// No description provided for @canIBuyCalculator_stepMoney.
  ///
  /// In ru, this message translates to:
  /// **'Деньги'**
  String get canIBuyCalculator_stepMoney;

  /// No description provided for @canIBuyCalculator_stepRules.
  ///
  /// In ru, this message translates to:
  /// **'Правила'**
  String get canIBuyCalculator_stepRules;

  /// No description provided for @canIBuyCalculator_headerPrice.
  ///
  /// In ru, this message translates to:
  /// **'1) Цена покупки'**
  String get canIBuyCalculator_headerPrice;

  /// No description provided for @canIBuyCalculator_priceLabel.
  ///
  /// In ru, this message translates to:
  /// **'Цена'**
  String get canIBuyCalculator_priceLabel;

  /// No description provided for @canIBuyCalculator_headerAvailableMoney.
  ///
  /// In ru, this message translates to:
  /// **'2) Сколько денег доступно'**
  String get canIBuyCalculator_headerAvailableMoney;

  /// No description provided for @canIBuyCalculator_walletBalanceLabel.
  ///
  /// In ru, this message translates to:
  /// **'В кошельке сейчас'**
  String get canIBuyCalculator_walletBalanceLabel;

  /// No description provided for @canIBuyCalculator_headerRules.
  ///
  /// In ru, this message translates to:
  /// **'3) Правила'**
  String get canIBuyCalculator_headerRules;

  /// No description provided for @canIBuyCalculator_ruleDontTouchPiggies.
  ///
  /// In ru, this message translates to:
  /// **'Не трогать копилки'**
  String get canIBuyCalculator_ruleDontTouchPiggies;

  /// No description provided for @canIBuyCalculator_ruleDontTouchPiggiesSubtitleEnabled.
  ///
  /// In ru, this message translates to:
  /// **'Считаем только кошелёк'**
  String get canIBuyCalculator_ruleDontTouchPiggiesSubtitleEnabled;

  /// No description provided for @canIBuyCalculator_ruleDontTouchPiggiesSubtitleDisabled.
  ///
  /// In ru, this message translates to:
  /// **'Можно использовать деньги из копилок как резерв'**
  String get canIBuyCalculator_ruleDontTouchPiggiesSubtitleDisabled;

  /// No description provided for @canIBuyCalculator_ruleConsiderPlans.
  ///
  /// In ru, this message translates to:
  /// **'Учитывать планы на 7 дней'**
  String get canIBuyCalculator_ruleConsiderPlans;

  /// No description provided for @canIBuyCalculator_ruleConsiderPlansSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Запланированные доходы/расходы из календаря'**
  String get canIBuyCalculator_ruleConsiderPlansSubtitle;

  /// No description provided for @canIBuyCalculator_result.
  ///
  /// In ru, this message translates to:
  /// **'Результат'**
  String get canIBuyCalculator_result;

  /// No description provided for @canIBuyCalculator_statusYes.
  ///
  /// In ru, this message translates to:
  /// **'Можно сейчас'**
  String get canIBuyCalculator_statusYes;

  /// No description provided for @canIBuyCalculator_statusYesBut.
  ///
  /// In ru, this message translates to:
  /// **'Можно сейчас, но планы на неделю могут помешать'**
  String get canIBuyCalculator_statusYesBut;

  /// No description provided for @canIBuyCalculator_statusMaybeWithPiggies.
  ///
  /// In ru, this message translates to:
  /// **'Можно, если взять часть из копилки'**
  String get canIBuyCalculator_statusMaybeWithPiggies;

  /// No description provided for @canIBuyCalculator_statusMaybeWithPlans.
  ///
  /// In ru, this message translates to:
  /// **'Пока не хватает, но планы/доходы на неделе могут помочь'**
  String get canIBuyCalculator_statusMaybeWithPlans;

  /// No description provided for @canIBuyCalculator_statusNo.
  ///
  /// In ru, this message translates to:
  /// **'Лучше подождать: не хватает {amount}'**
  String canIBuyCalculator_statusNo(String amount);

  /// No description provided for @canIBuyCalculator_planPurchaseButton.
  ///
  /// In ru, this message translates to:
  /// **'Запланировать покупку'**
  String get canIBuyCalculator_planPurchaseButton;

  /// No description provided for @canIBuyCalculator_dialogTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подтверждение'**
  String get canIBuyCalculator_dialogTitle;

  /// No description provided for @canIBuyCalculator_dialogSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Создание запланированного события'**
  String get canIBuyCalculator_dialogSubtitle;

  /// No description provided for @canIBuyCalculator_dialogContent.
  ///
  /// In ru, this message translates to:
  /// **'Создать запланированное событие для покупки?'**
  String get canIBuyCalculator_dialogContent;

  /// No description provided for @canIBuyCalculator_dialogAmount.
  ///
  /// In ru, this message translates to:
  /// **'Сумма: {amount}'**
  String canIBuyCalculator_dialogAmount(String amount);

  /// No description provided for @canIBuyCalculator_dialogInfo.
  ///
  /// In ru, this message translates to:
  /// **'Событие будет создано на 7 дней вперед.'**
  String get canIBuyCalculator_dialogInfo;

  /// No description provided for @canIBuyCalculator_defaultEventName.
  ///
  /// In ru, this message translates to:
  /// **'Покупка'**
  String get canIBuyCalculator_defaultEventName;

  /// No description provided for @toolsHub_subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Считай, планируй, прокачивайся'**
  String get toolsHub_subtitle;

  /// No description provided for @toolsHub_bariTipTitle.
  ///
  /// In ru, this message translates to:
  /// **'Совет Бари'**
  String get toolsHub_bariTipTitle;

  /// No description provided for @toolsHub_tipCalculators.
  ///
  /// In ru, this message translates to:
  /// **'Калькуляторы помогут тебе планировать и считать. Попробуй начать с \"Копилка-план\"!'**
  String get toolsHub_tipCalculators;

  /// No description provided for @toolsHub_tipEarningsLab.
  ///
  /// In ru, this message translates to:
  /// **'В Лаборатории заработка ты можешь выполнять задания и зарабатывать. Начни с простых!'**
  String get toolsHub_tipEarningsLab;

  /// No description provided for @toolsHub_tipMiniTrainers.
  ///
  /// In ru, this message translates to:
  /// **'60-секундные тренажёры помогут быстро прокачать навыки. Регулярность важнее скорости!'**
  String get toolsHub_tipMiniTrainers;

  /// No description provided for @toolsHub_tipBariRecommendations.
  ///
  /// In ru, this message translates to:
  /// **'Совет дня от Бари обновляется каждый день. Заходи почаще за новыми идеями!'**
  String get toolsHub_tipBariRecommendations;

  /// No description provided for @toolsHub_calendarForecastTitle.
  ///
  /// In ru, this message translates to:
  /// **'Календарный прогноз'**
  String get toolsHub_calendarForecastTitle;

  /// No description provided for @toolsHub_calendarForecastSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Будущий баланс и все запланированные события'**
  String get toolsHub_calendarForecastSubtitle;

  /// No description provided for @toolsHub_calculatorsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Калькуляторы'**
  String get toolsHub_calculatorsTitle;

  /// No description provided for @toolsHub_calculatorsSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'8 полезных калькуляторов для финансов'**
  String get toolsHub_calculatorsSubtitle;

  /// No description provided for @toolsHub_earningsLabTitle.
  ///
  /// In ru, this message translates to:
  /// **'Лаборатория заработка'**
  String get toolsHub_earningsLabTitle;

  /// No description provided for @toolsHub_earningsLabSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Задания и миссии для заработка'**
  String get toolsHub_earningsLabSubtitle;

  /// No description provided for @toolsHub_miniTrainersTitle.
  ///
  /// In ru, this message translates to:
  /// **'60 секунд'**
  String get toolsHub_miniTrainersTitle;

  /// No description provided for @toolsHub_miniTrainersSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Микро-упражнения для тренировки'**
  String get toolsHub_miniTrainersSubtitle;

  /// No description provided for @toolsHub_recommendationsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Совет дня'**
  String get toolsHub_recommendationsTitle;

  /// No description provided for @toolsHub_recommendationsSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Подборка советов и объяснений от Бари'**
  String get toolsHub_recommendationsSubtitle;

  /// No description provided for @toolsHub_notesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Заметки'**
  String get toolsHub_notesTitle;

  /// No description provided for @toolsHub_notesSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Создавай и организуй свои заметки'**
  String get toolsHub_notesSubtitle;

  /// No description provided for @toolsHub_tipNotes.
  ///
  /// In ru, this message translates to:
  /// **'Заметки помогут тебе не забыть важные мысли. Закрепляй самые важные!'**
  String get toolsHub_tipNotes;

  /// No description provided for @piggyBanks_explanationSimple.
  ///
  /// In ru, this message translates to:
  /// **'Копилка — это отдельная цель. Деньги в ней не влияют на баланс.'**
  String get piggyBanks_explanationSimple;

  /// No description provided for @piggyBanks_explanationPro.
  ///
  /// In ru, this message translates to:
  /// **'Копилка — это отдельная цель для накоплений. Деньги, которые ты кладёшь в копилку, не влияют на твой основной баланс. Это помогает видеть прогресс к конкретной цели.'**
  String get piggyBanks_explanationPro;

  /// No description provided for @piggyBanks_deleteConfirmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить копилку?'**
  String get piggyBanks_deleteConfirmTitle;

  /// No description provided for @piggyBanks_deleteConfirmMessage.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите удалить копилку \"{name}\"? Все связанные с ней операции останутся в истории, но сама копилка будет удалена.'**
  String piggyBanks_deleteConfirmMessage(String name);

  /// No description provided for @piggyBanks_deleteSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Копилка \"{name}\" удалена'**
  String piggyBanks_deleteSuccess(String name);

  /// No description provided for @piggyBanks_deleteError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка при удалении: {error}'**
  String piggyBanks_deleteError(String error);

  /// No description provided for @piggyBanks_emptyStateTitle.
  ///
  /// In ru, this message translates to:
  /// **'Нет копилок'**
  String get piggyBanks_emptyStateTitle;

  /// No description provided for @piggyBanks_createNewTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Создать новую копилку'**
  String get piggyBanks_createNewTooltip;

  /// No description provided for @piggyBanks_createNewButton.
  ///
  /// In ru, this message translates to:
  /// **'Создать копилку'**
  String get piggyBanks_createNewButton;

  /// No description provided for @piggyBanks_addNewButton.
  ///
  /// In ru, this message translates to:
  /// **'Добавить новую копилку'**
  String get piggyBanks_addNewButton;

  /// No description provided for @piggyBanks_fabTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Создать копилку'**
  String get piggyBanks_fabTooltip;

  /// No description provided for @piggyBanks_card_statusEmojiCompleted.
  ///
  /// In ru, this message translates to:
  /// **'🎉'**
  String get piggyBanks_card_statusEmojiCompleted;

  /// No description provided for @piggyBanks_card_statusEmojiAlmost.
  ///
  /// In ru, this message translates to:
  /// **'🔥'**
  String get piggyBanks_card_statusEmojiAlmost;

  /// No description provided for @piggyBanks_card_statusEmojiHalfway.
  ///
  /// In ru, this message translates to:
  /// **'💪'**
  String get piggyBanks_card_statusEmojiHalfway;

  /// No description provided for @piggyBanks_card_statusEmojiQuarter.
  ///
  /// In ru, this message translates to:
  /// **'🌱'**
  String get piggyBanks_card_statusEmojiQuarter;

  /// No description provided for @piggyBanks_card_statusEmojiStarted.
  ///
  /// In ru, this message translates to:
  /// **'🎯'**
  String get piggyBanks_card_statusEmojiStarted;

  /// No description provided for @piggyBanks_card_deleteTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get piggyBanks_card_deleteTooltip;

  /// No description provided for @piggyBanks_card_goalReached.
  ///
  /// In ru, this message translates to:
  /// **'✓ Цель достигнута!'**
  String get piggyBanks_card_goalReached;

  /// No description provided for @piggyBanks_card_estimatedDate.
  ///
  /// In ru, this message translates to:
  /// **'Достигнете к {date}'**
  String piggyBanks_card_estimatedDate(String date);

  /// No description provided for @piggyBanks_progress_goalReached.
  ///
  /// In ru, this message translates to:
  /// **'Цель достигнута! 🎉'**
  String get piggyBanks_progress_goalReached;

  /// No description provided for @piggyBanks_progress_almostThere.
  ///
  /// In ru, this message translates to:
  /// **'Почти у цели! Ещё {amount}'**
  String piggyBanks_progress_almostThere(String amount);

  /// No description provided for @piggyBanks_progress_halfway.
  ///
  /// In ru, this message translates to:
  /// **'Больше половины! 💪'**
  String get piggyBanks_progress_halfway;

  /// No description provided for @piggyBanks_progress_quarter.
  ///
  /// In ru, this message translates to:
  /// **'Четверть пути. Ещё {amount}'**
  String piggyBanks_progress_quarter(String amount);

  /// No description provided for @piggyBanks_progress_started.
  ///
  /// In ru, this message translates to:
  /// **'Начало положено 🌱'**
  String get piggyBanks_progress_started;

  /// No description provided for @piggyBanks_progress_initialGoal.
  ///
  /// In ru, this message translates to:
  /// **'Цель — {amount}'**
  String piggyBanks_progress_initialGoal(String amount);

  /// No description provided for @piggyBanks_createSheet_title.
  ///
  /// In ru, this message translates to:
  /// **'Новая копилка'**
  String get piggyBanks_createSheet_title;

  /// No description provided for @piggyBanks_createSheet_nameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Название копилки'**
  String get piggyBanks_createSheet_nameLabel;

  /// No description provided for @piggyBanks_createSheet_nameHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: Новый телефон'**
  String get piggyBanks_createSheet_nameHint;

  /// No description provided for @piggyBanks_createSheet_targetLabel.
  ///
  /// In ru, this message translates to:
  /// **'Целевая сумма'**
  String get piggyBanks_createSheet_targetLabel;

  /// No description provided for @piggyBanks_detail_deleteTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Удалить копилку'**
  String get piggyBanks_detail_deleteTooltip;

  /// No description provided for @piggyBanks_detail_fromAmount.
  ///
  /// In ru, this message translates to:
  /// **'из {amount}'**
  String piggyBanks_detail_fromAmount(String amount);

  /// No description provided for @piggyBanks_detail_topUpButton.
  ///
  /// In ru, this message translates to:
  /// **'Пополнить'**
  String get piggyBanks_detail_topUpButton;

  /// No description provided for @piggyBanks_detail_withdrawButton.
  ///
  /// In ru, this message translates to:
  /// **'Снять'**
  String get piggyBanks_detail_withdrawButton;

  /// No description provided for @piggyBanks_detail_autofillTitle.
  ///
  /// In ru, this message translates to:
  /// **'Автопополнение'**
  String get piggyBanks_detail_autofillTitle;

  /// No description provided for @piggyBanks_detail_autofillRuleLabel.
  ///
  /// In ru, this message translates to:
  /// **'Правило'**
  String get piggyBanks_detail_autofillRuleLabel;

  /// No description provided for @piggyBanks_detail_autofillTypePercent.
  ///
  /// In ru, this message translates to:
  /// **'Процент'**
  String get piggyBanks_detail_autofillTypePercent;

  /// No description provided for @piggyBanks_detail_autofillTypeFixed.
  ///
  /// In ru, this message translates to:
  /// **'Фиксированная'**
  String get piggyBanks_detail_autofillTypeFixed;

  /// No description provided for @piggyBanks_detail_autofillPercentLabel.
  ///
  /// In ru, this message translates to:
  /// **'Процент от дохода'**
  String get piggyBanks_detail_autofillPercentLabel;

  /// No description provided for @piggyBanks_detail_autofillFixedLabel.
  ///
  /// In ru, this message translates to:
  /// **'Фиксированная сумма'**
  String get piggyBanks_detail_autofillFixedLabel;

  /// No description provided for @piggyBanks_detail_autofillEnabledSnackbar.
  ///
  /// In ru, this message translates to:
  /// **'Автокопилка — это как невидимая привычка.'**
  String get piggyBanks_detail_autofillEnabledSnackbar;

  /// No description provided for @piggyBanks_detail_whenToReachGoalTitle.
  ///
  /// In ru, this message translates to:
  /// **'Когда достигну цель?'**
  String get piggyBanks_detail_whenToReachGoalTitle;

  /// No description provided for @piggyBanks_detail_calculateButton.
  ///
  /// In ru, this message translates to:
  /// **'Рассчитать'**
  String get piggyBanks_detail_calculateButton;

  /// No description provided for @piggyBanks_detail_goalExceededTitle.
  ///
  /// In ru, this message translates to:
  /// **'Цель будет превышена!'**
  String get piggyBanks_detail_goalExceededTitle;

  /// No description provided for @piggyBanks_detail_goalExceededMessage.
  ///
  /// In ru, this message translates to:
  /// **'При пополнении копилки \"{name}\" на {amount}, новая сумма составит {newAmount}, что превышает цель в {targetAmount}. Продолжить?'**
  String piggyBanks_detail_goalExceededMessage(
    String name,
    String amount,
    String newAmount,
    String targetAmount,
  );

  /// No description provided for @piggyBanks_detail_topUpTransactionNote.
  ///
  /// In ru, this message translates to:
  /// **'Пополнение копилки \"{name}\"'**
  String piggyBanks_detail_topUpTransactionNote(String name);

  /// No description provided for @piggyBanks_detail_successAnimationGoalReached.
  ///
  /// In ru, this message translates to:
  /// **'🎉 Цель достигнута!'**
  String get piggyBanks_detail_successAnimationGoalReached;

  /// No description provided for @piggyBanks_detail_successAnimationDaysCloser.
  ///
  /// In ru, this message translates to:
  /// **'+{amount} • Цель ближе на {count} {days} 🚀'**
  String piggyBanks_detail_successAnimationDaysCloser(
    String amount,
    int count,
    String days,
  );

  /// No description provided for @piggyBanks_detail_successAnimationSimpleTopUp.
  ///
  /// In ru, this message translates to:
  /// **'Копилка пополнена на {amount}'**
  String piggyBanks_detail_successAnimationSimpleTopUp(String amount);

  /// No description provided for @piggyBanks_detail_noFundsError.
  ///
  /// In ru, this message translates to:
  /// **'В копилке нет средств для снятия.'**
  String get piggyBanks_detail_noFundsError;

  /// No description provided for @piggyBanks_detail_noOtherPiggiesError.
  ///
  /// In ru, this message translates to:
  /// **'Нет других копилок для перевода.'**
  String get piggyBanks_detail_noOtherPiggiesError;

  /// No description provided for @piggyBanks_detail_insufficientFundsError.
  ///
  /// In ru, this message translates to:
  /// **'Недостаточно средств в копилке.'**
  String get piggyBanks_detail_insufficientFundsError;

  /// No description provided for @piggyBanks_detail_withdrawToWalletNote.
  ///
  /// In ru, this message translates to:
  /// **'Снятие из копилки \"{name}\" → кошелёк'**
  String piggyBanks_detail_withdrawToWalletNote(String name);

  /// No description provided for @piggyBanks_detail_withdrawToWalletSnackbar.
  ///
  /// In ru, this message translates to:
  /// **'{amount} переведено в кошелёк'**
  String piggyBanks_detail_withdrawToWalletSnackbar(String amount);

  /// No description provided for @piggyBanks_detail_spendFromPiggyNote.
  ///
  /// In ru, this message translates to:
  /// **'Покупка из копилки \"{name}\"'**
  String piggyBanks_detail_spendFromPiggyNote(String name);

  /// No description provided for @piggyBanks_detail_spendFromPiggySnackbar.
  ///
  /// In ru, this message translates to:
  /// **'Потрачено {amount} из копилки'**
  String piggyBanks_detail_spendFromPiggySnackbar(String amount);

  /// No description provided for @piggyBanks_detail_transferNote.
  ///
  /// In ru, this message translates to:
  /// **'Перевод между копилками: \"{fromBank}\" → \"{toBank}\"'**
  String piggyBanks_detail_transferNote(String fromBank, String toBank);

  /// No description provided for @piggyBanks_detail_transferSnackbar.
  ///
  /// In ru, this message translates to:
  /// **'{amount} переведено в \"{toBank}\"'**
  String piggyBanks_detail_transferSnackbar(String amount, String toBank);

  /// No description provided for @piggyBanks_operationSheet_addTitle.
  ///
  /// In ru, this message translates to:
  /// **'Пополнить копилку'**
  String get piggyBanks_operationSheet_addTitle;

  /// No description provided for @piggyBanks_operationSheet_transferTitle.
  ///
  /// In ru, this message translates to:
  /// **'Перевести в другую копилку'**
  String get piggyBanks_operationSheet_transferTitle;

  /// No description provided for @piggyBanks_operationSheet_spendTitle.
  ///
  /// In ru, this message translates to:
  /// **'Потратить из копилки'**
  String get piggyBanks_operationSheet_spendTitle;

  /// No description provided for @piggyBanks_operationSheet_withdrawTitle.
  ///
  /// In ru, this message translates to:
  /// **'Снять в кошелёк'**
  String get piggyBanks_operationSheet_withdrawTitle;

  /// No description provided for @piggyBanks_operationSheet_amountLabel.
  ///
  /// In ru, this message translates to:
  /// **'Сумма'**
  String get piggyBanks_operationSheet_amountLabel;

  /// No description provided for @piggyBanks_operationSheet_maxAmountHint.
  ///
  /// In ru, this message translates to:
  /// **'Максимум: {amount}'**
  String piggyBanks_operationSheet_maxAmountHint(String amount);

  /// No description provided for @piggyBanks_operationSheet_enterAmountHint.
  ///
  /// In ru, this message translates to:
  /// **'Введите сумму'**
  String get piggyBanks_operationSheet_enterAmountHint;

  /// No description provided for @piggyBanks_operationSheet_categoryLabel.
  ///
  /// In ru, this message translates to:
  /// **'Категория'**
  String get piggyBanks_operationSheet_categoryLabel;

  /// No description provided for @piggyBanks_operationSheet_categoryHint.
  ///
  /// In ru, this message translates to:
  /// **'Выберите категорию'**
  String get piggyBanks_operationSheet_categoryHint;

  /// No description provided for @piggyBanks_operationSheet_categoryFood.
  ///
  /// In ru, this message translates to:
  /// **'Еда'**
  String get piggyBanks_operationSheet_categoryFood;

  /// No description provided for @piggyBanks_operationSheet_categoryTransport.
  ///
  /// In ru, this message translates to:
  /// **'Транспорт'**
  String get piggyBanks_operationSheet_categoryTransport;

  /// No description provided for @piggyBanks_operationSheet_categoryEntertainment.
  ///
  /// In ru, this message translates to:
  /// **'Развлечения'**
  String get piggyBanks_operationSheet_categoryEntertainment;

  /// No description provided for @piggyBanks_operationSheet_categoryOther.
  ///
  /// In ru, this message translates to:
  /// **'Другое'**
  String get piggyBanks_operationSheet_categoryOther;

  /// No description provided for @piggyBanks_operationSheet_noteLabel.
  ///
  /// In ru, this message translates to:
  /// **'Название покупки (необязательно)'**
  String get piggyBanks_operationSheet_noteLabel;

  /// No description provided for @piggyBanks_operationSheet_noteHint.
  ///
  /// In ru, this message translates to:
  /// **'Введите название...'**
  String get piggyBanks_operationSheet_noteHint;

  /// No description provided for @piggyBanks_operationSheet_errorTooMuch.
  ///
  /// In ru, this message translates to:
  /// **'Сумма превышает доступные средства'**
  String get piggyBanks_operationSheet_errorTooMuch;

  /// No description provided for @piggyBanks_operationSheet_errorInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Введите корректную сумму'**
  String get piggyBanks_operationSheet_errorInvalid;

  /// No description provided for @piggyBanks_withdrawMode_title.
  ///
  /// In ru, this message translates to:
  /// **'Что сделать с деньгами?'**
  String get piggyBanks_withdrawMode_title;

  /// No description provided for @piggyBanks_withdrawMode_toWalletTitle.
  ///
  /// In ru, this message translates to:
  /// **'В кошелёк'**
  String get piggyBanks_withdrawMode_toWalletTitle;

  /// No description provided for @piggyBanks_withdrawMode_toWalletSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Кошелёк +, Копилка −'**
  String get piggyBanks_withdrawMode_toWalletSubtitle;

  /// No description provided for @piggyBanks_withdrawMode_spendTitle.
  ///
  /// In ru, this message translates to:
  /// **'Потратить сразу из копилки'**
  String get piggyBanks_withdrawMode_spendTitle;

  /// No description provided for @piggyBanks_withdrawMode_spendSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Кошелёк не меняется, Копилка −'**
  String get piggyBanks_withdrawMode_spendSubtitle;

  /// No description provided for @piggyBanks_withdrawMode_transferTitle.
  ///
  /// In ru, this message translates to:
  /// **'Перевести в другую копилку'**
  String get piggyBanks_withdrawMode_transferTitle;

  /// No description provided for @piggyBanks_withdrawMode_transferSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Кошелёк не меняется, Копилка A −, Копилка B +'**
  String get piggyBanks_withdrawMode_transferSubtitle;

  /// No description provided for @piggyBanks_picker_title.
  ///
  /// In ru, this message translates to:
  /// **'Выбери копилку для перевода'**
  String get piggyBanks_picker_title;

  /// No description provided for @piggyBanks_picker_defaultTitle.
  ///
  /// In ru, this message translates to:
  /// **'Выбери копилку'**
  String get piggyBanks_picker_defaultTitle;

  /// No description provided for @balance_currentBalance.
  ///
  /// In ru, this message translates to:
  /// **'Текущий баланс'**
  String get balance_currentBalance;

  /// No description provided for @balance_forecast.
  ///
  /// In ru, this message translates to:
  /// **'Прогноз'**
  String get balance_forecast;

  /// No description provided for @balance_fact.
  ///
  /// In ru, this message translates to:
  /// **'Факт'**
  String get balance_fact;

  /// No description provided for @balance_withPlannedExpenses.
  ///
  /// In ru, this message translates to:
  /// **'С учётом запланированных трат'**
  String get balance_withPlannedExpenses;

  /// No description provided for @balance_forecastForDay.
  ///
  /// In ru, this message translates to:
  /// **'Прогноз на день'**
  String get balance_forecastForDay;

  /// No description provided for @balance_forecastForWeek.
  ///
  /// In ru, this message translates to:
  /// **'Прогноз на неделю'**
  String get balance_forecastForWeek;

  /// No description provided for @balance_forecastForMonth.
  ///
  /// In ru, this message translates to:
  /// **'Прогноз на месяц'**
  String get balance_forecastForMonth;

  /// No description provided for @balance_forecastFor3Months.
  ///
  /// In ru, this message translates to:
  /// **'Прогноз на 3 месяца'**
  String get balance_forecastFor3Months;

  /// No description provided for @balance_level.
  ///
  /// In ru, this message translates to:
  /// **'Уровень {level}'**
  String balance_level(int level);

  /// No description provided for @balance_toolsDescription.
  ///
  /// In ru, this message translates to:
  /// **'Калькуляторы и инструменты для финансового планирования'**
  String get balance_toolsDescription;

  /// No description provided for @balance_tools.
  ///
  /// In ru, this message translates to:
  /// **'Инструменты'**
  String get balance_tools;

  /// No description provided for @balance_filterDay.
  ///
  /// In ru, this message translates to:
  /// **'День'**
  String get balance_filterDay;

  /// No description provided for @balance_filterWeek.
  ///
  /// In ru, this message translates to:
  /// **'Неделя'**
  String get balance_filterWeek;

  /// No description provided for @balance_filterMonth.
  ///
  /// In ru, this message translates to:
  /// **'Месяц'**
  String get balance_filterMonth;

  /// No description provided for @balance_emptyStateIncome.
  ///
  /// In ru, this message translates to:
  /// **'Пока пусто. Добавьте доход!'**
  String get balance_emptyStateIncome;

  /// No description provided for @balance_emptyStateNoTransactions.
  ///
  /// In ru, this message translates to:
  /// **'Нет транзакций за выбранный период'**
  String get balance_emptyStateNoTransactions;

  /// No description provided for @balance_addIncome.
  ///
  /// In ru, this message translates to:
  /// **'Добавить доход'**
  String get balance_addIncome;

  /// No description provided for @balance_addExpense.
  ///
  /// In ru, this message translates to:
  /// **'Добавить расход'**
  String get balance_addExpense;

  /// No description provided for @balance_amount.
  ///
  /// In ru, this message translates to:
  /// **'Сумма'**
  String get balance_amount;

  /// No description provided for @balance_category.
  ///
  /// In ru, this message translates to:
  /// **'Категория'**
  String get balance_category;

  /// No description provided for @balance_selectCategory.
  ///
  /// In ru, this message translates to:
  /// **'Выберите категорию'**
  String get balance_selectCategory;

  /// No description provided for @balance_toPiggyBank.
  ///
  /// In ru, this message translates to:
  /// **'В копилку (необязательно)'**
  String get balance_toPiggyBank;

  /// No description provided for @balance_fromPiggyBank.
  ///
  /// In ru, this message translates to:
  /// **'Из копилки (необязательно)'**
  String get balance_fromPiggyBank;

  /// No description provided for @balance_note.
  ///
  /// In ru, this message translates to:
  /// **'Заметка'**
  String get balance_note;

  /// No description provided for @balance_noteHint.
  ///
  /// In ru, this message translates to:
  /// **'Введите заметку...'**
  String get balance_noteHint;

  /// No description provided for @balance_save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get balance_save;

  /// No description provided for @balance_categories_food.
  ///
  /// In ru, this message translates to:
  /// **'Еда'**
  String get balance_categories_food;

  /// No description provided for @balance_categories_transport.
  ///
  /// In ru, this message translates to:
  /// **'Транспорт'**
  String get balance_categories_transport;

  /// No description provided for @balance_categories_games.
  ///
  /// In ru, this message translates to:
  /// **'Игры'**
  String get balance_categories_games;

  /// No description provided for @balance_categories_clothing.
  ///
  /// In ru, this message translates to:
  /// **'Одежда'**
  String get balance_categories_clothing;

  /// No description provided for @balance_categories_entertainment.
  ///
  /// In ru, this message translates to:
  /// **'Развлечения'**
  String get balance_categories_entertainment;

  /// No description provided for @balance_categories_other.
  ///
  /// In ru, this message translates to:
  /// **'Другое'**
  String get balance_categories_other;

  /// No description provided for @balance_categories_pocketMoney.
  ///
  /// In ru, this message translates to:
  /// **'Карманные'**
  String get balance_categories_pocketMoney;

  /// No description provided for @balance_categories_gift.
  ///
  /// In ru, this message translates to:
  /// **'Подарок'**
  String get balance_categories_gift;

  /// No description provided for @balance_categories_sideJob.
  ///
  /// In ru, this message translates to:
  /// **'Подработка'**
  String get balance_categories_sideJob;

  /// No description provided for @settings_language.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get settings_language;

  /// No description provided for @settings_selectCurrency.
  ///
  /// In ru, this message translates to:
  /// **'Выбери валюту'**
  String get settings_selectCurrency;

  /// No description provided for @settings_appearance.
  ///
  /// In ru, this message translates to:
  /// **'Внешний вид'**
  String get settings_appearance;

  /// No description provided for @settings_theme.
  ///
  /// In ru, this message translates to:
  /// **'Тема'**
  String get settings_theme;

  /// No description provided for @settings_themeBlue.
  ///
  /// In ru, this message translates to:
  /// **'Синяя'**
  String get settings_themeBlue;

  /// No description provided for @settings_themePurple.
  ///
  /// In ru, this message translates to:
  /// **'Фиолетовая'**
  String get settings_themePurple;

  /// No description provided for @settings_themeGreen.
  ///
  /// In ru, this message translates to:
  /// **'Зелёная'**
  String get settings_themeGreen;

  /// No description provided for @settings_explanationMode.
  ///
  /// In ru, this message translates to:
  /// **'Режим объяснений'**
  String get settings_explanationMode;

  /// No description provided for @settings_howToExplain.
  ///
  /// In ru, this message translates to:
  /// **'Как объяснять'**
  String get settings_howToExplain;

  /// No description provided for @settings_uxSimple.
  ///
  /// In ru, this message translates to:
  /// **'Simple'**
  String get settings_uxSimple;

  /// No description provided for @settings_uxPro.
  ///
  /// In ru, this message translates to:
  /// **'Pro'**
  String get settings_uxPro;

  /// No description provided for @settings_uxSimpleDescription.
  ///
  /// In ru, this message translates to:
  /// **'Простые объяснения'**
  String get settings_uxSimpleDescription;

  /// No description provided for @settings_uxProDescription.
  ///
  /// In ru, this message translates to:
  /// **'Подробные объяснения'**
  String get settings_uxProDescription;

  /// No description provided for @settings_currency.
  ///
  /// In ru, this message translates to:
  /// **'Валюта'**
  String get settings_currency;

  /// No description provided for @settings_notifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get settings_notifications;

  /// No description provided for @settings_bari.
  ///
  /// In ru, this message translates to:
  /// **'Bari Smart'**
  String get settings_bari;

  /// No description provided for @settings_bariMode.
  ///
  /// In ru, this message translates to:
  /// **'Режим Bari'**
  String get settings_bariMode;

  /// No description provided for @settings_bariModeOffline.
  ///
  /// In ru, this message translates to:
  /// **'Офлайн'**
  String get settings_bariModeOffline;

  /// No description provided for @settings_bariModeOnline.
  ///
  /// In ru, this message translates to:
  /// **'Онлайн'**
  String get settings_bariModeOnline;

  /// No description provided for @settings_bariModeHybrid.
  ///
  /// In ru, this message translates to:
  /// **'Гибридный'**
  String get settings_bariModeHybrid;

  /// No description provided for @settings_showSources.
  ///
  /// In ru, this message translates to:
  /// **'Показывать источники'**
  String get settings_showSources;

  /// No description provided for @settings_showSourcesDescription.
  ///
  /// In ru, this message translates to:
  /// **'Показывать источники советов'**
  String get settings_showSourcesDescription;

  /// No description provided for @settings_smallTalk.
  ///
  /// In ru, this message translates to:
  /// **'Небольшие разговоры'**
  String get settings_smallTalk;

  /// No description provided for @settings_smallTalkDescription.
  ///
  /// In ru, this message translates to:
  /// **'Разрешить небольшие разговоры с Bari'**
  String get settings_smallTalkDescription;

  /// No description provided for @settings_parentZone.
  ///
  /// In ru, this message translates to:
  /// **'Родительская зона'**
  String get settings_parentZone;

  /// No description provided for @settings_parentZoneDescription.
  ///
  /// In ru, this message translates to:
  /// **'Управление одобрениями и настройками'**
  String get settings_parentZoneDescription;

  /// No description provided for @settings_tools.
  ///
  /// In ru, this message translates to:
  /// **'Инструменты'**
  String get settings_tools;

  /// No description provided for @settings_toolsDescription.
  ///
  /// In ru, this message translates to:
  /// **'Калькуляторы и другие инструменты'**
  String get settings_toolsDescription;

  /// No description provided for @settings_exportData.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт данных'**
  String get settings_exportData;

  /// No description provided for @settings_importData.
  ///
  /// In ru, this message translates to:
  /// **'Импорт данных'**
  String get settings_importData;

  /// No description provided for @settings_resetProgress.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить прогресс'**
  String get settings_resetProgress;

  /// No description provided for @settings_resetProgressWarning.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите сбросить весь прогресс? Это действие нельзя отменить.'**
  String get settings_resetProgressWarning;

  /// No description provided for @settings_cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get settings_cancel;

  /// No description provided for @settings_progressReset.
  ///
  /// In ru, this message translates to:
  /// **'Прогресс сброшен'**
  String get settings_progressReset;

  /// No description provided for @settings_enterPinToConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Введите PIN для подтверждения'**
  String get settings_enterPinToConfirm;

  /// No description provided for @settings_wrongPin.
  ///
  /// In ru, this message translates to:
  /// **'Неверный PIN'**
  String get settings_wrongPin;

  /// No description provided for @priceComparisonCalculator_factSaved.
  ///
  /// In ru, this message translates to:
  /// **'Факт сохранён'**
  String get priceComparisonCalculator_factSaved;

  /// No description provided for @twentyFourHourRuleCalculator_enterItemName.
  ///
  /// In ru, this message translates to:
  /// **'Введите название предмета'**
  String get twentyFourHourRuleCalculator_enterItemName;

  /// No description provided for @twentyFourHourRuleCalculator_reminderSet.
  ///
  /// In ru, this message translates to:
  /// **'Напоминание установлено'**
  String get twentyFourHourRuleCalculator_reminderSet;

  /// No description provided for @twentyFourHourRuleCalculator_no.
  ///
  /// In ru, this message translates to:
  /// **'Нет'**
  String get twentyFourHourRuleCalculator_no;

  /// No description provided for @subscriptionsCalculator_no.
  ///
  /// In ru, this message translates to:
  /// **'Нет'**
  String get subscriptionsCalculator_no;

  /// No description provided for @subscriptionsCalculator_repeatDaily.
  ///
  /// In ru, this message translates to:
  /// **'Ежедневно'**
  String get subscriptionsCalculator_repeatDaily;

  /// No description provided for @subscriptionsCalculator_repeatWeekly.
  ///
  /// In ru, this message translates to:
  /// **'Еженедельно'**
  String get subscriptionsCalculator_repeatWeekly;

  /// No description provided for @subscriptionsCalculator_repeatMonthly.
  ///
  /// In ru, this message translates to:
  /// **'Ежемесячно'**
  String get subscriptionsCalculator_repeatMonthly;

  /// No description provided for @subscriptionsCalculator_repeatYearly.
  ///
  /// In ru, this message translates to:
  /// **'Ежегодно'**
  String get subscriptionsCalculator_repeatYearly;

  /// No description provided for @subscriptionsCalculator_enterSubscriptionName.
  ///
  /// In ru, this message translates to:
  /// **'Введите название подписки'**
  String get subscriptionsCalculator_enterSubscriptionName;

  /// No description provided for @calendar_completed.
  ///
  /// In ru, this message translates to:
  /// **'Выполнено'**
  String get calendar_completed;

  /// No description provided for @calendar_edit.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать'**
  String get calendar_edit;

  /// No description provided for @calendar_reschedule.
  ///
  /// In ru, this message translates to:
  /// **'Перенести'**
  String get calendar_reschedule;

  /// No description provided for @calendar_completeNow.
  ///
  /// In ru, this message translates to:
  /// **'Выполнить сейчас'**
  String get calendar_completeNow;

  /// No description provided for @calendar_showTransaction.
  ///
  /// In ru, this message translates to:
  /// **'Показать транзакцию'**
  String get calendar_showTransaction;

  /// No description provided for @calendar_restore.
  ///
  /// In ru, this message translates to:
  /// **'Восстановить'**
  String get calendar_restore;

  /// No description provided for @calendar_eventAlreadyCompleted.
  ///
  /// In ru, this message translates to:
  /// **'Событие уже выполнено'**
  String get calendar_eventAlreadyCompleted;

  /// No description provided for @calendar_noPiggyBanks.
  ///
  /// In ru, this message translates to:
  /// **'Нет копилок'**
  String get calendar_noPiggyBanks;

  /// No description provided for @calendar_eventAlreadyCompletedWithTx.
  ///
  /// In ru, this message translates to:
  /// **'Событие уже выполнено. Транзакция создана.'**
  String get calendar_eventAlreadyCompletedWithTx;

  /// No description provided for @calendar_sentToParentForApproval.
  ///
  /// In ru, this message translates to:
  /// **'Отправлено родителю на одобрение'**
  String get calendar_sentToParentForApproval;

  /// No description provided for @calendar_addedToPiggyBank.
  ///
  /// In ru, this message translates to:
  /// **'добавлено в копилку'**
  String get calendar_addedToPiggyBank;

  /// No description provided for @calendar_eventCompletedWithAmount.
  ///
  /// In ru, this message translates to:
  /// **'Событие выполнено: {amount}'**
  String calendar_eventCompletedWithAmount(String amount);

  /// No description provided for @calendar_planContinues.
  ///
  /// In ru, this message translates to:
  /// **'План продолжается'**
  String get calendar_planContinues;

  /// No description provided for @calendar_cancelEvent.
  ///
  /// In ru, this message translates to:
  /// **'Отменить событие'**
  String get calendar_cancelEvent;

  /// No description provided for @calendar_cancelEventMessage.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите отменить это событие?'**
  String get calendar_cancelEventMessage;

  /// No description provided for @calendar_no.
  ///
  /// In ru, this message translates to:
  /// **'Нет'**
  String get calendar_no;

  /// No description provided for @calendar_yesCancel.
  ///
  /// In ru, this message translates to:
  /// **'Да, отменить'**
  String get calendar_yesCancel;

  /// No description provided for @calendar_wantToReschedule.
  ///
  /// In ru, this message translates to:
  /// **'Хотите перенести событие?'**
  String get calendar_wantToReschedule;

  /// No description provided for @calendar_eventRestored.
  ///
  /// In ru, this message translates to:
  /// **'Событие восстановлено'**
  String get calendar_eventRestored;

  /// No description provided for @calendar_eventUpdated.
  ///
  /// In ru, this message translates to:
  /// **'Событие обновлено'**
  String get calendar_eventUpdated;

  /// No description provided for @calendar_deleteEventConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Удалить событие?'**
  String get calendar_deleteEventConfirm;

  /// No description provided for @calendar_deleteEventSeriesMessage.
  ///
  /// In ru, this message translates to:
  /// **'Удалить всю серию событий?'**
  String get calendar_deleteEventSeriesMessage;

  /// No description provided for @calendar_deleteAllRepeatingConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Все повторяющиеся события будут удалены. Это действие нельзя отменить.'**
  String get calendar_deleteAllRepeatingConfirm;

  /// No description provided for @calendar_undo.
  ///
  /// In ru, this message translates to:
  /// **'Отменить'**
  String get calendar_undo;

  /// No description provided for @calendar_editScopeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Что редактировать?'**
  String get calendar_editScopeTitle;

  /// No description provided for @calendar_editScopeSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Выберите область применения изменений'**
  String get calendar_editScopeSubtitle;

  /// No description provided for @calendar_editThisEventOnly.
  ///
  /// In ru, this message translates to:
  /// **'Только это событие'**
  String get calendar_editThisEventOnly;

  /// No description provided for @calendar_editThisEventOnlyDesc.
  ///
  /// In ru, this message translates to:
  /// **'Изменения коснутся только выбранного события'**
  String get calendar_editThisEventOnlyDesc;

  /// No description provided for @calendar_editAllRepeating.
  ///
  /// In ru, this message translates to:
  /// **'Все повторения'**
  String get calendar_editAllRepeating;

  /// No description provided for @calendar_editAllRepeatingDesc.
  ///
  /// In ru, this message translates to:
  /// **'Изменения применятся ко всем событиям в серии'**
  String get calendar_editAllRepeatingDesc;

  /// No description provided for @calendar_deleteScopeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Что удалить?'**
  String get calendar_deleteScopeTitle;

  /// No description provided for @calendar_deleteScopeSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Выберите область удаления'**
  String get calendar_deleteScopeSubtitle;

  /// No description provided for @calendar_deleteAllRepeatingDesc.
  ///
  /// In ru, this message translates to:
  /// **'Удалены будут все события в серии'**
  String get calendar_deleteAllRepeatingDesc;

  /// No description provided for @calendar_cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get calendar_cancel;

  /// No description provided for @calendar_transactionNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Транзакция не найдена'**
  String get calendar_transactionNotFound;

  /// No description provided for @calendar_transaction.
  ///
  /// In ru, this message translates to:
  /// **'Транзакция'**
  String get calendar_transaction;

  /// No description provided for @calendar_transactionAmount.
  ///
  /// In ru, this message translates to:
  /// **'Сумма'**
  String get calendar_transactionAmount;

  /// No description provided for @calendar_transactionDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата'**
  String get calendar_transactionDate;

  /// No description provided for @calendar_transactionCategory.
  ///
  /// In ru, this message translates to:
  /// **'Категория'**
  String get calendar_transactionCategory;

  /// No description provided for @calendar_transactionNote.
  ///
  /// In ru, this message translates to:
  /// **'Заметка'**
  String get calendar_transactionNote;

  /// No description provided for @deletedEvents_title.
  ///
  /// In ru, this message translates to:
  /// **'Удаленные события'**
  String get deletedEvents_title;

  /// No description provided for @deletedEvents_empty.
  ///
  /// In ru, this message translates to:
  /// **'Корзина пуста'**
  String get deletedEvents_empty;

  /// No description provided for @deletedEvents_count.
  ///
  /// In ru, this message translates to:
  /// **'{count} событий'**
  String deletedEvents_count(int count);

  /// No description provided for @deletedEvents_restore.
  ///
  /// In ru, this message translates to:
  /// **'Восстановить'**
  String get deletedEvents_restore;

  /// No description provided for @deletedEvents_deletePermanent.
  ///
  /// In ru, this message translates to:
  /// **'Удалить навсегда'**
  String get deletedEvents_deletePermanent;

  /// No description provided for @deletedEvents_deletedAt.
  ///
  /// In ru, this message translates to:
  /// **'Удалено:'**
  String get deletedEvents_deletedAt;

  /// No description provided for @deletedEvents_restored.
  ///
  /// In ru, this message translates to:
  /// **'Событие восстановлено'**
  String get deletedEvents_restored;

  /// No description provided for @deletedEvents_deleted.
  ///
  /// In ru, this message translates to:
  /// **'Событие удалено навсегда'**
  String get deletedEvents_deleted;

  /// No description provided for @deletedEvents_permanentDeleteTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить навсегда?'**
  String get deletedEvents_permanentDeleteTitle;

  /// No description provided for @deletedEvents_permanentDeleteMessage.
  ///
  /// In ru, this message translates to:
  /// **'Это действие нельзя отменить. Событие будет удалено без возможности восстановления.'**
  String get deletedEvents_permanentDeleteMessage;

  /// No description provided for @deletedEvents_clearOld.
  ///
  /// In ru, this message translates to:
  /// **'Очистить старые'**
  String get deletedEvents_clearOld;

  /// No description provided for @deletedEvents_clearOldTitle.
  ///
  /// In ru, this message translates to:
  /// **'Очистить старые события?'**
  String get deletedEvents_clearOldTitle;

  /// No description provided for @deletedEvents_clearOldMessage.
  ///
  /// In ru, this message translates to:
  /// **'Удалить события, которые находятся в корзине более 30 дней?'**
  String get deletedEvents_clearOldMessage;

  /// No description provided for @deletedEvents_clearedCount.
  ///
  /// In ru, this message translates to:
  /// **'Удалено {count} событий'**
  String deletedEvents_clearedCount(int count);

  /// No description provided for @deletedEvents_restoreScopeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Что восстановить?'**
  String get deletedEvents_restoreScopeTitle;

  /// No description provided for @deletedEvents_restoreScopeMessage.
  ///
  /// In ru, this message translates to:
  /// **'Выберите область восстановления'**
  String get deletedEvents_restoreScopeMessage;

  /// No description provided for @subscriptions_filter.
  ///
  /// In ru, this message translates to:
  /// **'Фильтр'**
  String get subscriptions_filter;

  /// No description provided for @subscriptions_all.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get subscriptions_all;

  /// No description provided for @subscriptions_income.
  ///
  /// In ru, this message translates to:
  /// **'Доходы'**
  String get subscriptions_income;

  /// No description provided for @subscriptions_expense.
  ///
  /// In ru, this message translates to:
  /// **'Расходы'**
  String get subscriptions_expense;

  /// No description provided for @subscriptions_type.
  ///
  /// In ru, this message translates to:
  /// **'Тип'**
  String get subscriptions_type;

  /// No description provided for @bariChat_title.
  ///
  /// In ru, this message translates to:
  /// **'Чат с Бари'**
  String get bariChat_title;

  /// No description provided for @bariChat_welcomeDefault.
  ///
  /// In ru, this message translates to:
  /// **'Привет! Я Бари, твой помощник в финансовой грамотности. Чем могу помочь?'**
  String get bariChat_welcomeDefault;

  /// No description provided for @bariChat_welcomeCalculator.
  ///
  /// In ru, this message translates to:
  /// **'Привет! Ты используешь калькулятор. Нужна помощь с расчётами?'**
  String get bariChat_welcomeCalculator;

  /// No description provided for @bariChat_welcomePiggyBank.
  ///
  /// In ru, this message translates to:
  /// **'Привет! Говорим про копилку? Расскажи, что хочешь узнать!'**
  String get bariChat_welcomePiggyBank;

  /// No description provided for @bariChat_welcomePlannedEvent.
  ///
  /// In ru, this message translates to:
  /// **'Привет! У тебя запланированное событие. Вопросы по планированию?'**
  String get bariChat_welcomePlannedEvent;

  /// No description provided for @bariChat_welcomeLesson.
  ///
  /// In ru, this message translates to:
  /// **'Привет! Ты проходишь урок. Что-то непонятно? Спрашивай!'**
  String get bariChat_welcomeLesson;

  /// No description provided for @bariChat_welcomeTask.
  ///
  /// In ru, this message translates to:
  /// **'Привет! Поговорим про задание \"{title}\"? Могу помочь разобраться с наградой, временем или сложностью.'**
  String bariChat_welcomeTask(String title);

  /// No description provided for @bariChat_fallbackResponse.
  ///
  /// In ru, this message translates to:
  /// **'Извини, не понял. Попробуй переформулировать вопрос.'**
  String get bariChat_fallbackResponse;

  /// No description provided for @bariChat_source.
  ///
  /// In ru, this message translates to:
  /// **'Источник'**
  String get bariChat_source;

  /// No description provided for @bariChat_close.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get bariChat_close;

  /// No description provided for @bariChat_inputHint.
  ///
  /// In ru, this message translates to:
  /// **'Напиши сообщение...'**
  String get bariChat_inputHint;

  /// No description provided for @bariChat_thinking.
  ///
  /// In ru, this message translates to:
  /// **'Думаю...'**
  String get bariChat_thinking;

  /// No description provided for @bariChat_task.
  ///
  /// In ru, this message translates to:
  /// **'задание'**
  String get bariChat_task;

  /// No description provided for @calculatorsList_title.
  ///
  /// In ru, this message translates to:
  /// **'Калькуляторы'**
  String get calculatorsList_title;

  /// No description provided for @calculatorsList_piggyPlan.
  ///
  /// In ru, this message translates to:
  /// **'Копилка-план'**
  String get calculatorsList_piggyPlan;

  /// No description provided for @calculatorsList_piggyPlanDesc.
  ///
  /// In ru, this message translates to:
  /// **'Сколько откладывать для цели'**
  String get calculatorsList_piggyPlanDesc;

  /// No description provided for @calculatorsList_goalDate.
  ///
  /// In ru, this message translates to:
  /// **'Когда достигну цель'**
  String get calculatorsList_goalDate;

  /// No description provided for @calculatorsList_goalDateDesc.
  ///
  /// In ru, this message translates to:
  /// **'Дата достижения по регулярным взносам'**
  String get calculatorsList_goalDateDesc;

  /// No description provided for @calculatorsList_monthlyBudget.
  ///
  /// In ru, this message translates to:
  /// **'План расходов на месяц'**
  String get calculatorsList_monthlyBudget;

  /// No description provided for @calculatorsList_monthlyBudgetDesc.
  ///
  /// In ru, this message translates to:
  /// **'Лимит и остаток на месяц'**
  String get calculatorsList_monthlyBudgetDesc;

  /// No description provided for @calculatorsList_subscriptions.
  ///
  /// In ru, this message translates to:
  /// **'Подписки и регулярки'**
  String get calculatorsList_subscriptions;

  /// No description provided for @calculatorsList_subscriptionsDesc.
  ///
  /// In ru, this message translates to:
  /// **'Сколько съедают регулярные траты'**
  String get calculatorsList_subscriptionsDesc;

  /// No description provided for @calculatorsList_canIBuy.
  ///
  /// In ru, this message translates to:
  /// **'Хочу купить — можно ли сейчас?'**
  String get calculatorsList_canIBuy;

  /// No description provided for @calculatorsList_canIBuyDesc.
  ///
  /// In ru, this message translates to:
  /// **'Проверка доступности покупки'**
  String get calculatorsList_canIBuyDesc;

  /// No description provided for @calculatorsList_priceComparison.
  ///
  /// In ru, this message translates to:
  /// **'Сравнение цен'**
  String get calculatorsList_priceComparison;

  /// No description provided for @calculatorsList_priceComparisonDesc.
  ///
  /// In ru, this message translates to:
  /// **'Что выгоднее купить'**
  String get calculatorsList_priceComparisonDesc;

  /// No description provided for @calculatorsList_24hRule.
  ///
  /// In ru, this message translates to:
  /// **'Правило 24 часов'**
  String get calculatorsList_24hRule;

  /// No description provided for @calculatorsList_24hRuleDesc.
  ///
  /// In ru, this message translates to:
  /// **'Отложить импульсную покупку'**
  String get calculatorsList_24hRuleDesc;

  /// No description provided for @calculatorsList_budget503020.
  ///
  /// In ru, this message translates to:
  /// **'Бюджет 50/30/20'**
  String get calculatorsList_budget503020;

  /// No description provided for @calculatorsList_budget503020Desc.
  ///
  /// In ru, this message translates to:
  /// **'Распределение дохода'**
  String get calculatorsList_budget503020Desc;

  /// No description provided for @earningsLab_title.
  ///
  /// In ru, this message translates to:
  /// **'Лаборатория заработка'**
  String get earningsLab_title;

  /// No description provided for @earningsLab_explanationSimple.
  ///
  /// In ru, this message translates to:
  /// **'Запланируй задание → выполни его в календаре → получи награду.'**
  String get earningsLab_explanationSimple;

  /// No description provided for @earningsLab_explanationPro.
  ///
  /// In ru, this message translates to:
  /// **'Лаборатория заработка: сначала запланируй задание на дату, затем отметь его выполненным в календаре. Награда будет зачислена автоматически. Планирование помогает не забывать о важных делах.'**
  String get earningsLab_explanationPro;

  /// No description provided for @earningsLab_taskAdded.
  ///
  /// In ru, this message translates to:
  /// **'Задание добавлено!'**
  String get earningsLab_taskAdded;

  /// No description provided for @earningsLab_tabQuick.
  ///
  /// In ru, this message translates to:
  /// **'Быстрые'**
  String get earningsLab_tabQuick;

  /// No description provided for @earningsLab_tabHome.
  ///
  /// In ru, this message translates to:
  /// **'Домашние'**
  String get earningsLab_tabHome;

  /// No description provided for @earningsLab_tabProjects.
  ///
  /// In ru, this message translates to:
  /// **'Проекты'**
  String get earningsLab_tabProjects;

  /// No description provided for @earningsLab_helpAtHome.
  ///
  /// In ru, this message translates to:
  /// **'Помочь по дому'**
  String get earningsLab_helpAtHome;

  /// No description provided for @earningsLab_helpAtHomeDesc.
  ///
  /// In ru, this message translates to:
  /// **'Выбери одно дело: посуда / мусор / пыль / пол / стол. Сделай 10–15 минут и доведи до результата.'**
  String get earningsLab_helpAtHomeDesc;

  /// No description provided for @earningsLab_learnPoem.
  ///
  /// In ru, this message translates to:
  /// **'Выучить стих'**
  String get earningsLab_learnPoem;

  /// No description provided for @earningsLab_learnPoemDesc.
  ///
  /// In ru, this message translates to:
  /// **'Прочитай 3 раза, выучи по строчкам, потом расскажи без подсказок.'**
  String get earningsLab_learnPoemDesc;

  /// No description provided for @earningsLab_cleanRoom.
  ///
  /// In ru, this message translates to:
  /// **'Убрать комнату'**
  String get earningsLab_cleanRoom;

  /// No description provided for @earningsLab_cleanRoomDesc.
  ///
  /// In ru, this message translates to:
  /// **'Наведи порядок 10–15 минут: игрушки на место, стол чистый, мусор выброшен.'**
  String get earningsLab_cleanRoomDesc;

  /// No description provided for @earningsLab_readBook.
  ///
  /// In ru, this message translates to:
  /// **'Прочитать книгу'**
  String get earningsLab_readBook;

  /// No description provided for @earningsLab_readBookDesc.
  ///
  /// In ru, this message translates to:
  /// **'Прочитай главу из интересной книги. Чтение развивает воображение и словарный запас.'**
  String get earningsLab_readBookDesc;

  /// No description provided for @earningsLab_helpCooking.
  ///
  /// In ru, this message translates to:
  /// **'Помочь с готовкой'**
  String get earningsLab_helpCooking;

  /// No description provided for @earningsLab_helpCookingDesc.
  ///
  /// In ru, this message translates to:
  /// **'Помоги родителям приготовить обед или ужин. Научишься готовить простые блюда!'**
  String get earningsLab_helpCookingDesc;

  /// No description provided for @earningsLab_homework.
  ///
  /// In ru, this message translates to:
  /// **'Выполнить домашнее задание'**
  String get earningsLab_homework;

  /// No description provided for @earningsLab_homeworkDesc.
  ///
  /// In ru, this message translates to:
  /// **'Сделай все домашние задания аккуратно и вовремя. Это твоя главная работа!'**
  String get earningsLab_homeworkDesc;

  /// No description provided for @earningsLab_helpShopping.
  ///
  /// In ru, this message translates to:
  /// **'Помочь с покупками'**
  String get earningsLab_helpShopping;

  /// No description provided for @earningsLab_helpShoppingDesc.
  ///
  /// In ru, this message translates to:
  /// **'Сходи с родителями в магазин и помоги нести покупки. Учишься планировать расходы!'**
  String get earningsLab_helpShoppingDesc;

  /// No description provided for @earningsLab_tagLearning.
  ///
  /// In ru, this message translates to:
  /// **'обучение'**
  String get earningsLab_tagLearning;

  /// No description provided for @earningsLab_tagHelp.
  ///
  /// In ru, this message translates to:
  /// **'помощь'**
  String get earningsLab_tagHelp;

  /// No description provided for @earningsLab_tagCreativity.
  ///
  /// In ru, this message translates to:
  /// **'творчество'**
  String get earningsLab_tagCreativity;

  /// No description provided for @rule24h_title.
  ///
  /// In ru, this message translates to:
  /// **'Правило 24 часов'**
  String get rule24h_title;

  /// No description provided for @rule24h_subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Помогает не делать импульсные покупки: отложи решение на сутки и проверь себя ещё раз.'**
  String get rule24h_subtitle;

  /// No description provided for @rule24h_step1.
  ///
  /// In ru, this message translates to:
  /// **'Хочу'**
  String get rule24h_step1;

  /// No description provided for @rule24h_step2.
  ///
  /// In ru, this message translates to:
  /// **'Цена'**
  String get rule24h_step2;

  /// No description provided for @rule24h_step3.
  ///
  /// In ru, this message translates to:
  /// **'Пауза'**
  String get rule24h_step3;

  /// No description provided for @rule24h_wantToBuy.
  ///
  /// In ru, this message translates to:
  /// **'Хочу купить'**
  String get rule24h_wantToBuy;

  /// No description provided for @rule24h_example.
  ///
  /// In ru, this message translates to:
  /// **'Например: наушники'**
  String get rule24h_example;

  /// No description provided for @rule24h_price.
  ///
  /// In ru, this message translates to:
  /// **'Цена'**
  String get rule24h_price;

  /// No description provided for @rule24h_explanation.
  ///
  /// In ru, this message translates to:
  /// **'Если через 24 часа всё ещё хочешь — покупка более осознанная. Если нет — ты сэкономил и прокачал самоконтроль.'**
  String get rule24h_explanation;

  /// No description provided for @rule24h_postpone.
  ///
  /// In ru, this message translates to:
  /// **'Отложить на 24 часа'**
  String get rule24h_postpone;

  /// No description provided for @rule24h_reminderSet.
  ///
  /// In ru, this message translates to:
  /// **'Напоминание установлено. Через 24 часа вернись и проверь желание ещё раз.'**
  String get rule24h_reminderSet;

  /// No description provided for @rule24h_checkAgain.
  ///
  /// In ru, this message translates to:
  /// **'Проверить снова'**
  String get rule24h_checkAgain;

  /// No description provided for @rule24h_dialogTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подтверждение'**
  String get rule24h_dialogTitle;

  /// No description provided for @rule24h_dialogSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Создание напоминания'**
  String get rule24h_dialogSubtitle;

  /// No description provided for @rule24h_dialogContent.
  ///
  /// In ru, this message translates to:
  /// **'Создать напоминание через 24 часа для проверки желания купить \"{itemName}\"?'**
  String rule24h_dialogContent(String itemName);

  /// No description provided for @rule24h_reminderIn24h.
  ///
  /// In ru, this message translates to:
  /// **'Напоминание придет через 24 часа'**
  String get rule24h_reminderIn24h;

  /// No description provided for @rule24h_eventName.
  ///
  /// In ru, this message translates to:
  /// **'Проверка желания: {itemName}'**
  String rule24h_eventName(String itemName);

  /// No description provided for @rule24h_checkTitle.
  ///
  /// In ru, this message translates to:
  /// **'Проверка желания'**
  String get rule24h_checkTitle;

  /// No description provided for @rule24h_checkSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Прошло 24 часа'**
  String get rule24h_checkSubtitle;

  /// No description provided for @rule24h_stillWant.
  ///
  /// In ru, this message translates to:
  /// **'Хочешь ещё купить это?'**
  String get rule24h_stillWant;

  /// No description provided for @rule24h_yes.
  ///
  /// In ru, this message translates to:
  /// **'Да'**
  String get rule24h_yes;

  /// No description provided for @budget503020_title.
  ///
  /// In ru, this message translates to:
  /// **'Бюджет 50/30/20'**
  String get budget503020_title;

  /// No description provided for @budget503020_subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Раздели доход на 3 части: нужное, желания и накопления.'**
  String get budget503020_subtitle;

  /// No description provided for @budget503020_step1.
  ///
  /// In ru, this message translates to:
  /// **'Доход'**
  String get budget503020_step1;

  /// No description provided for @budget503020_step2.
  ///
  /// In ru, this message translates to:
  /// **'Распределение'**
  String get budget503020_step2;

  /// No description provided for @budget503020_step3.
  ///
  /// In ru, this message translates to:
  /// **'Копилки'**
  String get budget503020_step3;

  /// No description provided for @budget503020_incomeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Мой доход за месяц'**
  String get budget503020_incomeLabel;

  /// No description provided for @budget503020_needs50.
  ///
  /// In ru, this message translates to:
  /// **'Нужное (50%)'**
  String get budget503020_needs50;

  /// No description provided for @budget503020_wants30.
  ///
  /// In ru, this message translates to:
  /// **'Желания (30%)'**
  String get budget503020_wants30;

  /// No description provided for @budget503020_savings20.
  ///
  /// In ru, this message translates to:
  /// **'Коплю (20%)'**
  String get budget503020_savings20;

  /// No description provided for @budget503020_tip.
  ///
  /// In ru, this message translates to:
  /// **'Совет: если хочешь быстрее копить — попробуй начать с 10% в накопления и постепенно увеличивать.'**
  String get budget503020_tip;

  /// No description provided for @budget503020_createPiggyBanks.
  ///
  /// In ru, this message translates to:
  /// **'Создать 3 копилки'**
  String get budget503020_createPiggyBanks;

  /// No description provided for @budget503020_dialogTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подтверждение'**
  String get budget503020_dialogTitle;

  /// No description provided for @budget503020_dialogSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Создание копилок по правилу 50/30/20'**
  String get budget503020_dialogSubtitle;

  /// No description provided for @priceComparison_title.
  ///
  /// In ru, this message translates to:
  /// **'Сравнение цен'**
  String get priceComparison_title;

  /// No description provided for @priceComparison_subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Сравни два варианта и узнай, какой выгоднее по цене за единицу.'**
  String get priceComparison_subtitle;

  /// No description provided for @priceComparison_step1.
  ///
  /// In ru, this message translates to:
  /// **'Вариант A'**
  String get priceComparison_step1;

  /// No description provided for @priceComparison_step2.
  ///
  /// In ru, this message translates to:
  /// **'Вариант B'**
  String get priceComparison_step2;

  /// No description provided for @priceComparison_step3.
  ///
  /// In ru, this message translates to:
  /// **'Итог'**
  String get priceComparison_step3;

  /// No description provided for @priceComparison_priceA.
  ///
  /// In ru, this message translates to:
  /// **'Цена A'**
  String get priceComparison_priceA;

  /// No description provided for @priceComparison_quantityA.
  ///
  /// In ru, this message translates to:
  /// **'Количество / вес A'**
  String get priceComparison_quantityA;

  /// No description provided for @priceComparison_priceB.
  ///
  /// In ru, this message translates to:
  /// **'Цена B'**
  String get priceComparison_priceB;

  /// No description provided for @priceComparison_quantityB.
  ///
  /// In ru, this message translates to:
  /// **'Количество / вес B'**
  String get priceComparison_quantityB;

  /// No description provided for @priceComparison_result.
  ///
  /// In ru, this message translates to:
  /// **'Итог'**
  String get priceComparison_result;

  /// No description provided for @priceComparison_pricePerUnitA.
  ///
  /// In ru, this message translates to:
  /// **'Цена за 1 единицу A'**
  String get priceComparison_pricePerUnitA;

  /// No description provided for @priceComparison_pricePerUnitB.
  ///
  /// In ru, this message translates to:
  /// **'Цена за 1 единицу B'**
  String get priceComparison_pricePerUnitB;

  /// No description provided for @priceComparison_betterOption.
  ///
  /// In ru, this message translates to:
  /// **'Выгоднее: вариант {option} (экономия ~{percent}%)'**
  String priceComparison_betterOption(String option, String percent);

  /// No description provided for @priceComparison_saveForBari.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить вывод для Бари'**
  String get priceComparison_saveForBari;

  /// No description provided for @subscriptions_title.
  ///
  /// In ru, this message translates to:
  /// **'Подписки и регулярки'**
  String get subscriptions_title;

  /// No description provided for @subscriptions_regular.
  ///
  /// In ru, this message translates to:
  /// **'Регулярка'**
  String get subscriptions_regular;

  /// No description provided for @calendar_today.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get calendar_today;

  /// No description provided for @calendar_noEvents.
  ///
  /// In ru, this message translates to:
  /// **'Нет событий'**
  String get calendar_noEvents;

  /// No description provided for @calendar_eventsCount.
  ///
  /// In ru, this message translates to:
  /// **'{count} {events}'**
  String calendar_eventsCount(int count, String events);

  /// No description provided for @calendar_event.
  ///
  /// In ru, this message translates to:
  /// **'событие'**
  String get calendar_event;

  /// No description provided for @calendar_events234.
  ///
  /// In ru, this message translates to:
  /// **'события'**
  String get calendar_events234;

  /// No description provided for @calendar_events5plus.
  ///
  /// In ru, this message translates to:
  /// **'событий'**
  String get calendar_events5plus;

  /// No description provided for @calendar_freeDay.
  ///
  /// In ru, this message translates to:
  /// **'Свободный день'**
  String get calendar_freeDay;

  /// No description provided for @calendar_noEventsOnDay.
  ///
  /// In ru, this message translates to:
  /// **'На этот день ничего не запланировано.\nМожет, самое время что-то добавить?'**
  String get calendar_noEventsOnDay;

  /// No description provided for @calendar_startPlanning.
  ///
  /// In ru, this message translates to:
  /// **'Начни планировать! 🚀'**
  String get calendar_startPlanning;

  /// No description provided for @calendar_createFirstEvent.
  ///
  /// In ru, this message translates to:
  /// **'Создай первое событие — так проще копить и не забывать о важном'**
  String get calendar_createFirstEvent;

  /// No description provided for @calendar_createFirstPlan.
  ///
  /// In ru, this message translates to:
  /// **'Создать первый план'**
  String get calendar_createFirstPlan;

  /// No description provided for @calendar_addEvent.
  ///
  /// In ru, this message translates to:
  /// **'Добавить событие'**
  String get calendar_addEvent;

  /// No description provided for @calendar_income.
  ///
  /// In ru, this message translates to:
  /// **'Доходы'**
  String get calendar_income;

  /// No description provided for @calendar_expense.
  ///
  /// In ru, this message translates to:
  /// **'Расходы'**
  String get calendar_expense;

  /// No description provided for @calendar_done.
  ///
  /// In ru, this message translates to:
  /// **'Выполнено'**
  String get calendar_done;

  /// No description provided for @calendar_confirmCompletion.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить выполнение'**
  String get calendar_confirmCompletion;

  /// No description provided for @calendar_amount.
  ///
  /// In ru, this message translates to:
  /// **'Сумма'**
  String get calendar_amount;

  /// No description provided for @calendar_confirm.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить'**
  String get calendar_confirm;

  /// No description provided for @calendar_rescheduleEvent.
  ///
  /// In ru, this message translates to:
  /// **'Перенести событие'**
  String get calendar_rescheduleEvent;

  /// No description provided for @calendar_dateAndTime.
  ///
  /// In ru, this message translates to:
  /// **'Дата и время'**
  String get calendar_dateAndTime;

  /// No description provided for @calendar_notification.
  ///
  /// In ru, this message translates to:
  /// **'Уведомление'**
  String get calendar_notification;

  /// No description provided for @calendar_move.
  ///
  /// In ru, this message translates to:
  /// **'Перенести'**
  String get calendar_move;

  /// No description provided for @calendar_whereToAdd.
  ///
  /// In ru, this message translates to:
  /// **'Куда добавить {amount}?'**
  String calendar_whereToAdd(String amount);

  /// No description provided for @calendar_toWallet.
  ///
  /// In ru, this message translates to:
  /// **'В кошелёк'**
  String get calendar_toWallet;

  /// No description provided for @calendar_availableForSpending.
  ///
  /// In ru, this message translates to:
  /// **'Доступно для трат'**
  String get calendar_availableForSpending;

  /// No description provided for @calendar_toPiggyBank.
  ///
  /// In ru, this message translates to:
  /// **'В копилку'**
  String get calendar_toPiggyBank;

  /// No description provided for @calendar_forGoal.
  ///
  /// In ru, this message translates to:
  /// **'На цель'**
  String get calendar_forGoal;

  /// No description provided for @calendar_selectPiggyBank.
  ///
  /// In ru, this message translates to:
  /// **'Выбери копилку'**
  String get calendar_selectPiggyBank;

  /// No description provided for @calendar_eventCompleted.
  ///
  /// In ru, this message translates to:
  /// **'Событие выполнено! +15 XP'**
  String get calendar_eventCompleted;

  /// No description provided for @calendar_eventCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Событие отменено'**
  String get calendar_eventCancelled;

  /// No description provided for @calendar_eventDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Событие удалено'**
  String get calendar_eventDeleted;

  /// No description provided for @calendar_eventCompletedXp.
  ///
  /// In ru, this message translates to:
  /// **'Событие выполнено! +15 XP'**
  String get calendar_eventCompletedXp;

  /// No description provided for @calendar_invalidAmount.
  ///
  /// In ru, this message translates to:
  /// **'Введите корректную сумму'**
  String get calendar_invalidAmount;

  /// No description provided for @calendar_date.
  ///
  /// In ru, this message translates to:
  /// **'Дата'**
  String get calendar_date;

  /// No description provided for @calendar_time.
  ///
  /// In ru, this message translates to:
  /// **'Время'**
  String get calendar_time;

  /// No description provided for @calendar_everyDay.
  ///
  /// In ru, this message translates to:
  /// **'Каждый день'**
  String get calendar_everyDay;

  /// No description provided for @calendar_everyWeek.
  ///
  /// In ru, this message translates to:
  /// **'Каждую неделю'**
  String get calendar_everyWeek;

  /// No description provided for @calendar_everyMonth.
  ///
  /// In ru, this message translates to:
  /// **'Каждый месяц'**
  String get calendar_everyMonth;

  /// No description provided for @calendar_everyYear.
  ///
  /// In ru, this message translates to:
  /// **'Каждый год'**
  String get calendar_everyYear;

  /// No description provided for @calendar_repeat.
  ///
  /// In ru, this message translates to:
  /// **'Повтор'**
  String get calendar_repeat;

  /// No description provided for @calendar_noRepeat.
  ///
  /// In ru, this message translates to:
  /// **'Нет'**
  String get calendar_noRepeat;

  /// No description provided for @calendar_deleteAction.
  ///
  /// In ru, this message translates to:
  /// **'Это действие нельзя отменить.'**
  String get calendar_deleteAction;

  /// No description provided for @calendar_week.
  ///
  /// In ru, this message translates to:
  /// **'Неделя'**
  String get calendar_week;

  /// No description provided for @calendar_month.
  ///
  /// In ru, this message translates to:
  /// **'Месяц'**
  String get calendar_month;

  /// No description provided for @parentZone_title.
  ///
  /// In ru, this message translates to:
  /// **'Родительская зона'**
  String get parentZone_title;

  /// No description provided for @parentZone_approvals.
  ///
  /// In ru, this message translates to:
  /// **'Ожидают одобрения'**
  String get parentZone_approvals;

  /// No description provided for @parentZone_statistics.
  ///
  /// In ru, this message translates to:
  /// **'Статистика'**
  String get parentZone_statistics;

  /// No description provided for @parentZone_settings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get parentZone_settings;

  /// No description provided for @parentZone_pinMustBe4Digits.
  ///
  /// In ru, this message translates to:
  /// **'PIN должен содержать 4 цифры'**
  String get parentZone_pinMustBe4Digits;

  /// No description provided for @parentZone_wrongPin.
  ///
  /// In ru, this message translates to:
  /// **'Неверный PIN'**
  String get parentZone_wrongPin;

  /// No description provided for @parentZone_pinChanged.
  ///
  /// In ru, this message translates to:
  /// **'PIN изменён'**
  String get parentZone_pinChanged;

  /// No description provided for @parentZone_premiumUnlocked.
  ///
  /// In ru, this message translates to:
  /// **'Премиум разблокирован'**
  String get parentZone_premiumUnlocked;

  /// No description provided for @parentZone_resetData.
  ///
  /// In ru, this message translates to:
  /// **'Сброс данных'**
  String get parentZone_resetData;

  /// No description provided for @parentZone_resetWarning.
  ///
  /// In ru, this message translates to:
  /// **'ВНИМАНИЕ! Это действие удалит ВСЕ данные приложения.'**
  String get parentZone_resetWarning;

  /// No description provided for @parentZone_enterPinToConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Введите PIN для подтверждения:'**
  String get parentZone_enterPinToConfirm;

  /// No description provided for @parentZone_pin.
  ///
  /// In ru, this message translates to:
  /// **'PIN'**
  String get parentZone_pin;

  /// No description provided for @parentZone_reset.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить'**
  String get parentZone_reset;

  /// No description provided for @parentZone_allDataDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Все данные удалены'**
  String get parentZone_allDataDeleted;

  /// No description provided for @parentZone_resetError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка сброса: {error}'**
  String parentZone_resetError(String error);

  /// No description provided for @parentZone_login.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get parentZone_login;

  /// No description provided for @parentZone_unlockPremium.
  ///
  /// In ru, this message translates to:
  /// **'Разблокировать премиум'**
  String get parentZone_unlockPremium;

  /// No description provided for @parentZone_edit.
  ///
  /// In ru, this message translates to:
  /// **'Изменить'**
  String get parentZone_edit;

  /// No description provided for @parentZone_close.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get parentZone_close;

  /// No description provided for @parentZone_earningsApproved.
  ///
  /// In ru, this message translates to:
  /// **'Заработок одобрен'**
  String get parentZone_earningsApproved;

  /// No description provided for @parentZone_earningsRejected.
  ///
  /// In ru, this message translates to:
  /// **'Заработок отклонён'**
  String get parentZone_earningsRejected;

  /// No description provided for @exportImport_title.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт/Импорт'**
  String get exportImport_title;

  /// No description provided for @exportImport_exportData.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт данных'**
  String get exportImport_exportData;

  /// No description provided for @exportImport_exportDescription.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить все данные в JSON файл'**
  String get exportImport_exportDescription;

  /// No description provided for @exportImport_export.
  ///
  /// In ru, this message translates to:
  /// **'Экспортировать'**
  String get exportImport_export;

  /// No description provided for @exportImport_importData.
  ///
  /// In ru, this message translates to:
  /// **'Импорт данных'**
  String get exportImport_importData;

  /// No description provided for @exportImport_importDescription.
  ///
  /// In ru, this message translates to:
  /// **'Загрузить данные из JSON файла'**
  String get exportImport_importDescription;

  /// No description provided for @exportImport_import.
  ///
  /// In ru, this message translates to:
  /// **'Импортировать'**
  String get exportImport_import;

  /// No description provided for @exportImport_dataCopied.
  ///
  /// In ru, this message translates to:
  /// **'Данные скопированы в буфер обмена'**
  String get exportImport_dataCopied;

  /// No description provided for @exportImport_exportError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка экспорта: {error}'**
  String exportImport_exportError(String error);

  /// No description provided for @exportImport_importSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Данные успешно импортированы'**
  String get exportImport_importSuccess;

  /// No description provided for @exportImport_importError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка импорта'**
  String get exportImport_importError;

  /// No description provided for @exportImport_importErrorDetails.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось импортировать данные:\n{error}'**
  String exportImport_importErrorDetails(String error);

  /// No description provided for @exportImport_pasteJson.
  ///
  /// In ru, this message translates to:
  /// **'Вставьте JSON данные'**
  String get exportImport_pasteJson;

  /// No description provided for @minitrainers_result.
  ///
  /// In ru, this message translates to:
  /// **'Результат'**
  String get minitrainers_result;

  /// No description provided for @minitrainers_correctAnswers.
  ///
  /// In ru, this message translates to:
  /// **'Правильных ответов: {score}/{total}\n+{xp} XP'**
  String minitrainers_correctAnswers(int score, int total, int xp);

  /// No description provided for @minitrainers_great.
  ///
  /// In ru, this message translates to:
  /// **'Отлично!'**
  String get minitrainers_great;

  /// No description provided for @minitrainers_findExtraPurchase.
  ///
  /// In ru, this message translates to:
  /// **'Найди лишнюю покупку'**
  String get minitrainers_findExtraPurchase;

  /// No description provided for @minitrainers_answer.
  ///
  /// In ru, this message translates to:
  /// **'Ответить'**
  String get minitrainers_answer;

  /// No description provided for @minitrainers_xpEarned.
  ///
  /// In ru, this message translates to:
  /// **'+{xp} XP'**
  String minitrainers_xpEarned(int xp);

  /// No description provided for @minitrainers_buildBudget.
  ///
  /// In ru, this message translates to:
  /// **'Собери бюджет'**
  String get minitrainers_buildBudget;

  /// No description provided for @minitrainers_check.
  ///
  /// In ru, this message translates to:
  /// **'Проверить'**
  String get minitrainers_check;

  /// No description provided for @minitrainers_wellDone.
  ///
  /// In ru, this message translates to:
  /// **'Молодец!'**
  String get minitrainers_wellDone;

  /// No description provided for @minitrainers_xp15.
  ///
  /// In ru, this message translates to:
  /// **'+15 XP'**
  String get minitrainers_xp15;

  /// No description provided for @minitrainers_discountOrTrap.
  ///
  /// In ru, this message translates to:
  /// **'Скидка или ловушка?'**
  String get minitrainers_discountOrTrap;

  /// No description provided for @minitrainers_yes.
  ///
  /// In ru, this message translates to:
  /// **'Да'**
  String get minitrainers_yes;

  /// No description provided for @minitrainers_no.
  ///
  /// In ru, this message translates to:
  /// **'Нет'**
  String get minitrainers_no;

  /// No description provided for @minitrainers_correct.
  ///
  /// In ru, this message translates to:
  /// **'Правильно!'**
  String get minitrainers_correct;

  /// No description provided for @minitrainers_goodTry.
  ///
  /// In ru, this message translates to:
  /// **'Хорошая попытка'**
  String get minitrainers_goodTry;

  /// No description provided for @calculators_3PiggyBanksCreated.
  ///
  /// In ru, this message translates to:
  /// **'3 копилки созданы'**
  String get calculators_3PiggyBanksCreated;

  /// No description provided for @rule24h_xp50.
  ///
  /// In ru, this message translates to:
  /// **'🎉 +50 XP за самоконтроль!'**
  String get rule24h_xp50;

  /// No description provided for @subscriptions_frequency.
  ///
  /// In ru, this message translates to:
  /// **'Частота'**
  String get subscriptions_frequency;

  /// No description provided for @statistics_title.
  ///
  /// In ru, this message translates to:
  /// **'Статистика'**
  String get statistics_title;

  /// No description provided for @calculators_nDaysSavings.
  ///
  /// In ru, this message translates to:
  /// **'Накопления за N дней'**
  String get calculators_nDaysSavings;

  /// No description provided for @calculators_weeklySavings.
  ///
  /// In ru, this message translates to:
  /// **'Накопления по неделям'**
  String get calculators_weeklySavings;

  /// No description provided for @calculators_piggyGoal.
  ///
  /// In ru, this message translates to:
  /// **'Цель копилки'**
  String get calculators_piggyGoal;

  /// No description provided for @earningsLab_schedule.
  ///
  /// In ru, this message translates to:
  /// **'Запланировать'**
  String get earningsLab_schedule;

  /// No description provided for @recommendations_newTip.
  ///
  /// In ru, this message translates to:
  /// **'Новый совет'**
  String get recommendations_newTip;

  /// No description provided for @earningsHistory_title.
  ///
  /// In ru, this message translates to:
  /// **'История заработка'**
  String get earningsHistory_title;

  /// No description provided for @earningsHistory_all.
  ///
  /// In ru, this message translates to:
  /// **'Всё'**
  String get earningsHistory_all;

  /// No description provided for @calendarForecast_7days.
  ///
  /// In ru, this message translates to:
  /// **'7 дн'**
  String get calendarForecast_7days;

  /// No description provided for @calendarForecast_30days.
  ///
  /// In ru, this message translates to:
  /// **'30 дн'**
  String get calendarForecast_30days;

  /// No description provided for @calendarForecast_90days.
  ///
  /// In ru, this message translates to:
  /// **'90 дн'**
  String get calendarForecast_90days;

  /// No description provided for @calendarForecast_year.
  ///
  /// In ru, this message translates to:
  /// **'Год'**
  String get calendarForecast_year;

  /// No description provided for @calendarForecast_summary.
  ///
  /// In ru, this message translates to:
  /// **'Сводка'**
  String get calendarForecast_summary;

  /// No description provided for @calendarForecast_categories.
  ///
  /// In ru, this message translates to:
  /// **'Категории'**
  String get calendarForecast_categories;

  /// No description provided for @calendarForecast_dates.
  ///
  /// In ru, this message translates to:
  /// **'Даты'**
  String get calendarForecast_dates;

  /// No description provided for @calendarForecast_month.
  ///
  /// In ru, this message translates to:
  /// **'Месяц'**
  String get calendarForecast_month;

  /// No description provided for @calendarForecast_all.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get calendarForecast_all;

  /// No description provided for @calendarForecast_income.
  ///
  /// In ru, this message translates to:
  /// **'Доходы'**
  String get calendarForecast_income;

  /// No description provided for @calendarForecast_expenses.
  ///
  /// In ru, this message translates to:
  /// **'Расходы'**
  String get calendarForecast_expenses;

  /// No description provided for @calendarForecast_large.
  ///
  /// In ru, this message translates to:
  /// **'Крупные'**
  String get calendarForecast_large;

  /// No description provided for @planEvent_amount.
  ///
  /// In ru, this message translates to:
  /// **'Сумма'**
  String get planEvent_amount;

  /// No description provided for @planEvent_nameOptional.
  ///
  /// In ru, this message translates to:
  /// **'Название (необязательно)'**
  String get planEvent_nameOptional;

  /// No description provided for @planEvent_category.
  ///
  /// In ru, this message translates to:
  /// **'Категория'**
  String get planEvent_category;

  /// No description provided for @planEvent_date.
  ///
  /// In ru, this message translates to:
  /// **'Дата'**
  String get planEvent_date;

  /// No description provided for @planEvent_time.
  ///
  /// In ru, this message translates to:
  /// **'Время'**
  String get planEvent_time;

  /// No description provided for @planEvent_repeat.
  ///
  /// In ru, this message translates to:
  /// **'Повтор'**
  String get planEvent_repeat;

  /// No description provided for @planEvent_notification.
  ///
  /// In ru, this message translates to:
  /// **'Уведомление'**
  String get planEvent_notification;

  /// No description provided for @planEvent_remindBefore.
  ///
  /// In ru, this message translates to:
  /// **'Напомнить за'**
  String get planEvent_remindBefore;

  /// No description provided for @planEvent_atMoment.
  ///
  /// In ru, this message translates to:
  /// **'В момент'**
  String get planEvent_atMoment;

  /// No description provided for @planEvent_15minutes.
  ///
  /// In ru, this message translates to:
  /// **'За 15 минут'**
  String get planEvent_15minutes;

  /// No description provided for @planEvent_30minutes.
  ///
  /// In ru, this message translates to:
  /// **'За 30 минут'**
  String get planEvent_30minutes;

  /// No description provided for @planEvent_1hour.
  ///
  /// In ru, this message translates to:
  /// **'За 1 час'**
  String get planEvent_1hour;

  /// No description provided for @planEvent_1day.
  ///
  /// In ru, this message translates to:
  /// **'За 1 день'**
  String get planEvent_1day;

  /// No description provided for @planEvent_eventChanged.
  ///
  /// In ru, this message translates to:
  /// **'Событие изменено'**
  String get planEvent_eventChanged;

  /// No description provided for @planEvent_repeatingEventWarning.
  ///
  /// In ru, this message translates to:
  /// **'Повторяющееся событие'**
  String get planEvent_repeatingEventWarning;

  /// No description provided for @planEvent_repeatingEventDescription.
  ///
  /// In ru, this message translates to:
  /// **'Это событие является частью повторяющейся серии. Изменения применятся ко всем будущим событиям.'**
  String get planEvent_repeatingEventDescription;

  /// No description provided for @calendar_editEvent.
  ///
  /// In ru, this message translates to:
  /// **'Изменить событие'**
  String get calendar_editEvent;

  /// No description provided for @calendar_planEvent.
  ///
  /// In ru, this message translates to:
  /// **'Запланировать событие'**
  String get calendar_planEvent;

  /// No description provided for @planEvent_eventType.
  ///
  /// In ru, this message translates to:
  /// **'Тип события'**
  String get planEvent_eventType;

  /// No description provided for @transaction_income.
  ///
  /// In ru, this message translates to:
  /// **'Доход'**
  String get transaction_income;

  /// No description provided for @transaction_expense.
  ///
  /// In ru, this message translates to:
  /// **'Расход'**
  String get transaction_expense;

  /// No description provided for @category_food.
  ///
  /// In ru, this message translates to:
  /// **'Еда'**
  String get category_food;

  /// No description provided for @category_transport.
  ///
  /// In ru, this message translates to:
  /// **'Транспорт'**
  String get category_transport;

  /// No description provided for @category_entertainment.
  ///
  /// In ru, this message translates to:
  /// **'Развлечения'**
  String get category_entertainment;

  /// No description provided for @category_other.
  ///
  /// In ru, this message translates to:
  /// **'Другое'**
  String get category_other;

  /// No description provided for @minitrainers_60seconds.
  ///
  /// In ru, this message translates to:
  /// **'60 секунд'**
  String get minitrainers_60seconds;

  /// No description provided for @earningsLab_wrongPin.
  ///
  /// In ru, this message translates to:
  /// **'Неверный PIN. Нужно одобрение родителя.'**
  String get earningsLab_wrongPin;

  /// No description provided for @earningsLab_noPiggyBanks.
  ///
  /// In ru, this message translates to:
  /// **'Нет копилок. Сначала создай копилку.'**
  String get earningsLab_noPiggyBanks;

  /// No description provided for @earningsLab_sentForApproval.
  ///
  /// In ru, this message translates to:
  /// **'Отправлено родителю на одобрение'**
  String get earningsLab_sentForApproval;

  /// No description provided for @earningsLab_amountCannotBeNegative.
  ///
  /// In ru, this message translates to:
  /// **'Сумма не может быть отрицательной'**
  String get earningsLab_amountCannotBeNegative;

  /// No description provided for @earningsLab_wallet.
  ///
  /// In ru, this message translates to:
  /// **'Кошелёк'**
  String get earningsLab_wallet;

  /// No description provided for @earningsLab_piggyBank.
  ///
  /// In ru, this message translates to:
  /// **'Копилка'**
  String get earningsLab_piggyBank;

  /// No description provided for @earningsLab_no.
  ///
  /// In ru, this message translates to:
  /// **'Нет'**
  String get earningsLab_no;

  /// No description provided for @earningsLab_daily.
  ///
  /// In ru, this message translates to:
  /// **'Ежедневно'**
  String get earningsLab_daily;

  /// No description provided for @earningsLab_weekly.
  ///
  /// In ru, this message translates to:
  /// **'Еженедельно'**
  String get earningsLab_weekly;

  /// No description provided for @earningsLab_reminder.
  ///
  /// In ru, this message translates to:
  /// **'Напоминание'**
  String get earningsLab_reminder;

  /// No description provided for @earningsLab_selectPiggyForReward.
  ///
  /// In ru, this message translates to:
  /// **'Выбери копилку для награды'**
  String get earningsLab_selectPiggyForReward;

  /// No description provided for @earningsLab_createPlan.
  ///
  /// In ru, this message translates to:
  /// **'Создать план'**
  String get earningsLab_createPlan;

  /// No description provided for @earningsLab_discussWithBari.
  ///
  /// In ru, this message translates to:
  /// **'Обсудить с Бари'**
  String get earningsLab_discussWithBari;

  /// No description provided for @earningsLab_parentApprovalRequired.
  ///
  /// In ru, this message translates to:
  /// **'Нужно одобрение родителя'**
  String get earningsLab_parentApprovalRequired;

  /// No description provided for @earningsLab_fillRequiredFields.
  ///
  /// In ru, this message translates to:
  /// **'Заполните обязательные поля'**
  String get earningsLab_fillRequiredFields;

  /// No description provided for @earningsLab_completed.
  ///
  /// In ru, this message translates to:
  /// **'Выполнено: {title}'**
  String earningsLab_completed(String title);

  /// No description provided for @earningsLab_howMuchEarned.
  ///
  /// In ru, this message translates to:
  /// **'Сколько получил?'**
  String get earningsLab_howMuchEarned;

  /// No description provided for @earningsLab_whatWasDifficult.
  ///
  /// In ru, this message translates to:
  /// **'Что было сложным?'**
  String get earningsLab_whatWasDifficult;

  /// No description provided for @earningsLab_addCustomTask.
  ///
  /// In ru, this message translates to:
  /// **'Добавить своё задание'**
  String get earningsLab_addCustomTask;

  /// No description provided for @earningsLab_canRepeat.
  ///
  /// In ru, this message translates to:
  /// **'Можно повторять'**
  String get earningsLab_canRepeat;

  /// No description provided for @earningsLab_requiresParent.
  ///
  /// In ru, this message translates to:
  /// **'Нужен родитель'**
  String get earningsLab_requiresParent;

  /// No description provided for @earningsLab_taskName.
  ///
  /// In ru, this message translates to:
  /// **'Название задания *'**
  String get earningsLab_taskName;

  /// No description provided for @earningsLab_taskNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: Помочь бабушке'**
  String get earningsLab_taskNameHint;

  /// No description provided for @earningsLab_description.
  ///
  /// In ru, this message translates to:
  /// **'Описание'**
  String get earningsLab_description;

  /// No description provided for @earningsLab_descriptionHint.
  ///
  /// In ru, this message translates to:
  /// **'Что нужно сделать?'**
  String get earningsLab_descriptionHint;

  /// No description provided for @earningsLab_descriptionOptional.
  ///
  /// In ru, this message translates to:
  /// **'Описание (необязательно)'**
  String get earningsLab_descriptionOptional;

  /// No description provided for @earningsLab_descriptionOptionalHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: что именно нужно сделать'**
  String get earningsLab_descriptionOptionalHint;

  /// No description provided for @earningsLab_time.
  ///
  /// In ru, this message translates to:
  /// **'Время *'**
  String get earningsLab_time;

  /// No description provided for @earningsLab_timeHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: 30 мин'**
  String get earningsLab_timeHint;

  /// No description provided for @earningsLab_reward.
  ///
  /// In ru, this message translates to:
  /// **'Награда'**
  String get earningsLab_reward;

  /// No description provided for @earningsLab_xp.
  ///
  /// In ru, this message translates to:
  /// **'XP'**
  String get earningsLab_xp;

  /// No description provided for @earningsLab_difficulty.
  ///
  /// In ru, this message translates to:
  /// **'Сложность'**
  String get earningsLab_difficulty;

  /// No description provided for @earningsLab_repeat.
  ///
  /// In ru, this message translates to:
  /// **'Повтор'**
  String get earningsLab_repeat;

  /// No description provided for @earningsLab_rewardMustBePositive.
  ///
  /// In ru, this message translates to:
  /// **'Награда должна быть больше нуля'**
  String get earningsLab_rewardMustBePositive;

  /// No description provided for @earningsLab_taskDescription.
  ///
  /// In ru, this message translates to:
  /// **'Описание не задано'**
  String get earningsLab_taskDescription;

  /// No description provided for @earningsLab_rewardHelper.
  ///
  /// In ru, this message translates to:
  /// **'Сколько ты получишь за выполнение'**
  String get earningsLab_rewardHelper;

  /// No description provided for @earningsLab_taskNameRequired.
  ///
  /// In ru, this message translates to:
  /// **'Напиши название'**
  String get earningsLab_taskNameRequired;

  /// No description provided for @settings_aiModelGpt4oMini.
  ///
  /// In ru, this message translates to:
  /// **'GPT-4o Mini (быстрый)'**
  String get settings_aiModelGpt4oMini;

  /// No description provided for @settings_aiModelGpt4o.
  ///
  /// In ru, this message translates to:
  /// **'GPT-4o (умный)'**
  String get settings_aiModelGpt4o;

  /// No description provided for @settings_aiModelGpt4Turbo.
  ///
  /// In ru, this message translates to:
  /// **'GPT-4 Turbo'**
  String get settings_aiModelGpt4Turbo;

  /// No description provided for @settings_aiModelGpt35.
  ///
  /// In ru, this message translates to:
  /// **'GPT-3.5 (дешёвый)'**
  String get settings_aiModelGpt35;

  /// Заголовок секции Gemini Nano
  ///
  /// In ru, this message translates to:
  /// **'AI на устройстве (Gemini Nano)'**
  String get settings_geminiNano;

  /// No description provided for @settings_geminiNanoDescription.
  ///
  /// In ru, this message translates to:
  /// **'Бесплатный AI, который работает без интернета'**
  String get settings_geminiNanoDescription;

  /// No description provided for @settings_geminiNanoStatus.
  ///
  /// In ru, this message translates to:
  /// **'Статус'**
  String get settings_geminiNanoStatus;

  /// No description provided for @settings_geminiNanoAvailable.
  ///
  /// In ru, this message translates to:
  /// **'Доступен'**
  String get settings_geminiNanoAvailable;

  /// No description provided for @settings_geminiNanoNotAvailable.
  ///
  /// In ru, this message translates to:
  /// **'Недоступен на этом устройстве'**
  String get settings_geminiNanoNotAvailable;

  /// No description provided for @settings_geminiNanoDownloaded.
  ///
  /// In ru, this message translates to:
  /// **'Скачан и готов к работе'**
  String get settings_geminiNanoDownloaded;

  /// No description provided for @settings_geminiNanoNotDownloaded.
  ///
  /// In ru, this message translates to:
  /// **'Не скачан'**
  String get settings_geminiNanoNotDownloaded;

  /// No description provided for @settings_geminiNanoDownload.
  ///
  /// In ru, this message translates to:
  /// **'Скачать модель (~2.5 GB)'**
  String get settings_geminiNanoDownload;

  /// No description provided for @settings_geminiNanoDownloading.
  ///
  /// In ru, this message translates to:
  /// **'Скачивание...'**
  String get settings_geminiNanoDownloading;

  /// No description provided for @settings_geminiNanoDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить модель'**
  String get settings_geminiNanoDelete;

  /// No description provided for @settings_geminiNanoAdvantages.
  ///
  /// In ru, this message translates to:
  /// **'Преимущества'**
  String get settings_geminiNanoAdvantages;

  /// No description provided for @settings_geminiNanoAdvantagesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Почему стоит скачать Gemini Nano?'**
  String get settings_geminiNanoAdvantagesTitle;

  /// No description provided for @settings_geminiNanoAdvantage1.
  ///
  /// In ru, this message translates to:
  /// **'💰 Полностью бесплатно — без ограничений'**
  String get settings_geminiNanoAdvantage1;

  /// No description provided for @settings_geminiNanoAdvantage2.
  ///
  /// In ru, this message translates to:
  /// **'⚡ Мгновенные ответы — без задержки сети'**
  String get settings_geminiNanoAdvantage2;

  /// No description provided for @settings_geminiNanoAdvantage3.
  ///
  /// In ru, this message translates to:
  /// **'🔒 100% приватность — данные не покидают устройство'**
  String get settings_geminiNanoAdvantage3;

  /// No description provided for @settings_geminiNanoAdvantage4.
  ///
  /// In ru, this message translates to:
  /// **'📱 Работает офлайн — без интернета'**
  String get settings_geminiNanoAdvantage4;

  /// No description provided for @settings_geminiNanoAdvantage5.
  ///
  /// In ru, this message translates to:
  /// **'🌍 Поддержка 3 языков — русский, английский, немецкий'**
  String get settings_geminiNanoAdvantage5;

  /// No description provided for @settings_geminiNanoRequirements.
  ///
  /// In ru, this message translates to:
  /// **'Требования'**
  String get settings_geminiNanoRequirements;

  /// No description provided for @settings_geminiNanoRequirement1.
  ///
  /// In ru, this message translates to:
  /// **'Android 14+ (Google Pixel 8+, Samsung S24+, OnePlus 12+)'**
  String get settings_geminiNanoRequirement1;

  /// No description provided for @settings_geminiNanoRequirement2.
  ///
  /// In ru, this message translates to:
  /// **'~2.5 GB свободного места'**
  String get settings_geminiNanoRequirement2;

  /// No description provided for @settings_geminiNanoRequirement3.
  ///
  /// In ru, this message translates to:
  /// **'6 GB оперативной памяти'**
  String get settings_geminiNanoRequirement3;

  /// No description provided for @settings_geminiNanoDownloadConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Скачать модель Gemini Nano?'**
  String get settings_geminiNanoDownloadConfirm;

  /// No description provided for @settings_geminiNanoDownloadConfirmDescription.
  ///
  /// In ru, this message translates to:
  /// **'Модель займёт ~2.5 GB места, но даст вам бесплатный AI без интернета.'**
  String get settings_geminiNanoDownloadConfirmDescription;

  /// No description provided for @settings_geminiNanoDeleteConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Удалить модель?'**
  String get settings_geminiNanoDeleteConfirm;

  /// No description provided for @settings_geminiNanoDeleteConfirmDescription.
  ///
  /// In ru, this message translates to:
  /// **'Освободит ~2.5 GB места, но AI на устройстве перестанет работать.'**
  String get settings_geminiNanoDeleteConfirmDescription;

  /// No description provided for @settings_geminiNanoError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка'**
  String get settings_geminiNanoError;

  /// No description provided for @settings_geminiNanoErrorDownload.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось скачать модель. Проверьте подключение к интернету.'**
  String get settings_geminiNanoErrorDownload;

  /// No description provided for @settings_geminiNanoErrorDelete.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось удалить модель.'**
  String get settings_geminiNanoErrorDelete;

  /// No description provided for @settings_geminiNanoSuccessDownload.
  ///
  /// In ru, this message translates to:
  /// **'Модель успешно скачана!'**
  String get settings_geminiNanoSuccessDownload;

  /// No description provided for @settings_geminiNanoSuccessDelete.
  ///
  /// In ru, this message translates to:
  /// **'Модель удалена.'**
  String get settings_geminiNanoSuccessDelete;

  /// No description provided for @bari_goal_noPiggyBanks.
  ///
  /// In ru, this message translates to:
  /// **'У тебя пока нет копилок.'**
  String get bari_goal_noPiggyBanks;

  /// No description provided for @bari_goal_noPiggyBanksAdvice.
  ///
  /// In ru, this message translates to:
  /// **'Создай первую копилку с целью — это главный шаг к накоплениям! Что хочешь купить?'**
  String get bari_goal_noPiggyBanksAdvice;

  /// No description provided for @bari_goal_createPiggyBank.
  ///
  /// In ru, this message translates to:
  /// **'Создать копилку'**
  String get bari_goal_createPiggyBank;

  /// No description provided for @bari_goal_whenWillReach.
  ///
  /// In ru, this message translates to:
  /// **'Когда достигну цели'**
  String get bari_goal_whenWillReach;

  /// No description provided for @bari_goal_onePiggyBank.
  ///
  /// In ru, this message translates to:
  /// **'У тебя 1 копилка с {amount} внутри.'**
  String bari_goal_onePiggyBank(String amount);

  /// No description provided for @bari_goal_multiplePiggyBanks.
  ///
  /// In ru, this message translates to:
  /// **'У тебя {count} копилок, всего накоплено {total}.'**
  String bari_goal_multiplePiggyBanks(int count, String total);

  /// No description provided for @bari_goal_almostFull.
  ///
  /// In ru, this message translates to:
  /// **'Копилка \"{name}\" почти заполнена ({percent}%)! 🎉 Скоро цель!'**
  String bari_goal_almostFull(String name, int percent);

  /// No description provided for @bari_goal_justStarted.
  ///
  /// In ru, this message translates to:
  /// **'Копилка \"{name}\" только начата ({percent}%). Пора пополнить!'**
  String bari_goal_justStarted(String name, int percent);

  /// No description provided for @bari_goal_goodProgress.
  ///
  /// In ru, this message translates to:
  /// **'Хороший прогресс! Продолжай откладывать регулярно.'**
  String get bari_goal_goodProgress;

  /// No description provided for @bari_goal_piggyBanks.
  ///
  /// In ru, this message translates to:
  /// **'Копилки'**
  String get bari_goal_piggyBanks;

  /// No description provided for @bari_goal_createFirst.
  ///
  /// In ru, this message translates to:
  /// **'У тебя пока нет копилок — создай первую!'**
  String get bari_goal_createFirst;

  /// No description provided for @bari_goal_createFirstAdvice.
  ///
  /// In ru, this message translates to:
  /// **'Выбери цель: игрушка, гаджет, подарок. И начни с маленьких взносов.'**
  String get bari_goal_createFirstAdvice;

  /// No description provided for @bari_goal_topUpSoonest.
  ///
  /// In ru, this message translates to:
  /// **'Пополни \"{name}\" — до дедлайна осталось {days} дней!'**
  String bari_goal_topUpSoonest(String name, int days);

  /// No description provided for @bari_goal_topUpClosest.
  ///
  /// In ru, this message translates to:
  /// **'Советую пополнить \"{name}\" ({progress}%) — осталось {remaining}, ты близко к цели!'**
  String bari_goal_topUpClosest(String name, int progress, String remaining);

  /// No description provided for @bari_goal_allFullOrEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Все копилки полные или пустые. Создай новую цель!'**
  String get bari_goal_allFullOrEmpty;

  /// No description provided for @bari_goal_topUpAdvice.
  ///
  /// In ru, this message translates to:
  /// **'Лучше пополнять ту копилку, которая ближе к цели или у которой скоро дедлайн.'**
  String get bari_goal_topUpAdvice;

  /// No description provided for @bari_goal_walletAlmostEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас в кошельке почти пусто ({balance}). Время подкопить!'**
  String bari_goal_walletAlmostEmpty(String balance);

  /// No description provided for @bari_goal_walletEnoughForSmall.
  ///
  /// In ru, this message translates to:
  /// **'В кошельке {balance} — хватит на мелочи. Для большего нужен план.'**
  String bari_goal_walletEnoughForSmall(String balance);

  /// No description provided for @bari_goal_walletGood.
  ///
  /// In ru, this message translates to:
  /// **'В кошельке {balance} — неплохо! Но помни про цели в копилках.'**
  String bari_goal_walletGood(String balance);

  /// No description provided for @bari_goal_walletExcellent.
  ///
  /// In ru, this message translates to:
  /// **'В кошельке {balance} — отлично! Подумай, стоит ли часть перевести в копилку.'**
  String bari_goal_walletExcellent(String balance);

  /// No description provided for @bari_goal_walletBalance.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас в кошельке {balance}'**
  String bari_goal_walletBalance(String balance);

  /// No description provided for @bari_goal_canIBuy.
  ///
  /// In ru, this message translates to:
  /// **'Можно ли купить?'**
  String get bari_goal_canIBuy;

  /// No description provided for @bari_goal_balance.
  ///
  /// In ru, this message translates to:
  /// **'Баланс'**
  String get bari_goal_balance;

  /// No description provided for @bari_goal_enoughMoney.
  ///
  /// In ru, this message translates to:
  /// **'Да, у тебя уже достаточно денег! 🎉'**
  String get bari_goal_enoughMoney;

  /// No description provided for @bari_goal_enoughMoneyAdvice.
  ///
  /// In ru, this message translates to:
  /// **'Всего есть {available} (кошелёк + копилки), а нужно {target}.'**
  String bari_goal_enoughMoneyAdvice(String available, String target);

  /// No description provided for @bari_goal_needToSave.
  ///
  /// In ru, this message translates to:
  /// **'Нужно накопить ещё {needed}'**
  String bari_goal_needToSave(String needed);

  /// No description provided for @bari_goal_needToSaveAdvice.
  ///
  /// In ru, this message translates to:
  /// **'Если откладывать по {perMonth} в месяц, успеешь! Создай копилку с целью.'**
  String bari_goal_needToSaveAdvice(String perMonth);

  /// No description provided for @bari_goal_savingSecret.
  ///
  /// In ru, this message translates to:
  /// **'Главный секрет накоплений — регулярность!'**
  String get bari_goal_savingSecret;

  /// No description provided for @bari_goal_hardToSave.
  ///
  /// In ru, this message translates to:
  /// **'Копить сложно, когда нет привычки — это нормально!'**
  String get bari_goal_hardToSave;

  /// No description provided for @bari_goal_optimalPercent.
  ///
  /// In ru, this message translates to:
  /// **'Оптимально откладывать 10-20% от каждого дохода.'**
  String get bari_goal_optimalPercent;

  /// No description provided for @bari_goal_createFirstPiggy.
  ///
  /// In ru, this message translates to:
  /// **'Создай первую копилку — цель мотивирует откладывать.'**
  String get bari_goal_createFirstPiggy;

  /// No description provided for @bari_hint_highSpending.
  ///
  /// In ru, this message translates to:
  /// **'За последнюю неделю у тебя много расходов.'**
  String get bari_hint_highSpending;

  /// No description provided for @bari_hint_highSpendingAdvice.
  ///
  /// In ru, this message translates to:
  /// **'Давай посмотрим, куда больше всего уходит денег.'**
  String get bari_hint_highSpendingAdvice;

  /// No description provided for @bari_hint_mainExpenses.
  ///
  /// In ru, this message translates to:
  /// **'Основные траты'**
  String get bari_hint_mainExpenses;

  /// No description provided for @bari_hint_stalledPiggy.
  ///
  /// In ru, this message translates to:
  /// **'Копилка \"{name}\" давно не пополнялась.'**
  String bari_hint_stalledPiggy(String name);

  /// No description provided for @bari_hint_stalledPiggies.
  ///
  /// In ru, this message translates to:
  /// **'Копилки немного \"застыли\".'**
  String get bari_hint_stalledPiggies;

  /// No description provided for @bari_hint_stalledAdvice.
  ///
  /// In ru, this message translates to:
  /// **'Могу помочь придумать задание в Лаборатории заработка.'**
  String get bari_hint_stalledAdvice;

  /// No description provided for @bari_hint_earningsLab.
  ///
  /// In ru, this message translates to:
  /// **'Лаборатория заработка'**
  String get bari_hint_earningsLab;

  /// No description provided for @bari_hint_noLessons.
  ///
  /// In ru, this message translates to:
  /// **'Уроки давно не открывали.'**
  String get bari_hint_noLessons;

  /// No description provided for @bari_hint_noLessonsAdvice.
  ///
  /// In ru, this message translates to:
  /// **'Хочешь короткий урок на 3–5 минут?'**
  String get bari_hint_noLessonsAdvice;

  /// No description provided for @bari_hint_lessons.
  ///
  /// In ru, this message translates to:
  /// **'Уроки'**
  String get bari_hint_lessons;

  /// No description provided for @bari_hint_noLessonsYet.
  ///
  /// In ru, this message translates to:
  /// **'Ещё не проходили уроки?'**
  String get bari_hint_noLessonsYet;

  /// No description provided for @bari_hint_noLessonsYetAdvice.
  ///
  /// In ru, this message translates to:
  /// **'Пройди первый урок — это займёт всего 3 минуты!'**
  String get bari_hint_noLessonsYetAdvice;

  /// No description provided for @bari_hint_lowBalance.
  ///
  /// In ru, this message translates to:
  /// **'Баланс низкий, а скоро запланированы расходы.'**
  String get bari_hint_lowBalance;

  /// No description provided for @bari_hint_lowBalanceAdvice.
  ///
  /// In ru, this message translates to:
  /// **'Можешь заработать в Лаборатории заработка или посмотреть план.'**
  String get bari_hint_lowBalanceAdvice;

  /// No description provided for @bari_hint_calendar.
  ///
  /// In ru, this message translates to:
  /// **'Календарь'**
  String get bari_hint_calendar;

  /// No description provided for @bari_hint_highIncomeNoGoals.
  ///
  /// In ru, this message translates to:
  /// **'У тебя хорошие доходы, но нет целей для накопления.'**
  String get bari_hint_highIncomeNoGoals;

  /// No description provided for @bari_hint_highIncomeNoGoalsAdvice.
  ///
  /// In ru, this message translates to:
  /// **'Создай копилку для важной покупки!'**
  String get bari_hint_highIncomeNoGoalsAdvice;

  /// No description provided for @bari_hint_manySpendingCategory.
  ///
  /// In ru, this message translates to:
  /// **'Много трат на \"{category}\".'**
  String bari_hint_manySpendingCategory(String category);

  /// No description provided for @bari_hint_manySpendingCategoryAdvice.
  ///
  /// In ru, this message translates to:
  /// **'Проверь, не превышаешь ли ты бюджет. Открой калькулятор бюджета.'**
  String get bari_hint_manySpendingCategoryAdvice;

  /// No description provided for @bari_hint_budgetCalculator.
  ///
  /// In ru, this message translates to:
  /// **'Калькулятор бюджета'**
  String get bari_hint_budgetCalculator;

  /// No description provided for @bari_hint_noPlannedEvents.
  ///
  /// In ru, this message translates to:
  /// **'Нет запланированных событий.'**
  String get bari_hint_noPlannedEvents;

  /// No description provided for @bari_hint_noPlannedEventsAdvice.
  ///
  /// In ru, this message translates to:
  /// **'Запланируй доходы и расходы, чтобы лучше управлять деньгами.'**
  String get bari_hint_noPlannedEventsAdvice;

  /// No description provided for @bari_hint_createPlan.
  ///
  /// In ru, this message translates to:
  /// **'Создать план'**
  String get bari_hint_createPlan;

  /// No description provided for @bari_hint_tipTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подсказка Бари'**
  String get bari_hint_tipTitle;

  /// No description provided for @bari_emptyMessage.
  ///
  /// In ru, this message translates to:
  /// **'Напиши вопрос 🙂'**
  String get bari_emptyMessage;

  /// No description provided for @bari_emptyMessageAdvice.
  ///
  /// In ru, this message translates to:
  /// **'Например: \"можно ли купить за 20€\" или \"что такое инфляция\"'**
  String get bari_emptyMessageAdvice;

  /// No description provided for @bari_balance.
  ///
  /// In ru, this message translates to:
  /// **'Баланс'**
  String get bari_balance;

  /// No description provided for @bari_piggyBanks.
  ///
  /// In ru, this message translates to:
  /// **'Копилки'**
  String get bari_piggyBanks;

  /// No description provided for @bari_math_percentOf.
  ///
  /// In ru, this message translates to:
  /// **'{percent}% от {base} = {result}'**
  String bari_math_percentOf(String percent, String base, String result);

  /// No description provided for @bari_math_percentAdvice.
  ///
  /// In ru, this message translates to:
  /// **'Полезно знать: если откладывать {percent}% от дохода, это поможет копить регулярно.'**
  String bari_math_percentAdvice(String percent);

  /// No description provided for @bari_math_calculator503020.
  ///
  /// In ru, this message translates to:
  /// **'Калькулятор 50/30/20'**
  String get bari_math_calculator503020;

  /// No description provided for @bari_math_explainSimpler.
  ///
  /// In ru, this message translates to:
  /// **'Объясни проще'**
  String get bari_math_explainSimpler;

  /// No description provided for @bari_math_monthlyToYearly.
  ///
  /// In ru, this message translates to:
  /// **'{monthly} в месяц = {yearly} в год'**
  String bari_math_monthlyToYearly(String monthly, String yearly);

  /// No description provided for @bari_math_monthlyToYearlyAdvice.
  ///
  /// In ru, this message translates to:
  /// **'Маленькие регулярные суммы накапливаются! Подписки тоже стоит считать за год.'**
  String get bari_math_monthlyToYearlyAdvice;

  /// No description provided for @bari_math_subscriptionsCalculator.
  ///
  /// In ru, this message translates to:
  /// **'Калькулятор подписок'**
  String get bari_math_subscriptionsCalculator;

  /// No description provided for @bari_math_saveYearly.
  ///
  /// In ru, this message translates to:
  /// **'Если откладывать по {monthly} в месяц, за год накопится {yearly}'**
  String bari_math_saveYearly(String monthly, String yearly);

  /// No description provided for @bari_math_saveYearlyAdvice.
  ///
  /// In ru, this message translates to:
  /// **'Регулярность важнее суммы! Начни с маленького и увеличивай постепенно.'**
  String get bari_math_saveYearlyAdvice;

  /// No description provided for @bari_math_savePerPeriod.
  ///
  /// In ru, this message translates to:
  /// **'Чтобы накопить {target}, нужно откладывать по {perPeriod} в {period}'**
  String bari_math_savePerPeriod(
    String target,
    String perPeriod,
    String period,
  );

  /// No description provided for @bari_math_savePerPeriodAdvice.
  ///
  /// In ru, this message translates to:
  /// **'Создай копилку с этой целью — так проще не забывать!'**
  String get bari_math_savePerPeriodAdvice;

  /// No description provided for @bari_math_alreadyEnough.
  ///
  /// In ru, this message translates to:
  /// **'Ты уже накопил(а) достаточно! 🎉'**
  String get bari_math_alreadyEnough;

  /// No description provided for @bari_math_alreadyEnoughAdvice.
  ///
  /// In ru, this message translates to:
  /// **'Цель достигнута — можешь потратить или продолжить копить на что-то большее.'**
  String get bari_math_alreadyEnoughAdvice;

  /// No description provided for @bari_math_remainingToSave.
  ///
  /// In ru, this message translates to:
  /// **'Осталось накопить {remaining} (уже {percent}% от цели)'**
  String bari_math_remainingToSave(String remaining, int percent);

  /// No description provided for @bari_math_remainingAdvice.
  ///
  /// In ru, this message translates to:
  /// **'Ты на правильном пути! Продолжай в том же темпе.'**
  String get bari_math_remainingAdvice;

  /// No description provided for @bari_math_multiply.
  ///
  /// In ru, this message translates to:
  /// **'{a} × {b} = {result}'**
  String bari_math_multiply(String a, String b, String result);

  /// No description provided for @bari_math_multiplyAdvice.
  ///
  /// In ru, this message translates to:
  /// **'Умножение помогает считать регулярные траты: ежедневные за месяц, месячные за год.'**
  String get bari_math_multiplyAdvice;

  /// No description provided for @bari_math_calculators.
  ///
  /// In ru, this message translates to:
  /// **'Калькуляторы'**
  String get bari_math_calculators;

  /// No description provided for @bari_math_divideByZero.
  ///
  /// In ru, this message translates to:
  /// **'На ноль делить нельзя!'**
  String get bari_math_divideByZero;

  /// No description provided for @bari_math_divideByZeroAdvice.
  ///
  /// In ru, this message translates to:
  /// **'Это как делить пиццу между нулём друзей — некому есть.'**
  String get bari_math_divideByZeroAdvice;

  /// No description provided for @bari_math_divide.
  ///
  /// In ru, this message translates to:
  /// **'{a} ÷ {b} = {result}'**
  String bari_math_divide(String a, String b, String result);

  /// No description provided for @bari_math_divideAdvice.
  ///
  /// In ru, this message translates to:
  /// **'Деление помогает понять, сколько откладывать в неделю/месяц для цели.'**
  String get bari_math_divideAdvice;

  /// No description provided for @bari_math_priceComparison.
  ///
  /// In ru, this message translates to:
  /// **'Вариант {better} выгоднее! ({price1} за единицу vs {price2})'**
  String bari_math_priceComparison(int better, String price1, String price2);

  /// No description provided for @bari_math_priceComparisonAdvice.
  ///
  /// In ru, this message translates to:
  /// **'Экономия ~{savings}%. Но проверь: успеешь ли использовать большую упаковку?'**
  String bari_math_priceComparisonAdvice(int savings);

  /// No description provided for @bari_math_priceComparisonCalculator.
  ///
  /// In ru, this message translates to:
  /// **'Сравнение цен'**
  String get bari_math_priceComparisonCalculator;

  /// No description provided for @bari_math_rule72.
  ///
  /// In ru, this message translates to:
  /// **'При {rate}% годовых деньги удвоятся примерно за {years} лет'**
  String bari_math_rule72(String rate, String years);

  /// No description provided for @bari_math_rule72Advice.
  ///
  /// In ru, this message translates to:
  /// **'Это \"Правило 72\" — быстрый способ оценить рост накоплений. Чем выше %, тем быстрее рост, но и риск выше.'**
  String bari_math_rule72Advice(String rate);

  /// No description provided for @bari_math_lessons.
  ///
  /// In ru, this message translates to:
  /// **'Уроки'**
  String get bari_math_lessons;

  /// No description provided for @bari_math_inflation.
  ///
  /// In ru, this message translates to:
  /// **'{amount} через {years} лет будут \"стоить\" как {realValue} сегодня'**
  String bari_math_inflation(String amount, String years, String realValue);

  /// No description provided for @bari_math_inflationAdvice.
  ///
  /// In ru, this message translates to:
  /// **'Инфляция \"съедает\" деньги. Поэтому важно не только копить, но и учиться инвестировать (когда подрастёшь).'**
  String bari_math_inflationAdvice(String amount, String years);

  /// No description provided for @bari_spending_noData.
  ///
  /// In ru, this message translates to:
  /// **'Пока мало данных о твоих доходах и расходах.'**
  String get bari_spending_noData;

  /// No description provided for @bari_spending_noDataAdvice.
  ///
  /// In ru, this message translates to:
  /// **'Продолжай записывать операции — тогда я смогу подсказать больше.'**
  String get bari_spending_noDataAdvice;

  /// No description provided for @bari_goal_deadlineSoon.
  ///
  /// In ru, this message translates to:
  /// **'Пополни \"{name}\" — до дедлайна осталось {days} дней!'**
  String bari_goal_deadlineSoon(String name, int days);

  /// No description provided for @bari_goal_closeToGoal.
  ///
  /// In ru, this message translates to:
  /// **'Советую пополнить \"{name}\" ({progress}%) — осталось {remaining}, ты близко к цели!'**
  String bari_goal_closeToGoal(String name, int progress, String remaining);

  /// No description provided for @bari_goal_whichPiggyBankAdvice.
  ///
  /// In ru, this message translates to:
  /// **'Лучше пополнять ту копилку, которая ближе к цели или у которой скоро дедлайн.'**
  String get bari_goal_whichPiggyBankAdvice;

  /// No description provided for @bari_goal_alreadyEnough.
  ///
  /// In ru, this message translates to:
  /// **'Да, у тебя уже достаточно денег! 🎉'**
  String get bari_goal_alreadyEnough;

  /// No description provided for @bari_goal_alreadyEnoughAdvice.
  ///
  /// In ru, this message translates to:
  /// **'Всего есть {available} (кошелёк + копилки), а нужно {target}.'**
  String bari_goal_alreadyEnoughAdvice(String available, String target);

  /// No description provided for @bari_goal_savePerMonth.
  ///
  /// In ru, this message translates to:
  /// **'Если откладывать по {perMonth} в месяц, успеешь! Создай копилку с целью.'**
  String bari_goal_savePerMonth(String perMonth);

  /// No description provided for @bari_goal_emptyWallet.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас в кошельке почти пусто ({balance}). Время подкопить!'**
  String bari_goal_emptyWallet(String balance);

  /// No description provided for @bari_goal_lowBalance.
  ///
  /// In ru, this message translates to:
  /// **'В кошельке {balance} — можно пополнить копилку или оставить на расходы.'**
  String bari_goal_lowBalance(String balance);

  /// No description provided for @bari_goal_goodBalance.
  ///
  /// In ru, this message translates to:
  /// **'В кошельке {balance} — отличный баланс! Можно пополнить копилки.'**
  String bari_goal_goodBalance(String balance);

  /// No description provided for @bari_goal_createFirstPiggyBank.
  ///
  /// In ru, this message translates to:
  /// **'Создай первую копилку — цель мотивирует откладывать.'**
  String get bari_goal_createFirstPiggyBank;

  /// No description provided for @bari_goal_setDeadline.
  ///
  /// In ru, this message translates to:
  /// **'Установи дедлайн для копилки — так проще планировать.'**
  String get bari_goal_setDeadline;

  /// No description provided for @bari_goal_regularTopUps.
  ///
  /// In ru, this message translates to:
  /// **'Пополняй копилки регулярно, даже маленькими суммами.'**
  String get bari_goal_regularTopUps;

  /// No description provided for @bari_goal_checkProgress.
  ///
  /// In ru, this message translates to:
  /// **'Проверяй прогресс копилок — это мотивирует!'**
  String get bari_goal_checkProgress;

  /// No description provided for @bari_goal_completeLessons.
  ///
  /// In ru, this message translates to:
  /// **'Пройди уроки о накоплениях — узнаешь полезные советы.'**
  String get bari_goal_completeLessons;

  /// No description provided for @bari_math_percentOfResult.
  ///
  /// In ru, this message translates to:
  /// **'{percent}% от {base} = {result}'**
  String bari_math_percentOfResult(String percent, String base, String result);

  /// No description provided for @bari_math_percentAdviceWithPercent.
  ///
  /// In ru, this message translates to:
  /// **'Полезно знать: если откладывать {percent}% от дохода, это поможет копить регулярно.'**
  String bari_math_percentAdviceWithPercent(String percent);

  /// No description provided for @bari_math_monthlyToYearlyResult.
  ///
  /// In ru, this message translates to:
  /// **'{monthly} в месяц = {yearly} в год'**
  String bari_math_monthlyToYearlyResult(String monthly, String yearly);

  /// No description provided for @bari_math_saveYearlyResult.
  ///
  /// In ru, this message translates to:
  /// **'Если откладывать по {monthly} в месяц, за год накопится {yearly}'**
  String bari_math_saveYearlyResult(String monthly, String yearly);

  /// No description provided for @bari_math_savePerPeriodResult.
  ///
  /// In ru, this message translates to:
  /// **'Чтобы накопить {target}, нужно откладывать по {perPeriod} в {period}'**
  String bari_math_savePerPeriodResult(
    String target,
    String perPeriod,
    String period,
  );

  /// No description provided for @bari_math_createPiggyBank.
  ///
  /// In ru, this message translates to:
  /// **'Создать копилку'**
  String get bari_math_createPiggyBank;

  /// No description provided for @bari_math_whenWillReach.
  ///
  /// In ru, this message translates to:
  /// **'Когда достигну цели'**
  String get bari_math_whenWillReach;

  /// No description provided for @bari_math_remainingToSaveResult.
  ///
  /// In ru, this message translates to:
  /// **'Осталось накопить {remaining} (уже {percent}% от цели)'**
  String bari_math_remainingToSaveResult(String remaining, int percent);

  /// No description provided for @bari_math_multiplyResult.
  ///
  /// In ru, this message translates to:
  /// **'{a} × {b} = {result}'**
  String bari_math_multiplyResult(String a, String b, String result);

  /// No description provided for @bari_math_divideResult.
  ///
  /// In ru, this message translates to:
  /// **'{a} ÷ {b} = {result}'**
  String bari_math_divideResult(String a, String b, String result);

  /// No description provided for @bari_math_priceComparisonResult.
  ///
  /// In ru, this message translates to:
  /// **'Вариант {better} выгоднее! ({price1} за единицу vs {price2})'**
  String bari_math_priceComparisonResult(
    int better,
    String price1,
    String price2,
  );

  /// No description provided for @bari_math_priceComparisonAdviceWithSavings.
  ///
  /// In ru, this message translates to:
  /// **'Экономия ~{savings}%. Но проверь: успеешь ли использовать большую упаковку?'**
  String bari_math_priceComparisonAdviceWithSavings(int savings);

  /// No description provided for @bari_math_rule72Result.
  ///
  /// In ru, this message translates to:
  /// **'При {rate}% годовых деньги удвоятся примерно за {years} лет'**
  String bari_math_rule72Result(String rate, String years);

  /// No description provided for @bari_math_rule72AdviceWithRate.
  ///
  /// In ru, this message translates to:
  /// **'Это \"Правило 72\" — быстрый способ оценить рост накоплений. Чем выше %, тем быстрее рост, но и риск выше.'**
  String bari_math_rule72AdviceWithRate(String rate);

  /// No description provided for @bari_math_inflationResult.
  ///
  /// In ru, this message translates to:
  /// **'{amount} через {years} лет будут \"стоить\" как {realValue} сегодня'**
  String bari_math_inflationResult(
    String amount,
    String years,
    String realValue,
  );

  /// No description provided for @bari_math_inflationAdviceWithAmount.
  ///
  /// In ru, this message translates to:
  /// **'Инфляция \"съедает\" деньги. Поэтому важно не только копить, но и учиться инвестировать (когда подрастёшь).'**
  String bari_math_inflationAdviceWithAmount(String amount, String years);

  /// No description provided for @earningsLab_piggyBankNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Копилка не найдена'**
  String get earningsLab_piggyBankNotFound;

  /// No description provided for @earningsLab_noTransactions.
  ///
  /// In ru, this message translates to:
  /// **'По этой копилке ещё нет операций'**
  String get earningsLab_noTransactions;

  /// No description provided for @earningsLab_transactionHistory.
  ///
  /// In ru, this message translates to:
  /// **'История по этой копилке'**
  String get earningsLab_transactionHistory;

  /// No description provided for @earningsLab_topUp.
  ///
  /// In ru, this message translates to:
  /// **'Пополнение копилки'**
  String get earningsLab_topUp;

  /// No description provided for @earningsLab_withdrawal.
  ///
  /// In ru, this message translates to:
  /// **'Снятие из копилки'**
  String get earningsLab_withdrawal;

  /// No description provided for @earningsLab_goalReached.
  ///
  /// In ru, this message translates to:
  /// **'Цель достигнута 🎉'**
  String get earningsLab_goalReached;

  /// No description provided for @earningsLab_goalReachedSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Молодец! Можешь создать новую цель или перенести деньги в кошелёк.'**
  String get earningsLab_goalReachedSubtitle;

  /// No description provided for @earningsLab_almostThere.
  ///
  /// In ru, this message translates to:
  /// **'Осталось совсем чуть-чуть'**
  String get earningsLab_almostThere;

  /// No description provided for @earningsLab_almostThereSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Подумай, как сделать ещё 1–2 пополнения — и цель будет закрыта.'**
  String get earningsLab_almostThereSubtitle;

  /// No description provided for @earningsLab_halfway.
  ///
  /// In ru, this message translates to:
  /// **'Половина пути пройдена'**
  String get earningsLab_halfway;

  /// No description provided for @earningsLab_halfwaySubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Если будешь пополнять копилку регулярно, достигнешь цели гораздо быстрее.'**
  String get earningsLab_halfwaySubtitle;

  /// No description provided for @earningsLab_goodStart.
  ///
  /// In ru, this message translates to:
  /// **'Хорошее начало'**
  String get earningsLab_goodStart;

  /// No description provided for @earningsLab_goodStartSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Попробуй настроить автопополнение или добавить задание в Лаборатории заработка специально под эту цель.'**
  String get earningsLab_goodStartSubtitle;

  /// No description provided for @notes_title.
  ///
  /// In ru, this message translates to:
  /// **'Заметки'**
  String get notes_title;

  /// No description provided for @notes_listView.
  ///
  /// In ru, this message translates to:
  /// **'Список'**
  String get notes_listView;

  /// No description provided for @notes_gridView.
  ///
  /// In ru, this message translates to:
  /// **'Сетка'**
  String get notes_gridView;

  /// No description provided for @notes_searchHint.
  ///
  /// In ru, this message translates to:
  /// **'Поиск заметок...'**
  String get notes_searchHint;

  /// No description provided for @notes_all.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get notes_all;

  /// No description provided for @notes_pinned.
  ///
  /// In ru, this message translates to:
  /// **'Закреплённые'**
  String get notes_pinned;

  /// No description provided for @notes_archived.
  ///
  /// In ru, this message translates to:
  /// **'Архив'**
  String get notes_archived;

  /// No description provided for @notes_linked.
  ///
  /// In ru, this message translates to:
  /// **'Связанные'**
  String get notes_linked;

  /// No description provided for @notes_errorLoading.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка загрузки заметок'**
  String get notes_errorLoading;

  /// No description provided for @notes_emptyArchived.
  ///
  /// In ru, this message translates to:
  /// **'Архив пуст'**
  String get notes_emptyArchived;

  /// No description provided for @notes_emptyPinned.
  ///
  /// In ru, this message translates to:
  /// **'Нет закреплённых заметок'**
  String get notes_emptyPinned;

  /// No description provided for @notes_empty.
  ///
  /// In ru, this message translates to:
  /// **'Нет заметок'**
  String get notes_empty;

  /// No description provided for @notes_emptySubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Создайте первую заметку, чтобы сохранить важные мысли'**
  String get notes_emptySubtitle;

  /// No description provided for @notes_createFirst.
  ///
  /// In ru, this message translates to:
  /// **'Создать первую заметку'**
  String get notes_createFirst;

  /// No description provided for @notes_deleteConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Удалить заметку?'**
  String get notes_deleteConfirm;

  /// No description provided for @notes_deleteMessage.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите удалить заметку \"{noteTitle}\"?'**
  String notes_deleteMessage(String noteTitle);

  /// No description provided for @notes_unpin.
  ///
  /// In ru, this message translates to:
  /// **'Открепить'**
  String get notes_unpin;

  /// No description provided for @notes_pin.
  ///
  /// In ru, this message translates to:
  /// **'Закрепить'**
  String get notes_pin;

  /// No description provided for @notes_unarchive.
  ///
  /// In ru, this message translates to:
  /// **'Вернуть из архива'**
  String get notes_unarchive;

  /// No description provided for @notes_archive.
  ///
  /// In ru, this message translates to:
  /// **'В архив'**
  String get notes_archive;

  /// No description provided for @notes_copy.
  ///
  /// In ru, this message translates to:
  /// **'Копировать'**
  String get notes_copy;

  /// No description provided for @notes_share.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться'**
  String get notes_share;

  /// No description provided for @notes_copied.
  ///
  /// In ru, this message translates to:
  /// **'Заметка скопирована'**
  String get notes_copied;

  /// No description provided for @notes_shareNotAvailable.
  ///
  /// In ru, this message translates to:
  /// **'Функция шаринга временно недоступна'**
  String get notes_shareNotAvailable;

  /// No description provided for @notes_edit.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать заметку'**
  String get notes_edit;

  /// No description provided for @notes_create.
  ///
  /// In ru, this message translates to:
  /// **'Новая заметка'**
  String get notes_create;

  /// No description provided for @notes_changeColor.
  ///
  /// In ru, this message translates to:
  /// **'Изменить цвет'**
  String get notes_changeColor;

  /// No description provided for @notes_editTags.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать теги'**
  String get notes_editTags;

  /// No description provided for @notes_selectColor.
  ///
  /// In ru, this message translates to:
  /// **'Выберите цвет'**
  String get notes_selectColor;

  /// No description provided for @notes_clearColor.
  ///
  /// In ru, this message translates to:
  /// **'Очистить цвет'**
  String get notes_clearColor;

  /// No description provided for @notes_tagHint.
  ///
  /// In ru, this message translates to:
  /// **'Добавить тег...'**
  String get notes_tagHint;

  /// No description provided for @notes_titleRequired.
  ///
  /// In ru, this message translates to:
  /// **'Введите заголовок заметки'**
  String get notes_titleRequired;

  /// No description provided for @notes_titleHint.
  ///
  /// In ru, this message translates to:
  /// **'Заголовок заметки...'**
  String get notes_titleHint;

  /// No description provided for @notes_contentHint.
  ///
  /// In ru, this message translates to:
  /// **'Начните писать здесь...'**
  String get notes_contentHint;

  /// No description provided for @notes_save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить заметку'**
  String get notes_save;

  /// No description provided for @notes_today.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get notes_today;

  /// No description provided for @notes_yesterday.
  ///
  /// In ru, this message translates to:
  /// **'Вчера'**
  String get notes_yesterday;

  /// No description provided for @notes_daysAgo.
  ///
  /// In ru, this message translates to:
  /// **'{days} дн.'**
  String notes_daysAgo(int days);

  /// No description provided for @notes_templates.
  ///
  /// In ru, this message translates to:
  /// **'Шаблоны'**
  String get notes_templates;

  /// No description provided for @notes_templateExpense.
  ///
  /// In ru, this message translates to:
  /// **'Планирование расходов'**
  String get notes_templateExpense;

  /// No description provided for @notes_templateGoal.
  ///
  /// In ru, this message translates to:
  /// **'Цель'**
  String get notes_templateGoal;

  /// No description provided for @notes_templateIdea.
  ///
  /// In ru, this message translates to:
  /// **'Идея'**
  String get notes_templateIdea;

  /// No description provided for @notes_templateMeeting.
  ///
  /// In ru, this message translates to:
  /// **'Встреча'**
  String get notes_templateMeeting;

  /// No description provided for @notes_templateLearning.
  ///
  /// In ru, this message translates to:
  /// **'Обучение'**
  String get notes_templateLearning;

  /// No description provided for @notes_templateExpenseDesc.
  ///
  /// In ru, this message translates to:
  /// **'Запланируй свои расходы'**
  String get notes_templateExpenseDesc;

  /// No description provided for @notes_templateGoalDesc.
  ///
  /// In ru, this message translates to:
  /// **'Запиши свою цель'**
  String get notes_templateGoalDesc;

  /// No description provided for @notes_templateIdeaDesc.
  ///
  /// In ru, this message translates to:
  /// **'Сохрани свою идею'**
  String get notes_templateIdeaDesc;

  /// No description provided for @notes_templateMeetingDesc.
  ///
  /// In ru, this message translates to:
  /// **'Заметки к встрече'**
  String get notes_templateMeetingDesc;

  /// No description provided for @notes_templateLearningDesc.
  ///
  /// In ru, this message translates to:
  /// **'Заметки к уроку'**
  String get notes_templateLearningDesc;

  /// No description provided for @notes_linkToEvent.
  ///
  /// In ru, this message translates to:
  /// **'Привязать к событию'**
  String get notes_linkToEvent;

  /// No description provided for @notes_linkedToEvent.
  ///
  /// In ru, this message translates to:
  /// **'Привязано к событию'**
  String get notes_linkedToEvent;

  /// No description provided for @notes_unlinkFromEvent.
  ///
  /// In ru, this message translates to:
  /// **'Отвязать от события'**
  String get notes_unlinkFromEvent;

  /// No description provided for @notes_selectEvent.
  ///
  /// In ru, this message translates to:
  /// **'Выберите событие'**
  String get notes_selectEvent;

  /// No description provided for @notes_noEvents.
  ///
  /// In ru, this message translates to:
  /// **'Нет доступных событий'**
  String get notes_noEvents;

  /// No description provided for @notes_bariTip.
  ///
  /// In ru, this message translates to:
  /// **'Совет от Бари'**
  String get notes_bariTip;

  /// No description provided for @notes_quickNote.
  ///
  /// In ru, this message translates to:
  /// **'Быстрая заметка'**
  String get notes_quickNote;

  /// No description provided for @notes_autoSave.
  ///
  /// In ru, this message translates to:
  /// **'Автосохранение'**
  String get notes_autoSave;

  /// No description provided for @notes_preview.
  ///
  /// In ru, this message translates to:
  /// **'Предпросмотр'**
  String get notes_preview;

  /// No description provided for @notes_swipeToArchive.
  ///
  /// In ru, this message translates to:
  /// **'Смахните влево для архива'**
  String get notes_swipeToArchive;

  /// No description provided for @notes_swipeToDelete.
  ///
  /// In ru, this message translates to:
  /// **'Смахните вправо для удаления'**
  String get notes_swipeToDelete;

  /// No description provided for @notes_templateShoppingList.
  ///
  /// In ru, this message translates to:
  /// **'Список покупок'**
  String get notes_templateShoppingList;

  /// No description provided for @notes_templateShoppingListDesc.
  ///
  /// In ru, this message translates to:
  /// **'Организуй свои покупки'**
  String get notes_templateShoppingListDesc;

  /// No description provided for @notes_templateReflection.
  ///
  /// In ru, this message translates to:
  /// **'Размышления'**
  String get notes_templateReflection;

  /// No description provided for @notes_templateReflectionDesc.
  ///
  /// In ru, this message translates to:
  /// **'Запиши свои мысли'**
  String get notes_templateReflectionDesc;

  /// No description provided for @notes_templateGratitude.
  ///
  /// In ru, this message translates to:
  /// **'Благодарность'**
  String get notes_templateGratitude;

  /// No description provided for @notes_templateGratitudeDesc.
  ///
  /// In ru, this message translates to:
  /// **'За что я благодарен'**
  String get notes_templateGratitudeDesc;

  /// No description provided for @notes_templateParentReport.
  ///
  /// In ru, this message translates to:
  /// **'Отчет для родителей'**
  String get notes_templateParentReport;

  /// No description provided for @notes_templateParentReportDesc.
  ///
  /// In ru, this message translates to:
  /// **'Автоматический отчет за период'**
  String get notes_templateParentReportDesc;

  /// No description provided for @calendarSync_title.
  ///
  /// In ru, this message translates to:
  /// **'Синхронизация с календарём'**
  String get calendarSync_title;

  /// No description provided for @calendarSync_enable.
  ///
  /// In ru, this message translates to:
  /// **'Включить синхронизацию'**
  String get calendarSync_enable;

  /// No description provided for @calendarSync_syncToCalendar.
  ///
  /// In ru, this message translates to:
  /// **'Синхронизировать события в календарь'**
  String get calendarSync_syncToCalendar;

  /// No description provided for @calendarSync_syncFromCalendar.
  ///
  /// In ru, this message translates to:
  /// **'Импортировать события из календаря'**
  String get calendarSync_syncFromCalendar;

  /// No description provided for @calendarSync_selectCalendars.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать календари'**
  String get calendarSync_selectCalendars;

  /// No description provided for @calendarSync_noCalendars.
  ///
  /// In ru, this message translates to:
  /// **'Нет доступных календарей'**
  String get calendarSync_noCalendars;

  /// No description provided for @calendarSync_requestPermissions.
  ///
  /// In ru, this message translates to:
  /// **'Запросить разрешения'**
  String get calendarSync_requestPermissions;

  /// No description provided for @calendarSync_permissionsGranted.
  ///
  /// In ru, this message translates to:
  /// **'Разрешения предоставлены'**
  String get calendarSync_permissionsGranted;

  /// No description provided for @calendarSync_permissionsDenied.
  ///
  /// In ru, this message translates to:
  /// **'Разрешения не предоставлены'**
  String get calendarSync_permissionsDenied;

  /// No description provided for @calendarSync_syncNow.
  ///
  /// In ru, this message translates to:
  /// **'Синхронизировать сейчас'**
  String get calendarSync_syncNow;

  /// No description provided for @calendarSync_lastSync.
  ///
  /// In ru, this message translates to:
  /// **'Последняя синхронизация'**
  String get calendarSync_lastSync;

  /// No description provided for @calendarSync_never.
  ///
  /// In ru, this message translates to:
  /// **'Никогда'**
  String get calendarSync_never;

  /// No description provided for @calendarSync_conflictResolution.
  ///
  /// In ru, this message translates to:
  /// **'Разрешение конфликтов'**
  String get calendarSync_conflictResolution;

  /// No description provided for @calendarSync_appWins.
  ///
  /// In ru, this message translates to:
  /// **'Приложение имеет приоритет'**
  String get calendarSync_appWins;

  /// No description provided for @calendarSync_calendarWins.
  ///
  /// In ru, this message translates to:
  /// **'Календарь имеет приоритет'**
  String get calendarSync_calendarWins;

  /// No description provided for @calendarSync_askUser.
  ///
  /// In ru, this message translates to:
  /// **'Спрашивать пользователя'**
  String get calendarSync_askUser;

  /// No description provided for @calendarSync_merge.
  ///
  /// In ru, this message translates to:
  /// **'Объединять'**
  String get calendarSync_merge;

  /// No description provided for @calendarSync_syncInterval.
  ///
  /// In ru, this message translates to:
  /// **'Интервал синхронизации (часы)'**
  String get calendarSync_syncInterval;

  /// No description provided for @calendarSync_showNotifications.
  ///
  /// In ru, this message translates to:
  /// **'Показывать уведомления'**
  String get calendarSync_showNotifications;

  /// No description provided for @calendarSync_syncNotesAsEvents.
  ///
  /// In ru, this message translates to:
  /// **'Синхронизировать заметки как события'**
  String get calendarSync_syncNotesAsEvents;

  /// No description provided for @calendarSync_statistics.
  ///
  /// In ru, this message translates to:
  /// **'Статистика'**
  String get calendarSync_statistics;

  /// No description provided for @calendarSync_totalEvents.
  ///
  /// In ru, this message translates to:
  /// **'Всего событий'**
  String get calendarSync_totalEvents;

  /// No description provided for @calendarSync_syncedEvents.
  ///
  /// In ru, this message translates to:
  /// **'Синхронизировано'**
  String get calendarSync_syncedEvents;

  /// No description provided for @calendarSync_localEvents.
  ///
  /// In ru, this message translates to:
  /// **'Локальные'**
  String get calendarSync_localEvents;

  /// No description provided for @calendarSync_errorEvents.
  ///
  /// In ru, this message translates to:
  /// **'Ошибки'**
  String get calendarSync_errorEvents;

  /// No description provided for @calendarSync_successRate.
  ///
  /// In ru, this message translates to:
  /// **'Успешность'**
  String get calendarSync_successRate;

  /// No description provided for @calendarSync_syncInProgress.
  ///
  /// In ru, this message translates to:
  /// **'Синхронизация...'**
  String get calendarSync_syncInProgress;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
