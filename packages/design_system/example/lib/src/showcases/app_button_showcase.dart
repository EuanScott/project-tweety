import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import '../comparison/comparison_view.dart';
import '../shell/showcase_controls.dart';

enum _ButtonVariant { primary, secondary, text, destructive }

/// Showcase for [AppButton], demonstrating every variant and its
/// enabled/disabled state in both comparison panes.
class const AppButtonShowcase({
  required final Brightness brightness,
  super.key,
}) extends StatefulWidget {
  @override
  State<AppButtonShowcase> createState() => _AppButtonShowcaseState();
}

class _AppButtonShowcaseState extends State<AppButtonShowcase> {
  _ButtonVariant _variant = .primary;
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        ShowcaseControls(
          variantOptions: _ButtonVariant.values
              .map((variant) => variant.name)
              .toList(growable: false),
          variantValue: _variant.name,
          onVariantChanged: (value) =>
              setState(() => _variant = _ButtonVariant.values.byName(value)),
          enabled: _enabled,
          onEnabledChanged: (value) => setState(() => _enabled = value),
        ),
        Expanded(
          child: ComparisonView(
            brightness: widget.brightness,
            contentBuilder: (context) => _buildButton(),
          ),
        ),
      ],
    );
  }

  Widget _buildButton() {
    final onPressed = _enabled ? noop : null;
    const label = Text('Continue');

    switch (_variant) {
      case .primary:
        return AppButton.primary(onPressed: onPressed, child: label);
      case .secondary:
        return AppButton.secondary(onPressed: onPressed, child: label);
      case .text:
        return AppButton.text(onPressed: onPressed, child: label);
      case .destructive:
        return AppButton.destructive(onPressed: onPressed, child: label);
    }
  }
}
