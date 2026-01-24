import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bary3/screens/calculators/budget_50_30_20_calculator.dart';

void main() {
  group('Budget503020Calculator', () {
    testWidgets('calculates 50/30/20 correctly for monthly income', (
      WidgetTester tester,
    ) async {
      // Стартуем калькулятор внутри MaterialApp
      await tester.pumpWidget(
        const MaterialApp(home: Budget503020Calculator()),
      );

      // Находим поле ввода дохода по тексту
      final incomeField = find.text('Мой доход за месяц');

      // Ищем TextField внутри AuroraTextField
      final textField = find.byType(TextField);
      expect(textField, findsWidgets, reason: 'Должно быть поле ввода');

      // Вводим доход 1000 (условная валюта) - используем первый TextField
      await tester.enterText(textField.first, '1000');
      await tester.pumpAndSettle();

      // Ожидаем, что калькулятор покажет:
      //  - 50% Нужное  = 500
      //  - 30% Желания = 300
      //  - 20% Накопления = 200
      expect(find.text('50% Нужное'), findsOneWidget);
      expect(find.text('30% Желания'), findsOneWidget);
      expect(find.text('20% Накопления'), findsOneWidget);

      expect(
        find.text('500'),
        findsOneWidget,
        reason: '50% от 1000 должно быть 500',
      );
      expect(
        find.text('300'),
        findsOneWidget,
        reason: '30% от 1000 должно быть 300',
      );
      expect(
        find.text('200'),
        findsOneWidget,
        reason: '20% от 1000 должно быть 200',
      );
    });

    testWidgets('clears results when income is invalid', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Budget503020Calculator()),
      );

      final textField = find.byType(TextField);
      expect(textField, findsWidgets, reason: 'Должно быть поле ввода');

      // Сначала вводим корректное значение
      await tester.enterText(textField.first, '1000');
      await tester.pumpAndSettle();

      // Ждем расчета
      await tester.pump(const Duration(milliseconds: 500));

      // Проверяем результаты (могут быть отформатированы с валютой)
      final hasResults =
          find.text('50% Нужное').evaluate().isNotEmpty ||
          find.text('30% Желания').evaluate().isNotEmpty ||
          find.text('20% Накопления').evaluate().isNotEmpty;
      expect(hasResults, isTrue, reason: 'Должны быть результаты расчета');

      // Затем вводим некорректное значение (пустая строка)
      await tester.enterText(textField.first, '');
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      // Результаты должны исчезнуть
      expect(find.text('500'), findsNothing);
      expect(find.text('300'), findsNothing);
      expect(find.text('200'), findsNothing);
    });
  });
}
