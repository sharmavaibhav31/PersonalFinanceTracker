import 'package:flutter/material.dart';
import 'package:expense_manager/models/user_model.dart';
import 'package:expense_manager/utils/storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

class AuthController extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get error => _error;

  final _storageService = StorageService();
  final firebase.FirebaseAuth _firebaseAuth = firebase.FirebaseAuth.instance;

  AuthController() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      _isLoading = true;
      notifyListeners();

      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        _currentUser = User(
          id: firebaseUser.uid,
          username: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? '',
          avatarUrl: firebaseUser.photoURL,
          createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
        );
      } else {
        final userData = await _storageService.getUserData();
        if (userData != null) {
          _currentUser = User.fromJson(userData);
        }
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

      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser != null) {
        _currentUser = User(
          id: firebaseUser.uid,
          username: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? '',
          avatarUrl: firebaseUser.photoURL,
          createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
        );
        await _storageService.saveUserData(_currentUser!.toJson());
        notifyListeners();
        return true;
      } else {
        _error = 'User not found';
        notifyListeners();
        return false;
      }
    } on firebase.FirebaseAuthException catch (e) {
      _error = e.message ?? 'Login failed';
      notifyListeners();
      return false;
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

      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser != null) {
        // Optionally update display name
        await firebaseUser.updateDisplayName(username);

        _currentUser = User(
          id: firebaseUser.uid,
          username: username,
          email: firebaseUser.email ?? '',
          avatarUrl: firebaseUser.photoURL,
          createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
        );
        await _storageService.saveUserData(_currentUser!.toJson());
        notifyListeners();
        return true;
      } else {
        _error = 'Registration failed';
        notifyListeners();
        return false;
      }
    } on firebase.FirebaseAuthException catch (e) {
      _error = e.message ?? 'Registration failed';
      notifyListeners();
      return false;
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

      await _firebaseAuth.signOut();
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

      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        await firebaseUser.updateDisplayName(username);
        if (avatarUrl != null) {
          await firebaseUser.updatePhotoURL(avatarUrl);
        }
      }

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
