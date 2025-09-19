import 'package:expense_manager/controllers/theme_controller.dart';
import 'package:expense_manager/providers/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_manager/screens/login_screen.dart';
import 'package:expense_manager/screens/ai_mentor_screen.dart';
import 'package:expense_manager/screens/literacy_hub_screen.dart';
import 'package:expense_manager/screens/add_expense_screen.dart';
import 'package:expense_manager/screens/profile_settings_screen.dart';
import 'package:expense_manager/controllers/auth_controller.dart';
import 'package:expense_manager/controllers/expense_controller.dart';
import 'package:expense_manager/utils/theme.dart';




void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  final currencyProvider = CurrencyProvider();
  await currencyProvider.loadCurrencyCode();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ExpenseController()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => currencyProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);

    return MaterialApp(
      title: 'Expense Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const LoginScreen(),
      routes: {
        '/ai': (_) => const AIMentorScreen(),
        '/hub': (_) => const LiteracyHubScreen(),
        '/add': (_) => const AddExpenseScreen(),
        '/profile-settings': (_) => const ProfileSettingsScreen(),
      },
    );
  }
}