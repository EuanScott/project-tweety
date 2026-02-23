import 'package:flutter/material.dart';

class CustomCardTheme {
  static CardThemeData cardThemeData(ColorScheme colorScheme) {
    return CardThemeData(color: colorScheme.surface, elevation: 3);
  }
}
