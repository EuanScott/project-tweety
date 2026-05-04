import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/core/storage/app_preferences.storage.dart'
    as storage;
import 'package:project_tweety/data/datasources/app_preferences/app_preferences_local.datasource.dart';
import 'package:project_tweety/data/repositories/app_preferences/app_preferences.repository_impl.dart';
import 'package:project_tweety/domain/entities/app_preferences/app_preferences.entity.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../support/in_memory_shared_preferences_async_platform.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsyncPlatform();
  });

  test(
    'maps missing stored language to system default in the domain model',
    () async {
      final storageDriver = storage.AppPreferencesStorage();
      final dataSource = AppPreferencesLocalDataSource(storageDriver);
      final repository = AppPreferencesRepositoryImpl(dataSource);

      await storageDriver.writePreferences(
        const storage.AppPreferences(themeMode: ThemeMode.system),
      );

      final appPreferences = await repository.getAppPreferences();

      expect(appPreferences.languageCode, isNull);
      expect(appPreferences.themeMode, AppPreferencesThemeMode.system);
    },
  );

  test('preserves explicit stored language overrides', () async {
    final storageDriver = storage.AppPreferencesStorage();
    final dataSource = AppPreferencesLocalDataSource(storageDriver);
    final repository = AppPreferencesRepositoryImpl(dataSource);

    await storageDriver.writePreferences(
      const storage.AppPreferences(
        themeMode: ThemeMode.dark,
        languageCode: 'es',
      ),
    );

    final appPreferences = await repository.getAppPreferences();

    expect(appPreferences.languageCode, 'es');
    expect(appPreferences.themeMode, AppPreferencesThemeMode.dark);
  });
}
