import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../models/piggy_bank.dart';
import '../models/planned_event.dart';
import '../models/lesson.dart';
import '../models/player_profile.dart';
import '../models/bari_memory.dart';
import '../models/custom_task.dart';
import '../models/note.dart';
import '../models/calendar_sync_config.dart';

class StorageService {
  static const String _keyTransactions = 'transactions';
  static const String _keyPiggyBanks = 'piggy_banks';
  static const String _keyPlannedEvents = 'planned_events';
  static const String _keyLessons = 'lessons';
  static const String _keyLessonProgress = 'lesson_progress';
  static const String _keyPlayerProfile = 'player_profile';
  static const String _keyAchievements = 'achievements';
  static const String _keyBariMemory = 'bari_memory';
  static const String _keyParentPin = 'parent_pin';
  static const String _keyParentPinSalt = 'parent_pin_salt';
  // Соль для хеширования PIN (генерируется один раз)
  static const String _keyCurrencyCode = 'currency_code';
  static const String _keyLanguage = 'language';
  static const String _keyTheme = 'theme';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyCustomTasks = 'custom_tasks';
  static const String _keyEarningsStreak = 'earnings_streak';
  static const String _keyLastStreakDate = 'last_streak_date';
  static const String _keyUxDetailLevel =
      'ux_detail_level'; // 'simple' or 'pro'
  // Bari settings
  static const String _keyBariMode = 'bari_mode'; // 'offline' or 'online'
  static const String _keyBariShowSources = 'bari_show_sources';
  static const String _keyBariAllowOnlineReference =
      'bari_allow_online_reference';
  // Notes and Calendar Sync
  static const String _keyNotes = 'notes';
  static const String _keyCalendarSyncConfig = 'calendar_sync_config';

  /// Версия списка транзакций.
  ///
  /// Увеличивается каждый раз, когда транзакции меняются.
  /// Можно использовать, чтобы экраны (например, Баланс) автоматически
  /// обновлялись при появлении новых операций.
  static final ValueNotifier<int> transactionsVersion = ValueNotifier<int>(0);
  static final ValueNotifier<int> piggyBanksVersion = ValueNotifier<int>(0);
  static final ValueNotifier<int> plannedEventsVersion = ValueNotifier<int>(0);
  static final ValueNotifier<int> playerProfileVersion = ValueNotifier<int>(0);
  static final ValueNotifier<int> notesVersion = ValueNotifier<int>(0);

  // Кэш в памяти для оптимизации производительности
  static List<Transaction>? _transactionsCache;
  static List<PiggyBank>? _piggyBanksCache;
  static List<PlannedEvent>? _plannedEventsCache;
  static PlayerProfile? _profileCache;
  static List<Note>? _notesCache;
  static CalendarSyncConfig? _calendarSyncConfigCache;
  static DateTime? _transactionsCacheAt;
  static DateTime? _piggyBanksCacheAt;
  static DateTime? _plannedEventsCacheAt;
  static DateTime? _profileCacheAt;
  static DateTime? _notesCacheAt;
  static DateTime? _calendarSyncConfigCacheAt;
  static const Duration _cacheTTL = Duration(seconds: 5);

  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  /// Инвалидирует весь кэш
  static void invalidateCache() {
    _transactionsCache = null;
    _piggyBanksCache = null;
    _plannedEventsCache = null;
    _profileCache = null;
    _notesCache = null;
    _calendarSyncConfigCache = null;
    _transactionsCacheAt = null;
    _piggyBanksCacheAt = null;
    _plannedEventsCacheAt = null;
    _profileCacheAt = null;
    _notesCacheAt = null;
    _calendarSyncConfigCacheAt = null;
  }

  // Transactions
  static Future<List<Transaction>> getTransactions({
    bool forceRefresh = false,
  }) async {
    final now = DateTime.now();

    // Возвращаем кэш, если он свежий
    if (!forceRefresh &&
        _transactionsCache != null &&
        _transactionsCacheAt != null &&
        now.difference(_transactionsCacheAt!) < _cacheTTL) {
      return _transactionsCache!;
    }

    try {
      final prefs = await _prefs;
      final json = prefs.getString(_keyTransactions);
      if (json == null) {
        _transactionsCache = [];
        _transactionsCacheAt = now;
        return [];
      }
      final List<dynamic> decoded = jsonDecode(json);
      _transactionsCache = decoded
          .map((j) => Transaction.fromJson(j as Map<String, dynamic>))
          .toList();
      _transactionsCacheAt = now;
      return _transactionsCache!;
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      return _transactionsCache ?? [];
    }
  }

