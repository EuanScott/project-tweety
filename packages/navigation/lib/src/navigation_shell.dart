import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:navigation/src/navigation_tab_config.dart';
import 'package:navigation/src/tab_reselect/tab_reselect_controller.dart';
import 'package:navigation/src/tab_reselect/tab_reselect_scope.dart';

const String _sideNavigationToggleTooltip = 'Toggle side navigation';

/// Bottom-navigation shell for top-level tab routes.
///
/// The shell renders the active [StatefulNavigationShell] branch and preserves
/// each tab's nested navigation stack. Tapping a nested active tab returns it
/// to its root route; tapping an active root tab can run a registered
/// [TabReselectController] callback.
/// Creates a shell around [navigationShell].
class const NavigationShell<TTab extends Object>({
  /// The shell route object supplied by `go_router`.
  required final StatefulNavigationShell navigationShell,

  /// Ordered top-level tab configurations.
  required final List<NavigationTabConfig<TTab>> tabs,

  /// Optional route-name callback used by analytics when tabs are selected.
  final ValueChanged<String>? onTabRouteSelected,
  super.key,
}) extends StatefulWidget {
  @override
  State<NavigationShell<TTab>> createState() => _NavigationShellState<TTab>();
}

class _NavigationShellState<TTab extends Object>
    extends State<NavigationShell<TTab>> {
  static const double _mediumWidthBreakpoint = 600;
  static const double _drawerWidthBreakpoint = 1200;
  static const double _expandedSideNavigationWidth = 304;
  static const double _collapsedSideNavigationWidth = 72;

  final TabReselectController<TTab> _tabReselectController =
      TabReselectController<TTab>();
  bool _isSideNavigationCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return TabReselectScope<TTab>(
      controller: _tabReselectController,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useRail = constraints.maxWidth >= _mediumWidthBreakpoint;
          final useDrawer = constraints.maxWidth >= _drawerWidthBreakpoint;
          final useCupertinoNavigation =
              Theme.of(context).platform == TargetPlatform.iOS;
          final useCupertinoTabBar = useCupertinoNavigation && !useRail;
          final content = _NavigationContentTheme(
            useSideNavigation: useRail,
            useDrawer: useDrawer && !useCupertinoNavigation,
            child: widget.navigationShell,
          );

          return Scaffold(
            body: Row(
              children: [
                if (useRail && useCupertinoNavigation)
                  SizedBox(
                    width: _sideNavigationWidth,
                    child: _CupertinoSideNavigation<TTab>(
                      isCollapsed: _isSideNavigationCollapsed,
                      selectedIndex: widget.navigationShell.currentIndex,
                      tabs: widget.tabs,
                      onDestinationSelected: _onDestinationSelected,
                      onToggleCollapsed: _toggleSideNavigation,
                    ),
                  )
                else if (useDrawer)
                  SizedBox(
                    width: _sideNavigationWidth,
                    child: _MaterialSideNavigation<TTab>(
                      isCollapsed: _isSideNavigationCollapsed,
                      selectedIndex: widget.navigationShell.currentIndex,
                      tabs: widget.tabs,
                      onDestinationSelected: _onDestinationSelected,
                      onToggleCollapsed: _toggleSideNavigation,
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
                : useCupertinoTabBar
                ? CupertinoTabBar(
                    currentIndex: widget.navigationShell.currentIndex,
                    onTap: _onDestinationSelected,
                    items: widget.tabs
                        .map(
                          (tab) => BottomNavigationBarItem(
                            icon: Icon(tab.icon),
                            label: tab.labelBuilder(context),
                          ),
                        )
                        .toList(growable: false),
                  )
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

  double get _sideNavigationWidth {
    return _isSideNavigationCollapsed
        ? _collapsedSideNavigationWidth
        : _expandedSideNavigationWidth;
  }

  void _toggleSideNavigation() {
    setState(() {
      _isSideNavigationCollapsed = !_isSideNavigationCollapsed;
    });
  }

  Future<void> _onDestinationSelected(int index) async {
    final tabConfig = widget.tabs[index];

    if (index != widget.navigationShell.currentIndex) {
      widget.onTabRouteSelected?.call(tabConfig.routeName);
      widget.navigationShell.goBranch(index);
      return;
    }

    final currentPath = GoRouterState.of(context).uri.path;

    if (currentPath != tabConfig.rootPath) {
      widget.onTabRouteSelected?.call(tabConfig.routeName);
      final canReset = await _tabReselectController.requestBranchReset(
        tabConfig.tab,
      );
      if (!mounted || !canReset) {
        return;
      }
      widget.navigationShell.goBranch(index, initialLocation: true);
      return;
    }

    _tabReselectController.handle(tabConfig.tab);
  }
}

class const _MaterialSideNavigation<TTab extends Object>({
  required final bool isCollapsed,
  required final int selectedIndex,
  required final List<NavigationTabConfig<TTab>> tabs,
  required final ValueChanged<int> onDestinationSelected,
  required final VoidCallback onToggleCollapsed,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (isCollapsed) {
      return NavigationRail(
        labelType: NavigationRailLabelType.none,
        leading: IconButton(
          tooltip: _sideNavigationToggleTooltip,
          icon: const Icon(Icons.menu_open),
          onPressed: onToggleCollapsed,
        ),
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: tabs
            .map(
              (tab) => NavigationRailDestination(
                icon: Icon(tab.icon),
                label: Text(tab.labelBuilder(context)),
              ),
            )
            .toList(growable: false),
      );
    }

    return NavigationDrawer(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      children: [
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: IconButton(
            tooltip: _sideNavigationToggleTooltip,
            icon: const Icon(Icons.menu_open),
            onPressed: onToggleCollapsed,
          ),
        ),
        ...tabs.map(
          (tab) => NavigationDrawerDestination(
            icon: Icon(tab.icon),
            label: Text(tab.labelBuilder(context)),
          ),
        ),
      ],
    );
  }
}

class const _CupertinoSideNavigation<TTab extends Object>({
  required final bool isCollapsed,
  required final int selectedIndex,
  required final List<NavigationTabConfig<TTab>> tabs,
  required final ValueChanged<int> onDestinationSelected,
  required final VoidCallback onToggleCollapsed,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final backgroundColor = CupertinoDynamicColor.resolve(
      CupertinoColors.systemGroupedBackground,
      context,
    );
    final dividerColor = CupertinoDynamicColor.resolve(
      CupertinoColors.separator,
      context,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(right: BorderSide(color: dividerColor, width: 0)),
      ),
      child: SafeArea(
        right: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          children: [
            Align(
              alignment: isCollapsed
                  ? AlignmentDirectional.center
                  : AlignmentDirectional.centerEnd,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size.square(44),
                onPressed: onToggleCollapsed,
                child: Tooltip(
                  message: _sideNavigationToggleTooltip,
                  child: Icon(
                    isCollapsed
                        ? CupertinoIcons.sidebar_left
                        : CupertinoIcons.sidebar_left,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            for (final indexedTab in tabs.indexed) ...[
              if (isCollapsed)
                _CollapsedCupertinoSideNavigationItem(
                  isSelected: indexedTab.$1 == selectedIndex,
                  icon: indexedTab.$2.icon,
                  label: indexedTab.$2.labelBuilder(context),
                  onTap: () => onDestinationSelected(indexedTab.$1),
                )
              else
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: indexedTab.$1 == selectedIndex
                        ? theme.primaryColor.withAlpha(31)
                        : null,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CupertinoListTile(
                    leading: Icon(
                      indexedTab.$2.icon,
                      color: indexedTab.$1 == selectedIndex
                          ? theme.primaryColor
                          : CupertinoColors.secondaryLabel.resolveFrom(context),
                    ),
                    title: Text(
                      indexedTab.$2.labelBuilder(context),
                      style: TextStyle(
                        color: indexedTab.$1 == selectedIndex
                            ? theme.primaryColor
                            : CupertinoColors.label.resolveFrom(context),
                      ),
                    ),
                    trailing: indexedTab.$1 == selectedIndex
                        ? Icon(
                            CupertinoIcons.check_mark,
                            color: theme.primaryColor,
                          )
                        : null,
                    onTap: () => onDestinationSelected(indexedTab.$1),
                  ),
                ),
              const SizedBox(height: 4),
            ],
          ],
        ),
      ),
    );
  }
}

class const _CollapsedCupertinoSideNavigationItem({
  required final bool isSelected,
  required final IconData icon,
  required final String label,
  required final VoidCallback onTap,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return Tooltip(
      message: label,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: const Size.square(48),
        onPressed: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isSelected ? theme.primaryColor.withAlpha(31) : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: SizedBox.square(
            dimension: 48,
            child: Icon(
              icon,
              color: isSelected
                  ? theme.primaryColor
                  : CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ),
        ),
      ),
    );
  }
}

class const _NavigationContentTheme({
  required final bool useSideNavigation,
  required final bool useDrawer,
  required final Widget child,
}) extends StatelessWidget {
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
