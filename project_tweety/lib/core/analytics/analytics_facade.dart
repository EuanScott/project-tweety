import 'package:injectable/injectable.dart';
import 'analytics_service.dart';

@lazySingleton
class AnalyticsFacade {
  AnalyticsFacade(this._services);

  final Iterable<AnalyticsService> _services;

  Future<void> setUserId(String userId) async {
    for (final s in _services) {
      try {
        await s.setUserId(userId);
      } catch (_) {}
    }
  }

  Future<void> clearUserId() async {
    for (final s in _services) {
      try {
        await s.clearUserId();
      } catch (_) {}
    }
  }

  Future<void> trackEvent(String name, Map<String, Object?>? params) async {
    for (final s in _services) {
      try {
        await s.trackEvent(name, params);
      } catch (_) {}
    }
  }

  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    for (final s in _services) {
      try {
        await s.logScreenView(screenName, screenClass);
      } catch (_) {}
    }
  }
}
