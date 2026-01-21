import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../l10n/app_localizations.dart';

/// Виджет для отображения графиков трат
class SpendingChartWidget extends StatelessWidget {
  final Map<String, int> categoryExpenses;
  final Map<String, int> categoryIncome;
  final String currencyCode;

  const SpendingChartWidget({
    super.key,
    required this.categoryExpenses,
    required this.categoryIncome,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final l10n = AppLocalizations.of(context);
    
    if (categoryExpenses.isEmpty && categoryIncome.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (categoryExpenses.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            l10n?.charts_expensesByCategory ?? 'Расходы по категориям',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          RepaintBoundary(
            child: Container(
              height: 220,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(
                    categoryExpenses,
                    locale,
                    isExpense: true,
                  ),
                  sectionsSpace: 3,
                  centerSpaceRadius: 70,
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      // Можно добавить обработку нажатий для детального просмотра
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildLegend(context, categoryExpenses, locale, isExpense: true),
        ],
        if (categoryIncome.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            l10n?.charts_incomeByCategory ?? 'Доходы по категориям',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          RepaintBoundary(
            child: Container(
              height: 220,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(
                    categoryIncome,
                    locale,
                    isExpense: false,
                  ),
                  sectionsSpace: 3,
                  centerSpaceRadius: 70,
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      // Можно добавить обработку нажатий для детального просмотра
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildLegend(context, categoryIncome, locale, isExpense: false),
        ],
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    Map<String, int> categories,
    String locale, {
    required bool isExpense,
  }) {
    final sorted = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final total = sorted.fold<int>(0, (sum, entry) => sum + entry.value);
    if (total == 0) return [];

    final colors = isExpense
        ? [
            Colors.redAccent,
            Colors.orangeAccent,
            Colors.deepOrange,
            Colors.red.shade300,
            Colors.pinkAccent,
          ]
        : [
            Colors.greenAccent,
            Colors.lightGreen,
            Colors.green.shade300,
            Colors.tealAccent,
            Colors.cyanAccent,
          ];

    return sorted.take(5).toList().asMap().entries.map((entry) {
      final index = entry.key;
      final categoryEntry = entry.value;
      final percentage = (categoryEntry.value / total * 100);
      final color = colors[index % colors.length];
      
      return PieChartSectionData(
        value: categoryEntry.value.toDouble(),
        title: percentage > 5 ? '${percentage.toStringAsFixed(1)}%' : '',
        color: color,
        radius: 55,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: percentage <= 5
            ? Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
      );
    }).toList();
  }

  Widget _buildLegend(BuildContext context, Map<String, int> categories, String locale, {required bool isExpense}) {
    final sorted = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final total = sorted.fold<int>(0, (sum, entry) => sum + entry.value);
    if (total == 0) return const SizedBox.shrink();

    final colors = isExpense
        ? [
            Colors.redAccent,
            Colors.orangeAccent,
            Colors.deepOrange,
            Colors.red.shade300,
            Colors.pinkAccent,
          ]
        : [
            Colors.greenAccent,
            Colors.lightGreen,
            Colors.green.shade300,
            Colors.tealAccent,
            Colors.cyanAccent,
          ];

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: sorted.take(5).toList().asMap().entries.map((entry) {
        final index = entry.key;
        final categoryEntry = entry.value;
        final percentage = (categoryEntry.value / total * 100);
        final color = colors[index % colors.length];
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${categoryEntry.key}: ${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
