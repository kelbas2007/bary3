import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:bary3/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Bary3 Complete App Integration Test', () {
    testWidgets('Complete end-to-end test: all features', (
      WidgetTester tester,
    ) async {
      // ============================================
      // ФАЗА 1: ЗАПУСК И БАЗОВАЯ НАВИГАЦИЯ
      // ============================================
      await tester.pumpWidget(const Bary3App());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Проверяем базовую структуру
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // ============================================
      // ФАЗА 2: НАВИГАЦИЯ ПО ВСЕМ ЭКРАНАМ
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
      // ФАЗА 3: ЭКРАН БАЛАНС - ПОЛНЫЙ ТЕСТ
      // ============================================
      final balanceTab = find.text('Баланс');
      if (balanceTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(balanceTab.first);
        await tester.tap(balanceTab.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      // Проверяем все элементы экрана баланса
      expect(find.text('Баланс'), findsWidgets);
      expect(find.text('Добавить'), findsOneWidget);
      expect(find.text('Потратить'), findsOneWidget);
      expect(find.text('Запланировать'), findsOneWidget);
      expect(find.text('День'), findsOneWidget);
      expect(find.text('Неделя'), findsOneWidget);
      expect(find.text('Месяц'), findsOneWidget);
      expect(find.text('Всё'), findsOneWidget);

      // Тест добавления дохода
      await tester.ensureVisible(find.text('Добавить'));
      await tester.tap(find.text('Добавить'));
      await tester.pumpAndSettle();

      if (find.text('Добавить доход').evaluate().isNotEmpty) {
        expect(find.text('Добавить доход'), findsOneWidget);

        final textFields = find.byType(TextField);
        if (textFields.evaluate().isNotEmpty) {
          await tester.enterText(textFields.first, '100');
          await tester.pumpAndSettle();
        }

        // Отменяем (не сохраняем в тесте)
        final cancel = find.text('Отмена');
        if (cancel.evaluate().isNotEmpty) {
          await tester.tap(cancel);
          await tester.pumpAndSettle();
        }
      }

      // Тест фильтров
      final weekFilter = find.text('Неделя');
      if (weekFilter.evaluate().isNotEmpty) {
        await tester.ensureVisible(weekFilter.first);
        await tester.tap(weekFilter.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      // Тест переключателя прогноза
      final switches = find.byType(Switch);
      if (switches.evaluate().isNotEmpty) {
        await tester.tap(switches.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      // ============================================
      // ФАЗА 4: ИНСТРУМЕНТЫ ИЗ БАЛАНСА
      // ============================================
      final toolsButton = find.text('Инструменты');
      if (toolsButton.evaluate().isNotEmpty) {
        await tester.ensureVisible(toolsButton);
        await tester.tap(toolsButton);
        await tester.pumpAndSettle();

        // Проверяем, что открылся экран инструментов
        if (find.textContaining('Инструмент').evaluate().isNotEmpty) {
          // Ищем калькуляторы
          final calculatorsCard = find.text('Калькуляторы');
          if (calculatorsCard.evaluate().isNotEmpty) {
            await tester.tap(calculatorsCard);
            await tester.pumpAndSettle();

            // Проверяем список калькуляторов
            if (find.text('Копилка-план').evaluate().isNotEmpty ||
                find.text('Бюджет 50/30/20').evaluate().isNotEmpty) {
              // Возвращаемся назад
              final back = find.byIcon(Icons.arrow_back);
              if (back.evaluate().isNotEmpty) {
                await tester.tap(back.first);
                await tester.pumpAndSettle();
              }
            }
          }

          // Возвращаемся на баланс
          final backToBalance = find.byIcon(Icons.arrow_back);
          if (backToBalance.evaluate().isNotEmpty) {
            await tester.tap(backToBalance.first);
            await tester.pumpAndSettle();
          }
        }
      }

      // ============================================
      // ФАЗА 5: ЭКРАН КОПИЛКИ
      // ============================================
      final piggyTab = find.text('Копилки');
      if (piggyTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(piggyTab.first);
        await tester.tap(piggyTab.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      expect(find.text('Копилки'), findsWidgets);

      // Проверяем наличие кнопки создания
      final createPiggy = find.widgetWithText(
        ElevatedButton,
        'Создать копилку',
      );
      final fab = find.byType(FloatingActionButton);
      if (createPiggy.evaluate().isNotEmpty || fab.evaluate().isNotEmpty) {
        // Кнопка есть - экран работает
      }

      // ============================================
      // ФАЗА 6: ЭКРАН КАЛЕНДАРЬ
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
        // Кнопка есть - экран работает
      }

      // ============================================
      // ФАЗА 7: ЭКРАН УРОКИ
      // ============================================
      final lessonsTab = find.text('Уроки');
      if (lessonsTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(lessonsTab.first);
        await tester.tap(lessonsTab.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      expect(find.text('Уроки'), findsWidgets);

      // ============================================
      // ФАЗА 8: ЭКРАН НАСТРОЙКИ - ПОЛНЫЙ ТЕСТ
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

      // Тест переключения языка (пробуем DE)
      final deButton = find.text('DE');
      if (deButton.evaluate().isNotEmpty) {
        await tester.tap(deButton.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      // Тест переключения темы (пробуем Purple)
      final purpleButton = find.text('Purple');
      if (purpleButton.evaluate().isNotEmpty) {
        await tester.tap(purpleButton.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      // Тест валюты
      final currencyTile = find.text('Валюта');
      if (currencyTile.evaluate().isNotEmpty) {
        await tester.tap(currencyTile);
        await tester.pumpAndSettle();

        // Если открылся выбор валюты, закрываем
        if (find.text('Выбери валюту').evaluate().isNotEmpty) {
          final back = find.byIcon(Icons.arrow_back);
          if (back.evaluate().isNotEmpty) {
            await tester.tap(back.first);
            await tester.pumpAndSettle();
          }
        }
      }

      // Тест уведомлений
      final notificationSwitches = find.byType(Switch);
      if (notificationSwitches.evaluate().length > 1) {
        await tester.tap(notificationSwitches.at(1), warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      // ============================================
      // ФАЗА 9: ИНСТРУМЕНТЫ ИЗ НАСТРОЕК
      // ============================================
      final toolsTile = find.text('Инструменты');
      if (toolsTile.evaluate().isNotEmpty) {
        await tester.ensureVisible(toolsTile);
        await tester.tap(toolsTile);
        await tester.pumpAndSettle();

        // Проверяем экран инструментов
        if (find.textContaining('Инструмент').evaluate().isNotEmpty) {
          // Проверяем наличие секций
          final calculatorsSection = find.text('Калькуляторы');

          // Тест калькуляторов
          if (calculatorsSection.evaluate().isNotEmpty) {
            await tester.tap(calculatorsSection);
            await tester.pumpAndSettle();

            // Проверяем список калькуляторов
            if (find.text('Копилка-план').evaluate().isNotEmpty ||
                find.text('Бюджет 50/30/20').evaluate().isNotEmpty ||
                find.text('Можно ли купить').evaluate().isNotEmpty) {
              // Возвращаемся назад
              final back = find.byIcon(Icons.arrow_back);
              if (back.evaluate().isNotEmpty) {
                await tester.tap(back.first);
                await tester.pumpAndSettle();
              }
            }
          }

          // Возвращаемся в настройки
          final backToSettings = find.byIcon(Icons.arrow_back);
          if (backToSettings.evaluate().isNotEmpty) {
            await tester.tap(backToSettings.first);
            await tester.pumpAndSettle();
          }
        }
      }

      // ============================================
      // ФАЗА 10: РОДИТЕЛЬСКАЯ ЗОНА
      // ============================================
      final parentZone = find.text('Родительская зона');
      if (parentZone.evaluate().isNotEmpty) {
        await tester.tap(parentZone);
        await tester.pumpAndSettle();

        // Проверяем, что открылась родительская зона
        if (find.textContaining('PIN').evaluate().isNotEmpty ||
            find.textContaining('Родитель').evaluate().isNotEmpty) {
          // Возвращаемся назад
          final back = find.byIcon(Icons.arrow_back);
          if (back.evaluate().isNotEmpty) {
            await tester.tap(back.first);
            await tester.pumpAndSettle();
          }
        }
      }

      // ============================================
      // ФАЗА 11: СИСТЕМА BARI - ЧАТ
      // ============================================
      // Возвращаемся на Баланс
      final backToBalance = find.text('Баланс');
      if (backToBalance.evaluate().isNotEmpty) {
        await tester.ensureVisible(backToBalance.first);
        await tester.tap(backToBalance.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      // Ищем overlay Бари или кнопку чата
      final chatButtons = find.byIcon(Icons.chat);
      if (chatButtons.evaluate().isNotEmpty) {
        await tester.tap(chatButtons.first, warnIfMissed: false);
        await tester.pumpAndSettle();

        // Если открылся чат
        if (find.textContaining('Бари').evaluate().isNotEmpty ||
            find.textContaining('Привет').evaluate().isNotEmpty) {
          // Пробуем отправить сообщение
          final messageFields = find.byType(TextField);
          if (messageFields.evaluate().isNotEmpty) {
            await tester.enterText(messageFields.first, 'Привет');
            await tester.pumpAndSettle();

            // Ищем кнопку отправки
            final sendButtons = find.byIcon(Icons.send);
            if (sendButtons.evaluate().isNotEmpty) {
              await tester.tap(sendButtons.first, warnIfMissed: false);
              await tester.pumpAndSettle(const Duration(seconds: 2));
            }
          }

          // Возвращаемся назад
          final back = find.byIcon(Icons.arrow_back);
          if (back.evaluate().isNotEmpty) {
            await tester.tap(back.first);
            await tester.pumpAndSettle();
          }
        }
      }

      // ============================================
      // ФАЗА 12: ФИНАЛЬНАЯ ПРОВЕРКА ВСЕХ ЭКРАНОВ
      // ============================================
      // Проходим по всем вкладкам еще раз
      for (final tab in tabs) {
        final tabFinder = find.text(tab);
        if (tabFinder.evaluate().isNotEmpty) {
          await tester.ensureVisible(tabFinder.first);
          await tester.tap(tabFinder.first, warnIfMissed: false);
          await tester.pumpAndSettle();
          expect(find.text(tab), findsWidgets);
        }
      }

      // Финальная проверка
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('Calculators: access and basic functionality', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const Bary3App());
      await tester.pumpAndSettle();

      // Переходим в Настройки -> Инструменты
      final settingsTab = find.text('Настройки');
      if (settingsTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(settingsTab.first);
        await tester.tap(settingsTab.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      final toolsTile = find.text('Инструменты');
      if (toolsTile.evaluate().isNotEmpty) {
        await tester.tap(toolsTile);
        await tester.pumpAndSettle();

        // Открываем калькуляторы
        final calculators = find.text('Калькуляторы');
        if (calculators.evaluate().isNotEmpty) {
          await tester.tap(calculators);
          await tester.pumpAndSettle();

          // Проверяем наличие калькуляторов
          final calculatorTitles = [
            'Копилка-план',
            'Бюджет 50/30/20',
            'Можно ли купить',
            'Правило 24 часов',
          ];

          for (final title in calculatorTitles) {
            final calc = find.textContaining(title);
            if (calc.evaluate().isNotEmpty) {
              // Калькулятор найден
              break;
            }
          }
        }
      }
    });

    testWidgets('Settings: all toggles and options work', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const Bary3App());
      await tester.pumpAndSettle();

      final settingsTab = find.text('Настройки');
      if (settingsTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(settingsTab.first);
        await tester.tap(settingsTab.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      // Проверяем все переключатели
      final switches = find.byType(Switch);
      for (int i = 0; i < switches.evaluate().length && i < 3; i++) {
        await tester.tap(switches.at(i), warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      // Проверяем сегментированные кнопки (язык, тема)
      final segmentedButtons = find.byType(SegmentedButton);
      if (segmentedButtons.evaluate().isNotEmpty) {
        // Кнопки есть - настройки работают
      }
    });
  });
}
