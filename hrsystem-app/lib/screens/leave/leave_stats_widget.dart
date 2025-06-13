import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/leave.dart';
import '../../services/leave_service.dart';
import 'package:fl_chart/fl_chart.dart';

class LeaveStatsWidget extends StatelessWidget {
  final LeaveStats stats;

  const LeaveStatsWidget({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Cards
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _SummaryCard(
                title: 'Total Leaves',
                value: '${stats.totalLeaves}',
                subtitle: '${stats.totalDays} days',
                color: theme.colorScheme.primary,
              ),
              _SummaryCard(
                title: 'Approved',
                value: '${stats.approvedLeaves}',
                subtitle: '${stats.approvedDays} days',
                color: theme.colorScheme.tertiary,
              ),
              _SummaryCard(
                title: 'Pending',
                value: '${stats.pendingLeaves}',
                subtitle: '${stats.pendingDays} days',
                color: theme.colorScheme.secondary,
              ),
              _SummaryCard(
                title: 'Rejected',
                value: '${stats.rejectedLeaves}',
                subtitle: '${stats.rejectedDays} days',
                color: theme.colorScheme.error,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Leave Type Breakdown
        Text(
          'Leave Type Breakdown',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: _getTypeSections(context, stats.typeBreakdown),
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
          children: stats.typeBreakdown.entries.map((entry) {
            return _TypeLegendItem(
              type: entry.key,
              days: entry.value,
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
                        value.toStringAsFixed(1),
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
                      entry.value.days,
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

  List<PieChartSectionData> _getTypeSections(
    BuildContext context,
    Map<LeaveType, double> breakdown,
  ) {
    final theme = Theme.of(context);
    final total = breakdown.values.fold(0.0, (sum, days) => sum + days);

    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      theme.colorScheme.error,
      theme.colorScheme.primaryContainer,
      theme.colorScheme.secondaryContainer,
      theme.colorScheme.tertiaryContainer,
      theme.colorScheme.errorContainer,
    ];

    return breakdown.entries.where((entry) => entry.value > 0).map((entry) {
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

class _TypeLegendItem extends StatelessWidget {
  final LeaveType type;
  final double days;

  const _TypeLegendItem({
    required this.type,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          type.getTypeIcon(),
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          type.toString().split('.').last,
          style: theme.textTheme.labelSmall,
        ),
        const SizedBox(width: 4),
        Text(
          '${days.toStringAsFixed(1)} days',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
