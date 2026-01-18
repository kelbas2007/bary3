import 'package:flutter/material.dart';
import '../../models/planned_event.dart';
import '../../models/transaction.dart';
import '../../utils/repeating_events_helper.dart';
import '../../services/storage_service.dart';
import '../../services/notification_service.dart';
import '../../services/money_ui.dart';
import '../../theme/aurora_theme.dart';
import '../../utils/money_input_validator.dart';
import '../../widgets/aurora_dialog.dart';
import '../../widgets/aurora_button.dart';
import '../../widgets/aurora_calculator_scaffold.dart';
import '../../widgets/aurora_text_field.dart';
import '../../l10n/app_localizations.dart';

class SubscriptionsCalculator extends StatefulWidget {
  const SubscriptionsCalculator({super.key});

  @override
  State<SubscriptionsCalculator> createState() =>
      _SubscriptionsCalculatorState();
}

enum SubscriptionFilter {
  all,
  income,
  expense,
}

class _SubscriptionsCalculatorState extends State<SubscriptionsCalculator> {
  List<Map<String, dynamic>> _subscriptions = [];
  double _monthlyTotal = 0;
  double _yearlyTotal = 0;
  Map<String, dynamic>? _topMonthly;
  SubscriptionFilter _filter = SubscriptionFilter.all;

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  /// Создаёт все повторяющиеся события на год вперёд
  List<PlannedEvent> _createRepeatEvents(PlannedEvent baseEvent) {
    final List<PlannedEvent> repeatEvents = [baseEvent];

    if (baseEvent.repeat == RepeatType.none) {
      return repeatEvents;
    }

    final DateTime endDate = DateTime.now().add(const Duration(days: 365));
    DateTime currentDate = baseEvent.dateTime;

    while (currentDate.isBefore(endDate)) {
      DateTime nextDate;
      switch (baseEvent.repeat) {
        case RepeatType.daily:
          nextDate = currentDate.add(const Duration(days: 1));
          break;
        case RepeatType.weekly:
          nextDate = currentDate.add(const Duration(days: 7));
          break;
        case RepeatType.monthly:
          nextDate = DateTime(
            currentDate.year,
            currentDate.month + 1,
            currentDate.day,
            currentDate.hour,
            currentDate.minute,
          );
          break;
        case RepeatType.yearly:
          nextDate = DateTime(
            currentDate.year + 1,
            currentDate.month,
            currentDate.day,
            currentDate.hour,
            currentDate.minute,
          );
          break;
        default:
          return repeatEvents;
      }

      if (nextDate.isAfter(endDate)) break;

      final event = PlannedEvent(
        id: '${baseEvent.id}_${nextDate.millisecondsSinceEpoch}',
        type: baseEvent.type,
        amount: baseEvent.amount,
        name: baseEvent.name,
        category: baseEvent.category,
        dateTime: nextDate,
        repeat: baseEvent.repeat,
        notificationEnabled: baseEvent.notificationEnabled,
        notificationMinutesBefore: baseEvent.notificationMinutesBefore,
        source: baseEvent.source,
      );

      repeatEvents.add(event);
      currentDate = nextDate;
    }

    return repeatEvents;
  }

