import 'package:flutter/material.dart';

class CustomAppBarTheme {
  static AppBarTheme appBarTheme(ColorScheme colorScheme) {
    return AppBarTheme(
      backgroundColor: colorScheme.primary,
      centerTitle: false,
      foregroundColor: colorScheme.onPrimary,
      elevation: 2,
    );
  }
}
