import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:navigation/src/navigation_branch.dart';
import 'package:navigation/src/navigation_navigator_keys.dart';
import 'package:navigation/src/navigation_shell.dart';
import 'package:navigation/src/navigation_tab_config.dart';

/// Creates a configured tab-shell [GoRouter].
GoRouter createNavigationRouter<TTab extends Object>({
  required String initialLocation,
  required String rootPath,
  required String rootRedirectPath,
  required List<NavigationTabConfig<TTab>> tabs,
  required List<NavigationBranch<TTab>> branches,
  required Widget Function(BuildContext context, Exception? error) errorBuilder,
  GlobalKey<NavigatorState>? navigatorKey,
  String? restorationScopeId,
  String? shellRestorationScopeId,
  List<NavigatorObserver>? observers,
  ValueChanged<String>? onTabRouteSelected,
}) {
  _validateRouterConfig(tabs: tabs, branches: branches);

  final navigationKeys = NavigationNavigatorKeys<TTab>(
    tabs.map((tab) => tab.tab),
  );
  final branchesByTab = <TTab, NavigationBranch<TTab>>{
    for (final branch in branches) branch.tab: branch,
  };

  return GoRouter(
    navigatorKey: navigatorKey ?? navigationKeys.root,
    initialLocation: initialLocation,
    restorationScopeId: restorationScopeId,
    observers: observers,
    errorBuilder: (context, state) => errorBuilder(context, state.error),
    routes: [
      GoRoute(path: rootPath, redirect: (context, state) => rootRedirectPath),
      StatefulShellRoute.indexedStack(
        restorationScopeId: shellRestorationScopeId,
        builder: (context, state, navigationShell) {
          return NavigationShell<TTab>(
            navigationShell: navigationShell,
            tabs: tabs,
            onTabRouteSelected: onTabRouteSelected,
          );
        },
        branches: tabs
            .map((tabConfig) {
              final branch = branchesByTab[tabConfig.tab]!;

              return StatefulShellBranch(
                navigatorKey:
                    branch.navigatorKey ??
                    navigationKeys.branchKeyFor(branch.tab),
                restorationScopeId: branch.restorationScopeId,
                observers: branch.observers,
                routes: branch.routes,
              );
            })
            .toList(growable: false),
      ),
    ],
  );
}

void _validateRouterConfig<TTab extends Object>({
  required List<NavigationTabConfig<TTab>> tabs,
  required List<NavigationBranch<TTab>> branches,
}) {
  if (tabs.isEmpty) {
    throw ArgumentError.value(tabs, 'tabs', 'At least one tab is required');
  }

  if (tabs.length != branches.length) {
    throw ArgumentError(
      'The number of navigation tabs must match the number of branches',
    );
  }

  final tabIds = tabs.map((tab) => tab.tab).toSet();
  if (tabIds.length != tabs.length) {
    throw ArgumentError.value(tabs, 'tabs', 'Tabs must be unique');
  }

  final branchIds = branches.map((branch) => branch.tab).toSet();
  if (branchIds.length != branches.length) {
    throw ArgumentError.value(branches, 'branches', 'Branches must be unique');
  }

  final missingBranches = tabIds.difference(branchIds);
  if (missingBranches.isNotEmpty) {
    throw ArgumentError.value(
      branches,
      'branches',
      'Missing branches for tabs: $missingBranches',
    );
  }

  final unknownBranches = branchIds.difference(tabIds);
  if (unknownBranches.isNotEmpty) {
    throw ArgumentError.value(
      branches,
      'branches',
      'Branches include unknown tabs: $unknownBranches',
    );
  }
}
