import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import '../comparison/comparison_view.dart';
import '../shell/showcase_controls.dart';

/// Showcase for [AppLoadingIndicator]. It takes no parameters, so there's
/// nothing to control.
class const AppLoadingIndicatorShowcase({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        const ShowcaseControls(),
        Expanded(
          child: ComparisonView(
            contentBuilder: (context) => const AppLoadingIndicator(),
          ),
        ),
      ],
    );
  }
}
