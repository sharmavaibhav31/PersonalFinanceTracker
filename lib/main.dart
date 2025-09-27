import 'package:expense_manager/controllers/theme_controller.dart';
import 'package:expense_manager/providers/currency_provider.dart';
import 'package:expense_manager/services/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:expense_manager/screens/ai_mentor_screen.dart';
import 'package:expense_manager/screens/literacy_hub_screen.dart';
import 'package:expense_manager/screens/add_expense_screen.dart';
import 'package:expense_manager/screens/profile_settings_screen.dart';
import 'package:expense_manager/screens/notifications_screen.dart';
<<<<<<< HEAD
import 'package:expense_manager/screens/swadeshi_meter_screen.dart';
import 'package:expense_manager/controllers/auth_controller.dart';
=======
>>>>>>> 4c294086ebed6cacdf11e89edb7e4e8c3f8be7fc
import 'package:expense_manager/controllers/expense_controller.dart';
import 'package:expense_manager/controllers/notification_controller.dart';
import 'package:expense_manager/utils/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final currencyProvider = CurrencyProvider();
  await currencyProvider.loadCurrencyCode();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['ANON_KEY']!,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseController()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => NotificationController()),
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
      title: 'FinTrix',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const AuthGate(),

      routes: {
        '/ai': (_) => const AIMentorScreen(),
        '/hub': (_) => const LiteracyHubScreen(),
        '/add': (_) => const AddExpenseScreen(),
        '/profile-settings': (_) => const ProfileSettingsScreen(),
        '/notifications': (_) => const NotificationsScreen(),
        '/swadeshi': (_) => const SwadeshiMeterScreen(),
      },
    );
  }
}
