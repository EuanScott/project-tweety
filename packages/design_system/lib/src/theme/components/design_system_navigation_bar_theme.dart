import 'package:material_ui/material_ui.dart';

import 'design_system_text_theme.dart';

class DesignSystemNavigationBarTheme {
  new _();

  static NavigationBarThemeData build(ColorScheme colorScheme) {
    final labelStyle = DesignSystemTextTheme.build(colorScheme).labelMedium;

    return NavigationBarThemeData(
      backgroundColor: colorScheme.surfaceContainerHigh,
      elevation: 3,
      indicatorColor: colorScheme.primaryContainer,
      indicatorShape: const StadiumBorder(),
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
        final color = states.contains(WidgetState.selected)
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurfaceVariant;

        return IconThemeData(color: color);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
        final style = labelStyle ?? const TextStyle();

        return states.contains(WidgetState.selected)
            ? style.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              )
            : style.copyWith(color: colorScheme.onSurfaceVariant);
      }),
    );
  }
}
