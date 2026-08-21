import 'package:flutter/widgets.dart';
import 'package:project_tweety/presentation/navigation/analytics/navigation_analytics_tracker.dart';

/// Navigator observer that forwards route changes to navigation analytics.
class NavigationAnalyticsObserver(final NavigationAnalyticsTracker _analyticsTracker)
    extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _analyticsTracker.track(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _analyticsTracker.track(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _analyticsTracker.track(previousRoute);
  }
}
