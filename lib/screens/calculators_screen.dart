import 'package:flutter/material.dart';
import '../theme/aurora_theme.dart';
import '../l10n/app_localizations.dart';

class CalculatorsScreen extends StatelessWidget {
  const CalculatorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.calculatorsList_title),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AuroraTheme.blueGradient,
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _CalculatorCard(
              title: 'Сколько накоплю за N дней',
              icon: Icons.calendar_today,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DaysSavingsCalculator(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _CalculatorCard(
              title: 'Если откладывать X в неделю',
              icon: Icons.trending_up,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WeeklySavingsCalculator(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _CalculatorCard(
              title: 'Цель копилки: сколько осталось',
              icon: Icons.savings,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GoalCalculator(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CalculatorCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _CalculatorCard({
    required this.title,
    required this.icon,
    required this.onTap,
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
              Icon(icon, color: AuroraTheme.neonBlue, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}

class DaysSavingsCalculator extends StatefulWidget {
  const DaysSavingsCalculator({super.key});

  @override
  State<DaysSavingsCalculator> createState() => _DaysSavingsCalculatorState();
}

class _DaysSavingsCalculatorState extends State<DaysSavingsCalculator> {
  final _dailyAmountController = TextEditingController();
  final _daysController = TextEditingController();
  double? _result;

  @override
  void dispose() {
    _dailyAmountController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  void _calculate() {
    final dailyAmount = double.tryParse(_dailyAmountController.text);
    final days = int.tryParse(_daysController.text);
    if (dailyAmount != null && days != null && dailyAmount > 0 && days > 0) {
      setState(() {
        _result = dailyAmount * days;
      });
    } else {
      setState(() {
        _result = null;
      });
    }
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.calculators_nDaysSavings),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AuroraTheme.blueGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuroraTheme.glassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Сколько накоплю',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _dailyAmountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Сумма в день',
                        ),
                        onChanged: (_) => _calculate(),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _daysController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Количество дней',
                        ),
                        onChanged: (_) => _calculate(),
                      ),
                      if (_result != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AuroraTheme.neonYellow.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Результат',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatAmount(_result!),
                                style: const TextStyle(
                                  color: AuroraTheme.neonYellow,
                                  fontSize: 32,
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
            ],
          ),
        ),
      ),
    );
  }
}

class WeeklySavingsCalculator extends StatefulWidget {
  const WeeklySavingsCalculator({super.key});

  @override
  State<WeeklySavingsCalculator> createState() => _WeeklySavingsCalculatorState();
}

class _WeeklySavingsCalculatorState extends State<WeeklySavingsCalculator> {
  final _weeklyAmountController = TextEditingController();
  final _weeksController = TextEditingController();
  double? _result;

  @override
  void dispose() {
    _weeklyAmountController.dispose();
    _weeksController.dispose();
    super.dispose();
  }

  void _calculate() {
    final weeklyAmount = double.tryParse(_weeklyAmountController.text);
    final weeks = int.tryParse(_weeksController.text);
    if (weeklyAmount != null && weeks != null && weeklyAmount > 0 && weeks > 0) {
      setState(() {
        _result = weeklyAmount * weeks;
      });
    } else {
      setState(() {
        _result = null;
      });
    }
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.calculators_weeklySavings),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AuroraTheme.blueGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuroraTheme.glassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Если откладывать X в неделю',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _weeklyAmountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Сумма в неделю',
                        ),
                        onChanged: (_) => _calculate(),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _weeksController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Количество недель',
                        ),
                        onChanged: (_) => _calculate(),
                      ),
                      if (_result != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AuroraTheme.neonYellow.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Результат',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatAmount(_result!),
                                style: const TextStyle(
                                  color: AuroraTheme.neonYellow,
                                  fontSize: 32,
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
            ],
          ),
        ),
      ),
    );
  }
}

class GoalCalculator extends StatefulWidget {
  const GoalCalculator({super.key});

  @override
  State<GoalCalculator> createState() => _GoalCalculatorState();
}

class _GoalCalculatorState extends State<GoalCalculator> {
  final _currentAmountController = TextEditingController();
  final _targetAmountController = TextEditingController();
  double? _remaining;
  int? _daysToGoal;
  final _dailySavingsController = TextEditingController();

  @override
  void dispose() {
    _currentAmountController.dispose();
    _targetAmountController.dispose();
    _dailySavingsController.dispose();
    super.dispose();
  }

  void _calculate() {
    final current = double.tryParse(_currentAmountController.text);
    final target = double.tryParse(_targetAmountController.text);
    final daily = double.tryParse(_dailySavingsController.text);

    if (current != null && target != null && current >= 0 && target > 0) {
      setState(() {
        _remaining = target - current;
        if (daily != null && daily > 0 && _remaining! > 0) {
          _daysToGoal = (_remaining! / daily).ceil();
        } else {
          _daysToGoal = null;
        }
      });
    } else {
      setState(() {
        _remaining = null;
        _daysToGoal = null;
      });
    }
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.calculators_piggyGoal),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AuroraTheme.blueGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuroraTheme.glassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Сколько осталось до цели',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _currentAmountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Текущая сумма',
                        ),
                        onChanged: (_) => _calculate(),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _targetAmountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Целевая сумма',
                        ),
                        onChanged: (_) => _calculate(),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _dailySavingsController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Откладываю в день - опционально',
                        ),
                        onChanged: (_) => _calculate(),
                      ),
                      if (_remaining != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _remaining! <= 0
                                ? Colors.green.withValues(alpha: 0.2)
                                : AuroraTheme.neonYellow.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _remaining! <= 0 ? 'Цель достигнута!' : 'Осталось',
                                style: TextStyle(
                                  color: _remaining! <= 0
                                      ? Colors.green
                                      : AuroraTheme.neonYellow,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatAmount(_remaining!.abs()),
                                style: TextStyle(
                                  color: _remaining! <= 0
                                      ? Colors.green
                                      : AuroraTheme.neonYellow,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_daysToGoal != null && _remaining! > 0) ...[
                                const SizedBox(height: 16),
                                Text(
                                  'Дней до цели: $_daysToGoal',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


