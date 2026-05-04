import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/design_system_text_theme.dart';

/// Convenience modifiers for creating text-weight and decoration variants.
extension TextStyleExtensions on TextStyle {
  TextStyle get regular => _applyWeight(FontWeight.w400);

  TextStyle get medium => _applyWeight(FontWeight.w500);

  TextStyle get semiBold => _applyWeight(FontWeight.w600);

  TextStyle get bold => _applyWeight(FontWeight.w700);

  TextStyle get extraBold => _applyWeight(FontWeight.w900);

  TextStyle get underlined =>
      copyWith(decoration: TextDecoration.underline, decorationColor: color);

  TextStyle get lineThrough =>
      copyWith(decoration: TextDecoration.lineThrough, decorationColor: color);

  TextStyle get italics => copyWith(fontStyle: FontStyle.italic);

  TextStyle _applyWeight(FontWeight weight) {
    if (fontFamily != null && fontFamily!.contains('OpenSans')) {
      return GoogleFonts.openSans(
        fontSize: fontSize,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        fontStyle: fontStyle,
        decoration: decoration,
      );
    }

    return copyWith(fontWeight: weight);
  }
}

/// Null-safe accessors for common text theme styles.
extension SafeTextThemeExtension on TextTheme {
  TextStyle safeStyle(TextStyle? style) {
    return style ?? DesignSystemTextTheme.defaultStyle;
  }

  TextStyle get safeDisplayLarge => safeStyle(displayLarge);

  TextStyle get safeTitleLarge => safeStyle(titleLarge);

  TextStyle get safeTitleMedium => safeStyle(titleMedium);

  TextStyle get safeTitleSmall => safeStyle(titleSmall);

  TextStyle get safeHeadlineSmall => safeStyle(headlineSmall);

  TextStyle get safeBodyLarge => safeStyle(bodyLarge);

  TextStyle get safeBodyMedium => safeStyle(bodyMedium);

  TextStyle get safeBodySmall => safeStyle(bodySmall);

  TextStyle get safeLabelLarge => safeStyle(labelLarge);

  TextStyle get safeLabelMedium => safeStyle(labelMedium);
}

/// Convenience accessors for commonly used text styles from [BuildContext].
extension BuildContextThemeExtension on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;

  TextStyle get displayLarge => textTheme.safeDisplayLarge;

  TextStyle get titleLarge => textTheme.safeTitleLarge;

  TextStyle get titleMedium => textTheme.safeTitleMedium;

  TextStyle get titleSmall => textTheme.safeTitleSmall;

  TextStyle get headlineSmall => textTheme.safeHeadlineSmall;

  TextStyle get bodyLarge => textTheme.safeBodyLarge;

  TextStyle get bodyMedium => textTheme.safeBodyMedium;

  TextStyle get bodySmall => textTheme.safeBodySmall;

  TextStyle get labelLarge => textTheme.safeLabelLarge;

  TextStyle get labelMedium => textTheme.safeLabelMedium;
}
