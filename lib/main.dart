import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_manager/screens/login_screen.dart';
import 'package:expense_manager/controllers/auth_controller.dart';
import 'package:expense_manager/controllers/expense_controller.dart';
import 'package:expense_manager/utils/theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ExpenseController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const LoginScreen(),
    );
  }
}