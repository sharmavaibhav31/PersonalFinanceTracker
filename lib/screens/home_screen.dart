import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_manager/widgets/app_drawer.dart';
import 'package:expense_manager/screens/tabs/dashboard_tab.dart';
import 'package:expense_manager/screens/tabs/history_tab.dart';
import 'package:expense_manager/screens/tabs/tips_tab.dart';
import 'package:expense_manager/screens/ai_mentor_screen.dart';
import 'package:expense_manager/widgets/custom_bottom_navigation.dart';
import 'package:expense_manager/widgets/add_expense_button.dart';
import 'package:expense_manager/controllers/notification_controller.dart';
import 'package:expense_manager/controllers/expense_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const DashboardTab(),
    const HistoryTab(),
    const AIMentorScreen(),
    const TipsTab(),
  ];

  final List<String> _tabTitles = [
    'Dashboard',
    'Transactions',
    'AI Mentor',
    'Learn',
  ];

  @override
  void initState() {
    super.initState();
    // Check for budget alerts when home screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBudgetAlerts();
    });
  }

  void _checkBudgetAlerts() {
    final expenseController = Provider.of<ExpenseController>(context, listen: false);
    final notificationController = Provider.of<NotificationController>(context, listen: false);
    
    // Check budget alerts with current expenses
    notificationController.checkBudgetAlerts(expenseController.expenses);
  }

  bool _shouldShowFAB() {
    // Show FAB only on Dashboard (0) and Transactions (1) tabs
    // Hide on AI Mentor (2) and Learn (3) tabs
    return _currentIndex == 0 || _currentIndex == 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tabTitles[_currentIndex]),
        centerTitle: true,
        actions: [
          Consumer<NotificationController>(
            builder: (context, notificationController, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      Navigator.pushNamed(context, '/notifications');
                    },
                  ),
                  if (notificationController.unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${notificationController.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      floatingActionButton: _shouldShowFAB() ? const AddExpenseButton() : null,
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}