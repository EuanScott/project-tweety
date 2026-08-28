import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

/// Shared no-op callback for showcases demonstrating an enabled widget with
/// nothing real to do when pressed/tapped.
void noop() {}

/// Uniform, minimal control bar shared by every showcase: an optional
/// variant picker and an optional enabled/disabled toggle. No free-text
/// inputs — every showcase's other content is hardcoded dummy data.
class const ShowcaseControls({
  final List<String>? variantOptions,
  final String? variantValue,
  final ValueChanged<String>? onVariantChanged,
  final bool? enabled,
  final ValueChanged<bool>? onEnabledChanged,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (variantOptions == null && enabled == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const .all(16),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        crossAxisAlignment: .center,
        children: [
          if (variantOptions != null && variantValue != null)
            SizedBox(
              width: 200,
              child: AppPickerField<String>(
                label: 'Variant',
                value: variantValue!,
                options: variantOptions!
                    .map(
                      (option) => AppPickerOption(value: option, label: option),
                    )
                    .toList(growable: false),
                onChanged: (value) => onVariantChanged?.call(value),
              ),
            ),
          if (enabled != null)
            Row(
              mainAxisSize: .min,
              children: [
                const Text('Enabled'),
                AppSwitch(value: enabled!, onChanged: onEnabledChanged),
              ],
            ),
        ],
      ),
    );
  }
}
