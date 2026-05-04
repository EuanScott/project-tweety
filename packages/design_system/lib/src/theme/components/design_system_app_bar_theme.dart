import 'package:flutter/material.dart';

import 'design_system_text_theme.dart';

class DesignSystemAppBarTheme {
  DesignSystemAppBarTheme._();

  static AppBarTheme light(ColorScheme colorScheme) {
    final textTheme = DesignSystemTextTheme.build(colorScheme);

    return AppBarTheme(
      backgroundColor: colorScheme.primary,
      centerTitle: false,
      elevation: 2,
      foregroundColor: colorScheme.onPrimary,
      titleTextStyle: textTheme.headlineSmall?.copyWith(
        color: colorScheme.onPrimary,
      ),
      toolbarTextStyle: textTheme.labelLarge?.copyWith(
        color: colorScheme.onPrimary,
      ),
    );
  }

  static AppBarTheme dark(ColorScheme colorScheme) {
    final textTheme = DesignSystemTextTheme.build(colorScheme);

    return AppBarTheme(
      backgroundColor: colorScheme.surface,
      centerTitle: false,
      elevation: 2,
      foregroundColor: colorScheme.onSurface,
      titleTextStyle: textTheme.headlineSmall?.copyWith(
        color: colorScheme.onSurface,
      ),
      toolbarTextStyle: textTheme.labelLarge?.copyWith(
        color: colorScheme.onSurface,
      ),
    );
  }
}
