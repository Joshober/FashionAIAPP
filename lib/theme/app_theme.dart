import 'package:flutter/material.dart';

/// Streetwear palette from `frontend/src/index.css` (Fashion AI UI guide).
abstract final class SwColors {
  static const white = Color(0xFFF5F4F0);
  static const black = Color(0xFF0D0D0D);
  static const gray = Color(0xFF888888);
  static const light = Color(0xFFE8E6E0);
  static const accent = Color(0xFFFF3B00);
  static const accent2 = Color(0xFF1A1AFF);
  static const border = Color(0xFFD0CEC8);
}

ThemeData buildFashionAiTheme() {
  const outline = SwColors.border;
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: SwColors.white,
    colorScheme: ColorScheme.light(
      surface: SwColors.white,
      onSurface: SwColors.black,
      primary: SwColors.accent,
      onPrimary: Colors.white,
      secondary: SwColors.accent2,
      onSecondary: Colors.white,
      error: SwColors.accent,
      outline: outline,
      surfaceContainerHighest: SwColors.light,
    ),
    dividerColor: outline,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: SwColors.white,
      foregroundColor: SwColors.black,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
        color: SwColors.black,
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
        side: const BorderSide(color: outline, width: 1),
      ),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: SwColors.black,
      disabledColor: SwColors.light,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 11,
        letterSpacing: 0.8,
        color: SwColors.black,
      ),
      secondaryLabelStyle: const TextStyle(color: SwColors.white),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
        side: const BorderSide(color: outline, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: const BorderSide(color: outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: const BorderSide(color: outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: const BorderSide(color: SwColors.black, width: 1.5),
      ),
      labelStyle: const TextStyle(
        color: SwColors.gray,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        backgroundColor: SwColors.accent,
        foregroundColor: Colors.white,
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: 0.9,
          fontSize: 12,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        elevation: 0,
        foregroundColor: SwColors.black,
        side: const BorderSide(color: SwColors.black, width: 1.5),
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: 0.9,
          fontSize: 12,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: SwColors.accent2,
        textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.4),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: SwColors.black,
      contentTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: SwColors.accent),
  );
}
