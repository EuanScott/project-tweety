import 'package:flutter/material.dart';
import 'package:project_tweety/core/themes/color_theme.dart';

import 'button_theme.dart';

class AppTheme {
  static ThemeData lightTheme() {
    final colorScheme = ColorTheme.lightColorScheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorTheme.lightColorScheme,
      elevatedButtonTheme: CustomButtonTheme.elevatedButtonTheme(colorScheme),
      textButtonTheme: CustomButtonTheme.textButtonTheme(colorScheme),
    );
  }

  static ThemeData darkTheme() {
    final colorScheme = ColorTheme.darkColorScheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorTheme.darkColorScheme,
      elevatedButtonTheme: CustomButtonTheme.elevatedButtonTheme(colorScheme),
      textButtonTheme: CustomButtonTheme.textButtonTheme(colorScheme),
    );
  }
}
