import 'package:flutter/material.dart';
import 'package:expense_manager/models/expense_model.dart';
import 'package:expense_manager/utils/storage_service.dart';
import 'package:uuid/uuid.dart';

class ExpenseController extends ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;
  final _storageService = StorageService();
  final _uuid = const Uuid();

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ExpenseController() {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    try {
      _isLoading = true;
      notifyListeners();

      final expensesData = await _storageService.getExpenses();
      _expenses = expensesData.map((data) => Expense.fromJson(data)).toList();
      _expenses.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      _error = 'Failed to load expenses: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense({
    required String userId,
    required String title,
    required double amount,
    required DateTime date,
    required ExpenseCategory category,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final expense = Expense(
        id: _uuid.v4(),
        userId: userId,
        title: title,
        amount: amount,
        date: date,
        category: category,
        notes: notes,
      );

      _expenses.add(expense);
      _expenses.sort((a, b) => b.date.compareTo(a.date));
      await _storageService.saveExpenses(_expenses.map((e) => e.toJson()).toList());
    } catch (e) {
      _error = 'Failed to add expense: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      _isLoading = true;
      notifyListeners();

      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index >= 0) {
        _expenses[index] = expense;
        _expenses.sort((a, b) => b.date.compareTo(a.date));
        await _storageService.saveExpenses(_expenses.map((e) => e.toJson()).toList());
      }
    } catch (e) {
      _error = 'Failed to update expense: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      _expenses.removeWhere((e) => e.id == id);
      await _storageService.saveExpenses(_expenses.map((e) => e.toJson()).toList());
    } catch (e) {
      _error = 'Failed to delete expense: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double getTotalExpenses() {
    return _expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  Map<ExpenseCategory, double> getExpensesByCategory() {
    final map = <ExpenseCategory, double>{};
    for (final expense in _expenses) {
      final category = expense.category;
      map[category] = (map[category] ?? 0) + expense.amount;
    }
    return map;
  }

  List<Expense> getRecentExpenses({int days = 30}) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    return _expenses.where((e) => e.date.isAfter(startDate)).toList();
  }

  Map<String, double> getDailyExpenses({int days = 7}) {
    final map = <String, double>{};
    final now = DateTime.now();
    
    // Initialize all days with zero
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr = '${date.day}/${date.month}';
      map[dateStr] = 0;
    }
    
    // Fill with actual expenses
    for (final expense in _expenses) {
      final difference = now.difference(expense.date).inDays;
      if (difference < days) {
        final dateStr = '${expense.date.day}/${expense.date.month}';
        map[dateStr] = (map[dateStr] ?? 0) + expense.amount;
      }
    }
    
    return map;
  }
}