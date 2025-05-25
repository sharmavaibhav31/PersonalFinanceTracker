import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _userKey = 'user_data';
  static const String _expensesKey = 'expenses';

  // User data methods
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    return jsonDecode(userJson) as Map<String, dynamic>;
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
  }

  Future<void> deleteUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Expenses methods
  Future<List<Map<String, dynamic>>> getExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = prefs.getString(_expensesKey);
    if (expensesJson == null) return [];
    
    final List<dynamic> decoded = jsonDecode(expensesJson);
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> saveExpenses(List<Map<String, dynamic>> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_expensesKey, jsonEncode(expenses));
  }

  Future<void> clearExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_expensesKey);
  }

  // General app settings
  Future<void> saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else {
      await prefs.setString(key, jsonEncode(value));
    }
  }

  Future<dynamic> getSetting(String key, dynamic defaultValue) async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(key)) return defaultValue;
    
    if (defaultValue is String) {
      return prefs.getString(key) ?? defaultValue;
    } else if (defaultValue is int) {
      return prefs.getInt(key) ?? defaultValue;
    } else if (defaultValue is bool) {
      return prefs.getBool(key) ?? defaultValue;
    } else if (defaultValue is double) {
      return prefs.getDouble(key) ?? defaultValue;
    } else {
      final value = prefs.getString(key);
      if (value == null) return defaultValue;
      try {
        return jsonDecode(value);
      } catch (_) {
        return defaultValue;
      }
    }
  }
}