  static Future<void> saveTransactions(List<Transaction> transactions) async {
    final prefs = await _prefs;
    final json = jsonEncode(transactions.map((t) => t.toJson()).toList());
    await prefs.setString(_keyTransactions, json);

    // Обновляем кэш
    _transactionsCache = transactions;
    _transactionsCacheAt = DateTime.now();

    // Уведомляем слушателей, что список транзакций изменился
    transactionsVersion.value++;
  }

  static Future<void> addTransaction(Transaction transaction) async {
    final transactions = await getTransactions();
    transactions.add(transaction);
    await saveTransactions(transactions);
  }

  // Piggy Banks
  static Future<List<PiggyBank>> getPiggyBanks({
    bool forceRefresh = false,
  }) async {
    final now = DateTime.now();

    // Возвращаем кэш, если он свежий
    if (!forceRefresh &&
        _piggyBanksCache != null &&
        _piggyBanksCacheAt != null &&
        now.difference(_piggyBanksCacheAt!) < _cacheTTL) {
      return _piggyBanksCache!;
    }

    try {
      final prefs = await _prefs;
      final json = prefs.getString(_keyPiggyBanks);
      if (json == null) {
        _piggyBanksCache = [];
        _piggyBanksCacheAt = now;
        return [];
      }
      final List<dynamic> decoded = jsonDecode(json);
      _piggyBanksCache = decoded
          .map((j) => PiggyBank.fromJson(j as Map<String, dynamic>))
          .toList();
      _piggyBanksCacheAt = now;
      return _piggyBanksCache!;
    } catch (e) {
      debugPrint('Error loading piggy banks: $e');
      return _piggyBanksCache ?? [];
    }
  }

  static Future<void> savePiggyBanks(List<PiggyBank> piggyBanks) async {
    final prefs = await _prefs;
    final json = jsonEncode(piggyBanks.map((p) => p.toJson()).toList());
    await prefs.setString(_keyPiggyBanks, json);

    // Обновляем кэш
    _piggyBanksCache = piggyBanks;
    _piggyBanksCacheAt = DateTime.now();
    piggyBanksVersion.value++;
  }

  // Planned Events
  static Future<List<PlannedEvent>> getPlannedEvents({
    bool forceRefresh = false,
  }) async {
    final now = DateTime.now();

    // Возвращаем кэш, если он свежий
    if (!forceRefresh &&
        _plannedEventsCache != null &&
        _plannedEventsCacheAt != null &&
        now.difference(_plannedEventsCacheAt!) < _cacheTTL) {
      return _plannedEventsCache!;
    }

    try {
      final prefs = await _prefs;
      final json = prefs.getString(_keyPlannedEvents);
      if (json == null) {
        _plannedEventsCache = [];
        _plannedEventsCacheAt = now;
        return [];
      }
      final List<dynamic> decoded = jsonDecode(json);
      _plannedEventsCache = decoded
          .map((j) => PlannedEvent.fromJson(j as Map<String, dynamic>))
          .toList();
      _plannedEventsCacheAt = now;
      return _plannedEventsCache!;
    } catch (e) {
      debugPrint('Error loading planned events: $e');
      return _plannedEventsCache ?? [];
    }
  }

  static Future<void> savePlannedEvents(List<PlannedEvent> events) async {
    final prefs = await _prefs;
    final json = jsonEncode(events.map((e) => e.toJson()).toList());
    await prefs.setString(_keyPlannedEvents, json);

    // Обновляем кэш
    _plannedEventsCache = events;
    _plannedEventsCacheAt = DateTime.now();
    plannedEventsVersion.value++;
  }

