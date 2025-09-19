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
import 'package:expense_manager/utils/storage_service.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final StorageService _storageService = StorageService();

  Future<void> _openSetBudgetSheet(BuildContext context) async {
    final existing = await _storageService.getSetting('monthly_budget', 0.0) as double;
    final controller = TextEditingController(text: existing == 0.0 ? '' : existing.toStringAsFixed(0));

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Set Monthly Budget', style: Theme.of(ctx).textTheme.headlineMedium),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Budget amount (₹)',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final value = double.tryParse(controller.text.trim()) ?? 0.0;
                    await _storageService.saveSetting('monthly_budget', value);
                    if (mounted) Navigator.pop(ctx);
                    if (mounted) setState(() {});
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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

              // Expense Summary Card with budget support
              FutureBuilder<dynamic>(
                future: _storageService.getSetting('monthly_budget', 0.0),
                builder: (context, snapshot) {
                  final budgetValue = (snapshot.data is double) ? snapshot.data as double : 0.0;
                  return ExpenseSummaryCard(
                    totalExpenses: totalExpenses,
                    recentExpenses: recentExpenses,
                    monthlyBudget: budgetValue,
                  );
                },
              ),
              const SizedBox(height: 16),

              // Financial Health Score + AI Insights + Set Budget
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
                            'Financial Health Score',
                            style: theme.textTheme.titleLarge,
                          ),
                          Text('74/100', style: theme.textTheme.titleLarge),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: 0.74,
                        minHeight: 10,
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        backgroundColor: theme.colorScheme.surface.withOpacity(0.5),
                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/ai');
                              },
                              icon: const Icon(Icons.psychology_outlined),
                              label: const Text('Get AI Insights'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _openSetBudgetSheet(context),
                              icon: const Icon(Icons.savings_outlined),
                              label: const Text('Set Budget'),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
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