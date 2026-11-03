import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/domain/entities/app_preferences/app_preferences.entity.dart';

/// The route error map scene's own colours, one palette per theme colour and
/// brightness, as the water scene has its own (ADR-0016). They belong to the
/// illustration, not to the design system.
///
/// The day palettes share their values with the water scene's. The night
/// palettes are tuned by hand from the same night set, so the paper reads
/// against a dark sky. The sky, the page and the primary colour are not here:
/// they come from the water scene palette and the theme, as on Sign-in.
///
/// The app registers the palette for the chosen theme colour on each
/// [ThemeData], so the scene follows the theme.
class const MapScenePalette({
  required final Brightness brightness,

  /// The paper of the near map card, the 404 title box and the compass face.
  required final Color cloud,

  /// The far map card, the map rings in the sky and the compass's inner ring.
  required final Color far,

  /// Contour lines on the cards, the south half of the needle.
  required final Color mid,

  /// The wave lines on the small map card.
  required final Color back,

  /// The compass rim and its main ticks.
  required final Color close,

  /// The small map card and the folds on the near card.
  required final Color foam,

  /// The 404, the compass letters and the needle's hub.
  required final Color ink,

  /// The pin's shadow on the map, with its opacity.
  required final Color pinShadow,

  /// The compass's shadow, with its opacity.
  required final Color compassShadow,
}) extends ThemeExtension<MapScenePalette> {
  /// Every night palette casts the same black shadows.
  static const Color _nightPinShadow = Color(0x73000000);
  static const Color _nightCompassShadow = Color(0x59000000);

  static const fjordDay = MapScenePalette(
    brightness: .light,
    cloud: Color(0xFFFFFFFF),
    far: Color(0xFFC6E4E7),
    mid: Color(0xFF9FD2D8),
    back: Color(0xFF6DBDC7),
    close: Color(0xFF0E7474),
    foam: Color(0xFFBFE6EA),
    ink: Color(0xFF0F5D5D),
    pinShadow: Color(0x2E0F5D5D),
    compassShadow: Color(0x1F0F5D5D),
  );

  static const fjordNight = MapScenePalette(
    brightness: .dark,
    cloud: Color(0xFF1A3F46),
    far: Color(0xFF143840),
    mid: Color(0xFF1F5E66),
    back: Color(0xFF13707A),
    close: Color(0xFF7FD3D3),
    foam: Color(0xFF1A4950),
    ink: Color(0xFFE7F5F5),
    pinShadow: _nightPinShadow,
    compassShadow: _nightCompassShadow,
  );

  static const fynbosDay = MapScenePalette(
    brightness: .light,
    cloud: Color(0xFFFFFFFF),
    far: Color(0xFFD6DFC0),
    mid: Color(0xFFB3C48A),
    back: Color(0xFF8CA35A),
    close: Color(0xFF56691C),
    foam: Color(0xFFE2EBC8),
    ink: Color(0xFF3F4D12),
    pinShadow: Color(0x2E3F4D12),
    compassShadow: Color(0x1F3F4D12),
  );

  static const fynbosNight = MapScenePalette(
    brightness: .dark,
    cloud: Color(0xFF252C1C),
    far: Color(0xFF1D2415),
    mid: Color(0xFF2F3D1F),
    back: Color(0xFF3B4C22),
    close: Color(0xFFC8D98A),
    foam: Color(0xFF26301B),
    ink: Color(0xFFEEF2E3),
    pinShadow: _nightPinShadow,
    compassShadow: _nightCompassShadow,
  );

  static const kalahariDay = MapScenePalette(
    brightness: .light,
    cloud: Color(0xFFFFF8F2),
    far: Color(0xFFEDCDB8),
    mid: Color(0xFFDFA27F),
    back: Color(0xFFCF7F58),
    close: Color(0xFFA8441F),
    foam: Color(0xFFF5D4C0),
    ink: Color(0xFF7A2E12),
    pinShadow: Color(0x2E7A2E12),
    compassShadow: Color(0x1F7A2E12),
  );

  static const kalahariNight = MapScenePalette(
    brightness: .dark,
    cloud: Color(0xFF33282C),
    far: Color(0xFF2C2124),
    mid: Color(0xFF4F2D22),
    back: Color(0xFF6A3220),
    close: Color(0xFFF39A74),
    foam: Color(0xFF3C2925),
    ink: Color(0xFFF7E6DA),
    pinShadow: _nightPinShadow,
    compassShadow: _nightCompassShadow,
  );

  static const lyngDay = MapScenePalette(
    brightness: .light,
    cloud: Color(0xFFFFFFFF),
    far: Color(0xFFE0D3EC),
    mid: Color(0xFFC4AAD9),
    back: Color(0xFFA083C0),
    close: Color(0xFF77449A),
    foam: Color(0xFFE7D8F0),
    ink: Color(0xFF552E70),
    pinShadow: Color(0x2E552E70),
    compassShadow: Color(0x1F552E70),
  );

  static const lyngNight = MapScenePalette(
    brightness: .dark,
    cloud: Color(0xFF2C2440),
    far: Color(0xFF231D34),
    mid: Color(0xFF3A2D59),
    back: Color(0xFF4A3572),
    close: Color(0xFFD2A6EF),
    foam: Color(0xFF2E2544),
    ink: Color(0xFFEFE6F7),
    pinShadow: _nightPinShadow,
    compassShadow: _nightCompassShadow,
  );

  static const whinDay = MapScenePalette(
    brightness: .light,
    cloud: Color(0xFFFFFDF5),
    far: Color(0xFFECE0B0),
    mid: Color(0xFFE0C96E),
    back: Color(0xFFC9A838),
    close: Color(0xFF7A5C00),
    foam: Color(0xFFF3E6B0),
    ink: Color(0xFF5C4500),
    pinShadow: Color(0x2E5C4500),
    compassShadow: Color(0x1F5C4500),
  );

  static const whinNight = MapScenePalette(
    brightness: .dark,
    cloud: Color(0xFF2A2618),
    far: Color(0xFF211E13),
    mid: Color(0xFF3D3719),
    back: Color(0xFF4F4517),
    close: Color(0xFFF2D76A),
    foam: Color(0xFF2E2A17),
    ink: Color(0xFFF6F1DC),
    pinShadow: _nightPinShadow,
    compassShadow: _nightCompassShadow,
  );

  static const douroDay = MapScenePalette(
    brightness: .light,
    cloud: Color(0xFFFFF8F9),
    far: Color(0xFFECD0D7),
    mid: Color(0xFFD6A0AE),
    back: Color(0xFFBB6B80),
    close: Color(0xFF8C1D3A),
    foam: Color(0xFFF2D0D9),
    ink: Color(0xFF6E1530),
    pinShadow: Color(0x2E6E1530),
    compassShadow: Color(0x1F6E1530),
  );

  static const douroNight = MapScenePalette(
    brightness: .dark,
    cloud: Color(0xFF33242B),
    far: Color(0xFF2A1C22),
    mid: Color(0xFF4C2533),
    back: Color(0xFF66283D),
    close: Color(0xFFF0A3B5),
    foam: Color(0xFF3A2229),
    ink: Color(0xFFF6E4E9),
    pinShadow: _nightPinShadow,
    compassShadow: _nightCompassShadow,
  );

  static const cuillinDay = MapScenePalette(
    brightness: .light,
    cloud: Color(0xFFFFFFFF),
    far: Color(0xFFD3D8DC),
    mid: Color(0xFFAAB3BA),
    back: Color(0xFF7F8B94),
    close: Color(0xFF1F2326),
    foam: Color(0xFFCFD6DB),
    ink: Color(0xFF1F2326),
    pinShadow: Color(0x2E1F2326),
    compassShadow: Color(0x1F1F2326),
  );

  static const cuillinNight = MapScenePalette(
    brightness: .dark,
    cloud: Color(0xFF24282C),
    far: Color(0xFF1A1D20),
    mid: Color(0xFF2E3439),
    back: Color(0xFF3A4249),
    close: Color(0xFFB8C4CC),
    foam: Color(0xFF23272B),
    ink: Color(0xFFE6E8EA),
    pinShadow: _nightPinShadow,
    compassShadow: _nightCompassShadow,
  );

  /// The palette on the current theme. A theme built without one, such as a
  /// bare design-system theme in a widget test, gets the Fjord palette, the
  /// same default as the design system.
  static MapScenePalette of(BuildContext context) {
    final theme = Theme.of(context);

    return theme.extension<MapScenePalette>() ??
        forThemeColour(.fjord, theme.brightness);
  }

  static MapScenePalette forThemeColour(
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

  @override
  MapScenePalette copyWith({
    Brightness? brightness,
    Color? cloud,
    Color? far,
    Color? mid,
    Color? back,
    Color? close,
    Color? foam,
    Color? ink,
    Color? pinShadow,
    Color? compassShadow,
  }) {
    return MapScenePalette(
      brightness: brightness ?? this.brightness,
      cloud: cloud ?? this.cloud,
      far: far ?? this.far,
      mid: mid ?? this.mid,
      back: back ?? this.back,
      close: close ?? this.close,
      foam: foam ?? this.foam,
      ink: ink ?? this.ink,
      pinShadow: pinShadow ?? this.pinShadow,
      compassShadow: compassShadow ?? this.compassShadow,
    );
  }

  @override
  MapScenePalette lerp(MapScenePalette? other, double t) {
    if (other == null) {
      return this;
    }

    return MapScenePalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      cloud: Color.lerp(cloud, other.cloud, t)!,
      far: Color.lerp(far, other.far, t)!,
      mid: Color.lerp(mid, other.mid, t)!,
      back: Color.lerp(back, other.back, t)!,
      close: Color.lerp(close, other.close, t)!,
      foam: Color.lerp(foam, other.foam, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      pinShadow: Color.lerp(pinShadow, other.pinShadow, t)!,
      compassShadow: Color.lerp(compassShadow, other.compassShadow, t)!,
    );
  }
}
