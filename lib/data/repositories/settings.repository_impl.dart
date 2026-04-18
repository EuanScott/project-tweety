import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:project_tweety/core/storage/app_preferences.storage.dart';
import 'package:project_tweety/data/datasources/settings_local.datasource.dart';
import 'package:project_tweety/domain/entities/settings.entity.dart';
import 'package:project_tweety/domain/repositories/settings.repository.dart';

@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._localDataSource);

  final SettingsLocalDataSource _localDataSource;

  @override
  Future<Settings> getSettings() async {
    final preferences = await _localDataSource.readSettings();

    return Settings(
      themeMode: _mapThemeMode(preferences.themeMode),
      languageCode: preferences.languageCode ?? 'en',
    );
  }

  @override
  Future<void> saveSettings(Settings settings) {
    return _localDataSource.writeSettings(
      AppPreferences(
        themeMode: _mapStorageThemeMode(settings.themeMode),
        languageCode: settings.languageCode,
      ),
    );
  }

  SettingsThemeMode _mapThemeMode(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return SettingsThemeMode.system;
      case ThemeMode.light:
        return SettingsThemeMode.light;
      case ThemeMode.dark:
        return SettingsThemeMode.dark;
    }
  }

  ThemeMode _mapStorageThemeMode(SettingsThemeMode themeMode) {
    switch (themeMode) {
      case SettingsThemeMode.system:
        return ThemeMode.system;
      case SettingsThemeMode.light:
        return ThemeMode.light;
      case SettingsThemeMode.dark:
        return ThemeMode.dark;
    }
  }
}
