import 'package:flutter_test/flutter_test.dart';
import 'package:bary3/bari_smart/bari_smart.dart';
import 'package:bary3/bari_smart/bari_context.dart';
import 'package:bary3/bari_smart/providers/spending_rules_provider.dart';
import 'package:bary3/bari_smart/providers/goal_advisor_provider.dart';

void main() {
  group('SpendingRulesProvider Tests', () {
    test('should respond to spending-related questions', () async {
      final provider = SpendingRulesProvider();
      
      final ctx = BariContext(
        localeTag: 'ru',
        currencyCode: 'EUR',
        walletBalanceCents: 10000,
        recentTransactions: [
          {
            'date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
            'amount': 5000,
            'type': 'TransactionType.income',
            'category': 'pocketMoney',
          },
          {
            'date': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
            'amount': 3000,
            'type': 'TransactionType.expense',
            'category': 'games',
          },
        ],
      );
      
      // Тест на вопрос о тратах
      final response = await provider.tryRespond('куда уходят мои деньги', ctx);
      
      expect(response, isNotNull);
      expect(response!.meaning, isNotEmpty);
      expect(response.advice, isNotEmpty);
      expect(response.confidence, greaterThan(0.7));
    });
    
    test('should return null for non-spending questions', () async {
      final provider = SpendingRulesProvider();
      
      final ctx = BariContext(
        localeTag: 'ru',
        currencyCode: 'EUR',
        walletBalanceCents: 10000,
      );
      
      final response = await provider.tryRespond('что такое инфляция', ctx);
      
      expect(response, isNull);
    });
    
    test('should handle no data case', () async {
      final provider = SpendingRulesProvider();
      
      final ctx = BariContext(
        localeTag: 'ru',
        currencyCode: 'EUR',
        walletBalanceCents: 10000,
        recentTransactions: [],
      );
      
      final response = await provider.tryRespond('куда уходят деньги', ctx);
      
      expect(response, isNotNull);
      expect(response!.meaning.toLowerCase(), contains('мало данных'));
    });
  });
  
  group('GoalAdvisorProvider Enhanced Tests', () {
    test('should detect deadline issues', () async {
      final provider = GoalAdvisorProvider();
      
      final now = DateTime.now();
      final ctx = BariContext(
        localeTag: 'ru',
        currencyCode: 'EUR',
        walletBalanceCents: 10000,
        piggyBanks: [
          {
            'name': 'Велосипед',
            'currentAmount': 10000,
            'targetAmount': 50000,
            'targetDate': now.add(const Duration(days: 10)).toIso8601String(),
          },
        ],
      );
      
      final response = await provider.tryRespond('мои копилки', ctx);
      
      expect(response, isNotNull);
      // Проверяем, что есть предупреждение о дедлайне
      expect(
        response!.advice.toLowerCase(),
        anyOf(
          contains('дедлайн'),
          contains('осталось'),
          contains('увеличить'),
        ),
      );
    });
  });
  
  group('BariContext Helper Methods', () {
    test('getIncomeLastDays should calculate correctly', () {
      final now = DateTime.now();
      final ctx = BariContext(
        localeTag: 'ru',
        currencyCode: 'EUR',
        walletBalanceCents: 10000,
        recentTransactions: [
          {
            'date': now.subtract(const Duration(days: 5)).toIso8601String(),
            'amount': 5000,
            'type': 'TransactionType.income',
          },
          {
            'date': now.subtract(const Duration(days: 20)).toIso8601String(),
            'amount': 3000,
            'type': 'TransactionType.income',
          },
          {
            'date': now.subtract(const Duration(days: 40)).toIso8601String(),
            'amount': 2000,
            'type': 'TransactionType.income',
          },
        ],
      );
      
      final income30 = ctx.getIncomeLastDays(30);
      expect(income30, equals(8000)); // 5000 + 3000, без 2000 (40 дней назад)
    });
    
    test('getExpensesLastDays should calculate correctly', () {
      final now = DateTime.now();
      final ctx = BariContext(
        localeTag: 'ru',
        currencyCode: 'EUR',
        walletBalanceCents: 10000,
        recentTransactions: [
          {
            'date': now.subtract(const Duration(days: 3)).toIso8601String(),
            'amount': 2000,
            'type': 'TransactionType.expense',
          },
          {
            'date': now.subtract(const Duration(days: 15)).toIso8601String(),
            'amount': 1500,
            'type': 'TransactionType.expense',
          },
          {
            'date': now.subtract(const Duration(days: 35)).toIso8601String(),
            'amount': 1000,
            'type': 'TransactionType.expense',
          },
        ],
      );
      
      final expenses30 = ctx.getExpensesLastDays(30);
      expect(expenses30, equals(3500)); // 2000 + 1500, без 1000 (35 дней назад)
    });
  });
}
