import 'package:equatable/equatable.dart';

enum SettingsThemeMode { system, light, dark }

class Settings extends Equatable {
  const Settings({
    this.themeMode = SettingsThemeMode.system,
    this.languageCode = 'en',
  });

  final SettingsThemeMode themeMode;
  final String languageCode;

  Settings copyWith({
    SettingsThemeMode? themeMode,
    String? languageCode,
  }) {
    return Settings(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  @override
  List<Object> get props => [themeMode, languageCode];
}
