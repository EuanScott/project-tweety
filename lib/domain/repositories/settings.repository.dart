import 'package:project_tweety/domain/entities/settings.entity.dart';

abstract class SettingsRepository {
  Future<Settings> getSettings();

  Future<void> saveSettings(Settings settings);
}
