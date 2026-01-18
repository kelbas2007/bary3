// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get common_cancel => 'Abbrechen';

  @override
  String get common_save => 'Speichern';

  @override
  String get common_create => 'Erstellen';

  @override
  String get common_delete => 'Löschen';

  @override
  String get common_done => 'Fertig';

  @override
  String get common_understand => 'Verstanden';

  @override
  String get common_planCreated => 'Plan erfolgreich erstellt!';

  @override
  String get common_purchasePlanned => 'Kauf geplant!';

  @override
  String get common_income => 'Einkommen';

  @override
  String get common_expense => 'Ausgabe';

  @override
  String get common_plan => 'Plan';

  @override
  String get common_balance => 'Guthaben';

  @override
  String get common_piggyBanks => 'Spardosen';

  @override
  String get common_calendar => 'Kalender';

  @override
  String get common_lessons => 'Lektionen';

  @override
  String get common_settings => 'Einstellungen';

  @override
  String get common_tools => 'Werkzeuge';

  @override
  String get common_continue => 'Weiter';

  @override
  String get common_confirm => 'Bestätigen';

  @override
  String get common_error => 'Fehler';

  @override
  String get common_tryAgain => 'Erneut versuchen';

  @override
  String get balance => 'Guthaben';

  @override
  String get search => 'Suchen';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get done => 'Fertig';

  @override
  String get moneyValidator_enterAmount => 'Bitte gib einen Betrag ein';

  @override
  String get moneyValidator_notANumber => 'Das sieht nicht wie eine Zahl aus';

  @override
  String get moneyValidator_mustBePositive =>
      'Der Betrag muss größer als 0 sein';

  @override
  String get moneyValidator_tooSmall => 'Der Betrag ist zu klein';

  @override
  String get bariOverlay_tipOfDay => 'Tipp des Tages';

  @override
  String get bariOverlay_defaultTip =>
      'Denk dran: Jede Münze bringt dich näher an dein Ziel!';

  @override
  String get bariOverlay_instructions =>
      'Tippe auf Bari für einen Tipp. Doppeltipp für den Chat.';

  @override
  String get bariOverlay_openChat => 'Chat öffnen';

  @override
  String get bariOverlay_moreTips => 'Nächster Tipp';

  @override
  String get bariAvatar_happy => '😄';

  @override
  String get bariAvatar_encouraging => '🤔';

  @override
  String get bariAvatar_neutral => '😌';

  @override
  String mainScreen_transferToPiggyBank(String bankName) {
    return 'Überweisung in Spardose \"$bankName\" (aus Einkommen)';
  }

  @override
  String get bariTip_income => 'Tolles Einkommen! Wofür wirst du es ausgeben?';

  @override
  String get bariTip_expense => 'Ausgegeben. War das geplant?';

  @override
  String get bariTip_planCreated =>
      'Plan erstellt! Daran zu halten ist der Schlüssel zum Erfolg.';

  @override
  String get bariTip_planCompleted => 'Plan abgeschlossen! Du bist großartig!';

  @override
  String get bariTip_piggyBankCreated => 'Neue Spardose! Wofür sparen wir?';

  @override
  String get bariTip_piggyBankCompleted =>
      'Spardose ist voll! Herzlichen Glückwunsch zum Erreichen deines Ziels!';

  @override
  String get bariTip_lessonCompleted =>
      'Lektion abgeschlossen! Neues Wissen ist eine Superkraft!';

  @override
  String get period_day => 'Tag';

  @override
  String get period_week => 'Woche';

  @override
  String get period_month => 'Monat';

  @override
  String get period_inADay => 'pro Tag';

  @override
  String get period_inAWeek => 'pro Woche';

  @override
  String get period_inAMonth => 'pro Monat';

  @override
  String get period_everyDay => 'Jeden Tag';

  @override
  String get period_onceAWeek => 'Einmal pro Woche';

  @override
  String get period_onceAMonth => 'Einmal im Monat';

  @override
  String plural_days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage',
      one: 'Tag',
    );
    return '$_temp0';
  }

  @override
  String get monthlyBudgetCalculator_title => 'Monatlicher Ausgabenplan';

  @override
  String get monthlyBudgetCalculator_subtitle =>
      'Setze ein Limit und sieh den Rest – es wird einfacher sein, dein Geld zu kontrollieren.';

  @override
  String get monthlyBudgetCalculator_step1 => 'Monat';

  @override
  String get monthlyBudgetCalculator_step2 => 'Limit';

  @override
  String get monthlyBudgetCalculator_step3 => 'Ergebnis';

  @override
  String get monthlyBudgetCalculator_selectMonth => '1) Monat auswählen';

  @override
  String get monthlyBudgetCalculator_setLimit => '2) Limit setzen';

  @override
  String get monthlyBudgetCalculator_limitForMonth => 'Limit für den Monat';

  @override
  String get monthlyBudgetCalculator_result => 'Ergebnis';

  @override
  String get monthlyBudgetCalculator_spent => 'Ausgegeben';

  @override
  String get monthlyBudgetCalculator_remaining => 'Übrig';

  @override
  String get monthlyBudgetCalculator_warningAlmostLimit =>
      '⚠️ Limit fast erreicht! Versuche, die Ausgaben in den verbleibenden Tagen zu reduzieren.';

  @override
  String monthlyBudgetCalculator_warningOverLimit(String amount) {
    return 'Du hast das Limit um $amount überschritten. Du kannst das Limit überdenken oder Sparmöglichkeiten finden.';
  }

  @override
  String get goalDateCalculator_title => 'Wann erreiche ich mein Ziel?';

  @override
  String get goalDateCalculator_subtitle =>
      'Gib den Beitragsbetrag und die Häufigkeit ein – ich zeige dir das ungefähre Zieldatum.';

  @override
  String get goalDateCalculator_stepGoal => 'Ziel';

  @override
  String get goalDateCalculator_stepContribution => 'Beitrag';

  @override
  String get goalDateCalculator_stepFrequency => 'Häufigkeit';

  @override
  String get goalDateCalculator_headerGoal => '1) Ziel';

  @override
  String get goalDateCalculator_piggyBankLabel => 'Spardose';

  @override
  String goalDateCalculator_remainingToGoal(String amount) {
    return 'Übrig: $amount';
  }

  @override
  String get goalDateCalculator_headerContribution =>
      '2) Wie viel legst du zurück';

  @override
  String get goalDateCalculator_contributionAmountLabel => 'Beitragsbetrag';

  @override
  String get goalDateCalculator_headerFrequency => '3) Häufigkeit';

  @override
  String get goalDateCalculator_result => 'Ergebnis';

  @override
  String get goalDateCalculator_goalAlreadyReached =>
      'Das Ziel ist bereits erreicht – du kannst ein neues setzen!';

  @override
  String goalDateCalculator_resultSummary(int count, String period) {
    return 'In etwa $count Beiträgen (jede $period)';
  }

  @override
  String get goalDateCalculator_upcomingDates => 'Nächste Termine:';

  @override
  String get goalDateCalculator_createPlanButton => 'Beitragsplan erstellen';

  @override
  String get goalDateCalculator_dialogTitle => 'Bestätigung';

  @override
  String get goalDateCalculator_dialogSubtitle =>
      'Geplante Ereignisse erstellen';

  @override
  String goalDateCalculator_dialogContent(String goalName) {
    return 'Geplante Ereignisse für Beiträge zur Spardose \"$goalName\" erstellen?';
  }

  @override
  String get goalDateCalculator_defaultGoalName => 'Ziel';

  @override
  String goalDateCalculator_dialogContributionAmount(String amount) {
    return 'Beitragsbetrag: $amount';
  }

  @override
  String goalDateCalculator_dialogFrequency(String period) {
    return 'Häufigkeit: jede $period';
  }

  @override
  String goalDateCalculator_eventName(String goalName) {
    return 'Beitrag zur Spardose \"$goalName\"';
  }

  @override
  String get piggyPlanCalculator_title => 'Spardosen-Plan';

  @override
  String get piggyPlanCalculator_subtitle =>
      'Ich helfe dir herauszufinden, wie viel und wie oft du sparen musst, um dein Ziel zu erreichen.';

  @override
  String get piggyPlanCalculator_stepGoal => 'Ziel';

  @override
  String get piggyPlanCalculator_stepDate => 'Datum';

  @override
  String get piggyPlanCalculator_stepFrequency => 'Häufigkeit';

  @override
  String get piggyPlanCalculator_headerSelectGoal => '1) Wähle ein Ziel';

  @override
  String get piggyPlanCalculator_goalAmountLabel => 'Ziel (Betrag)';

  @override
  String get piggyPlanCalculator_currentAmountLabel => 'Bereits vorhanden';

  @override
  String get piggyPlanCalculator_headerTargetDate =>
      '2) Wann möchtest du das Ziel erreichen?';

  @override
  String get piggyPlanCalculator_selectDate => 'Datum auswählen';

  @override
  String get piggyPlanCalculator_headerFrequency => '3) Wie oft sparen?';

  @override
  String get piggyPlanCalculator_result => 'Ergebnis';

  @override
  String piggyPlanCalculator_resultSummary(
    String amount,
    String period,
    int count,
  ) {
    return 'Spare etwa $amount jede $period (insgesamt $count Beiträge).';
  }

  @override
  String piggyPlanCalculator_planCreatedSnackbar(String amount, String period) {
    return 'Plan erstellt: $amount jede $period';
  }

  @override
  String get piggyPlanCalculator_scheduleFirstContributionButton =>
      'Ersten Beitrag planen';

  @override
  String piggyPlanCalculator_dialogContributionAmount(String amount) {
    return 'Betrag: $amount';
  }

  @override
  String get canIBuyCalculator_title => 'Kann ich das kaufen?';

  @override
  String get canIBuyCalculator_subtitle =>
      'Lass uns den Kauf jetzt und unter Berücksichtigung der Wochenpläne prüfen.';

  @override
  String get canIBuyCalculator_stepPrice => 'Preis';

  @override
  String get canIBuyCalculator_stepMoney => 'Geld';

  @override
  String get canIBuyCalculator_stepRules => 'Regeln';

  @override
  String get canIBuyCalculator_headerPrice => '1) Kaufpreis';

  @override
  String get canIBuyCalculator_priceLabel => 'Preis';

  @override
  String get canIBuyCalculator_headerAvailableMoney =>
      '2) Wie viel Geld ist verfügbar';

  @override
  String get canIBuyCalculator_walletBalanceLabel => 'Im Geldbeutel jetzt';

  @override
  String get canIBuyCalculator_headerRules => '3) Regeln';

  @override
  String get canIBuyCalculator_ruleDontTouchPiggies =>
      'Spardosen nicht anrühren';

  @override
  String get canIBuyCalculator_ruleDontTouchPiggiesSubtitleEnabled =>
      'Zählt nur den Geldbeutel';

  @override
  String get canIBuyCalculator_ruleDontTouchPiggiesSubtitleDisabled =>
      'Kann Geld aus Spardosen als Reserve verwenden';

  @override
  String get canIBuyCalculator_ruleConsiderPlans =>
      'Pläne für 7 Tage berücksichtigen';

  @override
  String get canIBuyCalculator_ruleConsiderPlansSubtitle =>
      'Geplante Einnahmen/Ausgaben aus dem Kalender';

  @override
  String get canIBuyCalculator_result => 'Ergebnis';

  @override
  String get canIBuyCalculator_statusYes => 'Du kannst es jetzt kaufen';

  @override
  String get canIBuyCalculator_statusYesBut =>
      'Du kannst es jetzt kaufen, aber die Wochenpläne könnten stören';

  @override
  String get canIBuyCalculator_statusMaybeWithPiggies =>
      'Möglich, wenn du etwas aus einer Spardose nimmst';

  @override
  String get canIBuyCalculator_statusMaybeWithPlans =>
      'Noch nicht genug, aber Pläne/Einkommen für die Woche könnten helfen';

  @override
  String canIBuyCalculator_statusNo(String amount) {
    return 'Besser warten: es fehlen $amount';
  }

  @override
  String get canIBuyCalculator_planPurchaseButton => 'Kauf planen';

  @override
  String get canIBuyCalculator_dialogTitle => 'Bestätigung';

  @override
  String get canIBuyCalculator_dialogSubtitle =>
      'Ein geplantes Ereignis erstellen';

  @override
  String get canIBuyCalculator_dialogContent =>
      'Ein geplantes Ereignis für den Kauf erstellen?';

  @override
  String canIBuyCalculator_dialogAmount(String amount) {
    return 'Betrag: $amount';
  }

  @override
  String get canIBuyCalculator_dialogInfo =>
      'Das Ereignis wird für 7 Tage im Voraus erstellt.';

  @override
  String get canIBuyCalculator_defaultEventName => 'Kauf';

  @override
  String get toolsHub_subtitle => 'Rechnen, planen, verbessern';

  @override
  String get toolsHub_bariTipTitle => 'Baris Tipp';

  @override
  String get toolsHub_tipCalculators =>
      'Rechner helfen dir beim Planen und Kalkulieren. Beginne mit dem \"Spardosen-Plan\"!';

  @override
  String get toolsHub_tipEarningsLab =>
      'Im Verdienst-Labor kannst du Aufgaben erledigen und Geld verdienen. Beginne mit den einfachen!';

  @override
  String get toolsHub_tipMiniTrainers =>
      '60-Sekunden-Trainer helfen dir, deine Fähigkeiten schnell zu verbessern. Beständigkeit ist wichtiger als Geschwindigkeit!';

  @override
  String get toolsHub_tipBariRecommendations =>
      'Baris Tipp des Tages wird täglich aktualisiert. Schau oft für neue Ideen vorbei!';

  @override
  String get toolsHub_calendarForecastTitle => 'Kalenderprognose';

  @override
  String get toolsHub_calendarForecastSubtitle =>
      'Zukünftiges Guthaben und alle geplanten Ereignisse';

  @override
  String get toolsHub_calculatorsTitle => 'Rechner';

  @override
  String get toolsHub_calculatorsSubtitle => '8 nützliche Finanzrechner';

  @override
  String get toolsHub_earningsLabTitle => 'Verdienst-Labor';

  @override
  String get toolsHub_earningsLabSubtitle =>
      'Aufgaben und Missionen zum Geldverdienen';

  @override
  String get toolsHub_miniTrainersTitle => '60 Sekunden';

  @override
  String get toolsHub_miniTrainersSubtitle => 'Mikro-Übungen zum Trainieren';

  @override
  String get toolsHub_recommendationsTitle => 'Tipp des Tages';

  @override
  String get toolsHub_recommendationsSubtitle =>
      'Eine Auswahl an Tipps und Erklärungen von Bari';

  @override
  String get toolsHub_notesTitle => 'Заметки';

  @override
  String get toolsHub_notesSubtitle => 'Создавай и организуй свои заметки';

  @override
  String get toolsHub_tipNotes =>
      'Заметки помогут тебе не забыть важные мысли. Закрепляй самые важные!';

  @override
  String get piggyBanks_explanationSimple =>
      'Eine Spardose ist ein separates Ziel. Das Geld darin beeinflusst nicht dein Guthaben.';

  @override
  String get piggyBanks_explanationPro =>
      'Eine Spardose ist ein separates Sparziel. Das Geld, das du in eine Spardose legst, beeinflusst nicht dein Hauptguthaben. Das hilft dir, deinen Fortschritt zu einem bestimmten Ziel zu sehen.';

  @override
  String get piggyBanks_deleteConfirmTitle => 'Spardose löschen?';

  @override
  String piggyBanks_deleteConfirmMessage(String name) {
    return 'Möchtest du die Spardose \"$name\" wirklich löschen? Alle zugehörigen Transaktionen bleiben im Verlauf, aber die Spardose selbst wird gelöscht.';
  }

  @override
  String piggyBanks_deleteSuccess(String name) {
    return 'Spardose \"$name\" gelöscht';
  }

  @override
  String piggyBanks_deleteError(String error) {
    return 'Fehler beim Löschen: $error';
  }

  @override
  String get piggyBanks_emptyStateTitle => 'Keine Spardosen';

  @override
  String get piggyBanks_createNewTooltip => 'Neue Spardose erstellen';

  @override
  String get piggyBanks_createNewButton => 'Spardose erstellen';

  @override
  String get piggyBanks_addNewButton => 'Neue Spardose hinzufügen';

  @override
  String get piggyBanks_fabTooltip => 'Spardose erstellen';

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
  String get piggyBanks_card_deleteTooltip => 'Löschen';

  @override
  String get piggyBanks_card_goalReached => '✓ Ziel erreicht!';

  @override
  String piggyBanks_card_estimatedDate(String date) {
    return 'Du wirst es bis zum $date erreichen';
  }

  @override
  String get piggyBanks_progress_goalReached => 'Ziel erreicht! 🎉';

  @override
  String piggyBanks_progress_almostThere(String amount) {
    return 'Fast geschafft! Nur noch $amount';
  }

  @override
  String get piggyBanks_progress_halfway => 'Mehr als die Hälfte geschafft! 💪';

  @override
  String piggyBanks_progress_quarter(String amount) {
    return 'Ein Viertel des Weges. Noch $amount';
  }

  @override
  String get piggyBanks_progress_started => 'Ein guter Anfang 🌱';

  @override
  String piggyBanks_progress_initialGoal(String amount) {
    return 'Ziel ist $amount';
  }

  @override
  String get piggyBanks_createSheet_title => 'Neue Spardose';

  @override
  String get piggyBanks_createSheet_nameLabel => 'Name der Spardose';

  @override
  String get piggyBanks_createSheet_nameHint => 'z.B. Neues Telefon';

  @override
  String get piggyBanks_createSheet_targetLabel => 'Zielbetrag';

  @override
  String get piggyBanks_detail_deleteTooltip => 'Spardose löschen';

  @override
  String piggyBanks_detail_fromAmount(String amount) {
    return 'von $amount';
  }

  @override
  String get piggyBanks_detail_topUpButton => 'Aufladen';

  @override
  String get piggyBanks_detail_withdrawButton => 'Abheben';

  @override
  String get piggyBanks_detail_autofillTitle => 'Automatisch füllen';

  @override
  String get piggyBanks_detail_autofillRuleLabel => 'Regel';

  @override
  String get piggyBanks_detail_autofillTypePercent => 'Prozentsatz';

  @override
  String get piggyBanks_detail_autofillTypeFixed => 'Fester Betrag';

  @override
  String get piggyBanks_detail_autofillPercentLabel =>
      'Prozentsatz vom Einkommen';

  @override
  String get piggyBanks_detail_autofillFixedLabel => 'Fester Betrag';

  @override
  String get piggyBanks_detail_autofillEnabledSnackbar =>
      'Automatisches Sparen ist wie eine unsichtbare Gewohnheit.';

  @override
  String get piggyBanks_detail_whenToReachGoalTitle =>
      'Wann erreiche ich das Ziel?';

  @override
  String get piggyBanks_detail_calculateButton => 'Berechnen';

  @override
  String get piggyBanks_detail_goalExceededTitle => 'Ziel wird überschritten!';

  @override
  String piggyBanks_detail_goalExceededMessage(
    String name,
    String amount,
    String newAmount,
    String targetAmount,
  ) {
    return 'Wenn du $amount zur Spardose \"$name\" hinzufügst, beträgt der neue Betrag $newAmount, was das Ziel von $targetAmount überschreitet. Fortfahren?';
  }

  @override
  String piggyBanks_detail_topUpTransactionNote(String name) {
    return 'Spardose \"$name\" aufladen';
  }

  @override
  String get piggyBanks_detail_successAnimationGoalReached =>
      '🎉 Ziel erreicht!';

  @override
  String piggyBanks_detail_successAnimationDaysCloser(
    String amount,
    int count,
    String days,
  ) {
    return '+$amount • Ziel ist $count $days näher 🚀';
  }

  @override
  String piggyBanks_detail_successAnimationSimpleTopUp(String amount) {
    return 'Spardose um $amount aufgeladen';
  }

  @override
  String get piggyBanks_detail_noFundsError =>
      'Kein Geld in der Spardose zum Abheben.';

  @override
  String get piggyBanks_detail_noOtherPiggiesError =>
      'Keine anderen Spardosen zum Überweisen.';

  @override
  String get piggyBanks_detail_insufficientFundsError =>
      'Nicht genügend Geld in der Spardose.';

  @override
  String piggyBanks_detail_withdrawToWalletNote(String name) {
    return 'Abhebung von Spardose \"$name\" → Geldbeutel';
  }

  @override
  String piggyBanks_detail_withdrawToWalletSnackbar(String amount) {
    return '$amount in den Geldbeutel überwiesen';
  }

  @override
  String piggyBanks_detail_spendFromPiggyNote(String name) {
    return 'Kauf aus Spardose \"$name\"';
  }

  @override
  String piggyBanks_detail_spendFromPiggySnackbar(String amount) {
    return '$amount aus der Spardose ausgegeben';
  }

  @override
  String piggyBanks_detail_transferNote(String fromBank, String toBank) {
    return 'Überweisung zwischen Spardosen: \"$fromBank\" → \"$toBank\"';
  }

  @override
  String piggyBanks_detail_transferSnackbar(String amount, String toBank) {
    return '$amount nach \"$toBank\" überwiesen';
  }

  @override
  String get piggyBanks_operationSheet_addTitle => 'Spardose aufladen';

  @override
  String get piggyBanks_operationSheet_transferTitle =>
      'In eine andere Spardose überweisen';

  @override
  String get piggyBanks_operationSheet_spendTitle =>
      'Aus der Spardose ausgeben';

  @override
  String get piggyBanks_operationSheet_withdrawTitle =>
      'In den Geldbeutel abheben';

  @override
  String get piggyBanks_operationSheet_amountLabel => 'Betrag';

  @override
  String piggyBanks_operationSheet_maxAmountHint(String amount) {
    return 'Maximum: $amount';
  }

  @override
  String get piggyBanks_operationSheet_enterAmountHint => 'Betrag eingeben';

  @override
  String get piggyBanks_operationSheet_categoryLabel => 'Kategorie';

  @override
  String get piggyBanks_operationSheet_categoryHint => 'Kategorie auswählen';

  @override
  String get piggyBanks_operationSheet_categoryFood => 'Essen';

  @override
  String get piggyBanks_operationSheet_categoryTransport => 'Transport';

  @override
  String get piggyBanks_operationSheet_categoryEntertainment => 'Unterhaltung';

  @override
  String get piggyBanks_operationSheet_categoryOther => 'Sonstiges';

  @override
  String get piggyBanks_operationSheet_noteLabel => 'Name des Kaufs (optional)';

  @override
  String get piggyBanks_operationSheet_noteHint => 'Namen eingeben...';

  @override
  String get piggyBanks_operationSheet_errorTooMuch =>
      'Der Betrag übersteigt die verfügbaren Mittel';

  @override
  String get piggyBanks_operationSheet_errorInvalid =>
      'Bitte gib einen gültigen Betrag ein';

  @override
  String get piggyBanks_withdrawMode_title =>
      'Was soll mit dem Geld geschehen?';

  @override
  String get piggyBanks_withdrawMode_toWalletTitle => 'In den Geldbeutel';

  @override
  String get piggyBanks_withdrawMode_toWalletSubtitle =>
      'Geldbeutel +, Spardose −';

  @override
  String get piggyBanks_withdrawMode_spendTitle =>
      'Direkt aus der Spardose ausgeben';

  @override
  String get piggyBanks_withdrawMode_spendSubtitle =>
      'Geldbeutel unverändert, Spardose −';

  @override
  String get piggyBanks_withdrawMode_transferTitle =>
      'In eine andere Spardose überweisen';

  @override
  String get piggyBanks_withdrawMode_transferSubtitle =>
      'Geldbeutel unverändert, Spardose A −, Spardose B +';

  @override
  String get piggyBanks_picker_title =>
      'Wähle eine Spardose für die Überweisung';

  @override
  String get piggyBanks_picker_defaultTitle => 'Wähle eine Spardose';

  @override
  String get balance_currentBalance => 'Aktuelles Guthaben';

  @override
  String get balance_forecast => 'Prognose';

  @override
  String get balance_fact => 'Tatsächlich';

  @override
  String get balance_withPlannedExpenses => 'Inkl. geplanter Ausgaben';

  @override
  String get balance_forecastForDay => 'Tagesprognose';

  @override
  String get balance_forecastForWeek => 'Wochenprognose';

  @override
  String get balance_forecastForMonth => 'Monatsprognose';

  @override
  String get balance_forecastFor3Months => '3-Monats-Prognose';

  @override
  String balance_level(int level) {
    return 'Level $level';
  }

  @override
  String get balance_toolsDescription =>
      'Rechner und Tools für die Finanzplanung';

  @override
  String get balance_tools => 'Werkzeuge';

  @override
  String get balance_filterDay => 'Tag';

  @override
  String get balance_filterWeek => 'Woche';

  @override
  String get balance_filterMonth => 'Monat';

  @override
  String get balance_emptyStateIncome =>
      'Noch nichts hier. Füge Einkommen hinzu!';

  @override
  String get balance_emptyStateNoTransactions =>
      'Keine Transaktionen im gewählten Zeitraum';

  @override
  String get balance_addIncome => 'Einkommen hinzufügen';

  @override
  String get balance_addExpense => 'Ausgabe hinzufügen';

  @override
  String get balance_amount => 'Betrag';

  @override
  String get balance_category => 'Kategorie';

  @override
  String get balance_selectCategory => 'Kategorie auswählen';

  @override
  String get balance_toPiggyBank => 'Zur Spardose (optional)';

  @override
  String get balance_fromPiggyBank => 'Aus Spardose (optional)';

  @override
  String get balance_note => 'Notiz';

  @override
  String get balance_noteHint => 'Notiz eingeben...';

  @override
  String get balance_save => 'Speichern';

  @override
  String get balance_categories_food => 'Essen';

  @override
  String get balance_categories_transport => 'Transport';

  @override
  String get balance_categories_games => 'Spiele';

  @override
  String get balance_categories_clothing => 'Kleidung';

  @override
  String get balance_categories_entertainment => 'Unterhaltung';

  @override
  String get balance_categories_other => 'Sonstiges';

  @override
  String get balance_categories_pocketMoney => 'Taschengeld';

  @override
  String get balance_categories_gift => 'Geschenk';

  @override
  String get balance_categories_sideJob => 'Nebenjob';

  @override
  String get settings_language => 'Sprache';

  @override
  String get settings_selectCurrency => 'Währung auswählen';

  @override
  String get settings_appearance => 'Erscheinungsbild';

  @override
  String get settings_theme => 'Design';

  @override
  String get settings_themeBlue => 'Blau';

  @override
  String get settings_themePurple => 'Lila';

  @override
  String get settings_themeGreen => 'Grün';

  @override
  String get settings_explanationMode => 'Erklärungsmodus';

  @override
  String get settings_howToExplain => 'Wie erklären';

  @override
  String get settings_uxSimple => 'Einfach';

  @override
  String get settings_uxPro => 'Pro';

  @override
  String get settings_uxSimpleDescription => 'Einfache Erklärungen';

  @override
  String get settings_uxProDescription => 'Detaillierte Erklärungen';

  @override
  String get settings_currency => 'Währung';

  @override
  String get settings_notifications => 'Benachrichtigungen';

  @override
  String get settings_bari => 'Bari Smart';

  @override
  String get settings_bariMode => 'Bari-Modus';

  @override
  String get settings_bariModeOffline => 'Offline';

  @override
  String get settings_bariModeOnline => 'Online';

  @override
  String get settings_bariModeHybrid => 'Hybrid';

  @override
  String get settings_showSources => 'Quellen anzeigen';

  @override
  String get settings_showSourcesDescription => 'Quellen für Tipps anzeigen';

  @override
  String get settings_smallTalk => 'Smalltalk';

  @override
  String get settings_smallTalkDescription => 'Smalltalk mit Bari erlauben';

  @override
  String get settings_parentZone => 'Elternbereich';

  @override
  String get settings_parentZoneDescription =>
      'Genehmigungen und Einstellungen verwalten';

  @override
  String get settings_tools => 'Werkzeuge';

  @override
  String get settings_toolsDescription => 'Rechner und andere Werkzeuge';

  @override
  String get settings_exportData => 'Daten exportieren';

  @override
  String get settings_importData => 'Daten importieren';

  @override
  String get settings_resetProgress => 'Fortschritt zurücksetzen';

  @override
  String get settings_resetProgressWarning =>
      'Bist du sicher, dass du den gesamten Fortschritt zurücksetzen möchtest? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get settings_cancel => 'Abbrechen';

  @override
  String get settings_progressReset => 'Fortschritt zurückgesetzt';

  @override
  String get settings_enterPinToConfirm => 'PIN zur Bestätigung eingeben';

  @override
  String get settings_wrongPin => 'Falsche PIN';

  @override
  String get priceComparisonCalculator_factSaved => 'Fakten gespeichert';

  @override
  String get twentyFourHourRuleCalculator_enterItemName =>
      'Artikelname eingeben';

  @override
  String get twentyFourHourRuleCalculator_reminderSet => 'Erinnerung gesetzt';

  @override
  String get twentyFourHourRuleCalculator_no => 'Nein';

  @override
  String get subscriptionsCalculator_no => 'Nein';

  @override
  String get subscriptionsCalculator_repeatDaily => 'Täglich';

  @override
  String get subscriptionsCalculator_repeatWeekly => 'Wöchentlich';

  @override
  String get subscriptionsCalculator_repeatMonthly => 'Monatlich';

  @override
  String get subscriptionsCalculator_repeatYearly => 'Jährlich';

  @override
  String get subscriptionsCalculator_enterSubscriptionName =>
      'Abonnementname eingeben';

  @override
  String get calendar_completed => 'Abgeschlossen';

  @override
  String get calendar_edit => 'Bearbeiten';

  @override
  String get calendar_reschedule => 'Verschieben';

  @override
  String get calendar_completeNow => 'Jetzt abschließen';

  @override
  String get calendar_showTransaction => 'Transaktion anzeigen';

  @override
  String get calendar_restore => 'Wiederherstellen';

  @override
  String get calendar_eventAlreadyCompleted => 'Ereignis bereits abgeschlossen';

  @override
  String get calendar_noPiggyBanks => 'Keine Spardosen';

  @override
  String get calendar_eventAlreadyCompletedWithTx =>
      'Ereignis bereits abgeschlossen. Transaktion erstellt.';

  @override
  String get calendar_sentToParentForApproval =>
      'An Eltern zur Genehmigung gesendet';

  @override
  String get calendar_addedToPiggyBank => 'zur Spardose hinzugefügt';

  @override
  String calendar_eventCompletedWithAmount(String amount) {
    return 'Ereignis abgeschlossen: $amount';
  }

  @override
  String get calendar_planContinues => 'Plan läuft weiter';

  @override
  String get calendar_cancelEvent => 'Ereignis abbrechen';

  @override
  String get calendar_cancelEventMessage =>
      'Bist du sicher, dass du dieses Ereignis abbrechen möchtest?';

  @override
  String get calendar_no => 'Nein';

  @override
  String get calendar_yesCancel => 'Ja, abbrechen';

  @override
  String get calendar_wantToReschedule =>
      'Möchtest du das Ereignis verschieben?';

  @override
  String get calendar_eventRestored => 'Ereignis wiederhergestellt';

  @override
  String get calendar_eventUpdated => 'Ereignis aktualisiert';

  @override
  String get calendar_deleteEventConfirm => 'Ereignis löschen?';

  @override
  String get calendar_deleteEventSeriesMessage =>
      'Gesamte Ereignisserie löschen?';

  @override
  String get calendar_deleteAllRepeatingConfirm =>
      'Alle wiederholenden Ereignisse werden gelöscht. Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get calendar_undo => 'Rückgängig';

  @override
  String get calendar_editScopeTitle => 'Was bearbeiten?';

  @override
  String get calendar_editScopeSubtitle =>
      'Wählen Sie den Anwendungsbereich der Änderungen';

  @override
  String get calendar_editThisEventOnly => 'Nur dieses Ereignis';

  @override
  String get calendar_editThisEventOnlyDesc =>
      'Änderungen betreffen nur das ausgewählte Ereignis';

  @override
  String get calendar_editAllRepeating => 'Alle Wiederholungen';

  @override
  String get calendar_editAllRepeatingDesc =>
      'Änderungen gelten für alle Ereignisse in der Serie';

  @override
  String get calendar_deleteScopeTitle => 'Was löschen?';

  @override
  String get calendar_deleteScopeSubtitle => 'Wählen Sie den Löschbereich';

  @override
  String get calendar_deleteAllRepeatingDesc =>
      'Alle Ereignisse in der Serie werden gelöscht';

  @override
  String get calendar_cancel => 'Abbrechen';

  @override
  String get calendar_transactionNotFound => 'Transaktion nicht gefunden';

  @override
  String get calendar_transaction => 'Transaktion';

  @override
  String get calendar_transactionAmount => 'Betrag';

  @override
  String get calendar_transactionDate => 'Datum';

  @override
  String get calendar_transactionCategory => 'Kategorie';

  @override
  String get calendar_transactionNote => 'Notiz';

  @override
  String get deletedEvents_title => 'Gelöschte Ereignisse';

  @override
  String get deletedEvents_empty => 'Papierkorb ist leer';

  @override
  String deletedEvents_count(int count) {
    return '$count Ereignisse';
  }

  @override
  String get deletedEvents_restore => 'Wiederherstellen';

  @override
  String get deletedEvents_deletePermanent => 'Endgültig löschen';

  @override
  String get deletedEvents_deletedAt => 'Gelöscht:';

  @override
  String get deletedEvents_restored => 'Ereignis wiederhergestellt';

  @override
  String get deletedEvents_deleted => 'Ereignis endgültig gelöscht';

  @override
  String get deletedEvents_permanentDeleteTitle => 'Endgültig löschen?';

  @override
  String get deletedEvents_permanentDeleteMessage =>
      'Diese Aktion kann nicht rückgängig gemacht werden. Das Ereignis wird ohne Wiederherstellungsmöglichkeit gelöscht.';

  @override
  String get deletedEvents_clearOld => 'Alte löschen';

  @override
  String get deletedEvents_clearOldTitle => 'Alte Ereignisse löschen?';

  @override
  String get deletedEvents_clearOldMessage =>
      'Ereignisse löschen, die sich seit mehr als 30 Tagen im Papierkorb befinden?';

  @override
  String deletedEvents_clearedCount(int count) {
    return '$count Ereignisse gelöscht';
  }

  @override
  String get deletedEvents_restoreScopeTitle => 'Was wiederherstellen?';

  @override
  String get deletedEvents_restoreScopeMessage =>
      'Wählen Sie den Wiederherstellungsbereich';

  @override
  String get subscriptions_filter => 'Filter';

  @override
  String get subscriptions_all => 'Alle';

  @override
  String get subscriptions_income => 'Einkommen';

  @override
  String get subscriptions_expense => 'Ausgaben';

  @override
  String get subscriptions_type => 'Typ';

  @override
  String get bariChat_title => 'Chat mit Bari';

  @override
  String get bariChat_welcomeDefault =>
      'Hallo! Ich bin Bari, dein Finanzhelfer. Wie kann ich helfen?';

  @override
  String get bariChat_welcomeCalculator =>
      'Hallo! Du verwendest einen Rechner. Brauchst du Hilfe bei den Berechnungen?';

  @override
  String get bariChat_welcomePiggyBank =>
      'Hallo! Reden wir über eine Spardose? Erzähl mir, was du wissen möchtest!';

  @override
  String get bariChat_welcomePlannedEvent =>
      'Hallo! Du hast ein geplantes Ereignis. Fragen zur Planung?';

  @override
  String get bariChat_welcomeLesson =>
      'Hallo! Du machst eine Lektion. Etwas unklar? Frag mich!';

  @override
  String bariChat_welcomeTask(String title) {
    return 'Hallo! Lass uns über die Aufgabe \"$title\" sprechen? Ich kann bei Belohnung, Zeit oder Schwierigkeit helfen.';
  }

  @override
  String get bariChat_fallbackResponse =>
      'Entschuldige, ich habe das nicht verstanden. Versuche, deine Frage umzuformulieren.';

  @override
  String get bariChat_source => 'Quelle';

  @override
  String get bariChat_close => 'Schließen';

  @override
  String get bariChat_inputHint => 'Schreibe eine Nachricht...';

  @override
  String get bariChat_thinking => 'Denke nach...';

  @override
  String get bariChat_task => 'Aufgabe';

  @override
  String get calculatorsList_title => 'Rechner';

  @override
  String get calculatorsList_piggyPlan => 'Spardosen-Plan';

  @override
  String get calculatorsList_piggyPlanDesc => 'Wie viel für ein Ziel sparen';

  @override
  String get calculatorsList_goalDate => 'Wann erreiche ich mein Ziel';

  @override
  String get calculatorsList_goalDateDesc =>
      'Erreichungsdatum bei regelmäßigen Beiträgen';

  @override
  String get calculatorsList_monthlyBudget => 'Monatlicher Ausgabenplan';

  @override
  String get calculatorsList_monthlyBudgetDesc =>
      'Limit und Rest für den Monat';

  @override
  String get calculatorsList_subscriptions => 'Abos & regelmäßige Zahlungen';

  @override
  String get calculatorsList_subscriptionsDesc =>
      'Was regelmäßige Ausgaben kosten';

  @override
  String get calculatorsList_canIBuy => 'Kann ich das jetzt kaufen?';

  @override
  String get calculatorsList_canIBuyDesc => 'Kaufbarkeit prüfen';

  @override
  String get calculatorsList_priceComparison => 'Preisvergleich';

  @override
  String get calculatorsList_priceComparisonDesc => 'Was ist günstiger';

  @override
  String get calculatorsList_24hRule => '24-Stunden-Regel';

  @override
  String get calculatorsList_24hRuleDesc => 'Impulskäufe verschieben';

  @override
  String get calculatorsList_budget503020 => '50/30/20 Budget';

  @override
  String get calculatorsList_budget503020Desc => 'Einkommensverteilung';

  @override
  String get earningsLab_title => 'Verdienst-Labor';

  @override
  String get earningsLab_explanationSimple =>
      'Aufgabe planen → im Kalender erledigen → Belohnung erhalten.';

  @override
  String get earningsLab_explanationPro =>
      'Verdienstlabor: Plane zuerst eine Aufgabe für ein Datum, markiere sie dann im Kalender als erledigt. Belohnung wird automatisch gutgeschrieben. Planung hilft, wichtige Dinge nicht zu vergessen.';

  @override
  String get earningsLab_taskAdded => 'Aufgabe hinzugefügt!';

  @override
  String get earningsLab_tabQuick => 'Schnell';

  @override
  String get earningsLab_tabHome => 'Zuhause';

  @override
  String get earningsLab_tabProjects => 'Projekte';

  @override
  String get earningsLab_helpAtHome => 'Zu Hause helfen';

  @override
  String get earningsLab_helpAtHomeDesc =>
      'Wähle eine Aufgabe: Geschirr / Müll / Staub / Boden / Tisch. Mache 10-15 Minuten und schließe ab.';

  @override
  String get earningsLab_learnPoem => 'Ein Gedicht lernen';

  @override
  String get earningsLab_learnPoemDesc =>
      '3 Mal lesen, Zeile für Zeile lernen, dann ohne Hilfe vortragen.';

  @override
  String get earningsLab_cleanRoom => 'Zimmer aufräumen';

  @override
  String get earningsLab_cleanRoomDesc =>
      '10-15 Minuten aufräumen: Spielzeug wegräumen, Tisch sauber, Müll entsorgen.';

  @override
  String get earningsLab_readBook => 'Ein Buch lesen';

  @override
  String get earningsLab_readBookDesc =>
      'Lies ein Kapitel aus einem interessanten Buch. Lesen fördert Fantasie und Wortschatz.';

  @override
  String get earningsLab_helpCooking => 'Beim Kochen helfen';

  @override
  String get earningsLab_helpCookingDesc =>
      'Hilf den Eltern beim Mittag- oder Abendessen. Du lernst einfache Gerichte zu kochen!';

  @override
  String get earningsLab_homework => 'Hausaufgaben machen';

  @override
  String get earningsLab_homeworkDesc =>
      'Erledige alle Hausaufgaben ordentlich und pünktlich. Das ist deine Hauptaufgabe!';

  @override
  String get earningsLab_helpShopping => 'Beim Einkaufen helfen';

  @override
  String get earningsLab_helpShoppingDesc =>
      'Geh mit den Eltern einkaufen und hilf beim Tragen. Du lernst Ausgaben zu planen!';

  @override
  String get earningsLab_tagLearning => 'Lernen';

  @override
  String get earningsLab_tagHelp => 'Hilfe';

  @override
  String get earningsLab_tagCreativity => 'Kreativität';

  @override
  String get rule24h_title => '24-Stunden-Regel';

  @override
  String get rule24h_subtitle =>
      'Hilft, Impulskäufe zu vermeiden: Verschiebe die Entscheidung um einen Tag und prüfe dich erneut.';

  @override
  String get rule24h_step1 => 'Will';

  @override
  String get rule24h_step2 => 'Preis';

  @override
  String get rule24h_step3 => 'Pause';

  @override
  String get rule24h_wantToBuy => 'Ich möchte kaufen';

  @override
  String get rule24h_example => 'Zum Beispiel: Kopfhörer';

  @override
  String get rule24h_price => 'Preis';

  @override
  String get rule24h_explanation =>
      'Wenn du es nach 24 Stunden noch willst — ist der Kauf bewusster. Wenn nicht — hast du gespart und Selbstkontrolle geübt.';

  @override
  String get rule24h_postpone => '24 Stunden verschieben';

  @override
  String get rule24h_reminderSet =>
      'Erinnerung gesetzt. Komm in 24 Stunden zurück, um dein Verlangen erneut zu prüfen.';

  @override
  String get rule24h_checkAgain => 'Erneut prüfen';

  @override
  String get rule24h_dialogTitle => 'Bestätigung';

  @override
  String get rule24h_dialogSubtitle => 'Erinnerung erstellen';

  @override
  String rule24h_dialogContent(String itemName) {
    return 'Eine Erinnerung in 24 Stunden erstellen, um zu prüfen, ob du \"$itemName\" noch kaufen möchtest?';
  }

  @override
  String get rule24h_reminderIn24h => 'Erinnerung kommt in 24 Stunden';

  @override
  String rule24h_eventName(String itemName) {
    return 'Wunschprüfung: $itemName';
  }

  @override
  String get rule24h_checkTitle => 'Wunschprüfung';

  @override
  String get rule24h_checkSubtitle => '24 Stunden sind vergangen';

  @override
  String get rule24h_stillWant => 'Willst du das noch kaufen?';

  @override
  String get rule24h_yes => 'Ja';

  @override
  String get budget503020_title => '50/30/20 Budget';

  @override
  String get budget503020_subtitle =>
      'Teile dein Einkommen in 3 Teile: Bedarf, Wünsche und Sparen.';

  @override
  String get budget503020_step1 => 'Einkommen';

  @override
  String get budget503020_step2 => 'Verteilung';

  @override
  String get budget503020_step3 => 'Spardosen';

  @override
  String get budget503020_incomeLabel => 'Mein monatliches Einkommen';

  @override
  String get budget503020_needs50 => 'Bedarf (50%)';

  @override
  String get budget503020_wants30 => 'Wünsche (30%)';

  @override
  String get budget503020_savings20 => 'Sparen (20%)';

  @override
  String get budget503020_tip =>
      'Tipp: Wenn du schneller sparen willst — beginne mit 10% Sparen und erhöhe schrittweise.';

  @override
  String get budget503020_createPiggyBanks => '3 Spardosen erstellen';

  @override
  String get budget503020_dialogTitle => 'Bestätigung';

  @override
  String get budget503020_dialogSubtitle =>
      'Spardosen nach der 50/30/20-Regel erstellen';

  @override
  String get priceComparison_title => 'Preisvergleich';

  @override
  String get priceComparison_subtitle =>
      'Vergleiche zwei Optionen und finde heraus, welche pro Einheit günstiger ist.';

  @override
  String get priceComparison_step1 => 'Option A';

  @override
  String get priceComparison_step2 => 'Option B';

  @override
  String get priceComparison_step3 => 'Ergebnis';

  @override
  String get priceComparison_priceA => 'Preis A';

  @override
  String get priceComparison_quantityA => 'Menge / Gewicht A';

  @override
  String get priceComparison_priceB => 'Preis B';

  @override
  String get priceComparison_quantityB => 'Menge / Gewicht B';

  @override
  String get priceComparison_result => 'Ergebnis';

  @override
  String get priceComparison_pricePerUnitA => 'Preis pro Einheit A';

  @override
  String get priceComparison_pricePerUnitB => 'Preis pro Einheit B';

  @override
  String priceComparison_betterOption(String option, String percent) {
    return 'Besser: Option $option (Ersparnis ~$percent%)';
  }

  @override
  String get priceComparison_saveForBari => 'Ergebnis für Bari speichern';

  @override
  String get subscriptions_title => 'Abos & regelmäßige Zahlungen';

  @override
  String get subscriptions_regular => 'Regelmäßige Zahlung';

  @override
  String get calendar_today => 'Heute';

  @override
  String get calendar_noEvents => 'Keine Ereignisse';

  @override
  String calendar_eventsCount(int count, String events) {
    return '$count $events';
  }

  @override
  String get calendar_event => 'Ereignis';

  @override
  String get calendar_events234 => 'Ereignisse';

  @override
  String get calendar_events5plus => 'Ereignisse';

  @override
  String get calendar_freeDay => 'Freier Tag';

  @override
  String get calendar_noEventsOnDay =>
      'Für diesen Tag ist nichts geplant.\nVielleicht ist es Zeit, etwas hinzuzufügen?';

  @override
  String get calendar_startPlanning => 'Fang an zu planen! 🚀';

  @override
  String get calendar_createFirstEvent =>
      'Erstelle dein erstes Ereignis — es macht Sparen und Erinnern einfacher';

  @override
  String get calendar_createFirstPlan => 'Ersten Plan erstellen';

  @override
  String get calendar_addEvent => 'Ereignis hinzufügen';

  @override
  String get calendar_income => 'Einnahmen';

  @override
  String get calendar_expense => 'Ausgaben';

  @override
  String get calendar_done => 'Erledigt';

  @override
  String get calendar_confirmCompletion => 'Abschluss bestätigen';

  @override
  String get calendar_amount => 'Betrag';

  @override
  String get calendar_confirm => 'Bestätigen';

  @override
  String get calendar_rescheduleEvent => 'Ereignis verschieben';

  @override
  String get calendar_dateAndTime => 'Datum und Uhrzeit';

  @override
  String get calendar_notification => 'Benachrichtigung';

  @override
  String get calendar_move => 'Verschieben';

  @override
  String calendar_whereToAdd(String amount) {
    return 'Wohin $amount hinzufügen?';
  }

  @override
  String get calendar_toWallet => 'In den Geldbeutel';

  @override
  String get calendar_availableForSpending => 'Verfügbar zum Ausgeben';

  @override
  String get calendar_toPiggyBank => 'In die Spardose';

  @override
  String get calendar_forGoal => 'Für ein Ziel';

  @override
  String get calendar_selectPiggyBank => 'Spardose auswählen';

  @override
  String get calendar_eventCompleted => 'Ereignis abgeschlossen! +15 XP';

  @override
  String get calendar_eventCancelled => 'Ereignis abgebrochen';

  @override
  String get calendar_eventDeleted => 'Ereignis gelöscht';

  @override
  String get calendar_eventCompletedXp => 'Ereignis abgeschlossen! +15 XP';

  @override
  String get calendar_invalidAmount => 'Bitte gib einen gültigen Betrag ein';

  @override
  String get calendar_date => 'Datum';

  @override
  String get calendar_time => 'Uhrzeit';

  @override
  String get calendar_everyDay => 'Jeden Tag';

  @override
  String get calendar_everyWeek => 'Jede Woche';

  @override
  String get calendar_everyMonth => 'Jeden Monat';

  @override
  String get calendar_everyYear => 'Jedes Jahr';

  @override
  String get calendar_repeat => 'Wiederholen';

  @override
  String get calendar_noRepeat => 'Keine';

  @override
  String get calendar_deleteAction =>
      'Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get calendar_week => 'Woche';

  @override
  String get calendar_month => 'Monat';

  @override
  String get parentZone_title => 'Elternbereich';

  @override
  String get parentZone_approvals => 'Ausstehende Genehmigungen';

  @override
  String get parentZone_statistics => 'Statistik';

  @override
  String get parentZone_settings => 'Einstellungen';

  @override
  String get parentZone_pinMustBe4Digits => 'PIN muss 4 Ziffern enthalten';

  @override
  String get parentZone_wrongPin => 'Falsche PIN';

  @override
  String get parentZone_pinChanged => 'PIN geändert';

  @override
  String get parentZone_premiumUnlocked => 'Premium freigeschaltet';

  @override
  String get parentZone_resetData => 'Daten zurücksetzen';

  @override
  String get parentZone_resetWarning =>
      'WARNUNG! Diese Aktion löscht ALLE Anwendungsdaten.';

  @override
  String get parentZone_enterPinToConfirm => 'PIN zur Bestätigung eingeben:';

  @override
  String get parentZone_pin => 'PIN';

  @override
  String get parentZone_reset => 'Zurücksetzen';

  @override
  String get parentZone_allDataDeleted => 'Alle Daten gelöscht';

  @override
  String parentZone_resetError(String error) {
    return 'Fehler beim Zurücksetzen: $error';
  }

  @override
  String get parentZone_login => 'Anmelden';

  @override
  String get parentZone_unlockPremium => 'Premium freischalten';

  @override
  String get parentZone_edit => 'Bearbeiten';

  @override
  String get parentZone_close => 'Schließen';

  @override
  String get parentZone_earningsApproved => 'Verdienst genehmigt';

  @override
  String get parentZone_earningsRejected => 'Verdienst abgelehnt';

  @override
  String get exportImport_title => 'Export/Import';

  @override
  String get exportImport_exportData => 'Daten exportieren';

  @override
  String get exportImport_exportDescription =>
      'Alle Daten in JSON-Datei speichern';

  @override
  String get exportImport_export => 'Exportieren';

  @override
  String get exportImport_importData => 'Daten importieren';

  @override
  String get exportImport_importDescription => 'Daten aus JSON-Datei laden';

  @override
  String get exportImport_import => 'Importieren';

  @override
  String get exportImport_dataCopied => 'Daten in Zwischenablage kopiert';

  @override
  String exportImport_exportError(String error) {
    return 'Exportfehler: $error';
  }

  @override
  String get exportImport_importSuccess => 'Daten erfolgreich importiert';

  @override
  String get exportImport_importError => 'Importfehler';

  @override
  String exportImport_importErrorDetails(String error) {
    return 'Daten konnten nicht importiert werden:\n$error';
  }

  @override
  String get exportImport_pasteJson => 'JSON-Daten einfügen';

  @override
  String get minitrainers_result => 'Ergebnis';

  @override
  String minitrainers_correctAnswers(int score, int total, int xp) {
    return 'Richtige Antworten: $score/$total\n+$xp XP';
  }

  @override
  String get minitrainers_great => 'Großartig!';

  @override
  String get minitrainers_findExtraPurchase => 'Finde den überflüssigen Kauf';

  @override
  String get minitrainers_answer => 'Antworten';

  @override
  String minitrainers_xpEarned(int xp) {
    return '+$xp XP';
  }

  @override
  String get minitrainers_buildBudget => 'Budget erstellen';

  @override
  String get minitrainers_check => 'Prüfen';

  @override
  String get minitrainers_wellDone => 'Gut gemacht!';

  @override
  String get minitrainers_xp15 => '+15 XP';

  @override
  String get minitrainers_discountOrTrap => 'Rabatt oder Falle?';

  @override
  String get minitrainers_yes => 'Ja';

  @override
  String get minitrainers_no => 'Nein';

  @override
  String get minitrainers_correct => 'Richtig!';

  @override
  String get minitrainers_goodTry => 'Guter Versuch';

  @override
  String get calculators_3PiggyBanksCreated => '3 Spardosen erstellt';

  @override
  String get rule24h_xp50 => '🎉 +50 XP für Selbstkontrolle!';

  @override
  String get subscriptions_frequency => 'Häufigkeit';

  @override
  String get statistics_title => 'Statistik';

  @override
  String get calculators_nDaysSavings => 'Ersparnisse für N Tage';

  @override
  String get calculators_weeklySavings => 'Wöchentliche Ersparnisse';

  @override
  String get calculators_piggyGoal => 'Spardosen-Ziel';

  @override
  String get earningsLab_schedule => 'Planen';

  @override
  String get recommendations_newTip => 'Neuer Tipp';

  @override
  String get earningsHistory_title => 'Verdiensthistorie';

  @override
  String get earningsHistory_all => 'Alle';

  @override
  String get calendarForecast_7days => '7 Tage';

  @override
  String get calendarForecast_30days => '30 Tage';

  @override
  String get calendarForecast_90days => '90 Tage';

  @override
  String get calendarForecast_year => 'Jahr';

  @override
  String get calendarForecast_summary => 'Zusammenfassung';

  @override
  String get calendarForecast_categories => 'Kategorien';

  @override
  String get calendarForecast_dates => 'Daten';

  @override
  String get calendarForecast_month => 'Monat';

  @override
  String get calendarForecast_all => 'Alle';

  @override
  String get calendarForecast_income => 'Einnahmen';

  @override
  String get calendarForecast_expenses => 'Ausgaben';

  @override
  String get calendarForecast_large => 'Groß';

  @override
  String get planEvent_amount => 'Betrag';

  @override
  String get planEvent_nameOptional => 'Name (optional)';

  @override
  String get planEvent_category => 'Kategorie';

  @override
  String get planEvent_date => 'Datum';

  @override
  String get planEvent_time => 'Uhrzeit';

  @override
  String get planEvent_repeat => 'Wiederholen';

  @override
  String get planEvent_notification => 'Benachrichtigung';

  @override
  String get planEvent_remindBefore => 'Erinnern vor';

  @override
  String get planEvent_atMoment => 'Zum Zeitpunkt';

  @override
  String get planEvent_15minutes => '15 Minuten vorher';

  @override
  String get planEvent_30minutes => '30 Minuten vorher';

  @override
  String get planEvent_1hour => '1 Stunde vorher';

  @override
  String get planEvent_1day => '1 Tag vorher';

  @override
  String get planEvent_eventChanged => 'Ereignis geändert';

  @override
  String get planEvent_repeatingEventWarning => 'Wiederholendes Ereignis';

  @override
  String get planEvent_repeatingEventDescription =>
      'Dieses Ereignis ist Teil einer wiederholenden Serie. Änderungen gelten für alle zukünftigen Ereignisse.';

  @override
  String get calendar_editEvent => 'Ereignis bearbeiten';

  @override
  String get calendar_planEvent => 'Ereignis planen';

  @override
  String get planEvent_eventType => 'Ereignistyp';

  @override
  String get transaction_income => 'Einkommen';

  @override
  String get transaction_expense => 'Ausgabe';

  @override
  String get category_food => 'Essen';

  @override
  String get category_transport => 'Transport';

  @override
  String get category_entertainment => 'Unterhaltung';

  @override
  String get category_other => 'Sonstiges';

  @override
  String get minitrainers_60seconds => '60 Sekunden';

  @override
  String get earningsLab_wrongPin =>
      'Falscher PIN. Eltern-Genehmigung erforderlich.';

  @override
  String get earningsLab_noPiggyBanks =>
      'Keine Sparschweine. Erstelle zuerst ein Sparschwein.';

  @override
  String get earningsLab_sentForApproval =>
      'An Eltern zur Genehmigung gesendet';

  @override
  String get earningsLab_amountCannotBeNegative =>
      'Betrag darf nicht negativ sein';

  @override
  String get earningsLab_wallet => 'Geldbörse';

  @override
  String get earningsLab_piggyBank => 'Sparschwein';

  @override
  String get earningsLab_no => 'Nein';

  @override
  String get earningsLab_daily => 'Täglich';

  @override
  String get earningsLab_weekly => 'Wöchentlich';

  @override
  String get earningsLab_reminder => 'Erinnerung';

  @override
  String get earningsLab_selectPiggyForReward =>
      'Sparschwein für Belohnung auswählen';

  @override
  String get earningsLab_createPlan => 'Plan erstellen';

  @override
  String get earningsLab_discussWithBari => 'Mit Bari besprechen';

  @override
  String get earningsLab_parentApprovalRequired =>
      'Eltern-Genehmigung erforderlich';

  @override
  String get earningsLab_fillRequiredFields =>
      'Bitte füllen Sie die erforderlichen Felder aus';

  @override
  String earningsLab_completed(String title) {
    return 'Abgeschlossen: $title';
  }

  @override
  String get earningsLab_howMuchEarned => 'Wie viel hast du verdient?';

  @override
  String get earningsLab_whatWasDifficult => 'Was war schwierig?';

  @override
  String get earningsLab_addCustomTask => 'Eigene Aufgabe hinzufügen';

  @override
  String get earningsLab_canRepeat => 'Kann wiederholt werden';

  @override
  String get earningsLab_requiresParent => 'Eltern erforderlich';

  @override
  String get earningsLab_taskName => 'Aufgabename *';

  @override
  String get earningsLab_taskNameHint => 'Zum Beispiel: Oma helfen';

  @override
  String get earningsLab_description => 'Beschreibung';

  @override
  String get earningsLab_descriptionHint => 'Was muss getan werden?';

  @override
  String get earningsLab_descriptionOptional => 'Beschreibung (optional)';

  @override
  String get earningsLab_descriptionOptionalHint =>
      'Zum Beispiel: was genau getan werden muss';

  @override
  String get earningsLab_time => 'Zeit *';

  @override
  String get earningsLab_timeHint => 'Zum Beispiel: 30 Min';

  @override
  String get earningsLab_reward => 'Belohnung';

  @override
  String get earningsLab_xp => 'XP';

  @override
  String get earningsLab_difficulty => 'Schwierigkeit';

  @override
  String get earningsLab_repeat => 'Wiederholen';

  @override
  String get earningsLab_rewardMustBePositive =>
      'Belohnung muss größer als null sein';

  @override
  String get earningsLab_taskDescription => 'Keine Beschreibung';

  @override
  String get earningsLab_rewardHelper =>
      'Wie viel bekommst du für die Erfüllung';

  @override
  String get earningsLab_taskNameRequired => 'Aufgabename eingeben';

  @override
  String get settings_aiModelGpt4oMini => 'GPT-4o Mini (schnell)';

  @override
  String get settings_aiModelGpt4o => 'GPT-4o (intelligent)';

  @override
  String get settings_aiModelGpt4Turbo => 'GPT-4 Turbo';

  @override
  String get settings_aiModelGpt35 => 'GPT-3.5 (günstig)';

  @override
  String get settings_geminiNano => 'KI auf dem Gerät (Gemini Nano)';

  @override
  String get settings_geminiNanoDescription =>
      'Kostenlose KI, die ohne Internet funktioniert';

  @override
  String get settings_geminiNanoStatus => 'Status';

  @override
  String get settings_geminiNanoAvailable => 'Verfügbar';

  @override
  String get settings_geminiNanoNotAvailable =>
      'Auf diesem Gerät nicht verfügbar';

  @override
  String get settings_geminiNanoDownloaded => 'Heruntergeladen und bereit';

  @override
  String get settings_geminiNanoNotDownloaded => 'Nicht heruntergeladen';

  @override
  String get settings_geminiNanoDownload => 'Modell herunterladen (~2,5 GB)';

  @override
  String get settings_geminiNanoDownloading => 'Wird heruntergeladen...';

  @override
  String get settings_geminiNanoDelete => 'Modell löschen';

  @override
  String get settings_geminiNanoAdvantages => 'Vorteile';

  @override
  String get settings_geminiNanoAdvantagesTitle =>
      'Warum Gemini Nano herunterladen?';

  @override
  String get settings_geminiNanoAdvantage1 =>
      '💰 Völlig kostenlos — ohne Limits';

  @override
  String get settings_geminiNanoAdvantage2 =>
      '⚡ Sofortige Antworten — ohne Netzwerkverzögerung';

  @override
  String get settings_geminiNanoAdvantage3 =>
      '🔒 100% Privatsphäre — Daten bleiben auf dem Gerät';

  @override
  String get settings_geminiNanoAdvantage4 =>
      '📱 Funktioniert offline — kein Internet nötig';

  @override
  String get settings_geminiNanoAdvantage5 =>
      '🌍 Unterstützt 3 Sprachen — Deutsch, Englisch, Russisch';

  @override
  String get settings_geminiNanoRequirements => 'Anforderungen';

  @override
  String get settings_geminiNanoRequirement1 =>
      'Android 14+ (Google Pixel 8+, Samsung S24+, OnePlus 12+)';

  @override
  String get settings_geminiNanoRequirement2 => '~2,5 GB freier Speicherplatz';

  @override
  String get settings_geminiNanoRequirement3 => '6 GB RAM';

  @override
  String get settings_geminiNanoDownloadConfirm =>
      'Gemini Nano Modell herunterladen?';

  @override
  String get settings_geminiNanoDownloadConfirmDescription =>
      'Das Modell benötigt ~2,5 GB Speicherplatz, gibt Ihnen aber kostenlose KI ohne Internet.';

  @override
  String get settings_geminiNanoDeleteConfirm => 'Modell löschen?';

  @override
  String get settings_geminiNanoDeleteConfirmDescription =>
      'Gibt ~2,5 GB Speicherplatz frei, aber die KI auf dem Gerät funktioniert nicht mehr.';

  @override
  String get settings_geminiNanoError => 'Fehler';

  @override
  String get settings_geminiNanoErrorDownload =>
      'Modell konnte nicht heruntergeladen werden. Überprüfen Sie Ihre Internetverbindung.';

  @override
  String get settings_geminiNanoErrorDelete =>
      'Modell konnte nicht gelöscht werden.';

  @override
  String get settings_geminiNanoSuccessDownload =>
      'Modell erfolgreich heruntergeladen!';

  @override
  String get settings_geminiNanoSuccessDelete => 'Modell gelöscht.';

  @override
  String get bari_goal_noPiggyBanks => 'Du hast noch keine Sparschweine.';

  @override
  String get bari_goal_noPiggyBanksAdvice =>
      'Erstelle dein erstes Sparschwein mit einem Ziel — das ist der Hauptschritt zum Sparen! Was möchtest du kaufen?';

  @override
  String get bari_goal_createPiggyBank => 'Sparschwein erstellen';

  @override
  String get bari_goal_whenWillReach => 'Wann erreiche ich das Ziel';

  @override
  String bari_goal_onePiggyBank(String amount) {
    return 'Du hast 1 Sparschwein mit $amount drin.';
  }

  @override
  String bari_goal_multiplePiggyBanks(int count, String total) {
    return 'Du hast $count Sparschweine, insgesamt gespart $total.';
  }

  @override
  String bari_goal_almostFull(String name, int percent) {
    return 'Sparschwein \"$name\" ist fast voll ($percent%)! 🎉 Ziel bald!';
  }

  @override
  String bari_goal_justStarted(String name, int percent) {
    return 'Sparschwein \"$name\" wurde gerade gestartet ($percent%). Zeit zum Auffüllen!';
  }

  @override
  String get bari_goal_goodProgress =>
      'Guter Fortschritt! Spare weiter regelmäßig.';

  @override
  String get bari_goal_piggyBanks => 'Sparschweine';

  @override
  String get bari_goal_createFirst =>
      'Du hast noch keine Sparschweine — erstelle dein erstes!';

  @override
  String get bari_goal_createFirstAdvice =>
      'Wähle ein Ziel: Spielzeug, Gadget, Geschenk. Und beginne mit kleinen Beiträgen.';

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
      'Alle Sparschweine sind voll oder leer. Erstelle ein neues Ziel!';

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
    return 'Noch $needed sparen';
  }

  @override
  String bari_goal_needToSaveAdvice(String perMonth) {
    return 'Если откладывать по $perMonth в месяц, успеешь! Создай копилку с целью.';
  }

  @override
  String get bari_goal_savingSecret =>
      'Das Hauptgeheimnis des Sparens — Regelmäßigkeit!';

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
  String get bari_emptyMessage => 'Schreibe eine Frage 🙂';

  @override
  String get bari_emptyMessageAdvice =>
      'Zum Beispiel: \"kann ich für 20€ kaufen\" oder \"was ist Inflation\"';

  @override
  String get bari_balance => 'Kontostand';

  @override
  String get bari_piggyBanks => 'Sparschweine';

  @override
  String bari_math_percentOf(String percent, String base, String result) {
    return '$percent% от $base = $result';
  }

  @override
  String bari_math_percentAdvice(String percent) {
    return 'Полезно знать: если откладывать $percent% от дохода, это поможет копить регулярно.';
  }

  @override
  String get bari_math_calculator503020 => '50/30/20 Rechner';

  @override
  String get bari_math_explainSimpler => 'Einfacher erklären';

  @override
  String bari_math_monthlyToYearly(String monthly, String yearly) {
    return '$monthly в месяц = $yearly в год';
  }

  @override
  String get bari_math_monthlyToYearlyAdvice =>
      'Kleine regelmäßige Beträge sammeln sich! Abonnements sind auch wert, pro Jahr zu zählen.';

  @override
  String get bari_math_subscriptionsCalculator => 'Abonnement-Rechner';

  @override
  String bari_math_saveYearly(String monthly, String yearly) {
    return 'Если откладывать по $monthly в месяц, за год накопится $yearly';
  }

  @override
  String get bari_math_saveYearlyAdvice =>
      'Regelmäßigkeit ist wichtiger als Betrag! Beginne klein und steigere allmählich.';

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
      'Erstelle ein Sparschwein mit diesem Ziel — einfacher nicht zu vergessen!';

  @override
  String get bari_math_alreadyEnough => 'Du hast schon genug gespart! 🎉';

  @override
  String get bari_math_alreadyEnoughAdvice =>
      'Ziel erreicht — du kannst ausgeben oder weiter für etwas Größeres sparen.';

  @override
  String bari_math_remainingToSave(String remaining, int percent) {
    return 'Осталось накопить $remaining (уже $percent% от цели)';
  }

  @override
  String get bari_math_remainingAdvice =>
      'Du bist auf dem richtigen Weg! Halte das Tempo.';

  @override
  String bari_math_multiply(String a, String b, String result) {
    return '$a × $b = $result';
  }

  @override
  String get bari_math_multiplyAdvice =>
      'Multiplikation hilft regelmäßige Ausgaben zu zählen: tägliche für einen Monat, monatliche für ein Jahr.';

  @override
  String get bari_math_calculators => 'Rechner';

  @override
  String get bari_math_divideByZero => 'Kann nicht durch null teilen!';

  @override
  String get bari_math_divideByZeroAdvice =>
      'Es ist wie Pizza unter null Freunden zu teilen — niemand zum Essen.';

  @override
  String bari_math_divide(String a, String b, String result) {
    return '$a ÷ $b = $result';
  }

  @override
  String get bari_math_divideAdvice =>
      'Division hilft zu verstehen, wie viel pro Woche/Monat für ein Ziel gespart werden muss.';

  @override
  String bari_math_priceComparison(int better, String price1, String price2) {
    return 'Вариант $better выгоднее! ($price1 за единицу vs $price2)';
  }

  @override
  String bari_math_priceComparisonAdvice(int savings) {
    return 'Экономия ~$savings%. Но проверь: успеешь ли использовать большую упаковку?';
  }

  @override
  String get bari_math_priceComparisonCalculator => 'Preisvergleich';

  @override
  String bari_math_rule72(String rate, String years) {
    return 'При $rate% годовых деньги удвоятся примерно за $years лет';
  }

  @override
  String bari_math_rule72Advice(String rate) {
    return 'Это \"Правило 72\" — быстрый способ оценить рост накоплений. Чем выше %, тем быстрее рост, но и риск выше.';
  }

  @override
  String get bari_math_lessons => 'Lektionen';

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
      'Noch nicht genug Daten über deine Einnahmen und Ausgaben.';

  @override
  String get bari_spending_noDataAdvice =>
      'Fahre fort, Transaktionen aufzuzeichnen — dann kann ich bessere Ratschläge geben.';

  @override
  String bari_goal_deadlineSoon(String name, int days) {
    return 'Fülle \"$name\" auf — noch $days Tage bis zum Termin!';
  }

  @override
  String bari_goal_closeToGoal(String name, int progress, String remaining) {
    return 'Ich rate dir, \"$name\" aufzufüllen ($progress%) — noch $remaining, du bist nah am Ziel!';
  }

  @override
  String get bari_goal_whichPiggyBankAdvice =>
      'Besser das Sparschwein auffüllen, das näher am Ziel ist oder bald einen Termin hat.';

  @override
  String get bari_goal_alreadyEnough => 'Ja, du hast schon genug Geld! 🎉';

  @override
  String bari_goal_alreadyEnoughAdvice(String available, String target) {
    return 'Insgesamt verfügbar $available (Geldbörse + Sparschweine), benötigt $target.';
  }

  @override
  String bari_goal_savePerMonth(String perMonth) {
    return 'Wenn du $perMonth pro Monat sparst, schaffst du es! Erstelle ein Sparschwein mit einem Ziel.';
  }

  @override
  String bari_goal_emptyWallet(String balance) {
    return 'Geldbörse ist fast leer ($balance). Zeit zum Sparen!';
  }

  @override
  String bari_goal_lowBalance(String balance) {
    return 'Geldbörse hat $balance — kann Sparschwein auffüllen oder für Ausgaben lassen.';
  }

  @override
  String bari_goal_goodBalance(String balance) {
    return 'Geldbörse hat $balance — großartiger Kontostand! Kann Sparschweine auffüllen.';
  }

  @override
  String get bari_goal_createFirstPiggyBank =>
      'Erstelle dein erstes Sparschwein — ein Ziel motiviert zum Sparen.';

  @override
  String get bari_goal_setDeadline =>
      'Setze einen Termin für das Sparschwein — einfacher zu planen.';

  @override
  String get bari_goal_regularTopUps =>
      'Fülle Sparschweine regelmäßig auf, auch mit kleinen Beträgen.';

  @override
  String get bari_goal_checkProgress =>
      'Prüfe den Fortschritt der Sparschweine — das motiviert!';

  @override
  String get bari_goal_completeLessons =>
      'Absolviere Lektionen zum Sparen — du lernst nützliche Tipps.';

  @override
  String bari_math_percentOfResult(String percent, String base, String result) {
    return '$percent% von $base = $result';
  }

  @override
  String bari_math_percentAdviceWithPercent(String percent) {
    return 'Gut zu wissen: Wenn du $percent% des Einkommens sparst, hilft das regelmäßig zu sparen.';
  }

  @override
  String bari_math_monthlyToYearlyResult(String monthly, String yearly) {
    return '$monthly pro Monat = $yearly pro Jahr';
  }

  @override
  String bari_math_saveYearlyResult(String monthly, String yearly) {
    return 'Wenn du $monthly pro Monat sparst, sammelst du $yearly pro Jahr';
  }

  @override
  String bari_math_savePerPeriodResult(
    String target,
    String perPeriod,
    String period,
  ) {
    return 'Um $target zu sparen, muss man $perPeriod pro $period sparen';
  }

  @override
  String get bari_math_createPiggyBank => 'Sparschwein erstellen';

  @override
  String get bari_math_whenWillReach => 'Wann erreiche ich das Ziel';

  @override
  String bari_math_remainingToSaveResult(String remaining, int percent) {
    return 'Noch $remaining sparen (bereits $percent% vom Ziel)';
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
    return 'Option $better ist besser! ($price1 pro Einheit vs $price2)';
  }

  @override
  String bari_math_priceComparisonAdviceWithSavings(int savings) {
    return 'Ersparnis ~$savings%. Aber prüfe: wirst du die größere Packung nutzen?';
  }

  @override
  String bari_math_rule72Result(String rate, String years) {
    return 'Bei $rate% Jahreszins verdoppelt sich das Geld in etwa $years Jahren';
  }

  @override
  String bari_math_rule72AdviceWithRate(String rate) {
    return 'Das ist die \"72er-Regel\" — ein schneller Weg, das Sparwachstum zu schätzen. Je höher der %, desto schneller das Wachstum, aber auch das Risiko.';
  }

  @override
  String bari_math_inflationResult(
    String amount,
    String years,
    String realValue,
  ) {
    return '$amount in $years Jahren werden \"wert\" sein wie $realValue heute';
  }

  @override
  String bari_math_inflationAdviceWithAmount(String amount, String years) {
    return 'Inflation \"frisst\" Geld. Deshalb ist es wichtig, nicht nur zu sparen, sondern auch zu lernen zu investieren (wenn du älter wirst).';
  }

  @override
  String get earningsLab_piggyBankNotFound => 'Sparschwein nicht gefunden';

  @override
  String get earningsLab_noTransactions =>
      'Noch keine Transaktionen für dieses Sparschwein';

  @override
  String get earningsLab_transactionHistory =>
      'Transaktionshistorie für dieses Sparschwein';

  @override
  String get earningsLab_topUp => 'Sparschwein-Auffüllung';

  @override
  String get earningsLab_withdrawal => 'Abhebung vom Sparschwein';

  @override
  String get earningsLab_goalReached => 'Ziel erreicht 🎉';

  @override
  String get earningsLab_goalReachedSubtitle =>
      'Gut gemacht! Du kannst ein neues Ziel erstellen oder Geld in die Geldbörse überweisen.';

  @override
  String get earningsLab_almostThere => 'Fast geschafft';

  @override
  String get earningsLab_almostThereSubtitle =>
      'Überlege, 1-2 weitere Auffüllungen zu machen — und das Ziel wird erreicht.';

  @override
  String get earningsLab_halfway => 'Halbzeit';

  @override
  String get earningsLab_halfwaySubtitle =>
      'Wenn du das Sparschwein regelmäßig auffüllst, erreichst du das Ziel viel schneller.';

  @override
  String get earningsLab_goodStart => 'Guter Start';

  @override
  String get earningsLab_goodStartSubtitle =>
      'Versuche, die automatische Auffüllung einzurichten oder eine Aufgabe im Verdienstlabor speziell für dieses Ziel hinzuzufügen.';

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
}
