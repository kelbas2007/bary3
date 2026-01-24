import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/planned_event.dart';
import '../models/transaction.dart';
import '../models/bari_memory.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/money_ui.dart';
import '../models/piggy_bank.dart';
import '../domain/finance_rules.dart';
import '../theme/aurora_theme.dart';
import 'plan_event_screen.dart';
import '../state/planned_events_notifier.dart';
import '../state/providers.dart';
import '../state/piggy_banks_notifier.dart';
import '../widgets/async_error_widget.dart';
import '../l10n/app_localizations.dart';
import '../utils/date_formatter.dart';
import '../services/deleted_events_service.dart';
import '../models/edit_scope.dart';
import '../utils/repeating_events_helper.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<PlannedEvent> _events = [];
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _checkMissedEvents().then(
      (_) => ref.read(plannedEventsProvider.notifier).refresh(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadEvents() async {
    if (!mounted) return;
    await ref.read(plannedEventsProvider.notifier).refresh();
    if (mounted) {
      setState(() {});
    }
  }

  List<PlannedEvent> _getEventsForDay(DateTime day) {
    return _events.where((event) {
      return event.dateTime.year == day.year &&
          event.dateTime.month == day.month &&
          event.dateTime.day == day.day;
    }).toList();
  }

  // Статистика месяца
  Map<String, int> _getMonthStats() {
    int income = 0;
    int expense = 0;
    int planned = 0;
    int completed = 0;

    for (final event in _events) {
      // Убрали canceled события - они теперь в корзине при удалении
      // if (event.status == PlannedEventStatus.canceled) {
      //   continue;
      // }
      if (event.dateTime.year == _focusedDay.year &&
          event.dateTime.month == _focusedDay.month) {
        if (event.type == TransactionType.income) {
          income += event.amount;
        } else {
          expense += event.amount;
        }
        if (event.status == PlannedEventStatus.planned) {
          planned++;
        } else if (event.status == PlannedEventStatus.completed) {
          completed++;
        }
      }
    }

    return {
      'income': income,
      'expense': expense,
      'planned': planned,
      'completed': completed,
    };
  }

  @override
  Widget build(BuildContext context) {
    final allEventsAsync = ref.watch(plannedEventsProvider);

    if (allEventsAsync.hasError) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.common_calendar),
        ),
        body: AsyncErrorWidget(
          error: allEventsAsync.error!,
          stackTrace: allEventsAsync.stackTrace,
          onRetry: () => ref.read(plannedEventsProvider.notifier).refresh(),
        ),
      );
    }

    // Показываем загрузку только если нет данных (первая загрузка)
    // Если есть старое значение, показываем его во время обновления
    if (allEventsAsync.isLoading && !allEventsAsync.hasValue) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(context),
        body: Container(
          decoration: const BoxDecoration(gradient: AuroraTheme.blueGradient),
          child: const SafeArea(
            child: Center(
              child: CircularProgressIndicator(color: AuroraTheme.neonBlue),
            ),
          ),
        ),
      );
    }

    // Если есть ошибка, показываем её
    if (allEventsAsync.hasError) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.common_calendar),
        ),
        body: AsyncErrorWidget(
          error: allEventsAsync.error!,
          stackTrace: allEventsAsync.stackTrace,
          onRetry: () => ref.read(plannedEventsProvider.notifier).refresh(),
        ),
      );
    }

    // Используем старое значение, если есть, даже во время обновления
    final allEvents =
        allEventsAsync.value ??
        (allEventsAsync.hasValue
            ? allEventsAsync.requireValue
            : const <PlannedEvent>[]);
    final now = DateTime.now();
    _events = allEvents
        .where(
          (e) =>
              e.status == PlannedEventStatus.planned ||
              e.status == PlannedEventStatus.missed ||
              (e.status == PlannedEventStatus.completed &&
                  e.dateTime.isAfter(now.subtract(const Duration(days: 30)))),
          // Убрали canceled события - они теперь в корзине при удалении
        )
        .toList();

    final dayEvents = _getEventsForDay(_selectedDay);
    final monthStats = _getMonthStats();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Container(
        decoration: const BoxDecoration(gradient: AuroraTheme.blueGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Месячная статистика
              _MonthStatsBar(
                income: monthStats['income']!,
                expense: monthStats['expense']!,
                planned: monthStats['planned']!,
                completed: monthStats['completed']!,
              ),

              // Календарь
              _buildCalendar(),

              // Разделитель с датой
              _buildDateHeader(),

              // Список событий
              Expanded(
                child: dayEvents.isEmpty
                    ? _AnimatedEmptyState(
                        selectedDay: _selectedDay,
                        isFirstEvent: _events.isEmpty,
                        onAddPlan: _openPlanScreen,
                      )
                    : _buildEventsList(dayEvents),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          const Icon(Icons.calendar_month, color: AuroraTheme.neonBlue),
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(context)!.common_calendar,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        // Переключатель формата
        IconButton(
          icon: Icon(
            _calendarFormat == CalendarFormat.month
                ? Icons.view_week
                : Icons.calendar_view_month,
            color: Colors.white70,
          ),
          tooltip: _calendarFormat == CalendarFormat.month ? 'Неделя' : 'Месяц',
          onPressed: () {
            HapticFeedback.lightImpact();
            setState(() {
              _calendarFormat = _calendarFormat == CalendarFormat.month
                  ? CalendarFormat.week
                  : CalendarFormat.month;
            });
          },
        ),
        // Сегодня
        IconButton(
          icon: const Icon(Icons.today, color: Colors.white70),
          tooltip: 'Сегодня',
          onPressed: () {
            HapticFeedback.lightImpact();
            setState(() {
              _focusedDay = DateTime.now();
              _selectedDay = DateTime.now();
            });
          },
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AuroraTheme.spaceBlue.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: TableCalendar<PlannedEvent>(
          firstDay: DateTime.utc(2020),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: _getEventsForDay,
          onDaySelected: (selectedDay, focusedDay) {
            HapticFeedback.selectionClick();
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          calendarStyle: CalendarStyle(
            // Сегодня
            todayDecoration: BoxDecoration(
              color: AuroraTheme.neonBlue.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(color: AuroraTheme.neonBlue, width: 2),
            ),
            todayTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            // Выбранный день
            selectedDecoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AuroraTheme.neonBlue, AuroraTheme.neonPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            selectedTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            // Обычные дни
            defaultTextStyle: const TextStyle(color: Colors.white),
            weekendTextStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
            ),
            outsideDaysVisible: false,
            // Маркеры
            markersMaxCount: 1,
            markerSize: 0, // Скрываем стандартные маркеры
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white70),
            rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white70),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            weekendStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isEmpty) return null;
              return _buildDayMarker(events);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDayMarker(List<PlannedEvent> events) {
    final hasIncome = events.any((e) => e.type == TransactionType.income);
    final hasExpense = events.any((e) => e.type == TransactionType.expense);
    final hasPlanned = events.any(
      (e) => e.status == PlannedEventStatus.planned,
    );

    Color markerColor;
    if (hasIncome && hasExpense) {
      markerColor = AuroraTheme.neonYellow;
    } else if (hasIncome) {
      markerColor = Colors.green;
    } else {
      markerColor = Colors.redAccent;
    }

    return Positioned(
      bottom: 4,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: markerColor,
              shape: BoxShape.circle,
              boxShadow: hasPlanned
                  ? [
                      BoxShadow(
                        color: markerColor.withValues(alpha: 0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
          if (events.length > 1) ...[
            const SizedBox(width: 2),
            Text(
              '+${events.length - 1}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateHeader() {
    final isToday = isSameDay(_selectedDay, DateTime.now());
    final dayEvents = _getEventsForDay(_selectedDay);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          // Иконка дня
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isToday
                  ? AuroraTheme.neonBlue.withValues(alpha: 0.2)
                  : AuroraTheme.spaceBlue.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: isToday ? Border.all(color: AuroraTheme.neonBlue) : null,
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('dd').format(_selectedDay),
                  style: TextStyle(
                    color: isToday ? AuroraTheme.neonBlue : Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  LocalizedDateFormatter.formatWeekdayShort(
                    context,
                    _selectedDay,
                  ),
                  style: TextStyle(
                    color: isToday ? AuroraTheme.neonBlue : Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Информация о дне
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday
                      ? 'Сегодня'
                      : DateFormat('d MMMM yyyy', 'ru').format(_selectedDay),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dayEvents.isEmpty
                      ? 'Нет событий'
                      : '${dayEvents.length} ${_pluralize(dayEvents.length, 'событие', 'события', 'событий')}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Быстрое добавление
          IconButton(
            onPressed: _openPlanScreen,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AuroraTheme.neonBlue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add,
                color: AuroraTheme.neonBlue,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(List<PlannedEvent> dayEvents) {
    // Сортируем по времени
    dayEvents.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: dayEvents.length,
      itemBuilder: (context, index) {
        final event = dayEvents[index];
        final isLast = index == dayEvents.length - 1;

        return _TimelineEventCard(
          event: event,
          isLast: isLast,
          onReload: _loadEvents,
        );
      },
    );
  }

  Widget? _buildFAB() {
    return FloatingActionButton(
      heroTag: 'calendar_fab_unique',
      onPressed: _openPlanScreen,
      backgroundColor: AuroraTheme.neonBlue,
      child: const Icon(Icons.add, color: Colors.black),
    );
  }

  void _openPlanScreen() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PlanEventScreen()),
    ).then((_) => _loadEvents());
  }

  String _pluralize(int count, String one, String few, String many) {
    if (count % 10 == 1 && count % 100 != 11) {
      return one;
    }
    if (count % 10 >= 2 &&
        count % 10 <= 4 &&
        (count % 100 < 10 || count % 100 >= 20)) {
      return few;
    }
    return many;
  }

  Future<void> _checkMissedEvents() async {
    final events = await StorageService.getPlannedEvents();
    final now = DateTime.now();
    bool hasChanges = false;

    for (var event in events) {
      if (event.status == PlannedEventStatus.planned &&
          event.dateTime.isBefore(now)) {
        final index = events.indexWhere((e) => e.id == event.id);
        if (index < 0) continue;

        if (event.autoExecute) {
          await _autoExecuteEvent(event, events, index);
          hasChanges = true;
        } else if (event.repeat == RepeatType.none) {
          events[index] = events[index].copyWith(
            status: PlannedEventStatus.missed,
          );
          hasChanges = true;
        }
      }
    }

    if (hasChanges) {
      await StorageService.savePlannedEvents(events);
      ref.read(plannedEventsProvider.notifier).refresh();
    }
  }

  Future<void> _autoExecuteEvent(
    PlannedEvent event,
    List<PlannedEvent> events,
    int index,
  ) async {
    final txRepo = ref.read(transactionsRepositoryProvider);
    final piggyRepo = ref.read(piggyBanksRepositoryProvider);

    final existing = await txRepo.findByPlannedEventId(event.id);
    if (existing != null) {
      events[index] = events[index].copyWith(
        status: PlannedEventStatus.completed,
      );
      await StorageService.savePlannedEvents(events);
      return;
    }

    final requiresApproval = event.source == EventSource.earningsLab
        ? FinanceRules.requiresParentApproval(event.amount)
        : false;

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: event.type,
      amount: event.amount,
      date: DateTime.now(),
      note: event.name ?? 'Автоматическое выполнение',
      category: event.category,
      plannedEventId: event.id,
      source: event.source == EventSource.earningsLab
          ? TransactionSource.earningsLab
          : TransactionSource.plannedEvent,
      parentApproved: event.source == EventSource.earningsLab
          ? !requiresApproval
          : true,
      affectsWallet: event.affectsWallet,
      piggyBankId: event.payoutPiggyBankId,
    );

    await txRepo.add(transaction);

    if (transaction.piggyBankId != null && transaction.parentApproved) {
      final banks = await piggyRepo.fetch();
      final bankIndex = banks.indexWhere(
        (b) => b.id == transaction.piggyBankId,
      );
      if (bankIndex >= 0) {
        final bank = banks[bankIndex];
        final updatedBank = bank.copyWith(
          currentAmount: bank.currentAmount + transaction.amount,
        );
        await piggyRepo.upsert(updatedBank);
        ref.read(piggyBanksProvider.notifier).refresh();
      }
    }

    events[index] = events[index].copyWith(
      status: PlannedEventStatus.completed,
    );

    if (event.repeat != RepeatType.none) {
      await _createNextRepeatEventForAutoExecute(event);
      ref.read(plannedEventsProvider.notifier).refresh();
    }

    final profile = await StorageService.getPlayerProfile();
    final newXP = profile.xp + 15;
    await StorageService.savePlayerProfile(profile.copyWith(xp: newXP));

    final memory = await StorageService.getBariMemory();
    memory.addAction(
      BariAction(
        type: BariActionType.planCompleted,
        timestamp: DateTime.now(),
        amount: event.amount,
      ),
    );
    await StorageService.saveBariMemory(memory);
  }

  Future<void> _createNextRepeatEventForAutoExecute(PlannedEvent event) async {
    DateTime nextDate;
    switch (event.repeat) {
      case RepeatType.daily:
        nextDate = event.dateTime.add(const Duration(days: 1));
        break;
      case RepeatType.weekly:
        nextDate = event.dateTime.add(const Duration(days: 7));
        break;
      case RepeatType.monthly:
        nextDate = DateTime(
          event.dateTime.year,
          event.dateTime.month + 1,
          event.dateTime.day,
          event.dateTime.hour,
          event.dateTime.minute,
        );
        break;
      case RepeatType.yearly:
        nextDate = DateTime(
          event.dateTime.year + 1,
          event.dateTime.month,
          event.dateTime.day,
          event.dateTime.hour,
          event.dateTime.minute,
        );
        break;
      default:
        return;
    }

    final events = await StorageService.getPlannedEvents();
    final existingNext = events.any(
      (e) =>
          e.name == event.name &&
          e.type == event.type &&
          e.repeat == event.repeat &&
          e.dateTime == nextDate &&
          e.status == PlannedEventStatus.planned,
    );

    if (existingNext) return;

    final nextEvent = PlannedEvent(
      id: '${event.id}_${nextDate.millisecondsSinceEpoch}',
      type: event.type,
      amount: event.amount,
      name: event.name,
      category: event.category,
      dateTime: nextDate,
      repeat: event.repeat,
      notificationEnabled: event.notificationEnabled,
      notificationMinutesBefore: event.notificationMinutesBefore,
      source: event.source,
      autoExecute: event.autoExecute,
      payoutPiggyBankId: event.payoutPiggyBankId,
      affectsWallet: event.affectsWallet,
    );

    events.add(nextEvent);
    await StorageService.savePlannedEvents(events);

    if (nextEvent.notificationEnabled) {
      await NotificationService.scheduleEventNotification(nextEvent);
    }
  }
}

// ============================================================================
// ВИДЖЕТЫ
// ============================================================================

/// Статистика месяца
class _MonthStatsBar extends StatelessWidget {
  final int income;
  final int expense;
  final int planned;
  final int completed;

  const _MonthStatsBar({
    required this.income,
    required this.expense,
    required this.planned,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AuroraTheme.spaceBlue.withValues(alpha: 0.6),
            AuroraTheme.spaceBlue.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          // Доходы
          Expanded(
            child: _StatItem(
              icon: Icons.arrow_upward,
              iconColor: Colors.green,
              label: 'Доходы',
              value: formatAmountUi(context, income),
              valueColor: Colors.green,
            ),
          ),
          Container(
            height: 30,
            width: 1,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          // Расходы
          Expanded(
            child: _StatItem(
              icon: Icons.arrow_downward,
              iconColor: Colors.redAccent,
              label: 'Расходы',
              value: formatAmountUi(context, expense),
              valueColor: Colors.redAccent,
            ),
          ),
          Container(
            height: 30,
            width: 1,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          // Прогресс
          Expanded(
            child: _StatItem(
              icon: Icons.check_circle_outline,
              iconColor: AuroraTheme.neonBlue,
              label: 'Выполнено',
              value: '$completed/$planned',
              valueColor: AuroraTheme.neonBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color valueColor;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

/// Анимированное пустое состояние
class _AnimatedEmptyState extends StatefulWidget {
  final DateTime selectedDay;
  final bool isFirstEvent;
  final VoidCallback onAddPlan;

  const _AnimatedEmptyState({
    required this.selectedDay,
    required this.isFirstEvent,
    required this.onAddPlan,
  });

  @override
  State<_AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<_AnimatedEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Иллюстрация
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AuroraTheme.spaceBlue.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AuroraTheme.neonBlue.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    widget.isFirstEvent
                        ? Icons.event_available
                        : Icons.event_busy,
                    size: 56,
                    color: AuroraTheme.neonBlue.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 24),
                // Заголовок
                Text(
                  widget.isFirstEvent
                      ? 'Начни планировать! 🚀'
                      : 'Свободный день',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Описание
                Text(
                  widget.isFirstEvent
                      ? 'Создай первое событие — так проще копить и не забывать о важном'
                      : 'На этот день ничего не запланировано.\nМожет, самое время что-то добавить?',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 15,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Кнопка
                ElevatedButton.icon(
                  onPressed: widget.onAddPlan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AuroraTheme.neonBlue,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: Text(
                    widget.isFirstEvent
                        ? 'Создать первый план'
                        : 'Добавить событие',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Карточка события в стиле Timeline
class _TimelineEventCard extends ConsumerWidget {
  final PlannedEvent event;
  final bool isLast;
  final VoidCallback? onReload;

  const _TimelineEventCard({
    required this.event,
    required this.isLast,
    this.onReload,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = event.status == PlannedEventStatus.completed;
    final isCanceled = event.status == PlannedEventStatus.canceled;
    final isMissed = event.status == PlannedEventStatus.missed;
    final isPlanned = event.status == PlannedEventStatus.planned;
    final isIncome = event.type == TransactionType.income;

    final statusColor = _getStatusColor();
    final typeColor = isIncome ? Colors.green : Colors.redAccent;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline линия
          SizedBox(
            width: 60,
            child: Column(
              children: [
                // Время
                Text(
                  DateFormat('HH:mm').format(event.dateTime),
                  style: TextStyle(
                    color: isCompleted || isCanceled
                        ? Colors.white38
                        : Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                // Точка
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green
                        : isCanceled
                        ? Colors.grey
                        : isMissed
                        ? Colors.orange
                        : typeColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: isPlanned
                        ? [
                            BoxShadow(
                              color: typeColor.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 8, color: Colors.white)
                      : null,
                ),
                // Линия вниз
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
              ],
            ),
          ),
          // Карточка
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AuroraTheme.spaceBlue.withValues(
                  alpha: isCompleted || isCanceled ? 0.2 : 0.4,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isPlanned
                      ? typeColor.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _showEventDetails(context, ref),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Заголовок
                        Row(
                          children: [
                            // Иконка типа
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isIncome
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: isCompleted || isCanceled
                                    ? Colors.grey
                                    : typeColor,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Название и категория
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.name ??
                                        AppLocalizations.of(
                                          context,
                                        )!.calendar_event,
                                    style: TextStyle(
                                      color: isCompleted || isCanceled
                                          ? Colors.white54
                                          : Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      decoration: isCanceled
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  if (event.category != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      event.category!,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.5,
                                        ),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            // Сумма
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${isIncome ? '+' : '-'}${formatAmountUi(context, event.amount)}',
                                  style: TextStyle(
                                    color: isCompleted || isCanceled
                                        ? Colors.grey
                                        : typeColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (event.status != PlannedEventStatus.planned)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _getStatusLabel(),
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        // Кнопки действий для запланированных
                        if (isPlanned) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _ActionButton(
                                  label: 'Выполнено',
                                  icon: Icons.check,
                                  color: Colors.green,
                                  onPressed: () => _completeEvent(context, ref),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _ActionButton(
                                label: '',
                                icon: Icons.edit,
                                color: Colors.white54,
                                onPressed: () {
                                  // Не закрываем bottom sheet здесь - _editEvent сам закроет его
                                  _editEvent(context, ref);
                                },
                                compact: true,
                              ),
                              const SizedBox(width: 8),
                              _ActionButton(
                                label: '',
                                icon: Icons.close,
                                color: Colors.redAccent,
                                onPressed: () => _cancelEvent(context, ref),
                                compact: true,
                              ),
                            ],
                          ),
                        ],
                        // Кнопки для пропущенных
                        if (isMissed) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _ActionButton(
                                  label: 'Выполнить сейчас',
                                  icon: Icons.check,
                                  color: Colors.green,
                                  onPressed: () => _completeEvent(context, ref),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _ActionButton(
                                label: '',
                                icon: Icons.refresh,
                                color: AuroraTheme.neonBlue,
                                onPressed: () => _rescheduleEvent(context, ref),
                                compact: true,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (event.status) {
      case PlannedEventStatus.completed:
        return Colors.green;
      case PlannedEventStatus.canceled:
        return Colors.grey;
      case PlannedEventStatus.missed:
        return Colors.orange;
      default:
        return Colors.transparent;
    }
  }

  String _getStatusLabel() {
    switch (event.status) {
      case PlannedEventStatus.completed:
        return 'Выполнено';
      case PlannedEventStatus.canceled:
        return 'Отменено';
      case PlannedEventStatus.missed:
        return 'Пропущено';
      default:
        return '';
    }
  }

  Future<void> _showEventDetails(BuildContext context, WidgetRef ref) async {
    HapticFeedback.lightImpact();
    // Сохраняем ref для использования в колбэках
    final currentRef = ref;

    // Используем enum для результата (или строку)
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AuroraTheme.spaceBlue,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => _EventDetailsSheet(
        event: event,
        onComplete: () => _completeEvent(context, currentRef),
        onEdit: () {
          // Возвращаем результат вместо прямого вызова
          Navigator.pop(sheetContext, 'edit');
        },
        onCancel: () => _cancelEvent(context, currentRef),
        onReschedule: () => _rescheduleEvent(context, currentRef),
        onDelete: () => _deleteEvent(context, currentRef),
      ),
    );

    // Обрабатываем результат после полного закрытия шторки
    if (result == 'edit' && context.mounted) {
      // Шторка закрыта, контекст CalendarScreen стабилен
      _editEvent(context, currentRef);
    }
  }

  Future<void> _completeEvent(BuildContext context, WidgetRef ref) async {
    if (!context.mounted) return;

    if (event.status == PlannedEventStatus.completed) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.calendar_eventAlreadyCompleted,
            ),
          ),
        );
      }
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _CompleteEventDialog(event: event),
    );

    if (result == null || !context.mounted) return;

    final finalAmount = result['amount'] as int;
    final confirmed = result['confirmed'] as bool;

    if (!confirmed) return;

    final events = await StorageService.getPlannedEvents();
    final currentEvent = events.firstWhere(
      (e) => e.id == event.id,
      orElse: () => event,
    );

    if (currentEvent.status == PlannedEventStatus.completed) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.calendar_eventAlreadyCompleted,
            ),
          ),
        );
      }
      return;
    }

    String? payoutPiggyBankId;
    bool affectsWallet = true;

    if (event.source == EventSource.earningsLab) {
      payoutPiggyBankId = currentEvent.payoutPiggyBankId;
      affectsWallet = currentEvent.affectsWallet;

      if (payoutPiggyBankId == null && !affectsWallet) {
        if (!context.mounted) return;
        final destination = await showDialog<String>(
          context: context,
          builder: (context) => _EarningsDestinationDialog(amount: finalAmount),
        );
        if (destination == null) return;

        if (destination == 'piggy') {
          final banks = await StorageService.getPiggyBanks();
          if (banks.isEmpty) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.calendar_noPiggyBanks,
                ),
              ),
            );
            return;
          }
          if (!context.mounted) return;
          final selectedBank = await showDialog<PiggyBank>(
            context: context,
            builder: (context) => _PiggyBankPickerDialog(banks: banks),
          );
          if (selectedBank == null) return;
          payoutPiggyBankId = selectedBank.id;
          affectsWallet = false;
        } else {
          affectsWallet = true;
        }
      }
    }

    final requiresApproval = FinanceRules.requiresParentApproval(finalAmount);
    final parentApproved = event.source == EventSource.earningsLab
        ? !requiresApproval
        : true;

    final txRepo = ref.read(transactionsRepositoryProvider);
    final piggyRepo = ref.read(piggyBanksRepositoryProvider);

    final existingTx = await txRepo.findByPlannedEventId(event.id);
    if (existingTx != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!.calendar_eventAlreadyCompletedWithTx,
            ),
          ),
        );
      }
      return;
    }

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: event.type,
      amount: finalAmount,
      date: DateTime.now(),
      note: event.name != null
          ? (event.name!.startsWith('Earnings: ')
                ? event.name!.substring(10)
                : event.name!)
          : 'Заработок',
      category: event.category,
      plannedEventId: event.id,
      source: event.source == EventSource.earningsLab
          ? TransactionSource.earningsLab
          : TransactionSource.plannedEvent,
      parentApproved: parentApproved,
      affectsWallet: affectsWallet,
      piggyBankId: payoutPiggyBankId,
    );
    await txRepo.add(transaction);

    if (payoutPiggyBankId != null && parentApproved) {
      final banks = await piggyRepo.fetch();
      final bankIndex = banks.indexWhere((b) => b.id == payoutPiggyBankId);
      if (bankIndex >= 0) {
        final bank = banks[bankIndex];
        final updatedBank = bank.copyWith(
          currentAmount: bank.currentAmount + finalAmount,
        );
        await piggyRepo.upsert(updatedBank);
        if (context.mounted) {
          ref.read(piggyBanksProvider.notifier).refresh();
        }
      }
    }

    final eventIndex = events.indexWhere((e) => e.id == event.id);
    if (eventIndex >= 0) {
      events[eventIndex] = events[eventIndex].copyWith(
        status: PlannedEventStatus.completed,
      );
      await StorageService.savePlannedEvents(events);
    }

    if (event.repeat != RepeatType.none) {
      await _createNextRepeatEvent(event);
    }

    final profile = await StorageService.getPlayerProfile();
    final newXP = profile.xp + 15;
    await StorageService.savePlayerProfile(profile.copyWith(xp: newXP));

    final memory = await StorageService.getBariMemory();
    memory.addAction(
      BariAction(
        type: BariActionType.planCompleted,
        timestamp: DateTime.now(),
        amount: finalAmount,
      ),
    );
    await StorageService.saveBariMemory(memory);

    if (!context.mounted) return;

    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.calendar_eventCompletedXp),
          ],
        ),
        backgroundColor: AuroraTheme.spaceBlue,
      ),
    );
    onReload?.call();
  }

  Future<void> _createNextRepeatEvent(PlannedEvent event) async {
    DateTime nextDate;
    switch (event.repeat) {
      case RepeatType.daily:
        nextDate = event.dateTime.add(const Duration(days: 1));
        break;
      case RepeatType.weekly:
        nextDate = event.dateTime.add(const Duration(days: 7));
        break;
      case RepeatType.monthly:
        nextDate = DateTime(
          event.dateTime.year,
          event.dateTime.month + 1,
          event.dateTime.day,
          event.dateTime.hour,
          event.dateTime.minute,
        );
        break;
      case RepeatType.yearly:
        nextDate = DateTime(
          event.dateTime.year + 1,
          event.dateTime.month,
          event.dateTime.day,
          event.dateTime.hour,
          event.dateTime.minute,
        );
        break;
      default:
        return;
    }

    final events = await StorageService.getPlannedEvents();
    final existingNext = events.any(
      (e) =>
          e.name == event.name &&
          e.type == event.type &&
          e.repeat == event.repeat &&
          e.dateTime == nextDate &&
          e.status == PlannedEventStatus.planned,
    );

    if (existingNext) return;

    final nextEvent = PlannedEvent(
      id: '${event.id}_${nextDate.millisecondsSinceEpoch}',
      type: event.type,
      amount: event.amount,
      name: event.name,
      category: event.category,
      dateTime: nextDate,
      repeat: event.repeat,
      notificationEnabled: event.notificationEnabled,
      notificationMinutesBefore: event.notificationMinutesBefore,
      source: event.source,
      autoExecute: event.autoExecute,
      payoutPiggyBankId: event.payoutPiggyBankId,
      affectsWallet: event.affectsWallet,
    );

    events.add(nextEvent);
    await StorageService.savePlannedEvents(events);

    if (nextEvent.notificationEnabled) {
      await NotificationService.scheduleEventNotification(nextEvent);
    }
  }

  /// Показать диалог выбора области редактирования
  Future<EditScope?> _showEditScopeDialog(
    BuildContext context,
    bool isRepeating,
  ) async {
    try {
      // Проверяем контекст сразу
      if (!context.mounted) {
        return EditScope.thisEventOnly;
      }

      if (!isRepeating) {
        return EditScope.thisEventOnly;
      }

      final l10n = AppLocalizations.of(context);
      if (l10n == null) {
        return EditScope.thisEventOnly;
      }

      // Используем Completer для безопасного получения результата
      final completer = Completer<EditScope?>();

      // Показываем диалог в следующем кадре для гарантии готовности контекста
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        if (!context.mounted) {
          completer.complete(EditScope.thisEventOnly);
          return;
        }

        try {
          final dialogResult = await showDialog<EditScope>(
            context: context,
            barrierColor: Colors.black.withValues(alpha: 0.7),
            builder: (dialogContext) {
              return Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + (0.2 * value),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AuroraTheme.spaceBlue, AuroraTheme.inkBlue],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Иконка
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      AuroraTheme.neonBlue,
                                      AuroraTheme.neonBlue.withValues(
                                        alpha: 0.6,
                                      ),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AuroraTheme.neonBlue.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.edit_calendar,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Заголовок
                              Text(
                                l10n.calendar_editScopeTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),

                              // Подзаголовок
                              Text(
                                l10n.calendar_editScopeSubtitle,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),

                              // Опции выбора
                              _EditScopeOption(
                                icon: Icons.event,
                                iconColor: AuroraTheme.neonMint,
                                title: l10n.calendar_editThisEventOnly,
                                description:
                                    l10n.calendar_editThisEventOnlyDesc,
                                onTap: () {
                                  Navigator.pop(
                                    dialogContext,
                                    EditScope.thisEventOnly,
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              _EditScopeOption(
                                icon: Icons.repeat,
                                iconColor: AuroraTheme.neonPurple,
                                title: l10n.calendar_editAllRepeating,
                                description: l10n.calendar_editAllRepeatingDesc,
                                onTap: () {
                                  Navigator.pop(
                                    dialogContext,
                                    EditScope.allRepeating,
                                  );
                                },
                              ),
                              const SizedBox(height: 24),

                              // Кнопка отмены
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(
                                  l10n.calendar_cancel,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );

          completer.complete(dialogResult);
        } catch (e, stackTrace) {
          debugPrint('Error in showDialog: $e');
          debugPrint('Stack trace: $stackTrace');
          completer.complete(EditScope.thisEventOnly);
        }
      });

      // Ждем результат без таймаута, так как пользователь может думать долго
      final result = await completer.future;

      return result;
    } catch (e, stackTrace) {
      debugPrint('Critical error in _showEditScopeDialog: $e');
      debugPrint('Stack trace: $stackTrace');
      return EditScope.thisEventOnly;
    }
  }

  /// Показать диалог выбора области удаления
  Future<EditScope?> _showDeleteScopeDialog(
    BuildContext context,
    bool isRepeating,
  ) async {
    try {
      if (!context.mounted) return EditScope.thisEventOnly;

      if (!isRepeating) {
        return EditScope.thisEventOnly;
      }

      final l10n = AppLocalizations.of(context);
      if (l10n == null) {
        return EditScope.thisEventOnly;
      }

      final completer = Completer<EditScope?>();

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          if (!context.mounted) {
            completer.complete(EditScope.thisEventOnly);
            return;
          }

          final result = await showDialog<EditScope>(
            context: context,
            useRootNavigator: false,
            barrierColor: Colors.black.withValues(alpha: 0.5),
            builder: (context) {
              return AlertDialog(
                backgroundColor: AuroraTheme.spaceBlue,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text(
                  l10n.calendar_deleteScopeTitle,
                  style: const TextStyle(color: Colors.white),
                ),
                content: Text(
                  l10n.calendar_deleteScopeSubtitle,
                  style: const TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      l10n.calendar_cancel,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (context.mounted) {
                        Navigator.pop(context, EditScope.thisEventOnly);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AuroraTheme.neonBlue,
                    ),
                    child: Text(l10n.calendar_editThisEventOnly),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (context.mounted) {
                        Navigator.pop(context, EditScope.allRepeating);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    child: Text(l10n.calendar_editAllRepeating),
                  ),
                ],
              );
            },
          );

          completer.complete(result);
        } catch (e) {
          debugPrint('Error in showDialog: $e');
          completer.complete(EditScope.thisEventOnly);
        }
      });

      final result = await completer.future;
      return result;
    } catch (e) {
      debugPrint('Critical error in _showDeleteScopeDialog: $e');
      return EditScope.thisEventOnly;
    }
  }

  Future<void> _editEvent(BuildContext context, WidgetRef ref) async {
    // 1. Проверки
    if (!context.mounted) return;

    // 2. Получаем необходимые данные
    final eventsNotifier = ref.read(plannedEventsProvider.notifier);
    final eventToEdit = event;
    final isRepeating =
        RepeatingEventsHelper.isRepeatingInstance(event) ||
        RepeatingEventsHelper.isRepeatingSeries(event);

    // 3. Диалог выбора области (только если повторяющееся)
    EditScope? scope = EditScope.thisEventOnly;

    if (isRepeating) {
      // Используем rootNavigator: true для диалога, чтобы он был поверх всего
      // Но вызываем из текущего контекста, так как шторка уже закрыта
      scope = await _showEditScopeDialog(context, isRepeating);

      if (scope == null) return;
    }

    if (!context.mounted) return;

    // 4. Навигация на экран редактирования
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PlanEventScreen(editingEvent: eventToEdit, editScope: scope!),
      ),
    );

    // 5. Обновление данных после возврата
    if (result == true) {
      // Небольшая задержка, чтобы анимация возврата завершилась
      // и экран успел перерисоваться перед обновлением тяжелых данных
      await Future.delayed(const Duration(milliseconds: 100));

      await eventsNotifier.refresh();

      if (onReload != null) {
        onReload!();
      }
    }
  }

  Future<void> _rescheduleEvent(BuildContext context, WidgetRef ref) async {
    if (!context.mounted) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _RescheduleEventDialog(event: event),
    );

    if (result == null) return;

    final newDate = result['date'] as DateTime;
    final notificationEnabled = result['notification'] as bool;

    final events = await StorageService.getPlannedEvents();
    final index = events.indexWhere((e) => e.id == event.id);
    if (index >= 0) {
      if (event.notificationEnabled) {
        await NotificationService.cancelEventNotification(event.id);
      }

      events[index] = events[index].copyWith(
        dateTime: newDate,
        notificationEnabled: notificationEnabled,
      );
      await StorageService.savePlannedEvents(events);

      if (notificationEnabled) {
        await NotificationService.scheduleEventNotification(events[index]);
      }

      final memory = await StorageService.getBariMemory();
      memory.addAction(
        BariAction(type: BariActionType.planCreated, timestamp: DateTime.now()),
      );
      await StorageService.saveBariMemory(memory);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.calendar_planContinues),
          ),
        );
        try {
          await ref.read(plannedEventsProvider.notifier).refresh();
        } catch (e) {
          debugPrint('Error refreshing events: $e');
        }
        onReload?.call();
      } else {
        // Если контекст не доступен, все равно обновляем данные
        try {
          await ref.read(plannedEventsProvider.notifier).refresh();
        } catch (e) {
          debugPrint('Error refreshing events: $e');
        }
        onReload?.call();
      }
    }
  }

  Future<void> _cancelEvent(BuildContext context, WidgetRef ref) async {
    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AuroraTheme.spaceBlue,
        title: Text(
          AppLocalizations.of(context)!.calendar_cancelEvent,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          AppLocalizations.of(context)!.calendar_cancelEventMessage,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.calendar_no),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(AppLocalizations.of(context)!.calendar_yesCancel),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final events = await StorageService.getPlannedEvents();
    final index = events.indexWhere((e) => e.id == event.id);
    if (index >= 0) {
      events[index] = events[index].copyWith(
        status: PlannedEventStatus.canceled,
      );
      await StorageService.savePlannedEvents(events);
    }

    if (event.notificationEnabled) {
      await NotificationService.cancelEventNotification(event.id);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.calendar_eventCancelled),
        ),
      );
      try {
        await ref.read(plannedEventsProvider.notifier).refresh();
      } catch (e) {
        debugPrint('Error refreshing events: $e');
      }
      onReload?.call();
    } else {
      // Если контекст не доступен, все равно обновляем данные
      try {
        await ref.read(plannedEventsProvider.notifier).refresh();
      } catch (e) {
        debugPrint('Error refreshing events: $e');
      }
      onReload?.call();
    }
  }

  Future<void> _deleteEvent(BuildContext context, WidgetRef ref) async {
    debugPrint('=== _deleteEvent STARTED for event: ${event.id} ===');

    // Глобальная обработка ошибок для предотвращения краша приложения
    try {
      // Проверяем контекст в самом начале
      if (!context.mounted) {
        debugPrint('_deleteEvent: ERROR - context not mounted at start');
        return;
      }

      // Определяем, является ли это повторяющимся событием
      final isRepeating =
          event.repeat != RepeatType.none || event.id.contains('_');
      debugPrint('_deleteEvent: isRepeating = $isRepeating');

      // Показываем диалог выбора области удаления
      debugPrint('_deleteEvent: showing delete scope dialog');
      final scope = await _showDeleteScopeDialog(context, isRepeating);
      debugPrint('_deleteEvent: scope result = $scope');

      if (scope == null) {
        debugPrint('_deleteEvent: scope is null - user cancelled');
        return;
      }

      // Проверяем контекст после асинхронной операции
      if (!context.mounted) {
        debugPrint('_deleteEvent: ERROR - context not mounted after dialog');
        return;
      }

      final l10n = AppLocalizations.of(context)!;

      // Показываем диалог подтверждения удаления
      debugPrint('_deleteEvent: showing confirmation dialog');
      final confirmed = await _showDeleteConfirmationDialog(
        context,
        l10n,
        scope,
      );
      debugPrint('_deleteEvent: confirmed = $confirmed');

      if (confirmed != true) {
        debugPrint('_deleteEvent: deletion cancelled by user');
        return;
      }

      // Проверяем контекст после второго диалога
      if (!context.mounted) {
        debugPrint(
          '_deleteEvent: ERROR - context not mounted after confirmation',
        );
        return;
      }

      // Закрываем bottom sheet ДО начала асинхронных операций
      debugPrint('_deleteEvent: closing bottom sheet before operations');
      try {
        // Пытаемся закрыть bottom sheet несколько раз с разными методами
        if (context.mounted) {
          // Метод 1: Прямой вызов Navigator.pop
          if (context.mounted) {
            Navigator.pop(context); // Close bottom sheet
            debugPrint(
              '_deleteEvent: bottom sheet closed successfully (method 1)',
            );
          }

          // Метод 2: Дополнительная проверка через Future.delayed
          await Future.delayed(const Duration(milliseconds: 50));
          if (context.mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
            debugPrint('_deleteEvent: bottom sheet closed (method 2)');
          }
        } else {
          debugPrint(
            '_deleteEvent: context not mounted for bottom sheet close',
          );
        }
      } catch (e) {
        debugPrint('_deleteEvent: error closing bottom sheet: $e');
        // Продолжаем выполнение даже если не удалось закрыть bottom sheet
      }

      // Выполняем удаление в отдельном блоке с задержкой для стабильности UI
      await Future.delayed(const Duration(milliseconds: 150));
      debugPrint('_deleteEvent: delay completed, starting deletion');

      debugPrint('_deleteEvent: getting events from storage');
      final events = await StorageService.getPlannedEvents();
      debugPrint('_deleteEvent: found ${events.length} events');

      // Выполняем удаление
      try {
        if (scope == EditScope.allRepeating) {
          debugPrint('_deleteEvent: deleting all repeating events');
          await _deleteAllRepeatingEvents(events, event);
        } else {
          debugPrint('_deleteEvent: deleting single event');
          await _deleteSingleEvent(events, event);
        }
        debugPrint('_deleteEvent: deletion operation completed successfully');
      } catch (e, stackTrace) {
        debugPrint('_deleteEvent: ERROR during deletion operation: $e');
        debugPrint('_deleteEvent: Stack trace: $stackTrace');

        // Показываем ошибку пользователю, если контекст доступен
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ошибка при удалении: ${e.toString()}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        });
        return;
      }

      // Обновляем данные с проверкой контекста
      debugPrint('_deleteEvent: refreshing events provider');
      try {
        await ref.read(plannedEventsProvider.notifier).refresh();
        debugPrint('_deleteEvent: events provider refreshed successfully');
      } catch (e) {
        debugPrint('_deleteEvent: ERROR refreshing events: $e');
      }

      // Гарантированное обновление UI через принудительный refresh
      debugPrint('_deleteEvent: forcing UI update');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          // Принудительно обновляем провайдеры
          ref.invalidate(plannedEventsProvider);
          debugPrint('_deleteEvent: UI updated via provider invalidation');
        } catch (e) {
          debugPrint('_deleteEvent: error updating UI via provider: $e');
        }
      });

      // Показываем уведомление об успешном удалении
      debugPrint('_deleteEvent: showing success notification');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          _showDeleteSuccessSnackBar(context, l10n, scope, event.id, ref);
          debugPrint('_deleteEvent: success snackbar shown');
        } else {
          debugPrint('_deleteEvent: context not mounted for success snackbar');
        }
      });

      // Вызываем callback для обновления UI
      debugPrint('_deleteEvent: calling onReload callback');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (onReload != null) {
          onReload!();
          debugPrint('_deleteEvent: onReload callback executed');
        }
      });

      debugPrint('=== _deleteEvent COMPLETED successfully ===');
    } catch (e, stackTrace) {
      debugPrint('=== _deleteEvent CRITICAL ERROR: $e ===');
      debugPrint('_deleteEvent: Stack trace: $stackTrace');

      // Критическая ошибка - логируем и пытаемся восстановить UI
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          if (context.mounted) {
            // Пытаемся закрыть все открытые диалоги и bottom sheets
            Navigator.popUntil(context, (route) => route.isFirst);

            final l10n = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.calendar_deleteError),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
            debugPrint('_deleteEvent: error recovery completed');
          }
        } catch (e2) {
          debugPrint('_deleteEvent: Error during error recovery: $e2');
        }
      });
    }
  }

  /// Показать диалог подтверждения удаления
  Future<bool?> _showDeleteConfirmationDialog(
    BuildContext context,
    AppLocalizations l10n,
    EditScope scope,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AuroraTheme.spaceBlue,
        title: Text(
          l10n.calendar_deleteEventConfirm,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          scope == EditScope.allRepeating
              ? l10n.calendar_deleteAllRepeatingConfirm
              : l10n.calendar_deleteAction,
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
  }

  /// Удалить одно событие
  Future<void> _deleteSingleEvent(
    List<PlannedEvent> events,
    PlannedEvent event,
  ) async {
    // Перемещаем событие в корзину
    await DeletedEventsService.moveToTrash(event);

    // Удаляем из основного списка
    final updatedEvents = events.where((e) => e.id != event.id).toList();
    await StorageService.savePlannedEvents(updatedEvents);

    // Отменяем уведомление
    if (event.notificationEnabled) {
      await NotificationService.cancelEventNotification(event.id);
    }
  }

  /// Удалить все повторяющиеся события
  Future<void> _deleteAllRepeatingEvents(
    List<PlannedEvent> events,
    PlannedEvent event,
  ) async {
    try {
      debugPrint('_deleteAllRepeatingEvents started for event: ${event.id}');

      // Перемещаем все связанные события в корзину
      await DeletedEventsService.moveToTrashWithRelated(event, events);

      // Удаляем из основного списка
      final baseId = RepeatingEventsHelper.getBaseEventId(event.id);
      debugPrint('_deleteAllRepeatingEvents: baseId = $baseId');

      if (baseId != null && baseId.isNotEmpty) {
        final relatedEvents = RepeatingEventsHelper.findRelatedEvents(
          events,
          baseId,
        );
        debugPrint(
          '_deleteAllRepeatingEvents: found ${relatedEvents.length} related events',
        );

        final relatedIds = relatedEvents.map((e) => e.id).toSet();

        final updatedEvents = events
            .where((e) => !relatedIds.contains(e.id))
            .toList();
        debugPrint(
          '_deleteAllRepeatingEvents: saving ${updatedEvents.length} events',
        );

        await StorageService.savePlannedEvents(updatedEvents);

        // Отменяем уведомления для всех связанных событий
        for (var e in relatedEvents) {
          if (e.notificationEnabled) {
            try {
              await NotificationService.cancelEventNotification(e.id);
            } catch (e2) {
              debugPrint('Error cancelling notification for ${e.id}: $e2');
            }
          }
        }
      } else {
        // Если baseId не определен, удаляем только это событие
        debugPrint(
          '_deleteAllRepeatingEvents: baseId is null or empty, deleting single event',
        );
        final updatedEvents = events.where((e) => e.id != event.id).toList();
        await StorageService.savePlannedEvents(updatedEvents);

        if (event.notificationEnabled) {
          try {
            await NotificationService.cancelEventNotification(event.id);
          } catch (e2) {
            debugPrint('Error cancelling notification for ${event.id}: $e2');
          }
        }
      }

      debugPrint('_deleteAllRepeatingEvents completed successfully');
    } catch (e, stackTrace) {
      debugPrint('Error in _deleteAllRepeatingEvents: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow; // Пробрасываем ошибку дальше для обработки в _deleteEvent
    }
  }

  /// Показать SnackBar об успешном удалении
  void _showDeleteSuccessSnackBar(
    BuildContext context,
    AppLocalizations l10n,
    EditScope scope,
    String eventId,
    WidgetRef ref,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.calendar_eventDeleted),
        action: SnackBarAction(
          label: l10n.calendar_undo,
          onPressed: () async {
            try {
              // Восстанавливаем событие
              if (scope == EditScope.allRepeating) {
                final restored =
                    await DeletedEventsService.restoreEventWithRelated(eventId);
                final currentEvents = await StorageService.getPlannedEvents();
                currentEvents.addAll(restored);
                await StorageService.savePlannedEvents(currentEvents);
              } else {
                final restored = await DeletedEventsService.restoreEvent(
                  eventId,
                );
                if (restored != null) {
                  final currentEvents = await StorageService.getPlannedEvents();
                  currentEvents.add(restored);
                  await StorageService.savePlannedEvents(currentEvents);
                }
              }
              await ref.read(plannedEventsProvider.notifier).refresh();
            } catch (e) {
              debugPrint('Error restoring event: $e');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.calendar_deleteError),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}

/// Кнопка действия
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool compact;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      );
    }

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Детали события (Bottom Sheet)
class _EventDetailsSheet extends StatelessWidget {
  final PlannedEvent event;
  final VoidCallback onComplete;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final VoidCallback onReschedule;
  final VoidCallback onDelete;

  const _EventDetailsSheet({
    required this.event,
    required this.onComplete,
    required this.onEdit,
    required this.onCancel,
    required this.onReschedule,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isIncome = event.type == TransactionType.income;
    final typeColor = isIncome ? Colors.green : Colors.redAccent;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Индикатор
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // Иконка и название
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                  color: typeColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name ??
                          AppLocalizations.of(context)!.calendar_event,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (event.category != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        event.category!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                '${isIncome ? '+' : '-'}${formatAmountUi(context, event.amount)}',
                style: TextStyle(
                  color: typeColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Детали
          _DetailRow(
            icon: Icons.access_time,
            label: l10n.calendar_dateAndTime,
            value: LocalizedDateFormatter.formatCalendarDateTime(
              context,
              event.dateTime,
            ),
          ),
          if (event.repeat != RepeatType.none)
            _DetailRow(
              icon: Icons.repeat,
              label: l10n.calendar_repeat,
              value: _getRepeatLabel(event.repeat, l10n),
            ),
          const SizedBox(height: 24),
          // Действия
          if (event.status == PlannedEventStatus.planned) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onComplete();
                },
                icon: const Icon(Icons.check),
                label: Text(l10n.calendar_completed),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Просто вызываем onEdit - он сам вернет результат через Navigator.pop
                      onEdit();
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: Text(l10n.calendar_edit),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onCancel();
                    },
                    icon: const Icon(Icons.close, size: 18),
                    label: Text(l10n.calendar_cancel),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          ] else if (event.status == PlannedEventStatus.missed) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onComplete();
                    },
                    icon: const Icon(Icons.check),
                    label: Text(l10n.calendar_completeNow),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onReschedule();
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.calendar_reschedule),
                  ),
                ),
              ],
            ),
          ] else ...[
            OutlinedButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete),
              label: Text(l10n.common_delete),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _getRepeatLabel(RepeatType repeat, AppLocalizations l10n) {
    switch (repeat) {
      case RepeatType.daily:
        return l10n.calendar_everyDay;
      case RepeatType.weekly:
        return l10n.calendar_everyWeek;
      case RepeatType.monthly:
        return l10n.calendar_everyMonth;
      case RepeatType.yearly:
        return l10n.calendar_everyYear;
      default:
        return l10n.calendar_noRepeat;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 20),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ДИАЛОГИ
// ============================================================================

class _CompleteEventDialog extends StatefulWidget {
  final PlannedEvent event;

  const _CompleteEventDialog({required this.event});

  @override
  State<_CompleteEventDialog> createState() => _CompleteEventDialogState();
}

class _CompleteEventDialogState extends State<_CompleteEventDialog> {
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountController.text = (widget.event.amount / 100).toStringAsFixed(0);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AuroraTheme.spaceBlue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Подтвердить выполнение',
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.event.name ?? 'Событие',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white, fontSize: 20),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              labelText: 'Сумма',
              labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              prefixIcon: Icon(
                widget.event.type == TransactionType.income
                    ? Icons.add
                    : Icons.remove,
                color: widget.event.type == TransactionType.income
                    ? Colors.green
                    : Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.common_cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(_amountController.text);
            if (amount == null || amount <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.calendar_invalidAmount,
                  ),
                ),
              );
              return;
            }
            Navigator.pop(context, {
              'amount': (amount * 100).toInt(),
              'confirmed': true,
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: Text(AppLocalizations.of(context)!.calendar_confirm),
        ),
      ],
    );
  }
}

