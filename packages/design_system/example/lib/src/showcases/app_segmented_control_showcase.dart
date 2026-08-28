import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import '../comparison/comparison_view.dart';
import '../shell/showcase_controls.dart';

enum _Size { small, medium, large }

/// Showcase for [AppSegmentedControl]. Selection is driven by the widget's
/// own tap interaction, so there's no separate external control for it —
/// same as [AppPickerField]'s showcase.
class const AppSegmentedControlShowcase({super.key}) extends StatefulWidget {
  @override
  State<AppSegmentedControlShowcase> createState() =>
      _AppSegmentedControlShowcaseState();
}

class _AppSegmentedControlShowcaseState
    extends State<AppSegmentedControlShowcase> {
  _Size _selected = .medium;

  static const List<AppPickerOption<_Size>> _segments = [
    AppPickerOption(value: _Size.small, label: 'Small'),
    AppPickerOption(value: _Size.medium, label: 'Medium'),
    AppPickerOption(value: _Size.large, label: 'Large'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        const ShowcaseControls(),
        Expanded(
          child: ComparisonView(
            contentBuilder: (context) => AppSegmentedControl<_Size>(
              value: _selected,
              segments: _segments,
              onChanged: (value) => setState(() => _selected = value),
            ),
          ),
        ),
      ],
    );
  }
}