  Future<void> _loadSubscriptions() async {
    final events = await StorageService.getPlannedEvents();

    // Группируем повторяющиеся события по базовому ID
    // Базовое событие - то, у которого ID не содержит "_" (не является производным)
    final baseEvents = <String, PlannedEvent>{};
    // Убрали ограничение только на expense - теперь поддерживаем и доходы
    final allRepeatEvents = events.where(
      (e) =>
          e.repeat != RepeatType.none &&
          e.status == PlannedEventStatus.planned,
    );

    for (var event in allRepeatEvents) {
      // Определяем базовый ID
      final baseId = RepeatingEventsHelper.getBaseEventId(event.id);
      if (baseId == null) continue;

      // Если базовое событие ещё не найдено, ищем его
      if (!baseEvents.containsKey(baseId)) {
        final baseEvent = events.firstWhere(
          (e) => e.id == baseId,
          orElse: () => event, // Если базовое не найдено, используем текущее
        );
        baseEvents[baseId] = baseEvent;
      }
    }

    final subs = baseEvents.values.map((e) {
      double monthly = 0;
      switch (e.repeat) {
        case RepeatType.daily:
          monthly = (e.amount / 100) * 30;
          break;
        case RepeatType.weekly:
          monthly =
              (e.amount / 100) *
              4.33; // Более точный расчёт (52 недели / 12 месяцев)
          break;
        case RepeatType.monthly:
          monthly = e.amount / 100;
          break;
        case RepeatType.yearly:
          monthly = (e.amount / 100) / 12;
          break;
        default:
          break;
      }

      return {
        'id': e.id, // Базовый ID
        'name': e.name ?? 'Регулярка',
        'amount': e.amount / 100,
        'period': e.repeat,
        'monthly': monthly,
        'type': e.type, // Сохраняем тип для фильтрации
      };
    }).toList();

    final monthly = subs.fold<double>(
      0,
      (sum, s) => sum + (s['monthly'] as double),
    );
    final yearly = monthly * 12;

    Map<String, dynamic>? top;
    for (final s in subs) {
      if (top == null) {
        top = s;
      } else {
        if ((s['monthly'] as double) > (top['monthly'] as double)) {
          top = s;
        }
      }
    }

    setState(() {
      _subscriptions = subs;
      _monthlyTotal = monthly;
      _yearlyTotal = yearly;
      _topMonthly = top;
    });
    _updateFilteredStats();
  }

  void _updateFilteredStats() {
    final filtered = _filteredSubscriptions;
    
    // Пересчитываем статистику для отфильтрованных подписок
    final monthly = filtered.fold<double>(
      0,
      (sum, s) => sum + (s['monthly'] as double),
    );
    final yearly = monthly * 12;
    
    Map<String, dynamic>? top;
    for (final s in filtered) {
      if (top == null) {
        top = s;
      } else {
        if ((s['monthly'] as double).abs() > (top['monthly'] as double).abs()) {
          top = s;
        }
      }
    }
    
    setState(() {
      _monthlyTotal = monthly;
      _yearlyTotal = yearly;
      _topMonthly = top;
    });
  }

  List<Map<String, dynamic>> get _filteredSubscriptions {
    if (_filter == SubscriptionFilter.income) {
      return _subscriptions.where((s) => s['type'] == TransactionType.income).toList();
    } else if (_filter == SubscriptionFilter.expense) {
      return _subscriptions.where((s) => s['type'] == TransactionType.expense).toList();
    }
    return _subscriptions;
  }

  String _periodName(RepeatType period) {
    switch (period) {
      case RepeatType.daily:
        return 'День';
      case RepeatType.weekly:
        return 'Неделя';
      case RepeatType.monthly:
        return 'Месяц';
      case RepeatType.yearly:
        return 'Год';
      default:
        return '';
    }
  }

