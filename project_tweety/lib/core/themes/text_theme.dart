import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// PayFlexTheme provides centralized theme definition for the PayFlex application.
///
/// This class encapsulates all theme-related elements including typography, colors,
/// and material theme definitions. It pre-loads font weights to ensure consistent
/// font rendering throughout the application.
class CustomTextTheme {

  static TextStyle buttonTextStyle(ColorScheme colorScheme) {
    return GoogleFonts.openSans(
      color: colorScheme.primary,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.25,
      letterSpacing: 0,
    );
  }

  /// Constructs a complete TextTheme with all the text styles needed by the application.
  ///
  /// This method defines 6 key text styles according to the PayFlex design system:
  /// - displayLarge: Hero headlines (36px, bold)
  /// - titleLarge: Section headlines (28px, bold)
  /// - titleMedium: Form field labels when filled (17px, bold)
  /// - titleSmall: Form field labels when empty (17px, regular)
  /// - bodyLarge: Standard paragraph text (16px, regular)
  /// - bodySmall: Small supplementary text (12px, regular)
  ///
  /// Each style has specific line height (expressed as height ratio) for proper vertical
  /// rhythm throughout the application.
  ///
  /// @return A TextTheme with all required text styles configured.
  static TextTheme buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: _createTextStyle(
        colorScheme: colorScheme,
        height: 1.2,
        size: 30,
        weight: FontWeight.w700,
      ),
      titleMedium: _createTextStyle(
        color: colorScheme.primary,
        colorScheme: colorScheme,
        height: 1.25,
        size: 19,
        weight: FontWeight.w700,
      ),
      titleSmall: _createTextStyle(
        colorScheme: colorScheme,
        height: 1.25,
        size: 16,
        weight: FontWeight.w400,
      ),
      bodyLarge: _createTextStyle(
        colorScheme: colorScheme,
        height: 1.3,
        size: 14,
        weight: FontWeight.w400,
      ),
      bodySmall: _createTextStyle(
        colorScheme: colorScheme,
        height: 1.4,
        size: 12,
        weight: FontWeight.w400,
      ),
    );
  }

  /// Creates a TextStyle with consistent properties using Google Fonts.
  ///
  /// This helper method ensures all text styles are created using the same approach,
  /// directly leveraging GoogleFonts.openSans() to create styles with proper font
  /// weight rendering. This avoids issues with weights not being applied correctly
  /// when using fontFamily with TextStyle.
  ///
  /// @param height The line height as a ratio of line height to font size
  /// @param weight The font weight to apply (w400-w900)
  /// @param size The font size in logical pixels
  /// @param color Optional text color (defaults to primaryTextColor)
  /// @return A TextStyle configured with the specified properties
  static TextStyle _createTextStyle({
    required ColorScheme colorScheme,
    required double height,
    required FontWeight weight,
    required double size,
    Color? color,
  }) {
    return GoogleFonts.openSans(
      color: color ?? colorScheme.secondary,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: 0,
    );
  }

  /// Default text style used as a fallback when a requested style is null.
  ///
  /// This style matches bodyLarge (16px regular) to ensure consistent appearance
  /// even when styles might be missing.
  static TextStyle defaultStyle=  GoogleFonts.openSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.black87,
      letterSpacing: 0,
      height: 16 / 14,
    );
}

/// Extension providing modifier methods for TextStyle to easily create variations.
///
/// These extensions allow for fluent chaining of style modifications, such as:
/// `context.bodyLarge.bold.secondary.underlined`
extension TextStyleExtensions on TextStyle {
  /// Changes text color to primary brand color
  // TextStyle get primary => copyWith(color: colorScheme.primary);

  /// Changes text color to secondary text color
  // TextStyle get secondary => copyWith(color: colorScheme.secondary);

  /// Sets font weight to normal/regular (w400)
  TextStyle get regular => _applyWeight(FontWeight.w400);

  /// Sets font weight to medium (w500)
  TextStyle get medium => _applyWeight(FontWeight.w500);

