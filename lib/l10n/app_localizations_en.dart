// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_save => 'Save';

  @override
  String get common_create => 'Create';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_done => 'Done';

  @override
  String get common_understand => 'Got it';

  @override
  String get common_planCreated => 'Plan created successfully!';

  @override
  String get common_purchasePlanned => 'Purchase planned!';

  @override
  String get common_income => 'Income';

  @override
  String get common_expense => 'Expense';

  @override
  String get common_plan => 'Plan';

  @override
  String get common_balance => 'Balance';

  @override
  String get common_piggyBanks => 'Piggy Banks';

  @override
  String get common_calendar => 'Calendar';

  @override
  String get common_lessons => 'Lessons';

  @override
  String get common_settings => 'Settings';

  @override
  String get common_tools => 'Tools';

  @override
  String get common_continue => 'Continue';

  @override
  String get common_confirm => 'Confirm';

  @override
  String get common_error => 'Error';

  @override
  String get common_tryAgain => 'Try again';

  @override
  String get balance => 'Balance';

  @override
  String get search => 'Search';

  @override
  String get reset => 'Reset';

  @override
  String get done => 'Done';

  @override
  String get moneyValidator_enterAmount => 'Please enter an amount';

  @override
  String get moneyValidator_notANumber => 'That doesn\'t look like a number';

  @override
  String get moneyValidator_mustBePositive =>
      'The amount must be greater than 0';

  @override
  String get moneyValidator_tooSmall => 'The amount is too small';

  @override
  String get bariOverlay_tipOfDay => 'Tip of the day';

  @override
  String get bariOverlay_defaultTip =>
      'Remember: every coin brings you closer to your goal!';

  @override
  String get bariOverlay_instructions =>
      'Tap Bari to open a tip. Double-tap for chat.';

  @override
  String get bariOverlay_openChat => 'Open Chat';

  @override
  String get bariOverlay_moreTips => 'Another tip';

  @override
  String get bariAvatar_happy => '😄';

  @override
  String get bariAvatar_encouraging => '🤔';

  @override
  String get bariAvatar_neutral => '😌';

  @override
  String mainScreen_transferToPiggyBank(String bankName) {
    return 'Transfer to piggy bank \"$bankName\" (from income)';
  }

  @override
  String get bariTip_income => 'Great income! What will you spend it on?';

  @override
  String get bariTip_expense => 'Spent. Was that in the plan?';

  @override
  String get bariTip_planCreated =>
      'Plan created! Sticking to it is the key to success.';

  @override
  String get bariTip_planCompleted => 'Plan completed! You are great!';

  @override
  String get bariTip_piggyBankCreated =>
      'New piggy bank! What are we saving for?';

  @override
  String get bariTip_piggyBankCompleted =>
      'Piggy bank is full! Congratulations on reaching your goal!';

  @override
  String get bariTip_lessonCompleted =>
      'Lesson completed! New knowledge is a superpower!';

  @override
  String get bariTip_levelUp => 'New level! You\'re growing as a financier!';

  @override
  String get period_day => 'Day';

  @override
  String get period_week => 'Week';

  @override
  String get period_month => 'Month';

  @override
  String get period_inADay => 'per day';

  @override
  String get period_inAWeek => 'per week';

  @override
  String get period_inAMonth => 'per month';

  @override
  String get period_everyDay => 'Every Day';

  @override
  String get period_onceAWeek => 'Once a Week';

  @override
  String get period_onceAMonth => 'Once a Month';

  @override
  String plural_days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: 'day',
    );
    return '$_temp0';
  }

  @override
  String get monthlyBudgetCalculator_title => 'Monthly Expense Plan';

  @override
  String get monthlyBudgetCalculator_subtitle =>
      'Set a limit and see the rest—it will be easier to control your money.';

  @override
  String get monthlyBudgetCalculator_step1 => 'Month';

  @override
  String get monthlyBudgetCalculator_step2 => 'Limit';

  @override
  String get monthlyBudgetCalculator_step3 => 'Result';

  @override
  String get monthlyBudgetCalculator_selectMonth => '1) Select month';

  @override
  String get monthlyBudgetCalculator_setLimit => '2) Set a limit';

  @override
  String get monthlyBudgetCalculator_limitForMonth => 'Limit for the month';

  @override
  String get monthlyBudgetCalculator_result => 'Result';

  @override
  String get monthlyBudgetCalculator_spent => 'Spent';

  @override
  String get monthlyBudgetCalculator_remaining => 'Remaining';

  @override
  String get monthlyBudgetCalculator_warningAlmostLimit =>
      '⚠️ Limit almost reached! Try to reduce spending in the remaining days.';

  @override
  String monthlyBudgetCalculator_warningOverLimit(String amount) {
    return 'You are over the limit by $amount. You can reconsider the limit or find where to save.';
  }

  @override
  String get goalDateCalculator_title => 'When Will I Reach My Goal?';

  @override
  String get goalDateCalculator_subtitle =>
      'Enter the contribution amount and frequency—I\'ll show you the approximate achievement date.';

  @override
  String get goalDateCalculator_stepGoal => 'Goal';

  @override
  String get goalDateCalculator_stepContribution => 'Contribution';

  @override
  String get goalDateCalculator_stepFrequency => 'Frequency';

  @override
  String get goalDateCalculator_headerGoal => '1) Goal';

  @override
  String get goalDateCalculator_piggyBankLabel => 'Piggy Bank';

  @override
  String goalDateCalculator_remainingToGoal(String amount) {
    return 'Remaining: $amount';
  }

  @override
  String get goalDateCalculator_headerContribution =>
      '2) How much do you set aside';

  @override
  String get goalDateCalculator_contributionAmountLabel =>
      'Contribution amount';

  @override
  String get goalDateCalculator_headerFrequency => '3) Frequency';

  @override
  String get goalDateCalculator_result => 'Result';

  @override
  String get goalDateCalculator_goalAlreadyReached =>
      'The goal is already reached—you can set a new one!';

  @override
  String goalDateCalculator_resultSummary(int count, String period) {
    return 'In about $count contributions (every $period)';
  }

  @override
  String get goalDateCalculator_upcomingDates => 'Upcoming dates:';

  @override
  String get goalDateCalculator_createPlanButton => 'Create Contribution Plan';

  @override
  String get goalDateCalculator_dialogTitle => 'Confirmation';

  @override
  String get goalDateCalculator_dialogSubtitle => 'Creating scheduled events';

  @override
  String goalDateCalculator_dialogContent(String goalName) {
    return 'Create scheduled events for contributions to the piggy bank \"$goalName\"?';
  }

  @override
  String get goalDateCalculator_defaultGoalName => 'goal';

  @override
  String goalDateCalculator_dialogContributionAmount(String amount) {
    return 'Contribution amount: $amount';
  }

  @override
  String goalDateCalculator_dialogFrequency(String period) {
    return 'Frequency: every $period';
  }

  @override
  String goalDateCalculator_eventName(String goalName) {
    return 'Contribution to piggy bank \"$goalName\"';
  }

  @override
  String get piggyPlanCalculator_title => 'Piggy Bank Plan';

  @override
  String get piggyPlanCalculator_subtitle =>
      'I\'ll help you figure out how much and how often to save to reach your goal.';

  @override
  String get piggyPlanCalculator_stepGoal => 'Goal';

  @override
  String get piggyPlanCalculator_stepDate => 'Date';

  @override
  String get piggyPlanCalculator_stepFrequency => 'Frequency';

  @override
  String get piggyPlanCalculator_headerSelectGoal => '1) Select a goal';

  @override
  String get piggyPlanCalculator_goalAmountLabel => 'Goal (amount)';

  @override
  String get piggyPlanCalculator_currentAmountLabel => 'Already have';

  @override
  String get piggyPlanCalculator_headerTargetDate =>
      '2) When do you want to reach the goal?';

  @override
  String get piggyPlanCalculator_selectDate => 'Select a date';

  @override
  String get piggyPlanCalculator_headerFrequency => '3) How often to save?';

  @override
  String get piggyPlanCalculator_result => 'Result';

  @override
  String piggyPlanCalculator_resultSummary(
    String amount,
    String period,
    int count,
  ) {
    return 'Save about $amount every $period (total contributions: $count).';
  }

  @override
  String piggyPlanCalculator_planCreatedSnackbar(String amount, String period) {
    return 'Plan created: $amount every $period';
  }

  @override
  String get piggyPlanCalculator_scheduleFirstContributionButton =>
      'Schedule First Contribution';

  @override
  String piggyPlanCalculator_dialogContributionAmount(String amount) {
    return 'Amount: $amount';
  }

  @override
  String get canIBuyCalculator_title => 'Can I buy it?';

  @override
  String get canIBuyCalculator_subtitle =>
      'Let\'s check the purchase right now and considering the plans for the week.';

  @override
  String get canIBuyCalculator_stepPrice => 'Price';

  @override
  String get canIBuyCalculator_stepMoney => 'Money';

  @override
  String get canIBuyCalculator_stepRules => 'Rules';

  @override
  String get canIBuyCalculator_headerPrice => '1) Purchase price';

  @override
  String get canIBuyCalculator_priceLabel => 'Price';

  @override
  String get canIBuyCalculator_headerAvailableMoney =>
      '2) How much money is available';

  @override
  String get canIBuyCalculator_walletBalanceLabel => 'In the wallet now';

  @override
  String get canIBuyCalculator_headerRules => '3) Rules';

  @override
  String get canIBuyCalculator_ruleDontTouchPiggies =>
      'Don\'t touch piggy banks';

  @override
  String get canIBuyCalculator_ruleDontTouchPiggiesSubtitleEnabled =>
      'Counting only the wallet';

  @override
  String get canIBuyCalculator_ruleDontTouchPiggiesSubtitleDisabled =>
      'Can use money from piggy banks as a reserve';

  @override
  String get canIBuyCalculator_ruleConsiderPlans => 'Consider plans for 7 days';

  @override
  String get canIBuyCalculator_ruleConsiderPlansSubtitle =>
      'Scheduled income/expenses from the calendar';

  @override
  String get canIBuyCalculator_result => 'Result';

  @override
  String get canIBuyCalculator_statusYes => 'You can buy it now';

  @override
  String get canIBuyCalculator_statusYesBut =>
      'You can buy it now, but plans for the week might interfere';

  @override
  String get canIBuyCalculator_statusMaybeWithPiggies =>
      'Possible, if you take some from a piggy bank';

  @override
  String get canIBuyCalculator_statusMaybeWithPlans =>
      'Not enough yet, but plans/income for the week might help';

  @override
  String canIBuyCalculator_statusNo(String amount) {
    return 'Better to wait: you are short by $amount';
  }

  @override
  String get canIBuyCalculator_planPurchaseButton => 'Plan the purchase';

  @override
  String get canIBuyCalculator_dialogTitle => 'Confirmation';

  @override
  String get canIBuyCalculator_dialogSubtitle => 'Creating a scheduled event';

  @override
  String get canIBuyCalculator_dialogContent =>
      'Create a scheduled event for the purchase?';

  @override
  String canIBuyCalculator_dialogAmount(String amount) {
    return 'Amount: $amount';
  }

  @override
  String get canIBuyCalculator_dialogInfo =>
      'The event will be created for 7 days ahead.';

  @override
  String get canIBuyCalculator_defaultEventName => 'Purchase';

  @override
  String get toolsHub_subtitle => 'Calculate, plan, improve';

  @override
  String get toolsHub_bariTipTitle => 'Bari\'s Tip';

  @override
  String get toolsHub_tipCalculators =>
      'Calculators will help you plan and calculate. Try starting with the \"Piggy Bank Plan\"!';

  @override
  String get toolsHub_tipEarningsLab =>
      'In the Earnings Lab, you can complete tasks and earn money. Start with the simple ones!';

  @override
  String get toolsHub_tipMiniTrainers =>
      '60-second trainers will help you quickly improve your skills. Consistency is more important than speed!';

  @override
  String get toolsHub_tipBariRecommendations =>
      'Bari\'s Tip of the Day is updated daily. Check back often for new ideas!';

  @override
  String get toolsHub_calendarForecastTitle => 'Calendar Forecast';

  @override
  String get toolsHub_calendarForecastSubtitle =>
      'Future balance and all scheduled events';

  @override
  String get toolsHub_calculatorsTitle => 'Calculators';

  @override
  String get toolsHub_calculatorsSubtitle => '8 useful financial calculators';

  @override
  String get toolsHub_earningsLabTitle => 'Earnings Lab';

  @override
  String get toolsHub_earningsLabSubtitle => 'Tasks and missions to earn money';

  @override
  String get toolsHub_miniTrainersTitle => '60 Seconds';

  @override
  String get toolsHub_miniTrainersSubtitle => 'Micro-exercises for training';

  @override
  String get toolsHub_recommendationsTitle => 'Tip of the Day';

  @override
  String get toolsHub_recommendationsSubtitle =>
      'A selection of tips and explanations from Bari';

  @override
  String get toolsHub_notesTitle => 'Notes';

  @override
  String get toolsHub_notesSubtitle => 'Create and organize your notes';

  @override
  String get toolsHub_tipNotes =>
      'Notes will help you remember important thoughts. Pin the most important ones!';

  @override
  String get piggyBanks_explanationSimple =>
      'A piggy bank is a separate goal. The money in it does not affect your balance.';

  @override
  String get piggyBanks_explanationPro =>
      'A piggy bank is a separate goal for savings. The money you put in a piggy bank does not affect your main balance. This helps you see your progress towards a specific goal.';

  @override
  String get piggyBanks_deleteConfirmTitle => 'Delete piggy bank?';

  @override
  String piggyBanks_deleteConfirmMessage(String name) {
    return 'Are you sure you want to delete the piggy bank \"$name\"? All related transactions will remain in history, but the piggy bank itself will be deleted.';
  }

  @override
  String piggyBanks_deleteSuccess(String name) {
    return 'Piggy bank \"$name\" deleted';
  }

  @override
  String piggyBanks_deleteError(String error) {
    return 'Error deleting: $error';
  }

  @override
  String get piggyBanks_emptyStateTitle => 'No piggy banks';

  @override
  String get piggyBanks_createNewTooltip => 'Create a new piggy bank';

  @override
  String get piggyBanks_createNewButton => 'Create a piggy bank';

  @override
  String get piggyBanks_addNewButton => 'Add a new piggy bank';

  @override
  String get piggyBanks_fabTooltip => 'Create a piggy bank';

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
  String get piggyBanks_card_deleteTooltip => 'Delete';

  @override
  String get piggyBanks_card_goalReached => '✓ Goal reached!';

  @override
  String piggyBanks_card_estimatedDate(String date) {
    return 'You will reach it by $date';
  }

  @override
  String get piggyBanks_progress_goalReached => 'Goal reached! 🎉';

  @override
  String piggyBanks_progress_almostThere(String amount) {
    return 'Almost there! Just $amount to go';
  }

  @override
  String get piggyBanks_progress_halfway => 'More than halfway there! 💪';

  @override
  String piggyBanks_progress_quarter(String amount) {
    return 'A quarter of the way. $amount to go';
  }

  @override
  String get piggyBanks_progress_started => 'A good start 🌱';

  @override
  String piggyBanks_progress_initialGoal(String amount) {
    return 'Goal is $amount';
  }

  @override
  String get piggyBanks_createSheet_title => 'New Piggy Bank';

  @override
  String get piggyBanks_createSheet_nameLabel => 'Piggy bank name';

  @override
  String get piggyBanks_createSheet_nameHint => 'e.g., New Phone';

  @override
  String get piggyBanks_createSheet_targetLabel => 'Target amount';

  @override
  String get piggyBanks_detail_deleteTooltip => 'Delete piggy bank';

  @override
  String piggyBanks_detail_fromAmount(String amount) {
    return 'of $amount';
  }

  @override
  String get piggyBanks_detail_topUpButton => 'Top Up';

  @override
  String get piggyBanks_detail_withdrawButton => 'Withdraw';

  @override
  String get piggyBanks_detail_autofillTitle => 'Auto-fill';

  @override
  String get piggyBanks_detail_autofillRuleLabel => 'Rule';

  @override
  String get piggyBanks_detail_autofillTypePercent => 'Percentage';

  @override
  String get piggyBanks_detail_autofillTypeFixed => 'Fixed amount';

  @override
  String get piggyBanks_detail_autofillPercentLabel => 'Percentage of income';

  @override
  String get piggyBanks_detail_autofillFixedLabel => 'Fixed amount';

  @override
  String get piggyBanks_detail_autofillEnabledSnackbar =>
      'Auto-saving is like an invisible habit.';

  @override
  String get piggyBanks_detail_whenToReachGoalTitle =>
      'When will I reach the goal?';

  @override
  String get piggyBanks_detail_calculateButton => 'Calculate';

  @override
  String get piggyBanks_detail_goalExceededTitle => 'Goal will be exceeded!';

  @override
  String piggyBanks_detail_goalExceededMessage(
    String name,
    String amount,
    String newAmount,
    String targetAmount,
  ) {
    return 'When adding $amount to the piggy bank \"$name\", the new amount will be $newAmount, which exceeds the goal of $targetAmount. Continue?';
  }

  @override
  String piggyBanks_detail_topUpTransactionNote(String name) {
    return 'Top up piggy bank \"$name\"';
  }

  @override
  String get piggyBanks_detail_successAnimationGoalReached =>
      '🎉 Goal reached!';

  @override
  String piggyBanks_detail_successAnimationDaysCloser(
    String amount,
    int count,
    String days,
  ) {
    return '+$amount • Goal is $count $days closer 🚀';
  }

  @override
  String piggyBanks_detail_successAnimationSimpleTopUp(String amount) {
    return 'Piggy bank topped up by $amount';
  }

  @override
  String get piggyBanks_detail_noFundsError =>
      'No funds in the piggy bank to withdraw.';

  @override
  String get piggyBanks_detail_noOtherPiggiesError =>
      'No other piggy banks to transfer to.';

  @override
  String get piggyBanks_detail_insufficientFundsError =>
      'Insufficient funds in the piggy bank.';

  @override
  String piggyBanks_detail_withdrawToWalletNote(String name) {
    return 'Withdrawal from piggy bank \"$name\" → wallet';
  }

  @override
  String piggyBanks_detail_withdrawToWalletSnackbar(String amount) {
    return '$amount transferred to wallet';
  }

  @override
  String piggyBanks_detail_spendFromPiggyNote(String name) {
    return 'Purchase from piggy bank \"$name\"';
  }

  @override
  String piggyBanks_detail_spendFromPiggySnackbar(String amount) {
    return 'Spent $amount from the piggy bank';
  }

  @override
  String piggyBanks_detail_transferNote(String fromBank, String toBank) {
    return 'Transfer between piggy banks: \"$fromBank\" → \"$toBank\"';
  }

  @override
  String piggyBanks_detail_transferSnackbar(String amount, String toBank) {
    return '$amount transferred to \"$toBank\"';
  }

  @override
  String get piggyBanks_operationSheet_addTitle => 'Top up piggy bank';

  @override
  String get piggyBanks_operationSheet_transferTitle =>
      'Transfer to another piggy bank';

  @override
  String get piggyBanks_operationSheet_spendTitle => 'Spend from piggy bank';

  @override
  String get piggyBanks_operationSheet_withdrawTitle => 'Withdraw to wallet';

  @override
  String get piggyBanks_operationSheet_amountLabel => 'Amount';

  @override
  String piggyBanks_operationSheet_maxAmountHint(String amount) {
    return 'Maximum: $amount';
  }

  @override
  String get piggyBanks_operationSheet_enterAmountHint => 'Enter amount';

  @override
  String get piggyBanks_operationSheet_categoryLabel => 'Category';

  @override
  String get piggyBanks_operationSheet_categoryHint => 'Select category';

  @override
  String get piggyBanks_operationSheet_categoryFood => 'Food';

  @override
  String get piggyBanks_operationSheet_categoryTransport => 'Transport';

  @override
  String get piggyBanks_operationSheet_categoryEntertainment => 'Entertainment';

  @override
  String get piggyBanks_operationSheet_categoryOther => 'Other';

  @override
  String get piggyBanks_operationSheet_noteLabel => 'Purchase name (optional)';

  @override
  String get piggyBanks_operationSheet_noteHint => 'Enter name...';

  @override
  String get piggyBanks_operationSheet_errorTooMuch =>
      'The amount exceeds the available funds';

  @override
  String get piggyBanks_operationSheet_errorInvalid =>
      'Please enter a valid amount';

  @override
  String get piggyBanks_withdrawMode_title => 'What to do with the money?';

  @override
  String get piggyBanks_withdrawMode_toWalletTitle => 'To wallet';

  @override
  String get piggyBanks_withdrawMode_toWalletSubtitle =>
      'Wallet +, Piggy Bank −';

  @override
  String get piggyBanks_withdrawMode_spendTitle =>
      'Spend directly from piggy bank';

  @override
  String get piggyBanks_withdrawMode_spendSubtitle =>
      'Wallet unchanged, Piggy Bank −';

  @override
  String get piggyBanks_withdrawMode_transferTitle =>
      'Transfer to another piggy bank';

  @override
  String get piggyBanks_withdrawMode_transferSubtitle =>
      'Wallet unchanged, Piggy Bank A −, Piggy Bank B +';

  @override
  String get piggyBanks_picker_title => 'Choose a piggy bank to transfer to';

  @override
  String get piggyBanks_picker_defaultTitle => 'Choose a piggy bank';

  @override
  String get balance_currentBalance => 'Current Balance';

  @override
  String get balance_forecast => 'Forecast';

  @override
  String get balance_fact => 'Fact';

  @override
  String get balance_withPlannedExpenses => 'Including planned expenses';

  @override
  String get balance_forecastForDay => 'Day forecast';

  @override
  String get balance_forecastForWeek => 'Week forecast';

  @override
  String get balance_forecastForMonth => 'Month forecast';

  @override
  String get balance_forecastFor3Months => '3 months forecast';

  @override
  String balance_level(int level) {
    return 'Level $level';
  }

  @override
  String get balance_toolsDescription =>
      'Calculators and tools for financial planning';

  @override
  String get balance_tools => 'Tools';

  @override
  String get balance_filterDay => 'Day';

  @override
  String get balance_filterWeek => 'Week';

  @override
  String get balance_filterMonth => 'Month';

  @override
  String get balance_emptyStateIncome => 'Nothing here yet. Add some income!';

  @override
  String get balance_emptyStateNoTransactions =>
      'No transactions for the selected period';

  @override
  String get balance_addIncome => 'Add income';

  @override
  String get balance_addExpense => 'Add expense';

  @override
  String get balance_amount => 'Amount';

  @override
  String get balance_category => 'Category';

  @override
  String get balance_selectCategory => 'Select category';

  @override
  String get balance_toPiggyBank => 'To piggy bank (optional)';

  @override
  String get balance_fromPiggyBank => 'From piggy bank (optional)';

  @override
  String get balance_note => 'Note';

  @override
  String get balance_noteHint => 'Enter a note...';

  @override
  String get balance_save => 'Save';

  @override
  String get balance_categories_food => 'Food';

  @override
  String get balance_categories_transport => 'Transport';

  @override
  String get balance_categories_games => 'Games';

  @override
  String get balance_categories_clothing => 'Clothing';

  @override
  String get balance_categories_entertainment => 'Entertainment';

  @override
  String get balance_categories_other => 'Other';

  @override
  String get balance_categories_pocketMoney => 'Pocket money';

  @override
  String get balance_categories_gift => 'Gift';

  @override
  String get balance_categories_sideJob => 'Side job';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_selectCurrency => 'Select currency';

  @override
  String get settings_appearance => 'Appearance';

  @override
  String get settings_theme => 'Theme';

  @override
  String get settings_themeBlue => 'Blue';

  @override
  String get settings_themePurple => 'Purple';

  @override
  String get settings_themeGreen => 'Green';

  @override
  String get settings_explanationMode => 'Explanation mode';

  @override
  String get settings_howToExplain => 'How to explain';

  @override
  String get settings_uxSimple => 'Simple';

  @override
  String get settings_uxPro => 'Pro';

  @override
  String get settings_uxSimpleDescription => 'Simple explanations';

  @override
  String get settings_uxProDescription => 'Detailed explanations';

  @override
  String get settings_currency => 'Currency';

  @override
  String get settings_notifications => 'Notifications';

  @override
  String get settings_dailyExpenseReminder => 'Daily expense reminders';

  @override
  String get settings_dailyExpenseReminderDescription =>
      'Daily evening reminders to log expenses';

  @override
  String get settings_weeklyReview => 'Weekly reviews';

  @override
  String get settings_weeklyReviewDescription =>
      'Reminders to review weekly progress';

  @override
  String get settings_levelUpNotifications => 'Level up notifications';

  @override
  String get settings_levelUpNotificationsDescription =>
      'Notifications when reaching a new level';

  @override
  String get achievements_title => 'Achievements';

  @override
  String get achievements_empty => 'No achievements';

  @override
  String achievements_unlockedCount(int count) {
    return 'Unlocked achievements: $count';
  }

  @override
  String achievements_unlockedAt(String date) {
    return 'Unlocked: $date';
  }

  @override
  String get notifications_dailyReminderTitle => 'Bari reminds';

  @override
  String get notifications_dailyReminderBody =>
      'Don\'t forget to log today\'s expenses! 💰';

  @override
  String get notifications_weeklyReviewTitle => 'Bari reminds';

  @override
  String get notifications_weeklyReviewBody =>
      'Time to review the week! See how much you saved 📊';

  @override
  String get notifications_levelUpTitle => '🎉 New level!';

  @override
  String notifications_levelUpBody(int level) {
    return 'Congratulations! You reached level $level';
  }

  @override
  String get notifications_channelName => 'Bari Reminders';

  @override
  String get notifications_channelDescription => 'Personal reminders from Bari';

  @override
  String get notifications_levelUpChannelName => 'Level Up';

  @override
  String get notifications_levelUpChannelDescription =>
      'Level up notifications';

  @override
  String get charts_expensesByCategory => 'Expenses by category';

  @override
  String get charts_incomeByCategory => 'Income by category';

  @override
  String get settings_bari => 'Bari Smart';

  @override
  String get settings_bariMode => 'Bari mode';

  @override
  String get settings_bariModeOffline => 'Offline';

  @override
  String get settings_bariModeOnline => 'Online';

  @override
  String get settings_bariModeHybrid => 'Hybrid';

  @override
  String get settings_showSources => 'Show sources';

  @override
  String get settings_showSourcesDescription => 'Show sources for tips';

  @override
  String get settings_smallTalk => 'Small talk';

  @override
  String get settings_smallTalkDescription => 'Allow small talk with Bari';

  @override
  String get settings_parentZone => 'Parent zone';

  @override
  String get settings_parentZoneDescription => 'Manage approvals and settings';

  @override
  String get settings_tools => 'Tools';

  @override
  String get settings_toolsDescription => 'Calculators and other tools';

  @override
  String get settings_exportData => 'Export data';

  @override
  String get settings_importData => 'Import data';

  @override
  String get settings_resetProgress => 'Reset progress';

  @override
  String get settings_resetProgressWarning =>
      'Are you sure you want to reset all progress? This action cannot be undone.';

  @override
  String get settings_cancel => 'Cancel';

  @override
  String get settings_progressReset => 'Progress reset';

  @override
  String get settings_enterPinToConfirm => 'Enter PIN to confirm';

  @override
  String get settings_wrongPin => 'Wrong PIN';

  @override
  String get priceComparisonCalculator_factSaved => 'Fact saved';

  @override
  String get twentyFourHourRuleCalculator_enterItemName => 'Enter item name';

  @override
  String get twentyFourHourRuleCalculator_reminderSet => 'Reminder set';

  @override
  String get twentyFourHourRuleCalculator_no => 'No';

  @override
  String get subscriptionsCalculator_no => 'No';

  @override
  String get subscriptionsCalculator_repeatDaily => 'Daily';

  @override
  String get subscriptionsCalculator_repeatWeekly => 'Weekly';

  @override
  String get subscriptionsCalculator_repeatMonthly => 'Monthly';

  @override
  String get subscriptionsCalculator_repeatYearly => 'Yearly';

  @override
  String get subscriptionsCalculator_enterSubscriptionName =>
      'Enter subscription name';

  @override
  String get calendar_completed => 'Completed';

  @override
  String get calendar_edit => 'Edit';

  @override
  String get calendar_reschedule => 'Reschedule';

  @override
  String get calendar_completeNow => 'Complete now';

  @override
  String get calendar_showTransaction => 'Show transaction';

  @override
  String get calendar_restore => 'Restore';

  @override
  String get calendar_eventAlreadyCompleted => 'Event already completed';

  @override
  String get calendar_noPiggyBanks => 'No piggy banks';

  @override
  String get calendar_eventAlreadyCompletedWithTx =>
      'Event already completed. Transaction created.';

  @override
  String get calendar_sentToParentForApproval => 'Sent to parent for approval';

  @override
  String get calendar_addedToPiggyBank => 'added to piggy bank';

  @override
  String calendar_eventCompletedWithAmount(String amount) {
    return 'Event completed: $amount';
  }

  @override
  String get calendar_planContinues => 'Plan continues';

  @override
  String get calendar_cancelEvent => 'Cancel event';

  @override
  String get calendar_cancelEventMessage =>
      'Are you sure you want to cancel this event?';

  @override
  String get calendar_no => 'No';

  @override
  String get calendar_yesCancel => 'Yes, cancel';

  @override
  String get calendar_wantToReschedule =>
      'Do you want to reschedule the event?';

  @override
  String get calendar_eventRestored => 'Event restored';

  @override
  String get calendar_eventUpdated => 'Event updated';

  @override
  String get calendar_deleteEventConfirm => 'Delete event?';

  @override
  String get calendar_deleteEventSeriesMessage => 'Delete entire event series?';

  @override
  String get calendar_deleteAllRepeatingConfirm =>
      'All repeating events will be deleted. This action cannot be undone.';

  @override
  String get calendar_undo => 'Undo';

  @override
  String get calendar_editScopeTitle => 'What to edit?';

  @override
  String get calendar_editScopeSubtitle => 'Select the scope of changes';

  @override
  String get calendar_editThisEventOnly => 'This event only';

  @override
  String get calendar_editThisEventOnlyDesc =>
      'Changes will affect only the selected event';

  @override
  String get calendar_editAllRepeating => 'All repetitions';

  @override
  String get calendar_editAllRepeatingDesc =>
      'Changes will apply to all events in the series';

  @override
  String get calendar_deleteScopeTitle => 'What to delete?';

  @override
  String get calendar_deleteScopeSubtitle => 'Select the scope of deletion';

  @override
  String get calendar_deleteAllRepeatingDesc =>
      'All events in the series will be deleted';

  @override
  String get calendar_cancel => 'Cancel';

  @override
  String get calendar_transactionNotFound => 'Transaction not found';

  @override
  String get calendar_transaction => 'Transaction';

  @override
  String get calendar_transactionAmount => 'Amount';

  @override
  String get calendar_transactionDate => 'Date';

  @override
  String get calendar_transactionCategory => 'Category';

  @override
  String get calendar_transactionNote => 'Note';

  @override
  String get deletedEvents_title => 'Deleted events';

  @override
  String get deletedEvents_empty => 'Trash is empty';

  @override
  String deletedEvents_count(int count) {
    return '$count events';
  }

  @override
  String get deletedEvents_restore => 'Restore';

  @override
  String get deletedEvents_deletePermanent => 'Delete permanently';

  @override
  String get deletedEvents_deletedAt => 'Deleted:';

  @override
  String get deletedEvents_restored => 'Event restored';

  @override
  String get deletedEvents_deleted => 'Event deleted permanently';

  @override
  String get deletedEvents_permanentDeleteTitle => 'Delete permanently?';

  @override
  String get deletedEvents_permanentDeleteMessage =>
      'This action cannot be undone. The event will be deleted without the possibility of recovery.';

  @override
  String get deletedEvents_clearOld => 'Clear old';

  @override
  String get deletedEvents_clearOldTitle => 'Clear old events?';

  @override
  String get deletedEvents_clearOldMessage =>
      'Delete events that have been in the trash for more than 30 days?';

  @override
  String deletedEvents_clearedCount(int count) {
    return 'Deleted $count events';
  }

  @override
  String get deletedEvents_restoreScopeTitle => 'What to restore?';

  @override
  String get deletedEvents_restoreScopeMessage =>
      'Select the scope of restoration';

  @override
  String get subscriptions_filter => 'Filter';

  @override
  String get subscriptions_all => 'All';

  @override
  String get subscriptions_income => 'Income';

  @override
  String get subscriptions_expense => 'Expenses';

  @override
  String get subscriptions_type => 'Type';

  @override
  String get bariChat_title => 'Chat with Bari';

  @override
  String get bariChat_welcomeDefault =>
      'Hi! I\'m Bari, your financial literacy assistant. How can I help?';

  @override
  String get bariChat_welcomeCalculator =>
      'Hi! You\'re using a calculator. Need help with calculations?';

  @override
  String get bariChat_welcomePiggyBank =>
      'Hi! Talking about a piggy bank? Tell me what you want to know!';

  @override
  String get bariChat_welcomePlannedEvent =>
      'Hi! You have a planned event. Questions about planning?';

  @override
  String get bariChat_welcomeLesson =>
      'Hi! You\'re taking a lesson. Something unclear? Ask me!';

  @override
  String bariChat_welcomeTask(String title) {
    return 'Hi! Let\'s talk about the task \"$title\"? I can help with the reward, time, or difficulty.';
  }

  @override
  String get bariChat_fallbackResponse =>
      'Sorry, I didn\'t understand. Try rephrasing your question.';

  @override
  String get bariChat_source => 'Source';

  @override
  String get bariChat_close => 'Close';

  @override
  String get bariChat_inputHint => 'Type a message...';

  @override
  String get bariChat_thinking => 'Thinking...';

  @override
  String get bariChat_task => 'task';

  @override
  String get calculatorsList_title => 'Calculators';

  @override
  String get calculatorsList_piggyPlan => 'Piggy Bank Plan';

  @override
  String get calculatorsList_piggyPlanDesc => 'How much to save for a goal';

  @override
  String get calculatorsList_goalDate => 'When Will I Reach My Goal';

  @override
  String get calculatorsList_goalDateDesc =>
      'Achievement date with regular contributions';

  @override
  String get calculatorsList_monthlyBudget => 'Monthly Expense Plan';

  @override
  String get calculatorsList_monthlyBudgetDesc =>
      'Limit and remaining for the month';

  @override
  String get calculatorsList_subscriptions =>
      'Subscriptions & Regular Payments';

  @override
  String get calculatorsList_subscriptionsDesc =>
      'How much regular expenses cost';

  @override
  String get calculatorsList_canIBuy => 'Can I Buy It Now?';

  @override
  String get calculatorsList_canIBuyDesc => 'Check purchase affordability';

  @override
  String get calculatorsList_priceComparison => 'Price Comparison';

  @override
  String get calculatorsList_priceComparisonDesc => 'What\'s a better deal';

  @override
  String get calculatorsList_24hRule => '24-Hour Rule';

  @override
  String get calculatorsList_24hRuleDesc => 'Delay impulsive purchases';

  @override
  String get calculatorsList_budget503020 => '50/30/20 Budget';

  @override
  String get calculatorsList_budget503020Desc => 'Income distribution';

  @override
  String get earningsLab_title => 'Earnings Lab';

  @override
  String get earningsLab_explanationSimple =>
      'Plan task → complete it in calendar → get reward.';

  @override
  String get earningsLab_explanationPro =>
      'Earnings Lab: first plan a task for a date, then mark it as completed in the calendar. Reward will be credited automatically. Planning helps not to forget important things.';

  @override
  String get earningsLab_taskAdded => 'Task added!';

  @override
  String get earningsLab_tabQuick => 'Quick';

  @override
  String get earningsLab_tabHome => 'Home';

  @override
  String get earningsLab_tabProjects => 'Projects';

  @override
  String get earningsLab_helpAtHome => 'Help at Home';

  @override
  String get earningsLab_helpAtHomeDesc =>
      'Choose one task: dishes / trash / dust / floor / table. Do it for 10-15 minutes and complete it.';

  @override
  String get earningsLab_learnPoem => 'Learn a Poem';

  @override
  String get earningsLab_learnPoemDesc =>
      'Read 3 times, learn line by line, then recite without hints.';

  @override
  String get earningsLab_cleanRoom => 'Clean Your Room';

  @override
  String get earningsLab_cleanRoomDesc =>
      'Tidy up for 10-15 minutes: toys in place, clean desk, trash thrown out.';

  @override
  String get earningsLab_readBook => 'Read a Book';

  @override
  String get earningsLab_readBookDesc =>
      'Read a chapter from an interesting book. Reading develops imagination and vocabulary.';

  @override
  String get earningsLab_helpCooking => 'Help with Cooking';

  @override
  String get earningsLab_helpCookingDesc =>
      'Help parents prepare lunch or dinner. You\'ll learn to cook simple dishes!';

  @override
  String get earningsLab_homework => 'Do Homework';

  @override
  String get earningsLab_homeworkDesc =>
      'Complete all homework neatly and on time. This is your main job!';

  @override
  String get earningsLab_helpShopping => 'Help with Shopping';

  @override
  String get earningsLab_helpShoppingDesc =>
      'Go to the store with parents and help carry groceries. You\'ll learn to plan expenses!';

  @override
  String get earningsLab_tagLearning => 'learning';

  @override
  String get earningsLab_tagHelp => 'help';

  @override
  String get earningsLab_tagCreativity => 'creativity';

  @override
  String get rule24h_title => '24-Hour Rule';

  @override
  String get rule24h_subtitle =>
      'Helps avoid impulsive purchases: delay the decision for a day and check yourself again.';

  @override
  String get rule24h_step1 => 'Want';

  @override
  String get rule24h_step2 => 'Price';

  @override
  String get rule24h_step3 => 'Pause';

  @override
  String get rule24h_wantToBuy => 'I want to buy';

  @override
  String get rule24h_example => 'For example: headphones';

  @override
  String get rule24h_price => 'Price';

  @override
  String get rule24h_explanation =>
      'If you still want it after 24 hours — the purchase is more conscious. If not — you saved money and boosted self-control.';

  @override
  String get rule24h_postpone => 'Postpone for 24 hours';

  @override
  String get rule24h_reminderSet =>
      'Reminder set. Come back in 24 hours to check your desire again.';

  @override
  String get rule24h_checkAgain => 'Check again';

  @override
  String get rule24h_dialogTitle => 'Confirmation';

  @override
  String get rule24h_dialogSubtitle => 'Creating a reminder';

  @override
  String rule24h_dialogContent(String itemName) {
    return 'Create a reminder in 24 hours to check if you still want to buy \"$itemName\"?';
  }

  @override
  String get rule24h_reminderIn24h => 'Reminder will come in 24 hours';

  @override
  String rule24h_eventName(String itemName) {
    return 'Desire check: $itemName';
  }

  @override
  String get rule24h_checkTitle => 'Desire Check';

  @override
  String get rule24h_checkSubtitle => '24 hours have passed';

  @override
  String get rule24h_stillWant => 'Do you still want to buy this?';

  @override
  String get rule24h_yes => 'Yes';

  @override
  String get budget503020_title => '50/30/20 Budget';

  @override
  String get budget503020_subtitle =>
      'Divide your income into 3 parts: needs, wants, and savings.';

  @override
  String get budget503020_step1 => 'Income';

  @override
  String get budget503020_step2 => 'Distribution';

  @override
  String get budget503020_step3 => 'Piggy Banks';

  @override
  String get budget503020_incomeLabel => 'My monthly income';

  @override
  String get budget503020_needs50 => 'Needs (50%)';

  @override
  String get budget503020_wants30 => 'Wants (30%)';

  @override
  String get budget503020_savings20 => 'Savings (20%)';

  @override
  String get budget503020_tip =>
      'Tip: if you want to save faster — try starting with 10% in savings and gradually increase.';

  @override
  String get budget503020_createPiggyBanks => 'Create 3 piggy banks';

  @override
  String get budget503020_dialogTitle => 'Confirmation';

  @override
  String get budget503020_dialogSubtitle =>
      'Creating piggy banks using the 50/30/20 rule';

  @override
  String get priceComparison_title => 'Price Comparison';

  @override
  String get priceComparison_subtitle =>
      'Compare two options and find out which is better by unit price.';

  @override
  String get priceComparison_step1 => 'Option A';

  @override
  String get priceComparison_step2 => 'Option B';

  @override
  String get priceComparison_step3 => 'Result';

  @override
  String get priceComparison_priceA => 'Price A';

  @override
  String get priceComparison_quantityA => 'Quantity / weight A';

  @override
  String get priceComparison_priceB => 'Price B';

  @override
  String get priceComparison_quantityB => 'Quantity / weight B';

  @override
  String get priceComparison_result => 'Result';

  @override
  String get priceComparison_pricePerUnitA => 'Price per unit A';

  @override
  String get priceComparison_pricePerUnitB => 'Price per unit B';

  @override
  String priceComparison_betterOption(String option, String percent) {
    return 'Better: option $option (savings ~$percent%)';
  }

  @override
  String get priceComparison_saveForBari => 'Save conclusion for Bari';

  @override
  String get subscriptions_title => 'Subscriptions & Regular Payments';

  @override
  String get subscriptions_regular => 'Regular payment';

  @override
  String get calendar_today => 'Today';

  @override
  String get calendar_noEvents => 'No events';

  @override
  String calendar_eventsCount(int count, String events) {
    return '$count $events';
  }

  @override
  String get calendar_event => 'event';

  @override
  String get calendar_events234 => 'events';

  @override
  String get calendar_events5plus => 'events';

  @override
  String get calendar_freeDay => 'Free day';

  @override
  String get calendar_noEventsOnDay =>
      'Nothing planned for this day.\nMaybe it\'s time to add something?';

  @override
  String get calendar_startPlanning => 'Start planning! 🚀';

  @override
  String get calendar_createFirstEvent =>
      'Create your first event — it makes saving and remembering easier';

  @override
  String get calendar_createFirstPlan => 'Create first plan';

  @override
  String get calendar_addEvent => 'Add event';

  @override
  String get calendar_income => 'Income';

  @override
  String get calendar_expense => 'Expenses';

  @override
  String get calendar_done => 'Done';

  @override
  String get calendar_confirmCompletion => 'Confirm completion';

  @override
  String get calendar_amount => 'Amount';

  @override
  String get calendar_confirm => 'Confirm';

  @override
  String get calendar_rescheduleEvent => 'Reschedule event';

  @override
  String get calendar_dateAndTime => 'Date and time';

  @override
  String get calendar_notification => 'Notification';

  @override
  String get calendar_move => 'Move';

  @override
  String calendar_whereToAdd(String amount) {
    return 'Where to add $amount?';
  }

  @override
  String get calendar_toWallet => 'To wallet';

  @override
  String get calendar_availableForSpending => 'Available for spending';

  @override
  String get calendar_toPiggyBank => 'To piggy bank';

  @override
  String get calendar_forGoal => 'For a goal';

  @override
  String get calendar_selectPiggyBank => 'Select piggy bank';

  @override
  String get calendar_eventCompleted => 'Event completed! +15 XP';

  @override
  String get calendar_eventCancelled => 'Event cancelled';

  @override
  String get calendar_eventDeleted => 'Event deleted';

  @override
  String get calendar_eventCompletedXp => 'Event completed! +15 XP';

  @override
  String get calendar_invalidAmount => 'Please enter a valid amount';

  @override
  String get calendar_date => 'Date';

  @override
  String get calendar_time => 'Time';

  @override
  String get calendar_everyDay => 'Every day';

  @override
  String get calendar_everyWeek => 'Every week';

  @override
  String get calendar_everyMonth => 'Every month';

  @override
  String get calendar_everyYear => 'Every year';

  @override
  String get calendar_repeat => 'Repeat';

  @override
  String get calendar_noRepeat => 'None';

  @override
  String get calendar_deleteAction => 'This action cannot be undone.';

  @override
  String get calendar_week => 'Week';

  @override
  String get calendar_month => 'Month';

  @override
  String get parentZone_title => 'Parent Zone';

  @override
  String get parentZone_approvals => 'Pending approvals';

  @override
  String get parentZone_statistics => 'Statistics';

  @override
  String get parentZone_settings => 'Settings';

  @override
  String get parentZone_pinMustBe4Digits => 'PIN must contain 4 digits';

  @override
  String get parentZone_wrongPin => 'Wrong PIN';

  @override
  String get parentZone_pinChanged => 'PIN changed';

  @override
  String get parentZone_premiumUnlocked => 'Premium unlocked';

  @override
  String get parentZone_resetData => 'Reset data';

  @override
  String get parentZone_resetWarning =>
      'WARNING! This action will delete ALL application data.';

  @override
  String get parentZone_enterPinToConfirm => 'Enter PIN to confirm:';

  @override
  String get parentZone_pin => 'PIN';

  @override
  String get parentZone_reset => 'Reset';

  @override
  String get parentZone_allDataDeleted => 'All data deleted';

  @override
  String parentZone_resetError(String error) {
    return 'Reset error: $error';
  }

  @override
  String get parentZone_login => 'Login';

  @override
  String get parentZone_unlockPremium => 'Unlock premium';

  @override
  String get parentZone_edit => 'Edit';

  @override
  String get parentZone_close => 'Close';

  @override
  String get parentZone_aiSummaryTitle => 'AI Summary for Parents';

  @override
  String get parentZone_modelNotAvailable =>
      'Local model not available. Download model in settings.';

  @override
  String get parentZone_summaryGenerationFailed =>
      'Failed to generate summary. Please try again later.';

  @override
  String get parentZone_earningsApproved => 'Earnings approved';

  @override
  String get parentZone_earningsRejected => 'Earnings rejected';

  @override
  String get parentZone_enterPin => 'Enter PIN';

  @override
  String get parentZone_createPin => 'Create PIN';

  @override
  String get parentZone_premiumStatus => 'Premium';

  @override
  String get parentZone_premiumUnlockedStatus => 'Status: Unlocked';

  @override
  String get parentZone_premiumLockedStatus => 'Status: Locked';

  @override
  String get parentZone_statisticsTitle => 'Statistics';

  @override
  String get parentZone_statisticsSubtitle => 'Income, expenses, progress';

  @override
  String parentZone_pendingApprovals(int count) {
    return 'Pending Approval ($count)';
  }

  @override
  String get parentZone_pendingApprovalsSubtitle =>
      'Earnings requiring confirmation';

  @override
  String get parentZone_exportImport => 'Export / Import';

  @override
  String get parentZone_exportImportSubtitle => 'Save or load data';

  @override
  String get parentZone_resetDataSubtitle => 'Delete all data (requires PIN)';

  @override
  String get parentZone_changePin => 'Change PIN';

  @override
  String get parentZone_newPinLabel => 'New PIN (4 digits)';

  @override
  String get parentZone_earningsDefault => 'Earnings';

  @override
  String parentZone_photosCount(int count) {
    return '$count photos';
  }

  @override
  String get parentZone_reward => 'Reward';

  @override
  String get parentZone_childComment => 'Child\'s comment';

  @override
  String get parentZone_resultPhotos => 'Result photos';

  @override
  String get parentZone_rateQuality => 'Rate quality';

  @override
  String get parentZone_feedbackPlaceholder => 'Comment for child (optional)';

  @override
  String get parentZone_pinLabel => 'PIN (4 digits)';

  @override
  String get parentZone_reject => 'Reject';

  @override
  String get parentZone_approve => 'Approve';

  @override
  String get exportImport_title => 'Export/Import';

  @override
  String get exportImport_exportData => 'Export data';

  @override
  String get exportImport_exportDescription => 'Save all data to JSON file';

  @override
  String get exportImport_export => 'Export';

  @override
  String get exportImport_importData => 'Import data';

  @override
  String get exportImport_importDescription => 'Load data from JSON file';

  @override
  String get exportImport_import => 'Import';

  @override
  String get exportImport_dataCopied => 'Data copied to clipboard';

  @override
  String exportImport_exportError(String error) {
    return 'Export error: $error';
  }

  @override
  String get exportImport_importSuccess => 'Data successfully imported';

  @override
  String get exportImport_importError => 'Import error';

  @override
  String exportImport_importErrorDetails(String error) {
    return 'Failed to import data:\n$error';
  }

  @override
  String get exportImport_pasteJson => 'Paste JSON data';

  @override
  String get minitrainers_result => 'Result';

  @override
  String minitrainers_correctAnswers(int score, int total, int xp) {
    return 'Correct answers: $score/$total\n+$xp XP';
  }

  @override
  String get minitrainers_great => 'Great!';

  @override
  String get minitrainers_findExtraPurchase => 'Find the extra purchase';

  @override
  String get minitrainers_answer => 'Answer';

  @override
  String minitrainers_xpEarned(int xp) {
    return '+$xp XP';
  }

  @override
  String get minitrainers_buildBudget => 'Build budget';

  @override
  String get minitrainers_check => 'Check';

  @override
  String get minitrainers_wellDone => 'Well done!';

  @override
  String get minitrainers_xp15 => '+15 XP';

  @override
  String get minitrainers_discountOrTrap => 'Discount or trap?';

  @override
  String get minitrainers_yes => 'Yes';

  @override
  String get minitrainers_no => 'No';

  @override
  String get minitrainers_correct => 'Correct!';

  @override
  String get minitrainers_goodTry => 'Good try';

  @override
  String get calculators_3PiggyBanksCreated => '3 piggy banks created';

  @override
  String get rule24h_xp50 => '🎉 +50 XP for self-control!';

  @override
  String get subscriptions_frequency => 'Frequency';

  @override
  String get statistics_title => 'Statistics';

  @override
  String get calculators_nDaysSavings => 'Savings for N days';

  @override
  String get calculators_weeklySavings => 'Weekly savings';

  @override
  String get calculators_piggyGoal => 'Piggy bank goal';

  @override
  String get earningsLab_schedule => 'Schedule';

  @override
  String get recommendations_newTip => 'New tip';

  @override
  String get earningsHistory_title => 'Earnings history';

  @override
  String get earningsHistory_all => 'All';

  @override
  String get calendarForecast_7days => '7 days';

  @override
  String get calendarForecast_30days => '30 days';

  @override
  String get calendarForecast_90days => '90 days';

  @override
  String get calendarForecast_year => 'Year';

  @override
  String get calendarForecast_summary => 'Summary';

  @override
  String get calendarForecast_categories => 'Categories';

  @override
  String get calendarForecast_dates => 'Dates';

  @override
  String get calendarForecast_month => 'Month';

  @override
  String get calendarForecast_all => 'All';

  @override
  String get calendarForecast_income => 'Income';

  @override
  String get calendarForecast_expenses => 'Expenses';

  @override
  String get calendarForecast_large => 'Large';

  @override
  String get planEvent_amount => 'Amount';

  @override
  String get planEvent_nameOptional => 'Name (optional)';

  @override
  String get planEvent_category => 'Category';

  @override
  String get planEvent_date => 'Date';

  @override
  String get planEvent_time => 'Time';

  @override
  String get planEvent_repeat => 'Repeat';

  @override
  String get planEvent_notification => 'Notification';

  @override
  String get planEvent_remindBefore => 'Remind before';

  @override
  String get planEvent_atMoment => 'At moment';

  @override
  String get planEvent_15minutes => '15 minutes before';

  @override
  String get planEvent_30minutes => '30 minutes before';

  @override
  String get planEvent_1hour => '1 hour before';

  @override
  String get planEvent_1day => '1 day before';

  @override
  String get planEvent_eventChanged => 'Event changed';

  @override
  String get planEvent_repeatingEventWarning => 'Repeating event';

  @override
  String get planEvent_repeatingEventDescription =>
      'This event is part of a repeating series. Changes will apply to all future events.';

  @override
  String get calendar_editEvent => 'Edit event';

  @override
  String get calendar_planEvent => 'Plan event';

  @override
  String get planEvent_eventType => 'Event type';

  @override
  String get transaction_income => 'Income';

  @override
  String get transaction_expense => 'Expense';

  @override
  String get category_food => 'Food';

  @override
  String get category_transport => 'Transport';

  @override
  String get category_entertainment => 'Entertainment';

  @override
  String get category_other => 'Other';

  @override
  String get minitrainers_60seconds => '60 seconds';

  @override
  String get earningsLab_wrongPin => 'Wrong PIN. Parent approval required.';

  @override
  String get earningsLab_noPiggyBanks =>
      'No piggy banks. Create a piggy bank first.';

  @override
  String get earningsLab_sentForApproval => 'Sent to parent for approval';

  @override
  String get earningsLab_amountCannotBeNegative => 'Amount cannot be negative';

  @override
  String get earningsLab_wallet => 'Wallet';

  @override
  String get earningsLab_piggyBank => 'Piggy Bank';

  @override
  String get earningsLab_no => 'No';

  @override
  String get earningsLab_daily => 'Daily';

  @override
  String get earningsLab_weekly => 'Weekly';

  @override
  String get earningsLab_reminder => 'Reminder';

  @override
  String get earningsLab_selectPiggyForReward => 'Select piggy bank for reward';

  @override
  String get earningsLab_createPlan => 'Create plan';

  @override
  String get earningsLab_discussWithBari => 'Discuss with Bari';

  @override
  String get earningsLab_parentApprovalRequired => 'Parent approval required';

  @override
  String get earningsLab_fillRequiredFields => 'Please fill in required fields';

  @override
  String earningsLab_completed(String title) {
    return 'Completed: $title';
  }

  @override
  String get earningsLab_howMuchEarned => 'How much did you earn?';

  @override
  String get earningsLab_whatWasDifficult => 'What was difficult?';

  @override
  String get earningsLab_addCustomTask => 'Add custom task';

  @override
  String get earningsLab_canRepeat => 'Can repeat';

  @override
  String get earningsLab_requiresParent => 'Requires parent';

  @override
  String get earningsLab_taskName => 'Task name *';

  @override
  String get earningsLab_taskNameHint => 'For example: Help grandma';

  @override
  String get earningsLab_description => 'Description';

  @override
  String get earningsLab_descriptionHint => 'What needs to be done?';

  @override
  String get earningsLab_descriptionOptional => 'Description (optional)';

  @override
  String get earningsLab_descriptionOptionalHint =>
      'For example: what exactly needs to be done';

  @override
  String get earningsLab_time => 'Time *';

  @override
  String get earningsLab_timeHint => 'For example: 30 min';

  @override
  String get earningsLab_reward => 'Reward';

  @override
  String get earningsLab_xp => 'XP';

  @override
  String get earningsLab_difficulty => 'Difficulty';

  @override
  String get earningsLab_repeat => 'Repeat';

  @override
  String get earningsLab_rewardMustBePositive =>
      'Reward must be greater than zero';

  @override
  String get earningsLab_taskDescription => 'No description';

  @override
  String get earningsLab_rewardHelper => 'How much will you get for completion';

  @override
  String get earningsLab_taskNameRequired => 'Enter task name';

  @override
  String get bari_goal_noPiggyBanks => 'You don\'t have any piggy banks yet.';

  @override
  String get bari_goal_noPiggyBanksAdvice =>
      'Create your first piggy bank with a goal — this is the main step to savings! What do you want to buy?';

  @override
  String get bari_goal_createPiggyBank => 'Create Piggy Bank';

  @override
  String get bari_goal_whenWillReach => 'When Will I Reach Goal';

  @override
  String bari_goal_onePiggyBank(String amount) {
    return 'You have 1 piggy bank with $amount inside.';
  }

  @override
  String bari_goal_multiplePiggyBanks(int count, String total) {
    return 'You have $count piggy banks, total saved $total.';
  }

  @override
  String bari_goal_almostFull(String name, int percent) {
    return 'Piggy bank \"$name\" is almost full ($percent%)! 🎉 Goal soon!';
  }

  @override
  String bari_goal_justStarted(String name, int percent) {
    return 'Piggy bank \"$name\" just started ($percent%). Time to top up!';
  }

  @override
  String get bari_goal_goodProgress => 'Good progress! Keep saving regularly.';

  @override
  String get bari_goal_piggyBanks => 'Piggy Banks';

  @override
  String get bari_goal_createFirst =>
      'You don\'t have any piggy banks yet — create your first one!';

  @override
  String get bari_goal_createFirstAdvice =>
      'Choose a goal: toy, gadget, gift. And start with small contributions.';

  @override
  String bari_goal_topUpSoonest(String name, int days) {
    return 'Top up \"$name\" — $days days left!';
  }

  @override
  String bari_goal_topUpClosest(String name, int progress, String remaining) {
    return 'Advise topping up \"$name\" ($progress%) — $remaining left!';
  }

  @override
  String get bari_goal_allFullOrEmpty =>
      'All piggy banks are full or empty. Create a new goal!';

  @override
  String get bari_goal_topUpAdvice =>
      'Better to top up the piggy bank closest to goal or deadline.';

  @override
  String bari_goal_walletAlmostEmpty(String balance) {
    return 'Wallet almost empty ($balance). Time to save!';
  }

  @override
  String bari_goal_walletEnoughForSmall(String balance) {
    return 'Wallet has $balance — enough for small things.';
  }

  @override
  String bari_goal_walletGood(String balance) {
    return 'Wallet has $balance — good! Remember goals.';
  }

  @override
  String bari_goal_walletExcellent(String balance) {
    return 'Wallet has $balance — excellent! Consider saving some.';
  }

  @override
  String bari_goal_walletBalance(String balance) {
    return 'Current wallet balance: $balance';
  }

  @override
  String get bari_goal_canIBuy => 'Can I buy?';

  @override
  String get bari_goal_balance => 'Balance';

  @override
  String get bari_goal_enoughMoney => 'Yes, you have enough money! 🎉';

  @override
  String bari_goal_enoughMoneyAdvice(String available, String target) {
    return 'Total available: $available, needed: $target.';
  }

  @override
  String bari_goal_needToSave(String needed) {
    return 'Need to save $needed more';
  }

  @override
  String bari_goal_needToSaveAdvice(String perMonth) {
    return 'If you save $perMonth/mo, you\'ll make it!';
  }

  @override
  String get bari_goal_savingSecret =>
      'The main secret of savings — regularity!';

  @override
  String get bari_goal_hardToSave =>
      'Saving is hard without a habit — that\'s normal!';

  @override
  String get bari_goal_optimalPercent => 'Optimal to save 10-20% of income.';

  @override
  String get bari_goal_createFirstPiggy =>
      'Create first piggy bank — goal motivates saving.';

  @override
  String get bari_hint_highSpending => 'High spending last week.';

  @override
  String get bari_hint_highSpendingAdvice => 'Let\'s see where money goes.';

  @override
  String get bari_hint_mainExpenses => 'Main expenses';

  @override
  String bari_hint_stalledPiggy(String name) {
    return 'Piggy bank \"$name\" hasn\'t been topped up in a while.';
  }

  @override
  String get bari_hint_stalledPiggies => 'Piggy banks are stalled.';

  @override
  String get bari_hint_stalledAdvice =>
      'I can help create a task in Earnings Lab.';

  @override
  String get bari_hint_earningsLab => 'Earnings Lab';

  @override
  String get bari_hint_noLessons => 'Haven\'t opened lessons in a while.';

  @override
  String get bari_hint_noLessonsAdvice => 'Want a short 3-5 min lesson?';

  @override
  String get bari_hint_lessons => 'Lessons';

  @override
  String get bari_hint_noLessonsYet => 'Haven\'t taken lessons yet?';

  @override
  String get bari_hint_noLessonsYetAdvice =>
      'Take the first lesson — just 3 minutes!';

  @override
  String get bari_hint_lowBalance => 'Low balance, upcoming expenses.';

  @override
  String get bari_hint_lowBalanceAdvice =>
      'Earn in Earnings Lab or check plan.';

  @override
  String get bari_hint_calendar => 'Calendar';

  @override
  String get bari_hint_highIncomeNoGoals => 'Good income but no goals.';

  @override
  String get bari_hint_highIncomeNoGoalsAdvice =>
      'Create a piggy bank for a big purchase!';

  @override
  String bari_hint_manySpendingCategory(String category) {
    return 'High spending on \"$category\".';
  }

  @override
  String get bari_hint_manySpendingCategoryAdvice => 'Check budget calculator.';

  @override
  String get bari_hint_budgetCalculator => 'Budget Calculator';

  @override
  String get bari_hint_noPlannedEvents => 'No planned events.';

  @override
  String get bari_hint_noPlannedEventsAdvice =>
      'Plan income and expenses to manage money better.';

  @override
  String get bari_hint_createPlan => 'Create Plan';

  @override
  String get bari_hint_tipTitle => 'Bari\'s Tip';

  @override
  String get bari_emptyMessage => 'Write a question 🙂';

  @override
  String get bari_emptyMessageAdvice =>
      'For example: \"can I buy for 20€\" or \"what is inflation\"';

  @override
  String get bari_balance => 'Balance';

  @override
  String get bari_piggyBanks => 'Piggy Banks';

  @override
  String bari_math_percentOf(String percent, String base, String result) {
    return '$percent% of $base = $result';
  }

  @override
  String bari_math_percentAdvice(String percent) {
    return 'Good to know: saving $percent% helps build habit.';
  }

  @override
  String get bari_math_calculator503020 => '50/30/20 Calculator';

  @override
  String get bari_math_explainSimpler => 'Explain Simpler';

  @override
  String bari_math_monthlyToYearly(String monthly, String yearly) {
    return '$monthly/mo = $yearly/yr';
  }

  @override
  String get bari_math_monthlyToYearlyAdvice =>
      'Small regular amounts accumulate! Subscriptions are also worth counting per year.';

  @override
  String get bari_math_subscriptionsCalculator => 'Subscriptions Calculator';

  @override
  String bari_math_saveYearly(String monthly, String yearly) {
    return 'Saving $monthly/mo = $yearly/yr';
  }

  @override
  String get bari_math_saveYearlyAdvice =>
      'Regularity is more important than amount! Start small and increase gradually.';

  @override
  String bari_math_savePerPeriod(
    String target,
    String perPeriod,
    String period,
  ) {
    return 'To save $target, save $perPeriod every $period';
  }

  @override
  String get bari_math_savePerPeriodAdvice =>
      'Create a piggy bank with this goal — easier not to forget!';

  @override
  String get bari_math_alreadyEnough => 'You\'ve already saved enough! 🎉';

  @override
  String get bari_math_alreadyEnoughAdvice =>
      'Goal reached — you can spend or continue saving for something bigger.';

  @override
  String bari_math_remainingToSave(String remaining, int percent) {
    return '$remaining left to save ($percent%)';
  }

  @override
  String get bari_math_remainingAdvice =>
      'You\'re on the right track! Keep up the pace.';

  @override
  String bari_math_multiply(String a, String b, String result) {
    return '$a × $b = $result';
  }

  @override
  String get bari_math_multiplyAdvice =>
      'Multiplication helps count regular expenses: daily for a month, monthly for a year.';

  @override
  String get bari_math_calculators => 'Calculators';

  @override
  String get bari_math_divideByZero => 'Cannot divide by zero!';

  @override
  String get bari_math_divideByZeroAdvice =>
      'It\'s like dividing pizza among zero friends — no one to eat.';

  @override
  String bari_math_divide(String a, String b, String result) {
    return '$a ÷ $b = $result';
  }

  @override
  String get bari_math_divideAdvice =>
      'Division helps understand how much to save per week/month for a goal.';

  @override
  String bari_math_priceComparison(int better, String price1, String price2) {
    return 'Option $better is better! ($price1 vs $price2)';
  }

  @override
  String bari_math_priceComparisonAdvice(int savings) {
    return 'Save ~$savings%.';
  }

  @override
  String get bari_math_priceComparisonCalculator => 'Price Comparison';

  @override
  String bari_math_rule72(String rate, String years) {
    return 'At $rate%, money doubles in $years years';
  }

  @override
  String bari_math_rule72Advice(String rate) {
    return 'Rule of 72 estimates growth.';
  }

  @override
  String get bari_math_lessons => 'Lessons';

  @override
  String bari_math_inflation(String amount, String years, String realValue) {
    return '$amount in $years years = $realValue today';
  }

  @override
  String bari_math_inflationAdvice(String amount, String years) {
    return 'Inflation eats money. Learn to invest later.';
  }

  @override
  String get bari_spending_noData =>
      'Not enough data about your income and expenses yet.';

  @override
  String get bari_spending_noDataAdvice =>
      'Keep recording transactions — then I can give better advice.';

  @override
  String bari_goal_deadlineSoon(String name, int days) {
    return 'Top up \"$name\" — $days days left until deadline!';
  }

  @override
  String bari_goal_closeToGoal(String name, int progress, String remaining) {
    return 'I advise topping up \"$name\" ($progress%) — $remaining left, you\'re close to the goal!';
  }

  @override
  String get bari_goal_whichPiggyBankAdvice =>
      'Better to top up the piggy bank that\'s closer to the goal or has a deadline soon.';

  @override
  String get bari_goal_alreadyEnough =>
      'Yes, you already have enough money! 🎉';

  @override
  String bari_goal_alreadyEnoughAdvice(String available, String target) {
    return 'Total available $available (wallet + piggy banks), need $target.';
  }

  @override
  String bari_goal_savePerMonth(String perMonth) {
    return 'If you save $perMonth per month, you\'ll make it! Create a piggy bank with a goal.';
  }

  @override
  String bari_goal_emptyWallet(String balance) {
    return 'Wallet is almost empty ($balance). Time to save up!';
  }

  @override
  String bari_goal_lowBalance(String balance) {
    return 'Wallet has $balance — can top up piggy bank or leave for expenses.';
  }

  @override
  String bari_goal_goodBalance(String balance) {
    return 'Wallet has $balance — great balance! Can top up piggy banks.';
  }

  @override
  String get bari_goal_createFirstPiggyBank =>
      'Create your first piggy bank — a goal motivates saving.';

  @override
  String get bari_goal_setDeadline =>
      'Set a deadline for the piggy bank — easier to plan.';

  @override
  String get bari_goal_regularTopUps =>
      'Top up piggy banks regularly, even with small amounts.';

  @override
  String get bari_goal_checkProgress =>
      'Check piggy bank progress — it\'s motivating!';

  @override
  String get bari_goal_completeLessons =>
      'Complete lessons on savings — you\'ll learn useful tips.';

  @override
  String bari_math_percentOfResult(String percent, String base, String result) {
    return '$percent% of $base = $result';
  }

  @override
  String bari_math_percentAdviceWithPercent(String percent) {
    return 'Good to know: if you save $percent% of income, it helps save regularly.';
  }

  @override
  String bari_math_monthlyToYearlyResult(String monthly, String yearly) {
    return '$monthly per month = $yearly per year';
  }

  @override
  String bari_math_saveYearlyResult(String monthly, String yearly) {
    return 'If you save $monthly per month, you\'ll accumulate $yearly per year';
  }

  @override
  String bari_math_savePerPeriodResult(
    String target,
    String perPeriod,
    String period,
  ) {
    return 'To save $target, need to save $perPeriod per $period';
  }

  @override
  String get bari_math_createPiggyBank => 'Create Piggy Bank';

  @override
  String get bari_math_whenWillReach => 'When Will I Reach Goal';

  @override
  String bari_math_remainingToSaveResult(String remaining, int percent) {
    return 'Need to save $remaining more (already $percent% of goal)';
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
    return 'Option $better is better! ($price1 per unit vs $price2)';
  }

  @override
  String bari_math_priceComparisonAdviceWithSavings(int savings) {
    return 'Savings ~$savings%. But check: will you use the larger package?';
  }

  @override
  String bari_math_rule72Result(String rate, String years) {
    return 'At $rate% annual rate, money will double in approximately $years years';
  }

  @override
  String bari_math_rule72AdviceWithRate(String rate) {
    return 'This is the \"Rule of 72\" — a quick way to estimate savings growth. The higher the %, the faster the growth, but also the higher the risk.';
  }

  @override
  String bari_math_inflationResult(
    String amount,
    String years,
    String realValue,
  ) {
    return '$amount in $years years will be \"worth\" as $realValue today';
  }

  @override
  String bari_math_inflationAdviceWithAmount(String amount, String years) {
    return 'Inflation \"eats\" money. That\'s why it\'s important not only to save, but also to learn to invest (when you grow up).';
  }

  @override
  String get earningsLab_piggyBankNotFound => 'Piggy bank not found';

  @override
  String get earningsLab_noTransactions =>
      'No transactions for this piggy bank yet';

  @override
  String get earningsLab_transactionHistory =>
      'Transaction history for this piggy bank';

  @override
  String get earningsLab_topUp => 'Piggy bank top-up';

  @override
  String get earningsLab_withdrawal => 'Withdrawal from piggy bank';

  @override
  String get earningsLab_goalReached => 'Goal reached 🎉';

  @override
  String get earningsLab_goalReachedSubtitle =>
      'Well done! You can create a new goal or transfer money to wallet.';

  @override
  String get earningsLab_almostThere => 'Almost there';

  @override
  String get earningsLab_almostThereSubtitle =>
      'Think about making 1-2 more top-ups — and the goal will be closed.';

  @override
  String get earningsLab_halfway => 'Halfway there';

  @override
  String get earningsLab_halfwaySubtitle =>
      'If you top up the piggy bank regularly, you\'ll reach the goal much faster.';

  @override
  String get earningsLab_goodStart => 'Good start';

  @override
  String get earningsLab_goodStartSubtitle =>
      'Try setting up auto-top-up or adding a task in Earnings Lab specifically for this goal.';

  @override
  String get notes_title => 'Notes';

  @override
  String get notes_listView => 'List';

  @override
  String get notes_gridView => 'Grid';

  @override
  String get notes_searchHint => 'Search notes...';

  @override
  String get notes_all => 'All';

  @override
  String get notes_pinned => 'Pinned';

  @override
  String get notes_archived => 'Archive';

  @override
  String get notes_linked => 'Linked';

  @override
  String get notes_errorLoading => 'Error loading notes';

  @override
  String get notes_emptyArchived => 'Archive is empty';

  @override
  String get notes_emptyPinned => 'No pinned notes';

  @override
  String get notes_empty => 'No notes';

  @override
  String get notes_emptySubtitle =>
      'Create your first note to save important thoughts';

  @override
  String get notes_createFirst => 'Create first note';

  @override
  String get notes_deleteConfirm => 'Delete note?';

  @override
  String notes_deleteMessage(String noteTitle) {
    return 'Are you sure you want to delete note \"$noteTitle\"?';
  }

  @override
  String get notes_unpin => 'Unpin';

  @override
  String get notes_pin => 'Pin';

  @override
  String get notes_unarchive => 'Unarchive';

  @override
  String get notes_archive => 'Archive';

  @override
  String get notes_copy => 'Copy';

  @override
  String get notes_share => 'Share';

  @override
  String get notes_copied => 'Note copied';

  @override
  String get notes_shareNotAvailable =>
      'Share functionality temporarily unavailable';

  @override
  String get notes_edit => 'Edit note';

  @override
  String get notes_create => 'New note';

  @override
  String get notes_changeColor => 'Change color';

  @override
  String get notes_editTags => 'Edit tags';

  @override
  String get notes_selectColor => 'Select color';

  @override
  String get notes_clearColor => 'Clear color';

  @override
  String get notes_tagHint => 'Add tag...';

  @override
  String get notes_titleRequired => 'Please enter note title';

  @override
  String get notes_titleHint => 'Note title...';

  @override
  String get notes_contentHint => 'Start writing here...';

  @override
  String get notes_save => 'Save note';

  @override
  String get notes_today => 'Today';

  @override
  String get notes_yesterday => 'Yesterday';

  @override
  String notes_daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get notes_templates => 'Templates';

  @override
  String get notes_templateExpense => 'Expense Planning';

  @override
  String get notes_templateGoal => 'Goal';

  @override
  String get notes_templateIdea => 'Idea';

  @override
  String get notes_templateMeeting => 'Meeting';

  @override
  String get notes_templateLearning => 'Learning';

  @override
  String get notes_templateExpenseDesc => 'Plan your expenses';

  @override
  String get notes_templateGoalDesc => 'Write down your goal';

  @override
  String get notes_templateIdeaDesc => 'Save your idea';

  @override
  String get notes_templateMeetingDesc => 'Meeting notes';

  @override
  String get notes_templateLearningDesc => 'Lesson notes';

  @override
  String get notes_linkToEvent => 'Link to event';

  @override
  String get notes_linkedToEvent => 'Linked to event';

  @override
  String get notes_unlinkFromEvent => 'Unlink from event';

  @override
  String get notes_selectEvent => 'Select event';

  @override
  String get notes_noEvents => 'No events available';

  @override
  String get notes_bariTip => 'Bari\'s tip';

  @override
  String get notes_quickNote => 'Quick note';

  @override
  String get notes_autoSave => 'Auto-save';

  @override
  String get notes_preview => 'Preview';

  @override
  String get notes_swipeToArchive => 'Swipe left to archive';

  @override
  String get notes_swipeToDelete => 'Swipe right to delete';

  @override
  String get notes_templateShoppingList => 'Shopping List';

  @override
  String get notes_templateShoppingListDesc => 'Organize your shopping';

  @override
  String get notes_templateReflection => 'Reflection';

  @override
  String get notes_templateReflectionDesc => 'Write down your thoughts';

  @override
  String get notes_templateGratitude => 'Gratitude';

  @override
  String get notes_templateGratitudeDesc => 'What I\'m grateful for';

  @override
  String get notes_templateParentReport => 'Parent Report';

  @override
  String get notes_templateParentReportDesc => 'Automatic period report';

  @override
  String get calendarSync_title => 'Calendar Sync';

  @override
  String get calendarSync_enable => 'Enable sync';

  @override
  String get calendarSync_syncToCalendar => 'Sync events to calendar';

  @override
  String get calendarSync_syncFromCalendar => 'Import events from calendar';

  @override
  String get calendarSync_selectCalendars => 'Select calendars';

  @override
  String get calendarSync_noCalendars => 'No calendars available';

  @override
  String get calendarSync_requestPermissions => 'Request permissions';

  @override
  String get calendarSync_permissionsGranted => 'Permissions granted';

  @override
  String get calendarSync_permissionsDenied => 'Permissions denied';

  @override
  String get calendarSync_syncNow => 'Sync now';

  @override
  String get calendarSync_lastSync => 'Last sync';

  @override
  String get calendarSync_never => 'Never';

  @override
  String get calendarSync_conflictResolution => 'Conflict resolution';

  @override
  String get calendarSync_appWins => 'App wins';

  @override
  String get calendarSync_calendarWins => 'Calendar wins';

  @override
  String get calendarSync_askUser => 'Ask user';

  @override
  String get calendarSync_merge => 'Merge';

  @override
  String get calendarSync_syncInterval => 'Sync interval (hours)';

  @override
  String get calendarSync_showNotifications => 'Show notifications';

  @override
  String get calendarSync_syncNotesAsEvents => 'Sync notes as events';

  @override
  String get calendarSync_statistics => 'Statistics';

  @override
  String get calendarSync_totalEvents => 'Total events';

  @override
  String get calendarSync_syncedEvents => 'Synced';

  @override
  String get calendarSync_localEvents => 'Local';

  @override
  String get calendarSync_errorEvents => 'Errors';

  @override
  String get calendarSync_successRate => 'Success rate';

  @override
  String get calendarSync_syncInProgress => 'Syncing...';

  @override
  String get modelLoader_title => 'Loading AI Model';

  @override
  String get modelLoader_loading => 'Loading model from app...';

  @override
  String get modelLoader_preparing =>
      'Model loaded, preparing to decompress...';

  @override
  String get modelLoader_decompressing =>
      'Decompressing model (this may take a minute)...';

  @override
  String modelLoader_saving(String percent) {
    return 'Saving... $percent%';
  }

  @override
  String get modelLoader_complete => 'Model ready!';

  @override
  String get modelLoader_error => 'Model Loading Error';

  @override
  String get modelLoader_errorMessage =>
      'Failed to load AI model. Please try again or contact support.';

  @override
  String get modelLoader_retry => 'Retry';

  @override
  String get modelLoader_cancel => 'Cancel';

  @override
  String get testData_title => 'Test Data Generator';

  @override
  String get testData_success => 'Test data created successfully!';

  @override
  String testData_error(String error) {
    return 'Error: $error';
  }

  @override
  String get testData_generateWeekly => 'Generate Weekly Data';

  @override
  String get testData_clearTitle => 'Clear Test Data?';

  @override
  String get testData_clearCancel => 'Cancel';

  @override
  String get testData_cleared => 'Test data cleared';

  @override
  String testData_clearError(String error) {
    return 'Error: $error';
  }

  @override
  String get testData_clearButton => 'Clear Test Data';

  @override
  String get calendar_deleteError => 'Error deleting event';

  @override
  String get earningsLab_photoFeatureUnavailable => 'Photo feature unavailable';

  @override
  String get earningsLab_addPhoto => 'Add photo';

  @override
  String get noteEditor_unlinkedFromDate => 'Unlinked from date';

  @override
  String get noteEditor_imageAdded => 'Image added';

  @override
  String noteEditor_imageError(String error) {
    return 'Error adding image: $error';
  }

  @override
  String get noteEditor_fileAdded => 'File added';

  @override
  String noteEditor_fileError(String error) {
    return 'Error adding file: $error';
  }

  @override
  String get mainScreen_importSuccess => 'Import successful!';

  @override
  String mainScreen_importError(String error) {
    return 'Import error: $error';
  }

  @override
  String get parentReport_selectSectionError => 'Select at least one section';

  @override
  String parentReport_createError(String error) {
    return 'Error creating report: $error';
  }

  @override
  String templateBuilder_createError(String error) {
    return 'Error creating template: $error';
  }

  @override
  String get planEvent_viewAllNotes => 'View all notes';

  @override
  String calendarSync_loadError(String error) {
    return 'Error loading: $error';
  }

  @override
  String get calendarSync_permissionsGrantedMsg => 'Permissions granted';

  @override
  String get calendarSync_permissionsNotGrantedMsg => 'Permissions not granted';

  @override
  String calendarSync_permissionError(String error) {
    return 'Error requesting permissions: $error';
  }

  @override
  String get calendarSync_syncComplete => 'Sync complete';

  @override
  String calendarSync_syncError(String error) {
    return 'Sync error: $error';
  }

  @override
  String calendarSync_hours(int hours) {
    return '$hours h.';
  }

  @override
  String get calendarSync_unnamedCalendar => 'Unnamed Calendar';

  @override
  String paginatedList_error(String error) {
    return 'Error: $error';
  }

  @override
  String get paginatedList_retry => 'Retry';

  @override
  String get paginatedList_noData => 'No data';

  @override
  String get swipeable_confirm => 'Confirmation';

  @override
  String get swipeable_cancel => 'Cancel';

  @override
  String get swipeable_confirmAction => 'Confirm';

  @override
  String planEvent_foundRelatedEvents(int count) {
    return 'Found related events: $count';
  }

  @override
  String planEvent_saveError(String error) {
    return 'Error saving: $error';
  }

  @override
  String planEvent_createdRepeatingEvents(int count) {
    return 'Created $count repeating events';
  }

  @override
  String get planEvent_eventScheduled => 'Event scheduled';

  @override
  String get planEvent_autoExecute => 'Auto-execute on date';

  @override
  String get planEvent_autoExecuteSubtitle =>
      'Amount will be automatically added/deducted from balance';

  @override
  String get planEvent_linkedNotes => 'Linked notes';

  @override
  String get planEvent_createNote => 'Create note';

  @override
  String get planEvent_noLinkedNotes => 'No linked notes';

  @override
  String get planEvent_untitledNote => 'Untitled';
}
