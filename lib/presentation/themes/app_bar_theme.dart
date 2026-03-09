import 'package:flutter/material.dart';

class CustomAppBarTheme {
  static AppBarTheme lightAppBarTheme(ColorScheme colorScheme) {
    return AppBarTheme(
      backgroundColor: colorScheme.primary,
      centerTitle: false,
      elevation: 2,
      foregroundColor: colorScheme.onPrimary,
    );
  }

  static AppBarTheme darkAppBarTheme(ColorScheme colorScheme) {
    return const AppBarTheme(centerTitle: false, elevation: 2);
  }
}
