import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/core/storage/app_preferences.storage.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../support/in_memory_shared_preferences_async_platform.dart';

const _storageKey = 'app_cache.preferences';

void main() {
  group('AppPreferencesStorage theme colour', () {
    setUp(() {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsyncPlatform();
    });

    for (final themeColour in StoredThemeColour.values) {
      test('round trips ${themeColour.name}', () async {
        final storage = AppPreferencesStorage();

        await storage.writePreferences(
          AppPreferences(themeColour: themeColour),
        );

        expect((await storage.readPreferences()).themeColour, themeColour);
      });
    }

    test('stores the theme colour by name', () {
      expect(
        const AppPreferences(themeColour: StoredThemeColour.douro).toJson(),
        containsPair('themeColour', 'douro'),
      );
    });

    test('reads a saved preference without a theme colour as fjord', () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsyncPlatform({
            _storageKey: '{"themeMode":"dark","languageCode":"es"}',
          });

      final preferences = await AppPreferencesStorage().readPreferences();

      expect(preferences.themeColour, StoredThemeColour.fjord);
      expect(preferences.languageCode, 'es');
    });

    test('reads an unknown theme colour as fjord', () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsyncPlatform({
            _storageKey: '{"themeMode":"dark","themeColour":"sunrise"}',
          });

      final preferences = await AppPreferencesStorage().readPreferences();

      expect(preferences.themeColour, StoredThemeColour.fjord);
    });
  });
}
