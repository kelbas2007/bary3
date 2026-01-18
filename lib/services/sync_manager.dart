import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/note.dart';
import './calendar_sync_service.dart';
import './storage_service.dart';
import './note_service.dart';

class SyncManager {
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;
  SyncManager._internal();

  final CalendarSyncService _calendarSyncService = CalendarSyncService();
  final NoteService _noteService = NoteService();
  Timer? _autoSyncTimer;

  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  int _successfulSyncs = 0;
  int _failedSyncs = 0;

  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  int get successfulSyncs => _successfulSyncs;
  int get failedSyncs => _failedSyncs;

  Future<void> init() async {
    await _calendarSyncService.init();
    await _noteService.init();
    _scheduleAutoSync();
  }

  /// Полная синхронизация всех данных
  Future<void> syncAll() async {
    if (_isSyncing) {
      debugPrint('Sync already in progress');
      return;
    }

    _isSyncing = true;
    try {
      final config = await StorageService.getCalendarSyncConfig();
      if (!config.enabled) {
        debugPrint('Calendar sync is disabled');
        return;
      }

      // Синхронизация событий
      if (config.syncEventsToCalendar) {
        final events = await StorageService.getPlannedEvents();
        await _calendarSyncService.syncEventsToCalendar(events);
      }

      // Синхронизация заметок (если включено)
      if (config.syncNotesAsEvents) {
        final notes = _noteService.notes.value;
        await _calendarSyncService.syncNotesToCalendar(notes);
      }

      // Импорт из календаря (если включено)
      if (config.syncCalendarToApp) {
        await _calendarSyncService.syncFromCalendar();
      }

      _lastSyncTime = DateTime.now();
      _successfulSyncs++;
    } catch (e) {
      _failedSyncs++;
      debugPrint('Error during full sync: $e');
      await handleSyncError(SyncError(
        eventId: null,
        error: e.toString(),
        timestamp: DateTime.now(),
      ));
      rethrow;
    } finally {
      _isSyncing = false;
    }
  }

  /// Инкрементальная синхронизация (только изменения)
  Future<void> incrementalSync() async {
    if (_isSyncing) {
      debugPrint('Sync already in progress');
      return;
    }

    _isSyncing = true;
    try {
      final config = await StorageService.getCalendarSyncConfig();
      if (!config.enabled) {
        return;
      }

      // Получаем только события, которые нужно синхронизировать
      final allEvents = await StorageService.getPlannedEvents();
      final eventsToSync = allEvents.where((e) {
        // Синхронизируем только если:
        // 1. Включена синхронизация для этого события
        // 2. Событие не синхронизировано или статус синхронизации - ошибка
        return e.syncToCalendar &&
            (e.syncStatus == SyncStatus.local ||
                e.syncStatus == SyncStatus.error);
      }).toList();

      if (eventsToSync.isNotEmpty) {
        await _calendarSyncService.syncEventsToCalendar(eventsToSync);
      }

      _lastSyncTime = DateTime.now();
      _successfulSyncs++;
    } catch (e) {
      _failedSyncs++;
      debugPrint('Error during incremental sync: $e');
      await handleSyncError(SyncError(
        eventId: null,
        error: e.toString(),
        timestamp: DateTime.now(),
      ));
    } finally {
      _isSyncing = false;
    }
  }

  /// Обработка ошибок синхронизации
  Future<void> handleSyncError(SyncError error) async {
    debugPrint('Sync error: ${error.error}');
    // Можно добавить логирование ошибок в файл или отправку в аналитику
  }

  /// Получить отчет о синхронизации
  Future<SyncReport> getSyncReport() async {
    final config = await StorageService.getCalendarSyncConfig();
    final allEvents = await StorageService.getPlannedEvents();
    final syncedEvents = allEvents.where((e) => e.syncStatus == SyncStatus.synced).length;
    final localEvents = allEvents.where((e) => e.syncStatus == SyncStatus.local).length;
    final errorEvents = allEvents.where((e) => e.syncStatus == SyncStatus.error).length;

    return SyncReport(
      enabled: config.enabled,
      lastSyncTime: _lastSyncTime,
      totalEvents: allEvents.length,
      syncedEvents: syncedEvents,
      localEvents: localEvents,
      errorEvents: errorEvents,
      successfulSyncs: _successfulSyncs,
      failedSyncs: _failedSyncs,
      successRate: _successfulSyncs + _failedSyncs > 0
          ? _successfulSyncs / (_successfulSyncs + _failedSyncs)
          : 0.0,
    );
  }

  /// Настроить автоматическую синхронизацию по расписанию
  void _scheduleAutoSync() async {
    final config = await StorageService.getCalendarSyncConfig();
    if (!config.enabled) {
      return;
    }

    _autoSyncTimer?.cancel();
    final intervalHours = config.syncIntervalHours;
    if (intervalHours <= 0) {
      return;
    }

    _autoSyncTimer = Timer.periodic(
      Duration(hours: intervalHours),
      (_) => incrementalSync(),
    );
  }

  /// Обновить расписание автоматической синхронизации
  void updateAutoSyncSchedule() {
    _scheduleAutoSync();
  }

  void dispose() {
    _autoSyncTimer?.cancel();
  }
}

class SyncReport {
  final bool enabled;
  final DateTime? lastSyncTime;
  final int totalEvents;
  final int syncedEvents;
  final int localEvents;
  final int errorEvents;
  final int successfulSyncs;
  final int failedSyncs;
  final double successRate;

  SyncReport({
    required this.enabled,
    this.lastSyncTime,
    required this.totalEvents,
    required this.syncedEvents,
    required this.localEvents,
    required this.errorEvents,
    required this.successfulSyncs,
    required this.failedSyncs,
    required this.successRate,
  });
}
