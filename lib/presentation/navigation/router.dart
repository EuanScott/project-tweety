import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:navigation/navigation.dart';
import 'package:project_tweety/core/analytics/analytics_facade.dart';
import 'package:project_tweety/presentation/navigation/analytics/navigation_analytics_observer.dart';
import 'package:project_tweety/presentation/navigation/analytics/navigation_analytics_tracker.dart';
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/navigation/navigation_extensions.dart';
import 'package:project_tweety/presentation/navigation/routes.dart';
import 'package:project_tweety/presentation/navigation/tabs/app_tab.dart';
import 'package:project_tweety/presentation/navigation/tabs/app_tab_config.dart';
import 'package:project_tweety/presentation/pages/app_preferences/app_preferences.page.dart';
import 'package:project_tweety/presentation/pages/cards/cards.page.dart';
import 'package:project_tweety/presentation/pages/home/home.page.dart';
import 'package:project_tweety/presentation/pages/settings/settings.page.dart';

/// Creates the app's configured [GoRouter].
///
/// App bootstrap owns this object so the router survives theme and locale
/// rebuilds. [initialLocation] is exposed for deep-link widget tests, while
/// [analyticsFacade] is optional so the router can be tested without analytics.
GoRouter createRouter({
  String initialLocation = AppRoutes.rootPath,
  AnalyticsFacade? analyticsFacade,
}) {
  final analyticsTracker = analyticsFacade == null
      ? null
      : NavigationAnalyticsTracker(analyticsFacade);

  return createNavigationRouter<AppTab>(
    initialLocation: initialLocation,
    rootPath: AppRoutes.rootPath,
    rootRedirectPath: AppRoutes.homePath,
    tabs: appTabConfigs,
    branches: [
      NavigationBranch<AppTab>(
        tab: AppTab.home,
        restorationScopeId: 'home_branch',
        observers: _navigationObservers(analyticsTracker),
        routes: [
          GoRoute(
            path: AppRoutes.homePath,
            name: AppRoutes.homeName,
            builder: (context, state) => const Home(),
          ),
        ],
      ),
      NavigationBranch<AppTab>(
        tab: AppTab.cards,
        restorationScopeId: 'cards_branch',
        observers: _navigationObservers(analyticsTracker),
        routes: [
          GoRoute(
            path: AppRoutes.cardsPath,
            name: AppRoutes.cardsName,
            builder: (context, state) => const Cards(),
          ),
        ],
      ),
      NavigationBranch<AppTab>(
        tab: AppTab.settings,
        restorationScopeId: 'settings_branch',
        observers: _navigationObservers(analyticsTracker),
        routes: [
          GoRoute(
            path: AppRoutes.settingsPath,
            name: AppRoutes.settingsName,
            builder: (context, state) => const Settings(),
            routes: [
              GoRoute(
                path: AppRoutes.settingsAppPreferencesPath,
                name: AppRoutes.settingsAppPreferencesName,
                builder: (context, state) => const AppPreferencesPage(),
              ),
            ],
          ),
        ],
      ),
    ],
    restorationScopeId: 'app_router',
    observers: _navigationObservers(analyticsTracker),
    shellRestorationScopeId: 'app_shell',
    errorBuilder: _navigationErrorBuilder,
    onTabRouteSelected: analyticsTracker?.trackScreenName,
  );
}

Widget _navigationErrorBuilder(BuildContext context, Exception? error) {
  final l10n = AppLocalizations.of(context)!;

  return NavigationRouteErrorPage(
    error: error,
    title: l10n.navigationErrorTitle,
    description: l10n.navigationErrorDescription,
    actionLabel: l10n.navigationErrorGoHome,
    onActionPressed: context.goHome,
  );
}

List<NavigatorObserver>? _navigationObservers(
  NavigationAnalyticsTracker? analyticsTracker,
) {
  if (analyticsTracker == null) {
    return null;
  }

  return [NavigationAnalyticsObserver(analyticsTracker)];
}
