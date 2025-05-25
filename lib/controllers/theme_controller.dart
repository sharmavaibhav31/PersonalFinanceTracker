import 'package:flutter/material.dart';
import '../utils/storage_service.dart';

class ThemeController with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  final StorageService _storageService = StorageService();

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> loadTheme() async {
    final isDark = await _storageService.getSetting('dark_mode_enabled', false);
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setDarkMode(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _storageService.saveSetting('dark_mode_enabled', isDark);
    notifyListeners();
  }
}
