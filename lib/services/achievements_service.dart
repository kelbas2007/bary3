import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_profile.dart';
import '../models/transaction.dart';
import '../models/piggy_bank.dart';

class AchievementsService {
  static const String _keyAchievements = 'achievements';

  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  /// Получить все достижения
  /// 
  /// Если [l10n] передан, использует локализацию для дефолтных достижений.
  /// Если нет, использует русский язык по умолчанию.
  static Future<List<Achievement>> getAchievements([dynamic l10n]) async {
    try {
      final prefs = await _prefs;
      final json = prefs.getString(_keyAchievements);
      if (json == null) {
        // Инициализируем список достижений
        return _getDefaultAchievements(l10n);
      }
      final List<dynamic> decoded = jsonDecode(json);
      return decoded.map((j) => Achievement.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error loading achievements: $e');
      return _getDefaultAchievements(l10n);
    }
  }

  /// Сохранить достижения
  static Future<void> saveAchievements(List<Achievement> achievements) async {
    final prefs = await _prefs;
    final json = jsonEncode(achievements.map((a) => a.toJson()).toList());
    await prefs.setString(_keyAchievements, json);
  }

  /// Проверить и разблокировать достижения
  /// 
  /// Если [l10n] передан, использует локализацию для дефолтных достижений.
  static Future<List<Achievement>> checkAchievements({
    required PlayerProfile profile,
    List<Transaction>? transactions,
    List<PiggyBank>? piggyBanks,
    dynamic l10n,
  }) async {
    final achievements = await getAchievements(l10n);
    final newlyUnlocked = <Achievement>[];

    for (var achievement in achievements) {
      if (achievement.unlocked) continue;

      bool shouldUnlock = false;

      switch (achievement.id) {
        case 'first_transaction':
          shouldUnlock = transactions != null && transactions.isNotEmpty;
          break;
        case 'first_piggy':
          shouldUnlock = piggyBanks != null && piggyBanks.isNotEmpty;
          break;
        case 'level_5':
          shouldUnlock = profile.level >= 5;
          break;
        case 'level_10':
          shouldUnlock = profile.level >= 10;
          break;
        case 'streak_7':
          shouldUnlock = profile.streakDays >= 7;
          break;
        case 'streak_30':
          shouldUnlock = profile.streakDays >= 30;
          break;
        case 'save_100':
          final totalSaved = piggyBanks?.fold<int>(
                0,
                (sum, bank) => sum + bank.currentAmount,
              ) ??
              0;
          shouldUnlock = totalSaved >= 10000; // 100.00 в минорных единицах
          break;
        case 'save_1000':
          final totalSaved = piggyBanks?.fold<int>(
                0,
                (sum, bank) => sum + bank.currentAmount,
              ) ??
              0;
          shouldUnlock = totalSaved >= 100000; // 1000.00 в минорных единицах
          break;
        case 'transactions_10':
          shouldUnlock = transactions != null && transactions.length >= 10;
          break;
        case 'transactions_100':
          shouldUnlock = transactions != null && transactions.length >= 100;
          break;
        case 'self_control_80':
          shouldUnlock = profile.selfControlScore >= 80;
          break;
        case 'complete_piggy':
          shouldUnlock = piggyBanks?.any((bank) => 
            bank.currentAmount >= bank.targetAmount
          ) ?? false;
          break;
      }

      if (shouldUnlock) {
        final index = achievements.indexWhere((a) => a.id == achievement.id);
        if (index >= 0) {
          achievements[index] = achievement.copyWith(
            unlocked: true,
            unlockedAt: DateTime.now(),
          );
          newlyUnlocked.add(achievements[index]);
        }
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      await saveAchievements(achievements);
    }

    return newlyUnlocked;
  }

  /// Получить дефолтный список достижений
  /// 
  /// Если [l10n] передан, использует локализацию.
  /// Если нет, использует русский язык по умолчанию.
  static List<Achievement> _getDefaultAchievements([dynamic l10n]) {
    return <Achievement>[
      Achievement(
        id: 'first_transaction',
        title: l10n?.achievement_firstTransaction ?? 'Первая операция',
        description: l10n?.achievement_firstTransactionDesc ?? 'Создайте первую транзакцию',
      ),
      Achievement(
        id: 'first_piggy',
        title: l10n?.achievement_firstPiggy ?? 'Первая копилка',
        description: l10n?.achievement_firstPiggyDesc ?? 'Создайте свою первую копилку',
        icon: 'savings',
      ),
      Achievement(
        id: 'level_5',
        title: l10n?.achievement_level5 ?? 'Опытный финансист',
        description: l10n?.achievement_level5Desc ?? 'Достигните 5 уровня',
        icon: 'trending_up',
      ),
      Achievement(
        id: 'level_10',
        title: l10n?.achievement_level10 ?? 'Мастер финансов',
        description: l10n?.achievement_level10Desc ?? 'Достигните 10 уровня',
        icon: 'emoji_events',
      ),
      Achievement(
        id: 'streak_7',
        title: l10n?.achievement_streak7 ?? 'Неделя активности',
        description: l10n?.achievement_streak7Desc ?? 'Активность 7 дней подряд',
        icon: 'local_fire_department',
      ),
      Achievement(
        id: 'streak_30',
        title: l10n?.achievement_streak30 ?? 'Месяц активности',
        description: l10n?.achievement_streak30Desc ?? 'Активность 30 дней подряд',
        icon: 'whatshot',
      ),
      Achievement(
        id: 'save_100',
        title: l10n?.achievement_save100 ?? 'Накопитель',
        description: l10n?.achievement_save100Desc ?? 'Накопите 100 в копилках',
        icon: 'account_balance_wallet',
      ),
      Achievement(
        id: 'save_1000',
        title: l10n?.achievement_save1000 ?? 'Великий накопитель',
        description: l10n?.achievement_save1000Desc ?? 'Накопите 1000 в копилках',
        icon: 'diamond',
      ),
      Achievement(
        id: 'transactions_10',
        title: l10n?.achievement_transactions10 ?? 'Активный пользователь',
        description: l10n?.achievement_transactions10Desc ?? 'Создайте 10 транзакций',
        icon: 'receipt',
      ),
      Achievement(
        id: 'transactions_100',
        title: l10n?.achievement_transactions100 ?? 'Финансовый эксперт',
        description: l10n?.achievement_transactions100Desc ?? 'Создайте 100 транзакций',
        icon: 'bar_chart',
      ),
      Achievement(
        id: 'self_control_80',
        title: l10n?.achievement_selfControl80 ?? 'Самоконтроль',
        description: l10n?.achievement_selfControl80Desc ?? 'Достигните 80 баллов самоконтроля',
        icon: 'self_improvement',
      ),
      Achievement(
        id: 'complete_piggy',
        title: l10n?.achievement_completePiggy ?? 'Цель достигнута',
        description: l10n?.achievement_completePiggyDesc ?? 'Заполните копилку до цели',
        icon: 'check_circle',
      ),
    ];
  }
}

