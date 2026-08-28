import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import '../comparison/comparison_view.dart';
import '../shell/showcase_controls.dart';

/// Showcase for [AppListTile], demonstrating its enabled/disabled state
/// (`onTap` is nullable on the widget) in both comparison panes.
class const AppListTileShowcase({super.key}) extends StatefulWidget {
  @override
  State<AppListTileShowcase> createState() => _AppListTileShowcaseState();
}

class _AppListTileShowcaseState extends State<AppListTileShowcase> {
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        ShowcaseControls(
          enabled: _enabled,
          onEnabledChanged: (value) => setState(() => _enabled = value),
        ),
        Expanded(
          child: ComparisonView(
            contentBuilder: (context) => AppListTile(
              title: const Text('Notifications'),
              subtitle: const Text('Get notified about activity'),
              onTap: _enabled ? noop : null,
            ),
          ),
        ),
      ],
    );
  }
}
