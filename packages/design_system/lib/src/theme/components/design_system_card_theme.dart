import 'package:material_ui/material_ui.dart';

/// Cards sit flat on the page and read as a layer through colour alone.
///
/// The card colour, `surfaceContainer`, differs from the page's `surface` in
/// both modes, so neither a shadow nor an outline is needed. No outline: this
/// scheme resolves `outlineVariant` to solid black in light mode and solid
/// white in dark, so a themed border draws a hard line rather than a soft edge.
class DesignSystemCardTheme {
  new _();

  static CardThemeData build(ColorScheme colorScheme) {
    return CardThemeData(
      color: colorScheme.surfaceContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
