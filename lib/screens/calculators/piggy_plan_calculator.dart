import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../models/piggy_bank.dart';
import '../../models/planned_event.dart';
import '../../models/transaction.dart';
import '../../services/storage_service.dart';
import '../../services/notification_service.dart';
import '../../services/money_ui.dart';
import '../../theme/aurora_theme.dart';
import '../../utils/money_input_validator.dart';
import '../../widgets/aurora_dialog.dart';
import '../../widgets/aurora_button.dart';
import '../../widgets/aurora_text_field.dart';
import '../../widgets/aurora_calculator_scaffold.dart';

class PiggyPlanCalculator extends StatefulWidget {
  const PiggyPlanCalculator({super.key});

  @override
  State<PiggyPlanCalculator> createState() => _PiggyPlanCalculatorState();
}

class _PiggyPlanCalculatorState extends State<PiggyPlanCalculator> {
  final _targetController = TextEditingController();
  final _currentController = TextEditingController();
  PiggyBank? _selectedPiggyBank;
  List<PiggyBank> piggyBanks = [];

  String _period = 'week';
  DateTime? _targetDate;

  int? _resultMinor;
  int _periodsCount = 0;

  @override
  void initState() {
    super.initState();
    _targetController.addListener(_calculate);
    _currentController.addListener(_calculate);
    _loadPiggyBanks();
  }

  Future<void> _loadPiggyBanks() async {
    final banks = await StorageService.getPiggyBanks();
    if (!mounted) return;
    setState(() {
      piggyBanks = banks;
      if (banks.isNotEmpty) {
        _selectedPiggyBank = banks.first;
        _targetController.text =
            (banks.first.targetAmount / 100).toStringAsFixed(0);
        _currentController.text =
            (banks.first.currentAmount / 100).toStringAsFixed(0);
      }
      _targetDate = DateTime.now().add(const Duration(days: 56));
    });
    _calculate();
  }

