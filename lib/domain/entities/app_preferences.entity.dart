import 'package:equatable/equatable.dart';

enum AppPreferencesThemeMode { system, light, dark }

class AppPreferences extends Equatable {
  const AppPreferences({
    this.themeMode = AppPreferencesThemeMode.system,
    this.languageCode = 'en',
  });

  final AppPreferencesThemeMode themeMode;
  final String languageCode;

  AppPreferences copyWith({
    AppPreferencesThemeMode? themeMode,
    String? languageCode,
  }) {
    return AppPreferences(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  @override
  List<Object> get props => [themeMode, languageCode];
}