  // Lessons
  static Future<List<Lesson>> getLessons() async {
    try {
      final prefs = await _prefs;
      final json = prefs.getString(_keyLessons);
      if (json == null) return [];
      final List<dynamic> decoded = jsonDecode(json);
      return decoded
          .map((j) => Lesson.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading lessons: $e');
      return [];
    }
  }

  static Future<void> saveLessons(List<Lesson> lessons) async {
    final prefs = await _prefs;
    final json = jsonEncode(lessons.map((l) => l.toJson()).toList());
    await prefs.setString(_keyLessons, json);
  }

  // Lesson Progress
  static Future<List<LessonProgress>> getLessonProgress() async {
    try {
      final prefs = await _prefs;
      final json = prefs.getString(_keyLessonProgress);
      if (json == null) return [];
      final List<dynamic> decoded = jsonDecode(json);
      return decoded
          .map((j) => LessonProgress.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading lesson progress: $e');
      return [];
    }
  }

  static Future<void> saveLessonProgress(List<LessonProgress> progress) async {
    final prefs = await _prefs;
    final json = jsonEncode(progress.map((p) => p.toJson()).toList());
    await prefs.setString(_keyLessonProgress, json);
  }

  // Player Profile
  static Future<PlayerProfile> getPlayerProfile({
    bool forceRefresh = false,
  }) async {
    final now = DateTime.now();

    // Возвращаем кэш, если он свежий
    if (!forceRefresh &&
        _profileCache != null &&
        _profileCacheAt != null &&
        now.difference(_profileCacheAt!) < _cacheTTL) {
      return _profileCache!;
    }

    try {
      final prefs = await _prefs;
      final json = prefs.getString(_keyPlayerProfile);
      if (json == null) {
        _profileCache = PlayerProfile();
        _profileCacheAt = now;
        return _profileCache!;
      }
      _profileCache = PlayerProfile.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );
      _profileCacheAt = now;
      return _profileCache!;
    } catch (e) {
      debugPrint('Error loading player profile: $e');
      return _profileCache ?? PlayerProfile();
    }
  }

  static Future<void> savePlayerProfile(PlayerProfile profile) async {
    final prefs = await _prefs;
    final json = jsonEncode(profile.toJson());
    await prefs.setString(_keyPlayerProfile, json);

    // Обновляем кэш
    _profileCache = profile;
    _profileCacheAt = DateTime.now();
    playerProfileVersion.value++;
  }

  // Achievements
  static Future<List<Achievement>> getAchievements() async {
    try {
      final prefs = await _prefs;
      final json = prefs.getString(_keyAchievements);
      if (json == null) return [];
      final List<dynamic> decoded = jsonDecode(json);
      return decoded
          .map((j) => Achievement.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading achievements: $e');
      return [];
    }
  }

  static Future<void> saveAchievements(List<Achievement> achievements) async {
    final prefs = await _prefs;
    final json = jsonEncode(achievements.map((a) => a.toJson()).toList());
    await prefs.setString(_keyAchievements, json);
  }

  // Bari Memory
  static Future<BariMemory> getBariMemory() async {
    try {
      final prefs = await _prefs;
      final json = prefs.getString(_keyBariMemory);
      if (json == null) return BariMemory();
      return BariMemory.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error loading bari memory: $e');
      return BariMemory();
    }
  }

  static Future<void> saveBariMemory(BariMemory memory) async {
    final prefs = await _prefs;
    final json = jsonEncode(memory.toJson());
    await prefs.setString(_keyBariMemory, json);
  }

  // Settings
  // Получить соль для PIN (создаёт если нет)
  static Future<String> _getPinSalt() async {
    final prefs = await _prefs;
    String? salt = prefs.getString(_keyParentPinSalt);
    if (salt == null) {
      // Генерируем случайную соль
      final random =
          DateTime.now().millisecondsSinceEpoch.toString() +
          DateTime.now().microsecondsSinceEpoch.toString();
      salt = sha256.convert(utf8.encode(random)).toString();
      await prefs.setString(_keyParentPinSalt, salt);
    }
    return salt;
  }

  // Хешировать PIN с солью
  static String _hashPin(String pin, String salt) {
    final bytes = utf8.encode(pin + salt);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Проверить PIN
  static Future<bool> verifyParentPin(String pin) async {
    try {
      final prefs = await _prefs;
      final storedHash = prefs.getString(_keyParentPin);
      if (storedHash == null) return false;

      final salt = await _getPinSalt();
      final inputHash = _hashPin(pin, salt);
      return storedHash == inputHash;
    } catch (e) {
      debugPrint('Error verifying PIN: $e');
      return false;
    }
  }

  // Установить PIN (сохраняет хеш)
  static Future<void> setParentPin(String pin) async {
    try {
      final prefs = await _prefs;
      final salt = await _getPinSalt();
      final hash = _hashPin(pin, salt);
      await prefs.setString(_keyParentPin, hash);
    } catch (e) {
      debugPrint('Error setting PIN: $e');
      rethrow;
    }
  }

  // Проверить, установлен ли PIN
  static Future<bool> hasParentPin() async {
    try {
      final prefs = await _prefs;
      return prefs.getString(_keyParentPin) != null;
    } catch (e) {
      debugPrint('Error checking PIN: $e');
      return false;
    }
  }

  // Currency
  static Future<String> getCurrencyCode() async {
    final prefs = await _prefs;
    return prefs.getString(_keyCurrencyCode) ?? 'EUR';
  }

  static Future<void> setCurrencyCode(String code) async {
    final prefs = await _prefs;
    await prefs.setString(_keyCurrencyCode, code);
  }

  static Future<String> getLanguage() async {
    final prefs = await _prefs;
    return prefs.getString(_keyLanguage) ?? 'ru';
  }

  static Future<void> setLanguage(String lang) async {
    final prefs = await _prefs;
    await prefs.setString(_keyLanguage, lang);
  }

  static Future<String> getTheme() async {
    final prefs = await _prefs;
    return prefs.getString(_keyTheme) ?? 'blue';
  }

  static Future<void> setTheme(String theme) async {
    final prefs = await _prefs;
    await prefs.setString(_keyTheme, theme);
  }

  static Future<bool> getNotificationsEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyNotificationsEnabled) ?? true;
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyNotificationsEnabled, enabled);
  }

