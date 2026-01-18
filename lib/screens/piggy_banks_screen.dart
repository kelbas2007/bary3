import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';

import '../models/piggy_bank.dart';
import '../models/transaction.dart';
import '../models/bari_memory.dart';
import '../services/storage_service.dart';
import '../theme/aurora_theme.dart';
import '../services/money_ui.dart';
import 'calculators/goal_date_calculator.dart';
import '../state/piggy_banks_notifier.dart';
import '../domain/ux_detail_level.dart';
import '../widgets/async_error_widget.dart';
import '../state/providers.dart';
import '../state/transactions_notifier.dart';
import '../widgets/aurora_bottom_sheet.dart';
import '../widgets/aurora_text_field.dart';
import '../widgets/aurora_button.dart';
import '../utils/money_input_validator.dart';
import '../utils/haptic_feedback_util.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/skeleton_loader.dart';

class PiggyBanksScreen extends ConsumerStatefulWidget {
  const PiggyBanksScreen({super.key});

  @override
  ConsumerState<PiggyBanksScreen> createState() => _PiggyBanksScreenState();
}

class _PiggyBanksScreenState extends ConsumerState<PiggyBanksScreen> {
  UxDetailLevel _uxDetailLevel = UxDetailLevel.simple;

  @override
  void initState() {
    super.initState();
    StorageService.getUxDetailLevel().then((raw) {
      if (!mounted) return;
      setState(() {
        _uxDetailLevel = UxDetailLevelX.fromStorage(raw);
      });
    });
  }

  String _getPiggyBankExplanation(AppLocalizations l10n) {
    return _uxDetailLevel == UxDetailLevel.simple
        ? l10n.piggyBanks_explanationSimple
        : l10n.piggyBanks_explanationPro;
  }

  Future<void> _createPiggyBank() async {
    HapticFeedbackUtil.lightImpact();
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CreatePiggyBankSheet(),
    );

