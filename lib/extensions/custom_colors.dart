import 'package:flutter/material.dart';

@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  final Color primaryBlue;
  final Color accentViolet;

  const CustomColors({required this.primaryBlue, required this.accentViolet});

  @override
  CustomColors copyWith({Color? primaryBlue, Color? accentViolet}) =>
      CustomColors(
        primaryBlue: primaryBlue ?? this.primaryBlue,
        accentViolet: accentViolet ?? this.accentViolet,
      );

  @override
  ThemeExtension<CustomColors> lerp(
      ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      primaryBlue: Color.lerp(primaryBlue, other.primaryBlue, t)!,
      accentViolet: Color.lerp(accentViolet, other.accentViolet, t)!,
    );
  }
}
