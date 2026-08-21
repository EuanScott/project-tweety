import 'package:material_ui/material_ui.dart';

import 'design_system_text_theme.dart';

class DesignSystemNavigationDrawerTheme {
  new _();

  static NavigationDrawerThemeData build(
    ColorScheme colorScheme, {
    required Color backgroundColor,
    required Color onBackgroundColor,
    required Color indicatorColor,
    required Color onIndicatorColor,
  }) {
    final labelStyle = DesignSystemTextTheme.build(colorScheme).labelLarge;

    return NavigationDrawerThemeData(
      backgroundColor: backgroundColor,
      elevation: 3,
      indicatorColor: indicatorColor,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: .circular(8),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
        final color = states.contains(WidgetState.selected)
            ? onIndicatorColor
            : onBackgroundColor;

        return (labelStyle ?? const TextStyle()).copyWith(color: color);
      }),
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
        final color = states.contains(WidgetState.selected)
            ? onIndicatorColor
            : onBackgroundColor;

        return IconThemeData(color: color);
      }),
    );
  }
}
