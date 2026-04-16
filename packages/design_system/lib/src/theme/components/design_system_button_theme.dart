import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DesignSystemButtonTheme {
  DesignSystemButtonTheme._();

  static TextStyle _buttonTextStyle() {
    return GoogleFonts.openSans(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      height: 1.25,
      letterSpacing: 0,
    );
  }

  static ElevatedButtonThemeData elevated(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        disabledBackgroundColor: colorScheme.onSurface.withAlpha(120),
        disabledForegroundColor: colorScheme.onSurface.withAlpha(120),
        elevation: 2,
        foregroundColor: colorScheme.onPrimary,
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: _buttonTextStyle(),
      ),
    );
  }

  static OutlinedButtonThemeData outlined(ColorScheme colorScheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        disabledForegroundColor: colorScheme.onSurface.withAlpha(120),
        foregroundColor: colorScheme.primary,
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(color: colorScheme.primary, width: 1),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: _buttonTextStyle(),
      ),
    );
  }

  static TextButtonThemeData text(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        disabledForegroundColor: colorScheme.onSurface.withAlpha(120),
        foregroundColor: colorScheme.primary,
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: _buttonTextStyle(),
      ),
    );
  }
}