  Future<void> _addSubscription() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => __AddSubscriptionDialog(),
    );

    if (result != null) {
      final baseEvent = PlannedEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: TransactionType.expense,
        amount: ((result['amount'] as double) * 100).toInt(),
        name: result['name'] as String,
        dateTime: DateTime.now(),
        repeat: result['repeat'] as RepeatType,
        source: EventSource.manual,
      );

      // Создаём все повторяющиеся события
      final repeatEvents = _createRepeatEvents(baseEvent);

      // Показываем диалог подтверждения с информацией о том, что будет создано
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          final periodLabel = _periodName(
            result['repeat'] as RepeatType,
          ).toLowerCase();
          return AuroraDialog(
            title: 'Подтверждение',
            subtitle: 'Создание подписки',
            icon: Icons.subscriptions,
            iconColor: AuroraTheme.neonBlue,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Будет создано ${repeatEvents.length} запланированных событий для подписки "${result['name'] as String}".',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AuroraTheme.neonBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AuroraTheme.neonBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.attach_money,
                            color: Colors.white70,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Сумма: ${(result['amount'] as double).toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.repeat,
                            color: Colors.white70,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Периодичность: каждую $periodLabel',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(foregroundColor: Colors.white70),
                child: Text(AppLocalizations.of(context)!.common_cancel),
              ),
              const SizedBox(width: 12),
              AuroraButton(
                text: 'Создать',
                icon: Icons.check,
                customColor: AuroraTheme.neonBlue,
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          );
        },
      );

      if (confirmed != true) return;

      final events = await StorageService.getPlannedEvents();
      events.addAll(repeatEvents);
      await StorageService.savePlannedEvents(events);

      // Планируем уведомления для всех событий
      for (var event in repeatEvents) {
        if (event.notificationEnabled) {
          await NotificationService.scheduleEventNotification(event);
        }
      }

      await _loadSubscriptions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Создано ${repeatEvents.length} запланированных событий',
            ),
          ),
        );
      }
    }
  }

  Future<void> _cancelSubscription(String baseId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AuroraDialog(
        title: 'Отменить подписку?',
        subtitle: 'Подтверждение действия',
        icon: Icons.cancel,
        iconColor: Colors.redAccent,
        content: const Text(
          'Все повторяющиеся события будут отменены. Это действие нельзя отменить.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: Colors.white70),
            child: Text(AppLocalizations.of(context)!.subscriptionsCalculator_no),
          ),
          const SizedBox(width: 12),
          AuroraButton(
            text: 'Да, отменить',
            icon: Icons.check,
            customColor: Colors.redAccent,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final events = await StorageService.getPlannedEvents();

    // Находим все события с этим базовым ID (включая производные)
    final toCancel = events
        .where((e) => e.id == baseId || e.id.startsWith('${baseId}_'))
        .toList();

    // Отменяем все связанные события
    for (var event in toCancel) {
      final index = events.indexWhere((e) => e.id == event.id);
      if (index >= 0) {
        events[index] = events[index].copyWith(
          status: PlannedEventStatus.canceled,
        );
        if (event.notificationEnabled) {
          await NotificationService.cancelEventNotification(event.id);
        }
      }
    }

    await StorageService.savePlannedEvents(events);
    await _loadSubscriptions();
  }

  @override
  Widget build(BuildContext context) {
    return AuroraCalculatorScaffold(
      title: 'Подписки и регулярки',
      icon: Icons.subscriptions,
      subtitle:
          'Посмотри, сколько съедают регулярные траты. Можно добавить подписку и сразу запланировать события.',
      steps: const ['Список', 'Итоги', 'Добавить'],
      activeStep: _subscriptions.isEmpty ? 0 : 1,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Добавить подписку',
        onPressed: _addSubscription,
        child: const Icon(Icons.add),
      ),
      children: [
        if (_subscriptions.isEmpty)
          AuroraTheme.glassCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(
                    Icons.subscriptions,
                    color: AuroraTheme.neonBlue,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Пока нет регулярных трат',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Добавь подписки — я посчитаю, сколько они стоят в месяц и в год.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  AuroraButton(
                    text: 'Добавить подписку',
                    icon: Icons.add,
                    customColor: AuroraTheme.neonBlue,
                    onPressed: _addSubscription,
                  ),
                ],
              ),
            ),
          )
        else ...[
          // Фильтр по типу
          AuroraTheme.glassCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.subscriptions_filter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<SubscriptionFilter>(
                    segments: [
                      ButtonSegment(
                        value: SubscriptionFilter.all,
                        label: Text(AppLocalizations.of(context)!.subscriptions_all),
                      ),
                      ButtonSegment(
                        value: SubscriptionFilter.income,
                        label: Text(AppLocalizations.of(context)!.subscriptions_income),
                      ),
                      ButtonSegment(
                        value: SubscriptionFilter.expense,
                        label: Text(AppLocalizations.of(context)!.subscriptions_expense),
                      ),
                    ],
                    selected: {_filter},
                    onSelectionChanged: (Set<SubscriptionFilter> newSelection) {
                      setState(() {
                        _filter = newSelection.first;
                        _updateFilteredStats();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AuroraTheme.glassCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Список подписок',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._filteredSubscriptions.map(
                    (sub) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AuroraTheme.glassCard(
                        child: ListTile(
                          title: Text(
                            sub['name'] as String,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            '${formatAmountUi(context, ((sub['amount'] as double) * 100).toInt())} / ${_periodName(sub['period'] as RepeatType)}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () =>
                                _cancelSubscription(sub['id'] as String),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AuroraTheme.glassCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Итоги',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'В месяц',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        formatAmountUi(context, (_monthlyTotal * 100).toInt()),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'В год',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        formatAmountUi(context, (_yearlyTotal * 100).toInt()),
                        style: const TextStyle(
                          color: AuroraTheme.neonYellow,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (_topMonthly != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AuroraTheme.neonBlue.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AuroraTheme.neonBlue.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.trending_up,
                            color: AuroraTheme.neonBlue,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Самая дорогая в месяц: ${_topMonthly!['name']} (${formatAmountUi(context, ((_topMonthly!['monthly'] as double) * 100).toInt())})',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class __AddSubscriptionDialog extends StatefulWidget {
  @override
  State<__AddSubscriptionDialog> createState() => __AddSubscriptionDialogState();
}

class __AddSubscriptionDialogState extends State<__AddSubscriptionDialog> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  RepeatType _repeat = RepeatType.monthly;
  TransactionType _type = TransactionType.expense;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuroraDialog(
      title: 'Добавить подписку',
      subtitle: 'Создадим регулярный расход в календаре',
      icon: Icons.subscriptions,
      iconColor: AuroraTheme.neonBlue,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuroraTextField(
            label: 'Название (например: _Spotify)',
            controller: _nameController,
            icon: Icons.title,
            iconColor: AuroraTheme.neonBlue,
            hintText: 'Название',
          ),
          const SizedBox(height: 16),
          AuroraTextField(
            label: 'Сумма',
            controller: _amountController,
            icon: Icons.attach_money,
            iconColor: AuroraTheme.neonBlue,
            hintText: '0',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          // Выбор типа (доход/расход)
          Text(
            AppLocalizations.of(context)!.subscriptions_type,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          SegmentedButton<TransactionType>(
            segments: [
              ButtonSegment(
                value: TransactionType.income,
                label: Text(AppLocalizations.of(context)!.subscriptions_income),
                icon: const Icon(Icons.arrow_downward, size: 18),
              ),
              ButtonSegment(
                value: TransactionType.expense,
                label: Text(AppLocalizations.of(context)!.subscriptions_expense),
                icon: const Icon(Icons.arrow_upward, size: 18),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (Set<TransactionType> newSelection) {
              setState(() {
                _type = newSelection.first;
              });
            },
          ),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.subscriptions_frequency, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          SegmentedButton<RepeatType>(
            segments: [
              ButtonSegment(
                value: RepeatType.daily,
                label: Text(AppLocalizations.of(context)!.subscriptionsCalculator_repeatDaily),
              ),
              ButtonSegment(
                value: RepeatType.weekly,
                label: Text(AppLocalizations.of(context)!.subscriptionsCalculator_repeatWeekly),
              ),
              ButtonSegment(
                value: RepeatType.monthly,
                label: Text(AppLocalizations.of(context)!.subscriptionsCalculator_repeatMonthly),
              ),
              ButtonSegment(
                value: RepeatType.yearly,
                label: Text(AppLocalizations.of(context)!.subscriptionsCalculator_repeatYearly),
              ),
            ],
            selected: {_repeat},
            onSelectionChanged: (Set<RepeatType> newSelection) {
              setState(() {
                _repeat = newSelection.first;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: Colors.white70),
          child: Text(AppLocalizations.of(context)!.common_cancel),
        ),
        const SizedBox(width: 12),
        AuroraButton(
          text: 'Добавить',
          icon: Icons.check,
          customColor: AuroraTheme.neonBlue,
          onPressed: () {
            if (_nameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.subscriptionsCalculator_enterSubscriptionName,
                  ),
                ),
              );
              return;
            }
            final amountMinor = MoneyInputValidator.validateAndShowError(
              context,
              _amountController.text,
            );
            if (amountMinor == null) return;
            Navigator.pop(context, {
              'name': _nameController.text.trim(),
              'amount': amountMinor / 100.0,
              'repeat': _repeat,
              'type': _type,
            });
          },
        ),
      ],
    );
  }
}
