import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_manager/controllers/theme_controller.dart';
import 'package:expense_manager/providers/currency_provider.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _budgetController = TextEditingController();

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('User', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: const Text('Your Name'),
            subtitle: const Text('student@example.com'),
            trailing: TextButton(onPressed: () {}, child: const Text('Edit')),
          ),
          const Divider(),
          const SizedBox(height: 8),
          Text('Preferences', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _budgetController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Monthly Budget (₹)'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: currencyProvider.currencyCode,
            decoration: const InputDecoration(labelText: 'Preferred Currency'),
            items: const [
              DropdownMenuItem(value: 'INR', child: Text('INR (\₹)')),
              DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
              DropdownMenuItem(value: 'EUR', child: Text('EUR (\€)')),
            ],
            onChanged: (code) {
              if (code != null) {
                currencyProvider.setCurrencyCode(code);
              }
            },
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: themeController.isDarkMode,
            title: const Text('Dark Mode'),
            onChanged: (v) => themeController.setDarkMode(v),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings saved (demo)')),
              );
            },
            child: const Text('Save Settings'),
          )
        ],
      ),
    );
  }
}


