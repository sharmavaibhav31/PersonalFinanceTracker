import 'package:expense_manager/providers/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_manager/models/expense_model.dart';
import 'package:expense_manager/utils/theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ExpenseSummaryCard extends StatelessWidget {
  final double totalExpenses;
  final List<Expense> recentExpenses;
  final double? monthlyBudget; // optional
  
  const ExpenseSummaryCard({
    super.key,
    required this.totalExpenses,
    required this.recentExpenses,
    this.monthlyBudget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencySymbol = context.watch<CurrencyProvider>().currencySymbol;
final currencyFormat = NumberFormat.currency(symbol: currencySymbol);
    
    // Calculate this month's expenses
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final monthlyExpenses = recentExpenses
        .where((e) => e.date.isAfter(startOfMonth))
        .fold(0.0, (sum, e) => sum + e.amount);
    
    // Calculate last 7 days expenses
    final last7Days = now.subtract(const Duration(days: 7));
    final weeklyExpenses = recentExpenses
        .where((e) => e.date.isAfter(last7Days))
        .fold(0.0, (sum, e) => sum + e.amount);
    
    final remaining = monthlyBudget != null && monthlyBudget! > 0
        ? (monthlyBudget! - monthlyExpenses).clamp(-9999999, 9999999)
        : null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense Summary',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Total expenses
            Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Expenses',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      currencyFormat.format(totalExpenses),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 32),
            
            // This month's expenses
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_month,
                    size: 24,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This Month',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      currencyFormat.format(monthlyExpenses),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (remaining != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Remaining: ${currencyFormat.format(remaining)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: remaining >= 0 ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ]
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Last 7 days expenses
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.date_range,
                    size: 24,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last 7 Days',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      currencyFormat.format(weeklyExpenses),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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