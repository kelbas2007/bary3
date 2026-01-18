import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/deleted_events_service.dart';
import '../models/planned_event.dart';
import '../theme/aurora_theme.dart';
import '../l10n/app_localizations.dart';
import '../utils/date_formatter.dart';
import '../services/money_ui.dart' show formatAmountUi;
import '../services/storage_service.dart';
import '../state/planned_events_notifier.dart';
import '../services/notification_service.dart';
import '../models/transaction.dart';
import '../models/edit_scope.dart';

class DeletedEventsScreen extends ConsumerStatefulWidget {
  const DeletedEventsScreen({super.key});

  @override
  ConsumerState<DeletedEventsScreen> createState() => _DeletedEventsScreenState();
}

class _DeletedEventsScreenState extends ConsumerState<DeletedEventsScreen> {
  List<PlannedEvent> _deletedEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeletedEvents();
  }

  Future<void> _loadDeletedEvents() async {
    setState(() => _isLoading = true);
    final events = await DeletedEventsService.getDeletedEvents();
    // Сортируем по дате удаления (новые сверху)
    final eventsWithDates = <MapEntry<PlannedEvent, DateTime?>>[];
    for (var event in events) {
      final deletedAt = await DeletedEventsService.getDeletedAt(event.id);
      eventsWithDates.add(MapEntry(event, deletedAt));
    }
    eventsWithDates.sort((a, b) {
      if (a.value == null && b.value == null) return 0;
      if (a.value == null) return 1;
      if (b.value == null) return -1;
      return b.value!.compareTo(a.value!);
    });
    setState(() {
      _deletedEvents = eventsWithDates.map((e) => e.key).toList();
      _isLoading = false;
    });
  }

  Future<void> _restoreEvent(PlannedEvent event) async {
    final isRepeating = event.repeat != RepeatType.none || event.id.contains('_');
    
    if (isRepeating) {
      final scope = await _showRestoreScopeDialog();
      if (scope == null) return;
      
      if (scope == EditScope.allRepeating) {
        final restored = await DeletedEventsService.restoreEventWithRelated(event.id);
        final currentEvents = await StorageService.getPlannedEvents();
        currentEvents.addAll(restored);
        await StorageService.savePlannedEvents(currentEvents);
        
        // Планируем уведомления для восстановленных событий
        for (var restoredEvent in restored) {
          if (restoredEvent.notificationEnabled) {
            await NotificationService.scheduleEventNotification(restoredEvent);
          }
        }
      } else {
        final restored = await DeletedEventsService.restoreEvent(event.id);
        if (restored != null) {
          final currentEvents = await StorageService.getPlannedEvents();
          currentEvents.add(restored);
          await StorageService.savePlannedEvents(currentEvents);
          
          if (restored.notificationEnabled) {
            await NotificationService.scheduleEventNotification(restored);
          }
        }
      }
    } else {
      final restored = await DeletedEventsService.restoreEvent(event.id);
      if (restored != null) {
        final currentEvents = await StorageService.getPlannedEvents();
        currentEvents.add(restored);
        await StorageService.savePlannedEvents(currentEvents);
        
        if (restored.notificationEnabled) {
          await NotificationService.scheduleEventNotification(restored);
        }
      }
    }

    await ref.read(plannedEventsProvider.notifier).refresh();
    await _loadDeletedEvents();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.deletedEvents_restored)),
      );
    }
  }

  Future<EditScope?> _showRestoreScopeDialog() async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return null;
    
    return showDialog<EditScope>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AuroraTheme.spaceBlue,
        title: Text(
          l10n.deletedEvents_restoreScopeTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l10n.deletedEvents_restoreScopeMessage,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, EditScope.thisEventOnly),
            child: Text(l10n.calendar_editThisEventOnly),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, EditScope.allRepeating),
            child: Text(l10n.calendar_editAllRepeating),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.calendar_cancel),
          ),
        ],
      ),
    );
  }

  Future<void> _permanentlyDelete(PlannedEvent event) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AuroraTheme.spaceBlue,
        title: Text(
          l10n.deletedEvents_permanentDeleteTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l10n.deletedEvents_permanentDeleteMessage,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.calendar_cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.common_delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final isRepeating = event.repeat != RepeatType.none || event.id.contains('_');
    if (isRepeating) {
      await DeletedEventsService.permanentlyDeleteWithRelated(event.id);
    } else {
      await DeletedEventsService.permanentlyDelete(event.id);
    }

    await _loadDeletedEvents();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.deletedEvents_deleted)),
      );
    }
  }

  Future<void> _clearOldEvents() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AuroraTheme.spaceBlue,
        title: Text(
          l10n.deletedEvents_clearOldTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l10n.deletedEvents_clearOldMessage,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.calendar_cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.common_delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final deletedCount = await DeletedEventsService.clearOldEvents();
    await _loadDeletedEvents();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.deletedEvents_clearedCount(deletedCount)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.deletedEvents_title),
        actions: [
          if (_deletedEvents.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: l10n.deletedEvents_clearOld,
              onPressed: _clearOldEvents,
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AuroraTheme.blueGradient),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AuroraTheme.neonBlue))
            : _deletedEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.delete_outline, size: 64, color: Colors.white38),
                        const SizedBox(height: 16),
                        Text(
                          l10n.deletedEvents_empty,
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _deletedEvents.length,
                    itemBuilder: (context, index) {
                      final event = _deletedEvents[index];
                      return _DeletedEventCard(
                        event: event,
                        onRestore: () => _restoreEvent(event),
                        onDelete: () => _permanentlyDelete(event),
                      );
                    },
                  ),
      ),
    );
  }
}

class _DeletedEventCard extends StatelessWidget {
  final PlannedEvent event;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const _DeletedEventCard({
    required this.event,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return FutureBuilder<DateTime?>(
      future: DeletedEventsService.getDeletedAt(event.id),
      builder: (context, snapshot) {
        final deletedAt = snapshot.data;
        
        return AuroraTheme.glassCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      event.type == TransactionType.income
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: event.type == TransactionType.income
                          ? Colors.green
                          : Colors.redAccent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.name ?? 
                        (event.type == TransactionType.income
                            ? l10n.transaction_income
                            : l10n.transaction_expense),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      formatAmountUi(context, event.amount),
                      style: TextStyle(
                        color: event.type == TransactionType.income
                            ? Colors.green
                            : Colors.redAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.white60),
                    const SizedBox(width: 4),
                    Text(
                      LocalizedDateFormatter.formatDateTime(context, event.dateTime),
                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                    if (deletedAt != null) ...[
                      const SizedBox(width: 16),
                      const Icon(Icons.delete, size: 14, color: Colors.white60),
                      const SizedBox(width: 4),
                      Text(
                        '${l10n.deletedEvents_deletedAt} ${LocalizedDateFormatter.formatDateTime(context, deletedAt)}',
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onRestore,
                        icon: const Icon(Icons.restore, size: 18),
                        label: Text(l10n.deletedEvents_restore),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AuroraTheme.neonBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_forever, size: 18),
                        label: Text(l10n.deletedEvents_deletePermanent),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
