import 'package:material_ui/material_ui.dart';

import 'app_floating_action_button.dart';

/// A content pane with the page's primary action floating at its bottom end.
///
/// The pane floats any [action] it receives, on every platform. The caller
/// decides where the action belongs: on Cupertino a page puts it in the
/// navigation bar instead, and gives this pane no action.
///
/// Scrolling content inside the pane reads [bottomClearanceOf] and adds it to
/// its bottom padding, so its last item can scroll clear of the action. A
/// hidden action keeps its space, so hiding it does not move the content.
///
/// The action floats inside the pane, not in a [Scaffold] slot, so it does
/// not move above a [SnackBar].
class AppPrimaryActionPane extends StatelessWidget {
  /// Shows [child] with [action] placed for the active platform.
  const new({
    required this.child,
    this.action,
    this.isActionVisible = true,
    super.key,
  });

  /// The pane content.
  final Widget child;

  /// The primary action. Leave it null to show [child] alone, for example on
  /// Cupertino, where the action belongs in the navigation bar.
  final AppFloatingActionButton? action;

  /// Whether [action] is shown. A hidden action still reserves its space.
  final bool isActionVisible;

  /// Material's regular floating action button size.
  static const double _actionSize = 56;
  static const double _actionMargin = 16;

  /// The bottom space that content inside the nearest pane must reserve so
  /// the action does not cover it. It is zero when the pane has no action.
  static double bottomClearanceOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<_AppPrimaryActionScope>()
            ?.bottomClearance ??
        0;
  }

  @override
  Widget build(BuildContext context) {
    final action = this.action;
    if (action == null) {
      return child;
    }

    return Stack(
      children: [
        _AppPrimaryActionScope(
          bottomClearance: _actionSize + _actionMargin,
          child: child,
        ),
        if (isActionVisible)
          PositionedDirectional(
            end: _actionMargin,
            bottom: _actionMargin,
            child: action,
          ),
      ],
    );
  }
}

class _AppPrimaryActionScope extends InheritedWidget {
  const new({required this.bottomClearance, required super.child});

  final double bottomClearance;

  @override
  bool updateShouldNotify(_AppPrimaryActionScope oldWidget) =>
      bottomClearance != oldWidget.bottomClearance;
}