  // UX: уровень подробности объяснений
  static Future<String> getUxDetailLevel() async {
    final prefs = await _prefs;
    return prefs.getString(_keyUxDetailLevel) ?? 'simple';
  }

  static Future<void> setUxDetailLevel(String level) async {
    final prefs = await _prefs;
    await prefs.setString(_keyUxDetailLevel, level);
  }

  // Export/Import
  static Future<Map<String, dynamic>> exportData() async {
    return {
      'transactions': (await getTransactions()).map((t) => t.toJson()).toList(),
      'piggyBanks': (await getPiggyBanks()).map((p) => p.toJson()).toList(),
      'plannedEvents': (await getPlannedEvents())
          .map((e) => e.toJson())
          .toList(),
      'lessons': (await getLessons()).map((l) => l.toJson()).toList(),
      'lessonProgress': (await getLessonProgress())
          .map((p) => p.toJson())
          .toList(),
      'playerProfile': (await getPlayerProfile()).toJson(),
      'achievements': (await getAchievements()).map((a) => a.toJson()).toList(),
      'bariMemory': (await getBariMemory()).toJson(),
    };
  }

  static Future<void> importData(Map<String, dynamic> data) async {
    try {
      if (data['transactions'] != null) {
        try {
          final transactions = (data['transactions'] as List)
              .map((j) => Transaction.fromJson(j as Map<String, dynamic>))
              .toList();
          await saveTransactions(transactions);
        } catch (e) {
          debugPrint('Error importing transactions: $e');
        }
      }
      if (data['piggyBanks'] != null) {
        try {
          final piggyBanks = (data['piggyBanks'] as List)
              .map((j) => PiggyBank.fromJson(j as Map<String, dynamic>))
              .toList();
          await savePiggyBanks(piggyBanks);
        } catch (e) {
          debugPrint('Error importing piggy banks: $e');
        }
      }
      if (data['plannedEvents'] != null) {
        try {
          final events = (data['plannedEvents'] as List)
              .map((j) => PlannedEvent.fromJson(j as Map<String, dynamic>))
              .toList();
          await savePlannedEvents(events);
        } catch (e) {
          debugPrint('Error importing planned events: $e');
        }
      }
      if (data['lessons'] != null) {
        try {
          final lessons = (data['lessons'] as List)
              .map((j) => Lesson.fromJson(j as Map<String, dynamic>))
              .toList();
          await saveLessons(lessons);
        } catch (e) {
          debugPrint('Error importing lessons: $e');
        }
      }
      if (data['lessonProgress'] != null) {
        try {
          final progress = (data['lessonProgress'] as List)
              .map((j) => LessonProgress.fromJson(j as Map<String, dynamic>))
              .toList();
          await saveLessonProgress(progress);
        } catch (e) {
          debugPrint('Error importing lesson progress: $e');
        }
      }
      if (data['playerProfile'] != null) {
        try {
          final profile = PlayerProfile.fromJson(
            data['playerProfile'] as Map<String, dynamic>,
          );
          await savePlayerProfile(profile);
        } catch (e) {
          debugPrint('Error importing player profile: $e');
        }
      }
      if (data['achievements'] != null) {
        try {
          final achievements = (data['achievements'] as List)
              .map((j) => Achievement.fromJson(j as Map<String, dynamic>))
              .toList();
          await saveAchievements(achievements);
        } catch (e) {
          debugPrint('Error importing achievements: $e');
        }
      }
      if (data['bariMemory'] != null) {
        try {
          final memory = BariMemory.fromJson(
            data['bariMemory'] as Map<String, dynamic>,
          );
          await saveBariMemory(memory);
        } catch (e) {
          debugPrint('Error importing bari memory: $e');
        }
      }
    } catch (e) {
      debugPrint('Error in importData: $e');
      rethrow; // Пробрасываем для показа диалога в UI
    }
  }

