import 'bari_context.dart';
import '../services/storage_service.dart';
import '../models/transaction.dart';
import '../models/planned_event.dart';
import '../models/piggy_bank.dart';
import '../models/player_profile.dart';
import '../models/bari_memory.dart';

class BariContextAdapter {
  static Future<BariContext> build({
    required String currentScreenId,
  }) async {
    final now = DateTime.now();
    
    // Распараллеливаем загрузку данных для ускорения
    final results = await Future.wait([
      StorageService.getTransactions(),
      StorageService.getPiggyBanks(),
      StorageService.getPlannedEvents(),
      StorageService.getPlayerProfile(),
      StorageService.getLessonProgress(),
      StorageService.getCurrencyCode(),
      StorageService.getLanguage(),
      StorageService.getBariMemory(),
    ]);
    
    final transactions = results[0] as List<Transaction>;
    final piggyBanks = results[1] as List<PiggyBank>;
    final plannedEvents = results[2] as List<PlannedEvent>;
    final profile = results[3] as PlayerProfile;
    final lessonProgress = results[4] as List<dynamic>;
    final currencyCode = results[5] as String;
    final locale = results[6] as String;
    final memory = results[7] as BariMemory;
    
    // Вычисляем баланс кошелька (оптимизировано - используем fold вместо цикла)
    final balance = transactions
        .where((t) => t.parentApproved == true && t.affectsWallet == true)
        .fold<int>(
          0,
          (sum, t) => sum + (t.type == TransactionType.income ? t.amount : -t.amount),
        );
    
    // Собираем краткую информацию о копилках (оптимизировано)
    final piggyBanksInfo = List.generate(
      piggyBanks.length,
      (i) {
        final bank = piggyBanks[i];
        return {
          'id': bank.id,
          'name': bank.name,
          'currentAmount': bank.currentAmount,
          'targetAmount': bank.targetAmount,
          'progress': bank.progress,
        };
      },
    );
    
    // Собираем ближайшие события (на 7 дней вперёд) - оптимизировано
    final weekLater = now.add(const Duration(days: 7));
    final upcomingEvents = <Map<String, dynamic>>[];
    for (final e in plannedEvents) {
      if (e.status == PlannedEventStatus.planned &&
          e.dateTime.isAfter(now) &&
          e.dateTime.isBefore(weekLater)) {
        upcomingEvents.add({
          'id': e.id,
          'title': e.name ?? 'Событие',
          'date': e.dateTime.toIso8601String(),
          'amount': e.amount,
          'type': e.type.toString(),
        });
      }
    }
    
    // Собираем последние транзакции (за последние 30 дней, максимум 10) - оптимизировано
    final monthAgo = now.subtract(const Duration(days: 30));
    final recentTransactions = <Transaction>[];
    for (final t in transactions) {
      if (t.date.isAfter(monthAgo) &&
          t.parentApproved == true &&
          t.affectsWallet == true) {
        recentTransactions.add(t);
      }
    }
    recentTransactions.sort((a, b) => b.date.compareTo(a.date));
    
    final recentTransactionsInfo = recentTransactions
        .take(10)
        .map((t) => {
      'id': t.id,
      'date': t.date.toIso8601String(),
      'amount': t.amount,
      'type': t.type.toString(),
      'category': t.category ?? '',
      'note': t.note ?? '',
    }).toList();
    
    // Подсчитываем завершенные уроки (оптимизировано)
    final completedLessons = lessonProgress
        .where((p) => (p as dynamic).completed == true)
        .length;
    
    // Вычисляем примерный возраст на основе уровня
    final estimatedAge = profile.level <= 3
        ? 9
        : profile.level <= 6
            ? 12
            : 15;
    
    // Извлекаем информацию о недавних действиях из BariMemory
    final recentActions = memory.recentActions.map((a) => {
      'type': a.type.toString().split('.').last,
      'timestamp': a.timestamp.toIso8601String(),
      'lessonId': a.lessonId,
      'piggyBankId': a.piggyBankId,
      'transactionId': a.transactionId,
      'payload': _getActionPayload(a.type),
    }).toList();
    
    // Находим последние действия по типам
    final lessonActions = memory.recentActions
        .where((a) => a.type == BariActionType.lessonCompleted)
        .toList();
    final lastLesson = lessonActions.isNotEmpty ? lessonActions.first : null;
    
    final planActions = memory.recentActions
        .where((a) => a.type == BariActionType.planCreated)
        .toList();
    final lastPlan = planActions.isNotEmpty ? planActions.first : null;
    
    final piggyTopUpActions = memory.recentActions
        .where((a) => a.type == BariActionType.income && a.piggyBankId != null)
        .toList();
    final lastPiggyTopUp = piggyTopUpActions.isNotEmpty ? piggyTopUpActions.first : null;
    
    // Извлекаем типы недавно показанных подсказок (из recentTips)
    final recentHintTypes = memory.recentTips
        .where((tip) => tip.contains('hint_type:'))
        .map((tip) => tip.split('hint_type:').last.trim())
        .toList();
    
    return BariContext(
      localeTag: locale,
      currencyCode: currencyCode,
      walletBalanceCents: balance,
      currentScreenId: currentScreenId,
      piggyBanks: piggyBanksInfo,
      calendarEvents: upcomingEvents,
      recentTransactions: recentTransactionsInfo,
      playerLevel: profile.level,
      playerXp: profile.xp,
      lessonsCompleted: completedLessons,
      playerAge: estimatedAge,
      recentActions: recentActions,
      lastLessonCompletedAt: lastLesson?.timestamp,
      lastPlanCreatedAt: lastPlan?.timestamp,
      lastPiggyTopUpAt: lastPiggyTopUp?.timestamp,
      recentHintTypes: recentHintTypes.isNotEmpty ? recentHintTypes : null,
    );
  }
  
  /// Получает payload для действия на основе типа
  static String _getActionPayload(BariActionType type) {
    switch (type) {
      case BariActionType.lessonCompleted:
        return 'lessons';
      case BariActionType.planCreated:
        return 'plan';
      case BariActionType.piggyBankCreated:
        return 'piggy_banks';
      case BariActionType.income:
        return 'earnings_lab';
      case BariActionType.expense:
        return 'balance';
      case BariActionType.planCompleted:
        return 'calendar';
      case BariActionType.piggyBankCompleted:
        return 'piggy_banks';
    }
  }
}

