import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_manager/controllers/expense_controller.dart';
import 'package:expense_manager/models/expense_model.dart';
import 'package:expense_manager/widgets/transaction_list_item.dart';
import 'package:expense_manager/screens/expense_details_screen.dart';
import 'package:expense_manager/utils/theme.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  String _searchQuery = '';
  ExpenseCategory? _selectedCategory;

  List<Expense> _filterExpenses(List<Expense> expenses) {
    return expenses.where((expense) {
      final matchesQuery = expense.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (expense.notes?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

      final matchesCategory = _selectedCategory == null || expense.category == _selectedCategory;

      return matchesQuery && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final expenseController = Provider.of<ExpenseController>(context);
    final theme = Theme.of(context);

    if (expenseController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredExpenses = _filterExpenses(expenseController.expenses);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Search + Filter
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Search transactions',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: _selectedCategory == null,
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = null;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ...ExpenseCategory.values.map((category) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(category.name),
                              selected: _selectedCategory == category,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = selected ? category : null;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Transaction list section
            Expanded(
              child: filteredExpenses.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long,
                        size: 64,
                        color: AppColors.textSecondary.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text(
                      'No transactions found',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (_searchQuery.isNotEmpty || _selectedCategory != null)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _selectedCategory = null;
                          });
                        },
                        child: const Text('Clear filters'),
                      ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: filteredExpenses.length,
                itemBuilder: (context, index) {
                  final expense = filteredExpenses[index];
                  return TransactionListItem(
                    expense: expense,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ExpenseDetailsScreen(expense: expense),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 80), // space for FAB if needed
          ],
        ),
      ),

    );
  }
}
