import 'package:flutter/material.dart';
import 'package:project_tweety/core/themes/color_theme.dart';
import 'package:project_tweety/core/themes/text_theme.dart';

import 'button_theme.dart';

class AppTheme {
  static ThemeData lightTheme() {
    final colorScheme = ColorTheme.lightColorScheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorTheme.lightColorScheme,
      elevatedButtonTheme: CustomButtonTheme.elevatedButtonTheme(colorScheme),
      textButtonTheme: CustomButtonTheme.textButtonTheme(colorScheme),
      textTheme: CustomTextTheme.buildTextTheme(colorScheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 2,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 3,

        indicatorColor: colorScheme.primary,

        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          final color = states.contains(WidgetState.selected)
              ? colorScheme.onPrimary
              : colorScheme.primary;

          return IconThemeData(color: color);
        }),

        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          final color = states.contains(WidgetState.selected)
              ? colorScheme.primary
              : colorScheme.primary;

          return TextStyle(color: color);
        }),
      ),
    );
  }

  static ThemeData darkTheme() {
    final colorScheme = ColorTheme.darkColorScheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorTheme.darkColorScheme,
      elevatedButtonTheme: CustomButtonTheme.elevatedButtonTheme(colorScheme),
      textButtonTheme: CustomButtonTheme.textButtonTheme(colorScheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 2,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 3,

        indicatorColor: colorScheme.primary,

        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          final color = states.contains(WidgetState.selected)
              ? colorScheme.onPrimary
              : colorScheme.primary;

          return IconThemeData(color: color);
        }),

        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          final color = states.contains(WidgetState.selected)
              ? colorScheme.primary
              : colorScheme.primary;

          return TextStyle(color: color);
        }),
      ),
    );
  }
}
