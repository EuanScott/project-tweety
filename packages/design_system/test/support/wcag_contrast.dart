import 'package:material_ui/material_ui.dart';

/// The WCAG 2 contrast ratio of [foreground] drawn on [background].
///
/// A translucent [foreground] is blended onto [background] first, so text
/// colours such as black at 87% are measured as they render.
double contrastRatio(Color foreground, Color background) {
  final blended = Color.alphaBlend(foreground, background);
  final a = blended.computeLuminance();
  final b = background.computeLuminance();

  return (a > b ? a + 0.05 : b + 0.05) / (a > b ? b + 0.05 : a + 0.05);
}
