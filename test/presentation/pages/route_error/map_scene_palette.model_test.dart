import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/domain/entities/app_preferences/app_preferences.entity.dart';
import 'package:project_tweety/presentation/pages/route_error/map_scene_palette.model.dart';

/// A shadow is [colour] at [opacity], stored in 8 bits.
void expectShadow(Color shadow, Color colour, double opacity) {
  expect(shadow.withValues(alpha: 1), colour);
  expect(shadow.a, closeTo(opacity, 1 / 255));
}

void main() {
  group('MapScenePalette.forThemeColour', () {
    test("Fjord by day takes the design's light map colours", () {
      final palette = MapScenePalette.forThemeColour(.fjord, .light);

      expect(palette.cloud, const Color(0xFFFFFFFF));
      expect(palette.far, const Color(0xFFC6E4E7));
      expect(palette.mid, const Color(0xFF9FD2D8));
      expect(palette.back, const Color(0xFF6DBDC7));
      expect(palette.close, const Color(0xFF0E7474));
      expect(palette.foam, const Color(0xFFBFE6EA));
      expect(palette.ink, const Color(0xFF0F5D5D));
      expectShadow(palette.pinShadow, const Color(0xFF0F5D5D), 0.18);
      expectShadow(palette.compassShadow, const Color(0xFF0F5D5D), 0.12);
    });

    test("Kalahari by night takes the design's hand-tuned dark colours", () {
      final palette = MapScenePalette.forThemeColour(.kalahari, .dark);

      expect(palette.cloud, const Color(0xFF33282C));
      expect(palette.far, const Color(0xFF2C2124));
      expect(palette.mid, const Color(0xFF4F2D22));
      expect(palette.back, const Color(0xFF6A3220));
      expect(palette.close, const Color(0xFFF39A74));
      expect(palette.foam, const Color(0xFF3C2925));
      expect(palette.ink, const Color(0xFFF7E6DA));
      expectShadow(palette.pinShadow, const Color(0xFF000000), 0.45);
      expectShadow(palette.compassShadow, const Color(0xFF000000), 0.35);
    });

    test('every theme colour has its own palette by day and by night', () {
      final palettes = {
        for (final colour in AppPreferencesThemeColour.values)
          for (final brightness in Brightness.values)
            MapScenePalette.forThemeColour(colour, brightness),
      };

      expect(palettes, hasLength(AppPreferencesThemeColour.values.length * 2));
    });
  });
}
