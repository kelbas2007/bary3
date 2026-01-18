import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import '../../services/money_ui.dart';
import '../../theme/aurora_theme.dart';
import '../../utils/money_input_validator.dart';
import '../../widgets/aurora_button.dart';
import '../../widgets/aurora_calculator_scaffold.dart';
import '../../widgets/aurora_text_field.dart';
import '../../l10n/app_localizations.dart';

class PriceComparisonCalculator extends StatefulWidget {
  const PriceComparisonCalculator({super.key});

  @override
  State<PriceComparisonCalculator> createState() =>
      _PriceComparisonCalculatorState();
}

class _PriceComparisonCalculatorState extends State<PriceComparisonCalculator> {
  final _priceAController = TextEditingController();
  final _quantityAController = TextEditingController();
  final _priceBController = TextEditingController();
  final _quantityBController = TextEditingController();
  int? _unitPriceMinorA;
  int? _unitPriceMinorB;
  String? _betterOption;
  double? _savingsPercent;

  @override
  void initState() {
    super.initState();
    _priceAController.addListener(_calculate);
    _quantityAController.addListener(_calculate);
    _priceBController.addListener(_calculate);
    _quantityBController.addListener(_calculate);
  }

  @override
  void dispose() {
    _priceAController.removeListener(_calculate);
    _quantityAController.removeListener(_calculate);
    _priceBController.removeListener(_calculate);
    _quantityBController.removeListener(_calculate);
    _priceAController.dispose();
    _quantityAController.dispose();
    _priceBController.dispose();
    _quantityBController.dispose();
    super.dispose();
  }

  void _calculate() {
    double? parseQty(String raw) {
      final t = raw.trim().replaceAll(',', '.');
      final v = double.tryParse(t);
      if (v == null || v <= 0) return null;
      return v;
    }

    final priceARes = MoneyInputValidator.validateToMinor(
      _priceAController.text,
    );
    final priceBRes = MoneyInputValidator.validateToMinor(
      _priceBController.text,
    );
    final qtyA = parseQty(_quantityAController.text);
    final qtyB = parseQty(_quantityBController.text);

    if (!priceARes.isValid ||
        priceARes.amountMinor == null ||
        qtyA == null ||
        !priceBRes.isValid ||
        priceBRes.amountMinor == null ||
        qtyB == null) {
      setState(() {
        _unitPriceMinorA = null;
        _unitPriceMinorB = null;
        _betterOption = null;
        _savingsPercent = null;
      });
      return;
    }

    final unitA = (priceARes.amountMinor! / qtyA).round();
    final unitB = (priceBRes.amountMinor! / qtyB).round();

    setState(() {
      _unitPriceMinorA = unitA;
      _unitPriceMinorB = unitB;
      if (unitA < unitB) {
        _betterOption = 'A';
        _savingsPercent = ((unitB - unitA) / unitB * 100);
      } else if (unitB < unitA) {
        _betterOption = 'B';
        _savingsPercent = ((unitA - unitB) / unitA * 100);
      } else {
        _betterOption = null;
        _savingsPercent = null;
      }
    });
  }

  String _formatMinor(int minor) {
    return formatAmountUi(context, minor);
  }

  Future<void> _saveFact() async {
    if (_betterOption == null) return;

    final memory = await StorageService.getBariMemory();
    final fact =
        'Вариант $_betterOption выгоднее на ${_savingsPercent!.toStringAsFixed(1)}%';
    memory.addTip(fact);
    await StorageService.saveBariMemory(memory);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.priceComparisonCalculator_factSaved)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasA =
        _priceAController.text.trim().isNotEmpty &&
        _quantityAController.text.trim().isNotEmpty;
    final hasB =
        _priceBController.text.trim().isNotEmpty &&
        _quantityBController.text.trim().isNotEmpty;
    final step = hasA ? (hasB ? 2 : 1) : 0;
    final hasResult = _unitPriceMinorA != null && _unitPriceMinorB != null;

    return AuroraCalculatorScaffold(
      title: 'Сравнение цен',
      icon: Icons.compare_arrows,
      subtitle:
          'Сравни два варианта и узнай, какой выгоднее по цене за единицу.',
      steps: const ['Вариант A', 'Вариант B', 'Итог'],
      activeStep: hasResult ? 2 : step,
      children: [
        AuroraTheme.glassCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '1) Вариант A',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                AuroraTextField(
                  label: 'Цена A',
                  controller: _priceAController,
                  icon: Icons.attach_money,
                  iconColor: AuroraTheme.neonBlue,
                  hintText: '0',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 12),
                AuroraTextField(
                  label: 'Количество / вес A',
                  controller: _quantityAController,
                  icon: Icons.scale,
                  iconColor: AuroraTheme.neonBlue,
                  hintText: '1',
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
                  '2) Вариант B',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                AuroraTextField(
                  label: 'Цена B',
                  controller: _priceBController,
                  icon: Icons.attach_money,
                  iconColor: AuroraTheme.neonPurple,
                  hintText: '0',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 12),
                AuroraTextField(
                  label: 'Количество / вес B',
                  controller: _quantityBController,
                  icon: Icons.scale,
                  iconColor: AuroraTheme.neonBlue,
                  hintText: '1',
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
                        'Цена за 1 единицу A',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        _formatMinor(_unitPriceMinorA!),
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
                      const Text(
                        'Цена за 1 единицу B',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        _formatMinor(_unitPriceMinorB!),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (_betterOption != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AuroraTheme.neonYellow.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AuroraTheme.neonYellow.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: AuroraTheme.neonYellow,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Выгоднее: вариант $_betterOption (экономия ~${_savingsPercent?.toStringAsFixed(1) ?? '0'}%)',
                              style: const TextStyle(
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
                      text: 'Сохранить вывод для Бари',
                      icon: Icons.save,
                      customColor: AuroraTheme.neonYellow,
                      onPressed: _saveFact,
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
