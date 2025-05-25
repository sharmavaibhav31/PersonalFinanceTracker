import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';


class CurrencyProvider extends ChangeNotifier {
  String _currencyCode = 'USD'; // default

  String get currencyCode => _currencyCode;

  // Map currency codes to symbols
  static const Map<String, String> _currencySymbols = {
    'USD': '\$',
    'INR': '₹',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'CAD': 'CA\$',
    'AUD': 'A\$',
    // Add more as needed
  };

  String get currencySymbol => _currencySymbols[_currencyCode] ?? '\$';

  Future<void> loadCurrencyCode() async {
    final prefs = await SharedPreferences.getInstance();
    _currencyCode = prefs.getString('currency_code') ?? 'USD';
    notifyListeners();
  }

  Future<void> setCurrencyCode(String newCode) async {
    _currencyCode = newCode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency_code', newCode);
  }
}
