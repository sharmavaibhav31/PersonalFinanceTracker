import 'package:flutter/material.dart';
import 'package:expense_manager/screens/add_edit_expense_screen.dart';

class AddExpenseButton extends StatelessWidget {
  const AddExpenseButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddEditExpenseScreen(),
          ),
        );
      },
      elevation: 4,
      backgroundColor: theme.colorScheme.primary,
      child: const Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }
}