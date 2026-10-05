import 'package:material_ui/material_ui.dart';

import 'design_system_text_theme.dart';

class DesignSystemAppBarTheme {
  new _();

  /// A neutral app bar. The bold `primary` title is a deliberate brand
  /// choice, not the platform default.
  static AppBarTheme build(ColorScheme colorScheme) {
    final textTheme = DesignSystemTextTheme.build(colorScheme);

    return AppBarTheme(
      backgroundColor: colorScheme.surface,
      centerTitle: false,
      elevation: 2,
      foregroundColor: colorScheme.onSurface,
      titleTextStyle: textTheme.headlineSmall?.copyWith(
        color: colorScheme.primary,
      ),
      toolbarTextStyle: textTheme.labelLarge?.copyWith(
        color: colorScheme.onSurface,
      ),
    );
  }
}
