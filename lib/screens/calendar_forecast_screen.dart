import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/planned_event.dart';
import '../services/storage_service.dart';
import '../services/money_ui.dart';
import '../theme/aurora_theme.dart';
import '../widgets/aurora_calculator_scaffold.dart';
import '../domain/finance_rules.dart';
import '../l10n/app_localizations.dart';
import '../utils/date_formatter.dart';
import '../widgets/spending_chart_widget.dart';
import '../services/currency_scope.dart';

class CalendarForecastScreen extends StatefulWidget {
  const CalendarForecastScreen({super.key});

  @override
  State<CalendarForecastScreen> createState() => _CalendarForecastScreenState();
}

class _DayDelta {
  final DateTime date;
  final int delta;
  _DayDelta({required this.date, required this.delta});
}

class _SparklinePainter extends CustomPainter {
  final List<int> values;
  final Color color;

  _SparklinePainter({required this.values, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || size.width == 0 || size.height == 0) return;
    final minV = values.reduce((a, b) => a < b ? a : b).toDouble();
    final maxV = values.reduce((a, b) => a > b ? a : b).toDouble();
    final range = (maxV - minV).abs() < 1e-6 ? 1.0 : (maxV - minV);

    final dx = size.width / (values.length - 1).clamp(1, 1000000);
    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = dx * i;
      final norm = (values[i] - minV) / range; // 0..1
      final y = size.height - norm * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..isAntiAlias = true;
    canvas.drawPath(path, paint);

    // Точки акцента
    final pointPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < values.length; i++) {
      final x = dx * i;
      final norm = (values[i] - minV) / range;
      final y = size.height - norm * size.height;
      canvas.drawCircle(Offset(x, y), 1.5, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    if (oldDelegate.values.length != values.length) return true;
    for (int i = 0; i < values.length; i++) {
      if (oldDelegate.values[i] != values[i]) return true;
    }
    return oldDelegate.color != color;
  }
}

class _CalendarForecastScreenState extends State<CalendarForecastScreen> {
  int _period = 30; // дни
  int _viewMode = 0; // 0=Сводка, 1=По категориям, 2=По датам, 3=Месячная сетка
  DateTime? _selectedDate;
  DateTime _monthViewDate = DateTime.now(); // Текущий месяц в сетке

  int _currentBalance = 0;
  int _forecastBalance = 0;
  int _totalIncome = 0;
  int _totalExpense = 0;

  // Данные для группировки
  Map<String, int> _categoryExpenses = {};
  Map<String, int> _categoryIncome = {};
  Map<DateTime, int> _dailyBalance = {}; // баланс на каждый день
  Map<DateTime, List<PlannedEvent>> _eventsByDate = {};

  // Агрегированные повторяющиеся события
  List<_AggregatedEvent> _aggregatedEvents = [];
  // Фильтры для режима «Даты»
  int _typeFilter = 0; // 0=все, 1=доходы, 2=расходы
  bool _onlyBig = false; // только суммы >= порога
  String? _categoryFilter; // null=все категории

