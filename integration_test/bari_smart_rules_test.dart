import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bary3/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Bari Smart Rules Testing', () {
    testWidgets('Gemini Nano should be marked as "coming soon" in settings', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Переходим в настройки
      final settingsTab = find.text('Настройки');
      if (settingsTab.evaluate().isNotEmpty) {
        await tester.tap(settingsTab.first);
        await tester.pumpAndSettle();
      } else {
        // Пробуем найти через иконку или другой способ
        final settingsFinder = find.byIcon(Icons.settings);
        if (settingsFinder.evaluate().isNotEmpty) {
          await tester.tap(settingsFinder.first);
          await tester.pumpAndSettle();
        }
      }

      // Ищем текст про Gemini Nano
      expect(
        find.textContaining('Gemini Nano', findRichText: true),
        findsWidgets,
      );

      // Проверяем, что есть пометка "скоро" или "coming soon"
      final soonText = find.textContaining(RegExp(r'(скоро|coming soon|в разработке)', caseSensitive: false));
      expect(soonText, findsWidgets);
    });

    testWidgets('Bari chat should respond to spending questions', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Ищем кнопку или аватар Бари для открытия чата
      // Обычно это FloatingActionButton или GestureDetector
      final bariButton = find.byType(FloatingActionButton);
      if (bariButton.evaluate().isEmpty) {
        // Пробуем найти через иконку
        final chatIcon = find.byIcon(Icons.chat);
        if (chatIcon.evaluate().isNotEmpty) {
          await tester.tap(chatIcon.first);
          await tester.pumpAndSettle();
        }
      } else {
        await tester.tap(bariButton.first);
        await tester.pumpAndSettle();
      }

      // Ищем поле ввода сообщения
      final messageField = find.byType(TextField);
      if (messageField.evaluate().isNotEmpty) {
        await tester.enterText(messageField.first, 'куда уходят мои деньги');
        await tester.pumpAndSettle();

        // Ищем кнопку отправки
        final sendButton = find.byIcon(Icons.send);
        if (sendButton.evaluate().isNotEmpty) {
          await tester.tap(sendButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 5));

          // Проверяем, что получили ответ
          // Ответ должен содержать анализ трат
          expect(
            find.textContaining(RegExp(r'(трат|расход|доход|копил)', caseSensitive: false)),
            findsWidgets,
          );
        }
      }
    });

    testWidgets('Bari chat should respond to piggy bank questions', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Открываем чат Бари (повторяем логику из предыдущего теста)
      final bariButton = find.byType(FloatingActionButton);
      if (bariButton.evaluate().isEmpty) {
        final chatIcon = find.byIcon(Icons.chat);
        if (chatIcon.evaluate().isNotEmpty) {
          await tester.tap(chatIcon.first);
          await tester.pumpAndSettle();
        }
      } else {
        await tester.tap(bariButton.first);
        await tester.pumpAndSettle();
      }

      final messageField = find.byType(TextField);
      if (messageField.evaluate().isNotEmpty) {
        await tester.enterText(messageField.first, 'мои копилки');
        await tester.pumpAndSettle();

        final sendButton = find.byIcon(Icons.send);
        if (sendButton.evaluate().isNotEmpty) {
          await tester.tap(sendButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 5));

          // Проверяем ответ про копилки
          expect(
            find.textContaining(RegExp(r'(копил|цел|накоп)', caseSensitive: false)),
            findsWidgets,
          );
        }
      }
    });
  });
}
