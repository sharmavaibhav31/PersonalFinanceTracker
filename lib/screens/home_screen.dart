import 'package:flutter/material.dart';
import 'package:expense_manager/widgets/app_drawer.dart';
import 'package:expense_manager/screens/tabs/dashboard_tab.dart';
import 'package:expense_manager/screens/tabs/history_tab.dart';
import 'package:expense_manager/screens/tabs/tips_tab.dart';
import 'package:expense_manager/widgets/custom_bottom_navigation.dart';
import 'package:expense_manager/widgets/add_expense_button.dart';

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
    const TipsTab(),
  ];

  final List<String> _tabTitles = [
    'Dashboard',
    'Transactions',
    'Learn',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tabTitles[_currentIndex]),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Show notifications or alerts
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new notifications'),
                  behavior: SnackBarBehavior.floating,
                ),
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
      floatingActionButton: const AddExpenseButton(),
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