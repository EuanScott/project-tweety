import 'package:injectable/injectable.dart';

import 'analytics.service.dart';

@module
abstract class AnalyticsModule {
  @lazySingleton
  Iterable<AnalyticsService> analyticsServices(
    AnalyticsService firebaseAnalytics,
  ) => <AnalyticsService>[firebaseAnalytics];
}
