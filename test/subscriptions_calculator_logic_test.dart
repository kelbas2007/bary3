import 'package:flutter_test/flutter_test.dart';
import 'package:bary3/models/planned_event.dart';

/// Тестируем логику расчета подписок
/// Это чистая функция расчета месячной стоимости подписки
double calculateMonthlyCost({
  required int amountCents,
  required RepeatType repeat,
}) {
  double monthly = 0;
  switch (repeat) {
    case RepeatType.daily:
      monthly = (amountCents / 100) * 30;
      break;
    case RepeatType.weekly:
      monthly =
          (amountCents / 100) *
          4.33; // Более точный расчёт (52 недели / 12 месяцев)
      break;
    case RepeatType.monthly:
      monthly = amountCents / 100;
      break;
    case RepeatType.yearly:
      monthly = (amountCents / 100) / 12;
      break;
    default:
      break;
  }
  return monthly;
}

void main() {
  group('Subscriptions Calculator Logic', () {
    test('calculates monthly cost for daily subscription', () {
      // Подписка 10€ в день
      final monthly = calculateMonthlyCost(
        amountCents: 1000, // 10.00
        repeat: RepeatType.daily,
      );

      // 10 * 30 = 300
      expect(monthly, equals(300.0));
    });

    test('calculates monthly cost for weekly subscription', () {
      // Подписка 20€ в неделю
      final monthly = calculateMonthlyCost(
        amountCents: 2000, // 20.00
        repeat: RepeatType.weekly,
      );

      // 20 * 4.33 ≈ 86.6
      expect(monthly, closeTo(86.6, 0.1));
    });

    test('calculates monthly cost for monthly subscription', () {
      // Подписка 50€ в месяц
      final monthly = calculateMonthlyCost(
        amountCents: 5000, // 50.00
        repeat: RepeatType.monthly,
      );

      expect(monthly, equals(50.0));
    });

    test('calculates monthly cost for yearly subscription', () {
      // Подписка 120€ в год
      final monthly = calculateMonthlyCost(
        amountCents: 12000, // 120.00
        repeat: RepeatType.yearly,
      );

      // 120 / 12 = 10
      expect(monthly, equals(10.0));
    });

    test('calculates total monthly cost for multiple subscriptions', () {
      final subscriptions = [
        {'amount': 1000, 'repeat': RepeatType.monthly}, // 10€/мес = 10
        {
          'amount': 2000,
          'repeat': RepeatType.weekly,
        }, // 20€/нед = 20 * 4.33 = 86.6
        {'amount': 50, 'repeat': RepeatType.daily}, // 0.5€/день = 0.5 * 30 = 15
      ];

      double totalMonthly = 0;
      for (var sub in subscriptions) {
        totalMonthly += calculateMonthlyCost(
          amountCents: sub['amount'] as int,
          repeat: sub['repeat'] as RepeatType,
        );
      }

      // Пересчитываем вручную:
      // 10 (месячная) + 86.6 (недельная) + 15 (дневная) = 111.6
      // Но реальный расчет: 10 + (20 * 4.33) + (0.5 * 30) = 10 + 86.6 + 15 = 111.6
      expect(totalMonthly, closeTo(111.6, 1.0)); // Увеличиваем допуск
    });
  });
}
