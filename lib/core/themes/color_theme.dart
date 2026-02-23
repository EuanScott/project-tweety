import 'package:flutter/material.dart';

class ColorTheme {
  // Private constructor to prevent instantiation
  ColorTheme._();

  // Primary colors
  static const Color primary = Color(0xFF1BA6A6);
  static const Color secondary = Color(0xFFE76F51);
  static const Color disabledColor = Color(0xFF8A9A9A);

  // Text colors
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static const Color textOnPrimary = Colors.white;
  static const Color textOnSecondary = Colors.white;

  // Feedback colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFFFA000);
  static const Color info = Color(0xFF1976D2);

  // Background colors
  static const Color surface = Color(0xFFF4F6F7);
  static const Color surfaceVariant = Color(0xFFEFF2F3);

  // Border colors
  static const Color outline = Color(0xFFBDBDBD);
  static const Color divider = Color(0xFFE0E0E0);

  /// Get the light color scheme
  static ColorScheme get lightColorScheme => const ColorScheme.light(
        primary: primary,
        onPrimary: textOnPrimary,
        secondary: secondary,
        onSecondary: textOnSecondary,
        error: error,
        onError: Colors.white,
        surface: surface,
        onSurface: textPrimary,
        surfaceContainerHighest: surfaceVariant,
        outline: outline,
      );

  /// Get the dark color scheme
  static ColorScheme get darkColorScheme => const ColorScheme.dark(
        primary: primary,
        onPrimary: textOnPrimary,
        secondary: secondary,
        onSecondary: textOnSecondary,
        error: error,
        onError: Colors.white,
        surface: Color(0xFF121212),
        onSurface: Colors.white,
        surfaceContainerHighest: Color(0xFF2C2C2C),
        outline: Color(0xFF555555),
      );
}
