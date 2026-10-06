import 'package:material_ui/material_ui.dart';
import 'package:injectable/injectable.dart';
import 'package:project_tweety/core/storage/app_preferences.storage.dart'
    as storage;
import 'package:project_tweety/data/datasources/app_preferences/app_preferences_local.datasource.dart';
import 'package:project_tweety/domain/entities/app_preferences/app_preferences.entity.dart';
import 'package:project_tweety/domain/repositories/app_preferences/app_preferences.repository.dart';

@LazySingleton(as: AppPreferencesRepository)
class const AppPreferencesRepositoryImpl(
  final AppPreferencesLocalDataSource _localDataSource,
) implements AppPreferencesRepository {
  @override
  Future<AppPreferences> getAppPreferences() async {
    final appPreferences = await _localDataSource.readAppPreferences();

    return AppPreferences(
      themeMode: _mapThemeMode(appPreferences.themeMode),
      themeColour: _mapThemeColour(appPreferences.themeColour),
      languageCode: appPreferences.languageCode,
    );
  }

  @override
  Future<void> saveAppPreferences(AppPreferences appPreferences) {
    return _localDataSource.writeAppPreferences(
      storage.AppPreferences(
        themeMode: _mapStorageThemeMode(appPreferences.themeMode),
        themeColour: _mapStorageThemeColour(appPreferences.themeColour),
        languageCode: appPreferences.languageCode,
      ),
    );
  }

  AppPreferencesThemeMode _mapThemeMode(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return AppPreferencesThemeMode.system;
      case ThemeMode.light:
        return AppPreferencesThemeMode.light;
      case ThemeMode.dark:
        return AppPreferencesThemeMode.dark;
    }
  }

  ThemeMode _mapStorageThemeMode(AppPreferencesThemeMode themeMode) {
    switch (themeMode) {
      case AppPreferencesThemeMode.system:
        return ThemeMode.system;
      case AppPreferencesThemeMode.light:
        return ThemeMode.light;
      case AppPreferencesThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  AppPreferencesThemeColour _mapThemeColour(
    storage.StoredThemeColour themeColour,
  ) {
    return switch (themeColour) {
      .fjord => .fjord,
      .fynbos => .fynbos,
      .kalahari => .kalahari,
      .lyng => .lyng,
      .whin => .whin,
      .douro => .douro,
      .cuillin => .cuillin,
    };
  }

  storage.StoredThemeColour _mapStorageThemeColour(
    AppPreferencesThemeColour themeColour,
  ) {
    return switch (themeColour) {
      .fjord => .fjord,
      .fynbos => .fynbos,
      .kalahari => .kalahari,
      .lyng => .lyng,
      .whin => .whin,
      .douro => .douro,
      .cuillin => .cuillin,
    };
  }
}
