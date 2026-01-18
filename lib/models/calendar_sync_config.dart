import 'package:flutter/foundation.dart';

enum ConflictResolution { appWins, calendarWins, askUser, merge }

@immutable
class CalendarSyncConfig {
  final bool enabled;
  final bool syncEventsToCalendar;
  final bool syncCalendarToApp;
  final List<String> selectedCalendars;
  final bool syncNotesAsEvents;
  final ConflictResolution conflictResolution;
  final bool syncOnCreate;
  final bool syncOnUpdate;
  final bool syncOnDelete;
  final bool showSyncNotifications;
  final int syncIntervalHours;

  const CalendarSyncConfig({
    this.enabled = false,
    this.syncEventsToCalendar = true,
    this.syncCalendarToApp = false,
    this.selectedCalendars = const [],
    this.syncNotesAsEvents = false,
    this.conflictResolution = ConflictResolution.askUser,
    this.syncOnCreate = true,
    this.syncOnUpdate = true,
    this.syncOnDelete = true,
    this.showSyncNotifications = true,
    this.syncIntervalHours = 24,
  });

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'syncEventsToCalendar': syncEventsToCalendar,
    'syncCalendarToApp': syncCalendarToApp,
    'selectedCalendars': selectedCalendars,
    'syncNotesAsEvents': syncNotesAsEvents,
    'conflictResolution': conflictResolution.toString().split('.').last,
    'syncOnCreate': syncOnCreate,
    'syncOnUpdate': syncOnUpdate,
    'syncOnDelete': syncOnDelete,
    'showSyncNotifications': showSyncNotifications,
    'syncIntervalHours': syncIntervalHours,
  };

  factory CalendarSyncConfig.fromJson(Map<String, dynamic> json) =>
      CalendarSyncConfig(
        enabled: json['enabled'] as bool? ?? false,
        syncEventsToCalendar: json['syncEventsToCalendar'] as bool? ?? true,
        syncCalendarToApp: json['syncCalendarToApp'] as bool? ?? false,
        selectedCalendars:
            (json['selectedCalendars'] as List<dynamic>?)?.cast<String>() ??
            const [],
        syncNotesAsEvents: json['syncNotesAsEvents'] as bool? ?? false,
        conflictResolution: json['conflictResolution'] != null
            ? ConflictResolution.values.firstWhere(
                (e) =>
                    e.toString().split('.').last == json['conflictResolution'],
                orElse: () => ConflictResolution.askUser,
              )
            : ConflictResolution.askUser,
        syncOnCreate: json['syncOnCreate'] as bool? ?? true,
        syncOnUpdate: json['syncOnUpdate'] as bool? ?? true,
        syncOnDelete: json['syncOnDelete'] as bool? ?? true,
        showSyncNotifications: json['showSyncNotifications'] as bool? ?? true,
        syncIntervalHours: json['syncIntervalHours'] as int? ?? 24,
      );

  CalendarSyncConfig copyWith({
    bool? enabled,
    bool? syncEventsToCalendar,
    bool? syncCalendarToApp,
    List<String>? selectedCalendars,
    bool? syncNotesAsEvents,
    ConflictResolution? conflictResolution,
    bool? syncOnCreate,
    bool? syncOnUpdate,
    bool? syncOnDelete,
    bool? showSyncNotifications,
    int? syncIntervalHours,
  }) => CalendarSyncConfig(
    enabled: enabled ?? this.enabled,
    syncEventsToCalendar: syncEventsToCalendar ?? this.syncEventsToCalendar,
    syncCalendarToApp: syncCalendarToApp ?? this.syncCalendarToApp,
    selectedCalendars: selectedCalendars ?? this.selectedCalendars,
    syncNotesAsEvents: syncNotesAsEvents ?? this.syncNotesAsEvents,
    conflictResolution: conflictResolution ?? this.conflictResolution,
    syncOnCreate: syncOnCreate ?? this.syncOnCreate,
    syncOnUpdate: syncOnUpdate ?? this.syncOnUpdate,
    syncOnDelete: syncOnDelete ?? this.syncOnDelete,
    showSyncNotifications: showSyncNotifications ?? this.showSyncNotifications,
    syncIntervalHours: syncIntervalHours ?? this.syncIntervalHours,
  );
}
