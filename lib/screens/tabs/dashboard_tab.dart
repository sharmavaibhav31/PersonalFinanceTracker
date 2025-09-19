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

  // Calculate dynamic financial health score
  Future<double> _calculateFinancialHealthScore(
    List<Expense> recentExpenses,
    double monthlyBudget,
  ) async {
    if (recentExpenses.isEmpty) return 50.0; // Neutral score for no data

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final monthlyExpenses = recentExpenses
        .where((e) => e.date.isAfter(startOfMonth))
        .fold(0.0, (sum, e) => sum + e.amount);

    double score = 50.0; // Base score

    // Budget adherence (40% of score)
    if (monthlyBudget > 0) {
      final budgetRatio = monthlyExpenses / monthlyBudget;
      if (budgetRatio <= 0.8) {
        score += 20; // Under budget
      } else if (budgetRatio <= 1.0) {
        score += 15; // Within budget
      } else if (budgetRatio <= 1.2) {
        score += 5; // Slightly over
      } else {
        score -= 10; // Significantly over
      }
    }

    // Spending consistency (30% of score)
    final last7Days = now.subtract(const Duration(days: 7));
    final weeklyExpenses = recentExpenses
        .where((e) => e.date.isAfter(last7Days))
        .fold(0.0, (sum, e) => sum + e.amount);
    
    if (monthlyExpenses > 0) {
      final weeklyRatio = weeklyExpenses / (monthlyExpenses / 4.3); // 4.3 weeks per month
      if (weeklyRatio >= 0.8 && weeklyRatio <= 1.2) {
        score += 15; // Consistent spending
      } else if (weeklyRatio >= 0.6 && weeklyRatio <= 1.4) {
        score += 10; // Moderately consistent
      } else {
        score += 5; // Somewhat consistent
      }
    }

    // Category diversity (20% of score)
    final categories = recentExpenses.map((e) => e.category).toSet().length;
    if (categories >= 5) {
      score += 10; // Good diversity
    } else if (categories >= 3) {
      score += 5; // Moderate diversity
    }

    // Recent activity (10% of score)
    final lastTransaction = recentExpenses.isNotEmpty 
        ? recentExpenses.first.date 
        : now.subtract(const Duration(days: 30));
    final daysSinceLastTransaction = now.difference(lastTransaction).inDays;
    
    if (daysSinceLastTransaction <= 3) {
      score += 5; // Very recent activity
    } else if (daysSinceLastTransaction <= 7) {
      score += 3; // Recent activity
    } else if (daysSinceLastTransaction <= 14) {
      score += 1; // Somewhat recent
    }

    return score.clamp(0.0, 100.0);
  }

  String _getScoreDescription(double score) {
    if (score >= 90) return 'Excellent! You\'re managing finances very well.';
    if (score >= 80) return 'Great job! Your financial habits are strong.';
    if (score >= 70) return 'Good progress! Keep up the consistent spending.';
    if (score >= 60) return 'Fair. Consider setting a budget to improve.';
    if (score >= 50) return 'Room for improvement. Track expenses more regularly.';
    return 'Needs attention. Focus on budgeting and expense tracking.';
  }

  void _showScoreBreakdownDialog(BuildContext context, double score) {
    final scoreColor = score >= 80 
        ? AppColors.success 
        : score >= 60 
            ? AppColors.warning 
            : AppColors.error;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: scoreColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Financial Health Score Guide'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Current Score
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Your Current Score:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '${score.toStringAsFixed(0)}/100',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Score Ranges
              const Text('Score Ranges:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              _buildScoreRangeItem('90-100', AppColors.success, 'Excellent - Outstanding financial management'),
              _buildScoreRangeItem('80-89', AppColors.success, 'Great - Strong financial habits'),
              _buildScoreRangeItem('70-79', AppColors.warning, 'Good - Consistent spending patterns'),
              _buildScoreRangeItem('60-69', AppColors.warning, 'Fair - Room for improvement'),
              _buildScoreRangeItem('50-59', AppColors.error, 'Poor - Needs attention'),
              _buildScoreRangeItem('0-49', AppColors.error, 'Critical - Immediate action required'),
              
              const SizedBox(height: 16),
              
              // Scoring Factors
              const Text('How Your Score is Calculated:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              _buildFactorItem('Budget Adherence (40%)', 'How well you stick to your monthly budget'),
              _buildFactorItem('Spending Consistency (30%)', 'Regularity of your weekly vs monthly spending'),
              _buildFactorItem('Category Diversity (20%)', 'Variety in your expense categories'),
              _buildFactorItem('Recent Activity (10%)', 'How recently you\'ve been tracking expenses'),
              
              const SizedBox(height: 16),
              
              // Tips
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡 Tips to Improve:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('• Set and stick to a monthly budget'),
                    const Text('• Track expenses regularly'),
                    const Text('• Maintain consistent spending patterns'),
                    const Text('• Diversify your expense categories'),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRangeItem(String range, Color color, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 8),
          Text('$range: $description', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFactorItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                Text(description, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
              FutureBuilder<dynamic>(
                future: _storageService.getSetting('monthly_budget', 0.0),
                builder: (context, budgetSnapshot) {
                  final budgetValue = (budgetSnapshot.data is double) ? budgetSnapshot.data as double : 0.0;
                  
                  return FutureBuilder<double>(
                    future: _calculateFinancialHealthScore(recentExpenses, budgetValue),
                    builder: (context, scoreSnapshot) {
                      final score = scoreSnapshot.data ?? 50.0;
                      final scoreColor = score >= 80 
                          ? AppColors.success 
                          : score >= 60 
                              ? AppColors.warning 
                              : AppColors.error;
                      
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Financial Health Score',
                                    style: theme.textTheme.titleLarge,
                                  ),
                                  Text(
                                    '${score.toStringAsFixed(0)}/100',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: scoreColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () => _showScoreBreakdownDialog(context, score),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Column(
                                    children: [
                                      LinearProgressIndicator(
                                        value: score / 100,
                                        minHeight: 10,
                                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                                        backgroundColor: theme.colorScheme.surface.withOpacity(0.5),
                                        valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Tap for details',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: AppColors.textSecondary,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getScoreDescription(score),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
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
                      );
                    },
                  );
                },
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