import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/domain/entities/app_preferences/app_preferences.entity.dart';
import 'package:project_tweety/presentation/widgets/water_scene/scene_palette.model.dart';

void main() {
  group('ScenePalette.forThemeColour', () {
    for (final themeColour in AppPreferencesThemeColour.values) {
      test('${themeColour.name} has a day and a night palette', () {
        final day = ScenePalette.forThemeColour(themeColour, Brightness.light);
        final night = ScenePalette.forThemeColour(
          themeColour,
          Brightness.dark,
        );

        expect(day.isNight, isFalse);
        expect(night.isNight, isTrue);
        expect(day.sun, const Color(0xFFFFD45C));
        expect(night, isNot(same(day)));
      });
    }

    test('Fjord keeps the original day and night colours', () {
      final day = ScenePalette.forThemeColour(.fjord, Brightness.light);
      final night = ScenePalette.forThemeColour(.fjord, Brightness.dark);

      expect(day.sky, const Color(0xFFE3F2F3));
      expect(day.closestWater, const Color(0xFF0E7474));
      expect(night.sky, const Color(0xFF0D2A30));
      expect(night.ink, const Color(0xFFE7F5F5));
    });

    test('Kalahari day water ends in the light primary', () {
      expect(
        ScenePalette.forThemeColour(.kalahari, Brightness.light).closestWater,
        const Color(0xFFA8441F),
      );
    });

    test('a palette lerps its colours and keeps a valid brightness', () {
      final mid = ScenePalette.fjordDay.lerp(ScenePalette.fjordNight, 0.75);

      expect(
        mid.sky,
        Color.lerp(
          ScenePalette.fjordDay.sky,
          ScenePalette.fjordNight.sky,
          0.75,
        ),
      );
      expect(mid.isNight, isTrue);
    });
  });
}
