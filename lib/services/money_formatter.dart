import 'package:intl/intl.dart';

String formatMoney({
  required int amountMinor,
  required String currencyCode,
  required String locale,
}) {
  final f = NumberFormat.currency(locale: locale, name: currencyCode);
  return f.format(amountMinor / 100.0);
}










