import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_manager/controllers/expense_controller.dart';
import 'package:expense_manager/models/expense_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  ExpenseCategory _selectedCategory = ExpenseCategory.food;

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expenseController = Provider.of<ExpenseController>(context, listen: false);
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount (₹)'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter amount';
                  final value = double.tryParse(v);
                  if (value == null || value <= 0) return 'Enter valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ExpenseCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ExpenseCategory.values
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.name),
                        ))
                    .toList(),
                onChanged: (c) => setState(() => _selectedCategory = c ?? _selectedCategory),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) => v == null || v.isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text('Date: ${_selectedDate.toLocal().toString().split(' ').first}'),
                  ),
                  TextButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Pick Date'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Upload receipt (OCR coming soon)')),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Receipt OCR placeholder')),
                        );
                      },
                      child: const Text('Upload'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    final amount = double.parse(_amountController.text);
                    await expenseController.addExpense(
                      userId: user?.id ?? 'local-user',
                      title: _titleController.text,
                      amount: amount,
                      date: _selectedDate,
                      category: _selectedCategory,
                      notes: _notesController.text.isEmpty ? null : _notesController.text,
                    );
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('Save Expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


