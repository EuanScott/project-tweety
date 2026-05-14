import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:project_tweety/core/analytics/analytics_facade.dart';

/// De-duplicates navigation screen view events before sending analytics.
///
/// Both navigator observers and tab selections can report route names. This
/// tracker keeps the last screen name so repeated rebuilds or branch switches
/// do not spam analytics.
class NavigationAnalyticsTracker {
  /// Creates a tracker backed by [AnalyticsFacade].
  NavigationAnalyticsTracker(this._analyticsFacade);

  final AnalyticsFacade _analyticsFacade;
  String? _lastScreenName;

  /// Tracks a [Route] using its settings name and runtime type.
  void track(Route<dynamic>? route) {
    trackScreenName(
      route?.settings.name,
      screenClass: route?.runtimeType.toString(),
    );
  }

  /// Tracks [screenName] if it differs from the previous screen.
  void trackScreenName(String? screenName, {String? screenClass}) {
    if (screenName == null ||
        screenName.isEmpty ||
        screenName == _lastScreenName) {
      return;
    }

    _lastScreenName = screenName;
    unawaited(
      _analyticsFacade.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      ),
    );
  }
}