    if (result != null && mounted) {
      final bank = PiggyBank(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: result['name'] as String,
        targetAmount: result['target'] as int,
        icon: result['icon'] as String? ?? 'savings',
        color: result['color'] as int? ?? 0xFF4CAF50,
        createdAt: DateTime.now(),
      );

      final repo = ref.read(piggyBanksRepositoryProvider);
      await repo.upsert(bank);
      await ref.read(piggyBanksProvider.notifier).refresh();

      final memory = await StorageService.getBariMemory();
      memory.addAction(
        BariAction(
          type: BariActionType.piggyBankCreated,
          timestamp: DateTime.now(),
          piggyBankId: bank.id,
        ),
      );
      await StorageService.saveBariMemory(memory);
    }
  }

  Future<void> _deletePiggyBank(BuildContext context, PiggyBank bank) async {
    final l10n = AppLocalizations.of(context)!;
    final commonConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.piggyBanks_deleteConfirmTitle),
        content: Text(l10n.piggyBanks_deleteConfirmMessage(bank.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.common_cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.common_delete),
          ),
        ],
      ),
    );

    if (commonConfirmed != true || !mounted) return;

    try {
      final repo = ref.read(piggyBanksRepositoryProvider);
      await repo.delete(bank.id);
      await ref.read(piggyBanksProvider.notifier).refresh();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.piggyBanks_deleteSuccess(bank.name)),
            action: SnackBarAction(
              label: l10n.common_cancel,
              onPressed: () async {
                await repo.upsert(bank);
                await ref.read(piggyBanksProvider.notifier).refresh();
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.piggyBanks_deleteError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final banksAsync = ref.watch(piggyBanksProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.common_piggyBanks)),
      body: Container(
        decoration: const BoxDecoration(gradient: AuroraTheme.blueGradient),
        child: banksAsync.when(
          data: (banks) {
            if (banks.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.savings,
                title: l10n.piggyBanks_emptyStateTitle,
                subtitle: _getPiggyBankExplanation(l10n),
                actionLabel: l10n.piggyBanks_createNewButton,
                onAction: _createPiggyBank,
              );
            }
            return RepaintBoundary(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: banks.length + 1,
                itemBuilder: (context, index) {
                  if (index == banks.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 64),
                      child: ElevatedButton.icon(
                        onPressed: _createPiggyBank,
                        icon: const Icon(Icons.add),
                        label: Text(l10n.piggyBanks_addNewButton),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    );
                  }
                  final bank = banks[index];
                  return _PiggyBankCard(
                    key: ValueKey(bank.id),
                    bank: bank,
                    onTap: () {
                      HapticFeedbackUtil.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PiggyBankDetailScreen(bankId: bank.id),
                        ),
                      ).then(
                        (_) => ref.read(piggyBanksProvider.notifier).refresh(),
                      );
                    },
                    onDelete: () => _deletePiggyBank(context, bank),
                  );
                },
              ),
            );
          },
          error: (err, stack) => AsyncErrorWidget(
            error: err,
            stackTrace: stack,
            onRetry: () => ref.read(piggyBanksProvider.notifier).refresh(),
          ),
          loading: () => ListView.builder(
            itemCount: 3,
            itemBuilder: (context, index) => const PiggyBankSkeleton(),
            padding: const EdgeInsets.all(16),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.piggyBanks_fabTooltip,
        onPressed: _createPiggyBank,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PiggyBankCard extends StatelessWidget {
  final PiggyBank bank;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _PiggyBankCard({
    super.key,
    required this.bank,
    required this.onTap,
    required this.onDelete,
  });

  String _getStatusEmoji(AppLocalizations l10n) {
    final progress = bank.progress;
    if (progress >= 1.0) return l10n.piggyBanks_card_statusEmojiCompleted;
    if (progress >= 0.75) return l10n.piggyBanks_card_statusEmojiAlmost;
    if (progress >= 0.5) return l10n.piggyBanks_card_statusEmojiHalfway;
    if (progress >= 0.25) return l10n.piggyBanks_card_statusEmojiQuarter;
    return l10n.piggyBanks_card_statusEmojiStarted;
  }

  String? _calculateEstimatedDate(BuildContext context) {
    if (bank.isCompleted || bank.currentAmount <= 0) return null;

    final daysSinceCreation = DateTime.now().difference(bank.createdAt).inDays;
    if (daysSinceCreation <= 0) return null;

    final avgPerDay = bank.currentAmount / daysSinceCreation;
    if (avgPerDay <= 0) return null;

    final remaining = bank.targetAmount - bank.currentAmount;
    final daysToGoal = (remaining / avgPerDay).ceil();

    if (daysToGoal > 365 * 5) return null;

    final estimatedDate = DateTime.now().add(Duration(days: daysToGoal));
    final activeLocale = Localizations.localeOf(context).languageCode;
    return DateFormat.yMMMd(activeLocale).format(estimatedDate);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progress = bank.progress.clamp(0.0, 1.0);
    final progressPercent = (progress * 100).toInt();
    final estimatedDate = _calculateEstimatedDate(context);
    final bankColor = Color(bank.color);

    return Dismissible(
      key: key!,
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 32),
      ),
      confirmDismiss: (direction) async {
        HapticFeedbackUtil.warning();
        return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(l10n.piggyBanks_deleteConfirmTitle),
                content: Text(l10n.piggyBanks_deleteConfirmMessage(bank.name)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(l10n.common_cancel),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text(l10n.common_delete),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (direction) {
        HapticFeedbackUtil.success();
        onDelete();
      },
      child: Hero(
        tag: 'piggy_bank_${bank.id}',
        child: AuroraTheme.glassCard(
          child: InkWell(
            onTap: () {
              HapticFeedbackUtil.lightImpact();
              onTap();
            },
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const SizedBox(
                        width: 72,
                        height: 72,
                        child: CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 6,
                          color: Colors.white12,
                        ),
                      ),
                      SizedBox(
                        width: 72,
                        height: 72,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 6,
                          color: bankColor,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$progressPercent%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _getStatusEmoji(l10n),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              bank.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.white38,
                              size: 20,
                            ),
                            onPressed: onDelete,
                            tooltip: l10n.piggyBanks_card_deleteTooltip,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: formatAmountUi(context, bank.currentAmount),
                              style: TextStyle(
                                color: bankColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' / ${formatAmountUi(context, bank.targetAmount)}',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (bank.isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l10n.piggyBanks_card_goalReached,
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else if (estimatedDate != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: Colors.white38,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.piggyBanks_card_estimatedDate(estimatedDate),
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        )
                      else
                        _PiggyProgressLabel(
                          current: bank.currentAmount,
                          target: bank.targetAmount,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

class _PiggyProgressLabel extends StatelessWidget {
  final int current;
  final int target;

  const _PiggyProgressLabel({
    required this.current,
    required this.target,
  });

  static String getProgressText(
      BuildContext context, int current, int target) {
    final l10n = AppLocalizations.of(context)!;
    if (target <= 0) return '';
    final progress = current / target;

    if (progress >= 1.0) {
      return l10n.piggyBanks_progress_goalReached;
    } else if (progress >= 0.75) {
      return l10n.piggyBanks_progress_almostThere(
          formatAmountUi(context, target - current));
    } else if (progress >= 0.5) {
      return l10n.piggyBanks_progress_halfway;
    } else if (progress >= 0.25) {
      return l10n.piggyBanks_progress_quarter(
          formatAmountUi(context, target - current));
    } else if (current > 0) {
      return l10n.piggyBanks_progress_started;
    } else {
      return l10n.piggyBanks_progress_initialGoal(
          formatAmountUi(context, target));
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = getProgressText(context, current, target);
    if (text.isEmpty) return const SizedBox.shrink();

    return Text(
      text,
      style: const TextStyle(color: Colors.white70, fontSize: 12),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _CreatePiggyBankSheet extends StatefulWidget {
  const _CreatePiggyBankSheet();

  @override
  State<_CreatePiggyBankSheet> createState() => _CreatePiggyBankSheetState();
}

class _CreatePiggyBankSheetState extends State<_CreatePiggyBankSheet> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final String _icon = 'savings';
  final int _color = 0xFF4CAF50;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }
  
  void _submit() {
      if (!(_formKey.currentState?.validate() ?? false)) {
        return;
      }
      
      final name = _nameController.text;
      final targetResult = MoneyInputValidator.validateToMinor(_targetController.text);
      
      Navigator.pop(context, {
        'name': name,
        'target': targetResult.amountMinor,
        'icon': _icon,
        'color': _color,
      });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: AuroraBottomSheet(
          title: l10n.piggyBanks_createSheet_title,
          titleIcon: Icons.savings,
          titleIconColor: AuroraTheme.neonYellow,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuroraTextField(
                  label: l10n.piggyBanks_createSheet_nameLabel,
                  controller: _nameController,
                  icon: Icons.label,
                  iconColor: AuroraTheme.neonYellow,
                  hintText: l10n.piggyBanks_createSheet_nameHint,
                  validator: (value) => (value?.isEmpty ?? true)
                      ? l10n.moneyValidator_enterAmount
                      : null,
                ),
                const SizedBox(height: 20),
                AuroraTextField(
                  label: l10n.piggyBanks_createSheet_targetLabel,
                  controller: _targetController,
                  icon: Icons.attach_money,
                  iconColor: AuroraTheme.neonYellow,
                  hintText: '0.00',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                   validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.moneyValidator_enterAmount;
                    }
                    final res = MoneyInputValidator.validateToMinor(value);
                    if (!res.isValid) {
                      return res.getErrorMessage(context);
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Flexible(
                      child: AuroraButton(
                        text: l10n.common_cancel,
                        isPrimary: false,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: AuroraButton(
                        text: l10n.common_create,
                        icon: Icons.check,
                        customColor: AuroraTheme.neonYellow,
                        onPressed: _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PiggyBankDetailScreen extends ConsumerStatefulWidget {
  final String bankId;

  const PiggyBankDetailScreen({super.key, required this.bankId});

  @override
  ConsumerState<PiggyBankDetailScreen> createState() =>
      _PiggyBankDetailScreenState();
}

class _PiggyBankDetailScreenState
    extends ConsumerState<PiggyBankDetailScreen> {
  Future<void> _deletePiggyBank(PiggyBank bank) async {
    final l10n = AppLocalizations.of(context)!;
    final commonConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.piggyBanks_deleteConfirmTitle),
        content: Text(l10n.piggyBanks_deleteConfirmMessage(bank.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.common_cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.common_delete),
          ),
        ],
      ),
    );

    if (commonConfirmed != true || !mounted) return;

    try {
      final repo = ref.read(piggyBanksRepositoryProvider);
      await repo.delete(bank.id);
      await ref.read(piggyBanksProvider.notifier).refresh();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.piggyBanks_deleteSuccess(bank.name)),
            action: SnackBarAction(
              label: l10n.common_cancel,
              onPressed: () async {
                await repo.upsert(bank);
                await ref.read(piggyBanksProvider.notifier).refresh();
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.piggyBanks_deleteError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addToPiggyBank(PiggyBank bank) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _PiggyBankOperationSheet(
        operation: 'add',
      ),
    );

    if (result != null && mounted) {
      final amount = result['amount'] as int;
      final repo = ref.read(piggyBanksRepositoryProvider);
      final banks = await repo.fetch();
      final currentBank = banks.firstWhere((b) => b.id == bank.id, orElse: () => bank);
      if (currentBank.id != bank.id) return;
      
      final newAmount = currentBank.currentAmount + amount;

      if (newAmount > currentBank.targetAmount) {
         // excessAmount calculated but not used in dialog
         if (!mounted) return;
         final commonConfirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.piggyBanks_detail_goalExceededTitle),
              content: Text(l10n.piggyBanks_detail_goalExceededMessage(
                currentBank.name,
                formatAmountUi(context, amount),
                formatAmountUi(context, newAmount),
                formatAmountUi(context, currentBank.targetAmount),
              )),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.common_cancel),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(l10n.common_continue),
                ),
              ],
            ),
          );

          if (commonConfirmed != true) return;
      }
      
      final daysCloser = _calculateDaysCloser(currentBank, amount);
      
      final updatedBank = bank.copyWith(currentAmount: bank.currentAmount + amount);
      await repo.upsert(updatedBank);
      await ref.read(piggyBanksProvider.notifier).refresh();
      
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: TransactionType.expense,
        amount: amount,
        date: DateTime.now(),
        note: l10n.piggyBanks_detail_topUpTransactionNote(bank.name),
        piggyBankId: bank.id,
        source: TransactionSource.piggyBank,
      );
      await ref.read(transactionsProvider.notifier).add(transaction);

      if (newAmount >= currentBank.targetAmount) {
        final memory = await StorageService.getBariMemory();
        memory.addAction(
          BariAction(
            type: BariActionType.piggyBankCompleted,
            timestamp: DateTime.now(),
            piggyBankId: bank.id,
            amount: amount,
          ),
        );
        await StorageService.saveBariMemory(memory);
      }
      
      await ref.read(piggyBanksProvider.notifier).refresh();

      if (mounted) {
        _showSuccessAnimation(
          context,
          amount,
          daysCloser,
          newAmount >= currentBank.targetAmount,
        );
      }
    }
  }

  int? _calculateDaysCloser(PiggyBank bank, int addedAmount) {
    if (bank.currentAmount <= 0) return null;

    final daysSinceCreation = DateTime.now().difference(bank.createdAt).inDays;
    if (daysSinceCreation <= 0) return null;

    final avgPerDay = bank.currentAmount / daysSinceCreation;
    if (avgPerDay <= 0) return null;

    final daysCloser = (addedAmount / avgPerDay).round();
    return daysCloser > 0 ? daysCloser : null;
  }

  void _showSuccessAnimation(
    BuildContext context,
    int amount,
    int? daysCloser,
    bool goalReached,
  ) {
    final l10n = AppLocalizations.of(context)!;
    String message;
    Color backgroundColor;
    IconData icon;

    if (goalReached) {
      message = l10n.piggyBanks_detail_successAnimationGoalReached;
      backgroundColor = Colors.green;
      icon = Icons.celebration;
    } else if (daysCloser != null && daysCloser > 0) {
      final daysText = l10n.plural_days(daysCloser);
      message = l10n.piggyBanks_detail_successAnimationDaysCloser(
          formatAmountUi(context, amount), daysCloser, daysText);
      backgroundColor = AuroraTheme.neonBlue;
      icon = Icons.trending_up;
    } else {
      message = l10n.piggyBanks_detail_successAnimationSimpleTopUp(
          formatAmountUi(context, amount));
      backgroundColor = AuroraTheme.spaceBlue;
      icon = Icons.savings;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: goalReached
            ? const Duration(seconds: 4)
            : const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _withdrawFromPiggyBank(PiggyBank bank) async {
    final l10n = AppLocalizations.of(context)!;
    if (bank.currentAmount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.piggyBanks_detail_noFundsError)),
      );
      return;
    }

    final withdrawMode = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const _WithdrawModeSelector(),
    );

    if (withdrawMode == null || !mounted) return;

    final repo = ref.read(piggyBanksRepositoryProvider);
    Map<String, dynamic>? result;

    if (withdrawMode == 'transfer') {
      final banks = await repo.fetch();
      final otherBanks = banks.where((b) => b.id != bank.id).toList();
      if (otherBanks.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.piggyBanks_detail_noOtherPiggiesError),
          ),
        );
        return;
      }

      if (!mounted) return;
      final targetBankId = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => _PiggyBankPicker(banks: otherBanks),
      );

      if (targetBankId == null || !mounted) return;

      result = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _PiggyBankOperationSheet(
          operation: 'transfer',
          maxAmount: bank.currentAmount,
        ),
      );

      if (result != null) {
        result['targetBankId'] = targetBankId;
      }
    } else {
      result = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _PiggyBankOperationSheet(
          operation: withdrawMode,
          maxAmount: bank.currentAmount,
          showCategory: withdrawMode == 'spend',
        ),
      );
    }
    
    if (result == null || !mounted) return;

    final amount = result['amount'] as int;
    if (amount > bank.currentAmount) {
       ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.piggyBanks_detail_insufficientFundsError),
          ),
        );
        return;
    }
    
    // note and category extracted but not used in current implementation

    switch (withdrawMode) {
      case 'wallet':
        final updatedBank = bank.copyWith(currentAmount: bank.currentAmount - amount);
        await repo.upsert(updatedBank);
        await ref.read(piggyBanksProvider.notifier).refresh();
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.piggyBanks_detail_withdrawToWalletSnackbar(formatAmountUi(context, amount))),
          ));
        }
        break;
      case 'spend':
         final updatedBank = bank.copyWith(currentAmount: bank.currentAmount - amount);
        await repo.upsert(updatedBank);
        await ref.read(piggyBanksProvider.notifier).refresh();
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.piggyBanks_detail_spendFromPiggySnackbar(formatAmountUi(context, amount))),
          ));
        }
        break;
      case 'transfer':
         final targetBankId = result['targetBankId'] as String;
         final banks = await repo.fetch();
         final targetBank = banks.firstWhere((b) => b.id == targetBankId, orElse: () => bank);
         if (targetBank.id == targetBankId) {
            final updatedSourceBank = bank.copyWith(currentAmount: bank.currentAmount - amount);
            final updatedTargetBank = targetBank.copyWith(currentAmount: targetBank.currentAmount + amount);
            await repo.upsert(updatedSourceBank);
            await repo.upsert(updatedTargetBank);
            await ref.read(piggyBanksProvider.notifier).refresh();
            if (mounted) {
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(l10n.piggyBanks_detail_transferSnackbar(formatAmountUi(context, amount), targetBank.name)),
              ));
            }
         }
        break;
    }
    
    await ref.read(piggyBanksProvider.notifier).refresh();
    await ref.read(transactionsProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final banksAsync = ref.watch(piggyBanksProvider);
    return banksAsync.when(
      data: (banks) {
        final bank = banks.where((b) => b.id == widget.bankId).firstOrNull;
        if (bank == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.common_error),
            ),
            body: Center(
              child: Text(
                l10n.earningsLab_piggyBankNotFound,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final transactionsAsync = ref.watch(transactionsProvider);
        return Scaffold(
          appBar: AppBar(
            title: Text(bank.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.piggyBanks_detail_deleteTooltip,
                onPressed: () => _deletePiggyBank(bank),
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(gradient: AuroraTheme.blueGradient),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuroraTheme.glassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            formatAmountUi(context, bank.currentAmount),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.piggyBanks_detail_fromAmount(
                                formatAmountUi(context, bank.targetAmount)),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: bank.progress,
                            backgroundColor: Colors.white24,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(bank.color),
                            ),
                            minHeight: 12,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          if (bank.isCompleted) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    AuroraTheme.neonYellow.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.celebration,
                                    color: AuroraTheme.neonYellow,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.piggyBanks_card_goalReached,
                                    style: const TextStyle(
                                      color: AuroraTheme.neonYellow,
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
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _addToPiggyBank(bank),
                          icon: const Icon(Icons.add),
                          label: Text(l10n.piggyBanks_detail_topUpButton),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _withdrawFromPiggyBank(bank),
                          icon: const Icon(Icons.remove),
                          label: Text(l10n.piggyBanks_detail_withdrawButton),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AuroraTheme.glassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  l10n.piggyBanks_detail_autofillTitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Switch(
                                value: bank.autoFillEnabled,
                                onChanged: (value) async {
                                  final updatedBank = bank.copyWith(autoFillEnabled: value);
                                  await ref.read(piggyBanksRepositoryProvider).upsert(updatedBank);
                                  await ref.read(piggyBanksProvider.notifier).refresh();
                                  // No need to call refresh, provider will update
                                },
                              ),
                            ],
                          ),
                          if (bank.autoFillEnabled) ...[
                            const SizedBox(height: 16),
                             Text(
                              l10n.piggyBanks_detail_autofillRuleLabel,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            SegmentedButton<AutoFillType>(
                              segments: [
                                ButtonSegment(
                                  value: AutoFillType.percent,
                                  label: Text(l10n.piggyBanks_detail_autofillTypePercent),
                                ),
                                ButtonSegment(
                                  value: AutoFillType.fixed,
                                  label: Text(l10n.piggyBanks_detail_autofillTypeFixed),
                                ),
                              ],
                              selected: {
                                bank.autoFillType ?? AutoFillType.percent
                              },
                              onSelectionChanged:
                                  (Set<AutoFillType> newSelection) {
                                final updatedBank = bank.copyWith(autoFillType: newSelection.first);
                                ref.read(piggyBanksRepositoryProvider).upsert(updatedBank).then((_) {
                                  ref.read(piggyBanksProvider.notifier).refresh();
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            if (bank.autoFillType == AutoFillType.percent)
                              TextField(
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: InputDecoration(
                                  labelText: l10n.piggyBanks_detail_autofillPercentLabel,
                                  hintText:
                                      bank.autoFillPercent?.toString() ??
                                          '10',
                                ),
                                onChanged: (value) {
                                   final percent = double.tryParse(value);
                                   if (percent != null && percent > 0 && percent <= 100) {
                                      final updatedBank = bank.copyWith(autoFillPercent: percent);
                                      ref.read(piggyBanksRepositoryProvider).upsert(updatedBank).then((_) {
                                        ref.read(piggyBanksProvider.notifier).refresh();
                                      });
                                   }
                                },
                              )
                            else
                              TextField(
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: InputDecoration(
                                  labelText: l10n.piggyBanks_detail_autofillFixedLabel,
                                  hintText: bank.autoFillAmount != null
                                      ? (bank.autoFillAmount! / 100)
                                          .toString()
                                      : '100',
                                ),
                                onChanged: (value) {
                                   final amount = double.tryParse(value);
                                   if (amount != null && amount > 0) {
                                     final updatedBank = bank.copyWith(autoFillAmount: (amount * 100).toInt());
                                     ref.read(piggyBanksRepositoryProvider).upsert(updatedBank).then((_) {
                                       ref.read(piggyBanksProvider.notifier).refresh();
                                     });
                                   }
                                },
                              ),
                          ],
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
                           Text(
                            l10n.piggyBanks_detail_whenToReachGoalTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const GoalDateCalculator(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.calculate),
                            label: Text(l10n.piggyBanks_detail_calculateButton),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPiggyHistoryCard(context, bank, transactionsAsync),
                  const SizedBox(height: 16),
                  _buildBariHintForPiggy(context, bank),
                ],
              ),
            ),
          ),
        );
      },
      error: (err, stack) => Scaffold(
        appBar: AppBar(),
        body: AsyncErrorWidget(
          error: err,
          stackTrace: stack,
          onRetry: () => ref.refresh(piggyBanksProvider),
        ),
      ),
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  /// Мини-история операций по этой копилке
  Widget _buildPiggyHistoryCard(
    BuildContext context,
    PiggyBank bank,
    AsyncValue<List<Transaction>> transactionsAsync,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return transactionsAsync.when(
      data: (txs) {
        final history = txs
            .where((t) => t.piggyBankId == bank.id)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        if (history.isEmpty) {
        return AuroraTheme.glassCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.history, color: Colors.white54),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.earningsLab_noTransactions,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        }

        final dateFormat = DateFormat.yMMMd(Localizations.localeOf(context).toString());

        final last = history.take(5).toList();

        return AuroraTheme.glassCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history, color: Colors.white70, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n.earningsLab_transactionHistory,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...last.map((t) {
                  final isTopUp = t.type == TransactionType.income;
                  final icon = isTopUp
                      ? Icons.arrow_upward
                      : Icons.arrow_downward;
                  final iconColor = isTopUp ? Colors.greenAccent : Colors.redAccent;
                  final amountText = formatAmountUi(context, t.amount);
                  final dateText = dateFormat.format(t.date);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(icon, color: iconColor, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                amountText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                t.note?.isNotEmpty == true
                                    ? t.note!
                                    : (isTopUp
                                        ? l10n.earningsLab_topUp
                                        : l10n.earningsLab_withdrawal),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dateText,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  /// Подсказки от Бари для конкретной копилки
  Widget _buildBariHintForPiggy(
    BuildContext context,
    PiggyBank bank,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final progress = bank.progress;
    String title;
    String subtitle;

    if (progress >= 1.0) {
      title = l10n.earningsLab_goalReached;
      subtitle = l10n.earningsLab_goalReachedSubtitle;
    } else if (progress >= 0.75) {
      title = l10n.earningsLab_almostThere;
      subtitle = l10n.earningsLab_almostThereSubtitle;
    } else if (progress >= 0.5) {
      title = l10n.earningsLab_halfway;
      subtitle = l10n.earningsLab_halfwaySubtitle;
    } else {
      title = l10n.earningsLab_goodStart;
      subtitle = l10n.earningsLab_goodStartSubtitle;
    }

    return AuroraTheme.glassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AuroraTheme.neonBlue,
                    AuroraTheme.neonPurple,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PiggyBankOperationSheet extends StatefulWidget {
  final String operation;
  final int? maxAmount;
  final bool showCategory;

  const _PiggyBankOperationSheet({
    required this.operation,
    this.maxAmount,
    this.showCategory = false,
  });

  @override
  State<_PiggyBankOperationSheet> createState() =>
      _PiggyBankOperationSheetState();
}

class _PiggyBankOperationSheetState extends State<_PiggyBankOperationSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _category;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
  
  void _submit() {
      if (!(_formKey.currentState?.validate() ?? false)) {
        return;
      }
      
      final result = MoneyInputValidator.validateToMinor(_amountController.text);
      
      Navigator.pop(context, {
        'amount': result.amountMinor,
        'category': _category,
        'note': _noteController.text.isEmpty
            ? null
            : _noteController.text,
      });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAdd = widget.operation == 'add';

    final String title;
    switch(widget.operation) {
      case 'add':
        title = l10n.piggyBanks_operationSheet_addTitle;
        break;
      case 'transfer':
        title = l10n.piggyBanks_operationSheet_transferTitle;
        break;
      case 'spend':
        title = l10n.piggyBanks_operationSheet_spendTitle;
        break;
      case 'wallet':
        title = l10n.piggyBanks_operationSheet_withdrawTitle;
        break;
      default:
        title = '';
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: AuroraBottomSheet(
          title: title,
          titleIcon: isAdd ? Icons.add_circle : Icons.remove_circle,
          titleIconColor: isAdd ? Colors.greenAccent : Colors.orangeAccent,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuroraTextField(
                  label: l10n.piggyBanks_operationSheet_amountLabel,
                  controller: _amountController,
                  icon: Icons.attach_money,
                  iconColor: isAdd ? Colors.greenAccent : Colors.orangeAccent,
                  hintText: widget.maxAmount != null
                      ? l10n.piggyBanks_operationSheet_maxAmountHint(formatAmountUi(context, widget.maxAmount!))
                      : l10n.piggyBanks_operationSheet_enterAmountHint,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                     if (value == null || value.isEmpty) {
                      return l10n.moneyValidator_enterAmount;
                    }
                    final res = MoneyInputValidator.validateToMinor(value);
                    if (!res.isValid || res.amountMinor == null) {
                      return res.getErrorMessage(context) ?? l10n.piggyBanks_operationSheet_errorInvalid;
                    }
                     if (widget.maxAmount != null && res.amountMinor! > widget.maxAmount!) {
                       return l10n.piggyBanks_operationSheet_errorTooMuch;
                     }
                    return null;
                  },
                ),
                if (widget.showCategory) ...[
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(
                        l10n.piggyBanks_operationSheet_categoryLabel,
                        style: const TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _category,
                        dropdownColor: AuroraTheme.spaceBlue,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: l10n.piggyBanks_operationSheet_categoryHint,
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          filled: true,
                          fillColor: Colors.black.withValues(alpha: 0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: (isAdd
                                  ? Colors.greenAccent
                                  : Colors.orangeAccent),
                              width: 2,
                            ),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(value: 'food', child: Text(l10n.piggyBanks_operationSheet_categoryFood)),
                          DropdownMenuItem(
                            value: 'transport',
                            child: Text(l10n.piggyBanks_operationSheet_categoryTransport),
                          ),
                          DropdownMenuItem(
                            value: 'entertainment',
                            child: Text(l10n.piggyBanks_operationSheet_categoryEntertainment),
                          ),
                          DropdownMenuItem(value: 'other', child: Text(l10n.piggyBanks_operationSheet_categoryOther)),
                        ],
                        onChanged: (value) => setState(() => _category = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AuroraTextField(
                    label: l10n.piggyBanks_operationSheet_noteLabel,
                    controller: _noteController,
                    icon: Icons.note,
                    iconColor: AuroraTheme.neonBlue,
                    hintText: l10n.piggyBanks_operationSheet_noteHint,
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Flexible(
                      child: AuroraButton(
                        text: l10n.common_cancel,
                        isPrimary: false,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: AuroraButton(
                        text: l10n.common_confirm,
                        icon: Icons.check,
                        customColor:
                            isAdd ? Colors.greenAccent : Colors.orangeAccent,
                        onPressed: _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WithdrawModeSelector extends StatelessWidget {
  const _WithdrawModeSelector();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(
        color: AuroraTheme.spaceBlue,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.piggyBanks_withdrawMode_title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _WithdrawModeOption(
            icon: Icons.account_balance_wallet,
            title: l10n.piggyBanks_withdrawMode_toWalletTitle,
            subtitle: l10n.piggyBanks_withdrawMode_toWalletSubtitle,
            onTap: () => Navigator.pop(context, 'wallet'),
            isDefault: true,
          ),
          const SizedBox(height: 12),
          _WithdrawModeOption(
            icon: Icons.shopping_cart,
            title: l10n.piggyBanks_withdrawMode_spendTitle,
            subtitle: l10n.piggyBanks_withdrawMode_spendSubtitle,
            onTap: () => Navigator.pop(context, 'spend'),
          ),
          const SizedBox(height: 12),
          _WithdrawModeOption(
            icon: Icons.swap_horiz,
            title: l10n.piggyBanks_withdrawMode_transferTitle,
            subtitle: l10n.piggyBanks_withdrawMode_transferSubtitle,
            onTap: () => Navigator.pop(context, 'transfer'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _WithdrawModeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDefault;

  const _WithdrawModeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDefault = false,
  });

  @override
  Widget build(BuildContext context) {
    return AuroraTheme.glassCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AuroraTheme.neonBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AuroraTheme.neonBlue, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: isDefault
                                ? FontWeight.bold
                                : FontWeight.w600,
                          ),
                        ),
                        if (isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  AuroraTheme.neonYellow.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '✅',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.white54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PiggyBankPicker extends StatelessWidget {
  final List<PiggyBank> banks;

  const _PiggyBankPicker({required this.banks});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(
        color: AuroraTheme.spaceBlue,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.piggyBanks_picker_title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...banks.map((bank) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(bank.color),
                child: const Icon(Icons.savings, color: Colors.white),
              ),
              title: Text(
                bank.name,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${formatAmountUi(context, bank.currentAmount)} / ${formatAmountUi(context, bank.targetAmount)}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: bank.progress,
                    backgroundColor: Colors.white24,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(bank.color)),
                  ),
                ],
              ),
              onTap: () => Navigator.pop(context, bank.id),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

