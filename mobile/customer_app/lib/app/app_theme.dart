import 'package:material_ui/material_ui.dart';

/// HerCare brand colors. Use these instead of hard-coding hex values.
abstract final class AppColors {
  static const lavender = Color(0xFF8063C4);
  static const softRose = Color(0xFFE7A0B4);
  static const background = Color(0xFFF7F6FA);
  static const deepPlum = Color(0xFF30283D);
}

/// Neutral ink and line colours for the newer, flatter screens.
abstract final class AppInk {
  static const text = Color(0xFF1B1826);
  static const muted = Color(0xFF6E6A7A);
  static const hairline = Color(0xFFE3E1EA);
  static const canvas = Color(0xFFF4F4F9);
}

abstract final class AppTheme {
  /// [base] with the Figtree typeface. Wrap the newer screens in a `Theme`
  /// built from this; the older screens keep the system font.
  static ThemeData withFigtree(ThemeData base) {
    TextTheme t(TextTheme x) => x.apply(
      fontFamily: 'Figtree',
      bodyColor: AppInk.text,
      displayColor: AppInk.text,
    );
    return base.copyWith(
      textTheme: t(base.textTheme),
      primaryTextTheme: t(base.primaryTextTheme),
      filledButtonTheme: FilledButtonThemeData(
        style: base.filledButtonTheme.style?.copyWith(
          textStyle: const WidgetStatePropertyAll(
            TextStyle(
              fontFamily: 'Figtree',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  static ThemeData light() {
    final scheme =
        ColorScheme.fromSeed(
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
