import 'package:material_ui/material_ui.dart';

import 'design_brand.dart';

/// Predefined brand configurations for Tweety applications.
///
/// This is the default place to keep package-owned brand presets. Consuming
/// apps can either use one of these directly or define and pass their own
/// [DesignBrand] instances.
class DesignBrands {
  new _();

  /// The default consumer-facing Tweety brand.
  static const tweetyB2c = DesignBrand(
    name: 'Tweety B2C',
    primaryLight: Color(0xFF0E7474),
    onPrimaryLight: Colors.white,
    secondaryLight: Color(0xFF8E3B76),
    onSecondaryLight: Colors.white,
    primaryDark: Color(0xFF1BA6A6),
    onPrimaryDark: Color(0xFF002020),
    secondaryDark: Color(0xFFD68FC2),
    onSecondaryDark: Color(0xFF2E0A25),
    disabledColor: Color(0xFF8A9A9A),
    error: Color(0xFFD32F2F),
    onError: Colors.white,
    errorContainerLight: Color(0xFFFDECEC),
    onErrorContainerLight: Color(0xFFD32F2F),
    errorContainerDark: Color(0xFF2C2C2C),
    onErrorContainerDark: Colors.white,
    success: Color(0xFF388E3C),
    warning: Color(0xFFFFA000),
    info: Color(0xFF1976D2),
    surfaceLight: Color(0xFFF4F6F7),
    surfaceVariantLight: Color(0xFFEFF2F3),
    onSurfaceLight: Colors.black87,
    surfaceContainerLight: Colors.white,
    surfaceDark: Color(0xFF121212),
    surfaceVariantDark: Color(0xFF2C2C2C),
    onSurfaceDark: Colors.white,
    surfaceContainerDark: Color(0xFF383838),
    outline: Color(0xFFBDBDBD),
  );

  /// Every bundled brand, for code that must cover each one, such as tests.
  static const List<DesignBrand> all = [tweetyB2c];
}
