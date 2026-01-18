import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../models/planned_event.dart';
import '../services/storage_service.dart';

class DailyTask {
  final String id;
  final String title;
  final String description;
  final int rewardXP;
  final bool completed;
  final DateTime? completedAt;

  DailyTask({
    required this.id,
    required this.title,
    required this.description,
    this.rewardXP = 10,
    this.completed = false,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'rewardXP': rewardXP,
        'completed': completed,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory DailyTask.fromJson(Map<String, dynamic> json) => DailyTask(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        rewardXP: json['rewardXP'] as int? ?? 10,
        completed: json['completed'] as bool? ?? false,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
      );

  DailyTask copyWith({
    String? id,
    String? title,
    String? description,
    int? rewardXP,
    bool? completed,
    DateTime? completedAt,
  }) =>
      DailyTask(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        rewardXP: rewardXP ?? this.rewardXP,
        completed: completed ?? this.completed,
        completedAt: completedAt ?? this.completedAt,
      );
}

class DailyTasksService {
  static const String _keyDailyTasks = 'daily_tasks';
  static const String _keyLastResetDate = 'daily_tasks_last_reset';

  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  /// Получить ежедневные задания
  /// 
  /// Если [l10n] передан, использует локализацию для дефолтных заданий.
  /// Если нет, использует русский язык по умолчанию.
  static Future<List<DailyTask>> getDailyTasks([dynamic l10n]) async {
    await _resetIfNeeded();
    
    try {
      final prefs = await _prefs;
      final json = prefs.getString(_keyDailyTasks);
      if (json == null) {
        return _generateDefaultTasks(l10n);
      }
      final List<dynamic> decoded = jsonDecode(json);
      return decoded.map((j) => DailyTask.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error loading daily tasks: $e');
      return _generateDefaultTasks(l10n);
    }
  }

  /// Сохранить ежедневные задания
  static Future<void> saveDailyTasks(List<DailyTask> tasks) async {
    final prefs = await _prefs;
    final json = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_keyDailyTasks, json);
  }

  /// Отметить задание как выполненное
  static Future<void> completeTask(String taskId) async {
    final tasks = await getDailyTasks();
    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index >= 0 && !tasks[index].completed) {
      tasks[index] = tasks[index].copyWith(
        completed: true,
        completedAt: DateTime.now(),
      );
      await saveDailyTasks(tasks);
    }
  }

  /// Проверить и обновить статус заданий
  static Future<List<DailyTask>> checkTasksProgress() async {
    final tasks = await getDailyTasks();
    final transactions = await StorageService.getTransactions();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    bool changed = false;

    for (var i = 0; i < tasks.length; i++) {
      if (tasks[i].completed) continue;

      bool shouldComplete = false;

      switch (tasks[i].id) {
        case 'add_transaction':
          // Проверить, есть ли транзакция сегодня
          shouldComplete = transactions.any((t) {
            final txDate = DateTime(t.date.year, t.date.month, t.date.day);
            return txDate == today;
          });
          break;
        case 'add_piggy_deposit':
          // Проверить, есть ли пополнение копилки сегодня
          shouldComplete = transactions.any((t) {
            final txDate = DateTime(t.date.year, t.date.month, t.date.day);
            return txDate == today && 
                   t.source == TransactionSource.piggyBank &&
                   t.type == TransactionType.expense;
          });
          break;
        case 'plan_event':
          final events = await StorageService.getPlannedEvents();
          shouldComplete = events.any((e) {
            final eventDate = DateTime(e.dateTime.year, e.dateTime.month, e.dateTime.day);
            return eventDate == today || 
                   (e.dateTime.isAfter(now) && e.status == PlannedEventStatus.planned);
          });
          break;
        case 'check_balance':
          // Всегда можно выполнить - просто проверить баланс
          shouldComplete = true;
          break;
      }

      if (shouldComplete && !tasks[i].completed) {
        tasks[i] = tasks[i].copyWith(
          completed: true,
          completedAt: DateTime.now(),
        );
        changed = true;
      }
    }

    if (changed) {
      await saveDailyTasks(tasks);
    }

    return tasks;
  }

  /// Сбросить задания, если наступил новый день
  static Future<void> _resetIfNeeded() async {
    final prefs = await _prefs;
    final lastResetStr = prefs.getString(_keyLastResetDate);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastResetStr != null) {
      final lastReset = DateTime.parse(lastResetStr);
      final lastResetDay = DateTime(lastReset.year, lastReset.month, lastReset.day);
      
      if (lastResetDay == today) {
        return; // Уже сброшено сегодня
      }
    }

    // Сбрасываем задания
    final tasks = _generateDefaultTasks();
    await saveDailyTasks(tasks);
    await prefs.setString(_keyLastResetDate, today.toIso8601String());
  }

  /// Генерировать дефолтные задания
  /// 
  /// Если [l10n] передан, использует локализацию.
  /// Если нет, использует русский язык по умолчанию.
  static List<DailyTask> _generateDefaultTasks([dynamic l10n]) {
    return [
      DailyTask(
        id: 'add_transaction',
        title: l10n?.dailyTask_addTransaction ?? 'Добавить транзакцию',
        description: l10n?.dailyTask_addTransactionDesc ?? 'Создайте доход или расход сегодня',
      ),
      DailyTask(
        id: 'add_piggy_deposit',
        title: l10n?.dailyTask_addPiggyDeposit ?? 'Пополнить копилку',
        description: l10n?.dailyTask_addPiggyDepositDesc ?? 'Добавьте деньги в любую копилку',
        rewardXP: 15,
      ),
      DailyTask(
        id: 'plan_event',
        title: l10n?.dailyTask_planEvent ?? 'Запланировать событие',
        description: l10n?.dailyTask_planEventDesc ?? 'Создайте запланированное событие',
      ),
      DailyTask(
        id: 'check_balance',
        title: l10n?.dailyTask_checkBalance ?? 'Проверить баланс',
        description: l10n?.dailyTask_checkBalanceDesc ?? 'Откройте экран баланса',
        rewardXP: 5,
      ),
    ];
  }
}