  Color _colorForDelta(int delta, int maxAbs) {
    if (maxAbs <= 0) {
      return Colors.white.withValues(alpha: 0.08);
    }
    final ratio = (delta.abs() / maxAbs).clamp(0.0, 1.0);
    final baseAlpha = 0.12 + 0.38 * ratio; // 0.12..0.5
    if (delta > 0) {
      return Colors.green.withValues(alpha: baseAlpha);
    } else if (delta < 0) {
      return Colors.redAccent.withValues(alpha: baseAlpha);
    } else {
      return Colors.white.withValues(alpha: 0.08);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Текущий баланс - оптимизировано с использованием fold
    final transactions = await StorageService.getTransactions();
    final balance = transactions
        .where((t) => t.parentApproved && t.affectsWallet)
        .fold<int>(
          0,
          (sum, t) =>
              sum + (t.type == TransactionType.income ? t.amount : -t.amount),
        );

    // Запланированные события
    final events = await StorageService.getPlannedEvents();
    final now = DateTime.now();
    final endDate = now.add(Duration(days: _period));

    // Фильтруем события в период
    final upcoming = events
        .where(
          (e) =>
              e.status == PlannedEventStatus.planned &&
              e.dateTime.isAfter(now) &&
              e.dateTime.isBefore(endDate),
        )
        .toList();

    // Группируем события по датам и агрегируем повторяющиеся
    final eventsByDate = <DateTime, List<PlannedEvent>>{};
    final aggregatedEvents = <_AggregatedEvent>[];
    final categoryExpenses = <String, int>{};
    final categoryIncome = <String, int>{};
    final dailyBalance = <DateTime, int>{};

    int forecast = balance;
    int totalIncome = 0;
    int totalExpense = 0;

    // Группируем повторяющиеся события
    final repeatGroups = <String, List<PlannedEvent>>{};
    final singleEvents = <PlannedEvent>[];

    for (var event in upcoming) {
      if (event.repeat != RepeatType.none) {
        // Группируем по паттерну: тип + сумма + повтор
        final key = '${event.type}_${event.amount}_${event.repeat}';
        if (!repeatGroups.containsKey(key)) {
          repeatGroups[key] = [];
        }
        repeatGroups[key]!.add(event);
      } else {
        singleEvents.add(event);
      }
    }

    // Создаём агрегированные события для повторяющихся
    for (var entry in repeatGroups.entries) {
      final groupEvents = entry.value;
      if (groupEvents.isNotEmpty) {
        final firstEvent = groupEvents.first;
        final count = groupEvents.length;
        final totalAmount = firstEvent.amount * count;

        // Оптимизированное вычисление min/max дат
        DateTime firstDate = groupEvents.first.dateTime;
        DateTime lastDate = groupEvents.first.dateTime;
        for (final e in groupEvents) {
          if (e.dateTime.isBefore(firstDate)) {
            firstDate = e.dateTime;
          }
          if (e.dateTime.isAfter(lastDate)) {
            lastDate = e.dateTime;
          }
        }

        aggregatedEvents.add(
          _AggregatedEvent(
            name: firstEvent.name ?? 'Повторяющееся событие',
            type: firstEvent.type,
            amount: firstEvent.amount,
            totalAmount: totalAmount,
            count: count,
            repeat: firstEvent.repeat,
            category: firstEvent.category,
            firstDate: firstDate,
            lastDate: lastDate,
          ),
        );

        // Добавляем в категории
        final category = firstEvent.category ?? 'Без категории';
        if (firstEvent.type == TransactionType.income) {
          categoryIncome[category] =
              (categoryIncome[category] ?? 0) + totalAmount;
        } else {
          categoryExpenses[category] =
              (categoryExpenses[category] ?? 0) + totalAmount;
        }

        if (firstEvent.type == TransactionType.income) {
          forecast += totalAmount;
          totalIncome += totalAmount;
        } else {
          forecast -= totalAmount;
          totalExpense += totalAmount;
        }
      }
    }

    // Обрабатываем одиночные события - оптимизировано
    for (var event in singleEvents) {
      final date = DateTime(
        event.dateTime.year,
        event.dateTime.month,
        event.dateTime.day,
      );
      eventsByDate.putIfAbsent(date, () => []).add(event);

      final category = event.category ?? 'Без категории';
      final amount = event.amount;
      if (event.type == TransactionType.income) {
        categoryIncome[category] = (categoryIncome[category] ?? 0) + amount;
        forecast += amount;
        totalIncome += amount;
      } else {
        categoryExpenses[category] = (categoryExpenses[category] ?? 0) + amount;
        forecast -= amount;
        totalExpense += amount;
      }
    }

    // Вычисляем баланс на каждый день
    int runningBalance = balance;
    for (int i = 0; i <= _period; i++) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(Duration(days: i));
      final dayEvents = eventsByDate[date] ?? [];

      for (var event in dayEvents) {
        if (event.type == TransactionType.income) {
          runningBalance += event.amount;
        } else {
          runningBalance -= event.amount;
        }
      }

      // Добавляем повторяющиеся события
      for (var agg in aggregatedEvents) {
        if (_isDateInRepeatRange(
          date,
          agg.firstDate,
          agg.lastDate,
          agg.repeat,
        )) {
          if (agg.type == TransactionType.income) {
            runningBalance += agg.amount;
          } else {
            runningBalance -= agg.amount;
          }
        }
      }

      dailyBalance[date] = runningBalance;
    }

    if (mounted) {
      setState(() {
        _currentBalance = balance;
        _forecastBalance = forecast;
        _totalIncome = totalIncome;
        _totalExpense = totalExpense;
        _categoryExpenses = categoryExpenses;
        _categoryIncome = categoryIncome;
        _dailyBalance = dailyBalance;
        _eventsByDate = eventsByDate;
        _aggregatedEvents = aggregatedEvents;
      });
    }
  }

