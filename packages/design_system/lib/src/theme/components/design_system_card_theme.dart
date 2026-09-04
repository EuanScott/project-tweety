import 'package:material_ui/material_ui.dart';

/// Cards read as a raised layer through shadow alone.
///
/// No outline: this scheme resolves `outlineVariant` to solid black in light
/// mode and solid white in dark, so a themed border draws a hard line rather
/// than a soft edge. Elevation carries the layering instead.
class DesignSystemCardTheme {
  new _();

  static CardThemeData build(ColorScheme colorScheme) {
    return CardThemeData(
      color: colorScheme.surfaceContainer,
      elevation: 3,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
