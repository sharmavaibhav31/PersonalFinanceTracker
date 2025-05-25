import 'package:flutter/material.dart';
import 'package:expense_manager/models/user_model.dart';
import 'package:expense_manager/utils/storage_service.dart';
import 'package:uuid/uuid.dart';

class AuthController extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get error => _error;

  final _storageService = StorageService();
  final _uuid = const Uuid();

  AuthController() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      _isLoading = true;
      notifyListeners();

      final userData = await _storageService.getUserData();
      if (userData != null) {
        _currentUser = User.fromJson(userData);
      }
    } catch (e) {
      _error = 'Failed to load user data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, validate credentials against backend
      // For demo, just check for demo@example.com / password
      if (email == 'demo@example.com' && password == 'password') {
        final user = User(
          id: _uuid.v4(),
          username: 'Demo User',
          email: email,
          createdAt: DateTime.now(),
        );

        await _storageService.saveUserData(user.toJson());
        _currentUser = user;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid email or password';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login failed: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String username, String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, send registration data to backend
      // For demo, just create a local user
      final user = User(
        id: _uuid.v4(),
        username: username,
        email: email,
        createdAt: DateTime.now(),
      );

      await _storageService.saveUserData(user.toJson());
      _currentUser = user;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Registration failed: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _storageService.deleteUserData();
      _currentUser = null;
    } catch (e) {
      _error = 'Logout failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(String username, {String? avatarUrl}) async {
    try {
      if (_currentUser == null) return;

      _isLoading = true;
      notifyListeners();

      final updatedUser = User(
        id: _currentUser!.id,
        username: username,
        email: _currentUser!.email,
        avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
        createdAt: _currentUser!.createdAt,
      );

      await _storageService.saveUserData(updatedUser.toJson());
      _currentUser = updatedUser;
    } catch (e) {
      _error = 'Profile update failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}