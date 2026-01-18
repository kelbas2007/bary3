import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../models/transaction.dart';
import '../../services/storage_service.dart';
import '../../services/money_ui.dart';
import '../../theme/aurora_theme.dart';
import '../../utils/money_input_validator.dart';
import '../../widgets/aurora_text_field.dart';
import '../../widgets/aurora_calculator_scaffold.dart';

class MonthlyBudgetCalculator extends StatefulWidget {
  const MonthlyBudgetCalculator({super.key});

  @override
  State<MonthlyBudgetCalculator> createState() =>
      _MonthlyBudgetCalculatorState();
}

class _MonthlyBudgetCalculatorState extends State<MonthlyBudgetCalculator> {
  final _limitController = TextEditingController();
  DateTime _selectedMonth = DateTime.now();
  int? _limitMinor;
  int _spentMinor = 0;

  @override
  void initState() {
    super.initState();
    _limitController.addListener(_calculate);
    _loadData();
  }

  Future<void> _loadData() async {
    final transactions = await StorageService.getTransactions();
    final monthStart = DateTime(_selectedMonth.year, _selectedMonth.month);
    final monthEnd = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

    final monthExpenses = transactions.where((t) {
      return t.type == TransactionType.expense &&
          t.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
          t.date.isBefore(monthEnd.add(const Duration(days: 1)));
    });

    final spent = monthExpenses.fold<int>(0, (sum, t) => sum + t.amount);

    if (!mounted) return;

    setState(() {
      _spentMinor = spent;
    });
  }

  @override
  void dispose() {
    _limitController.removeListener(_calculate);
    _limitController.dispose();
    super.dispose();
  }

  void _calculate() {
    final limitRes = MoneyInputValidator.validateToMinor(_limitController.text);
    if (!limitRes.isValid || limitRes.amountMinor == null) {
      setState(() {
        _limitMinor = null;
      });
      return;
    }
    setState(() {
      _limitMinor = limitRes.amountMinor!;
    });
  }

  String _formatMinor(int minor) {
    return formatAmountUi(context, minor);
  }

  int get _remainingMinor => (_limitMinor ?? 0) - _spentMinor;
  double get _progress =>
      _limitMinor != null && _limitMinor! > 0 ? _spentMinor / _limitMinor! : 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activeLocale = Localizations.localeOf(context).languageCode;
    final step = _limitController.text.trim().isNotEmpty ? 2 : 1;

    return AuroraCalculatorScaffold(
      title: l10n.monthlyBudgetCalculator_title,
      icon: Icons.calendar_month,
      subtitle: l10n.monthlyBudgetCalculator_subtitle,
      steps: [
        l10n.monthlyBudgetCalculator_step1,
        l10n.monthlyBudgetCalculator_step2,
        l10n.monthlyBudgetCalculator_step3
      ],
      activeStep: step,
      children: [
        AuroraTheme.glassCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.monthlyBudgetCalculator_selectMonth,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                    borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedMonth,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      locale: Localizations.localeOf(context),
                    );
                    if (picked == null) return;
                    setState(() {
                      _selectedMonth = DateTime(picked.year, picked.month);
                    });
                    await _loadData();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: AuroraTheme.neonBlue,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            DateFormat(
                              'MMMM yyyy',
                              activeLocale,
                            ).format(_selectedMonth),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Icon(Icons.edit, color: Colors.white54, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.monthlyBudgetCalculator_setLimit,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                AuroraTextField(
                  label: l10n.monthlyBudgetCalculator_limitForMonth,
                  controller: _limitController,
                  icon: Icons.account_balance_wallet,
                  iconColor: AuroraTheme.neonBlue,
                  hintText: '0',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_limitMinor != null) ...[
          const SizedBox(height: 16),
          AuroraTheme.glassCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.monthlyBudgetCalculator_result,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.monthlyBudgetCalculator_spent,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        _formatMinor(_spentMinor),
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
                      Text(
                        l10n.monthlyBudgetCalculator_remaining,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        _formatMinor(_remainingMinor.abs()),
                        style: TextStyle(
                          color: _remainingMinor < 0
                              ? Colors.red
                              : AuroraTheme.neonYellow,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  LinearProgressIndicator(
                    value: _progress > 1 ? 1 : _progress,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _progress > 0.8
                          ? Colors.red
                          : _progress > 0.5
                          ? Colors.orange
                          : AuroraTheme.neonYellow,
                    ),
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  if (_progress > 0.8) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        l10n.monthlyBudgetCalculator_warningAlmostLimit,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                  if (_remainingMinor < 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        l10n.monthlyBudgetCalculator_warningOverLimit(
                          _formatMinor(_remainingMinor.abs()),
                        ),
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                        ),
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
