import 'package:expense_manager/utils/theme.dart';
import 'package:expense_manager/widgets/custom_button.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import 'package:spendo/features/statistics/widgets/chart_icon_button.dart';
import 'package:spendo/utils/constants/colors.dart';

class SpendingTrendChart extends StatelessWidget {
  const SpendingTrendChart({
    super.key,
    required this.data,
    required this.category,
  });

  final Map<DateTime, double> data;
  final String category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sortedDates = data.keys.toList()..sort();
    final spots = <FlSpot>[];

    for (var i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final amount = data[date]!;
      spots.add(FlSpot(i.toDouble(), amount));
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Iconsax.trend_up, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '$category Spending Trend',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                CustomButton(text: "Test Button", onPressed: (){}),
              ],
            ),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1.5,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          '\$${value.toInt()}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= sortedDates.length) {
                            return const SizedBox();
                          }
                          final date = sortedDates[index];
                          final formatter = DateFormat.MMMd();
                          return Text(
                            formatter.format(date),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: theme.colorScheme.primary,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: theme.colorScheme.primary.withAlpha((0.3 * 255).toInt()),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: theme.colorScheme.surface,
                      tooltipBorder: BorderSide(
                        color: theme.colorScheme.primary.withAlpha((0.2 * 255).toInt()),
                      ),
                      tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          final date = sortedDates[barSpot.x.toInt()];
                          return LineTooltipItem(
                            '${DateFormat.MMMd().format(date)}\n',
                            TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: '\$${barSpot.y.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
