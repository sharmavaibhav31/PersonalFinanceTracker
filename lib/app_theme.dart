import 'package:flutter/material.dart';
import 'extensions/custom_colors.dart';

class AppTheme {
  static ThemeData light() => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
    useMaterial3: true,
    extensions: <ThemeExtension<dynamic>>[
      const CustomColors(
        primaryBlue: Color(0xFF1E3A8A),
        accentViolet: Color(0xFF7C3AED),
      ),
    ],
  );

  static ThemeData dark() => ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurpleAccent,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    extensions: <ThemeExtension<dynamic>>[
      const CustomColors(
        primaryBlue: Color(0xFF1E3A8A),
        accentViolet: Color(0xFF7C3AED),
      ),
    ],
  );
}
