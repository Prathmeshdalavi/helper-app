import 'package:flutter/material.dart';

/// Brand tokens. Keep in sync with docs/design-tokens.md.
abstract final class AppColors {
  static const lavender = Color(0xFF8064C8);
  static const softRose = Color(0xFFE8A0B5);
  static const background = Color(0xFFFAF8FF);
  static const card = Color(0xFFFFFFFF);
  static const softLavender = Color(0xFFF3EDFC);
  static const textPrimary = Color(0xFF30283D);
  static const textSecondary = Color(0xFF675D70);
  static const border = Color(0xFFEAE5EF);
}

abstract final class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.lavender,
      primary: AppColors.lavender,
      secondary: AppColors.softRose,
      surface: AppColors.card,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
    );
  }
}
