import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:project_tweety/core/analytics/analytics_facade.dart';
import 'package:project_tweety/presentation/navigation/analytics/navigation_analytics_observer.dart';
import 'package:project_tweety/presentation/navigation/analytics/navigation_analytics_tracker.dart';
import 'package:project_tweety/presentation/navigation/navigator_keys.dart';
import 'package:project_tweety/presentation/navigation/routes.dart';
import 'package:project_tweety/presentation/navigation/widgets/app_navigation_shell.dart';
import 'package:project_tweety/presentation/navigation/widgets/app_route_error_page.dart';
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
  final navigatorKeys = AppNavigatorKeys();
  final analyticsTracker = analyticsFacade == null
      ? null
      : NavigationAnalyticsTracker(analyticsFacade);

  return GoRouter(
    navigatorKey: navigatorKeys.root,
    initialLocation: initialLocation,
    restorationScopeId: 'app_router',
    observers: _navigationObservers(analyticsTracker),
    errorBuilder: (context, state) => AppRouteErrorPage(error: state.error),
    routes: [
      GoRoute(
        path: AppRoutes.rootPath,
        redirect: (context, state) => AppRoutes.homePath,
      ),
      StatefulShellRoute.indexedStack(
        restorationScopeId: 'app_shell',
        builder: (context, state, navigationShell) {
          return AppNavigationShell(
            navigationShell: navigationShell,
            onTabRouteSelected: analyticsTracker?.trackScreenName,
          );
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: navigatorKeys.home,
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
          StatefulShellBranch(
            navigatorKey: navigatorKeys.cards,
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
          StatefulShellBranch(
            navigatorKey: navigatorKeys.settings,
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
      ),
    ],
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
