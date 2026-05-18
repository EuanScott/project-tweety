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
  static const double _mediumWidthBreakpoint = 600;
  static const double _drawerWidthBreakpoint = 1200;

  final TabReselectController<TTab> _tabReselectController =
      TabReselectController<TTab>();

  @override
  Widget build(BuildContext context) {
    return TabReselectScope<TTab>(
      controller: _tabReselectController,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useRail = constraints.maxWidth >= _mediumWidthBreakpoint;
          final useDrawer = constraints.maxWidth >= _drawerWidthBreakpoint;
          final content = _NavigationContentTheme(
            useSideNavigation: useRail,
            useDrawer: useDrawer,
            child: widget.navigationShell,
          );

          return Scaffold(
            body: Row(
              children: [
                if (useDrawer)
                  SizedBox(
                    width: 304,
                    child: NavigationDrawer(
                      selectedIndex: widget.navigationShell.currentIndex,
                      onDestinationSelected: _onDestinationSelected,
                      children: widget.tabs
                          .map(
                            (tab) => NavigationDrawerDestination(
                              icon: Icon(tab.icon),
                              label: Text(tab.labelBuilder(context)),
                            ),
                          )
                          .toList(growable: false),
                    ),
                  )
                else if (useRail)
                  NavigationRail(
                    labelType: NavigationRailLabelType.all,
                    selectedIndex: widget.navigationShell.currentIndex,
                    onDestinationSelected: _onDestinationSelected,
                    destinations: widget.tabs
                        .map(
                          (tab) => NavigationRailDestination(
                            icon: Icon(tab.icon),
                            label: Text(tab.labelBuilder(context)),
                          ),
                        )
                        .toList(growable: false),
                  ),
                Expanded(child: content),
              ],
            ),
            bottomNavigationBar: useRail
                ? null
                : NavigationBar(
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
          );
        },
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

class _NavigationContentTheme extends StatelessWidget {
  const _NavigationContentTheme({
    required this.useSideNavigation,
    required this.useDrawer,
    required this.child,
  });

  final bool useSideNavigation;
  final bool useDrawer;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!useSideNavigation) {
      return child;
    }

    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;
    final foregroundColor =
        _sideNavigationForegroundColor(context, useDrawer: useDrawer) ??
        appBarTheme.foregroundColor ??
        theme.colorScheme.onSurface;
    final backgroundColor =
        _sideNavigationBackgroundColor(context, useDrawer: useDrawer) ??
        appBarTheme.backgroundColor ??
        theme.colorScheme.surface;

    return Theme(
      data: theme.copyWith(
        appBarTheme: appBarTheme.copyWith(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          iconTheme:
              appBarTheme.iconTheme?.copyWith(color: foregroundColor) ??
              IconThemeData(color: foregroundColor),
          actionsIconTheme:
              appBarTheme.actionsIconTheme?.copyWith(color: foregroundColor) ??
              IconThemeData(color: foregroundColor),
          titleTextStyle: appBarTheme.titleTextStyle?.copyWith(
            color: foregroundColor,
          ),
          toolbarTextStyle: appBarTheme.toolbarTextStyle?.copyWith(
            color: foregroundColor,
          ),
        ),
      ),
      child: child,
    );
  }

  Color? _sideNavigationBackgroundColor(
    BuildContext context, {
    required bool useDrawer,
  }) {
    if (useDrawer) {
      return NavigationDrawerTheme.of(context).backgroundColor;
    }

    return NavigationRailTheme.of(context).backgroundColor;
  }

  Color? _sideNavigationForegroundColor(
    BuildContext context, {
    required bool useDrawer,
  }) {
    if (useDrawer) {
      final drawerTheme = NavigationDrawerTheme.of(context);

      return drawerTheme.iconTheme?.resolve(const <WidgetState>{})?.color ??
          drawerTheme.labelTextStyle?.resolve(const <WidgetState>{})?.color;
    }

    final railTheme = NavigationRailTheme.of(context);

    return railTheme.unselectedIconTheme?.color ??
        railTheme.unselectedLabelTextStyle?.color;
  }
}
