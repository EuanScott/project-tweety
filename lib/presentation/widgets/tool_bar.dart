import 'package:material_ui/material_ui.dart';

/// A small wrapper around [AppBar] that standardises title, leading, and action
/// configuration across the app.
///
/// This widget intentionally relies on Flutter's default leading behaviour, so
/// navigation pages keep the standard platform back affordance without each
/// caller manually configuring it.
///
/// Example:
/// ```dart
/// Scaffold(
///   appBar: const ToolBar(
///     title: 'Home',
///   ),
///   body: const SizedBox.shrink(),
/// )
/// ```
///
/// Pass [trailingAction] when the current page needs a single trailing action.
///
/// Example:
/// ```dart
/// Scaffold(
///   appBar: ToolBar(
///     title: 'Cards',
///     trailingAction: ToolBarAction(
///       icon: Icons.add,
///       onPressed: _handleAddPressed,
///     ),
///   ),
///   body: const SizedBox.shrink(),
/// )
/// ```
/// Creates a typed trailing app-bar action.
///
/// The [icon] and [onPressed] callback are required. [tooltip] is optional
/// and defaults to an empty string when omitted.
class const ToolBarAction({
  /// The icon shown for this action.
  required final IconData icon,

  /// The callback invoked when the action is pressed.
  required final VoidCallback onPressed,

  /// The tooltip announced when the action is focused or long-pressed.
  final String tooltip = '',
});

/// Creates a standard app bar with an optional trailing action.
///
/// The leading area is not manually overridden, so Flutter can infer the
/// appropriate platform navigation affordance automatically.
class const ToolBar({
  /// The text shown in the centre of the app bar.
  required final String title,

  /// The optional typed trailing action rendered in the app bar.
  final ToolBarAction? trailingAction,
  super.key,
}) extends StatelessWidget implements PreferredSizeWidget {
  /// Returns the standard Material app bar height.
  @override
  Size get preferredSize => const .fromHeight(kToolbarHeight);

  @override
  AppBar build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: trailingAction != null
          ? [
              IconButton(
                onPressed: trailingAction!.onPressed,
                tooltip: trailingAction!.tooltip,
                icon: Icon(trailingAction!.icon),
              ),
            ]
          : const [],
    );
  }
}
