import 'package:flutter/material.dart';
import 'package:expense_manager/screens/profile_screen.dart';
import 'package:expense_manager/screens/settings_screen.dart';
import 'package:expense_manager/screens/login_screen.dart';
import 'package:expense_manager/utils/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return const SizedBox.shrink();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.primary),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user.email?.substring(0, 1).toUpperCase() ?? "?",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            accountName: Text(
              user.userMetadata?['username'] ?? "User",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              user.email ?? "",
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ),

          // Drawer items
          ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.psychology_outlined),
            title: const Text('AI Mentor'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/ai');
            },
          ),
          ListTile(
            leading: const Icon(Icons.school_outlined),
            title: const Text('Literacy Hub'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/hub');
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: AppColors.error),
            title: Text('Logout', style: TextStyle(color: AppColors.error)),
            onTap: () async {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context); // close the dialog
                            await AuthService().signOut(); // use AuthService

                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                                (route) => false,
                              );
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                          ),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
    );
  }
}
