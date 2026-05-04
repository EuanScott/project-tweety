import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Object _unset = Object();

// TODO:
// * core/storage currently depends on Flutter ThemeMode, which leaks UI concerns into storage.
// * The storage key still uses cache naming even though the behavior is preferences-oriented.
// * ensureDefaultsExist() writes defaults eagerly, which is fine for preferences but not a good default for a generic cache service.
// * There are two different AppPreferences models, one in core storage and one in domain, which works but adds naming friction.

@immutable
class AppPreferences {
  const AppPreferences({this.themeMode = ThemeMode.system, this.languageCode});

  final ThemeMode themeMode;
  final String? languageCode;

  AppPreferences copyWith({
    ThemeMode? themeMode,
    Object? languageCode = _unset,
  }) {
    return AppPreferences(
      themeMode: themeMode ?? this.themeMode,
      languageCode: identical(languageCode, _unset)
          ? this.languageCode
          : languageCode as String?,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'themeMode': themeMode.name,
      'languageCode': languageCode,
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
      languageCode: json['languageCode'] as String?,
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
  AppPreferencesStorage() : _preferences = SharedPreferencesAsync();

  static const String _storageKey = 'app_cache.preferences';

  final SharedPreferencesAsync _preferences;

  Future<void> writePreferences(AppPreferences preferences) {
    return _preferences.setString(_storageKey, preferences.toStorageValue());
  }

  Future<AppPreferences> readPreferences() async {
    final storedPreferences = await _preferences.getString(_storageKey);

    if (storedPreferences == null || storedPreferences.isEmpty) {
      return const AppPreferences();
    }

    try {
      return AppPreferences.fromStorageValue(storedPreferences);
    } on FormatException {
      return const AppPreferences();
    } on TypeError {
      return const AppPreferences();
    }
  }

  Future<AppPreferences> ensureDefaultsExist() async {
    const defaults = AppPreferences();
    await writePreferences(defaults);
    return defaults;
  }
}
