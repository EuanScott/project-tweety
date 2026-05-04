import 'package:flutter/material.dart';

import 'components/design_system_app_bar_theme.dart';
import 'components/design_system_bottom_sheet_theme.dart';
import 'components/design_system_button_theme.dart';
import 'components/design_system_card_theme.dart';
import 'components/design_system_navigation_bar_theme.dart';
import 'components/design_system_radio_theme.dart';
import 'components/design_system_text_theme.dart';
import 'design_brand.dart';
import 'design_brands.dart';
import 'design_color_schemes.dart';

/// Builds the shared Material theme for consuming applications.
///
/// The structure of the theme is shared across apps while brand tokens are
/// supplied through [DesignBrand]. This keeps the visual system consistent
/// while still allowing different branded experiences.
class DesignSystemTheme {
  DesignSystemTheme._();

  /// Builds the light theme for a given [brand].
  static ThemeData light({DesignBrand brand = DesignBrands.tweetyB2c}) {
    final colorScheme = DesignColorSchemes.light(brand);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: brand.surfaceLight,
      dividerColor: colorScheme.primary,
      appBarTheme: DesignSystemAppBarTheme.light(colorScheme),
      bottomSheetTheme: DesignSystemBottomSheetTheme.light(colorScheme),
      cardTheme: DesignSystemCardTheme.build(colorScheme),
      elevatedButtonTheme: DesignSystemButtonTheme.elevated(colorScheme),
      outlinedButtonTheme: DesignSystemButtonTheme.outlined(colorScheme),
      textButtonTheme: DesignSystemButtonTheme.text(colorScheme),
      navigationBarTheme: DesignSystemNavigationBarTheme.build(colorScheme),
      radioTheme: DesignSystemRadioTheme.build(colorScheme),
      textTheme: DesignSystemTextTheme.build(colorScheme),
    );
  }

  /// Builds the dark theme for a given [brand].
  static ThemeData dark({DesignBrand brand = DesignBrands.tweetyB2c}) {
    final colorScheme = DesignColorSchemes.dark(brand);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: brand.surfaceDark,
      dividerColor: colorScheme.surface,
      appBarTheme: DesignSystemAppBarTheme.dark(colorScheme),
      bottomSheetTheme: DesignSystemBottomSheetTheme.dark(colorScheme),
      cardTheme: DesignSystemCardTheme.build(colorScheme),
      elevatedButtonTheme: DesignSystemButtonTheme.elevated(colorScheme),
      outlinedButtonTheme: DesignSystemButtonTheme.outlined(colorScheme),
      textButtonTheme: DesignSystemButtonTheme.text(colorScheme),
      navigationBarTheme: DesignSystemNavigationBarTheme.build(colorScheme),
      radioTheme: DesignSystemRadioTheme.build(colorScheme),
      textTheme: DesignSystemTextTheme.build(colorScheme),
    );
  }
}
