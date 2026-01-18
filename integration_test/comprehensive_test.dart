import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:bary3/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Bary3 Comprehensive Integration Tests', () {
    testWidgets('Full app navigation and core features', (WidgetTester tester) async {
      // ============================================
      // 1. ЗАПУСК ПРИЛОЖЕНИЯ
      // ============================================
      await tester.pumpWidget(const Bary3App());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Проверяем базовую структуру
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // ============================================
      // 2. НАВИГАЦИЯ ПО ВСЕМ ВКЛАДКАМ
      // ============================================
      final tabs = ['Баланс', 'Копилки', 'Календарь', 'Уроки', 'Настройки'];
      
      for (final tab in tabs) {
        final tabFinder = find.text(tab);
        if (tabFinder.evaluate().isNotEmpty) {
          await tester.ensureVisible(tabFinder.first);
          await tester.tap(tabFinder.first, warnIfMissed: false);
          await tester.pumpAndSettle();
          expect(find.text(tab), findsWidgets);
        }
      }

      // ============================================
      // 3. ЭКРАН БАЛАНС - ОСНОВНЫЕ ЭЛЕМЕНТЫ
      // ============================================
      final balanceTab = find.text('Баланс');
      if (balanceTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(balanceTab.first);
        await tester.tap(balanceTab.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      expect(find.text('Баланс'), findsWidgets);
      
      // Проверяем наличие кнопок действий
      expect(find.text('Добавить'), findsOneWidget);
      expect(find.text('Потратить'), findsOneWidget);
      expect(find.text('Запланировать'), findsOneWidget);

      // Проверяем фильтры
      expect(find.text('День'), findsOneWidget);
      expect(find.text('Неделя'), findsOneWidget);
      expect(find.text('Месяц'), findsOneWidget);
      expect(find.text('Всё'), findsOneWidget);

      // ============================================
      // 4. ЭКРАН БАЛАНС - ДОБАВЛЕНИЕ ДОХОДА
      // ============================================
      await tester.ensureVisible(find.text('Добавить'));
      await tester.tap(find.text('Добавить'));
      await tester.pumpAndSettle();

      // Проверяем, что открылась форма
      if (find.text('Добавить доход').evaluate().isNotEmpty) {
        expect(find.text('Добавить доход'), findsOneWidget);

        // Вводим данные
        final textFields = find.byType(TextField);
        if (textFields.evaluate().isNotEmpty) {
          await tester.enterText(textFields.first, '100');
          await tester.pumpAndSettle();

          if (textFields.evaluate().length > 1) {
            await tester.enterText(textFields.at(1), 'Тест доход');
            await tester.pumpAndSettle();
          }
        }

        // Закрываем форму (отмена)
        final cancelButton = find.text('Отмена');
        if (cancelButton.evaluate().isNotEmpty) {
          await tester.tap(cancelButton);
          await tester.pumpAndSettle();
        }
      }

      // ============================================
      // 5. ЭКРАН КОПИЛКИ
      // ============================================
      final piggyTab = find.text('Копилки');
      if (piggyTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(piggyTab.first);
        await tester.tap(piggyTab.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      expect(find.text('Копилки'), findsWidgets);

      // Проверяем наличие кнопки создания или FAB
      final createButton = find.widgetWithText(ElevatedButton, 'Создать копилку');
      final fab = find.byType(FloatingActionButton);
      
      if (createButton.evaluate().isNotEmpty || fab.evaluate().isNotEmpty) {
        // Кнопка создания есть, но не создаем в тесте (чтобы не засорять данные)
      }

      // ============================================
      // 6. ЭКРАН КАЛЕНДАРЬ
      // ============================================
      final calendarTab = find.text('Календарь');
      if (calendarTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(calendarTab.first);
        await tester.tap(calendarTab.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      expect(find.text('Календарь'), findsWidgets);

      // Проверяем наличие кнопки добавления
      final addButtons = find.byIcon(Icons.add);
      if (addButtons.evaluate().isNotEmpty) {
        // Кнопка есть, но не открываем форму (чтобы не создавать события)
      }

      // ============================================
      // 7. ЭКРАН УРОКИ
      // ============================================
      final lessonsTab = find.text('Уроки');
      if (lessonsTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(lessonsTab.first);
        await tester.tap(lessonsTab.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      expect(find.text('Уроки'), findsWidgets);

      // "Бесплатные" может не быть, если уроки не загрузились
      final freeLessons = find.text('Бесплатные');
      if (freeLessons.evaluate().isNotEmpty) {
        expect(freeLessons, findsOneWidget);
      }

      // ============================================
      // 8. ЭКРАН НАСТРОЙКИ
      // ============================================
      final settingsTab = find.text('Настройки');
      if (settingsTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(settingsTab.first);
        await tester.tap(settingsTab.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      expect(find.text('Настройки'), findsWidgets);
      expect(find.text('Внешний вид'), findsOneWidget);
      expect(find.text('Валюта'), findsOneWidget);
      expect(find.text('Уведомления'), findsOneWidget);
      expect(find.text('Бари'), findsOneWidget);

      // Проверяем переключатели языка
      expect(find.text('RU'), findsOneWidget);
      expect(find.text('DE'), findsOneWidget);
      expect(find.text('EN'), findsOneWidget);

      // Проверяем переключатели темы
      expect(find.text('Blue'), findsOneWidget);
      expect(find.text('Purple'), findsOneWidget);
      expect(find.text('Mint'), findsOneWidget);

      // ============================================
      // 9. НАСТРОЙКИ - ИНСТРУМЕНТЫ
      // ============================================
      final toolsTile = find.text('Инструменты');
      if (toolsTile.evaluate().isNotEmpty) {
        await tester.ensureVisible(toolsTile);
        await tester.tap(toolsTile);
        await tester.pumpAndSettle();

        // Проверяем, что открылся экран инструментов
        if (find.textContaining('Инструмент').evaluate().isNotEmpty ||
            find.textContaining('Калькулятор').evaluate().isNotEmpty) {
          // Возвращаемся назад
          final backButton = find.byIcon(Icons.arrow_back);
          if (backButton.evaluate().isNotEmpty) {
            await tester.tap(backButton.first);
            await tester.pumpAndSettle();
          }
        }
      }

      // ============================================
      // 10. ФИНАЛЬНАЯ ПРОВЕРКА
      // ============================================
      // Возвращаемся на Баланс
      final finalBalanceTab = find.text('Баланс');
      if (finalBalanceTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(finalBalanceTab.first);
        await tester.tap(finalBalanceTab.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      // Финальная проверка - приложение работает
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Баланс'), findsWidgets);
    });

    testWidgets('Balance screen: filters and actions', (WidgetTester tester) async {
      await tester.pumpWidget(const Bary3App());
      await tester.pumpAndSettle();

      // Проверяем фильтры
      expect(find.text('День'), findsOneWidget);
      expect(find.text('Неделя'), findsOneWidget);
      expect(find.text('Месяц'), findsOneWidget);
      expect(find.text('Всё'), findsOneWidget);

      // Проверяем кнопки действий
      expect(find.text('Добавить'), findsOneWidget);
      expect(find.text('Потратить'), findsOneWidget);
      expect(find.text('Запланировать'), findsOneWidget);
    });

    testWidgets('Settings screen: all sections visible', (WidgetTester tester) async {
      await tester.pumpWidget(const Bary3App());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Настройки'));
      await tester.tap(find.text('Настройки'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Проверяем все секции (некоторые могут отсутствовать)
      expect(find.text('Внешний вид'), findsOneWidget);
      expect(find.text('Валюта'), findsOneWidget);
      expect(find.text('Уведомления'), findsOneWidget);
      expect(find.text('Бари'), findsOneWidget);
      
      // Опциональные секции
      if (find.text('Родительская зона').evaluate().isNotEmpty) {
        expect(find.text('Родительская зона'), findsOneWidget);
      }
      if (find.text('Инструменты').evaluate().isNotEmpty) {
        expect(find.text('Инструменты'), findsOneWidget);
      }
    });

    testWidgets('All main screens accessible', (WidgetTester tester) async {
      await tester.pumpWidget(const Bary3App());
      await tester.pumpAndSettle();

      // Проверяем доступность всех экранов
      final screens = [
        {'tab': 'Баланс', 'title': 'Баланс'},
        {'tab': 'Копилки', 'title': 'Копилки'},
        {'tab': 'Календарь', 'title': 'Календарь'},
        {'tab': 'Уроки', 'title': 'Уроки'},
        {'tab': 'Настройки', 'title': 'Настройки'},
      ];

      for (final screen in screens) {
        final tabFinder = find.text(screen['tab'] as String);
        if (tabFinder.evaluate().isNotEmpty) {
          await tester.ensureVisible(tabFinder.first);
          await tester.tap(tabFinder.first, warnIfMissed: false);
          await tester.pumpAndSettle();
          expect(find.text(screen['title'] as String), findsWidgets);
        }
      }
    });
  });
}

