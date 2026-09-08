import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/database.dart';
import '../data/repositories/budget_repository.dart';
import '../logic/budget_providers.dart';

class SpendingPieChart extends StatelessWidget {
  const SpendingPieChart({required this.items, super.key});

  final List<BudgetTransaction> items;

  @override
  Widget build(BuildContext context) {
    final totals = <String, int>{};
    for (final item in items) {
      final category = item.subcategory?.trim().isNotEmpty == true
          ? item.subcategory!.trim()
          : 'General';
      totals[category] = (totals[category] ?? 0) + item.amountMinor;
    }

    if (totals.isEmpty) return const SizedBox.shrink();

    final colors = [
      const Color(0xFF2F6690),
      const Color(0xFFEF8354),
      const Color(0xFF5B8E7D),
      const Color(0xFFB38B59),
      const Color(0xFF7A6C93),
      const Color(0xFFCC6B49),
    ];
    final entries = totals.entries.toList();
    final total = totals.values.fold<int>(0, (sum, value) => sum + value);

    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending by category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 190,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 34,
                  sections: [
                    for (var index = 0; index < entries.length; index++)
                      PieChartSectionData(
                        color: colors[index % colors.length],
                        value: entries[index].value.toDouble(),
                        title:
                            '${(entries[index].value * 100 / total).round()}%',
                        radius: 64,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 14,
              runSpacing: 8,
              children: [
                for (var index = 0; index < entries.length; index++)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        color: colors[index % colors.length],
                      ),
                      const SizedBox(width: 5),
                      Consumer(builder: (context, ref, _) {
                        final curr = ref.watch(appCurrencyProvider);
                        return Text('${entries[index].key} ${formatAmount(entries[index].value, curr)}');
                      }),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SavingsBarChart extends StatelessWidget {
  const SavingsBarChart({required this.items, super.key});

  final List<BudgetTransaction> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final recent = items.reversed.take(6).toList();
    final maximum = recent.fold<int>(
          0,
          (max, item) => item.amountMinor > max ? item.amountMinor : max,
        ) *
        1.2;
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent savings',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    )),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  maxY: maximum == 0 ? 1 : maximum.toDouble(),
                  barGroups: [
                    for (var index = 0; index < recent.length; index++)
                      BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: recent[index].amountMinor.toDouble(),
                            color: const Color(0xFFB38B59),
                            width: 18,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ],
                      ),
                  ],
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SixMonthTrendChart extends StatelessWidget {
  const SixMonthTrendChart({required this.points, super.key});

  final List<TrendPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();
    const colors = {
      'monthly': Color(0xFFEF8354),
      'special': Color(0xFF5B8E7D),
      'travel': Color(0xFF3D6D9C),
      'savings': Color(0xFFB38B59),
    };
    final maximum = points
        .expand((point) => point.totals.values)
        .fold<int>(0, (max, value) => value > max ? value : max);
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Six-month trend',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    )),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maximum == 0 ? 1 : maximum.toDouble() * 1.2,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.round();
                          if (index < 0 || index >= points.length) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            '${points[index].month.month}/${points[index].month.year % 100}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    for (final type in colors.keys)
                      LineChartBarData(
                        isCurved: true,
                        color: colors[type],
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        spots: [
                          for (var index = 0; index < points.length; index++)
                            FlSpot(
                              index.toDouble(),
                              (points[index].totals[type] ?? 0).toDouble(),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: [
                for (final entry in colors.entries)
                  Text(
                    entry.key,
                    style: TextStyle(
                      color: entry.value,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
