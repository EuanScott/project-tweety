/// @docImport 'package:design_system/design_system.dart';
/// @docImport 'package:project_tweety/presentation/widgets/page_scaffold.widget.dart';
library;

import 'package:material_ui/material_ui.dart';

/// A typed, cross-platform trailing app-bar action.
///
/// [ToolBarAction] is the shared interface consumed by both platform
/// adapters inside [PageScaffold]: the Material branch renders it as an
/// [AppIconButton] in the [AppBar], and the Cupertino branch renders the
/// same value as an [AppIconButton] in its navigation bar. Construct one
/// [ToolBarAction] and both platforms render and behave identically —
/// callers never branch on platform themselves.
class const ToolBarAction({
  /// The icon shown for this action, on both platforms.
  required final IconData icon,

  /// The callback invoked when the action is pressed, on both platforms.
  required final VoidCallback onPressed,

  /// {@template tool_bar_action_tooltip}
  /// Announced as the Material tooltip on long-press/hover, and as the
  /// Cupertino accessibility semantic label. Defaults to an empty string,
  /// which mutes both.
  /// {@endtemplate}
  final String tooltip = '',
});
