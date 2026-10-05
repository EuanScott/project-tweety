import 'package:material_ui/material_ui.dart';

import 'design_system_text_theme.dart';

class DesignSystemNavigationRailTheme {
  new _();

  static NavigationRailThemeData build(ColorScheme colorScheme) {
    final labelStyle =
        DesignSystemTextTheme.build(colorScheme).labelMedium ??
        const TextStyle();

    return NavigationRailThemeData(
      backgroundColor: colorScheme.surfaceContainerHigh,
      elevation: 3,
      indicatorColor: colorScheme.primaryContainer,
      indicatorShape: const StadiumBorder(),
      selectedIconTheme: IconThemeData(color: colorScheme.onPrimaryContainer),
      unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      selectedLabelTextStyle: labelStyle.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelTextStyle: labelStyle.copyWith(
        color: colorScheme.onSurface,
      ),
    );
  }
}
