import 'package:design_system/design_system.dart';
import 'package:project_tweety/domain/entities/app_preferences/app_preferences.entity.dart';

/// Maps each theme colour to its design-system preset.
///
/// The switch is exhaustive, so a new theme colour fails to compile until it
/// has a preset.
extension AppPreferencesThemeColourExtension on AppPreferencesThemeColour {
  DesignBrand get brand {
    return switch (this) {
      .fjord => DesignBrands.fjord,
      .fynbos => DesignBrands.fynbos,
      .kalahari => DesignBrands.kalahari,
      .lyng => DesignBrands.lyng,
      .whin => DesignBrands.whin,
      .douro => DesignBrands.douro,
      .cuillin => DesignBrands.cuillin,
    };
  }
}
