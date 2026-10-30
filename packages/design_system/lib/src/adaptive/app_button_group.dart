import 'package:material_ui/material_ui.dart';

import 'pane_layout.dart';

/// A stack of [children] buttons, such as a primary action over a secondary
/// one, that fill the width they are given.
///
/// Inside a [PaneLayoutScope] that shows two panes, the group stops at
/// [maxSplitPaneWidth] and stays centred, so a wide pane does not stretch the
/// buttons across the screen. Anywhere else it fills the width.
class const AppButtonGroup({required final List<Widget> children, super.key})
    extends StatelessWidget {
  /// The widest a button group grows in a pane of a split layout.
  static const double maxSplitPaneWidth = 480;
  static const double _spacing = 12;

  @override
  Widget build(BuildContext context) {
    final group = Column(
      mainAxisSize: .min,
      crossAxisAlignment: .stretch,
      spacing: _spacing,
      children: children,
    );

    if (PaneLayoutScope.maybeOf(context) != PaneLayoutMode.split) {
      return group;
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxSplitPaneWidth),
        child: group,
      ),
    );
  }
}
