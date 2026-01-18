import 'package:flutter_test/flutter_test.dart';
import 'package:bary3/models/transaction.dart';
import 'package:bary3/models/planned_event.dart';

/// Тестируем логику расчета баланса из транзакций
/// Это чистая функция, которую можно протестировать без UI
int calculateBalance(
  List<Transaction> transactions, {
  bool showForecast = false,
  List<PlannedEvent> plannedEvents = const [],
  String filter = 'all',
}) {
  int balance = 0;
  final now = DateTime.now();

  // Фильтруем транзакции по времени
  final List<Transaction> filtered = transactions.where((t) {
    switch (filter) {
      case 'day':
        return t.date.year == now.year &&
            t.date.month == now.month &&
            t.date.day == now.day;
      case 'week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return t.date.isAfter(weekStart.subtract(const Duration(days: 1)));
      case 'month':
        return t.date.year == now.year && t.date.month == now.month;
      default:
        return true;
    }
  }).toList();

  for (var transaction in filtered) {
    // Игнорируем неодобренные транзакции
    if (transaction.parentApproved == false) {
      continue;
    }
    // Игнорируем транзакции, которые не влияют на кошелёк
    if (transaction.affectsWallet == false) {
      continue;
    }
    if (transaction.type == TransactionType.income) {
      balance += transaction.amount;
    } else {
      balance -= transaction.amount;
    }
  }

  // Если включён прогноз, добавляем запланированные события
  if (showForecast) {
    final periodEnd = now.add(Duration(
        days: filter == 'day' ? 1 : filter == 'week' ? 7 : filter == 'month' ? 30 : 90));

    for (var event in plannedEvents) {
      if (event.status == PlannedEventStatus.planned &&
          event.dateTime.isAfter(now) &&
          event.dateTime.isBefore(periodEnd)) {
        if (event.type == TransactionType.income) {
          balance += event.amount;
        } else {
          balance -= event.amount;
        }
      }
    }
  }

  return balance;
}

void main() {
  group('Balance Calculation Logic', () {
    test('calculates balance from income transactions', () {
      final transactions = [
        Transaction(
          id: '1',
          type: TransactionType.income,
          amount: 5000, // 50.00
          date: DateTime.now(),
        ),
        Transaction(
          id: '2',
          type: TransactionType.income,
          amount: 3000, // 30.00
          date: DateTime.now(),
        ),
      ];

      final balance = calculateBalance(transactions);
      expect(balance, equals(8000)); // 80.00
    });

    test('calculates balance from income and expense transactions', () {
      final transactions = [
        Transaction(
          id: '1',
          type: TransactionType.income,
          amount: 10000, // 100.00
          date: DateTime.now(),
        ),
        Transaction(
          id: '2',
          type: TransactionType.expense,
          amount: 3000, // 30.00
          date: DateTime.now(),
        ),
        Transaction(
          id: '3',
          type: TransactionType.expense,
          amount: 2000, // 20.00
          date: DateTime.now(),
        ),
      ];

      final balance = calculateBalance(transactions);
      expect(balance, equals(5000)); // 50.00
    });

    test('ignores unapproved transactions', () {
      final transactions = [
        Transaction(
          id: '1',
          type: TransactionType.income,
          amount: 5000,
          date: DateTime.now(),
          parentApproved: true,
        ),
        Transaction(
          id: '2',
          type: TransactionType.income,
          amount: 3000,
          date: DateTime.now(),
          parentApproved: false, // Не одобрено
        ),
      ];

      final balance = calculateBalance(transactions);
      expect(balance, equals(5000)); // Только одобренная транзакция
    });

    test('ignores transactions that do not affect wallet', () {
      final transactions = [
        Transaction(
          id: '1',
          type: TransactionType.income,
          amount: 5000,
          date: DateTime.now(),
          affectsWallet: true,
        ),
        Transaction(
          id: '2',
          type: TransactionType.expense,
          amount: 2000,
          date: DateTime.now(),
          affectsWallet: false, // Не влияет на кошелёк
        ),
      ];

      final balance = calculateBalance(transactions);
      expect(balance, equals(5000)); // Только транзакция, влияющая на кошелёк
    });

    test('includes forecast when enabled', () {
      final transactions = [
        Transaction(
          id: '1',
          type: TransactionType.income,
          amount: 5000,
          date: DateTime.now(),
        ),
      ];

      final plannedEvents = [
        PlannedEvent(
          id: '1',
          type: TransactionType.income,
          amount: 2000,
          dateTime: DateTime.now().add(const Duration(days: 5)),
          status: PlannedEventStatus.planned,
        ),
        PlannedEvent(
          id: '2',
          type: TransactionType.expense,
          amount: 1000,
          dateTime: DateTime.now().add(const Duration(days: 10)),
          status: PlannedEventStatus.planned,
        ),
      ];

      final balance = calculateBalance(
        transactions,
        showForecast: true,
        plannedEvents: plannedEvents,
        filter: 'month',
      );

      // 5000 (текущий) + 2000 (доход) - 1000 (расход) = 6000
      expect(balance, equals(6000));
    });

    test('filters transactions by day', () {
      final now = DateTime.now();
      final transactions = [
        Transaction(
          id: '1',
          type: TransactionType.income,
          amount: 5000,
          date: now, // Сегодня
        ),
        Transaction(
          id: '2',
          type: TransactionType.income,
          amount: 3000,
          date: now.subtract(const Duration(days: 1)), // Вчера
        ),
      ];

      final balance = calculateBalance(transactions, filter: 'day');
      expect(balance, equals(5000)); // Только сегодняшняя транзакция
    });

    test('filters transactions by month', () {
      final now = DateTime.now();
      final transactions = [
        Transaction(
          id: '1',
          type: TransactionType.income,
          amount: 5000,
          date: now, // Этот месяц
        ),
        Transaction(
          id: '2',
          type: TransactionType.income,
          amount: 3000,
          date: DateTime(now.year, now.month - 1, 1), // Прошлый месяц
        ),
      ];

      final balance = calculateBalance(transactions, filter: 'month');
      expect(balance, equals(5000)); // Только транзакция этого месяца
    });
  });
}


