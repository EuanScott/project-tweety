import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import '../comparison/comparison_view.dart';
import '../shell/showcase_controls.dart';

/// Showcase for [AppTextField], demonstrating its enabled/disabled state.
/// Both panes share one [TextEditingController] so typing in either pane
/// stays visibly in sync with the other.
class const AppTextFieldShowcase({super.key}) extends StatefulWidget {
  @override
  State<AppTextFieldShowcase> createState() => _AppTextFieldShowcaseState();
}

class _AppTextFieldShowcaseState extends State<AppTextFieldShowcase> {
  final _controller = TextEditingController(text: 'Sample text');
  bool _enabled = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
            contentBuilder: (context) => AppTextField(
              controller: _controller,
              label: 'Label',
              enabled: _enabled,
              onChanged: (_) {},
            ),
          ),
        ),
      ],
    );
  }
}
