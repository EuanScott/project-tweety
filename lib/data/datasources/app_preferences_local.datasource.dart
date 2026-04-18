import 'package:injectable/injectable.dart';
import 'package:project_tweety/core/storage/app_preferences.storage.dart'
    as storage;

@lazySingleton
class AppPreferencesLocalDataSource {
  const AppPreferencesLocalDataSource(this._appPreferencesStorage);

  final storage.AppPreferencesStorage _appPreferencesStorage;

  Future<storage.AppPreferences> readAppPreferences() {
    return _appPreferencesStorage.readPreferences();
  }

  Future<void> writeAppPreferences(storage.AppPreferences appPreferences) {
    return _appPreferencesStorage.writePreferences(appPreferences);
  }
}
