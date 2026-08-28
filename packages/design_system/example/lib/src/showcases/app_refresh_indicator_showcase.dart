import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import '../comparison/comparison_view.dart';
import '../shell/showcase_controls.dart';

/// Showcase for [AppRefreshIndicator], wrapping a dummy scrollable list so
/// pull-to-refresh has something to demonstrate against.
class const AppRefreshIndicatorShowcase({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        const ShowcaseControls(),
        Expanded(
          child: ComparisonView(
            contentBuilder: (context) => AppRefreshIndicator(
              onRefresh: () => Future<void>.delayed(const Duration(seconds: 1)),
              child: ListView(
                children: [
                  for (var index = 1; index <= 6; index++)
                    ListTile(title: Text('Item $index')),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
