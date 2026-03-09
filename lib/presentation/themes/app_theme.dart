import 'package:flutter/material.dart';
import 'package:project_tweety/presentation/themes/nav_bar_theme.dart';
import 'package:project_tweety/presentation/themes/card_theme.dart';
import 'package:project_tweety/presentation/themes/color_theme.dart';
import 'package:project_tweety/presentation/themes/text_theme.dart';

import 'app_bar_theme.dart';
import 'button_theme.dart';

class AppTheme {
  static ThemeData lightTheme() {
    final colorScheme = ColorTheme.lightColorScheme;
    return ThemeData(
      useMaterial3: true,
      appBarTheme: CustomAppBarTheme.lightAppBarTheme(colorScheme),
      cardTheme: CustomCardTheme.cardThemeData(colorScheme),
      colorScheme: ColorTheme.lightColorScheme,
      elevatedButtonTheme: CustomButtonTheme.elevatedButtonTheme(colorScheme),
      navigationBarTheme: CustomNavigationBarTheme.navBarTheme(
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
      appBarTheme: CustomAppBarTheme.darkAppBarTheme(colorScheme),
      cardTheme: CustomCardTheme.cardThemeData(colorScheme),
      colorScheme: ColorTheme.darkColorScheme,
      elevatedButtonTheme: CustomButtonTheme.elevatedButtonTheme(colorScheme),
      navigationBarTheme: CustomNavigationBarTheme.navBarTheme(
        colorScheme,
      ),
      scaffoldBackgroundColor: ColorTheme.surfaceDark,
      textButtonTheme: CustomButtonTheme.textButtonTheme(colorScheme),
      textTheme: CustomTextTheme.buildTextTheme(colorScheme),
    );
  }
}
