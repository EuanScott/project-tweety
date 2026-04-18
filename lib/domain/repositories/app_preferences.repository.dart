import 'package:project_tweety/domain/entities/app_preferences.entity.dart';

abstract class AppPreferencesRepository {
  Future<AppPreferences> getAppPreferences();

  Future<void> saveAppPreferences(AppPreferences appPreferences);
}
