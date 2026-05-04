import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

final class InMemorySharedPreferencesAsyncPlatform
    extends SharedPreferencesAsyncPlatform {
  InMemorySharedPreferencesAsyncPlatform([Map<String, Object>? seedData])
    : _data = <String, Object>{...?seedData};

  final Map<String, Object> _data;

  @override
  Future<void> clear(
    ClearPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    final allowList = parameters.filter.allowList;

    if (allowList == null) {
      _data.clear();
      return;
    }

    for (final key in allowList) {
      _data.remove(key);
    }
  }

  @override
  Future<bool?> getBool(String key, SharedPreferencesOptions options) async {
    return _data[key] as bool?;
  }

  @override
  Future<double?> getDouble(
    String key,
    SharedPreferencesOptions options,
  ) async {
    return _data[key] as double?;
  }

  @override
  Future<int?> getInt(String key, SharedPreferencesOptions options) async {
    return _data[key] as int?;
  }

  @override
  Future<Set<String>> getKeys(
    GetPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    final allowList = parameters.filter.allowList;

    if (allowList == null) {
      return _data.keys.toSet();
    }

    return _data.keys.where(allowList.contains).toSet();
  }

  @override
  Future<Map<String, Object>> getPreferences(
    GetPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    final allowList = parameters.filter.allowList;

    if (allowList == null) {
      return Map<String, Object>.from(_data);
    }

    return Map<String, Object>.fromEntries(
      _data.entries.where((entry) => allowList.contains(entry.key)),
    );
  }

  @override
  Future<String?> getString(
    String key,
    SharedPreferencesOptions options,
  ) async {
    return _data[key] as String?;
  }

  @override
  Future<List<String>?> getStringList(
    String key,
    SharedPreferencesOptions options,
  ) async {
    final value = _data[key];

    if (value is List<String>) {
      return value;
    }

    return null;
  }

  @override
  Future<void> setBool(
    String key,
    bool value,
    SharedPreferencesOptions options,
  ) async {
    _data[key] = value;
  }

  @override
  Future<void> setDouble(
    String key,
    double value,
    SharedPreferencesOptions options,
  ) async {
    _data[key] = value;
  }

  @override
  Future<void> setInt(
    String key,
    int value,
    SharedPreferencesOptions options,
  ) async {
    _data[key] = value;
  }

  @override
  Future<void> setString(
    String key,
    String value,
    SharedPreferencesOptions options,
  ) async {
    _data[key] = value;
  }

  @override
  Future<void> setStringList(
    String key,
    List<String> value,
    SharedPreferencesOptions options,
  ) async {
    _data[key] = value;
  }
}