  /// Sets font weight to semi-bold (w600)
  TextStyle get semiBold => _applyWeight(FontWeight.w600);

  /// Sets font weight to bold (w700)
  TextStyle get bold => _applyWeight(FontWeight.w700);

  /// Sets font weight to extra-bold (w900)
  TextStyle get extraBold => _applyWeight(FontWeight.w900);

  /// Adds underline decoration to text
  TextStyle get underlined =>
      copyWith(decoration: TextDecoration.underline, decorationColor: color);

  /// Adds line-through decoration to text
  TextStyle get lineThrough =>
      copyWith(decoration: TextDecoration.lineThrough, decorationColor: color);

  /// Sets font style to italic
  TextStyle get italics => copyWith(fontStyle: FontStyle.italic);

  /// Helper method that properly applies font weights to Google Fonts.
  ///
  /// This method detects if the TextStyle is using an OpenSans Google Font,
  /// and if so, uses GoogleFonts.openSans() directly to ensure proper weight
  /// rendering. This addresses a common issue where simply using copyWith() on
  /// a TextStyle doesn't correctly apply weight changes with Google Fonts.
  ///
  /// @param weight The FontWeight to apply
  /// @return A new TextStyle with the desired weight properly applied
  TextStyle _applyWeight(FontWeight weight) {
    // Check if this is a Google Font
    if (fontFamily != null && fontFamily!.contains('OpenSans')) {
      // If so, use Google Fonts directly to ensure weight is properly applied
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
    // Otherwise use copyWith for other fonts
    return copyWith(fontWeight: weight);
  }
}

/// Extension providing null-safe access to TextTheme styles.
///
/// This extension adds "safe" getters that return a default style instead
/// of null when a particular style isn't defined in the theme.
extension SafeTextThemeExtension on TextTheme {
  /// Helper method to safely get a style or use the default if null
  ///
  /// @param style The style to check
  /// @return The provided style if non-null, otherwise the default style
  TextStyle safeStyle(TextStyle? style) {
    return style ?? CustomTextTheme.defaultStyle;
  }

  /// Safely access displayLarge, falling back to default if null
  TextStyle get safeDisplayLarge => safeStyle(displayLarge);

  /// Safely access safeTitleLarge, falling back to default if null
  TextStyle get safeTitleLarge => safeStyle(titleLarge);

  /// Safely access safeTitleMedium, falling back to default if null
  TextStyle get safeTitleMedium => safeStyle(titleMedium);

  /// Safely access safeTitleSmall, falling back to default if null
  TextStyle get safeTitleSmall => safeStyle(titleSmall);

  /// Safely access bodyLarge, falling back to default if null
  TextStyle get safeBodyLarge => safeStyle(bodyLarge);

  /// Safely access bodySmall, falling back to default if null
  TextStyle get safeBodySmall => safeStyle(bodySmall);
}

/// Extension providing convenient access to text styles from BuildContext.
///
/// This extension allows for more readable and convenient access to text styles
/// directly from context, allowing patterns like:
/// `Text('Example', style: context.bodyLarge.bold)`
extension BuildContextThemeExtension on BuildContext {
  /// Accesses the TextTheme from the current Theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Safely access displayLarge style (36px bold)
  TextStyle get displayLarge => textTheme.safeDisplayLarge;

  /// Safely access titleLarge style (28px bold)
  TextStyle get titleLarge => textTheme.safeTitleLarge;

  /// Safely access titleMedium style (17px bold)
  TextStyle get titleMedium => textTheme.safeTitleMedium;

  /// Safely access titleSmall style (17px regular)
  TextStyle get titleSmall => textTheme.safeTitleSmall;

  /// Safely access bodyLarge style (16px regular)
  TextStyle get bodyLarge => textTheme.safeBodyLarge;

  /// Safely access bodySmall style (12px regular)
  TextStyle get bodySmall => textTheme.safeBodySmall;
}
