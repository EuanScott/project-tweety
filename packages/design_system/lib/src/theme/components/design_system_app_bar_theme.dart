import 'package:flutter/material.dart';

class DesignSystemAppBarTheme {
  DesignSystemAppBarTheme._();

  static AppBarTheme light(ColorScheme colorScheme) {
    return AppBarTheme(
      backgroundColor: colorScheme.primary,
      centerTitle: false,
      elevation: 2,
      foregroundColor: colorScheme.onPrimary,
    );
  }

  static AppBarTheme dark(ColorScheme colorScheme) {
    return AppBarTheme(
      backgroundColor: colorScheme.surface,
      centerTitle: false,
      elevation: 2,
      foregroundColor: colorScheme.onSurface,
    );
  }
}
