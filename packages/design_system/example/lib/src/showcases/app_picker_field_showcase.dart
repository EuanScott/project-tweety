import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import '../comparison/comparison_view.dart';
import '../shell/showcase_controls.dart';

enum _Size { small, medium, large }

/// Showcase for [AppPickerField]. Selection is driven by the widget's own
/// tap-to-pick interaction, so there's no separate external control for it.
class const AppPickerFieldShowcase({super.key}) extends StatefulWidget {
  @override
  State<AppPickerFieldShowcase> createState() => _AppPickerFieldShowcaseState();
}

class _AppPickerFieldShowcaseState extends State<AppPickerFieldShowcase> {
  _Size _selected = .medium;

  static const List<AppPickerOption<_Size>> _options = [
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
            contentBuilder: (context) => AppPickerField<_Size>(
              label: 'Size',
              value: _selected,
              options: _options,
              onChanged: (value) => setState(() => _selected = value),
            ),
          ),
        ),
      ],
    );
  }
}
