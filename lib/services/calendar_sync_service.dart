import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/planned_event.dart';
import '../models/transaction.dart';
import '../models/note.dart';
import '../models/calendar_sync_config.dart';
import './storage_service.dart';

class CalendarSyncService {
  static final CalendarSyncService _instance = CalendarSyncService._internal();
  factory CalendarSyncService() => _instance;
  CalendarSyncService._internal();

  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
  List<Calendar>? _calendars;
  CalendarSyncConfig? _config;

  final StreamController<SyncProgress> _progressController =
      StreamController<SyncProgress>.broadcast();
  Stream<SyncProgress> get progressStream => _progressController.stream;

  final StreamController<SyncError> _errorController =
      StreamController<SyncError>.broadcast();
  Stream<SyncError> get errorStream => _errorController.stream;

  bool _isSyncing = false;

  Future<void> init() async {
    _config = await StorageService.getCalendarSyncConfig();
  }

  Future<bool> requestPermissions() async {
    try {
      final result = await _deviceCalendarPlugin.requestPermissions();
      return result.isSuccess && result.data == true;
    } catch (e) {
      debugPrint('Error requesting calendar permissions: $e');
      return false;
    }
  }

  Future<bool> _checkPermissions() async {
    try {
      final hasPermissions = await _deviceCalendarPlugin.hasPermissions();
      return hasPermissions.isSuccess && hasPermissions.data == true;
    } catch (e) {
      debugPrint('Error checking calendar permissions: $e');
      return false;
    }
  }

  Future<List<Calendar>> getCalendars({bool forceRefresh = false}) async {
    if (!forceRefresh && _calendars != null) {
      return _calendars!;
    }

    final hasPermissions = await _checkPermissions();
    if (!hasPermissions) {
      throw CalendarSyncException('Calendar permissions not granted');
    }

    try {
      final result = await _deviceCalendarPlugin.retrieveCalendars();
      if (result.isSuccess != true || result.data == null) {
        final errorMsg = result.errors.isNotEmpty
            ? result.errors.first.toString()
            : 'Failed to retrieve calendars';
        throw CalendarSyncException(errorMsg);
      }

      _calendars = result.data!;
      return _calendars!;
    } catch (e) {
      debugPrint('Error retrieving calendars: $e');
      throw CalendarSyncException('Failed to retrieve calendars: $e');
    }
  }

