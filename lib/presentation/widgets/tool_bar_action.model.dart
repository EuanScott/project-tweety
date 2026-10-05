/// @docImport 'package:design_system/design_system.dart';
/// @docImport 'package:project_tweety/presentation/widgets/page_scaffold.widget.dart';
library;

import 'package:material_ui/material_ui.dart';

/// A typed, cross-platform app-bar action.
///
/// [ToolBarAction] is the shared interface consumed by both platform
/// adapters inside [PageScaffold]: each branch renders it as an
/// [AppIconButton] in its app bar or navigation bar. Construct one
/// [ToolBarAction] and both platforms render and behave identically —
/// callers never branch on platform themselves.
///
/// Not `freezed` (ADR-0004): it holds a callback and a widget, which have no
/// value equality, so a generated `==` and `copyWith` would add nothing.
sealed class ToolBarAction {
  /// An action that shows [icon].
  const factory({
    required IconData icon,
    required VoidCallback onPressed,
    String tooltip,
  }) = ToolBarIconAction;

  /// An action that shows [avatar], for example a profile picture, in the
  /// same touch target as an icon.
  const factory avatar({
    required Widget avatar,
    required VoidCallback onPressed,
    String tooltip,
  }) = ToolBarAvatarAction;

  const new _({required this.onPressed, required this.tooltip});

  /// The callback invoked when the action is pressed, on both platforms.
  final VoidCallback onPressed;

  /// {@template tool_bar_action_tooltip}
  /// Announced as the Material tooltip on long-press/hover, and as the
  /// Cupertino accessibility semantic label. Defaults to an empty string,
  /// which mutes both.
  /// {@endtemplate}
  final String tooltip;
}

final class ToolBarIconAction extends ToolBarAction {
  const new({
    required this.icon,
    required super.onPressed,
    super.tooltip = '',
  }) : super._();

  /// The icon shown for this action, on both platforms.
  final IconData icon;
}

final class ToolBarAvatarAction extends ToolBarAction {
  const new({
    required this.avatar,
    required super.onPressed,
    super.tooltip = '',
  }) : super._();

  /// The widget shown for this action, on both platforms. Its own semantics
  /// are replaced by [tooltip].
  final Widget avatar;
}
