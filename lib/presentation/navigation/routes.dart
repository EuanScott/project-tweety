/// Central route names and paths for app-level navigation.
///
/// Keep raw route strings here so feature pages can navigate through helpers
/// instead of hard-coding names or paths.
class AppRoutes {
  const AppRoutes._();

  /// Entry location that redirects to [homePath].
  static const rootPath = '/';

  /// Named route for the home tab root.
  static const homeName = 'home';

  /// Named route for the cards tab root.
  static const cardsName = 'cards';

  /// Named route for a card details page inside the cards tab.
  static const cardsDetailName = 'cardsDetail';

  /// Named route for the settings tab root.
  static const settingsName = 'settings';

  /// Named route for the display and language settings page.
  static const settingsAppPreferencesName = 'settingsAppPreferences';

  /// Absolute path for the home tab root.
  static const homePath = '/home';

  /// Absolute path for the cards tab root.
  static const cardsPath = '/cards';

  /// Card id path parameter used by [cardsDetailPath].
  static const cardsDetailIdParameter = 'cardId';

  /// Relative child path for card details under cards.
  static const cardsDetailPath = ':$cardsDetailIdParameter';

  /// Absolute path prefix for directly opening card details.
  static const cardsDetailFullPathPrefix = '$cardsPath/';

  /// Absolute path for the settings tab root.
  static const settingsPath = '/settings';

  /// Relative child path for app preferences under settings.
  static const settingsAppPreferencesPath = 'app-preferences';

  /// Absolute path for directly opening app preferences.
  static const settingsAppPreferencesFullPath = '/settings/app-preferences';
}
