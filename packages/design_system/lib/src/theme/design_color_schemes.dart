import 'package:flutter/material.dart';

import 'design_brand.dart';

/// Maps high-level brand tokens into Material [ColorScheme] instances.
class DesignColorSchemes {
  DesignColorSchemes._();

  /// Builds the light-mode color scheme for a given [brand].
  static ColorScheme light(DesignBrand brand) {
    return ColorScheme.light(
      primary: brand.primary,
      onPrimary: brand.onPrimary,
      secondary: brand.secondary,
      onSecondary: brand.onSecondary,
      error: brand.error,
      onError: brand.onPrimary,
      surface: brand.surfaceLight,
      onSurface: brand.onSurfaceLight,
      surfaceContainerHighest: brand.surfaceVariantLight,
      outline: brand.outline,
      surfaceTint: Colors.transparent,
    );
  }

  /// Builds the dark-mode color scheme for a given [brand].
  static ColorScheme dark(DesignBrand brand) {
    return ColorScheme.dark(
      primary: brand.primary,
      onPrimary: brand.onPrimary,
      secondary: brand.secondary,
      onSecondary: brand.onSecondary,
      error: brand.error,
      onError: brand.onPrimary,
      surface: brand.surfaceVariantDark,
      onSurface: brand.onSurfaceDark,
      surfaceContainerHighest: brand.surfaceDark,
      outline: brand.outline,
      surfaceTint: Colors.transparent,
    );
  }
}
