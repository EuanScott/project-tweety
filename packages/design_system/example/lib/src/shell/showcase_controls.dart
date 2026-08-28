import 'package:material_ui/material_ui.dart';

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
          if (variantOptions != null)
            DropdownButton<String>(
              value: variantValue,
              items: variantOptions!
                  .map(
                    (option) =>
                        DropdownMenuItem(value: option, child: Text(option)),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value != null) {
                  onVariantChanged?.call(value);
                }
              },
            ),
          if (enabled != null)
            Row(
              mainAxisSize: .min,
              children: [
                const Text('Enabled'),
                Switch(value: enabled!, onChanged: onEnabledChanged),
              ],
            ),
        ],
      ),
    );
  }
}
