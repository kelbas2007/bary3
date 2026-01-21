import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/money_formatter.dart';
import '../services/currency_scope.dart';
import '../utils/date_formatter.dart';
import '../l10n/app_localizations.dart';
import '../theme/aurora_theme.dart';
import '../utils/haptic_feedback_util.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final currencyCode = CurrencyScope.of(context).currencyCode;
    final l10n = AppLocalizations.of(context)!;

    // Определяем иконку и цвет
    IconData icon;
    Color color;

    if (transaction.piggyBankId != null) {
      icon = Icons.savings;
      color = Colors.orangeAccent;
    } else if (isIncome) {
      icon = Icons.arrow_downward;
      color = Colors.greenAccent;
    } else {
      icon = Icons.arrow_upward;
      color = Colors.redAccent;
    }

    // Переопределение иконки для категорий
    if (transaction.category != null) {
      // Простая логика иконок (можно расширить)
      if (transaction.category!.toLowerCase().contains('еда') ||
          transaction.category!.toLowerCase().contains('food')) {
        icon = Icons.fastfood;
      } else if (transaction.category!.toLowerCase().contains('транспорт') ||
          transaction.category!.toLowerCase().contains('transport')) {
        icon = Icons.directions_bus;
      } else if (transaction.category!.toLowerCase().contains('игра') ||
          transaction.category!.toLowerCase().contains('game')) {
        icon = Icons.videogame_asset;
      }
    }

    final categoryName = transaction.category ??
        (isIncome ? l10n.common_income : l10n.common_expense);
    final amountText = '${isIncome ? '+' : '-'}${formatMoney(amountMinor: transaction.amount, currencyCode: currencyCode, locale: Localizations.localeOf(context).toString())}';

    return Semantics(
      label: '$categoryName, $amountText',
      hint: transaction.note ?? LocalizedDateFormatter.formatDateTime(context, transaction.date),
      button: true,
      child: Hero(
        tag: 'transaction_${transaction.id}',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedbackUtil.lightImpact();
              // Можно добавить детальный просмотр транзакции
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AuroraTheme.spaceBlue.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: ListTile(
                leading: Hero(
                  tag: 'transaction_icon_${transaction.id}',
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                ),
                title: Text(
                  categoryName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: transaction.note != null
                    ? Text(
                        transaction.note!,
                        style: const TextStyle(color: Colors.white54),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : Text(
                        LocalizedDateFormatter.formatDateTime(context, transaction.date),
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                trailing: Hero(
                  tag: 'transaction_amount_${transaction.id}',
                  child: Text(
                    amountText,
                    style: TextStyle(
                      color: isIncome ? Colors.greenAccent : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
