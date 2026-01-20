import 'package:flutter/material.dart';
import 'package:project_tweety/core/themes/text_theme.dart';

class CustomButtonTheme {
  static ElevatedButtonThemeData elevatedButtonTheme(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withAlpha(120);
            }
            return colorScheme.primary;
          },
        ),
        foregroundColor: WidgetStateProperty.all<Color>(colorScheme.onPrimary),
        textStyle: WidgetStateProperty.all<TextStyle>(
          const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            fontFamily: 'Open-sans',
          ),
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        elevation: WidgetStateProperty.resolveWith<double>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return 1.0;
            }
            return 2.0;
          },
        ),
        minimumSize: WidgetStateProperty.all<Size>(
          const Size(double.infinity, 50),
        ),
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.symmetric(vertical: 12.0),
        ),
      ),
    );
  }

  /// Creates the text button theme data for secondary actions
  static TextButtonThemeData textButtonTheme(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withAlpha(120);
            }
            return colorScheme.primary;
          },
        ),
        textStyle: WidgetStateProperty.all<TextStyle>(
          CustomTextTheme.buttonTextStyle(colorScheme),
        ),
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }
}