  @override
  void dispose() {
    _targetController.removeListener(_calculate);
    _currentController.removeListener(_calculate);
    _targetController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  void _calculate() {
    final targetRes = MoneyInputValidator.validateToMinor(
      _targetController.text,
    );
    if (!targetRes.isValid || targetRes.amountMinor == null) {
      setState(() {
        _resultMinor = null;
        _periodsCount = 0;
      });
      return;
    }
    final currentRes = _currentController.text.trim().isEmpty
        ? null
        : MoneyInputValidator.validateToMinor(_currentController.text);
    final targetMinor = targetRes.amountMinor!;
    final currentMinor =
        currentRes != null && currentRes.isValid && currentRes.amountMinor != null
            ? currentRes.amountMinor!
            : 0;

    final neededMinor = targetMinor - currentMinor;
    if (neededMinor <= 0) {
      setState(() {
        _resultMinor = 0;
        _periodsCount = 0;
      });
      return;
    }

    final date = _targetDate;
    if (date == null) {
      setState(() {
        _resultMinor = null;
        _periodsCount = 0;
      });
      return;
    }

    final now = DateTime.now();
    final normalizedTarget = DateTime(date.year, date.month, date.day);
    final normalizedNow = DateTime(now.year, now.month, now.day);
    final days = normalizedTarget.difference(normalizedNow).inDays;
    if (days <= 0) {
      setState(() {
        _resultMinor = null;
        _periodsCount = 0;
      });
      return;
    }

    final periods = _period == 'week'
        ? (days / 7).ceil()
        : _period == 'month'
            ? (days / 30).ceil()
            : days; // day

    final perPeriodMinor = (neededMinor / periods).ceil();
    setState(() {
      _resultMinor = perPeriodMinor;
      _periodsCount = periods;
    });
  }

  String _formatMinor(int minor) {
    return formatAmountUi(context, minor);
  }

  String _periodLabel(AppLocalizations l10n) {
    switch (_period) {
      case 'day':
        return l10n.period_inADay;
      case 'month':
        return l10n.period_inAMonth;
      default:
        return l10n.period_inAWeek;
    }
  }

  List<DateTime> _previewSchedule(int count) {
    final start = DateTime.now();
    final res = <DateTime>[];
    DateTime d = DateTime(start.year, start.month, start.day);
    for (int i = 0; i < count; i++) {
      d = _period == 'day'
          ? d.add(const Duration(days: 1))
          : _period == 'month'
              ? DateTime(d.year, d.month + 1, d.day)
              : d.add(const Duration(days: 7));
      res.add(d);
    }
    return res;
  }

  Future<void> _createPlan() async {
    if (!mounted || _resultMinor == null || _resultMinor! <= 0) return;
    final l10n = AppLocalizations.of(context)!;
    HapticFeedback.lightImpact();

    final goalName =
        _selectedPiggyBank?.name ?? l10n.goalDateCalculator_defaultGoalName;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AuroraDialog(
        title: l10n.goalDateCalculator_dialogTitle,
        subtitle: l10n.goalDateCalculator_dialogSubtitle,
        icon: Icons.calendar_today,
        iconColor: AuroraTheme.neonBlue,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.goalDateCalculator_dialogContent(goalName),
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
                        l10n.piggyPlanCalculator_dialogContributionAmount(
                          _formatMinor(_resultMinor!),
                        ),
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
                      const Icon(Icons.repeat, color: Colors.white70, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        l10n.goalDateCalculator_dialogFrequency(
                          _periodLabel(l10n),
                        ),
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
            child: Text(l10n.common_cancel),
          ),
          const SizedBox(width: 12),
          AuroraButton(
            text: l10n.common_create,
            icon: Icons.check,
            customColor: AuroraTheme.neonBlue,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final event = PlannedEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: TransactionType.income,
      amount: _resultMinor!,
      name: l10n.goalDateCalculator_eventName(goalName),
      dateTime: DateTime.now().add(
        Duration(
          days: _period == 'week'
              ? 7
              : _period == 'month'
                  ? 30
                  : 1,
        ),
      ),
      repeat: _period == 'week'
          ? RepeatType.weekly
          : _period == 'month'
              ? RepeatType.monthly
              : RepeatType.daily,
      source: EventSource.calculator,
    );

    final events = await StorageService.getPlannedEvents();
    events.add(event);
    await StorageService.savePlannedEvents(events);
    await NotificationService.scheduleEventNotification(event);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.piggyPlanCalculator_planCreatedSnackbar(
              _formatMinor(_resultMinor!),
              _periodLabel(l10n),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activeLocale = Localizations.localeOf(context).languageCode;

    final schedule =
        _resultMinor != null ? _previewSchedule(3) : const <DateTime>[];

    final step =
        (_targetController.text.trim().isNotEmpty ||
            _currentController.text.trim().isNotEmpty)
            ? (_targetDate != null ? 2 : 1)
            : 0;

    return AuroraCalculatorScaffold(
      title: l10n.piggyPlanCalculator_title,
      icon: Icons.savings,
      subtitle: l10n.piggyPlanCalculator_subtitle,
      steps: [
        l10n.piggyPlanCalculator_stepGoal,
        l10n.piggyPlanCalculator_stepDate,
        l10n.piggyPlanCalculator_stepFrequency
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
                  l10n.piggyPlanCalculator_headerSelectGoal,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (piggyBanks.isNotEmpty)
                  DropdownButtonFormField<PiggyBank>(
                     initialValue: _selectedPiggyBank,
                    items: piggyBanks
                        .map(
                          (b) => DropdownMenuItem(
                            value: b,
                            child: Text(
                              b.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _selectedPiggyBank = v;
                        _targetController.text =
                            (v.targetAmount / 100).toStringAsFixed(0);
                        _currentController.text =
                            (v.currentAmount / 100).toStringAsFixed(0);
                      });
                      _calculate();
                    },
                    dropdownColor: AuroraTheme.inkBlue,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.2),
                      labelText: l10n.goalDateCalculator_piggyBankLabel,
                      labelStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                if (piggyBanks.isNotEmpty) const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AuroraTextField(
                        label: l10n.piggyPlanCalculator_goalAmountLabel,
                        controller: _targetController,
                        icon: Icons.flag,
                        iconColor: AuroraTheme.neonYellow,
                        hintText: '0',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AuroraTextField(
                        label: l10n.piggyPlanCalculator_currentAmountLabel,
                        controller: _currentController,
                        icon: Icons.account_balance_wallet,
                        iconColor: Colors.greenAccent,
                        hintText: '0',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.piggyPlanCalculator_headerTargetDate,
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
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      locale: Localizations.localeOf(context),
                      initialDate:
                          _targetDate ?? now.add(const Duration(days: 56)),
                      firstDate: now,
                      lastDate: now.add(const Duration(days: 365 * 3)),
                    );
                    if (picked == null) return;
                    setState(() {
                      _targetDate = picked;
                    });
                    _calculate();
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
                            _targetDate == null
                                ? l10n.piggyPlanCalculator_selectDate
                                : DateFormat(
                                    'd MMM yyyy',
                                    activeLocale,
                                  ).format(_targetDate!),
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
                const SizedBox(height: 20),
                Text(
                  l10n.piggyPlanCalculator_headerFrequency,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'day',
                      label: Text(l10n.period_everyDay),
                    ),
                    ButtonSegment(
                      value: 'week',
                      label: Text(l10n.period_onceAWeek),
                    ),
                    ButtonSegment(
                      value: 'month',
                      label: Text(l10n.period_onceAMonth),
                    ),
                  ],
                  selected: {_period},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _period = newSelection.first;
                    });
                    _calculate();
                  },
                ),
              ],
            ),
          ),
        ),
        if (_resultMinor != null) ...[
          const SizedBox(height: 16),
          AuroraTheme.glassCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.piggyPlanCalculator_result,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _resultMinor == 0
                        ? l10n.goalDateCalculator_goalAlreadyReached
                        : l10n.piggyPlanCalculator_resultSummary(
                            _formatMinor(_resultMinor!),
                            _periodLabel(l10n),
                            _periodsCount,
                          ),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  if (schedule.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      l10n.goalDateCalculator_upcomingDates,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: schedule
                          .map(
                            (d) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AuroraTheme.neonBlue.withValues(
                                  alpha: 0.18,
                                ),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: AuroraTheme.neonBlue.withValues(
                                    alpha: 0.25,
                                  ),
                                ),
                              ),
                              child: Text(
                                DateFormat('d MMM', activeLocale).format(d),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  AuroraButton(
                    text: l10n.piggyPlanCalculator_scheduleFirstContributionButton,
                    icon: Icons.calendar_today,
                    customColor: AuroraTheme.neonBlue,
                    onPressed: _createPlan,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
