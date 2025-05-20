import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_manager/controllers/auth_controller.dart';
import 'package:expense_manager/utils/theme.dart';
import 'package:expense_manager/utils/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storageService = StorageService();
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _currencyFormat = 'USD';
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final notificationsEnabled = await _storageService.getSetting('notifications_enabled', true);
    final darkModeEnabled = await _storageService.getSetting('dark_mode_enabled', false);
    final currencyFormat = await _storageService.getSetting('currency_format', 'USD');
    
    setState(() {
      _notificationsEnabled = notificationsEnabled;
      _darkModeEnabled = darkModeEnabled;
      _currencyFormat = currencyFormat;
    });
  }
  
  Future<void> _saveSettings() async {
    await _storageService.saveSetting('notifications_enabled', _notificationsEnabled);
    await _storageService.saveSetting('dark_mode_enabled', _darkModeEnabled);
    await _storageService.saveSetting('currency_format', _currencyFormat);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // General Settings
            _buildSectionHeader(context, 'General Settings'),
            ListTile(
              leading: Icon(
                Icons.notifications,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Notifications'),
              subtitle: const Text('Receive alerts and reminders'),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  _saveSettings();
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.dark_mode,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Dark Mode'),
              subtitle: const Text('Toggle dark theme'),
              trailing: Switch(
                value: _darkModeEnabled,
                onChanged: (value) {
                  setState(() {
                    _darkModeEnabled = value;
                  });
                  _saveSettings();
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.language,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Currency Format'),
              subtitle: Text(_currencyFormat),
              onTap: () {
                _showCurrencyPicker();
              },
            ),
            
            // App Settings
            _buildSectionHeader(context, 'App Settings'),
            ListTile(
              leading: Icon(
                Icons.lock,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Change Password'),
              onTap: () {
                // Navigate to change password screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('This feature is not available in the demo'),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: AppColors.error,
              ),
              title: Text(
                'Clear All Data',
                style: TextStyle(
                  color: AppColors.error,
                ),
              ),
              onTap: () {
                _showClearDataDialog();
              },
            ),
            
            // About
            _buildSectionHeader(context, 'About'),
            ListTile(
              leading: Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
              ),
              title: const Text('About App'),
              subtitle: const Text('Version 1.0.0'),
              onTap: () {
                // Show about dialog
                showAboutDialog(
                  context: context,
                  applicationName: 'Expense Manager',
                  applicationVersion: '1.0.0',
                  applicationIcon: Icon(
                    Icons.account_balance_wallet,
                    color: theme.colorScheme.primary,
                    size: 36,
                  ),
                  children: const [
                    Text(
                      'A simple expense manager app for students and professionals to track expenses and manage finances.',
                    ),
                  ],
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.help_outline,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Help & Support'),
              onTap: () {
                // Navigate to help screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('This feature is not available in the demo'),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  void _showCurrencyPicker() {
    final currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'INR'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: currencies.length,
            itemBuilder: (context, index) {
              final currency = currencies[index];
              return ListTile(
                title: Text(currency),
                trailing: _currencyFormat == currency
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  setState(() {
                    _currencyFormat = currency;
                  });
                  _saveSettings();
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
  
  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will delete all your transactions and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final storageService = StorageService();
              await storageService.clearExpenses();
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data has been cleared'),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }
}