import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DesignSystemTextTheme {
  DesignSystemTextTheme._();

  static TextStyle buttonTextStyle(ColorScheme colorScheme) {
    return GoogleFonts.openSans(
      color: colorScheme.primary,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.25,
      letterSpacing: 0,
    );
  }

  static TextTheme build(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: _createTextStyle(
        color: colorScheme.primary,
        colorScheme: colorScheme,
        height: 1.2,
        size: 30,
        weight: FontWeight.w700,
      ),
      titleMedium: _createTextStyle(
        color: colorScheme.primary,
        colorScheme: colorScheme,
        height: 1.25,
        size: 19,
        weight: FontWeight.w700,
      ),
      titleSmall: _createTextStyle(
        color: colorScheme.primary,
        colorScheme: colorScheme,
        height: 1.25,
        size: 16,
        weight: FontWeight.w400,
      ),
      bodyLarge: _createTextStyle(
        color: colorScheme.onPrimary,
        colorScheme: colorScheme,
        height: 1.3,
        size: 14,
        weight: FontWeight.w400,
      ),
      bodySmall: _createTextStyle(
        color: colorScheme.onPrimary,
        colorScheme: colorScheme,
        height: 1.4,
        size: 12,
        weight: FontWeight.w400,
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
