import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Object _unset = Object();

@immutable
class AppPreferences {
  const AppPreferences({
    this.themeMode = ThemeMode.system,
    this.languageCode = 'en',
    this.isOnboardingDismissed = false,
  });

  final ThemeMode themeMode;
  final String? languageCode;
  final bool isOnboardingDismissed;

  AppPreferences copyWith({
    ThemeMode? themeMode,
    Object? languageCode = _unset,
    bool? isOnboardingDismissed,
  }) {
    return AppPreferences(
      themeMode: themeMode ?? this.themeMode,
      languageCode: identical(languageCode, _unset)
          ? this.languageCode
          : languageCode as String?,
      isOnboardingDismissed:
          isOnboardingDismissed ?? this.isOnboardingDismissed,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'themeMode': themeMode.name,
      'languageCode': languageCode,
      'isOnboardingDismissed': isOnboardingDismissed,
    }..removeWhere((_, value) => value == null);
  }

  String toStorageValue() => jsonEncode(toJson());

  factory AppPreferences.fromStorageValue(String source) {
    final decoded = jsonDecode(source);

    if (decoded is! Map<String, dynamic>) {
      return const AppPreferences();
    }

    return AppPreferences.fromJson(decoded);
  }

  factory AppPreferences.fromJson(Map<String, dynamic> json) {
    return AppPreferences(
      themeMode: _themeModeFromName(json['themeMode']) ?? ThemeMode.system,
      languageCode: json['languageCode'] as String? ?? 'en',
      isOnboardingDismissed: json['isOnboardingDismissed'] as bool? ?? false,
    );
  }

  static ThemeMode? _themeModeFromName(Object? value) {
    return switch (value) {
      'system' => ThemeMode.system,
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => null,
    };
  }
}

@LazySingleton()
class AppPreferencesStorage {
  AppPreferencesStorage()
    : _preferences = SharedPreferencesAsync();

  static const String _storageKey = 'app_cache.preferences';

  final SharedPreferencesAsync _preferences;

  Future<void> writePreferences(AppPreferences preferences) {
    return _preferences.setString(_storageKey, preferences.toStorageValue());
  }

  Future<AppPreferences> readPreferences() async {
    final storedPreferences = await _preferences.getString(_storageKey);

    if (storedPreferences == null || storedPreferences.isEmpty) {
      return ensureDefaultsExist();
    }

    try {
      return AppPreferences.fromStorageValue(storedPreferences);
    } on FormatException {
      return ensureDefaultsExist();
    } on TypeError {
      return ensureDefaultsExist();
    }
  }

  Future<AppPreferences> ensureDefaultsExist() async {
    const defaults = AppPreferences();
    await writePreferences(defaults);
    return defaults;
  }
}
