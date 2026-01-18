import '../models/piggy_bank.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';

class AutoFillService {
  /// Проверяет и применяет автопополнение копилок при новом доходе
  static Future<void> processAutoFill(Transaction incomeTransaction) async {
    if (incomeTransaction.type != TransactionType.income) return;

    final banks = await StorageService.getPiggyBanks();
    final activeAutoFillBanks = banks.where((b) => b.autoFillEnabled).toList();

    for (var bank in activeAutoFillBanks) {
      int amountToAdd = 0;

      if (bank.autoFillType == AutoFillType.percent && bank.autoFillPercent != null) {
        // Процент от дохода
        amountToAdd =
            (incomeTransaction.amount * bank.autoFillPercent! / 100).round();
      } else if (bank.autoFillType == AutoFillType.fixed && bank.autoFillAmount != null) {
        // Фиксированная сумма
        amountToAdd = bank.autoFillAmount!;
      }

      if (amountToAdd > 0 && bank.currentAmount < bank.targetAmount) {
        // Не даём превысить цель: добавляем только доступную "ёмкость"
        final capacity = bank.targetAmount - bank.currentAmount;
        final actualAmount = amountToAdd > capacity ? capacity : amountToAdd;
        if (actualAmount <= 0) {
          continue;
        }

        final newAmount = bank.currentAmount + actualAmount;
        final updatedBank = bank.copyWith(
          currentAmount: newAmount,
        );

        final index = banks.indexWhere((b) => b.id == bank.id);
        if (index >= 0) {
          banks[index] = updatedBank;
        }

        // Создаём транзакцию для автопополнения
        final autoTransaction = Transaction(
          id: '${DateTime.now().millisecondsSinceEpoch}_auto_${bank.id}',
          type: TransactionType.expense, // автопополнение = расход из кошелька
          amount: actualAmount,
          date: DateTime.now(),
          note: 'Автопополнение: ${bank.name}',
          piggyBankId: bank.id,
          source: TransactionSource.piggyBank,
          // автопополнение уменьшает кошелёк (affectsWallet по умолчанию true)
        );
        await StorageService.addTransaction(autoTransaction);
      }
    }

    await StorageService.savePiggyBanks(banks);
  }
}


