import 'package:flutter/material.dart';

import 'design_system_text_theme.dart';

class DesignSystemNavigationRailTheme {
  DesignSystemNavigationRailTheme._();

  static NavigationRailThemeData build(
    ColorScheme colorScheme, {
    required Color backgroundColor,
    required Color onBackgroundColor,
    required Color indicatorColor,
    required Color onIndicatorColor,
  }) {
    final labelStyle = DesignSystemTextTheme.build(colorScheme).labelMedium;

    return NavigationRailThemeData(
      backgroundColor: backgroundColor,
      elevation: 3,
      indicatorColor: indicatorColor,
      selectedIconTheme: IconThemeData(color: onIndicatorColor),
      unselectedIconTheme: IconThemeData(color: onBackgroundColor),
      selectedLabelTextStyle: (labelStyle ?? const TextStyle()).copyWith(
        color: onIndicatorColor,
      ),
      unselectedLabelTextStyle: (labelStyle ?? const TextStyle()).copyWith(
        color: onBackgroundColor,
      ),
    );
  }
}
