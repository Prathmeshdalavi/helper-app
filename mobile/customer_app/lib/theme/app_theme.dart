import 'package:flutter/material.dart';

/// HerCare brand colors. Use these instead of hard-coding hex values.
abstract final class AppColors {
  static const lavender = Color(0xFF8063C4);
  static const softRose = Color(0xFFE7A0B4);
  static const background = Color(0xFFF7F6FA);
  static const deepPlum = Color(0xFF30283D);
}

abstract final class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.lavender,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.lavender,
      onPrimary: Colors.white,
      secondary: AppColors.softRose,
      surface: Colors.white,
      onSurface: AppColors.deepPlum,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: Typography.material2021().black.apply(
            bodyColor: AppColors.deepPlum,
            displayColor: AppColors.deepPlum,
          ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.deepPlum.withValues(alpha: 0.08)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.lavender,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
