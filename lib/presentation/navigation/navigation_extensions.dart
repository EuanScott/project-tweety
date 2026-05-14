import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'routes.dart';

/// App-specific navigation helpers available from a [BuildContext].
///
/// Feature pages should prefer these helpers over direct route names so route
/// structure stays centralized in the navigation layer.
extension AppNavigation on BuildContext {
  /// Navigates to the home tab root.
  void goHome() {
    goNamed(AppRoutes.homeName);
  }

  /// Pushes the display and language preferences page inside Settings.
  Future<T?> openAppPreferences<T extends Object?>() {
    return pushNamed<T>(AppRoutes.settingsAppPreferencesName);
  }
}
