import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expense_manager/widgets/custom_button.dart';
import 'package:expense_manager/widgets/custom_text_field.dart';
import 'package:expense_manager/utils/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;

  User? get _user => Supabase.instance.client.auth.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  String _formatDate(String createdAt) {
    try {
      final dt = DateTime.parse(createdAt);
      return "${dt.day}/${dt.month}/${dt.year}";
    } catch (e) {
      return createdAt; // fallback if parsing fails
    }
  }


  void _loadUserData() {
    if (_user != null) {
      _usernameController.text = _user!.userMetadata?['username'] ?? '';
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          data: {'username': _usernameController.text},
        ),
      );

      if (mounted) {
        setState(() {
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile image
              CircleAvatar(
                radius: 56,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  (user.userMetadata?['username'] ?? user.email ?? 'U')
                      .substring(0, 1)
                      .toUpperCase(),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Profile info
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Information',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),

                      // Username
                      if (_isEditing) ...[
                        CustomTextField(
                          controller: _usernameController,
                          label: 'Username',
                          hintText: 'Enter your username',
                          prefixIcon: Icons.person,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a username';
                            }
                            return null;
                          },
                        ),
                      ] else ...[
                        _buildProfileRow(
                          context,
                          'Username',
                          user.userMetadata?['username'] ?? 'Not set',
                          Icons.person,
                        ),
                      ],
                      const Divider(height: 32),

                      // Email
                      _buildProfileRow(
                        context,
                        'Email',
                        user.email ?? 'No email',
                        Icons.email,
                      ),
                      const Divider(height: 32),

                      // Created At
                      _buildProfileRow(
                        context,
                        'Member Since',
                        user.createdAt != null
                            ? _formatDate(user.createdAt!)
                            : 'Unknown',
                        Icons.calendar_today,
                      ),

                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save button (when editing)
              if (_isEditing)
                CustomButton(
                  text: 'Save Changes',
                  isLoading: _isLoading,
                  onPressed: _saveProfile,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileRow(
      BuildContext context,
      String label,
      String value,
      IconData icon,
      ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
