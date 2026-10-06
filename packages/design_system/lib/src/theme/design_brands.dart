import 'package:material_ui/material_ui.dart';

import 'design_brand.dart';

/// Predefined brand configurations for Tweety applications.
///
/// Each preset is one theme colour: a complete brand, named after a place or
/// a plant. Consuming apps can either use one of these directly or define and
/// pass their own [DesignBrand] instances.
class DesignBrands {
  new _();

  static const Color _onSurfaceLight = Colors.black87;
  static const Color _onSurfaceDark = Colors.white;
  static const Color _surfaceContainerLight = Colors.white;
  static const Color _surfaceContainerDark = Color(0xFF383838);
  static const Color _outline = Color(0xFFBDBDBD);
  static const Color _disabledColor = Color(0xFF8A9A9A);
  static const Color _error = Color(0xFFD32F2F);
  static const Color _onError = Colors.white;
  static const Color _errorContainerLight = Color(0xFFFDECEC);
  static const Color _onErrorContainerLight = Color(0xFFD32F2F);
  static const Color _errorContainerDark = Color(0xFF2C2C2C);
  static const Color _onErrorContainerDark = Colors.white;
  static const Color _success = Color(0xFF388E3C);
  static const Color _warning = Color(0xFFFFA000);

  /// Teal with plum, from Norway. The default theme colour.
  static const fjord = DesignBrand(
    name: 'Fjord',
    primaryLight: Color(0xFF0E7474),
    onPrimaryLight: Colors.white,
    secondaryLight: Color(0xFF8E3B76),
    onSecondaryLight: Colors.white,
    primaryDark: Color(0xFF1BA6A6),
    onPrimaryDark: Color(0xFF002020),
    secondaryDark: Color(0xFFD68FC2),
    onSecondaryDark: Color(0xFF2E0A25),
    disabledColor: _disabledColor,
    error: _error,
    onError: _onError,
    errorContainerLight: _errorContainerLight,
    onErrorContainerLight: _onErrorContainerLight,
    errorContainerDark: _errorContainerDark,
    onErrorContainerDark: _onErrorContainerDark,
    success: _success,
    warning: _warning,
    surfaceLight: Color(0xFFF4F6F7),
    surfaceVariantLight: Color(0xFFEFF2F3),
    onSurfaceLight: _onSurfaceLight,
    surfaceContainerLight: _surfaceContainerLight,
    surfaceDark: Color(0xFF121212),
    surfaceVariantDark: Color(0xFF2C2C2C),
    onSurfaceDark: _onSurfaceDark,
    surfaceContainerDark: _surfaceContainerDark,
    outline: _outline,
  );

  /// Olive with protea pink, from South Africa.
  static const fynbos = DesignBrand(
    name: 'Fynbos',
    primaryLight: Color(0xFF56691C),
    onPrimaryLight: Colors.white,
    secondaryLight: Color(0xFFA3365F),
    onSecondaryLight: Colors.white,
    primaryDark: Color(0xFFB5C96A),
    onPrimaryDark: Color(0xFF1C2200),
    secondaryDark: Color(0xFFF2A3BF),
    onSecondaryDark: Color(0xFF3D0A20),
    disabledColor: _disabledColor,
    error: _error,
    onError: _onError,
    errorContainerLight: _errorContainerLight,
    onErrorContainerLight: _onErrorContainerLight,
    errorContainerDark: _errorContainerDark,
    onErrorContainerDark: _onErrorContainerDark,
    success: _success,
    warning: _warning,
    surfaceLight: Color(0xFFF6F7F2),
    surfaceVariantLight: Color(0xFFF0F2EA),
    onSurfaceLight: _onSurfaceLight,
    surfaceContainerLight: _surfaceContainerLight,
    surfaceDark: Color(0xFF121310),
    surfaceVariantDark: Color(0xFF24261E),
    onSurfaceDark: _onSurfaceDark,
    surfaceContainerDark: _surfaceContainerDark,
    outline: _outline,
  );

  /// Red ochre with desert-sky blue, from South Africa.
  static const kalahari = DesignBrand(
    name: 'Kalahari',
    primaryLight: Color(0xFFA8441F),
    onPrimaryLight: Colors.white,
    secondaryLight: Color(0xFF2F5F8A),
    onSecondaryLight: Colors.white,
    primaryDark: Color(0xFFF39A74),
    onPrimaryDark: Color(0xFF3A1405),
    secondaryDark: Color(0xFF9CC3EE),
    onSecondaryDark: Color(0xFF0A2540),
    disabledColor: _disabledColor,
    error: _error,
    onError: _onError,
    errorContainerLight: _errorContainerLight,
    onErrorContainerLight: _onErrorContainerLight,
    errorContainerDark: _errorContainerDark,
    onErrorContainerDark: _onErrorContainerDark,
    success: _success,
    warning: _warning,
    surfaceLight: Color(0xFFF8F5F3),
    surfaceVariantLight: Color(0xFFF4EFEC),
    onSurfaceLight: _onSurfaceLight,
    surfaceContainerLight: _surfaceContainerLight,
    surfaceDark: Color(0xFF141110),
    surfaceVariantDark: Color(0xFF2A2321),
    onSurfaceDark: _onSurfaceDark,
    surfaceContainerDark: _surfaceContainerDark,
    outline: _outline,
  );

