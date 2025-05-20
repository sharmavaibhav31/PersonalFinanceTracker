import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expense_manager/utils/theme.dart';

class SpendingTrendChart extends StatelessWidget {
  final Map<String, double> dailyExpenses;
  
  const SpendingTrendChart({
    super.key,
    required this.dailyExpenses,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (dailyExpenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No expense data available',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }
    
    // Find the max expense for y-axis
    final maxExpense = dailyExpenses.values.reduce((max, value) => max > value ? max : value);
    final yMax = (maxExpense * 1.2).ceilToDouble(); // 20% higher than max for better visualization
    
    // Sort dates for consistent x-axis
    final sortedDates = dailyExpenses.keys.toList()
      ..sort((a, b) {
        // Parse dates in format 'day/month'
        final aParts = a.split('/').map(int.parse).toList();
        final bParts = b.split('/').map(int.parse).toList();
        
        // Compare month first, then day
        if (aParts[1] != bParts[1]) {
          return aParts[1] - bParts[1];
        }
        return aParts[0] - bParts[0];
      });
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yMax / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.textSecondary.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= sortedDates.length) {
                  return const Text('');
                }
                final index = value.toInt();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    sortedDates[index],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == 0) {
                  return const Text('0');
                }
                
                // Show fewer ticks on y-axis
                if (value % (yMax / 4).round() != 0) {
                  return const Text('');
                }
                
                return Text(
                  '\$${value.toInt()}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        minX: 0,
        maxX: (sortedDates.length - 1).toDouble(),
        minY: 0,
        maxY: yMax,
        lineBarsData: [
          LineChartBarData(
            spots: sortedDates.asMap().entries.map((entry) {
              final index = entry.key;
              final date = entry.value;
              final expense = dailyExpenses[date] ?? 0;
              return FlSpot(index.toDouble(), expense);
            }).toList(),
            isCurved: true,
            color: theme.colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: theme.colorScheme.primary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withOpacity(0.2),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: theme.colorScheme.surface,
            tooltipRoundedRadius: 8,
            tooltipBorder: BorderSide(
              color: theme.colorScheme.primary.withOpacity(0.2),
            ),
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final date = sortedDates[barSpot.x.toInt()];
                return LineTooltipItem(
                  '$date\n',
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
    );
  }
}