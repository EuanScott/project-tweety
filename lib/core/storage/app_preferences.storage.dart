import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_preferences.storage.freezed.dart';

// TODO:
// * core/storage currently depends on Flutter ThemeMode, which leaks UI concerns into storage.
// * The storage key still uses cache naming even though the behavior is preferences-oriented.
// * ensureDefaultsExist() writes defaults eagerly, which is fine for preferences but not a good default for a generic cache service.
// * There are two different AppPreferences models, one in core storage and one in domain, which works but adds naming friction.

@freezed
abstract class AppPreferences with _$AppPreferences {
  const factory AppPreferences({
    @Default(ThemeMode.system) ThemeMode themeMode,
    String? languageCode,
  }) = _AppPreferences;

  const AppPreferences._();

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

    return _fromJson(decoded);
  }

  static AppPreferences _fromJson(Map<String, dynamic> json) {
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
