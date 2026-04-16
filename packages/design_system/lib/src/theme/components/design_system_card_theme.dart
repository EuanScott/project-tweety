import 'package:flutter/material.dart';

class DesignSystemCardTheme {
  DesignSystemCardTheme._();

  static CardThemeData build(ColorScheme colorScheme) {
    return CardThemeData(
      color: colorScheme.surface,
      elevation: 3,
    );
  }
}
