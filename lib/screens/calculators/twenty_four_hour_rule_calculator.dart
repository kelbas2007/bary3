import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/planned_event.dart';
import '../../models/transaction.dart';
import '../../services/storage_service.dart';
import '../../services/notification_service.dart';
import '../../services/money_ui.dart';
import '../../theme/aurora_theme.dart';
import '../../widgets/aurora_dialog.dart';
import '../../widgets/aurora_button.dart';
import '../../widgets/aurora_text_field.dart';
import '../../utils/money_input_validator.dart';
import '../../widgets/aurora_calculator_scaffold.dart';
import '../../l10n/app_localizations.dart';

class Rule24HoursCalculator extends StatefulWidget {
  const Rule24HoursCalculator({super.key});

  @override
  State<Rule24HoursCalculator> createState() => _Rule24HoursCalculatorState();
}

class _Rule24HoursCalculatorState extends State<Rule24HoursCalculator> {
  final _itemController = TextEditingController();
  final _priceController = TextEditingController();
  bool _hasDelayed = false;

  @override
  void dispose() {
    _itemController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _delay24Hours() async {
    HapticFeedback.lightImpact();
    final priceRes = MoneyInputValidator.validateAndShowError(
      context,
      _priceController.text,
    );
    if (priceRes == null) return;

    final itemName = _itemController.text.trim();
    if (itemName.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.twentyFourHourRuleCalculator_enterItemName)),
        );
      }
      return;
    }

    // Показываем диалог подтверждения
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AuroraDialog(
        title: 'Подтверждение',
        subtitle: 'Создание напоминания',
        icon: Icons.timer,
        iconColor: AuroraTheme.neonYellow,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Создать напоминание через 24 часа для проверки желания купить "$itemName"?',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AuroraTheme.neonYellow.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AuroraTheme.neonYellow.withValues(alpha: 0.3),
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
                        'Цена: ${formatAmountUi(context, priceRes)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.white70,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Напоминание придет через 24 часа',
                        style: TextStyle(
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
            customColor: AuroraTheme.neonYellow,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final event = PlannedEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: TransactionType.expense,
      amount: priceRes,
      name: 'Проверка желания: $itemName',
      dateTime: DateTime.now().add(const Duration(hours: 24)),
      notificationMinutesBefore: 0,
      source: EventSource.rule24Hours,
    );

    final events = await StorageService.getPlannedEvents();
    events.add(event);
    await StorageService.savePlannedEvents(events);
    await NotificationService.scheduleEventNotification(event);

    setState(() {
      _hasDelayed = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.twentyFourHourRuleCalculator_reminderSet)),
      );
    }
  }

  Future<void> _checkAgain() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AuroraDialog(
        title: 'Проверка желания',
        subtitle: 'Прошло 24 часа',
        icon: Icons.psychology,
        iconColor: AuroraTheme.neonBlue,
        content: const Text(
          'Хочешь ещё купить это?',
          style: TextStyle(color: Colors.white70, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: Colors.white70),
            child: Text(AppLocalizations.of(context)!.twentyFourHourRuleCalculator_no),
          ),
          const SizedBox(width: 12),
          AuroraButton(
            text: 'Да',
            icon: Icons.check,
            customColor: AuroraTheme.neonBlue,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (result == false) {
      // Награда за самоконтроль
      final profile = await StorageService.getPlayerProfile();
      final newSelfControl = (profile.selfControlScore + 5).clamp(0, 100);
      await StorageService.savePlayerProfile(
        profile.copyWith(xp: profile.xp + 50, selfControlScore: newSelfControl),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.rule24h_xp50),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _itemController.text.trim().isNotEmpty
        ? (_priceController.text.trim().isNotEmpty ? 2 : 1)
        : 0;

    return AuroraCalculatorScaffold(
      title: 'Правило 24 часов',
      icon: Icons.timer,
      subtitle:
          'Помогает не делать импульсные покупки: отложи решение на сутки и проверь себя ещё раз.',
      steps: const ['Хочу', 'Цена', 'Пауза'],
      activeStep: _hasDelayed ? 2 : step,
      children: [
        AuroraTheme.glassCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '1) Что хочешь купить?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                AuroraTextField(
                  label: 'Хочу купить',
                  controller: _itemController,
                  icon: Icons.shopping_bag,
                  iconColor: AuroraTheme.neonYellow,
                  hintText: 'Например: наушники',
                ),
                const SizedBox(height: 18),
                const Text(
                  '2) Цена',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                AuroraTextField(
                  label: 'Цена',
                  controller: _priceController,
                  icon: Icons.attach_money,
                  iconColor: AuroraTheme.neonYellow,
                  hintText: '0',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
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
                  '3) Пауза',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Если через 24 часа всё ещё хочешь — покупка более осознанная. Если нет — ты сэкономил и прокачал самоконтроль.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                    height: 1.25,
                  ),
                ),
                if (!_hasDelayed) ...[
                  const SizedBox(height: 16),
                  AuroraButton(
                    text: 'Отложить на 24 часа',
                    icon: Icons.timer,
                    customColor: AuroraTheme.neonYellow,
                    onPressed: _delay24Hours,
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AuroraTheme.neonYellow.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AuroraTheme.neonYellow.withValues(alpha: 0.22),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.timer,
                          color: AuroraTheme.neonYellow,
                          size: 22,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Напоминание установлено. Через 24 часа вернись и проверь желание ещё раз.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  AuroraButton(
                    text: 'Проверить снова',
                    icon: Icons.check_circle,
                    customColor: AuroraTheme.neonBlue,
                    onPressed: _checkAgain,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
