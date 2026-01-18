import 'package:flutter/material.dart';
import '../theme/aurora_theme.dart';
import '../l10n/app_localizations.dart';
import 'calculators/piggy_plan_calculator.dart';
import 'calculators/goal_date_calculator.dart';
import 'calculators/monthly_budget_calculator.dart';
import 'calculators/subscriptions_calculator.dart';
import 'calculators/can_i_buy_calculator.dart';
import 'calculators/price_comparison_calculator.dart';
import 'calculators/twenty_four_hour_rule_calculator.dart';
import 'calculators/budget_50_30_20_calculator.dart';

class CalculatorsListScreen extends StatelessWidget {
  const CalculatorsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final calculators = [
      {
        'title': l10n.calculatorsList_piggyPlan,
        'description': l10n.calculatorsList_piggyPlanDesc,
        'screen': const PiggyPlanCalculator(),
      },
      {
        'title': l10n.calculatorsList_goalDate,
        'description': l10n.calculatorsList_goalDateDesc,
        'screen': const GoalDateCalculator(),
      },
      {
        'title': l10n.calculatorsList_monthlyBudget,
        'description': l10n.calculatorsList_monthlyBudgetDesc,
        'screen': const MonthlyBudgetCalculator(),
      },
      {
        'title': l10n.calculatorsList_subscriptions,
        'description': l10n.calculatorsList_subscriptionsDesc,
        'screen': const SubscriptionsCalculator(),
      },
      {
        'title': l10n.calculatorsList_canIBuy,
        'description': l10n.calculatorsList_canIBuyDesc,
        'screen': const CanIBuyCalculator(),
      },
      {
        'title': l10n.calculatorsList_priceComparison,
        'description': l10n.calculatorsList_priceComparisonDesc,
        'screen': const PriceComparisonCalculator(),
      },
      {
        'title': l10n.calculatorsList_24hRule,
        'description': l10n.calculatorsList_24hRuleDesc,
        'screen': const Rule24HoursCalculator(),
      },
      {
        'title': l10n.calculatorsList_budget503020,
        'description': l10n.calculatorsList_budget503020Desc,
        'screen': const Budget503020Calculator(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.calculatorsList_title),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AuroraTheme.blueGradient,
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: calculators.length,
          itemBuilder: (context, index) {
            final calc = calculators[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AuroraTheme.glassCard(
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AuroraTheme.neonBlue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calculate,
                      color: AuroraTheme.neonBlue,
                    ),
                  ),
                  title: Text(
                    calc['title'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    calc['description'] as String,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.white54,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => calc['screen'] as Widget,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
