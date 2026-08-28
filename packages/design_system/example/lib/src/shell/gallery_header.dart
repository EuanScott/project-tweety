import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

/// Title bar above a showcase, with the light/dark toggle.
class const GalleryHeader({
  required final String title,
  required final Brightness brightness,
  required final ValueChanged<Brightness> onBrightnessChanged,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          AppSegmentedControl<Brightness>(
            value: brightness,
            segments: const [
              AppPickerOption(value: .light, label: 'Light'),
              AppPickerOption(value: .dark, label: 'Dark'),
            ],
            onChanged: onBrightnessChanged,
          ),
        ],
      ),
    );
  }
}
