import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/navigation/tab_reselect/tab_reselect_controller.dart';
import 'package:project_tweety/presentation/navigation/tab_reselect/tab_reselect_scope.dart';
import 'package:project_tweety/presentation/navigation/tabs/app_tab_config.dart';

/// Bottom-navigation shell for the app's top-level routes.
///
/// The shell renders the active `StatefulShellRoute` branch and preserves each
/// tab's nested navigation stack. Tapping a nested active tab returns it to its
/// root route; tapping an active root tab can run a registered
/// `TabReselectHandler`.
class AppNavigationShell extends StatefulWidget {
  /// Creates the shell around a [StatefulNavigationShell].
  const AppNavigationShell({
    required this.navigationShell,
    this.onTabRouteSelected,
    super.key,
  });

  /// The shell route object supplied by `go_router`.
  final StatefulNavigationShell navigationShell;

  /// Optional route-name callback used by analytics when tabs are selected.
  final ValueChanged<String>? onTabRouteSelected;

  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell> {
  final TabReselectController _tabReselectController = TabReselectController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return TabReselectScope(
      controller: _tabReselectController,
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: widget.navigationShell.currentIndex,
          onDestinationSelected: _onDestinationSelected,
          destinations: appTabConfigs
              .map(
                (item) => NavigationDestination(
                  icon: Icon(item.icon),
                  label: item.label(l10n),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }

  void _onDestinationSelected(int index) {
    final tabConfig = appTabConfigs[index];

    if (index != widget.navigationShell.currentIndex) {
      widget.onTabRouteSelected?.call(tabConfig.routeName);
      widget.navigationShell.goBranch(index);
      return;
    }

    final currentPath = GoRouterState.of(context).uri.path;

    if (currentPath != tabConfig.rootPath) {
      widget.onTabRouteSelected?.call(tabConfig.routeName);
      widget.navigationShell.goBranch(index, initialLocation: true);
      return;
    }

    _tabReselectController.handle(tabConfig.tab);
  }
}
