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
import 'package:project_tweety/presentation/pages/logs/logs.page.dart';
import 'package:project_tweety/presentation/pages/logs/bloc/logs.bloc.dart';
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
        pageBuilder: (context, state) =>
            platformPage(context, state, const SignInPage()),
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
            pageBuilder: (context, state) =>
                platformPage(context, state, const Home()),
          ),
          GoRoute(
            path: AppRoutes.accessDeniedPath,
            name: AppRoutes.accessDeniedName,
            pageBuilder: (context, state) =>
                platformPage(context, state, const AccessDeniedPage()),
          ),
        ],
      ),
      NavigationBranch<AppTab>(
        tab: AppTab.logs,
        restorationScopeId: 'logs_branch',
        observers: _navigationObservers(analyticsTracker),
        routes: [
          ShellRoute(
            builder: (context, state, child) {
              return PaneLayoutScope(
                child: BlocProvider(
                  create: (_) => GetIt.I<LogsBloc>()..add(const LogsStarted()),
                  child: child,
                ),
              );
            },
            routes: [
              GoRoute(
                path: AppRoutes.logsPath,
                name: AppRoutes.logsName,
                pageBuilder: (context, state) => _logsPage(
                  context,
                  state,
                  const Logs(),
                  title: AppLocalizations.of(context)!.logsTab,
                  isCovered: state.fullPath != AppRoutes.logsPath,
                ),
                routes: [
                  GoRoute(
                    path: AppRoutes.logsNewChildPath,
                    name: AppRoutes.logsNewName,
                    pageBuilder: (context, state) => _logsPage(
                      context,
                      state,
                      const Logs(isCreating: true),
                      isSelection: true,
                    ),
                  ),
                  GoRoute(
                    path: AppRoutes.logsDetailChildPath,
                    name: AppRoutes.logsDetailName,
                    pageBuilder: (context, state) {
                      final logEntryId = state
                          .pathParameters[AppRoutes.logsDetailIdParameter]!;

                      return _logsPage(
                        context,
                        state,
                        Logs(selectedLogEntryId: logEntryId),
                        isSelection: true,
                      );
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
            pageBuilder: (context, state) =>
                platformPage(context, state, const Settings()),
            routes: [
              GoRoute(
                path: AppRoutes.settingsAppPreferencesPath,
                name: AppRoutes.settingsAppPreferencesName,
                redirect: (context, state) =>
                    _settingsAccessRedirect(policy: routeAccessPolicy),
                pageBuilder: (context, state) =>
                    platformPage(context, state, const AppPreferencesPage()),
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

/// The one compact page the editor and every log entry share.
const _logsSelectionPageKey = ValueKey('logs-selection');

/// Builds the page for a Logs location.
///
/// A compact region stacks a native page on the list, so a log entry or the editor
/// always swipes back to it. The editor and every log entry share that one page, so
/// a new log entry replaces its editor in place instead of sliding in over it.
///
/// A split region shows the list and the selection side by side on one page.
/// The topmost location owns that page under a shared key, so it stays mounted
/// as the selection changes: the list keeps its scroll position and nothing
/// animates over a layout that never changed. The list location is [isCovered]
/// by a selection there and is never visible, so it builds nothing.
Page<void> _logsPage(
  BuildContext context,
  GoRouterState state,
  Widget child, {
  String? title,
  bool isCovered = false,
  bool isSelection = false,
}) {
  if (PaneLayoutScope.of(context) != PaneLayoutMode.split) {
    return platformPage(
      context,
      state,
      child,
      key: isSelection ? _logsSelectionPageKey : null,
      title: title,
    );
  }

  if (isCovered) {
    return NoTransitionPage<void>(
      key: state.pageKey,
      child: const SizedBox.shrink(),
    );
  }

  return NoTransitionPage<void>(
    key: const ValueKey('logs-panes'),
    name: state.name,
    child: child,
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
