import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../models/transaction.dart';
import '../../models/planned_event.dart';
import '../../models/piggy_bank.dart';
import '../../services/storage_service.dart';
import '../../services/notification_service.dart';
import '../../services/money_ui.dart';
import '../../theme/aurora_theme.dart';
import '../../utils/money_input_validator.dart';
import '../../widgets/aurora_dialog.dart';
import '../../widgets/aurora_button.dart';
import '../../widgets/aurora_text_field.dart';
import '../../widgets/aurora_calculator_scaffold.dart';

class CanIBuyCalculator extends StatefulWidget {
  const CanIBuyCalculator({super.key});

  @override
  State<CanIBuyCalculator> createState() => _CanIBuyCalculatorState();
}

class _CanIBuyCalculatorState extends State<CanIBuyCalculator> {
  final _priceController = TextEditingController();
  final _balanceController = TextEditingController();
  bool _dontTouchPiggyBanks = true;
  bool _considerplannedEvents = true;
  int _currentBalance = 0;
  List<PlannedEvent> plannedEvents = [];
  List<PiggyBank> _piggyBanks = [];
  String _status = '';
  String _statusMessage = '';
  Color _statusColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _priceController.addListener(_calculate);
    _balanceController.addListener(_calculate);
    _loadContextData();
  }

  Future<void> _loadContextData() async {
    final transactions = await StorageService.getTransactions();
    final planned = await StorageService.getPlannedEvents();
    final piggies = await StorageService.getPiggyBanks();
    int balance = 0;
    for (var t in transactions) {
      if (!t.parentApproved || !t.affectsWallet) {
        continue;
      }
      if (t.type == TransactionType.income) {
        balance += t.amount;
      } else {
        balance -= t.amount;
      }
    }

    if (!mounted) return;
    setState(() {
      _currentBalance = balance;
      plannedEvents = planned;
      _piggyBanks = piggies;
      _balanceController.text = (balance / 100).toStringAsFixed(0);
    });
    _calculate();
  }

  @override
  void dispose() {
    _priceController.removeListener(_calculate);
    _balanceController.removeListener(_calculate);
    _priceController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    final priceRes = MoneyInputValidator.validateToMinor(_priceController.text);
    if (!priceRes.isValid || priceRes.amountMinor == null) {
      setState(() {
        _status = '';
        _statusMessage = '';
      });
      return;
    }
    final priceCents = priceRes.amountMinor!;

    final balanceRes = _balanceController.text.trim().isEmpty
        ? null
        : MoneyInputValidator.validateToMinor(_balanceController.text);
    final balanceCents =
        balanceRes != null && balanceRes.isValid && balanceRes.amountMinor != null
            ? balanceRes.amountMinor!
            : _currentBalance;

    final piggyReserve = _dontTouchPiggyBanks
        ? 0
        : _piggyBanks.fold<int>(0, (sum, b) => sum + b.currentAmount);

    int plannedDelta = 0;
    if (_considerplannedEvents) {
      final now = DateTime.now();
      final end = now.add(const Duration(days: 7));
      for (final e in plannedEvents) {
        if (!e.affectsWallet) continue;
        if (e.status != PlannedEventStatus.planned) continue;
        if (e.dateTime.isBefore(now) || e.dateTime.isAfter(end)) continue;
        plannedDelta +=
            (e.type == TransactionType.income ? e.amount : -e.amount);
      }
    }

    final availableNow = balanceCents + piggyReserve;
    final availableAfterPlans = balanceCents + plannedDelta + piggyReserve;

    if (availableNow >= priceCents) {
      setState(() {
        _status = '✅';
        if (_considerplannedEvents && availableAfterPlans < priceCents) {
          _statusMessage = l10n.canIBuyCalculator_statusYesBut;
          _statusColor = Colors.orange;
        } else {
          _statusMessage = l10n.canIBuyCalculator_statusYes;
          _statusColor = Colors.green;
        }
      });
    } else if (availableAfterPlans >= priceCents) {
      setState(() {
        _status = '🟡';
        if (!_dontTouchPiggyBanks && piggyReserve > 0) {
          _statusMessage = l10n.canIBuyCalculator_statusMaybeWithPiggies;
        } else {
          _statusMessage = l10n.canIBuyCalculator_statusMaybeWithPlans;
        }
        _statusColor = Colors.orange;
      });
    } else {
      final lack = (priceCents - availableAfterPlans).abs();
      setState(() {
        _status = '❌';
        _statusMessage = l10n.canIBuyCalculator_statusNo(_formatMinor(lack));
        _statusColor = Colors.red;
      });
    }
  }

  String _formatMinor(int minor) {
    return formatAmountUi(context, minor);
  }

  Future<void> _planPurchase() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final priceMinor = MoneyInputValidator.validateAndShowError(
      context,
      _priceController.text,
    );
    if (priceMinor == null) return;
    HapticFeedback.lightImpact();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AuroraDialog(
        title: l10n.canIBuyCalculator_dialogTitle,
        subtitle: l10n.canIBuyCalculator_dialogSubtitle,
        icon: Icons.calendar_today,
        iconColor: AuroraTheme.neonBlue,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.canIBuyCalculator_dialogContent,
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
              child: Row(
                children: [
                  const Icon(
                    Icons.attach_money,
                    color: Colors.white70,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.canIBuyCalculator_dialogAmount(_formatMinor(priceMinor)),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.canIBuyCalculator_dialogInfo,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
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
      type: TransactionType.expense,
      amount: priceMinor,
      name: l10n.canIBuyCalculator_defaultEventName,
      dateTime: DateTime.now().add(const Duration(days: 7)),
      source: EventSource.calculator,
    );

    final events = await StorageService.getPlannedEvents();
    events.add(event);
      await StorageService.savePlannedEvents(events);
    await NotificationService.scheduleEventNotification(event);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.common_purchasePlanned)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final step = _priceController.text.trim().isNotEmpty
        ? (_balanceController.text.trim().isNotEmpty ? 2 : 1)
        : 0;

    return AuroraCalculatorScaffold(
      title: l10n.canIBuyCalculator_title,
      icon: Icons.shopping_cart,
      subtitle: l10n.canIBuyCalculator_subtitle,
      steps: [
        l10n.canIBuyCalculator_stepPrice,
        l10n.canIBuyCalculator_stepMoney,
        l10n.canIBuyCalculator_stepRules,
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
                  l10n.canIBuyCalculator_headerPrice,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                AuroraTextField(
                  label: l10n.canIBuyCalculator_priceLabel,
                  controller: _priceController,
                  icon: Icons.attach_money,
                  iconColor: AuroraTheme.neonBlue,
                  hintText: '0',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.canIBuyCalculator_headerAvailableMoney,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                AuroraTextField(
                  label: l10n.canIBuyCalculator_walletBalanceLabel,
                  controller: _balanceController,
                  icon: Icons.account_balance_wallet,
                  iconColor: Colors.greenAccent,
                  hintText: '0',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.canIBuyCalculator_headerRules,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: Text(
                    l10n.canIBuyCalculator_ruleDontTouchPiggies,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    _dontTouchPiggyBanks
                        ? l10n.canIBuyCalculator_ruleDontTouchPiggiesSubtitleEnabled
                        : l10n.canIBuyCalculator_ruleDontTouchPiggiesSubtitleDisabled,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  value: _dontTouchPiggyBanks,
                  onChanged: (value) {
                    setState(() {
                      _dontTouchPiggyBanks = value;
                    });
                    _calculate();
                  },
                ),
                SwitchListTile(
                  title: Text(
                    l10n.canIBuyCalculator_ruleConsiderPlans,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    l10n.canIBuyCalculator_ruleConsiderPlansSubtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  value: _considerplannedEvents,
                  onChanged: (value) {
                    setState(() {
                      _considerplannedEvents = value;
                    });
                    _calculate();
                  },
                ),
              ],
            ),
          ),
        ),
        if (_status.isNotEmpty) ...[
          const SizedBox(height: 16),
          AuroraTheme.glassCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.canIBuyCalculator_result,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                       color: _statusColor.withValues(alpha: 0.16),
                       borderRadius: BorderRadius.circular(16),
                       border: Border.all(
                         color: _statusColor.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(_status, style: const TextStyle(fontSize: 40)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _statusMessage,
                            style: TextStyle(
                               color: Colors.white.withValues(alpha: 0.95),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  AuroraButton(
                    text: l10n.canIBuyCalculator_planPurchaseButton,
                    icon: Icons.calendar_today,
                    customColor: AuroraTheme.neonBlue,
                    onPressed: _planPurchase,
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
