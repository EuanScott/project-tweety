import 'package:material_ui/material_ui.dart';

import 'design_system_text_theme.dart';

class DesignSystemNavigationDrawerTheme {
  new _();

  static NavigationDrawerThemeData build(ColorScheme colorScheme) {
    final labelStyle =
        DesignSystemTextTheme.build(colorScheme).labelLarge ??
        const TextStyle();

    return NavigationDrawerThemeData(
      backgroundColor: colorScheme.surfaceContainerHigh,
      elevation: 3,
      indicatorColor: colorScheme.primaryContainer,
      indicatorShape: const StadiumBorder(),
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
        return states.contains(WidgetState.selected)
            ? labelStyle.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              )
            : labelStyle.copyWith(color: colorScheme.onSurfaceVariant);
      }),
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
        final color = states.contains(WidgetState.selected)
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurfaceVariant;

        return IconThemeData(color: color);
      }),
    );
  }
}
