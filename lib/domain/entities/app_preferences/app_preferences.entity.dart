import 'package:equatable/equatable.dart';

enum AppPreferencesThemeMode { system, light, dark }

const Object _unset = Object();

class AppPreferences extends Equatable {
  const AppPreferences({
    this.themeMode = AppPreferencesThemeMode.system,
    this.languageCode,
  });

  final AppPreferencesThemeMode themeMode;
  final String? languageCode;

  AppPreferences copyWith({
    AppPreferencesThemeMode? themeMode,
    Object? languageCode = _unset,
  }) {
    return AppPreferences(
      themeMode: themeMode ?? this.themeMode,
      languageCode: identical(languageCode, _unset)
          ? this.languageCode
          : languageCode as String?,
    );
  }

  @override
  List<Object?> get props => [themeMode, languageCode];
}