  static Future<void> resetAllData() async {
    final prefs = await _prefs;
    await prefs.remove(_keyTransactions);
    await prefs.remove(_keyPiggyBanks);
    await prefs.remove(_keyPlannedEvents);
    await prefs.remove(_keyLessons);
    await prefs.remove(_keyLessonProgress);
    await prefs.remove(_keyPlayerProfile);
    await prefs.remove(_keyAchievements);
    await prefs.remove(_keyBariMemory);
    await prefs.remove(_keyCustomTasks);
    await prefs.remove(_keyEarningsStreak);
    await prefs.remove(_keyLastStreakDate);
  }

  // Migration: Fix old wrong piggy bank transaction types
  static Future<void> migratePiggyLedgerIfNeeded() async {
    final prefs = await _prefs;
    const migrationKey = 'migrated_piggy_ledger_v1';

    // Check if migration already ran
    if (prefs.getBool(migrationKey) == true) {
      return;
    }

    final transactions = await getTransactions();
    bool changed = false;

    for (var i = 0; i < transactions.length; i++) {
      final t = transactions[i];

      // Only process piggy bank transactions
      if (t.source != TransactionSource.piggyBank) continue;

      bool needsFix = false;
      TransactionType? newType;

      // Fix: "Пополнение копилки" should be expense (wallet -> piggy)
      if (t.note != null &&
          t.note!.startsWith('Пополнение копилки') &&
          t.type == TransactionType.income) {
        needsFix = true;
        newType = TransactionType.expense;
      }

      // Fix: "Снятие из копилки" should be income (piggy -> wallet)
      if (t.note != null &&
          t.note!.startsWith('Снятие из копилки') &&
          t.type == TransactionType.expense) {
        needsFix = true;
        newType = TransactionType.income;
      }

      if (needsFix && newType != null) {
        transactions[i] = t.copyWith(type: newType);
        changed = true;
      }
    }

    if (changed) {
      await saveTransactions(transactions);
    }

    // Mark migration as completed
    await prefs.setBool(migrationKey, true);
  }

