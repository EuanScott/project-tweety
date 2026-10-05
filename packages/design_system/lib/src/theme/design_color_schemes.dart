import 'package:material_ui/material_ui.dart';

import 'design_brand.dart';

/// Maps high-level brand tokens into Material [ColorScheme] instances.
///
/// Navigation roles are derived from the brand, not set per brand:
/// `surfaceContainerHigh` is the neutral navigation surface,
/// `primaryContainer` is the soft tint behind the selected item, and
/// `onSurfaceVariant` is the muted ink for unselected items.
class DesignColorSchemes {
  new _();

  static const double _lightNavigationShade = 0.04;
  static const double _lightIndicatorTint = 0.12;
  static const double _darkIndicatorTint = 0.24;
  static const double _lightMutedInkOpacity = 0.6;
  static const double _darkMutedInkOpacity = 0.7;

  /// Builds the light-mode color scheme for a given [brand].
  static ColorScheme light(DesignBrand brand) {
    final navigationSurface = Color.lerp(
      brand.surfaceLight,
      Colors.black,
      _lightNavigationShade,
    )!;

    return ColorScheme.light(
      primary: brand.primaryLight,
      onPrimary: brand.onPrimaryLight,
      primaryContainer: Color.lerp(
        navigationSurface,
        brand.primaryLight,
        _lightIndicatorTint,
      ),
      onPrimaryContainer: brand.primaryLight,
      secondary: brand.secondaryLight,
      onSecondary: brand.onSecondaryLight,
      error: brand.error,
      onError: brand.onError,
      errorContainer: brand.errorContainerLight,
      onErrorContainer: brand.onErrorContainerLight,
      surface: brand.surfaceLight,
      onSurface: brand.onSurfaceLight,
      onSurfaceVariant: brand.onSurfaceLight.withValues(
        alpha: _lightMutedInkOpacity,
      ),
      surfaceContainer: brand.surfaceContainerLight,
      surfaceContainerHigh: navigationSurface,
      surfaceContainerHighest: brand.surfaceVariantLight,
      outline: brand.outline,
      surfaceTint: Colors.transparent,
    );
  }

  /// Builds the dark-mode color scheme for a given [brand].
  static ColorScheme dark(DesignBrand brand) {
    final navigationSurface = brand.surfaceVariantDark;

    return ColorScheme.dark(
      primary: brand.primaryDark,
      onPrimary: brand.onPrimaryDark,
      primaryContainer: Color.lerp(
        navigationSurface,
        brand.primaryDark,
        _darkIndicatorTint,
      ),
      // A dark primary can fail on its own tint, so the selected icon uses
      // the light ink, as Material 3's dark container roles do.
      onPrimaryContainer: brand.onSurfaceDark,
      secondary: brand.secondaryDark,
      onSecondary: brand.onSecondaryDark,
      error: brand.error,
      onError: brand.onError,
      errorContainer: brand.errorContainerDark,
      onErrorContainer: brand.onErrorContainerDark,
      surface: brand.surfaceVariantDark,
      onSurface: brand.onSurfaceDark,
      onSurfaceVariant: brand.onSurfaceDark.withValues(
        alpha: _darkMutedInkOpacity,
      ),
      surfaceContainer: brand.surfaceContainerDark,
      surfaceContainerHigh: navigationSurface,
      surfaceContainerHighest: brand.surfaceDark,
      outline: brand.outline,
      surfaceTint: Colors.transparent,
    );
  }
}
