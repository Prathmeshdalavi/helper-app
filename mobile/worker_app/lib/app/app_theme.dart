import 'package:material_ui/material_ui.dart';

/// HerCare colours. Every colour in the app comes from here: screens and
/// painters never hard-code hex values.
abstract final class AppColors {
  // The eight brand tokens (docs/design-tokens.md).
  static const lavender = Color(0xFF8064C8);
  static const softRose = Color(0xFFE8A0B5);
  static const background = Color(0xFFFAF8FF);
  static const card = Color(0xFFFFFFFF);
  static const softLavender = Color(0xFFF3EDFC);
  static const text = Color(0xFF30283D);
  static const textMuted = Color(0xFF675D70);
  static const border = Color(0xFFEAE5EF);

  // Shades of the brand, for gradients and illustrations.
  static const lavenderDeep = Color(0xFF5E45A6);
  static const lavenderLight = Color(0xFFBBA8E8);
  static const roseSoft = Color(0xFFFCEDF1);
  static const roseDeep = Color(0xFFB4536F);

  // Status colours, each with a soft fill.
  static const success = Color(0xFF1E8E5A);
  static const successSoft = Color(0xFFE6F5ED);
  static const warning = Color(0xFFA9640F);
  static const warningSoft = Color(0xFFFDF2E0);
  static const gold = Color(0xFFF2B94B);
  static const danger = Color(0xFFC93E54);
  static const dangerSoft = Color(0xFFFCEBEE);
  static const info = Color(0xFF3567B8);
  static const infoSoft = Color(0xFFEAF1FC);

  // Illustration skin and hair.
  static const skin = Color(0xFFD99A75);
  static const hair = Color(0xFF3B2B3F);

  static const white = Color(0xFFFFFFFF);
  static const clear = Color(0x00FFFFFF);
  static const shadow = Color(0xFF3A2D63);
}

abstract final class AppTheme {
  static const fontFamily = 'Figtree';

  static ThemeData light() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.lavender,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.lavender,
          onPrimary: AppColors.white,
          secondary: AppColors.softRose,
          surface: AppColors.card,
          onSurface: AppColors.text,
          error: AppColors.danger,
        );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: AppColors.background,
    );
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );
    const buttonText = TextStyle(
      fontFamily: fontFamily,
      fontSize: 15.5,
      fontWeight: FontWeight.w600,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: fontFamily,
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.lavender,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.lavenderLight,
          disabledForegroundColor: AppColors.white,
          minimumSize: const Size(64, 50),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.lavender,
          textStyle: buttonText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.softLavender,
        hintStyle: const TextStyle(color: AppColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lavender, width: 1.5),
        ),
      ),
    );
  }
}
