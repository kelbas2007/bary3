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

class GoalDateCalculator extends StatefulWidget {
  const GoalDateCalculator({super.key});

  @override
  State<GoalDateCalculator> createState() => _GoalDateCalculatorState();
}

class _GoalDateCalculatorState extends State<GoalDateCalculator> {
  PiggyBank? _selectedPiggyBank;
  List<PiggyBank> _piggyBanks = [];
  final _contributionController = TextEditingController();
  String _period = 'week';
  DateTime? _goalDate;
  int _periodsNeeded = 0;
  int _neededMinor = 0;

  @override
  void initState() {
    super.initState();
    _contributionController.addListener(_calculate);
    _loadPiggyBanks();
  }

  Future<void> _loadPiggyBanks() async {
    final banks = await StorageService.getPiggyBanks();
    if (!mounted) return;
    setState(() {
      _piggyBanks = banks;
      if (banks.isNotEmpty) {
        _selectedPiggyBank = banks.first;
      }
    });
    _calculate();
  }

  @override
  void dispose() {
    _contributionController.removeListener(_calculate);
    _contributionController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (_selectedPiggyBank == null) return;
    final contributionRes = MoneyInputValidator.validateToMinor(
      _contributionController.text,
    );
    if (!contributionRes.isValid ||
        contributionRes.amountMinor == null ||
        contributionRes.amountMinor! <= 0) {
      setState(() {
        _goalDate = null;
        _periodsNeeded = 0;
        _neededMinor = 0;
      });
      return;
    }

    final needed =
        _selectedPiggyBank!.targetAmount - _selectedPiggyBank!.currentAmount;
    if (needed <= 0) {
      setState(() {
        _goalDate = DateTime.now();
        _periodsNeeded = 0;
        _neededMinor = 0;
      });
      return;
    }

    final contributionMinor = contributionRes.amountMinor!;
    final periodsNeeded = (needed / contributionMinor).ceil();
    final daysPer = _period == 'day'
        ? 1
        : _period == 'month'
            ? 30
            : 7;
    final daysToAdd = periodsNeeded * daysPer;
    setState(() {
      _goalDate = DateTime.now().add(Duration(days: daysToAdd));
      _periodsNeeded = periodsNeeded;
      _neededMinor = needed;
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
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    final contributionMinor = MoneyInputValidator.validateAndShowError(
      context,
      _contributionController.text,
    );
    if (contributionMinor == null) return;
    HapticFeedback.lightImpact();

    final goalName = _selectedPiggyBank?.name ?? l10n.goalDateCalculator_defaultGoalName;

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
                        l10n.goalDateCalculator_dialogContributionAmount(
                          _formatMinor(contributionMinor),
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
      amount: contributionMinor,
      name: l10n.goalDateCalculator_eventName(goalName),
      dateTime: DateTime.now().add(
        Duration(
          days: _period == 'day'
              ? 1
              : _period == 'month'
                  ? 30
                  : 7,
        ),
      ),
      repeat: _period == 'day'
          ? RepeatType.daily
          : _period == 'month'
              ? RepeatType.monthly
              : RepeatType.weekly,
      source: EventSource.calculator,
    );

    final events = await StorageService.getPlannedEvents();
    events.add(event);
    await StorageService.savePlannedEvents(events);
    await NotificationService.scheduleEventNotification(event);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.common_planCreated)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activeLocale = Localizations.localeOf(context).languageCode;

    final schedule = (_goalDate != null && _goalDate!.isAfter(DateTime.now()))
        ? _previewSchedule(3)
        : const <DateTime>[];

    final step = _selectedPiggyBank != null
        ? (_contributionController.text.trim().isNotEmpty ? 2 : 1)
        : 0;

    return AuroraCalculatorScaffold(
      title: l10n.goalDateCalculator_title,
      icon: Icons.calendar_today,
      subtitle: l10n.goalDateCalculator_subtitle,
      steps: [
        l10n.goalDateCalculator_stepGoal,
        l10n.goalDateCalculator_stepContribution,
        l10n.goalDateCalculator_stepFrequency
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
                  l10n.goalDateCalculator_headerGoal,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (_piggyBanks.isNotEmpty)
                  DropdownButtonFormField<PiggyBank>(
                     initialValue: _selectedPiggyBank,
                    items: _piggyBanks
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
                      });
                      _calculate();
                    },
                    dropdownColor: AuroraTheme.neonBlue,
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
                if (_selectedPiggyBank != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.savings,
                          color: AuroraTheme.neonBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.goalDateCalculator_remainingToGoal(
                              _formatMinor(_neededMinor),
                            ),
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
                const SizedBox(height: 18),
                Text(
                  l10n.goalDateCalculator_headerContribution,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                AuroraTextField(
                  label: l10n.goalDateCalculator_contributionAmountLabel,
                  controller: _contributionController,
                  icon: Icons.attach_money,
                  iconColor: AuroraTheme.neonBlue,
                  hintText: '0',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.goalDateCalculator_headerFrequency,
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
                      label: Text(l10n.period_day),
                    ),
                    ButtonSegment(
                      value: 'week',
                      label: Text(l10n.period_week),
                    ),
                    ButtonSegment(
                      value: 'month',
                      label: Text(l10n.period_month),
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
        if (_goalDate != null) ...[
          const SizedBox(height: 16),
          AuroraTheme.glassCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.goalDateCalculator_result,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _periodsNeeded == 0
                        ? l10n.goalDateCalculator_goalAlreadyReached
                        : l10n.goalDateCalculator_resultSummary(
                            _periodsNeeded,
                            _periodLabel(l10n),
                          ),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AuroraTheme.neonBlue.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AuroraTheme.neonBlue.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.flag,
                          color: AuroraTheme.neonBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            DateFormat('d MMMM yyyy', activeLocale)
                                .format(_goalDate!),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
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
                    text: l10n.goalDateCalculator_createPlanButton,
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
