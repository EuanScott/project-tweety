import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:navigation/navigation.dart';
import 'package:project_tweety/core/analytics/analytics.facade.dart';
import 'package:project_tweety/presentation/navigation/analytics/navigation_analytics.observer.dart';
import 'package:project_tweety/presentation/navigation/analytics/navigation_analytics_tracker.service.dart';
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/navigation/navigation.extension.dart';
import 'package:project_tweety/presentation/navigation/route_access.policy.dart';
import 'package:project_tweety/presentation/navigation/session_notifier.service.dart';
import 'package:project_tweety/presentation/navigation/app_routes.constants.dart';
import 'package:project_tweety/presentation/navigation/tabs/app_tab.model.dart';
import 'package:project_tweety/presentation/navigation/tabs/app_tab_configs.constants.dart';
import 'package:project_tweety/presentation/pages/access_denied/access_denied.page.dart';
import 'package:project_tweety/presentation/pages/app_preferences/app_preferences.page.dart';
import 'package:project_tweety/presentation/pages/cards/cards.page.dart';
import 'package:project_tweety/presentation/pages/cards/bloc/cards.bloc.dart';
import 'package:project_tweety/presentation/pages/home/home.page.dart';
import 'package:project_tweety/presentation/pages/settings/settings.page.dart';
import 'package:project_tweety/presentation/pages/sign_in/sign_in.page.dart';

/// Creates the app's configured [GoRouter].
///
/// App bootstrap owns this object so the router survives theme and locale
/// rebuilds. [initialLocation] is exposed for deep-link widget tests, while
/// [analyticsFacade] is optional so the router can be tested without analytics.
///
/// [session] drives the launch gate: a top-level redirect that keeps signed-out
/// people on sign-in, re-run each time the Session changes. The caller owns
/// [session] and disposes it with the router.
GoRouter createRouter({
  required SessionNotifier session,
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
    routes: [
      GoRoute(
        path: AppRoutes.signInPath,
        name: AppRoutes.signInName,
        pageBuilder: (context, state) => _platformPage(
          state,
          const SignInPage(),
          Theme.of(context).platform,
        ),
      ),
    ],
    redirect: (context, state) => routeAccessPolicy
        .sessionAccessDecision(session: session.session, location: state.uri)
        .redirectPath,
    refreshListenable: session,
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
              return PaneLayoutScope(
                child: BlocProvider(
                  create: (_) =>
                      GetIt.I<CardsBloc>()..add(const CardsStarted()),
                  child: child,
                ),
              );
            },
            routes: [
              GoRoute(
                path: AppRoutes.cardsPath,
                name: AppRoutes.cardsName,
                pageBuilder: (context, state) =>
                    _cardsPage(context, state, const Cards()),
              ),
              GoRoute(
                path: AppRoutes.cardsNewPath,
                name: AppRoutes.cardsNewName,
                pageBuilder: (context, state) =>
                    _cardsPage(context, state, const Cards(isCreating: true)),
              ),
              GoRoute(
                path: AppRoutes.cardsDetailPath,
                name: AppRoutes.cardsDetailName,
                pageBuilder: (context, state) {
                  final cardId =
                      state.pathParameters[AppRoutes.cardsDetailIdParameter]!;

                  return _cardsPage(
                    context,
                    state,
                    Cards(selectedCardId: cardId),
                  );
                },
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

/// The Cards locations resolve to one page while the region shows both panes.
///
/// Moving between the list, a card, and the editor changes what the panes hold,
/// not which page is on screen. Giving them a shared key keeps the same page
/// mounted, so the list keeps its scroll position and nothing animates over a
/// layout that never changed. A compact region genuinely stacks pages, so there
/// each location keeps its own key and its own transition.
Page<void> _cardsPage(BuildContext context, GoRouterState state, Widget child) {
  final isSplit = PaneLayoutScope.of(context) == PaneLayoutMode.split;
  final isStacked = GoRouter.of(context).canPop();

  if (isSplit && !isStacked) {
    return NoTransitionPage<void>(
      key: const ValueKey('cards-panes'),
      child: child,
    );
  }

  return _platformPage(state, child, Theme.of(context).platform);
}

Page<void> _platformPage(
  GoRouterState state,
  Widget child,
  TargetPlatform platform,
) {
  return switch (platform) {
    TargetPlatform.iOS || TargetPlatform.macOS => CupertinoPage<void>(
      key: state.pageKey,
      child: child,
    ),
    _ => MaterialPage<void>(key: state.pageKey, child: child),
  };
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
