import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';
import '../services/currency_scope.dart';
import '../services/money_formatter.dart';
import '../theme/aurora_theme.dart';
import '../l10n/app_localizations.dart';
import '../utils/date_formatter.dart';

class EarningsHistoryScreen extends StatefulWidget {
  const EarningsHistoryScreen({super.key});

  @override
  State<EarningsHistoryScreen> createState() => _EarningsHistoryScreenState();
}

class _EarningsHistoryScreenState extends State<EarningsHistoryScreen> {
  String _filter = 'all'; // 'week', 'month', 'all'
  String _currencyCode = 'EUR';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.earningsHistory_title)),
      body: Container(
        decoration: const BoxDecoration(gradient: AuroraTheme.blueGradient),
        child: FutureBuilder<List<Transaction>>(
          future: _loadEarnings(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final allEarnings = snapshot.data!;
            final filteredEarnings = _filterEarnings(allEarnings);

            if (allEarnings.isEmpty) {
              return const Center(
                child: Text(
                  'Пока нет заработков',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            final monthlyTotal = _calculateMonthlyTotal(allEarnings);
            final allTimeTotal = _calculateAllTimeTotal(allEarnings);
            _currencyCode = CurrencyScope.of(context).currencyCode;
            final topTasks = _getTopTasks(allEarnings);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Фильтры
                  Row(
                    children: [
                      Expanded(
                        child: SegmentedButton<String>(
                          segments: [
                            ButtonSegment(value: 'week', label: Text(AppLocalizations.of(context)!.balance_filterWeek)),
                            ButtonSegment(value: 'month', label: Text(AppLocalizations.of(context)!.balance_filterMonth)),
                            ButtonSegment(value: 'all', label: Text(AppLocalizations.of(context)!.earningsHistory_all)),
                          ],
                          selected: {_filter},
                          onSelectionChanged: (Set<String> newSelection) {
                            setState(() {
                              _filter = newSelection.first;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Итоги
                  AuroraTheme.glassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'В месяц',
                                style: TextStyle(color: Colors.white70),
                              ),
                              Flexible(
                                child: Text(
                                  _formatAmount(monthlyTotal),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Всего',
                                style: TextStyle(color: Colors.white70),
                              ),
                              Flexible(
                                child: Text(
                                  _formatAmount(allTimeTotal),
                                  style: const TextStyle(
                                    color: AuroraTheme.neonYellow,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Топ-3 задания
                  if (topTasks.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Топ-3 задания',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...topTasks
                        .take(3)
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: AuroraTheme.glassCard(
                              child: ListTile(
                                leading: const Icon(
                                  Icons.star,
                                  color: AuroraTheme.neonYellow,
                                ),
                                title: Text(
                                  entry['title'] as String,
                                  style: const TextStyle(color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  'Выполнено ${entry['count']} раз',
                                  style: const TextStyle(color: Colors.white70),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: SizedBox(
                                  width: 80,
                                  child: Text(
                                    _formatAmount(entry['total'] as int),
                                    style: const TextStyle(
                                      color: AuroraTheme.neonYellow,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                  ],

                  const SizedBox(height: 16),
                  const Text(
                    'Все заработки',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (filteredEarnings.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'Нет заработков за выбранный период',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    )
                  else
                    ...filteredEarnings.map(
                      (earning) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AuroraTheme.glassCard(
                          child: ListTile(
                            leading: const Icon(
                              Icons.work,
                              color: AuroraTheme.neonYellow,
                            ),
                            title: Text(
                              earning.note ?? 'Заработок',
                              style: const TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              LocalizedDateFormatter.formatDateShort(context, earning.date),
                              style: const TextStyle(color: Colors.white70),
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: SizedBox(
                              width: 80,
                              child: Text(
                                _formatAmount(earning.amount),
                                style: const TextStyle(
                                  color: AuroraTheme.neonYellow,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<List<Transaction>> _loadEarnings() async {
    final transactions = await StorageService.getTransactions();
    return transactions
        .where(
          (t) =>
              t.type == TransactionType.income &&
              t.source == TransactionSource.earningsLab &&
              t.parentApproved == true,
        ) // Только одобренные заработки
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<Transaction> _filterEarnings(List<Transaction> earnings) {
    final now = DateTime.now();
    switch (_filter) {
      case 'week':
        final weekAgo = now.subtract(const Duration(days: 7));
        return earnings.where((e) => e.date.isAfter(weekAgo)).toList();
      case 'month':
        return earnings
            .where((e) => e.date.year == now.year && e.date.month == now.month)
            .toList();
      case 'all':
      default:
        return earnings;
    }
  }

  List<Map<String, dynamic>> _getTopTasks(List<Transaction> earnings) {
    final taskMap = <String, Map<String, dynamic>>{};

    for (var earning in earnings) {
      final taskTitle = earning.note ?? 'Неизвестно';
      if (!taskMap.containsKey(taskTitle)) {
        taskMap[taskTitle] = {'title': taskTitle, 'count': 0, 'total': 0};
      }
      taskMap[taskTitle]!['count'] = (taskMap[taskTitle]!['count'] as int) + 1;
      taskMap[taskTitle]!['total'] =
          (taskMap[taskTitle]!['total'] as int) + earning.amount;
    }

    final tasks = taskMap.values.toList();
    tasks.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    return tasks;
  }

  int _calculateMonthlyTotal(List<Transaction> earnings) {
    final now = DateTime.now();
    return earnings
        .where(
          (e) =>
              e.date.year == now.year &&
              e.date.month == now.month &&
              e.parentApproved == true,
        ) // Только одобренные
        .fold<int>(0, (sum, e) => sum + e.amount);
  }

  int _calculateAllTimeTotal(List<Transaction> earnings) {
    // earnings уже фильтруются по parentApproved в _loadEarnings
    return earnings.fold<int>(0, (sum, e) => sum + e.amount);
  }

  String _formatAmount(int cents) {
    final locale = Localizations.localeOf(context).toString();
    return formatMoney(
      amountMinor: cents,
      currencyCode: _currencyCode,
      locale: locale,
    );
  }
}
