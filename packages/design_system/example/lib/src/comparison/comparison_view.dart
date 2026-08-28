import 'package:material_ui/material_ui.dart';

import 'comparison_pane.dart';

/// Renders [contentBuilder] simultaneously under the iOS and Android design
/// languages, restyled by [brightness].
class const ComparisonView({
  required final Brightness brightness,
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
            brightness: brightness,
            contentBuilder: contentBuilder,
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: ComparisonPane(
            label: 'Android',
            platform: .android,
            brightness: brightness,
            contentBuilder: contentBuilder,
          ),
        ),
      ],
    );
  }
}
