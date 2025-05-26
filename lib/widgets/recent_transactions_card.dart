import 'package:expense_manager/providers/currency_provider.dart';
import 'package:expense_manager/screens/tabs/history_tab.dart';
import 'package:flutter/material.dart';
import 'package:expense_manager/models/expense_model.dart';
import 'package:expense_manager/screens/expense_details_screen.dart';
import 'package:expense_manager/utils/theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RecentTransactionsCard extends StatelessWidget {
  final List<Expense> expenses;
  
  const RecentTransactionsCard({
    super.key,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencySymbol = context.watch<CurrencyProvider>().currencySymbol;
final currencyFormat = NumberFormat.currency(symbol: currencySymbol);
    
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
            expenses.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 48,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No transactions yet',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: expenses.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      final dateFormat = DateFormat('MMM d');
                      
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                          child: Text(
                            expense.category.icon,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        title: Text(
                          expense.title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          dateFormat.format(expense.date),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: Text(
                          currencyFormat.format(expense.amount),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExpenseDetailsScreen(expense: expense),
                            ),
                          );
                        },
                      );
                    },
                  ),
            if (expenses.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            HistoryTab(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}