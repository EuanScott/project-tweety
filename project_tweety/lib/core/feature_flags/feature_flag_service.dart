import 'dart:developer';

// import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:injectable/injectable.dart';
import 'package:project_tweety/core/feature_flags/feature_flag_keys.dart';

@injectable
class FeatureFlagService {
  FeatureFlagService(this._remoteConfig);

  late final FirebaseRemoteConfig _remoteConfig;

  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 24),
      ),
    );

    _remoteConfig.onConfigUpdated.listen((event) async {
      await _remoteConfig.activate();
    });

    await _remoteConfig.setDefaults(FeatureFlagDefaults.defaults);

    await _fetchAndActivate();
  }

  Future<void> _fetchAndActivate() async {
    try {
      final isRetrievedAndActivated = await _remoteConfig.fetchAndActivate();

      if (isRetrievedAndActivated) {
        final allValues = _remoteConfig.getAll();
        log('Firebase remote config values: $allValues');
      } else {
        log('Firebase remote Config fetch and activate failed');
      }

      log('Firebase lastFetchTime ${_remoteConfig.lastFetchTime}');
      log('Firebase lastFetchStatus ${_remoteConfig.lastFetchStatus}');
    } catch (e) {
      log('Firebase failed to fetch remote config: $e');
      rethrow;
    }
  }

  //region Getters
  bool isFeatureEnabled() =>
      _remoteConfig.getBool(FeatureFlagKeys.isFeatureEnabled);

  //endregion
}
