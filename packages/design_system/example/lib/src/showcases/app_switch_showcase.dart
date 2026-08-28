import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import '../comparison/comparison_view.dart';
import '../shell/showcase_controls.dart';

/// Showcase for [AppSwitch], demonstrating its on/off state and its
/// enabled/disabled state (`onChanged` is nullable on the widget).
class const AppSwitchShowcase({super.key}) extends StatefulWidget {
  @override
  State<AppSwitchShowcase> createState() => _AppSwitchShowcaseState();
}

class _AppSwitchShowcaseState extends State<AppSwitchShowcase> {
  bool _value = true;
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
            contentBuilder: (context) => AppSwitch(
              value: _value,
              onChanged: _enabled
                  ? (value) => setState(() => _value = value)
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
