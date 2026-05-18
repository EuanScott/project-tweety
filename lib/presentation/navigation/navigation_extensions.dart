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

  /// Pushes a card details page inside Cards.
  Future<T?> openCardDetails<T extends Object?>(String cardId) {
    return pushNamed<T>(
      AppRoutes.cardsDetailName,
      pathParameters: {AppRoutes.cardsDetailIdParameter: cardId},
    );
  }

  /// Replaces the current cards location with a card details route.
  void goCardDetails(String cardId) {
    goNamed(
      AppRoutes.cardsDetailName,
      pathParameters: {AppRoutes.cardsDetailIdParameter: cardId},
    );
  }
}
