import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/piggy_bank.dart';
import '../../services/storage_service.dart';
import '../../services/money_ui.dart';
import '../../theme/aurora_theme.dart';
import '../../utils/money_input_validator.dart';
import '../../widgets/aurora_dialog.dart';
import '../../widgets/aurora_button.dart';
import '../../widgets/aurora_text_field.dart';
import '../../widgets/aurora_calculator_scaffold.dart';
import '../../l10n/app_localizations.dart';

class Budget503020Calculator extends StatefulWidget {
  const Budget503020Calculator({super.key});

  @override
  State<Budget503020Calculator> createState() => _Budget503020CalculatorState();
}

class _Budget503020CalculatorState extends State<Budget503020Calculator> {
  final _incomeController = TextEditingController();
  int? _needsMinor;
  int? _wantsMinor;
  int? _savingsMinor;

  @override
  void initState() {
    super.initState();
    _incomeController.addListener(_calculate);
  }

  @override
  void dispose() {
    _incomeController.removeListener(_calculate);
    _incomeController.dispose();
    super.dispose();
  }

  void _calculate() {
    final res = MoneyInputValidator.validateToMinor(_incomeController.text);
    if (res.isValid && res.amountMinor != null) {
      final incomeMinor = res.amountMinor!;
      setState(() {
        _needsMinor = (incomeMinor * 0.50).round();
        _wantsMinor = (incomeMinor * 0.30).round();
        _savingsMinor = incomeMinor - _needsMinor! - _wantsMinor!;
      });
    } else {
      setState(() {
        _needsMinor = null;
        _wantsMinor = null;
        _savingsMinor = null;
      });
    }
  }

  Widget _buildInfoRow(
    String label,
    int amountMinor,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          Text(
            formatAmountUi(context, amountMinor),
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createPiggyBanks() async {
    if (_needsMinor == null || _wantsMinor == null || _savingsMinor == null) {
      return;
    }
    if (!mounted) return;
    HapticFeedback.lightImpact();

    // Показываем диалог подтверждения с детальной информацией
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AuroraDialog(
        title: 'Подтверждение',
        subtitle: 'Создание копилок по правилу 50/30/20',
        icon: Icons.savings,
        iconColor: AuroraTheme.neonBlue,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoRow(
              'Нужное (50%)',
              _needsMinor!,
              Icons.shopping_cart,
              Colors.greenAccent,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Желания (30%)',
              _wantsMinor!,
              Icons.favorite,
              Colors.orangeAccent,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Коплю (20%)',
              _savingsMinor!,
              Icons.savings,
              Colors.blueAccent,
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
      ),
    );

    if (confirmed != true) return;

    final banks = await StorageService.getPiggyBanks();
    final now = DateTime.now();

    banks.add(
      PiggyBank(
        id: '${now.millisecondsSinceEpoch}_needs',
        name: 'Нужное (50%)',
        targetAmount: _needsMinor!,
        icon: 'shopping_cart',
        createdAt: now,
      ),
    );

    banks.add(
      PiggyBank(
        id: '${now.millisecondsSinceEpoch}_wants',
        name: 'Желания (30%)',
        targetAmount: _wantsMinor!,
        icon: 'favorite',
        color: 0xFFFF9800,
        createdAt: now,
      ),
    );

    banks.add(
      PiggyBank(
        id: '${now.millisecondsSinceEpoch}_savings',
        name: 'Коплю (20%)',
        targetAmount: _savingsMinor!,
        color: 0xFF2196F3,
        createdAt: now,
      ),
    );

    await StorageService.savePiggyBanks(banks);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.calculators_3PiggyBanksCreated)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _incomeController.text.trim().isNotEmpty ? 1 : 0;
    final hasResult =
        _needsMinor != null && _wantsMinor != null && _savingsMinor != null;

    return AuroraCalculatorScaffold(
      title: 'Бюджет 50/30/20',
      icon: Icons.account_balance_wallet,
      subtitle: 'Раздели доход на 3 части: нужное, желания и накопления.',
      steps: const ['Доход', 'Распределение', 'Копилки'],
      activeStep: hasResult ? 2 : step,
      children: [
        AuroraTheme.glassCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '1) Введи доход',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                AuroraTextField(
                  label: 'Мой доход за месяц',
                  controller: _incomeController,
                  icon: Icons.attach_money,
                  iconColor: Colors.greenAccent,
                  hintText: '0',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasResult) ...[
          const SizedBox(height: 16),
          AuroraTheme.glassCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '2) Распределение',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _BudgetItem(
                    label: '50% Нужное',
                    amountMinor: _needsMinor!,
                    color: const Color(0xFF4CAF50),
                  ),
                  const SizedBox(height: 12),
                  _BudgetItem(
                    label: '30% Желания',
                    amountMinor: _wantsMinor!,
                    color: const Color(0xFFFF9800),
                  ),
                  const SizedBox(height: 12),
                  _BudgetItem(
                    label: '20% Накопления',
                    amountMinor: _savingsMinor!,
                    color: const Color(0xFF2196F3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Совет: если хочешь быстрее копить — попробуй начать с 10% в накопления и постепенно увеличивать.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12,
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '3) Сделать копилки (по желанию)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AuroraButton(
                    text: 'Создать 3 копилки',
                    icon: Icons.savings,
                    customColor: AuroraTheme.neonBlue,
                    onPressed: _createPiggyBanks,
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

class _BudgetItem extends StatelessWidget {
  final String label;
  final int amountMinor;
  final Color color;

  const _BudgetItem({
    required this.label,
    required this.amountMinor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            formatAmountUi(context, amountMinor),
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
