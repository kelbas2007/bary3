import 'package:flutter_test/flutter_test.dart';
import 'package:bary3/models/piggy_bank.dart';

void main() {
  group('Piggy Bank Logic', () {
    test('calculates progress correctly', () {
      final bank = PiggyBank(
        id: '1',
        name: 'Test',
        targetAmount: 10000, // 100.00
        currentAmount: 5000, // 50.00
        createdAt: DateTime.now(),
      );

      expect(bank.progress, equals(0.5)); // 50%
    });

    test('progress is 0 when target is 0', () {
      final bank = PiggyBank(
        id: '1',
        name: 'Test',
        targetAmount: 0,
        currentAmount: 5000,
        createdAt: DateTime.now(),
      );

      expect(bank.progress, equals(0.0));
    });

    test('isCompleted returns true when goal reached', () {
      final bank = PiggyBank(
        id: '1',
        name: 'Test',
        targetAmount: 10000,
        currentAmount: 10000, // Достигнута цель
        createdAt: DateTime.now(),
      );

      expect(bank.isCompleted, isTrue);
    });

    test('isCompleted returns true when goal exceeded', () {
      final bank = PiggyBank(
        id: '1',
        name: 'Test',
        targetAmount: 10000,
        currentAmount: 15000, // Превышена цель
        createdAt: DateTime.now(),
      );

      expect(bank.isCompleted, isTrue);
    });

    test('isCompleted returns false when goal not reached', () {
      final bank = PiggyBank(
        id: '1',
        name: 'Test',
        targetAmount: 10000,
        currentAmount: 5000, // Не достигнута цель
        createdAt: DateTime.now(),
      );

      expect(bank.isCompleted, isFalse);
    });

    test('copyWith updates fields correctly', () {
      final original = PiggyBank(
        id: '1',
        name: 'Original',
        targetAmount: 10000,
        currentAmount: 5000,
        createdAt: DateTime.now(),
      );

      final updated = original.copyWith(
        currentAmount: 7500,
        name: 'Updated',
      );

      expect(updated.id, equals('1'));
      expect(updated.name, equals('Updated'));
      expect(updated.targetAmount, equals(10000));
      expect(updated.currentAmount, equals(7500));
      expect(updated.progress, equals(0.75));
    });

    test('calculates remaining amount correctly', () {
      final bank = PiggyBank(
        id: '1',
        name: 'Test',
        targetAmount: 10000,
        currentAmount: 3000,
        createdAt: DateTime.now(),
      );

      final remaining = bank.targetAmount - bank.currentAmount;
      expect(remaining, equals(7000)); // 70.00 осталось
    });
  });
}


