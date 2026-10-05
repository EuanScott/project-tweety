import 'package:material_ui/material_ui.dart';

import 'design_brand.dart';

/// Maps high-level brand tokens into Material [ColorScheme] instances.
class DesignColorSchemes {
  new _();

  /// Builds the light-mode color scheme for a given [brand].
  static ColorScheme light(DesignBrand brand) {
    return ColorScheme.light(
      primary: brand.primaryLight,
      onPrimary: brand.onPrimaryLight,
      secondary: brand.secondaryLight,
      onSecondary: brand.onSecondaryLight,
      error: brand.error,
      onError: brand.onError,
      errorContainer: brand.errorContainerLight,
      onErrorContainer: brand.onErrorContainerLight,
      surface: brand.surfaceLight,
      onSurface: brand.onSurfaceLight,
      surfaceContainer: brand.surfaceContainerLight,
      surfaceContainerHighest: brand.surfaceVariantLight,
      outline: brand.outline,
      surfaceTint: Colors.transparent,
    );
  }

  /// Builds the dark-mode color scheme for a given [brand].
  static ColorScheme dark(DesignBrand brand) {
    return ColorScheme.dark(
      primary: brand.primaryDark,
      onPrimary: brand.onPrimaryDark,
      secondary: brand.secondaryDark,
      onSecondary: brand.onSecondaryDark,
      error: brand.error,
      onError: brand.onError,
      errorContainer: brand.errorContainerDark,
      onErrorContainer: brand.onErrorContainerDark,
      surface: brand.surfaceVariantDark,
      onSurface: brand.onSurfaceDark,
      surfaceContainer: brand.surfaceContainerDark,
      surfaceContainerHighest: brand.surfaceDark,
      outline: brand.outline,
      surfaceTint: Colors.transparent,
    );
  }
}
