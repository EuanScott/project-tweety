import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Route branch definition for a top-level navigation tab.
///
/// The consuming app supplies the actual [routes], including page builders and
/// nested routes. The shared router factory wraps those routes in a
/// [StatefulShellBranch].
class NavigationBranch<TTab extends Object> {
  /// Creates a branch for [tab].
  const NavigationBranch({
    required this.tab,
    required this.routes,
    this.restorationScopeId,
    this.observers,
    this.navigatorKey,
  });

  /// The app-owned tab identifier this branch belongs to.
  final TTab tab;

  /// The app-owned route tree for this branch.
  final List<RouteBase> routes;

  /// Optional restoration scope for the branch navigator.
  final String? restorationScopeId;

  /// Optional observers for this branch navigator.
  final List<NavigatorObserver>? observers;

  /// Optional navigator key for this branch.
  final GlobalKey<NavigatorState>? navigatorKey;
}
