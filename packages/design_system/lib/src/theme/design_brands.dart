import 'package:material_ui/material_ui.dart';

import 'design_brand.dart';

/// Predefined brand configurations for Tweety applications.
///
/// This is the default place to keep package-owned brand presets. Consuming
/// apps can either use one of these directly or define and pass their own
/// [DesignBrand] instances.
class DesignBrands {
  DesignBrands._();

  /// The default consumer-facing Tweety brand.
  static const tweetyB2c = DesignBrand(
    name: 'Tweety B2C',
    primary: Color(0xFF1BA6A6),
    onPrimary: Colors.white,
    secondary: Color(0xFFA6A61B),
    onSecondary: Colors.white,
    disabledColor: Color(0xFF8A9A9A),
    error: Color(0xFFD32F2F),
    success: Color(0xFF388E3C),
    warning: Color(0xFFFFA000),
    info: Color(0xFF1976D2),
    surfaceLight: Color(0xFFF4F6F7),
    surfaceVariantLight: Color(0xFFEFF2F3),
    onSurfaceLight: Colors.black87,
    surfaceDark: Color(0xFF121212),
    surfaceVariantDark: Color(0xFF2C2C2C),
    onSurfaceDark: Colors.white,
    navigationSurfaceLight: Color(0xFFE5F5F4),
    onNavigationSurfaceLight: Color(0xFF0F5D5D),
    navigationSelectedLight: Color(0xFFFFFFFF),
    onNavigationSelectedLight: Color(0xFF0F5D5D),
    navigationSurfaceDark: Color(0xFF163434),
    onNavigationSurfaceDark: Color(0xFFE7F5F5),
    navigationSelectedDark: Color(0xFF244A4A),
    onNavigationSelectedDark: Colors.white,
    outline: Color(0xFFBDBDBD),
  );

  /// A business-facing Tweety brand that reuses the same shared theme structure.
  static const tweetyB2b = DesignBrand(
    name: 'Tweety B2B',
    primary: Color(0xFF1F3C88),
    onPrimary: Colors.white,
    secondary: Color(0xFF2D9CDB),
    onSecondary: Colors.white,
    disabledColor: Color(0xFF7D8799),
    error: Color(0xFFD32F2F),
    success: Color(0xFF388E3C),
    warning: Color(0xFFFFA000),
    info: Color(0xFF1976D2),
    surfaceLight: Color(0xFFF4F7FB),
    surfaceVariantLight: Color(0xFFE8EEF5),
    onSurfaceLight: Colors.black87,
    surfaceDark: Color(0xFF0F172A),
    surfaceVariantDark: Color(0xFF1E293B),
    onSurfaceDark: Colors.white,
    navigationSurfaceLight: Color(0xFFEAF1FF),
    onNavigationSurfaceLight: Color(0xFF1F3C88),
    navigationSelectedLight: Color(0xFFFFFFFF),
    onNavigationSelectedLight: Color(0xFF1F3C88),
    navigationSurfaceDark: Color(0xFF17213B),
    onNavigationSurfaceDark: Color(0xFFE7EDFF),
    navigationSelectedDark: Color(0xFF243154),
    onNavigationSelectedDark: Colors.white,
    outline: Color(0xFF94A3B8),
  );
}
