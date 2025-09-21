import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_manager/controllers/expense_controller.dart';
import 'package:expense_manager/models/expense_model.dart';
import 'package:expense_manager/widgets/custom_button.dart';
import 'package:expense_manager/widgets/custom_text_field.dart';
import 'package:expense_manager/utils/theme.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class AddEditExpenseScreen extends StatefulWidget {
  final Expense? expense;
  final bool isEditing;
  
  const AddEditExpenseScreen({
    super.key,
    this.expense,
    this.isEditing = false,
  });

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  late DateTime _selectedDate;
  late ExpenseCategory _selectedCategory;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize with existing expense data if editing
    if (widget.isEditing && widget.expense != null) {
      _titleController.text = widget.expense!.title;
      _amountController.text = widget.expense!.amount.toString();
      _notesController.text = widget.expense!.notes ?? '';
      _selectedDate = widget.expense!.date;
      _selectedCategory = widget.expense!.category;
    } else {
      _selectedDate = DateTime.now();
      _selectedCategory = ExpenseCategory.food;
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final expenseController = Provider.of<ExpenseController>(context, listen: false);
    final user = Supabase.instance.client.auth.currentUser;
    final amount = double.parse(_amountController.text);

    if (widget.isEditing && widget.expense != null) {
      final updatedExpense = Expense(
        id: widget.expense!.id,
        userId: widget.expense!.userId,
        title: _titleController.text,
        amount: amount,
        date: _selectedDate,
        category: _selectedCategory,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );
      await expenseController.updateExpense(updatedExpense);
    } else {
      await expenseController.addExpense(
        userId: user?.id ?? 'local-user',
        title: _titleController.text,
        amount: amount,
        date: _selectedDate,
        category: _selectedCategory,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseController = Provider.of<ExpenseController>(context);
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Expense' : 'Add Expense'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
              CustomTextField(
                controller: _titleController,
                label: 'Title',
                hintText: 'What did you spend on?',
                prefixIcon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Amount field
              CustomTextField(
                controller: _amountController,
                label: 'Amount',
                hintText: '0.00',
                prefixIcon: Icons.attach_money,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  try {
                    final amount = double.parse(value);
                    if (amount <= 0) {
                      return 'Amount must be greater than zero';
                    }
                  } catch (e) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Date picker
              Text(
                'Date',
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.textSecondary.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        dateFormat.format(_selectedDate),
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Category selection
              Text(
                'Category',
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Container(
                height: 100,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: ExpenseCategory.values.length,
                  itemBuilder: (context, index) {
                    final category = ExpenseCategory.values[index];
                    final isSelected = category == _selectedCategory;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      child: Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? theme.colorScheme.primary 
                              : theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              category.icon,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected 
                                    ? Colors.white 
                                    : theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Notes field
              CustomTextField(
                controller: _notesController,
                label: 'Notes (Optional)',
                hintText: 'Add any additional details...',
                prefixIcon: Icons.notes,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              
              // Save button
              CustomButton(
                text: widget.isEditing ? 'Update Expense' : 'Add Expense',
                isLoading: expenseController.isLoading,
                onPressed: _saveExpense,
              ),
            ],
          ),
        ),
      ),
    );
  }
}