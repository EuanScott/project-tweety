import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/domain/entities/app_preferences/app_preferences.entity.dart';

/// The scene illustration's own colours, one palette per theme colour and
/// brightness. They belong to the illustration, not to the design system. Far
/// layers sit close to the sky and near layers are deeper, which is the
/// atmospheric perspective.
///
/// The app registers the palette for the chosen theme colour on each
/// [ThemeData], so the scene follows the theme.
class const ScenePalette({
  /// [Brightness.dark] is a night palette: the scene paints stars and a moon,
  /// and no birds.
  required final Brightness brightness,
  required final Color sky,
  required final Color sun,
  required final Color cloud,

  /// Birds paint by day only; the night value is unused.
  required final Color bird,
  required final Color farHills,
  required final Color midHills,
  required final Color backWater,
  required final Color shimmer,
  required final Color nearWater,
  required final Color closestWater,
  required final Color foam,

  /// Text colour for the heading drawn over the sky.
  required final Color ink,
}) extends ThemeExtension<ScenePalette> {
  /// The sun is a scene choice, not a theme colour choice, so every day
  /// palette shares it.
  static const Color _daySun = Color(0xFFFFD45C);

  static const fjordDay = ScenePalette(
    brightness: .light,
    sky: Color(0xFFE3F2F3),
    sun: _daySun,
    cloud: Color(0xFFFFFFFF),
    bird: Color(0xFF7FB3BA),
    farHills: Color(0xFFC6E4E7),
    midHills: Color(0xFF9FD2D8),
    backWater: Color(0xFF6DBDC7),
    shimmer: Color(0xFFFFFFFF),
    nearWater: Color(0xFF2A98A4),
    closestWater: Color(0xFF0E7474),
    foam: Color(0xFFBFE6EA),
    ink: Color(0xFF0F5D5D),
  );

  static const fjordNight = ScenePalette(
    brightness: .dark,
    sky: Color(0xFF0D2A30),
    sun: Color(0xFFE7F5F5),
    cloud: Color(0xFF1A3F46),
    bird: Color(0xFF4F7F86),
    farHills: Color(0xFF143840),
    midHills: Color(0xFF1A4950),
    backWater: Color(0xFF1F5E66),
    shimmer: Color(0xFF7FD3D3),
    nearWater: Color(0xFF13707A),
    closestWater: Color(0xFF0B555D),
    foam: Color(0xFF5CC8C8),
    ink: Color(0xFFE7F5F5),
  );

  static const fynbosDay = ScenePalette(
    brightness: .light,
    sky: Color(0xFFEEF2E3),
    sun: _daySun,
    cloud: Color(0xFFFFFFFF),
    bird: Color(0xFF9AA77A),
    farHills: Color(0xFFD6DFC0),
    midHills: Color(0xFFB3C48A),
    backWater: Color(0xFF8CA35A),
    shimmer: Color(0xFFFFFFFF),
    nearWater: Color(0xFF6F8A35),
    closestWater: Color(0xFF56691C),
    foam: Color(0xFFE2EBC8),
    ink: Color(0xFF3F4D12),
  );

  static const fynbosNight = ScenePalette(
    brightness: .dark,
    sky: Color(0xFF161B10),
    sun: Color(0xFFEEF2E3),
    cloud: Color(0xFF252C1C),
    bird: Color(0xFF616B4C),
    farHills: Color(0xFF1D2415),
    midHills: Color(0xFF26301B),
    backWater: Color(0xFF2F3D1F),
    shimmer: Color(0xFFC8D98A),
    nearWater: Color(0xFF3B4C22),
    closestWater: Color(0xFF2B3818),
    foam: Color(0xFFA9BF62),
    ink: Color(0xFFEEF2E3),
  );

  static const kalahariDay = ScenePalette(
    brightness: .light,
    sky: Color(0xFFF7EBE2),
    sun: _daySun,
    cloud: Color(0xFFFFF8F2),
    bird: Color(0xFFBB8A72),
    farHills: Color(0xFFEDCDB8),
    midHills: Color(0xFFDFA27F),
    backWater: Color(0xFFCF7F58),
    shimmer: Color(0xFFFFF3EA),
    nearWater: Color(0xFFBB5D37),
    closestWater: Color(0xFFA8441F),
    foam: Color(0xFFF5D4C0),
    ink: Color(0xFF7A2E12),
  );

  static const kalahariNight = ScenePalette(
    brightness: .dark,
    sky: Color(0xFF1D1820),
    sun: Color(0xFFF7E6DA),
    cloud: Color(0xFF33282C),
    bird: Color(0xFF7A6468),
    farHills: Color(0xFF2C2124),
    midHills: Color(0xFF3C2925),
    backWater: Color(0xFF4F2D22),
    shimmer: Color(0xFFF39A74),
    nearWater: Color(0xFF6A3220),
    closestWater: Color(0xFF4E2416),
    foam: Color(0xFFDF8A64),
    ink: Color(0xFFF7E6DA),
  );

  static const lyngDay = ScenePalette(
    brightness: .light,
    sky: Color(0xFFF1EBF5),
    sun: _daySun,
    cloud: Color(0xFFFFFFFF),
    bird: Color(0xFF9E88B4),
    farHills: Color(0xFFE0D3EC),
    midHills: Color(0xFFC4AAD9),
    backWater: Color(0xFFA083C0),
    shimmer: Color(0xFFFFFFFF),
    nearWater: Color(0xFF8A5FAE),
    closestWater: Color(0xFF77449A),
    foam: Color(0xFFE7D8F0),
    ink: Color(0xFF552E70),
  );

  static const lyngNight = ScenePalette(
    brightness: .dark,
    sky: Color(0xFF1B1626),
    sun: Color(0xFFEFE6F7),
    cloud: Color(0xFF2C2440),
    bird: Color(0xFF6C5F8A),
    farHills: Color(0xFF231D34),
    midHills: Color(0xFF2E2544),
    backWater: Color(0xFF3A2D59),
    shimmer: Color(0xFFD2A6EF),
    nearWater: Color(0xFF4A3572),
    closestWater: Color(0xFF36275C),
    foam: Color(0xFFBC98E0),
    ink: Color(0xFFEFE6F7),
  );

  static const whinDay = ScenePalette(
    brightness: .light,
    sky: Color(0xFFF6F1DC),
    sun: _daySun,
    cloud: Color(0xFFFFFDF5),
    bird: Color(0xFFA99A62),
    farHills: Color(0xFFECE0B0),
    midHills: Color(0xFFE0C96E),
    backWater: Color(0xFFC9A838),
    shimmer: Color(0xFFFFFBE8),
    nearWater: Color(0xFF9C7A12),
    closestWater: Color(0xFF7A5C00),
    foam: Color(0xFFF3E6B0),
    ink: Color(0xFF5C4500),
  );

  static const whinNight = ScenePalette(
    brightness: .dark,
    sky: Color(0xFF17150D),
    sun: Color(0xFFF6F1DC),
    cloud: Color(0xFF2A2618),
    bird: Color(0xFF6E6648),
    farHills: Color(0xFF211E13),
    midHills: Color(0xFF2E2A17),
    backWater: Color(0xFF3D3719),
    shimmer: Color(0xFFF2D76A),
    nearWater: Color(0xFF4F4517),
    closestWater: Color(0xFF3A3210),
    foam: Color(0xFFD9BE52),
    ink: Color(0xFFF6F1DC),
  );

  static const douroDay = ScenePalette(
    brightness: .light,
    sky: Color(0xFFF6E9EC),
    sun: _daySun,
    cloud: Color(0xFFFFF8F9),
    bird: Color(0xFFB0828E),
    farHills: Color(0xFFECD0D7),
    midHills: Color(0xFFD6A0AE),
    backWater: Color(0xFFBB6B80),
    shimmer: Color(0xFFFFF4F6),
    nearWater: Color(0xFFA23C58),
    closestWater: Color(0xFF8C1D3A),
    foam: Color(0xFFF2D0D9),
    ink: Color(0xFF6E1530),
  );

  static const douroNight = ScenePalette(
    brightness: .dark,
    sky: Color(0xFF1C1418),
    sun: Color(0xFFF6E4E9),
    cloud: Color(0xFF33242B),
    bird: Color(0xFF7A5F68),
    farHills: Color(0xFF2A1C22),
    midHills: Color(0xFF3A2229),
    backWater: Color(0xFF4C2533),
    shimmer: Color(0xFFF0A3B5),
    nearWater: Color(0xFF66283D),
    closestWater: Color(0xFF4A1C2C),
    foam: Color(0xFFD98A9E),
    ink: Color(0xFFF6E4E9),
  );

  static const cuillinDay = ScenePalette(
    brightness: .light,
    sky: Color(0xFFE9ECEE),
    sun: _daySun,
    cloud: Color(0xFFFFFFFF),
    bird: Color(0xFF8A949B),
    farHills: Color(0xFFD3D8DC),
    midHills: Color(0xFFAAB3BA),
    backWater: Color(0xFF7F8B94),
    shimmer: Color(0xFFFFFFFF),
    nearWater: Color(0xFF4B565E),
    closestWater: Color(0xFF1F2326),
    foam: Color(0xFFCFD6DB),
    ink: Color(0xFF1F2326),
  );

  static const cuillinNight = ScenePalette(
    brightness: .dark,
    sky: Color(0xFF111315),
    sun: Color(0xFFE6E8EA),
    cloud: Color(0xFF24282C),
    bird: Color(0xFF5E666C),
    farHills: Color(0xFF1A1D20),
    midHills: Color(0xFF23272B),
    backWater: Color(0xFF2E3439),
    shimmer: Color(0xFFB8C4CC),
    nearWater: Color(0xFF3A4249),
    closestWater: Color(0xFF2A3035),
    foam: Color(0xFF8FA0AB),
    ink: Color(0xFFE6E8EA),
  );

  /// The palette on the current theme. A theme built without one, such as a
  /// bare design-system theme in a widget test, gets the Fjord palette, the
  /// same default as the design system.
  static ScenePalette of(BuildContext context) {
    final theme = Theme.of(context);

    return theme.extension<ScenePalette>() ??
        forThemeColour(.fjord, theme.brightness);
  }

  static ScenePalette forThemeColour(
    AppPreferencesThemeColour themeColour,
    Brightness brightness,
  ) {
    final (day, night) = switch (themeColour) {
      .fjord => (fjordDay, fjordNight),
      .fynbos => (fynbosDay, fynbosNight),
      .kalahari => (kalahariDay, kalahariNight),
      .lyng => (lyngDay, lyngNight),
      .whin => (whinDay, whinNight),
      .douro => (douroDay, douroNight),
      .cuillin => (cuillinDay, cuillinNight),
    };

    return brightness == .dark ? night : day;
  }

  bool get isNight => brightness == .dark;

  @override
  ScenePalette copyWith({
    Brightness? brightness,
    Color? sky,
    Color? sun,
    Color? cloud,
    Color? bird,
    Color? farHills,
    Color? midHills,
    Color? backWater,
    Color? shimmer,
    Color? nearWater,
    Color? closestWater,
    Color? foam,
    Color? ink,
  }) {
    return ScenePalette(
      brightness: brightness ?? this.brightness,
      sky: sky ?? this.sky,
      sun: sun ?? this.sun,
      cloud: cloud ?? this.cloud,
      bird: bird ?? this.bird,
      farHills: farHills ?? this.farHills,
      midHills: midHills ?? this.midHills,
      backWater: backWater ?? this.backWater,
      shimmer: shimmer ?? this.shimmer,
      nearWater: nearWater ?? this.nearWater,
      closestWater: closestWater ?? this.closestWater,
      foam: foam ?? this.foam,
      ink: ink ?? this.ink,
    );
  }

  @override
  ScenePalette lerp(ScenePalette? other, double t) {
    if (other == null) {
      return this;
    }

    return ScenePalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      sky: Color.lerp(sky, other.sky, t)!,
      sun: Color.lerp(sun, other.sun, t)!,
      cloud: Color.lerp(cloud, other.cloud, t)!,
      bird: Color.lerp(bird, other.bird, t)!,
      farHills: Color.lerp(farHills, other.farHills, t)!,
      midHills: Color.lerp(midHills, other.midHills, t)!,
      backWater: Color.lerp(backWater, other.backWater, t)!,
      shimmer: Color.lerp(shimmer, other.shimmer, t)!,
      nearWater: Color.lerp(nearWater, other.nearWater, t)!,
      closestWater: Color.lerp(closestWater, other.closestWater, t)!,
      foam: Color.lerp(foam, other.foam, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
    );
  }
}
