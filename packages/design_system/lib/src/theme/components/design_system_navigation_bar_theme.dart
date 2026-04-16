import 'package:flutter/material.dart';

class DesignSystemNavigationBarTheme {
  DesignSystemNavigationBarTheme._();

  static NavigationBarThemeData build(ColorScheme colorScheme) {
    return NavigationBarThemeData(
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
    );
  }
}
