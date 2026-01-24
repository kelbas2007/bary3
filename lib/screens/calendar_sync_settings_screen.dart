import 'package:flutter/material.dart';
import 'package:device_calendar/device_calendar.dart';
import '../services/calendar_sync_service.dart';
import '../services/sync_manager.dart';
import '../services/storage_service.dart';
import '../models/calendar_sync_config.dart';
import '../theme/aurora_theme.dart';
import '../l10n/app_localizations.dart';

class CalendarSyncSettingsScreen extends StatefulWidget {
  const CalendarSyncSettingsScreen({super.key});

  @override
  State<CalendarSyncSettingsScreen> createState() =>
      _CalendarSyncSettingsScreenState();
}

class _CalendarSyncSettingsScreenState
    extends State<CalendarSyncSettingsScreen> {
  final CalendarSyncService _syncService = CalendarSyncService();
  final SyncManager _syncManager = SyncManager();
  CalendarSyncConfig? _config;
  List<Calendar> _calendars = [];
  bool _loading = true;
  bool _syncing = false;
  SyncReport? _syncReport;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      await _syncService.init();
      _config = await StorageService.getCalendarSyncConfig();
      _syncReport = await _syncManager.getSyncReport();
      await _loadCalendars();
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.calendarSync_loadError(e.toString())),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadCalendars() async {
    try {
      _calendars = await _syncService.getCalendars(forceRefresh: true);
    } catch (e) {
      debugPrint('Error loading calendars: $e');
      _calendars = [];
    }
  }

  Future<void> _requestPermissions() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final granted = await _syncService.requestPermissions();
      if (granted) {
        await _loadCalendars();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.calendarSync_permissionsGrantedMsg),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.calendarSync_permissionsNotGrantedMsg),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.calendarSync_permissionError(e.toString())),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _updateConfig(CalendarSyncConfig newConfig) async {
    await _syncService.updateConfig(newConfig);
    _config = newConfig;
    _syncManager.updateAutoSyncSchedule();
    setState(() {});
  }

  Future<void> _syncNow() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _syncing = true);
    try {
      await _syncManager.syncAll();
      _syncReport = await _syncManager.getSyncReport();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.calendarSync_syncComplete),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.calendarSync_syncError(e.toString())),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _syncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.calendarSync_title),
          backgroundColor: Colors.transparent,
        ),
        body: Container(
          decoration: const BoxDecoration(gradient: AuroraTheme.blueGradient),
          child: const Center(
            child: CircularProgressIndicator(color: AuroraTheme.neonBlue),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.calendarSync_title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AuroraTheme.blueGradient),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Enable sync
            AuroraTheme.glassCard(
              child: SwitchListTile(
                title: Text(
                  l10n.calendarSync_enable,
                  style: const TextStyle(color: Colors.white),
                ),
                value: _config?.enabled ?? false,
                onChanged: (value) {
                  _updateConfig(_config!.copyWith(enabled: value));
                },
                activeTrackColor: AuroraTheme.neonBlue.withValues(alpha: 0.5),
                activeThumbColor: AuroraTheme.neonBlue,
              ),
            ),
            const SizedBox(height: 16),

            if (_config?.enabled == true) ...[
              // Permissions
              if (_calendars.isEmpty)
                AuroraTheme.glassCard(
                  child: ListTile(
                    title: Text(
                      l10n.calendarSync_requestPermissions,
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: ElevatedButton(
                      onPressed: _requestPermissions,
                      child: Text(l10n.calendarSync_requestPermissions),
                    ),
                  ),
                ),

              // Calendar selection
              if (_calendars.isNotEmpty) ...[
                AuroraTheme.glassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          l10n.calendarSync_selectCalendars,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ..._calendars.map((calendar) {
                        final isSelected = _config!.selectedCalendars
                            .contains(calendar.id);
                        return CheckboxListTile(
                          title: Text(
                            calendar.name ?? l10n.calendarSync_unnamedCalendar,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: calendar.accountName != null
                              ? Text(
                                  calendar.accountName!,
                                  style: const TextStyle(color: Colors.white70),
                                )
                              : null,
                          value: isSelected,
                          onChanged: (value) {
                            final selected = List<String>.from(
                              _config!.selectedCalendars,
                            );
                            if (value == true) {
                              selected.add(calendar.id ?? '');
                            } else {
                              selected.remove(calendar.id);
                            }
                            _updateConfig(
                              _config!.copyWith(selectedCalendars: selected),
                            );
                          },
                          activeColor: AuroraTheme.neonBlue,
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Sync directions
              AuroraTheme.glassCard(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(
                        l10n.calendarSync_syncToCalendar,
                        style: const TextStyle(color: Colors.white),
                      ),
                      value: _config?.syncEventsToCalendar ?? true,
                      onChanged: (value) {
                        _updateConfig(
                          _config!.copyWith(syncEventsToCalendar: value),
                        );
                      },
                      activeTrackColor: AuroraTheme.neonBlue.withValues(alpha: 0.5),
                activeThumbColor: AuroraTheme.neonBlue,
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: Text(
                        l10n.calendarSync_syncFromCalendar,
                        style: const TextStyle(color: Colors.white),
                      ),
                      value: _config?.syncCalendarToApp ?? false,
                      onChanged: (value) {
                        _updateConfig(
                          _config!.copyWith(syncCalendarToApp: value),
                        );
                      },
                      activeTrackColor: AuroraTheme.neonBlue.withValues(alpha: 0.5),
                activeThumbColor: AuroraTheme.neonBlue,
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: Text(
                        l10n.calendarSync_syncNotesAsEvents,
                        style: const TextStyle(color: Colors.white),
                      ),
                      value: _config?.syncNotesAsEvents ?? false,
                      onChanged: (value) {
                        _updateConfig(
                          _config!.copyWith(syncNotesAsEvents: value),
                        );
                      },
                      activeTrackColor: AuroraTheme.neonBlue.withValues(alpha: 0.5),
                activeThumbColor: AuroraTheme.neonBlue,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Conflict resolution
              AuroraTheme.glassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        l10n.calendarSync_conflictResolution,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    RadioGroup<ConflictResolution>(
                      groupValue: _config?.conflictResolution,
                      onChanged: (value) {
                        if (value != null) {
                          _updateConfig(
                            _config!.copyWith(conflictResolution: value),
                          );
                        }
                      },
                      child: Column(
                        children: [
                          RadioListTile<ConflictResolution>(
                            title: Text(
                              l10n.calendarSync_appWins,
                              style: const TextStyle(color: Colors.white),
                            ),
                            value: ConflictResolution.appWins,
                            activeColor: AuroraTheme.neonBlue,
                          ),
                          RadioListTile<ConflictResolution>(
                            title: Text(
                              l10n.calendarSync_calendarWins,
                              style: const TextStyle(color: Colors.white),
                            ),
                            value: ConflictResolution.calendarWins,
                            activeColor: AuroraTheme.neonBlue,
                          ),
                          RadioListTile<ConflictResolution>(
                            title: Text(
                              l10n.calendarSync_askUser,
                              style: const TextStyle(color: Colors.white),
                            ),
                            value: ConflictResolution.askUser,
                            activeColor: AuroraTheme.neonBlue,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Sync interval
              AuroraTheme.glassCard(
                child: ListTile(
                  title: Text(
                    l10n.calendarSync_syncInterval,
                    style: const TextStyle(color: Colors.white),
                  ),
                    subtitle: Text(
                      l10n.calendarSync_hours(_config?.syncIntervalHours ?? 24),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  trailing: DropdownButton<int>(
                    value: _config?.syncIntervalHours ?? 24,
                    items: [1, 6, 12, 24, 48].map((hours) {
                      return DropdownMenuItem(
                        value: hours,
                        child: Text(l10n.calendarSync_hours(hours)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _updateConfig(
                          _config!.copyWith(syncIntervalHours: value),
                        );
                        _syncManager.updateAutoSyncSchedule();
                      }
                    },
                    dropdownColor: AuroraTheme.spaceBlue,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sync now button
              AuroraTheme.glassCard(
                child: ListTile(
                  title: Text(
                    _syncing
                        ? l10n.calendarSync_syncInProgress
                        : l10n.calendarSync_syncNow,
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: _syncing
                      ? const CircularProgressIndicator(
                          color: AuroraTheme.neonBlue,
                        )
                      : IconButton(
                          icon: const Icon(Icons.sync),
                          onPressed: _syncNow,
                          color: AuroraTheme.neonBlue,
                        ),
                  onTap: _syncing ? null : _syncNow,
                ),
              ),
              const SizedBox(height: 16),

              // Statistics
              if (_syncReport != null) ...[
                AuroraTheme.glassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.calendarSync_statistics,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _StatRow(
                          label: l10n.calendarSync_totalEvents,
                          value: '${_syncReport!.totalEvents}',
                        ),
                        _StatRow(
                          label: l10n.calendarSync_syncedEvents,
                          value: '${_syncReport!.syncedEvents}',
                          color: Colors.green,
                        ),
                        _StatRow(
                          label: l10n.calendarSync_localEvents,
                          value: '${_syncReport!.localEvents}',
                          color: Colors.orange,
                        ),
                        _StatRow(
                          label: l10n.calendarSync_errorEvents,
                          value: '${_syncReport!.errorEvents}',
                          color: Colors.redAccent,
                        ),
                        _StatRow(
                          label: l10n.calendarSync_successRate,
                          value:
                              '${(_syncReport!.successRate * 100).toStringAsFixed(1)}%',
                          color: _syncReport!.successRate > 0.9
                              ? Colors.green
                              : Colors.orange,
                        ),
                        if (_syncReport!.lastSyncTime != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${l10n.calendarSync_lastSync}: ${_formatDateTime(_syncReport!.lastSyncTime!)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}.${dateTime.month}.${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatRow({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
