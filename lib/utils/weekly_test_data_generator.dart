import 'package:flutter/foundation.dart';
import 'package:bary3/models/transaction.dart';
import 'package:bary3/models/planned_event.dart';
import 'package:bary3/models/piggy_bank.dart';
import 'package:bary3/models/lesson.dart';
import 'package:bary3/services/storage_service.dart';

/// Генератор тестовых данных для симуляции недельного использования приложения
/// Создает реалистичные данные: транзакции, события, копилки, прогресс уроков
class WeeklyTestDataGenerator {
  /// Генерирует полный набор данных за неделю
  static Future<void> generateWeeklyData() async {
    final now = DateTime.now();
    
    // Генерируем данные за последние 7 дней
    await _generateTransactions(now);
    await _generatePlannedEvents(now);
    await _generatePiggyBanks();
    await _generateLessonProgress();
    
    debugPrint('✅ Тестовые данные за неделю успешно созданы!');
  }
  
  /// Генерирует транзакции за неделю
  static Future<void> _generateTransactions(DateTime now) async {
    final transactions = await StorageService.getTransactions();
    
    // Категории расходов
    final expenseCategories = [
      'Еда',
      'Транспорт',
      'Развлечения',
      'Игрушки',
      'Книги',
      'Одежда',
    ];
    
    // Категории доходов
    final incomeCategories = [
      'Карманные деньги',
      'Помощь по дому',
      'Подарок',
      'Заработок',
    ];
    
    // Генерируем транзакции за каждый день недели
    for (int day = 0; day < 7; day++) {
      final date = now.subtract(Duration(days: day));
      
      // Доходы (2-3 раза в неделю)
      if (day == 0 || day == 3 || day == 6) {
        final incomeAmount = [500, 1000, 1500, 2000][day % 4] * 100; // в центах
        final category = incomeCategories[day % incomeCategories.length];
        
        transactions.add(Transaction(
          id: 'test_income_$day',
          type: TransactionType.income,
          amount: incomeAmount,
          date: date,
          category: category,
          note: 'Тестовый доход: $category',
          source: TransactionSource.manual,
        ));
      }
      
      // Расходы (каждый день, 1-2 транзакции)
      final expenseCount = day % 2 == 0 ? 1 : 2;
      for (int i = 0; i < expenseCount; i++) {
        final expenseAmount = [200, 300, 500, 800, 1000][(day + i) % 5] * 100;
        final category = expenseCategories[(day + i) % expenseCategories.length];
        
        transactions.add(Transaction(
          id: 'test_expense_${day}_$i',
          type: TransactionType.expense,
          amount: expenseAmount,
          date: date,
          category: category,
          note: 'Тестовый расход: $category',
          source: TransactionSource.manual,
        ));
      }
    }
    
    await StorageService.saveTransactions(transactions);
    debugPrint('📊 Создано ${transactions.length} транзакций за неделю');
  }
  
  /// Генерирует запланированные события
  static Future<void> _generatePlannedEvents(DateTime now) async {
    final events = await StorageService.getPlannedEvents();
    
    // События на будущее (в течение недели)
    final eventTemplates = [
      {'name': 'Покупка новой игры', 'amount': 5000, 'type': TransactionType.expense},
      {'name': 'Подарок на день рождения друга', 'amount': 2000, 'type': TransactionType.expense},
      {'name': 'Карманные деньги', 'amount': 1000, 'type': TransactionType.income},
      {'name': 'Поход в кино', 'amount': 1500, 'type': TransactionType.expense},
    ];
    
    for (int i = 0; i < 4; i++) {
      final daysAhead = i + 1;
      final eventDate = now.add(Duration(days: daysAhead));
      final template = eventTemplates[i];
      
      events.add(PlannedEvent(
        id: 'test_event_$i',
        name: template['name'] as String,
        amount: template['amount'] as int,
        type: template['type'] as TransactionType,
        dateTime: eventDate,
        category: 'Тестовое событие на $daysAhead день',
      ));
    }
    
    await StorageService.savePlannedEvents(events);
    debugPrint('📅 Создано ${events.length} запланированных событий');
  }
  
  /// Генерирует копилки с прогрессом
  static Future<void> _generatePiggyBanks() async {
    final banks = await StorageService.getPiggyBanks();
    
    // Создаем 3 копилки с разным прогрессом
    final piggyTemplates = [
      {'name': 'Новая игра', 'target': 5000, 'current': 2500},
      {'name': 'Велосипед', 'target': 15000, 'current': 8000},
      {'name': 'Подарок маме', 'target': 3000, 'current': 3000}, // Завершенная
    ];
    
    for (int i = 0; i < piggyTemplates.length; i++) {
      final template = piggyTemplates[i];
      final target = (template['target'] as int) * 100;
      final current = (template['current'] as int) * 100;
      
      banks.add(PiggyBank(
        id: 'test_piggy_$i',
        name: template['name'] as String,
        targetAmount: target,
        currentAmount: current,
        createdAt: DateTime.now().subtract(Duration(days: 30 - i * 10)),
      ));
    }
    
    await StorageService.savePiggyBanks(banks);
    debugPrint('🐷 Создано ${banks.length} копилок');
  }
  
  /// Генерирует прогресс по урокам
  static Future<void> _generateLessonProgress() async {
    final progress = await StorageService.getLessonProgress();
    
    // Симулируем прохождение 5 уроков за неделю
    final now = DateTime.now();
    for (int i = 0; i < 5; i++) {
      final lessonId = 'lesson_${i + 1}';
      final completedDate = now.subtract(Duration(days: 6 - i));
      
      // Проверяем, не существует ли уже этот урок
      if (!progress.any((p) => p.lessonId == lessonId)) {
        progress.add(LessonProgress(
          lessonId: lessonId,
          completed: true,
          completedAt: completedDate,
          score: 80 + (i * 5), // Оценка от 80 до 100
          earnedXp: 50 + (i * 10), // XP от 50 до 90
        ));
      }
    }
    
    await StorageService.saveLessonProgress(progress);
    debugPrint('📚 Создан прогресс по ${progress.length} урокам');
  }
  
  /// Очищает все тестовые данные
  static Future<void> clearTestData() async {
    final transactions = await StorageService.getTransactions();
    transactions.removeWhere((t) => t.id.startsWith('test_'));
    await StorageService.saveTransactions(transactions);
    
    final events = await StorageService.getPlannedEvents();
    events.removeWhere((e) => e.id.startsWith('test_'));
    await StorageService.savePlannedEvents(events);
    
    final banks = await StorageService.getPiggyBanks();
    banks.removeWhere((b) => b.id.startsWith('test_'));
    await StorageService.savePiggyBanks(banks);
    
    debugPrint('🗑️ Тестовые данные очищены');
  }
}
