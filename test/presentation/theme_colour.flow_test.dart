import 'package:design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/domain/entities/app_preferences/app_preferences.entity.dart';
import 'package:project_tweety/presentation/pages/app_preferences/cubit/app_preferences.cubit.dart';
import 'package:project_tweety/presentation/widgets/water_scene/scene_palette.model.dart';

import '../support/app_harness.dart';
import '../support/fake_app_preferences_repository.dart';

void main() {
  useAppHarness();

  BuildContext appContext(WidgetTester tester) =>
      tester.element(find.byType(Navigator).first);

  Future<void> pumpWithPreferences(
    WidgetTester tester,
    AppPreferences preferences,
  ) async {
    replaceAppPreferencesRepository(FakeAppPreferencesRepository(preferences));
    await pumpApp(tester);
  }

  group('Theme colour', () {
    testWidgets('a cubit change to Kalahari rebuilds the light theme', (
      tester,
    ) async {
      await pumpWithPreferences(
        tester,
        const AppPreferences(themeMode: AppPreferencesThemeMode.light),
      );
      expect(
        Theme.of(appContext(tester)).colorScheme.primary,
        const Color(0xFF0E7474),
      );

      await appContext(
        tester,
      ).read<AppPreferencesCubit>().updateThemeColour(.kalahari);
      await tester.pumpAndSettle();

      expect(
        Theme.of(appContext(tester)).colorScheme.primary,
        const Color(0xFFA8441F),
      );
    });

    testWidgets('Cuillin in dark mode uses the near-white primary', (
      tester,
    ) async {
      await pumpWithPreferences(
        tester,
        const AppPreferences(
          themeMode: AppPreferencesThemeMode.dark,
          themeColour: AppPreferencesThemeColour.cuillin,
        ),
      );

      expect(
        Theme.of(appContext(tester)).colorScheme.primary,
        const Color(0xFFE6E8EA),
      );
    });

    testWidgets('Lyng in dark mode gives the scene the Lyng night palette', (
      tester,
    ) async {
      await pumpWithPreferences(
        tester,
        const AppPreferences(
          themeMode: AppPreferencesThemeMode.dark,
          themeColour: AppPreferencesThemeColour.lyng,
        ),
      );

      final context = appContext(tester);
      final palette = ScenePalette.of(context);

      expect(palette, same(ScenePalette.lyngNight));
      expect(palette.isNight, isTrue);
      expect(Theme.of(context).extension<DesignStatusColors>(), isNotNull);
      expect(Theme.of(context).extension<ScenePalette>(), isNotNull);
    });

    testWidgets('Fjord in light mode keeps the original day scene', (
      tester,
    ) async {
      await pumpWithPreferences(
        tester,
        const AppPreferences(themeMode: AppPreferencesThemeMode.light),
      );

      final context = appContext(tester);

      expect(ScenePalette.of(context), same(ScenePalette.fjordDay));
      expect(Theme.of(context).extension<DesignStatusColors>(), isNotNull);
    });
  });
}
