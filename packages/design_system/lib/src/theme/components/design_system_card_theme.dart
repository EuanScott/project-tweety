import 'package:material_ui/material_ui.dart';

class DesignSystemCardTheme {
  new _();

  static CardThemeData build(ColorScheme colorScheme) {
    return CardThemeData(color: colorScheme.surface, elevation: 3);
  }
}
