import 'package:material_ui/material_ui.dart';

import 'comparison_pane.dart';

/// Renders [contentBuilder] simultaneously under the iOS and Android design
/// languages.
///
/// Always previews against a light surface — alternate (dark) preview
/// theming is deferred; see the component gallery backlog.
class const ComparisonView({
  required final WidgetBuilder contentBuilder,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ComparisonPane(
            label: 'iOS',
            platform: .iOS,
            brightness: .light,
            contentBuilder: contentBuilder,
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: ComparisonPane(
            label: 'Android',
            platform: .android,
            brightness: .light,
            contentBuilder: contentBuilder,
          ),
        ),
      ],
    );
  }
}
