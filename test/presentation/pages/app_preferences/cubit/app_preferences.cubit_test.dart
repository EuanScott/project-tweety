import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/domain/entities/app_preferences/app_preferences.entity.dart';
import 'package:project_tweety/presentation/pages/app_preferences/cubit/app_preferences.cubit.dart';

import '../../../../support/fake_app_preferences_repository.dart';

void main() {
  group('AppPreferencesCubit.updateThemeColour', () {
    late FakeAppPreferencesRepository repository;

    setUp(() {
      repository = FakeAppPreferencesRepository();
    });

    blocTest<AppPreferencesCubit, AppPreferencesState>(
      'saves and emits the new theme colour',
      build: () => AppPreferencesCubit(repository),
      act: (cubit) => cubit.updateThemeColour(AppPreferencesThemeColour.lyng),
      expect: () => [
        isA<AppPreferencesState>().having(
          (state) => state.effectiveAppPreferences.themeColour,
          'themeColour',
          AppPreferencesThemeColour.lyng,
        ),
      ],
      verify: (_) {
        expect(repository.savedPreferences, [
          const AppPreferences(themeColour: AppPreferencesThemeColour.lyng),
        ]);
      },
    );

    blocTest<AppPreferencesCubit, AppPreferencesState>(
      'does nothing when the theme colour is already chosen',
      build: () => AppPreferencesCubit(repository),
      act: (cubit) => cubit.updateThemeColour(AppPreferencesThemeColour.fjord),
      expect: () => const <AppPreferencesState>[],
      verify: (_) => expect(repository.savedPreferences, isEmpty),
    );
  });
}
