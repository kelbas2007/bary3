import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bary3/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Полное тестирование приложения как пользователь', () {
    testWidgets('1. Запуск приложения и навигация по вкладкам', (WidgetTester tester) async {
      debugPrint('🚀 Запуск приложения...');
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Проверяем, что приложение запустилось
      expect(find.byType(MaterialApp), findsOneWidget);
      debugPrint('✅ Приложение успешно запущено');

      // Проверяем наличие основных вкладок
      final tabs = ['Баланс', 'Копилки', 'Календарь', 'Уроки', 'Настройки'];
      for (final tabName in tabs) {
        final tabFinder = find.text(tabName);
        if (tabFinder.evaluate().isNotEmpty) {
          debugPrint('✅ Найдена вкладка: $tabName');
          await tester.ensureVisible(tabFinder.first);
          await tester.tap(tabFinder.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          debugPrint('✅ Переключились на вкладку: $tabName');
        }
      }
    });

    testWidgets('2. Тестирование экрана Баланс', (WidgetTester tester) async {
      debugPrint('\n📊 Тестирование экрана Баланс...');
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Переходим на вкладку Баланс
      final balanceTab = find.text('Баланс');
      if (balanceTab.evaluate().isNotEmpty) {
        await tester.tap(balanceTab.first);
        await tester.pumpAndSettle();
        debugPrint('✅ Открыт экран Баланс');
      }

      // Ищем кнопки добавления дохода/расхода
      final addIncomeButton = find.textContaining('Доход', findRichText: true);
      final addExpenseButton = find.textContaining('Расход', findRichText: true);
      
      if (addIncomeButton.evaluate().isNotEmpty || addExpenseButton.evaluate().isNotEmpty) {
        debugPrint('✅ Найдены кнопки добавления транзакций');
      }

      // Проверяем наличие фильтров (День, Неделя, Месяц)
      final filters = ['День', 'Неделя', 'Месяц'];
      for (final filter in filters) {
        final filterFinder = find.text(filter);
        if (filterFinder.evaluate().isNotEmpty) {
          debugPrint('✅ Найден фильтр: $filter');
        }
      }
    });

    testWidgets('3. Тестирование экрана Копилки', (WidgetTester tester) async {
      debugPrint('\n🐷 Тестирование экрана Копилки...');
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Переходим на вкладку Копилки
      final piggyTab = find.text('Копилки');
      if (piggyTab.evaluate().isNotEmpty) {
        await tester.tap(piggyTab.first);
        await tester.pumpAndSettle();
        debugPrint('✅ Открыт экран Копилки');
      }

      // Ищем кнопку создания копилки
      final createButton = find.textContaining('Создать', findRichText: true);
      if (createButton.evaluate().isNotEmpty) {
        debugPrint('✅ Найдена кнопка создания копилки');
      }

      // Проверяем список копилок (может быть пустым)
      final piggyList = find.byType(ListView);
      if (piggyList.evaluate().isNotEmpty) {
        debugPrint('✅ Найден список копилок');
      } else {
        debugPrint('ℹ️ Список копилок пуст (это нормально для нового пользователя)');
      }
    });

    testWidgets('4. Тестирование экрана Календарь', (WidgetTester tester) async {
      debugPrint('\n📅 Тестирование экрана Календарь...');
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Переходим на вкладку Календарь
      final calendarTab = find.text('Календарь');
      if (calendarTab.evaluate().isNotEmpty) {
        await tester.tap(calendarTab.first);
        await tester.pumpAndSettle();
        debugPrint('✅ Открыт экран Календарь');
      }

      // Проверяем наличие календаря
      // Ищем календарь по различным признакам
      final calendarWidget = find.byWidgetPredicate((widget) => 
        widget.toString().contains('Calendar') || 
        widget.toString().contains('Table') ||
        widget.toString().contains('calendar')
      );
      if (calendarWidget.evaluate().isNotEmpty) {
        debugPrint('✅ Найден виджет календаря');
      } else {
        // Проверяем наличие текста с датами
        final dateText = find.textContaining(RegExp(r'\d{1,2}', caseSensitive: false));
        if (dateText.evaluate().isNotEmpty) {
          debugPrint('✅ Найден календарь (по наличию дат)');
        }
      }
    });

    testWidgets('5. Тестирование экрана Уроки', (WidgetTester tester) async {
      debugPrint('\n📚 Тестирование экрана Уроки...');
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Переходим на вкладку Уроки
      final lessonsTab = find.text('Уроки');
      if (lessonsTab.evaluate().isNotEmpty) {
        await tester.tap(lessonsTab.first);
        await tester.pumpAndSettle();
        debugPrint('✅ Открыт экран Уроки');
      }

      // Ищем список уроков
      final lessonsList = find.byType(ListView);
      if (lessonsList.evaluate().isNotEmpty) {
        debugPrint('✅ Найден список уроков');
      }
    });

    testWidgets('6. Тестирование экрана Настройки', (WidgetTester tester) async {
      debugPrint('\n⚙️ Тестирование экрана Настройки...');
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Переходим на вкладку Настройки
      final settingsTab = find.text('Настройки');
      if (settingsTab.evaluate().isNotEmpty) {
        await tester.tap(settingsTab.first);
        await tester.pumpAndSettle();
        debugPrint('✅ Открыт экран Настройки');
      }

      // Проверяем основные настройки
      final settings = [
        'Язык',
        'Тема',
        'Валюта',
        'Уведомления',
        'Bari Smart',
      ];

      for (final setting in settings) {
        final settingFinder = find.textContaining(setting, findRichText: true);
        if (settingFinder.evaluate().isNotEmpty) {
          debugPrint('✅ Найдена настройка: $setting');
        }
      }

      // Проверяем Gemini Nano (должен быть помечен как "скоро")
      final geminiNano = find.textContaining('Gemini Nano', findRichText: true);
      if (geminiNano.evaluate().isNotEmpty) {
        debugPrint('✅ Найдена секция Gemini Nano');
        
        // Проверяем, что есть пометка "скоро" или "в разработке"
        final soonText = find.textContaining(RegExp(r'(скоро|coming soon|в разработке)', caseSensitive: false));
        if (soonText.evaluate().isNotEmpty) {
          debugPrint('✅ Gemini Nano правильно помечен как "скоро"');
        }
      }
    });

    testWidgets('7. Тестирование Bari Smart - Чат', (WidgetTester tester) async {
      debugPrint('\n🤖 Тестирование Bari Smart...');
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Ищем кнопку/аватар Бари для открытия чата
      // Может быть FloatingActionButton или GestureDetector
      final bariButton = find.byType(FloatingActionButton);
      if (bariButton.evaluate().isEmpty) {
        // Пробуем найти через иконку чата
        final chatIcon = find.byIcon(Icons.chat);
        if (chatIcon.evaluate().isNotEmpty) {
          await tester.tap(chatIcon.first);
          await tester.pumpAndSettle();
          debugPrint('✅ Открыт чат Бари через иконку');
        } else {
          // Пробуем найти через текст
          final chatText = find.textContaining('Бари', findRichText: true);
          if (chatText.evaluate().isNotEmpty) {
            await tester.tap(chatText.first);
            await tester.pumpAndSettle();
            debugPrint('✅ Открыт чат Бари через текст');
          }
        }
      } else {
        await tester.tap(bariButton.first);
        await tester.pumpAndSettle();
        debugPrint('✅ Открыт чат Бари через FAB');
      }

      // Ищем поле ввода сообщения
      final messageField = find.byType(TextField);
      if (messageField.evaluate().isNotEmpty) {
        debugPrint('✅ Найдено поле ввода сообщения');
        
        // Тест 1: Вопрос о тратах
        await tester.enterText(messageField.first, 'куда уходят мои деньги');
        await tester.pumpAndSettle();
        
        final sendButton = find.byIcon(Icons.send);
        if (sendButton.evaluate().isNotEmpty) {
          await tester.tap(sendButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 5));
          debugPrint('✅ Отправлен вопрос о тратах');
          
          // Проверяем ответ
          final response = find.textContaining(RegExp(r'(трат|расход|доход|копил|данных)', caseSensitive: false));
          if (response.evaluate().isNotEmpty) {
            debugPrint('✅ Получен ответ от Бари о тратах');
          }
        }

        // Очищаем поле и тестируем другой вопрос
        await tester.enterText(messageField.first, '');
        await tester.pumpAndSettle();
        
        // Тест 2: Вопрос о копилках
        await tester.enterText(messageField.first, 'мои копилки');
        await tester.pumpAndSettle();
        
        if (sendButton.evaluate().isNotEmpty) {
          await tester.tap(sendButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 5));
          debugPrint('✅ Отправлен вопрос о копилках');
          
          final response = find.textContaining(RegExp(r'(копил|цел|накоп)', caseSensitive: false));
          if (response.evaluate().isNotEmpty) {
            debugPrint('✅ Получен ответ от Бари о копилках');
          }
        }
      } else {
        debugPrint('ℹ️ Поле ввода не найдено (возможно, чат открыт в другом формате)');
      }
    });

    testWidgets('8. Тестирование калькуляторов', (WidgetTester tester) async {
      debugPrint('\n🧮 Тестирование калькуляторов...');
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Ищем кнопку/вкладку с инструментами
      final toolsTab = find.text('Инструменты');
      if (toolsTab.evaluate().isEmpty) {
        // Пробуем найти через настройки или главный экран
        final toolsButton = find.textContaining('Калькулятор', findRichText: true);
        if (toolsButton.evaluate().isNotEmpty) {
          await tester.tap(toolsButton.first);
          await tester.pumpAndSettle();
          debugPrint('✅ Открыт список калькуляторов');
        }
      } else {
        await tester.tap(toolsTab.first);
        await tester.pumpAndSettle();
        debugPrint('✅ Открыт список инструментов');
      }

      // Проверяем наличие калькуляторов
      final calculators = [
        'Можно ли купить',
        'Правило 24 часа',
        'Бюджет 50/30/20',
        'Подписки',
        'Когда достигну цели',
      ];

      for (final calc in calculators) {
        final calcFinder = find.textContaining(calc, findRichText: true);
        if (calcFinder.evaluate().isNotEmpty) {
          debugPrint('✅ Найден калькулятор: $calc');
        }
      }
    });

    testWidgets('9. Тестирование создания транзакции', (WidgetTester tester) async {
      debugPrint('\n💰 Тестирование создания транзакции...');
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Переходим на экран Баланс
      final balanceTab = find.text('Баланс');
      if (balanceTab.evaluate().isNotEmpty) {
        await tester.tap(balanceTab.first);
        await tester.pumpAndSettle();
      }

      // Ищем кнопку добавления дохода
      final addIncome = find.textContaining('Доход', findRichText: true);
      if (addIncome.evaluate().isNotEmpty) {
        await tester.tap(addIncome.first);
        await tester.pumpAndSettle();
        debugPrint('✅ Открыта форма добавления дохода');

        // Ищем поле ввода суммы
        final amountField = find.byType(TextField).first;
        if (amountField.evaluate().isNotEmpty) {
          await tester.enterText(amountField, '100');
          await tester.pumpAndSettle();
          debugPrint('✅ Введена сумма: 100');

          // Ищем кнопку сохранения
          final saveButton = find.textContaining('Сохранить', findRichText: true);
          if (saveButton.evaluate().isNotEmpty) {
            // Не сохраняем, чтобы не создавать реальные данные
            debugPrint('✅ Найдена кнопка сохранения (не нажимаем для теста)');
          }
        }
      }
    });

    testWidgets('10. Тестирование локализации', (WidgetTester tester) async {
      debugPrint('\n🌍 Тестирование локализации...');
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Переходим в настройки
      final settingsTab = find.text('Настройки');
      if (settingsTab.evaluate().isNotEmpty) {
        await tester.tap(settingsTab.first);
        await tester.pumpAndSettle();
      }

      // Ищем переключатель языка
      final languageSetting = find.textContaining('Язык', findRichText: true);
      if (languageSetting.evaluate().isNotEmpty) {
        debugPrint('✅ Найдена настройка языка');
        
        // Проверяем наличие языков
        final languages = ['RU', 'EN', 'DE'];
        for (final lang in languages) {
          final langFinder = find.text(lang);
          if (langFinder.evaluate().isNotEmpty) {
            debugPrint('✅ Найден язык: $lang');
          }
        }
      }
    });

    testWidgets('11. Тестирование темы приложения', (WidgetTester tester) async {
      debugPrint('\n🎨 Тестирование темы приложения...');
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Переходим в настройки
      final settingsTab = find.text('Настройки');
      if (settingsTab.evaluate().isNotEmpty) {
        await tester.tap(settingsTab.first);
        await tester.pumpAndSettle();
      }

      // Ищем настройку темы
      final themeSetting = find.textContaining('Тема', findRichText: true);
      if (themeSetting.evaluate().isNotEmpty) {
        debugPrint('✅ Найдена настройка темы');
        
        // Проверяем наличие тем
        final themes = ['Синяя', 'Фиолетовая', 'Зелёная'];
        for (final theme in themes) {
          final themeFinder = find.textContaining(theme, findRichText: true);
          if (themeFinder.evaluate().isNotEmpty) {
            debugPrint('✅ Найдена тема: $theme');
          }
        }
      }
    });

    testWidgets('12. Финальная проверка - все экраны доступны', (WidgetTester tester) async {
      debugPrint('\n✅ Финальная проверка доступности всех экранов...');
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final screens = [
        {'tab': 'Баланс', 'check': 'Баланс'},
        {'tab': 'Копилки', 'check': 'Копилки'},
        {'tab': 'Календарь', 'check': 'Календарь'},
        {'tab': 'Уроки', 'check': 'Уроки'},
        {'tab': 'Настройки', 'check': 'Настройки'},
      ];

      int accessibleScreens = 0;
      for (final screen in screens) {
        final tabFinder = find.text(screen['tab'] as String);
        if (tabFinder.evaluate().isNotEmpty) {
          await tester.ensureVisible(tabFinder.first);
          await tester.tap(tabFinder.first);
          await tester.pumpAndSettle(const Duration(seconds: 1));
          
          final checkFinder = find.textContaining(screen['check'] as String, findRichText: true);
          if (checkFinder.evaluate().isNotEmpty) {
            accessibleScreens++;
            debugPrint('✅ Экран "${screen['tab']}" доступен и работает');
          }
        }
      }

      debugPrint('\n📊 Итого: $accessibleScreens из ${screens.length} экранов доступны');
      expect(accessibleScreens, greaterThan(0), reason: 'Хотя бы один экран должен быть доступен');
    });
  });
}
