import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../extensions/custom_colors.dart';

class SpendingChart extends StatelessWidget {
  final List<FlSpot> dataPoints;

  const SpendingChart({super.key, required this.dataPoints});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CustomColors>()!;
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: dataPoints,
            isCurved: true,
            dotData: FlDotData(show: false),
            color: colors.accentViolet,
            barWidth: 3,
          ),
        ],
      ),
    );
  }
}
