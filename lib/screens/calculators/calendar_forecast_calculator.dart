import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/transaction.dart';
import '../../models/planned_event.dart';
import '../../services/storage_service.dart';
import '../../services/money_ui.dart';
import '../../theme/aurora_theme.dart';
import '../../domain/finance_rules.dart';
import '../../widgets/aurora_calculator_scaffold.dart';

class CalendarForecastCalculator extends StatefulWidget {
  const CalendarForecastCalculator({super.key});

  @override
  State<CalendarForecastCalculator> createState() =>
      _CalendarForecastCalculatorState();
}

class _CalendarForecastCalculatorState
    extends State<CalendarForecastCalculator> {
  int _period = 30;
  bool _considerPiggyBanks = false;
  bool _onlyScheduled = true;
  int _currentBalance = 0;
  int _forecastBalance = 0;
  List<Map<String, dynamic>> _keyEvents = [];
  int _piggyReserve = 0;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  Future<void> _calculate() async {
    // Текущий баланс
    final transactions = await StorageService.getTransactions();
    int balance = 0;
    for (var t in transactions) {
      if (!t.parentApproved || !t.affectsWallet) continue;
      if (t.type == TransactionType.income) {
        balance += t.amount;
      } else {
        balance -= t.amount;
      }
    }

    int piggyReserve = 0;
    if (_considerPiggyBanks) {
      final piggies = await StorageService.getPiggyBanks();
      piggyReserve = piggies.fold<int>(0, (sum, b) => sum + b.currentAmount);
    }

    // Запланированные события
    final events = await StorageService.getPlannedEvents();
    final endDate = DateTime.now().add(Duration(days: _period));
    final now = DateTime.now();
    final upcoming = events.where((e) {
      if (!e.affectsWallet) return false;
      if (e.dateTime.isBefore(now) || e.dateTime.isAfter(endDate)) return false;
      if (_onlyScheduled) {
        return e.status == PlannedEventStatus.planned;
      }
      // В расширенном режиме считаем все будущие события, кроме отменённых.
      return e.status != PlannedEventStatus.canceled;
    });

    int forecast = balance;
    final keyEvents = <Map<String, dynamic>>[];

    for (var e in upcoming) {
      if (e.type == TransactionType.income) {
        forecast += e.amount;
      } else {
        forecast -= e.amount;
      }

      if (e.amount > FinanceRules.parentApprovalThresholdMinor) {
        // События больше заданного порога
        keyEvents.add({
          'date': e.dateTime,
          'type': e.type,
          'amount': e.amount,
          'name': e.name ?? 'Событие',
        });
      }
    }

    keyEvents.sort(
      (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
    );

    if (!mounted) return;
    setState(() {
      _currentBalance = balance;
      _forecastBalance = forecast;
      _keyEvents = keyEvents;
      _piggyReserve = piggyReserve;
    });
  }

  String _formatMinor(int minor) => formatAmountUi(context, minor);

  @override
  Widget build(BuildContext context) {
    final hasCalculated =
        _currentBalance != 0 || _forecastBalance != 0 || _keyEvents.isNotEmpty;
    return AuroraCalculatorScaffold(
      title: 'Календарный прогноз',
      icon: Icons.trending_up,
      subtitle: 'Показывает будущий баланс по запланированным событиям.',
      steps: const ['Период', 'Правила', 'Итог'],
      activeStep: hasCalculated ? 2 : 0,
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
                  ],
                  selected: {_period},
                  onSelectionChanged: (Set<int> newSelection) {
                    setState(() {
                      _period = newSelection.first;
                    });
                    _calculate();
                  },
                ),
                const SizedBox(height: 18),
                const Text(
                  '2) Правила',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text(
                    'Учитывать копилки',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    _considerPiggyBanks
                        ? 'Добавим деньги в копилках как резерв'
                        : 'Считаем только кошелёк',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  value: _considerPiggyBanks,
                  onChanged: (value) {
                    setState(() {
                      _considerPiggyBanks = value;
                    });
                    _calculate();
                  },
                ),
                SwitchListTile(
                  title: const Text(
                    'Только запланированные',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Если выключить — учитываем все будущие события кроме отменённых',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  value: _onlyScheduled,
                  onChanged: (value) {
                    setState(() {
                      _onlyScheduled = value;
                    });
                    _calculate();
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
                  'Итог',
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
                      'Текущий баланс',
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      _formatMinor(_currentBalance + _piggyReserve),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Через $_period дней',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      _formatMinor(_forecastBalance + _piggyReserve),
                      style: TextStyle(
                        color:
                            (_forecastBalance + _piggyReserve) >=
                                (_currentBalance + _piggyReserve)
                            ? AuroraTheme.neonYellow
                            : Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (_considerPiggyBanks && _piggyReserve > 0) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Резерв в копилках: ${_formatMinor(_piggyReserve)}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_keyEvents.isNotEmpty) ...[
          const SizedBox(height: 16),
          AuroraTheme.glassCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ключевые события',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._keyEvents.map((event) {
                    final type = event['type'] as TransactionType;
                    final amount = event['amount'] as int;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            type == TransactionType.income
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: type == TransactionType.income
                                ? Colors.green
                                : Colors.red,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event['name'] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat(
                                    'dd.MM.yyyy',
                                  ).format(event['date'] as DateTime),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _formatMinor(amount),
                            style: TextStyle(
                              color: type == TransactionType.income
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