class _RescheduleEventDialog extends StatefulWidget {
  final PlannedEvent event;

  const _RescheduleEventDialog({required this.event});

  @override
  State<_RescheduleEventDialog> createState() => _RescheduleEventDialogState();
}

class _RescheduleEventDialogState extends State<_RescheduleEventDialog> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _notificationEnabled = true;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.event.dateTime;
    _selectedTime = TimeOfDay.fromDateTime(widget.event.dateTime);
    _notificationEnabled = widget.event.notificationEnabled;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AuroraTheme.spaceBlue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Перенести событие',
        style: TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.calendar_today,
                color: AuroraTheme.neonBlue,
              ),
              title: Text(
                AppLocalizations.of(context)!.calendar_date,
                style: const TextStyle(color: Colors.white70),
              ),
              subtitle: Text(
                LocalizedDateFormatter.formatDateShort(context, _selectedDate),
                style: const TextStyle(color: Colors.white),
              ),
              onTap: _selectDate,
            ),
            ListTile(
              leading: const Icon(
                Icons.access_time,
                color: AuroraTheme.neonBlue,
              ),
              title: Text(
                AppLocalizations.of(context)!.calendar_time,
                style: const TextStyle(color: Colors.white70),
              ),
              subtitle: Text(
                _selectedTime.format(context),
                style: const TextStyle(color: Colors.white),
              ),
              onTap: _selectTime,
            ),
            SwitchListTile(
              secondary: const Icon(
                Icons.notifications,
                color: AuroraTheme.neonBlue,
              ),
              title: Text(
                AppLocalizations.of(context)!.calendar_notification,
                style: const TextStyle(color: Colors.white),
              ),
              value: _notificationEnabled,
              onChanged: (value) =>
                  setState(() => _notificationEnabled = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.common_cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final dateTime = DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
              _selectedTime.hour,
              _selectedTime.minute,
            );
            Navigator.pop(context, {
              'date': dateTime,
              'notification': _notificationEnabled,
            });
          },
          child: Text(AppLocalizations.of(context)!.calendar_move),
        ),
      ],
    );
  }
}

