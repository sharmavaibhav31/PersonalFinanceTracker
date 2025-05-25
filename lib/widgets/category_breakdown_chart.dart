import 'package:expense_manager/providers/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expense_manager/models/expense_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CategoryBreakdownChart extends StatelessWidget {
  final Map<ExpenseCategory, double> expensesByCategory;
  
  const CategoryBreakdownChart({
    super.key,
    required this.expensesByCategory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencySymbol = context.watch<CurrencyProvider>().currencySymbol;
final currencyFormat = NumberFormat.currency(symbol: currencySymbol);
    final total = expensesByCategory.values.fold(0.0, (sum, amount) => sum + amount);
    
    if (expensesByCategory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
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
    
    // Define colors for categories
    final categoryColors = <ExpenseCategory, Color>{
      ExpenseCategory.food: Colors.red,
      ExpenseCategory.transportation: Colors.blue,
      ExpenseCategory.shopping: Colors.purple,
      ExpenseCategory.entertainment: Colors.orange,
      ExpenseCategory.utilities: Colors.yellow.shade800,
      ExpenseCategory.health: Colors.green,
      ExpenseCategory.education: Colors.teal,
      ExpenseCategory.other: Colors.grey,
    };
    
    // Create pie chart sections
    final sections = expensesByCategory.entries.map((entry) {
      final category = entry.key;
      final amount = entry.value;
      final percentage = (amount / total * 100).toStringAsFixed(1);
      
      return PieChartSectionData(
        value: amount,
        title: '$percentage%',
        color: categoryColors[category] ?? Colors.grey,
        radius: 70,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
    
    return Row(
      children: [
        // Pie chart
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 30,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  // Could handle touch interactions here
                },
              ),
            ),
          ),
        ),
        
        // Legend
        Expanded(
          flex: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...expensesByCategory.entries.map((entry) {
                final category = entry.key;
                final amount = entry.value;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: categoryColors[category] ?? Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          category.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        currencyFormat.format(amount),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }
}