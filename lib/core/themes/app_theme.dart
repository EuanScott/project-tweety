import 'package:flutter/material.dart';
import 'package:project_tweety/core/themes/CustomNavigationBarTheme.dart';
import 'package:project_tweety/core/themes/card_theme.dart';
import 'package:project_tweety/core/themes/color_theme.dart';
import 'package:project_tweety/core/themes/text_theme.dart';

import 'app_bar_theme.dart';
import 'button_theme.dart';

class AppTheme {
  static ThemeData lightTheme() {
    final colorScheme = ColorTheme.lightColorScheme;
    return ThemeData(
      useMaterial3: true,
      appBarTheme: CustomAppBarTheme.appBarTheme(colorScheme),
      cardTheme: CustomCardTheme.cardThemeData(colorScheme),
      colorScheme: ColorTheme.lightColorScheme,
      elevatedButtonTheme: CustomButtonTheme.elevatedButtonTheme(colorScheme),
      navigationBarTheme: CustomNavigationBarTheme.customNavigationBarTheme(
        colorScheme,
      ),
      scaffoldBackgroundColor: ColorTheme.surfaceLight,
      textButtonTheme: CustomButtonTheme.textButtonTheme(colorScheme),
      textTheme: CustomTextTheme.buildTextTheme(colorScheme),
    );
  }

  static ThemeData darkTheme() {
    final colorScheme = ColorTheme.darkColorScheme;
    return ThemeData(
      useMaterial3: true,
      appBarTheme: CustomAppBarTheme.appBarTheme(colorScheme),
      cardTheme: CustomCardTheme.cardThemeData(colorScheme),
      colorScheme: ColorTheme.darkColorScheme,
      elevatedButtonTheme: CustomButtonTheme.elevatedButtonTheme(colorScheme),
      navigationBarTheme: CustomNavigationBarTheme.customNavigationBarTheme(
        colorScheme,
      ),
      scaffoldBackgroundColor: ColorTheme.surfaceDark,
      textButtonTheme: CustomButtonTheme.textButtonTheme(colorScheme),
      textTheme: CustomTextTheme.buildTextTheme(colorScheme),
    );
  }
}
