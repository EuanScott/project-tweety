import 'package:material_ui/material_ui.dart';

/// An app-level pull-to-refresh wrapper.
///
/// Feature code should use this instead of directly constructing
/// [RefreshIndicator] so refresh presentation can stay centralized.
/// Creates an adaptive pull-to-refresh wrapper around [child].
class const AppRefreshIndicator({
  /// Callback invoked when the user triggers pull-to-refresh.
  required final Future<void> Function() onRefresh,

  /// The scrollable content that can be refreshed.
  required final Widget child,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(onRefresh: onRefresh, child: child);
  }
}
