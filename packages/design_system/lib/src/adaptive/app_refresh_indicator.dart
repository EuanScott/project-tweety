import 'package:flutter/material.dart';

/// An app-level pull-to-refresh wrapper.
///
/// Feature code should use this instead of directly constructing
/// [RefreshIndicator] so refresh presentation can stay centralized.
class AppRefreshIndicator extends StatelessWidget {
  /// Creates an adaptive pull-to-refresh wrapper around [child].
  const AppRefreshIndicator({
    required this.onRefresh,
    required this.child,
    super.key,
  });

  /// Callback invoked when the user triggers pull-to-refresh.
  final Future<void> Function() onRefresh;

  /// The scrollable content that can be refreshed.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(onRefresh: onRefresh, child: child);
  }
}
