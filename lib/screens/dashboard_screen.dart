import 'package:flutter/material.dart';
import '../widgets/info_card.dart';
import '../widgets/spending_chart.dart';
import 'feature_screen.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final monthData = <FlSpot>[/* … */];
    final weekData = <FlSpot>[/* … */];

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InfoCard(title: 'This Month', child: SpendingChart(dataPoints: monthData)),
          const SizedBox(height: 16),
          InfoCard(title: 'Weekly Trend', child: SpendingChart(dataPoints: weekData)),
        ],
      ),
      drawer: const Drawer(child: FeatureMenu()), // see feature_screen.dart
    );
  }
}
