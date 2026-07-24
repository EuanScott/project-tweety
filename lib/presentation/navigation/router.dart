import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:navigation/navigation.dart';
import 'package:project_tweety/core/analytics/analytics_facade.dart';
import 'package:project_tweety/presentation/navigation/analytics/navigation_analytics_observer.dart';
import 'package:project_tweety/presentation/navigation/analytics/navigation_analytics_tracker.dart';
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/navigation/navigation_extensions.dart';
import 'package:project_tweety/presentation/navigation/route_access_policy.dart';
import 'package:project_tweety/presentation/navigation/routes.dart';
import 'package:project_tweety/presentation/navigation/tabs/app_tab.dart';
import 'package:project_tweety/presentation/navigation/tabs/app_tab_config.dart';
import 'package:project_tweety/presentation/pages/access_denied/access_denied.page.dart';
import 'package:project_tweety/presentation/pages/app_preferences/app_preferences.page.dart';
import 'package:project_tweety/presentation/pages/cards/cards.page.dart';
import 'package:project_tweety/presentation/pages/cards/bloc/cards.bloc.dart';
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
  bool canAccessSettings = true,
}) {
  final analyticsTracker = analyticsFacade == null
      ? null
      : NavigationAnalyticsTracker(analyticsFacade);
  final routeAccessPolicy = RouteAccessPolicy(
    canAccessSettings: canAccessSettings,
  );

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
          GoRoute(
            path: AppRoutes.accessDeniedPath,
            name: AppRoutes.accessDeniedName,
            builder: (context, state) => const AccessDeniedPage(),
          ),
        ],
      ),
      NavigationBranch<AppTab>(
        tab: AppTab.cards,
        restorationScopeId: 'cards_branch',
        observers: _navigationObservers(analyticsTracker),
        routes: [
          ShellRoute(
            builder: (context, state, child) {
              return BlocProvider(
                create: (_) => GetIt.I<CardsBloc>()..add(const CardsStarted()),
                child: child,
              );
            },
            routes: [
              GoRoute(
                path: AppRoutes.cardsPath,
                name: AppRoutes.cardsName,
                builder: (context, state) => const Cards(),
                routes: [
                  GoRoute(
                    path: AppRoutes.cardsNewPath,
                    name: AppRoutes.cardsNewName,
                    builder: (context, state) => const Cards(isCreating: true),
                  ),
                  GoRoute(
                    path: AppRoutes.cardsDetailPath,
                    name: AppRoutes.cardsDetailName,
                    builder: (context, state) {
                      final cardId = state
                          .pathParameters[AppRoutes.cardsDetailIdParameter]!;

                      return Cards(selectedCardId: cardId);
                    },
                  ),
                ],
              ),
            ],
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
            redirect: (context, state) =>
                _settingsAccessRedirect(policy: routeAccessPolicy),
            builder: (context, state) => const Settings(),
            routes: [
              GoRoute(
                path: AppRoutes.settingsAppPreferencesPath,
                name: AppRoutes.settingsAppPreferencesName,
                redirect: (context, state) =>
                    _settingsAccessRedirect(policy: routeAccessPolicy),
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

String? _settingsAccessRedirect({required RouteAccessPolicy policy}) {
  return policy.settingsAccessDecision().redirectPath;
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
