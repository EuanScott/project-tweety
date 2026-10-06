import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.constants.dart';

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

  /// Shows a card's details inside Cards, stacked on the list in a compact
  /// region.
  void goCardDetails(String cardId) {
    goNamed(
      AppRoutes.cardsDetailName,
      pathParameters: {AppRoutes.cardsDetailIdParameter: cardId},
    );
  }

  /// Shows the card creation editor inside Cards, stacked on the list in a
  /// compact region.
  void goNewCard() {
    goNamed(AppRoutes.cardsNewName);
  }

  /// Replaces the current Cards branch location with its collection root.
  void goCards() {
    goNamed(AppRoutes.cardsName);
  }
}
