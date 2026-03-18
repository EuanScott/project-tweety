import 'package:flutter/material.dart';

class CustomButtonTheme {
  static const _buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    fontFamily: 'Open-sans',
    height: 1.25,
  );

  static ElevatedButtonThemeData elevatedButtonTheme(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        disabledBackgroundColor: colorScheme.onSurface.withAlpha(120),
        disabledForegroundColor: colorScheme.onSurface.withAlpha(120),
        elevation: 2,
        foregroundColor: colorScheme.onPrimary,
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: _buttonTextStyle,
      ),
    );
  }

  static OutlinedButtonThemeData outlinedButtonTheme(ColorScheme colorScheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        disabledForegroundColor: colorScheme.onSurface.withAlpha(120),
        foregroundColor: colorScheme.primary,
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        side: BorderSide(color: colorScheme.primary, width: 1.0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: _buttonTextStyle,
      ),
    );
  }

  static TextButtonThemeData textButtonTheme(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        disabledForegroundColor: colorScheme.onSurface.withAlpha(120),
        foregroundColor: colorScheme.primary,
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: _buttonTextStyle,
      ),
    );
  }
}