class _EarningsDestinationDialog extends StatelessWidget {
  final int amount;

  const _EarningsDestinationDialog({required this.amount});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AuroraTheme.spaceBlue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Куда добавить ${formatAmountUi(context, amount)}?',
        style: const TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DestinationOption(
            icon: Icons.account_balance_wallet,
            title: 'В кошелёк',
            subtitle: 'Доступно для трат',
            onTap: () => Navigator.pop(context, 'wallet'),
          ),
          const SizedBox(height: 8),
          _DestinationOption(
            icon: Icons.savings,
            title: 'В копилку',
            subtitle: 'На цель',
            onTap: () => Navigator.pop(context, 'piggy'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.common_cancel),
        ),
      ],
    );
  }
}

class _DestinationOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DestinationOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AuroraTheme.neonBlue, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}

class _PiggyBankPickerDialog extends StatelessWidget {
  final List<PiggyBank> banks;

  const _PiggyBankPickerDialog({required this.banks});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AuroraTheme.spaceBlue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Выбери копилку',
        style: TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: banks.length,
          itemBuilder: (context, index) {
            final bank = banks[index];
            final progress = bank.targetAmount > 0
                ? bank.currentAmount / bank.targetAmount
                : 0.0;

            return InkWell(
              onTap: () => Navigator.pop(context, bank),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getIconData(bank.icon),
                      color: Color(bank.color),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bank.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white12,
                            valueColor: AlwaysStoppedAnimation(
                              Color(bank.color),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        color: Color(bank.color),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.common_cancel),
        ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'savings':
        return Icons.savings;
      case 'toys':
        return Icons.toys;
      case 'sports_esports':
        return Icons.sports_esports;
      case 'book':
        return Icons.book;
      case 'favorite':
        return Icons.favorite;
      default:
        return Icons.savings;
    }
  }
}

/// Виджет для отображения опции выбора области редактирования
class _EditScopeOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _EditScopeOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AuroraTheme.spaceBlue.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: iconColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Иконка
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              // Текст
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Стрелка
              Icon(
                Icons.arrow_forward_ios,
                color: iconColor.withValues(alpha: 0.6),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
