import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import '../comparison/comparison_view.dart';
import '../shell/showcase_controls.dart';

/// Showcase for [AppIconButton]. `onPressed` is non-nullable on the widget
/// itself, so there's no enabled/disabled state to demonstrate.
class const AppIconButtonShowcase({
  required final Brightness brightness,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        const ShowcaseControls(),
        Expanded(
          child: ComparisonView(
            brightness: brightness,
            contentBuilder: (context) => const AppIconButton(
              icon: Icons.close,
              onPressed: noop,
              semanticLabel: 'Close',
            ),
          ),
        ),
      ],
    );
  }
}
