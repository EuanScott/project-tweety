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

  /// Named route for the logs tab root.
  static const logsName = 'logs';

  /// Named route for a log entry details page inside the logs tab.
  static const logsDetailName = 'logsDetail';

  /// Named route for creating a log entry inside Logs.
  static const logsNewName = 'logsNew';

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

  /// Named route for the not-found page, shown over Home.
  static const homeNotFoundName = 'homeNotFound';

  /// Relative child path for the not-found page under [homePath].
  static const homeNotFoundChildPath = 'not-found';

  /// Absolute path for the not-found page. A location no route matches
  /// redirects here.
  static const homeNotFoundPath = '$homePath/$homeNotFoundChildPath';

  /// Absolute path for guarded-route access denial.
  static const accessDeniedPath = '/access-denied';

  /// Absolute path for the logs tab root.
  static const logsPath = '/logs';

  /// Log entry id path parameter used by [logsDetailPath].
  static const logsDetailIdParameter = 'entryId';

  /// Relative child path for creating a log entry under [logsPath].
  ///
  /// Log entry creation and log entry details are children of [logsPath], so a compact
  /// region always stacks them on the list and can swipe back to it.
  static const logsNewChildPath = 'new';

  /// Absolute path for creating a log entry under Logs.
  static const logsNewPath = '$logsPath/$logsNewChildPath';

  /// Relative child path for log entry details under [logsPath].
  static const logsDetailChildPath = ':$logsDetailIdParameter';

  /// Absolute path for log entry details under Logs.
  static const logsDetailPath = '$logsPath/$logsDetailChildPath';

  /// Absolute path prefix for directly opening log entry details.
  static const logsDetailFullPathPrefix = '$logsPath/';

  /// Absolute path for the settings tab root.
  static const settingsPath = '/settings';

  /// Relative child path for app preferences under settings.
  static const settingsAppPreferencesPath = 'app-preferences';

  /// Absolute path for directly opening app preferences.
  static const settingsAppPreferencesFullPath = '/settings/app-preferences';

  /// A path no route matches, so going to it shows the route error page as a
  /// broken link would. Never register a route for it.
  static const routeErrorPreviewPath = '/page-not-found-preview';
}
