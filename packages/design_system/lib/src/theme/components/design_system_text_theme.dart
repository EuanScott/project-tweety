import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DesignSystemTextTheme {
  DesignSystemTextTheme._();

  static TextStyle buttonTextStyle(ColorScheme colorScheme) {
    return _createTextStyle(
      color: colorScheme.primary,
      colorScheme: colorScheme,
      height: 1.25,
      size: 16,
      weight: FontWeight.w700,
    );
  }

  static TextTheme build(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: _createTextStyle(
        color: colorScheme.primary,
        colorScheme: colorScheme,
        height: 1.12,
        size: 36,
        weight: FontWeight.w700,
      ),
      displayMedium: _createTextStyle(
        color: colorScheme.primary,
        colorScheme: colorScheme,
        height: 1.15,
        size: 32,
        weight: FontWeight.w700,
      ),
      displaySmall: _createTextStyle(
        color: colorScheme.primary,
        colorScheme: colorScheme,
        height: 1.18,
        size: 28,
        weight: FontWeight.w700,
      ),
      headlineLarge: _createTextStyle(
        color: colorScheme.primary,
        colorScheme: colorScheme,
        height: 1.2,
        size: 24,
        weight: FontWeight.w700,
      ),
      headlineMedium: _createTextStyle(
        color: colorScheme.primary,
        colorScheme: colorScheme,
        height: 1.22,
        size: 22,
        weight: FontWeight.w700,
      ),
      headlineSmall: _createTextStyle(
        color: colorScheme.primary,
        colorScheme: colorScheme,
        height: 1.25,
        size: 20,
        weight: FontWeight.w700,
      ),
      titleLarge: _createTextStyle(
        color: colorScheme.primary,
        colorScheme: colorScheme,
        height: 1.25,
        size: 18,
        weight: FontWeight.w700,
      ),
      titleMedium: _createTextStyle(
        color: colorScheme.primary,
        colorScheme: colorScheme,
        height: 1.25,
        size: 16,
        weight: FontWeight.w700,
      ),
      titleSmall: _createTextStyle(
        color: colorScheme.primary,
        colorScheme: colorScheme,
        height: 1.3,
        size: 14,
        weight: FontWeight.w600,
      ),
      bodyLarge: _createTextStyle(
        color: colorScheme.onSurface,
        colorScheme: colorScheme,
        height: 1.45,
        size: 16,
        weight: FontWeight.w400,
      ),
      bodyMedium: _createTextStyle(
        color: colorScheme.onSurface,
        colorScheme: colorScheme,
        height: 1.45,
        size: 14,
        weight: FontWeight.w400,
      ),
      bodySmall: _createTextStyle(
        color: colorScheme.onSurfaceVariant,
        colorScheme: colorScheme,
        height: 1.4,
        size: 12,
        weight: FontWeight.w400,
      ),
      labelLarge: _createTextStyle(
        color: colorScheme.onSurface,
        colorScheme: colorScheme,
        height: 1.25,
        size: 16,
        weight: FontWeight.w700,
      ),
      labelMedium: _createTextStyle(
        color: colorScheme.onSurfaceVariant,
        colorScheme: colorScheme,
        height: 1.3,
        size: 14,
        weight: FontWeight.w600,
      ),
      labelSmall: _createTextStyle(
        color: colorScheme.onSurfaceVariant,
        colorScheme: colorScheme,
        height: 1.3,
        size: 12,
        weight: FontWeight.w600,
      ),
    );
  }

  static TextStyle _createTextStyle({
    required ColorScheme colorScheme,
    required double height,
    required FontWeight weight,
    required double size,
    Color? color,
  }) {
    return GoogleFonts.openSans(
      color: color ?? colorScheme.secondary,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: 0,
    );
  }

  static final TextStyle defaultStyle = GoogleFonts.openSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.black87,
    letterSpacing: 0,
    height: 16 / 14,
  );
}
