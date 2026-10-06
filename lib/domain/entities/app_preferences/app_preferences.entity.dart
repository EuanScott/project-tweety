import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_preferences.entity.freezed.dart';

enum AppPreferencesThemeMode { system, light, dark }

enum AppPreferencesThemeColour {
  fjord,
  fynbos,
  kalahari,
  lyng,
  whin,
  douro,
  cuillin,
}

@freezed
abstract class AppPreferences with _$AppPreferences {
  const factory({
    @Default(AppPreferencesThemeMode.system) AppPreferencesThemeMode themeMode,
    @Default(AppPreferencesThemeColour.fjord)
    AppPreferencesThemeColour themeColour,
    String? languageCode,
  }) = _AppPreferences;
}
