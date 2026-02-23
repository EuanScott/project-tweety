import 'package:flutter/material.dart';

import '../themes/color_theme.dart';

extension ButtonStyleExtensions on ButtonStyle {
  /// Creates a secondary button style variant by only changing the background color
  ButtonStyle asSecondary() {
    return copyWith(
      backgroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return ColorTheme.disabledColor.withAlpha(120);
          }
          return ColorTheme.secondary;
        },
      ),
    );
  }
}
