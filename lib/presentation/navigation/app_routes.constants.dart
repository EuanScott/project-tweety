/// Central route names and paths for app-level navigation.
///
/// Keep raw route strings here so feature pages can navigate through helpers
/// instead of hard-coding names or paths.
class AppRoutes {
  const new _();

  /// Entry location that redirects to [homePath].
  static const rootPath = '/';

  /// Named route for the sign-in page, outside the tab shell.
  static const signInName = 'signIn';

  /// Named route for the home tab root.
  static const homeName = 'home';

  /// Named route shown when a guarded route denies access.
  static const accessDeniedName = 'accessDenied';

  /// Named route for the cards tab root.
  static const cardsName = 'cards';

  /// Named route for a card details page inside the cards tab.
  static const cardsDetailName = 'cardsDetail';

  /// Named route for creating a card inside Cards.
  static const cardsNewName = 'cardsNew';

  /// Named route for the settings tab root.
  static const settingsName = 'settings';

  /// Named route for the display and language settings page.
  static const settingsAppPreferencesName = 'settingsAppPreferences';

  /// Absolute path for the sign-in page.
  static const signInPath = '/sign-in';

  /// Query parameter on [signInPath] that carries the location the person
  /// asked for, so the gate can take them there after they sign in.
  static const signInFromParameter = 'from';

  /// Absolute path for the home tab root.
  static const homePath = '/home';

  /// Absolute path for guarded-route access denial.
  static const accessDeniedPath = '/access-denied';

  /// Absolute path for the cards tab root.
  static const cardsPath = '/cards';

  /// Card id path parameter used by [cardsDetailPath].
  static const cardsDetailIdParameter = 'cardId';

  /// Relative child path for creating a card under [cardsPath].
  ///
  /// Card creation and card details are children of [cardsPath], so a compact
  /// region always stacks them on the list and can swipe back to it.
  static const cardsNewChildPath = 'new';

  /// Absolute path for creating a card under Cards.
  static const cardsNewPath = '$cardsPath/$cardsNewChildPath';

  /// Relative child path for card details under [cardsPath].
  static const cardsDetailChildPath = ':$cardsDetailIdParameter';

  /// Absolute path for card details under Cards.
  static const cardsDetailPath = '$cardsPath/$cardsDetailChildPath';

  /// Absolute path prefix for directly opening card details.
  static const cardsDetailFullPathPrefix = '$cardsPath/';

  /// Absolute path for the settings tab root.
  static const settingsPath = '/settings';

  /// Relative child path for app preferences under settings.
  static const settingsAppPreferencesPath = 'app-preferences';

  /// Absolute path for directly opening app preferences.
  static const settingsAppPreferencesFullPath = '/settings/app-preferences';
}
