import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_manager/controllers/expense_controller.dart';
import 'package:expense_manager/controllers/auth_controller.dart';
import 'package:expense_manager/models/expense_model.dart';
import 'package:expense_manager/widgets/expense_summary_card.dart';
import 'package:expense_manager/widgets/recent_transactions_card.dart';
import 'package:expense_manager/widgets/category_breakdown_chart.dart';
import 'package:expense_manager/widgets/spending_trend_chart.dart';
import 'package:expense_manager/utils/theme.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseController = Provider.of<ExpenseController>(context);
    final authController = Provider.of<AuthController>(context);
    final theme = Theme.of(context);
    
    final totalExpenses = expenseController.getTotalExpenses();
    final expensesByCategory = expenseController.getExpensesByCategory();
    final recentExpenses = expenseController.getRecentExpenses(days: 30);
    final dailyExpenses = expenseController.getDailyExpenses(days: 7);
    
    if (expenseController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return RefreshIndicator(
      onRefresh: () => expenseController.loadExpenses(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primary,
                      radius: 24,
                      child: Text(
                        authController.currentUser?.username.substring(0, 1) ?? 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          authController.currentUser?.username ?? 'User',
                          style: theme.textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Expense Summary Card
              ExpenseSummaryCard(
                totalExpenses: totalExpenses,
                recentExpenses: recentExpenses,
              ),
              const SizedBox(height: 16),
              
              // Spending Trend Chart
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Spending Trend',
                            style: theme.textTheme.titleLarge,
                          ),
                          Text(
                            'Last 7 days',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: SpendingTrendChart(
                          dailyExpenses: dailyExpenses,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Category Breakdown
              Text(
                'Spending by Category',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 240,
                    child: CategoryBreakdownChart(
                      expensesByCategory: expensesByCategory,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Recent Transactions
              Text(
                'Recent Transactions',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              RecentTransactionsCard(
                expenses: recentExpenses.take(5).toList(),
              ),
              const SizedBox(height: 80), // Extra space for FAB
            ],
          ),
        ),
      ),
    );
  }
}