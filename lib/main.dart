import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'routes.dart';

void main() {
  runApp(const ExpenseManagerApp());
}

class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Manager',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      initialRoute: Routes.login,
      routes: Routes.all,
    );
  }
}
