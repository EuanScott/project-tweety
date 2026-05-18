import 'package:flutter/widgets.dart';

/// Holds root and branch navigator keys for a tabbed router.
class NavigationNavigatorKeys<TTab extends Object> {
  /// Creates root and branch navigator keys for [tabs].
  NavigationNavigatorKeys(Iterable<TTab> tabs)
    : root = GlobalKey<NavigatorState>(debugLabel: 'rootNavigator'),
      _branchKeys = <TTab, GlobalKey<NavigatorState>>{
        for (final tab in tabs)
          tab: GlobalKey<NavigatorState>(
            debugLabel: '${tab.toString()}Navigator',
          ),
      };

  /// Navigator key for routes above the tab shell.
  final GlobalKey<NavigatorState> root;

  final Map<TTab, GlobalKey<NavigatorState>> _branchKeys;

  /// Returns the branch navigator key for [tab].
  GlobalKey<NavigatorState> branchKeyFor(TTab tab) {
    final key = _branchKeys[tab];

    if (key == null) {
      throw ArgumentError.value(tab, 'tab', 'No navigator key exists for tab');
    }

    return key;
  }
}
