import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_manager/controllers/auth_controller.dart';
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
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
  
  void _loadUserData() {
    final user = Provider.of<AuthController>(context, listen: false).currentUser;
    if (user != null) {
      _usernameController.text = user.username;
    }
  }
  
  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }
  
  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authController = Provider.of<AuthController>(context, listen: false);
    await authController.updateProfile(_usernameController.text);
    
    if (mounted) {
      setState(() {
        _isEditing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final theme = Theme.of(context);
    final user = authController.currentUser;
    
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
              Stack(
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      user.username.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                ],
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
                          user.username,
                          Icons.person,
                        ),
                      ],
                      const Divider(height: 32),
                      
                      // Email
                      _buildProfileRow(
                        context,
                        'Email',
                        user.email,
                        Icons.email,
                      ),
                      const Divider(height: 32),
                      
                      // Member since
                      _buildProfileRow(
                        context,
                        'Member Since',
                        '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
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
                  isLoading: authController.isLoading,
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