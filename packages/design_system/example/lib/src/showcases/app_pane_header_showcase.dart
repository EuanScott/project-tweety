import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import '../comparison/comparison_view.dart';
import '../shell/showcase_controls.dart';

/// Showcase for [AppPaneHeader] over a pane's content. It takes only a
/// title, so there's nothing to control.
class const AppPaneHeaderShowcase({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        const ShowcaseControls(),
        Expanded(
          child: ComparisonView(
            contentBuilder: (context) => const Column(
              mainAxisSize: .min,
              crossAxisAlignment: .stretch,
              children: [
                AppPaneHeader(title: 'Edit entry'),
                Padding(
                  padding: .all(16),
                  child: Text('Pane content'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
