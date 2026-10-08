import 'package:material_ui/material_ui.dart';

/// The fill of a Cupertino inset grouped card.
///
/// White in light mode. In dark mode the scheme's `surface` is the raised
/// colour, because the page itself uses the scaffold background.
Color groupedRaisedColour(ThemeData theme) {
  if (theme.brightness == .dark) {
    return theme.colorScheme.surface;
  }

  return theme.colorScheme.surfaceContainer;
}
