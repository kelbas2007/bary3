import 'package:flutter/material.dart';

import 'currency_scope.dart';
import 'money_formatter.dart';

/// Форматирование суммы для UI с учётом локали и выбранной валюты.
String formatAmountUi(BuildContext context, int amountMinor) {
  final locale = Localizations.localeOf(context).toString();
  final currencyCode = CurrencyScope.of(context).currencyCode;
  return formatMoney(
    amountMinor: amountMinor,
    currencyCode: currencyCode,
    locale: locale,
  );
}