  bool _isDateInRepeatRange(
    DateTime date,
    DateTime first,
    DateTime last,
    RepeatType repeat,
  ) {
    if (date.isBefore(first) || date.isAfter(last)) return false;

    switch (repeat) {
      case RepeatType.daily:
        return true;
      case RepeatType.weekly:
        return date.weekday == first.weekday;
      case RepeatType.monthly:
        return date.day == first.day;
      case RepeatType.yearly:
        return date.month == first.month && date.day == first.day;
      default:
        return false;
    }
  }

  String _getCategoryName(String? category) {
    if (category == null || category.isEmpty) return 'Без категории';
    switch (category) {
      case 'food':
        return 'Еда';
      case 'transport':
        return 'Транспорт';
      case 'entertainment':
        return 'Развлечения';
      case 'other':
        return 'Другое';
      case 'Заработок':
        return 'Заработок';
      default:
        return category;
    }
  }

  String _getRepeatLabel(RepeatType repeat) {
    switch (repeat) {
      case RepeatType.daily:
        return 'Ежедневно';
      case RepeatType.weekly:
        return 'Еженедельно';
      case RepeatType.monthly:
        return 'Ежемесячно';
      case RepeatType.yearly:
        return 'Ежегодно';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _viewMode.clamp(0, 3);
    return AuroraCalculatorScaffold(
      title: AppLocalizations.of(context)!.toolsHub_calendarForecastTitle,
      icon: Icons.event_available,
      subtitle:
          'Смотри, как изменится баланс по планам: сводка, категории и помесячно.',
      steps: const ['Период', 'Режим', 'Просмотр', 'Месяц'],
      activeStep: step,
      children: [
        AuroraTheme.glassCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '1) Период',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(
                      value: 7,
                      label: Text('7 дн', overflow: TextOverflow.ellipsis),
                    ),
                    ButtonSegment(
                      value: 30,
                      label: Text('30 дн', overflow: TextOverflow.ellipsis),
                    ),
                    ButtonSegment(
                      value: 90,
                      label: Text('90 дн', overflow: TextOverflow.ellipsis),
                    ),
                    ButtonSegment(
                      value: 365,
                      label: Text('Год', overflow: TextOverflow.ellipsis),
                    ),
                  ],
                  selected: {_period},
                  onSelectionChanged: (Set<int> newSelection) {
                    setState(() {
                      _period = newSelection.first;
                      _selectedDate = null;
                    });
                    _loadData();
                  },
                ),
                const SizedBox(height: 14),
                const Text(
                  '2) Режим',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SegmentedButton<int>(
                  segments: [
                    ButtonSegment(
                      value: 0,
                      label: Text(
                        AppLocalizations.of(context)!.calendarForecast_summary,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ButtonSegment(
                      value: 1,
                      label: Text(
                        AppLocalizations.of(
                          context,
                        )!.calendarForecast_categories,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ButtonSegment(
                      value: 2,
                      label: Text(
                        AppLocalizations.of(context)!.calendarForecast_dates,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ButtonSegment(
                      value: 3,
                      label: Text(
                        AppLocalizations.of(context)!.calendarForecast_month,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  selected: {_viewMode},
                  onSelectionChanged: (Set<int> newSelection) {
                    setState(() {
                      _viewMode = newSelection.first;
                      if (_viewMode == 3) {
                        _monthViewDate = DateTime.now();
                        _selectedDate = null;
                      }
                    });
                  },
                ),
                if (_viewMode == 2) ...[
                  const SizedBox(height: 14),
                  const Text(
                    'Фильтры',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(
                          AppLocalizations.of(context)!.calendarForecast_all,
                        ),
                        selected: _typeFilter == 0,
                        onSelected: (_) => setState(() => _typeFilter = 0),
                      ),
                      ChoiceChip(
                        label: Text(
                          AppLocalizations.of(context)!.calendarForecast_income,
                        ),
                        selected: _typeFilter == 1,
                        onSelected: (_) => setState(() => _typeFilter = 1),
                      ),
                      ChoiceChip(
                        label: Text(
                          AppLocalizations.of(
                            context,
                          )!.calendarForecast_expenses,
                        ),
                        selected: _typeFilter == 2,
                        onSelected: (_) => setState(() => _typeFilter = 2),
                      ),
                      FilterChip(
                        label: Text(
                          AppLocalizations.of(context)!.calendarForecast_large,
                        ),
                        selected: _onlyBig,
                        onSelected: (v) => setState(() => _onlyBig = v),
                      ),
                      ...({..._categoryExpenses.keys, ..._categoryIncome.keys}
                            ..removeWhere((e) => e.isEmpty))
                          .take(6)
                          .map(
                            (cat) => FilterChip(
                              label: Text(_getCategoryName(cat)),
                              selected: _categoryFilter == cat,
                              onSelected: (v) => setState(
                                () => _categoryFilter = v ? cat : null,
                              ),
                            ),
                          ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Контент в зависимости от режима
        if (_viewMode == 0) _buildSummaryView(),
        if (_viewMode == 1) _buildCategoriesView(),
        if (_viewMode == 2) _buildDatesView(),
        if (_viewMode == 3) _buildMonthGridView(),
      ],
    );
  }

  Widget _buildRiskTips() {
    if (_dailyBalance.length < 2) {
      return const SizedBox.shrink();
    }
    final dates = _dailyBalance.keys.toList()..sort();
    final deltas = <_DayDelta>[];
    for (int i = 1; i < dates.length; i++) {
      final d = dates[i];
      final prev = dates[i - 1];
      final delta = (_dailyBalance[d] ?? 0) - (_dailyBalance[prev] ?? 0);
      deltas.add(_DayDelta(date: d, delta: delta));
    }
    deltas.sort((a, b) => a.delta.compareTo(b.delta));
    final worst = deltas.where((e) => e.delta < 0).take(3).toList();
    if (worst.isEmpty) {
      return Text(
        'Нет рискованных дней — тренд стабильный 👍',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: 12,
        ),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: worst.map((e) {
        final label = DateFormat('dd.MM').format(e.date);
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.25)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  '$label: −${formatAmountUi(context, e.delta.abs())}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Мини-график баланса
  Widget _balanceSparkline({required Map<DateTime, int> series}) {
    final dates = series.keys.toList()..sort();
    final values = dates.map((d) => series[d] ?? 0).toList();
    if (values.isEmpty) return const SizedBox.shrink();
    int minV = values.reduce((a, b) => a < b ? a : b);
    int maxV = values.reduce((a, b) => a > b ? a : b);
    if (minV == maxV) {
      // слегка растянем, чтобы не была плоская линия
      minV -= 1;
      maxV += 1;
    }
    return CustomPaint(
      painter: _SparklinePainter(values: values, color: AuroraTheme.neonYellow),
    );
  }

  Widget _buildSummaryView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Текущий баланс
          AuroraTheme.glassCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Текущий баланс',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatAmountUi(context, _currentBalance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Прогноз баланса
          AuroraTheme.glassCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Через $_period дней',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Icon(
                        _forecastBalance >= _currentBalance
                            ? Icons.trending_up
                            : Icons.trending_down,
                        color: _forecastBalance >= _currentBalance
                            ? AuroraTheme.neonYellow
                            : Colors.redAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatAmountUi(context, _forecastBalance),
                    style: TextStyle(
                      color: _forecastBalance >= _currentBalance
                          ? AuroraTheme.neonYellow
                          : Colors.redAccent,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_forecastBalance != _currentBalance) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Доходы',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            formatAmountUi(context, _totalIncome),
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Расходы',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            formatAmountUi(context, _totalExpense),
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
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
          const SizedBox(height: 16),
          // Мини-график (sparkline) и подсказки по рисковым дням
          if (_dailyBalance.isNotEmpty) ...[
            AuroraTheme.glassCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Тренд баланса',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 80,
                      child: _balanceSparkline(series: _dailyBalance),
                    ),
                    const SizedBox(height: 12),
                    _buildRiskTips(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Агрегированные повторяющиеся события
          if (_aggregatedEvents.isNotEmpty) ...[
            AuroraTheme.glassCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Повторяющиеся события',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._aggregatedEvents.map(
                      (agg) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  agg.type == TransactionType.income
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  color: agg.type == TransactionType.income
                                      ? Colors.green
                                      : Colors.redAccent,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    agg.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_getRepeatLabel(agg.repeat)} × ${agg.count}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${agg.type == TransactionType.income ? '+' : '-'}${formatAmountUi(context, agg.totalAmount)}',
                                  style: TextStyle(
                                    color: agg.type == TransactionType.income
                                        ? Colors.green
                                        : Colors.redAccent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${formatAmountUi(context, agg.amount)} за раз',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoriesView() {
    final allCategories = <String>{};
    allCategories.addAll(_categoryExpenses.keys);
    allCategories.addAll(_categoryIncome.keys);

    if (allCategories.isEmpty) {
      return const Center(
        child: Text(
          'Нет событий с категориями',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Расходы по категориям
          if (_categoryExpenses.isNotEmpty || _categoryIncome.isNotEmpty) ...[
            AuroraTheme.glassCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SpendingChartWidget(
                  categoryExpenses: _categoryExpenses,
                  categoryIncome: _categoryIncome,
                  currencyCode: CurrencyScope.of(context).currencyCode,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          if (_categoryExpenses.isNotEmpty) ...[
            AuroraTheme.glassCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Расходы по категориям',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...[
                      ..._categoryExpenses.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value)),
                    ].map(
                      (entry) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                _getCategoryName(entry.key),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formatAmountUi(context, entry.value),
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Доходы по категориям
          if (_categoryIncome.isNotEmpty) ...[
            AuroraTheme.glassCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Доходы по категориям',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...[
                      ..._categoryIncome.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value)),
                    ].map(
                      (entry) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                _getCategoryName(entry.key),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formatAmountUi(context, entry.value),
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDatesView() {
    final sortedDates = _dailyBalance.keys.toList()..sort();

    return Column(
      children: [
        // Выбор даты
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                _selectedDate != null
                    ? LocalizedDateFormatter.formatMonthYearShort(
                        context,
                        _selectedDate!,
                      )
                    : LocalizedDateFormatter.formatMonthYearShort(
                        context,
                        DateTime.now(),
                      ),
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const Spacer(),
              Text(
                _selectedDate != null
                    ? LocalizedDateFormatter.formatDateShort(
                        context,
                        _selectedDate!,
                      )
                    : 'Выбери дату',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Мини-календарь heatmap
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AuroraTheme.glassCard(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Builder(
                builder: (context) {
                  if (sortedDates.isEmpty) {
                    return const Text(
                      'Нет данных для периода',
                      style: TextStyle(color: Colors.white54),
                    );
                  }
                  final start = sortedDates.first;
                  final end = sortedDates.last;
                  final days = end.difference(start).inDays + 1;
                  int maxAbsDelta = 0;
                  final items = <Widget>[];
                  for (int i = 0; i < days; i++) {
                    final d = DateTime(
                      start.year,
                      start.month,
                      start.day,
                    ).add(Duration(days: i));
                    final prev = d.subtract(const Duration(days: 1));
                    final curBal = _dailyBalance[d] ?? _currentBalance;
                    final prevBal = _dailyBalance[prev] ?? _currentBalance;
                    final delta = curBal - prevBal;
                    if (delta.abs() > maxAbsDelta) maxAbsDelta = delta.abs();
                  }
                  for (int i = 0; i < days; i++) {
                    final d = DateTime(
                      start.year,
                      start.month,
                      start.day,
                    ).add(Duration(days: i));
                    final prev = d.subtract(const Duration(days: 1));
                    final curBal = _dailyBalance[d] ?? _currentBalance;
                    final prevBal = _dailyBalance[prev] ?? _currentBalance;
                    final delta = curBal - prevBal;
                    final hasEvents =
                        (_eventsByDate[d] ?? []).isNotEmpty ||
                        _aggregatedEvents.any(
                          (agg) => _isDateInRepeatRange(
                            d,
                            agg.firstDate,
                            agg.lastDate,
                            agg.repeat,
                          ),
                        );
                    final isSelected =
                        _selectedDate != null &&
                        d.year == _selectedDate!.year &&
                        d.month == _selectedDate!.month &&
                        d.day == _selectedDate!.day;

                    items.add(
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = d;
                          });
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _colorForDelta(delta, maxAbsDelta),
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(
                                    color: AuroraTheme.neonYellow,
                                    width: 2,
                                  )
                                : Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                DateFormat('d').format(d),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (hasEvents)
                                Positioned(
                                  bottom: 4,
                                  right: 4,
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return Wrap(children: items);
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Список дат или детали выбранной даты
        Expanded(
          child: _selectedDate != null
              ? _buildDateDetails(_selectedDate!)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedDates.length,
                  itemBuilder: (context, index) {
                    final date = sortedDates[index];
                    final balance = _dailyBalance[date]!;
                    final dayEvents = _eventsByDate[date] ?? [];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AuroraTheme.glassCard(
                        child: ListTile(
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                DateFormat('dd').format(date),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            DateFormat('EEEE, dd MMMM', 'ru_RU').format(date),
                            style: const TextStyle(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${dayEvents.length} событий',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: SizedBox(
                            width: 100,
                            child: Text(
                              formatAmountUi(context, balance),
                              style: TextStyle(
                                color: balance >= _currentBalance
                                    ? AuroraTheme.neonYellow
                                    : Colors.redAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDateDetails(DateTime date) {
    final balance = _dailyBalance[date] ?? _currentBalance;
    final originalEvents = _eventsByDate[date] ?? [];
    final dayEvents = originalEvents.where((event) {
      if (_typeFilter == 1 && event.type != TransactionType.income) {
        return false;
      }
      if (_typeFilter == 2 && event.type != TransactionType.expense) {
        return false;
      }
      if (_onlyBig &&
          event.amount < FinanceRules.parentApprovalThresholdMinor) {
        return false;
      }
      if (_categoryFilter != null &&
          (event.category ?? '') != _categoryFilter) {
        return false;
      }
      return true;
    }).toList();
    final dayAggregated = _aggregatedEvents
        .where(
          (agg) => _isDateInRepeatRange(
            date,
            agg.firstDate,
            agg.lastDate,
            agg.repeat,
          ),
        )
        .where((agg) {
          if (_typeFilter == 1 && agg.type != TransactionType.income) {
            return false;
          }
          if (_typeFilter == 2 && agg.type != TransactionType.expense) {
            return false;
          }
          if (_onlyBig &&
              agg.amount < FinanceRules.parentApprovalThresholdMinor) {
            return false;
          }
          if (_categoryFilter != null &&
              (agg.category ?? '') != _categoryFilter) {
            return false;
          }
          return true;
        })
        .toList();

    int dayIncome = 0;
    int dayExpense = 0;

    for (var event in dayEvents) {
      if (event.type == TransactionType.income) {
        dayIncome += event.amount;
      } else {
        dayExpense += event.amount;
      }
    }

    for (var agg in dayAggregated) {
      if (agg.type == TransactionType.income) {
        dayIncome += agg.amount;
      } else {
        dayExpense += agg.amount;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuroraTheme.glassCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, dd MMMM yyyy', 'ru_RU').format(date),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Баланс на конец дня',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatAmountUi(context, balance),
                    style: TextStyle(
                      color: balance >= _currentBalance
                          ? AuroraTheme.neonYellow
                          : Colors.redAccent,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (dayIncome > 0 || dayExpense > 0) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Доходы',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                formatAmountUi(context, dayIncome),
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Расходы',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                formatAmountUi(context, dayExpense),
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // События дня
          if (dayEvents.isNotEmpty || dayAggregated.isNotEmpty) ...[
            AuroraTheme.glassCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'События дня',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...dayEvents.map((event) => _buildEventItem(event)),
                    ...dayAggregated.map(
                      (agg) => _buildAggregatedEventItem(agg),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEventItem(PlannedEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            event.type == TransactionType.income
                ? Icons.arrow_upward
                : Icons.arrow_downward,
            color: event.type == TransactionType.income
                ? Colors.green
                : Colors.redAccent,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name ?? 'Событие',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (event.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Text(
                          _getCategoryName(event.category),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    if (event.amount >=
                        FinanceRules.parentApprovalThresholdMinor)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Text(
                          'Крупное',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${event.type == TransactionType.income ? '+' : '-'}${formatAmountUi(context, event.amount)}',
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
    );
  }

  Widget _buildAggregatedEventItem(_AggregatedEvent agg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            agg.type == TransactionType.income
                ? Icons.arrow_upward
                : Icons.arrow_downward,
            color: agg.type == TransactionType.income
                ? Colors.green
                : Colors.redAccent,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agg.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${_getRepeatLabel(agg.repeat)} (${formatAmountUi(context, agg.amount)} за раз)',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${agg.type == TransactionType.income ? '+' : '-'}${formatAmountUi(context, agg.amount)}',
            style: TextStyle(
              color: agg.type == TransactionType.income
                  ? Colors.green
                  : Colors.redAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthGridView() {
    final year = _monthViewDate.year;
    final month = _monthViewDate.month;
    final firstDayOfMonth = DateTime(year, month);
    final lastDayOfMonth = DateTime(year, month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    final monthName = LocalizedDateFormatter.formatMonthYearShort(
      context,
      _monthViewDate,
    );

    final days = <Widget>[];

    for (int i = 0; i < (firstWeekday - 1) % 7; i++) {
      days.add(const SizedBox.shrink());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final balance = _dailyBalance[date];
      final events = _eventsByDate[date] ?? [];
      final hasAggregated = _aggregatedEvents.any(
        (agg) =>
            _isDateInRepeatRange(date, agg.firstDate, agg.lastDate, agg.repeat),
      );

      int delta = 0;
      if (balance != null) {
        final prevDate = date.subtract(const Duration(days: 1));
        final prevBalance = _dailyBalance[prevDate] ?? _currentBalance;
        delta = balance - prevBalance;
      }

      final maxAbs = _dailyBalance.values
          .map((b) => (b - _currentBalance).abs())
          .fold(0, (a, b) => a > b ? a : b)
          .clamp(1, 1000000000);

      final dayColor = _colorForDelta(delta, maxAbs);
      final isSelected =
          _selectedDate != null &&
          _selectedDate!.year == year &&
          _selectedDate!.month == month &&
          _selectedDate!.day == day;

      days.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? AuroraTheme.neonYellow.withValues(alpha: 0.3)
                  : dayColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? AuroraTheme.neonYellow
                    : Colors.white.withValues(alpha: 0.1),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (events.isNotEmpty || hasAggregated)
                  Positioned(
                    bottom: 2,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: AuroraTheme.neonYellow,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        AuroraTheme.glassCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _monthViewDate = DateTime(
                        _monthViewDate.year,
                        _monthViewDate.month - 1,
                      );
                      _selectedDate = null;
                    });
                  },
                ),
                Text(
                  monthName[0].toUpperCase() + monthName.substring(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _monthViewDate = DateTime(
                        _monthViewDate.year,
                        _monthViewDate.month + 1,
                      );
                      _selectedDate = null;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        AuroraTheme.glassCard(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Пн',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    Text(
                      'Вт',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    Text(
                      'Ср',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    Text(
                      'Чт',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    Text(
                      'Пт',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    Text(
                      'Сб',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    Text(
                      'Вс',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 7,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  children: days,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_selectedDate != null) _buildDateDetails(_selectedDate!),
      ],
    );
  }
}

class _AggregatedEvent {
  final String name;
  final TransactionType type;
  final int amount;
  final int totalAmount;
  final int count;
  final RepeatType repeat;
  final String? category;
  final DateTime firstDate;
  final DateTime lastDate;

  _AggregatedEvent({
    required this.name,
    required this.type,
    required this.amount,
    required this.totalAmount,
    required this.count,
    required this.repeat,
    this.category,
    required this.firstDate,
    required this.lastDate,
  });
}
