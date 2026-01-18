import 'package:flutter_test/flutter_test.dart';

/// Тестируем логику расчета плана копилки
/// Это чистая функция расчета, которую можно протестировать без UI
double? calculatePiggyPlan({
  required double target,
  required double current,
  required String deadline,
  required String period, // 'day', 'week', 'month'
}) {
  final needed = target - current;
  if (needed <= 0) {
    return 0;
  }

  // Парсим срок (например "4 недели" или "2 месяца")
  int totalWeeks = 0;
  if (deadline.contains('недел')) {
    final weeks = int.tryParse(deadline.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    totalWeeks = weeks;
  } else if (deadline.contains('месяц')) {
    final months = int.tryParse(deadline.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    totalWeeks = months * 4;
  }

  if (totalWeeks <= 0) {
    return null;
  }

  // Конвертируем в нужный период
  int totalPeriods = totalWeeks;
  if (period == 'day') {
    totalPeriods = totalWeeks * 7;
  } else if (period == 'month') {
    totalPeriods = (totalWeeks / 4).ceil();
  }

  if (totalPeriods <= 0) {
    return null;
  }

  return needed / totalPeriods;
}

void main() {
  group('Piggy Plan Calculator Logic', () {
    test('calculates weekly contribution correctly', () {
      final result = calculatePiggyPlan(
        target: 500.0,
        current: 100.0,
        deadline: '4 недели',
        period: 'week',
      );

      // Нужно: 500 - 100 = 400
      // За 4 недели: 400 / 4 = 100 в неделю
      expect(result, equals(100.0));
    });

    test('calculates daily contribution correctly', () {
      final result = calculatePiggyPlan(
        target: 500.0,
        current: 100.0,
        deadline: '4 недели',
        period: 'day',
      );

      // Нужно: 500 - 100 = 400
      // За 4 недели = 28 дней: 400 / 28 ≈ 14.29
      expect(result, closeTo(14.29, 0.01));
    });

    test('calculates monthly contribution correctly', () {
      final result = calculatePiggyPlan(
        target: 500.0,
        current: 100.0,
        deadline: '2 месяца',
        period: 'month',
      );

      // Нужно: 500 - 100 = 400
      // За 2 месяца = 8 недель: 400 / 2 = 200 в месяц
      expect(result, equals(200.0));
    });

    test('returns 0 when goal already reached', () {
      final result = calculatePiggyPlan(
        target: 500.0,
        current: 500.0,
        deadline: '4 недели',
        period: 'week',
      );

      expect(result, equals(0.0));
    });

    test('returns 0 when goal exceeded', () {
      final result = calculatePiggyPlan(
        target: 500.0,
        current: 600.0,
        deadline: '4 недели',
        period: 'week',
      );

      expect(result, equals(0.0));
    });

    test('handles different deadline formats', () {
      // Тест с "8 недель"
      final result1 = calculatePiggyPlan(
        target: 800.0,
        current: 0.0,
        deadline: '8 недель',
        period: 'week',
      );
      expect(result1, equals(100.0)); // 800 / 8 = 100

      // Тест с "3 месяца"
      final result2 = calculatePiggyPlan(
        target: 1200.0,
        current: 0.0,
        deadline: '3 месяца',
        period: 'month',
      );
      expect(result2, equals(400.0)); // 1200 / 3 = 400
    });
  });
}


