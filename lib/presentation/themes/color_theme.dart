import 'package:flutter/material.dart';

class ColorTheme {
  // Private constructor to prevent instantiation
  ColorTheme._();

  // Primary colors
  static const Color primary = Color(0xFF1BA6A6);
  static const Color secondary = Color(0xFFa6a61b);
  static const Color disabledColor = Color(0xFF8A9A9A);

  // Text colors
  // off black as it's easier on the eye
  static const Color textBlack = Colors.black87;
  static const Color textWhite = Colors.white;

  // Feedback colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFFFA000);
  static const Color info = Color(0xFF1976D2);

  // Background colors - light
  static const Color surfaceLight = Color(0xFFF4F6F7);
  static const Color surfaceVariantLight = Color(0xFFEFF2F3);

  // Background colors - dark
  static const Color surfaceDark = Color(0xFF121212);
  static const Color surfaceVariantDark = Color(0xFF2C2C2C);

  // Border colors
  static const Color outline = Color(0xFFBDBDBD);

  /// Get the light color scheme
  static ColorScheme get lightColorScheme => const ColorScheme.light(
    primary: primary,
    onPrimary: textWhite,
    secondary: secondary,
    onSecondary: textWhite,
    error: error,
    onError: textWhite,
    surface: surfaceLight,
    onSurface: textBlack,
    surfaceContainerHighest: surfaceVariantLight,
    outline: outline,
    surfaceTint: Colors.transparent,
  );

  /// Get the dark color scheme
  static ColorScheme get darkColorScheme => const ColorScheme.dark(
    primary: primary,
    onPrimary: textWhite,
    secondary: secondary,
    onSecondary: textWhite,
    error: error,
    onError: textWhite,
    surface: surfaceVariantDark,
    onSurface: textWhite,
    surfaceContainerHighest: surfaceDark,
    outline: outline,
    surfaceTint: Colors.transparent,
  );
}
