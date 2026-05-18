import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:navigation/src/navigation_tab_config.dart';
import 'package:navigation/src/tab_reselect/tab_reselect_controller.dart';
import 'package:navigation/src/tab_reselect/tab_reselect_scope.dart';

/// Bottom-navigation shell for top-level tab routes.
///
/// The shell renders the active [StatefulNavigationShell] branch and preserves
/// each tab's nested navigation stack. Tapping a nested active tab returns it
/// to its root route; tapping an active root tab can run a registered
/// [TabReselectController] callback.
class NavigationShell<TTab extends Object> extends StatefulWidget {
  /// Creates a shell around [navigationShell].
  const NavigationShell({
    required this.navigationShell,
    required this.tabs,
    this.onTabRouteSelected,
    super.key,
  });

  /// The shell route object supplied by `go_router`.
  final StatefulNavigationShell navigationShell;

  /// Ordered top-level tab configurations.
  final List<NavigationTabConfig<TTab>> tabs;

  /// Optional route-name callback used by analytics when tabs are selected.
  final ValueChanged<String>? onTabRouteSelected;

  @override
  State<NavigationShell<TTab>> createState() => _NavigationShellState<TTab>();
}

class _NavigationShellState<TTab extends Object>
    extends State<NavigationShell<TTab>> {
  final TabReselectController<TTab> _tabReselectController =
      TabReselectController<TTab>();

  @override
  Widget build(BuildContext context) {
    return TabReselectScope<TTab>(
      controller: _tabReselectController,
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: widget.navigationShell.currentIndex,
          onDestinationSelected: _onDestinationSelected,
          destinations: widget.tabs
              .map(
                (tab) => NavigationDestination(
                  icon: Icon(tab.icon),
                  label: tab.labelBuilder(context),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }

  void _onDestinationSelected(int index) {
    final tabConfig = widget.tabs[index];

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
