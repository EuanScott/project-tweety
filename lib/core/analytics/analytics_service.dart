import 'dart:developer';
import 'package:injectable/injectable.dart';

abstract class AnalyticsService {
  Future<void> setUserId(String userId);

  Future<void> clearUserId();

  Future<void> trackEvent(String eventName, Map<String, Object?>? params);

  Future<void> logScreenView(String screenName, String? screenClass);
}

@LazySingleton(as: AnalyticsService)
class FirebaseAnalyticsService implements AnalyticsService {
  @override
  Future<void> setUserId(String userId) async {
    log('[FirebaseAnalytics] setUserId: $userId');
  }

  @override
  Future<void> clearUserId() async {
    log('[FirebaseAnalytics] clearUserId');
  }

  @override
  Future<void> trackEvent(
      String eventName,
      Map<String, Object?>? params,
      ) async {
    log('[FirebaseAnalytics] event: $eventName $params');
  }

  @override
  Future<void> logScreenView(String screenName, String? screenClass) async {
    log('[FirebaseAnalytics] screen: $screenName');
  }
}