  /// Heather purple with cloudberry gold, from Norway.
  static const lyng = DesignBrand(
    name: 'Lyng',
    primaryLight: Color(0xFF77449A),
    onPrimaryLight: Colors.white,
    secondaryLight: Color(0xFF8A6100),
    onSecondaryLight: Colors.white,
    primaryDark: Color(0xFFD2A6EF),
    onPrimaryDark: Color(0xFF2A0F45),
    secondaryDark: Color(0xFFF2C14E),
    onSecondaryDark: Color(0xFF2A1F00),
    disabledColor: _disabledColor,
    error: _error,
    onError: _onError,
    errorContainerLight: _errorContainerLight,
    onErrorContainerLight: _onErrorContainerLight,
    errorContainerDark: _errorContainerDark,
    onErrorContainerDark: _onErrorContainerDark,
    success: _success,
    warning: _warning,
    surfaceLight: Color(0xFFF7F5F8),
    surfaceVariantLight: Color(0xFFF2EFF4),
    onSurfaceLight: _onSurfaceLight,
    surfaceContainerLight: _surfaceContainerLight,
    surfaceDark: Color(0xFF141216),
    surfaceVariantDark: Color(0xFF28232D),
    onSurfaceDark: _onSurfaceDark,
    surfaceContainerDark: _surfaceContainerDark,
    outline: _outline,
  );

  /// Gorse gold with slate blue, from Scotland. Light mode uses a dark
  /// mustard, because white text fails on the bright gorse yellow.
  static const whin = DesignBrand(
    name: 'Whin',
    primaryLight: Color(0xFF7A5C00),
    onPrimaryLight: Colors.white,
    secondaryLight: Color(0xFF3D5A80),
    onSecondaryLight: Colors.white,
    primaryDark: Color(0xFFF2C230),
    onPrimaryDark: Color(0xFF2A1F00),
    secondaryDark: Color(0xFFA9C1E6),
    onSecondaryDark: Color(0xFF0D2240),
    disabledColor: _disabledColor,
    error: _error,
    onError: _onError,
    errorContainerLight: _errorContainerLight,
    onErrorContainerLight: _onErrorContainerLight,
    errorContainerDark: _errorContainerDark,
    onErrorContainerDark: _onErrorContainerDark,
    success: _success,
    warning: _warning,
    surfaceLight: Color(0xFFF8F7F2),
    surfaceVariantLight: Color(0xFFF3F2EA),
    onSurfaceLight: _onSurfaceLight,
    surfaceContainerLight: _surfaceContainerLight,
    surfaceDark: Color(0xFF13120F),
    surfaceVariantDark: Color(0xFF26241D),
    onSurfaceDark: _onSurfaceDark,
    surfaceContainerDark: _surfaceContainerDark,
    outline: _outline,
  );

  /// Port-wine red with tile blue, from Portugal. The red is darker and
  /// bluer than the error red, so a primary button never reads as an error.
  static const douro = DesignBrand(
    name: 'Douro',
    primaryLight: Color(0xFF8C1D3A),
    onPrimaryLight: Colors.white,
    secondaryLight: Color(0xFF2F5E9E),
    onSecondaryLight: Colors.white,
    primaryDark: Color(0xFFF0A3B5),
    onPrimaryDark: Color(0xFF3D0A1A),
    secondaryDark: Color(0xFFA7C4EF),
    onSecondaryDark: Color(0xFF0A2245),
    disabledColor: _disabledColor,
    error: _error,
    onError: _onError,
    errorContainerLight: _errorContainerLight,
    onErrorContainerLight: _onErrorContainerLight,
    errorContainerDark: _errorContainerDark,
    onErrorContainerDark: _onErrorContainerDark,
    success: _success,
    warning: _warning,
    surfaceLight: Color(0xFFF8F4F5),
    surfaceVariantLight: Color(0xFFF4EEF0),
    onSurfaceLight: _onSurfaceLight,
    surfaceContainerLight: _surfaceContainerLight,
    surfaceDark: Color(0xFF141012),
    surfaceVariantDark: Color(0xFF2A2226),
    onSurfaceDark: _onSurfaceDark,
    surfaceContainerDark: _surfaceContainerDark,
    outline: _outline,
  );

  /// Mountain black with sea-loch blue, from Scotland. The primary inverts to
  /// near-white in dark mode, because near-black has no contrast there.
  static const cuillin = DesignBrand(
    name: 'Cuillin',
    primaryLight: Color(0xFF1F2326),
    onPrimaryLight: Colors.white,
    secondaryLight: Color(0xFF3F7A8C),
    onSecondaryLight: Colors.white,
    primaryDark: Color(0xFFE6E8EA),
    onPrimaryDark: Color(0xFF1A1C1E),
    secondaryDark: Color(0xFF8CC4D4),
    onSecondaryDark: Color(0xFF0A2A33),
    disabledColor: _disabledColor,
    error: _error,
    onError: _onError,
    errorContainerLight: _errorContainerLight,
    onErrorContainerLight: _onErrorContainerLight,
    errorContainerDark: _errorContainerDark,
    onErrorContainerDark: _onErrorContainerDark,
    success: _success,
    warning: _warning,
    surfaceLight: Color(0xFFF5F6F7),
    surfaceVariantLight: Color(0xFFF0F2F3),
    onSurfaceLight: _onSurfaceLight,
    surfaceContainerLight: _surfaceContainerLight,
    surfaceDark: Color(0xFF121314),
    surfaceVariantDark: Color(0xFF262829),
    onSurfaceDark: _onSurfaceDark,
    surfaceContainerDark: _surfaceContainerDark,
    outline: _outline,
  );

  /// Every bundled brand, for code that must cover each one, such as tests.
  /// The order carries no meaning.
  static const List<DesignBrand> all = [
    fjord,
    fynbos,
    kalahari,
    lyng,
    whin,
    douro,
    cuillin,
  ];
}
