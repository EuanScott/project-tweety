import 'package:injectable/injectable.dart';
import 'package:project_tweety/core/storage/app_preferences.storage.dart';

@lazySingleton
class SettingsLocalDataSource {
  const SettingsLocalDataSource(this._appPreferencesStorage);

  final AppPreferencesStorage _appPreferencesStorage;

  Future<AppPreferences> readSettings() {
    return _appPreferencesStorage.readPreferences();
  }

  Future<void> writeSettings(AppPreferences preferences) {
    return _appPreferencesStorage.writePreferences(preferences);
  }
}
