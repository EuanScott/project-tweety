class FeatureFlagKeys {
  static const String isFeatureEnabled = 'isFeatureEnabled';
}

class FeatureFlagDefaults {
  static Map<String, dynamic> defaults = {
    FeatureFlagKeys.isFeatureEnabled: false,
  };
}
