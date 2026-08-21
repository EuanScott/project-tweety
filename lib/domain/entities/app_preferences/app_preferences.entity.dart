import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_preferences.entity.freezed.dart';

enum AppPreferencesThemeMode { system, light, dark }

@freezed
abstract class AppPreferences with _$AppPreferences {
  const factory({
    @Default(AppPreferencesThemeMode.system) AppPreferencesThemeMode themeMode,
    String? languageCode,
  }) = _AppPreferences;
}
