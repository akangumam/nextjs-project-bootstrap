import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';
import '../../services/expense_service.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpenseStatsWidget extends StatelessWidget {
  final ExpenseStats stats;

  const ExpenseStatsWidget({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Cards
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _SummaryCard(
                title: 'Total Expenses',
                value: currencyFormat.format(stats.totalAmount),
                subtitle: '${stats.totalExpenses} expenses',
                color: theme.colorScheme.primary,
              ),
              _SummaryCard(
                title: 'Approved',
                value: currencyFormat.format(stats.approvedAmount),
                subtitle: '${stats.approvedExpenses} expenses',
                color: theme.colorScheme.tertiary,
              ),
              _SummaryCard(
                title: 'Pending',
                value: currencyFormat.format(stats.pendingAmount),
                subtitle: '${stats.pendingExpenses} expenses',
                color: theme.colorScheme.secondary,
              ),
              _SummaryCard(
                title: 'Rejected',
                value: currencyFormat.format(stats.rejectedAmount),
                subtitle: '${stats.rejectedExpenses} expenses',
                color: theme.colorScheme.error,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Category Breakdown
        Text(
          'Category Breakdown',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: _getCategorySections(context, stats.categoryBreakdown),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              startDegreeOffset: -90,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: stats.categoryBreakdown.entries.map((entry) {
            return _CategoryLegendItem(
              category: entry.key,
              amount: entry.value,
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Monthly Trend
        Text(
          'Monthly Trend',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        currencyFormat.format(value).split('.')[0],
                        style: theme.textTheme.labelSmall,
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final month = stats.monthlyTrend[value.toInt()].month;
                      return Text(
                        DateFormat('MMM').format(month),
                        style: theme.textTheme.labelSmall,
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: stats.monthlyTrend.asMap().entries.map((entry) {
                    return FlSpot(
                      entry.key.toDouble(),
                      entry.value.amount,
                    );
                  }).toList(),
                  isCurved: true,
                  color: theme.colorScheme.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: theme.colorScheme.primary.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _getCategorySections(
    BuildContext context,
    Map<ExpenseCategory, double> breakdown,
  ) {
    final theme = Theme.of(context);
    final total = breakdown.values.fold(0.0, (sum, amount) => sum + amount);

    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      theme.colorScheme.error,
      theme.colorScheme.primaryContainer,
      theme.colorScheme.secondaryContainer,
    ];

    return breakdown.entries.map((entry) {
      final percentage = (entry.value / total * 100).roundToDouble();
      return PieChartSectionData(
        color: colors[entry.key.index % colors.length],
        value: entry.value,
        title: '$percentage%',
        radius: 80,
        titleStyle: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimary,
        ),
      );
    }).toList();
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(right: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryLegendItem extends StatelessWidget {
  final ExpenseCategory category;
  final double amount;

  const _CategoryLegendItem({
    required this.category,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          category.getCategoryIcon(),
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          category.toString().split('.').last,
          style: theme.textTheme.labelSmall,
        ),
        const SizedBox(width: 4),
        Text(
          currencyFormat.format(amount),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