  // Custom Tasks
  static Future<List<CustomTask>> getCustomTasks() async {
    try {
      final prefs = await _prefs;
      final json = prefs.getString(_keyCustomTasks);
      if (json == null) return [];
      final List<dynamic> decoded = jsonDecode(json);
      return decoded
          .map((j) => CustomTask.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading custom tasks: $e');
      return [];
    }
  }

  static Future<void> saveCustomTasks(List<CustomTask> tasks) async {
    try {
      final prefs = await _prefs;
      final json = jsonEncode(tasks.map((t) => t.toJson()).toList());
      await prefs.setString(_keyCustomTasks, json);
    } catch (e) {
      debugPrint('Error saving custom tasks: $e');
    }
  }

  // Earnings Streak
  static Future<int> getEarningsStreak() async {
    try {
      final prefs = await _prefs;
      return prefs.getInt(_keyEarningsStreak) ?? 0;
    } catch (e) {
      debugPrint('Error loading earnings streak: $e');
      return 0;
    }
  }

  static Future<void> setEarningsStreak(int streak) async {
    try {
      final prefs = await _prefs;
      await prefs.setInt(_keyEarningsStreak, streak);
    } catch (e) {
      debugPrint('Error saving earnings streak: $e');
    }
  }

  static Future<DateTime?> getLastStreakDate() async {
    try {
      final prefs = await _prefs;
      final dateStr = prefs.getString(_keyLastStreakDate);
      if (dateStr == null) return null;
      return DateTime.parse(dateStr);
    } catch (e) {
      debugPrint('Error loading last streak date: $e');
      return null;
    }
  }

  static Future<void> setLastStreakDate(DateTime date) async {
    try {
      final prefs = await _prefs;
      await prefs.setString(_keyLastStreakDate, date.toIso8601String());
    } catch (e) {
      debugPrint('Error saving last streak date: $e');
    }
  }

  // Bari Settings
  static Future<String> getBariMode() async {
    final prefs = await _prefs;
    return prefs.getString(_keyBariMode) ?? 'offline';
  }

  static Future<void> setBariMode(String mode) async {
    final prefs = await _prefs;
    await prefs.setString(_keyBariMode, mode);
  }

  static Future<bool> getBariShowSources() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyBariShowSources) ?? true;
  }

  static Future<void> setBariShowSources(bool show) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyBariShowSources, show);
  }

  static Future<bool> getBariAllowOnlineReference() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyBariAllowOnlineReference) ?? false;
  }

  static Future<void> setBariAllowOnlineReference(bool allow) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyBariAllowOnlineReference, allow);
  }

  // Bari Smart settings (новые)
  static Future<bool> getBariOnlineEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool('bari_online_enabled') ?? false;
  }

  static Future<void> setBariOnlineEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool('bari_online_enabled', enabled);
  }

  static Future<bool> getBariOnlineManualOnly() async {
    final prefs = await _prefs;
    return prefs.getBool('bari_online_manual_only') ?? true;
  }

  static Future<void> setBariOnlineManualOnly(bool manualOnly) async {
    final prefs = await _prefs;
    await prefs.setBool('bari_online_manual_only', manualOnly);
  }

  static Future<bool> getBariSmallTalkEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool('bari_small_talk_enabled') ?? true;
  }

  static Future<void> setBariSmallTalkEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool('bari_small_talk_enabled', enabled);
  }

  static Future<bool> getBariUseSystemAssistant() async {
    final prefs = await _prefs;
    return prefs.getBool('bari_use_system_assistant') ?? true;
  }

  static Future<void> setBariUseSystemAssistant(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool('bari_use_system_assistant', enabled);
  }

  // AI Settings
  static Future<String?> getAiApiKey() async {
    final prefs = await _prefs;
    return prefs.getString('ai_api_key');
  }

  static Future<void> setAiApiKey(String? key) async {
    final prefs = await _prefs;
    if (key == null || key.isEmpty) {
      await prefs.remove('ai_api_key');
    } else {
      await prefs.setString('ai_api_key', key);
    }
  }

  static Future<String?> getAiBaseUrl() async {
    final prefs = await _prefs;
    return prefs.getString('ai_base_url');
  }

  static Future<void> setAiBaseUrl(String url) async {
    final prefs = await _prefs;
    await prefs.setString('ai_base_url', url);
  }

  static Future<String?> getAiModel() async {
    final prefs = await _prefs;
    return prefs.getString('ai_model');
  }

  static Future<void> setAiModel(String model) async {
    final prefs = await _prefs;
    await prefs.setString('ai_model', model);
  }

  // Gemini Nano Settings
  static const String _keyGeminiNanoEnabled = 'gemini_nano_enabled';
  static const String _keyGeminiNanoDownloaded = 'gemini_nano_downloaded';

  static Future<bool> getGeminiNanoEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyGeminiNanoEnabled) ?? false;
  }

  static Future<void> setGeminiNanoEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyGeminiNanoEnabled, enabled);
  }

  static Future<bool> getGeminiNanoDownloaded() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyGeminiNanoDownloaded) ?? false;
  }

  static Future<void> setGeminiNanoDownloaded(bool downloaded) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyGeminiNanoDownloaded, downloaded);
  }

  // Notes
  static Future<List<Note>> getNotes({bool forceRefresh = false}) async {
    final now = DateTime.now();

    // Return cache if fresh
    if (!forceRefresh &&
        _notesCache != null &&
        _notesCacheAt != null &&
        now.difference(_notesCacheAt!) < _cacheTTL) {
      return _notesCache!;
    }

    try {
      final prefs = await _prefs;
      final json = prefs.getString(_keyNotes);
      if (json == null) {
        _notesCache = [];
        _notesCacheAt = now;
        return [];
      }
      final List<dynamic> decoded = jsonDecode(json);
      _notesCache = decoded
          .map((j) => Note.fromJson(j as Map<String, dynamic>))
          .toList();
      _notesCacheAt = now;
      return _notesCache!;
    } catch (e) {
      debugPrint('Error loading notes: $e');
      return _notesCache ?? [];
    }
  }

  static Future<void> saveNotes(List<Note> notes) async {
    final prefs = await _prefs;
    final json = jsonEncode(notes.map((n) => n.toJson()).toList());
    await prefs.setString(_keyNotes, json);

    // Update cache
    _notesCache = notes;
    _notesCacheAt = DateTime.now();
    notesVersion.value++;
  }

  static Future<void> addNote(Note note) async {
    final notes = await getNotes();
    notes.add(note);
    await saveNotes(notes);
  }

  static Future<void> updateNote(Note updatedNote) async {
    final notes = await getNotes();
    final index = notes.indexWhere((n) => n.id == updatedNote.id);
    if (index >= 0) {
      notes[index] = updatedNote;
      await saveNotes(notes);
    }
  }

  static Future<void> deleteNote(String noteId) async {
    final notes = await getNotes();
    notes.removeWhere((n) => n.id == noteId);
    await saveNotes(notes);
  }

  // Calendar Sync Config
  static Future<CalendarSyncConfig> getCalendarSyncConfig({
    bool forceRefresh = false,
  }) async {
    final now = DateTime.now();

    if (!forceRefresh &&
        _calendarSyncConfigCache != null &&
        _calendarSyncConfigCacheAt != null &&
        now.difference(_calendarSyncConfigCacheAt!) < _cacheTTL) {
      return _calendarSyncConfigCache!;
    }

    try {
      final prefs = await _prefs;
      final json = prefs.getString(_keyCalendarSyncConfig);
      if (json == null) {
        _calendarSyncConfigCache = const CalendarSyncConfig();
        _calendarSyncConfigCacheAt = now;
        return _calendarSyncConfigCache!;
      }
      _calendarSyncConfigCache = CalendarSyncConfig.fromJson(jsonDecode(json));
      _calendarSyncConfigCacheAt = now;
      return _calendarSyncConfigCache!;
    } catch (e) {
      debugPrint('Error loading calendar sync config: $e');
      return _calendarSyncConfigCache ?? const CalendarSyncConfig();
    }
  }

  static Future<void> saveCalendarSyncConfig(CalendarSyncConfig config) async {
    final prefs = await _prefs;
    final json = jsonEncode(config.toJson());
    await prefs.setString(_keyCalendarSyncConfig, json);

    // Update cache
    _calendarSyncConfigCache = config;
    _calendarSyncConfigCacheAt = DateTime.now();
  }
}