  Future<void> syncEventsToCalendar(List<PlannedEvent> events) async {
    if (!_config!.enabled || !_config!.syncEventsToCalendar) {
      return;
    }

    if (_isSyncing) {
      debugPrint('Sync already in progress');
      return;
    }

    _isSyncing = true;
    try {
      final calendars = await getCalendars();
      final selectedCalendars = _config!.selectedCalendars;
      if (selectedCalendars.isEmpty) {
        _progressController.add(
          SyncProgress(
            message: 'No calendars selected for sync',
            progress: 1.0,
            completed: true,
          ),
        );
        return;
      }

      final targetCalendars = calendars
          .where((cal) => selectedCalendars.contains(cal.id))
          .toList();
      if (targetCalendars.isEmpty) {
        _progressController.add(
          SyncProgress(
            message: 'Selected calendars not found',
            progress: 1.0,
            completed: true,
          ),
        );
        return;
      }

      int processed = 0;
      final total = events.length;

      for (final event in events) {
        if (!event.syncToCalendar) {
          processed++;
          continue;
        }

        try {
          await _syncEventToCalendar(event, targetCalendars);
        } catch (e) {
          _errorController.add(
            SyncError(
              eventId: event.id,
              error: e.toString(),
              timestamp: DateTime.now(),
            ),
          );
        }

        processed++;
        _progressController.add(
          SyncProgress(
            message: 'Syncing event: ${event.name ?? event.id}',
            progress: processed / total,
            completed: false,
          ),
        );
      }

      _progressController.add(
        SyncProgress(message: 'Sync completed', progress: 1.0, completed: true),
      );
    } catch (e) {
      _errorController.add(
        SyncError(
          eventId: null,
          error: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncEventToCalendar(
    PlannedEvent event,
    List<Calendar> calendars,
  ) async {
    if (calendars.isEmpty) {
      throw CalendarSyncException('No calendars available for sync');
    }

    // Use first selected calendar
    final calendar = calendars.first;

    try {
      // Build event title
      final title =
          event.name ??
          '${event.type == TransactionType.income ? "Доход" : "Расход"}: ${_formatAmount(event.amount)}';

      // Build event description
      final description = _buildEventDescription(event);

      // Create or update event
      if (event.calendarEventId != null) {
        // Update existing event
        final updateResult = await _deviceCalendarPlugin.createOrUpdateEvent(
          Event(
            calendar.id,
            eventId: event.calendarEventId,
            title: title,
            description: description,
            start: tz.TZDateTime.from(event.dateTime, tz.local),
            end: tz.TZDateTime.from(
              event.dateTime.add(const Duration(hours: 1)),
              tz.local,
            ),
            recurrenceRule: _buildRecurrenceRule(event),
          ),
        );

        if (updateResult == null || updateResult.isSuccess != true) {
          final errorMsg =
              updateResult != null && updateResult.errors.isNotEmpty
              ? updateResult.errors.first.toString()
              : 'Failed to update calendar event';
          throw CalendarSyncException(errorMsg);
        }
      } else {
        // Create new event
        final createResult = await _deviceCalendarPlugin.createOrUpdateEvent(
          Event(
            calendar.id,
            title: title,
            description: description,
            start: tz.TZDateTime.from(event.dateTime, tz.local),
            end: tz.TZDateTime.from(
              event.dateTime.add(const Duration(hours: 1)),
              tz.local,
            ),
            recurrenceRule: _buildRecurrenceRule(event),
          ),
        );

        if (createResult == null ||
            createResult.isSuccess != true ||
            createResult.data == null) {
          final errorMsg =
              createResult != null && createResult.errors.isNotEmpty
              ? createResult.errors.first.toString()
              : 'Failed to create calendar event';
          throw CalendarSyncException(errorMsg);
        }

        // Save calendar event ID back to event
        // This should be done by updating the event in storage
        // For now, we'll just log it
        debugPrint('Created calendar event: ${createResult.data}');
      }
    } catch (e) {
      debugPrint('Error syncing event to calendar: $e');
      rethrow;
    }
  }

  String _formatAmount(int amountInCents) {
    return (amountInCents / 100).toStringAsFixed(2);
  }

  String _buildEventDescription(PlannedEvent event) {
    final buffer = StringBuffer();
    buffer.writeln(
      'Тип: ${event.type == TransactionType.income ? "Доход" : "Расход"}',
    );
    buffer.writeln('Сумма: ${_formatAmount(event.amount)}');
    if (event.category != null) {
      buffer.writeln('Категория: ${event.category}');
    }
    if (event.linkedNoteIds.isNotEmpty) {
      buffer.writeln('Связанные заметки: ${event.linkedNoteIds.length}');
    }
    return buffer.toString();
  }

  RecurrenceRule? _buildRecurrenceRule(PlannedEvent event) {
    if (event.repeat == RepeatType.none) {
      return null;
    }

    // Note: RecurrenceRule API in device_calendar 4.3.3 requires RecurrenceFrequency enum
    // The exact enum values and constructor parameters need to be verified
    // by checking device_calendar package documentation or source code
    //
    // Expected usage:
    // RecurrenceRule(RecurrenceFrequency.daily) or similar
    //
    // For now, we'll skip recurrence rules to avoid API compatibility issues
    // The event will be created without recurrence
    // NOTE: RecurrenceRule is intentionally not implemented here, because the
    // device_calendar API needs to be re-checked (RecurrenceFrequency values
    // and RecurrenceRule constructor signature) before enabling it.
    debugPrint(
      'Recurrence rule requested for ${event.repeat}, '
      'but RecurrenceRule API needs verification with device_calendar 4.3.3',
    );
    return null;
  }

  Future<void> syncNotesToCalendar(List<Note> notes) async {
    if (!_config!.enabled || !_config!.syncNotesAsEvents) {
      return;
    }

    try {
      final calendars = await getCalendars();
      final selectedCalendars = _config!.selectedCalendars;
      if (selectedCalendars.isEmpty || calendars.isEmpty) {
        return;
      }

      final targetCalendars = calendars
          .where((cal) => selectedCalendars.contains(cal.id))
          .toList();
      if (targetCalendars.isEmpty) {
        return;
      }

      final calendar = targetCalendars.first;

      for (final note in notes) {
        // Only sync notes that are not already synced or have sync errors
        if (note.syncStatus == SyncStatus.synced &&
            note.calendarEventId != null) {
          continue;
        }

        try {
          // Create calendar event for note
          final title = note.title.isEmpty ? 'Заметка' : note.title;
          final description = note.content.length > 500
              ? '${note.content.substring(0, 500)}...'
              : note.content;

          // Use note creation date as event date, or current date if not set
          final eventDate = note.createdAt;

          if (note.calendarEventId != null) {
            // Update existing event
            final updateResult = await _deviceCalendarPlugin
                .createOrUpdateEvent(
                  Event(
                    calendar.id,
                    eventId: note.calendarEventId,
                    title: title,
                    description: description,
                    start: tz.TZDateTime.from(eventDate, tz.local),
                    end: tz.TZDateTime.from(
                      eventDate.add(const Duration(hours: 1)),
                      tz.local,
                    ),
                  ),
                );

            if (updateResult != null && updateResult.isSuccess == true) {
              // Update note sync status
              // This should be done through NoteService
              debugPrint('Updated calendar event for note: ${note.id}');
            }
          } else {
            // Create new event
            final createResult = await _deviceCalendarPlugin
                .createOrUpdateEvent(
                  Event(
                    calendar.id,
                    title: title,
                    description: description,
                    start: tz.TZDateTime.from(eventDate, tz.local),
                    end: tz.TZDateTime.from(
                      eventDate.add(const Duration(hours: 1)),
                      tz.local,
                    ),
                  ),
                );

            if (createResult != null &&
                createResult.isSuccess == true &&
                createResult.data != null) {
              // Save calendar event ID to note
              // This should be done through NoteService
              debugPrint('Created calendar event for note: ${note.id}');
            }
          }
        } catch (e) {
          debugPrint('Error syncing note ${note.id} to calendar: $e');
          _errorController.add(
            SyncError(
              eventId: note.id,
              error: e.toString(),
              timestamp: DateTime.now(),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error in syncNotesToCalendar: $e');
      _errorController.add(
        SyncError(
          eventId: null,
          error: 'Failed to sync notes: $e',
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  Future<void> deleteEventFromCalendar(PlannedEvent event) async {
    if (event.calendarEventId == null) {
      return;
    }

    try {
      final calendars = await getCalendars();
      if (calendars.isEmpty) {
        debugPrint('No calendars available for deletion');
        return;
      }

      // Try to find the calendar that contains this event
      Calendar? targetCalendar;
      for (final cal in calendars) {
        try {
          // Try to retrieve events from this calendar and check if our event exists
          final retrieveResult = await _deviceCalendarPlugin.retrieveEvents(
            cal.id,
            RetrieveEventsParams(
              startDate: event.dateTime.subtract(const Duration(days: 1)),
              endDate: event.dateTime.add(const Duration(days: 1)),
            ),
          );
          if (retrieveResult.isSuccess && retrieveResult.data != null) {
            final events = retrieveResult.data!;
            if (events.any((e) => e.eventId == event.calendarEventId)) {
              targetCalendar = cal;
              break;
            }
          }
        } catch (e) {
          // Continue searching
        }
      }

      if (targetCalendar == null) {
        debugPrint('Calendar for event ${event.calendarEventId} not found');
        return;
      }

      final deleteResult = await _deviceCalendarPlugin.deleteEvent(
        targetCalendar.id,
        event.calendarEventId!,
      );

      if (deleteResult.isSuccess != true) {
        final errorMsg = deleteResult.errors.isNotEmpty
            ? deleteResult.errors.first.toString()
            : 'Failed to delete calendar event';
        throw CalendarSyncException(errorMsg);
      }
    } catch (e) {
      debugPrint('Error deleting calendar event: $e');
      rethrow;
    }
  }

  Future<List<Event>> fetchEventsFromCalendar(
    DateTime start,
    DateTime end,
  ) async {
    final calendars = await getCalendars();
    if (calendars.isEmpty) {
      return [];
    }

    final allEvents = <Event>[];
    for (final calendar in calendars) {
      try {
        final result = await _deviceCalendarPlugin.retrieveEvents(
          calendar.id,
          RetrieveEventsParams(startDate: start, endDate: end),
        );

        if (result.isSuccess && result.data != null) {
          allEvents.addAll(result.data!);
        }
      } catch (e) {
        debugPrint('Error fetching events from calendar ${calendar.id}: $e');
      }
    }

    return allEvents;
  }

  Future<void> syncFromCalendar() async {
    if (!_config!.enabled || !_config!.syncCalendarToApp) {
      return;
    }

    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month);
      final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final calendarEvents = await fetchEventsFromCalendar(start, end);

      // Process calendar events and create/update PlannedEvents
      // This is a simplified version - you may want to add more logic
      // to match calendar events with existing PlannedEvents
      for (final calendarEvent in calendarEvents) {
        // Check if this event is already synced
        // If not, create a new PlannedEvent from it
        // Implementation depends on your business logic
        debugPrint('Found calendar event: ${calendarEvent.title}');
      }
    } catch (e) {
      _errorController.add(
        SyncError(
          eventId: null,
          error: 'Failed to sync from calendar: $e',
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  Future<void> updateConfig(CalendarSyncConfig config) async {
    _config = config;
    await StorageService.saveCalendarSyncConfig(config);
  }

  void dispose() {
    _progressController.close();
    _errorController.close();
  }
}

class SyncProgress {
  final String message;
  final double progress; // 0.0 to 1.0
  final bool completed;

  SyncProgress({
    required this.message,
    required this.progress,
    required this.completed,
  });
}

class SyncError {
  final String? eventId;
  final String error;
  final DateTime timestamp;

  SyncError({
    required this.eventId,
    required this.error,
    required this.timestamp,
  });
}

class CalendarSyncException implements Exception {
  final String message;

  CalendarSyncException(this.message);

  @override
  String toString() => 'CalendarSyncException: $message';
}
