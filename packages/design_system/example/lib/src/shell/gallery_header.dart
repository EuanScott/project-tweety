import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

/// Title bar above a showcase, with the light/dark toggle.
///
/// Uses the real [AppBar] widget so its background, foreground, and title
/// styling come straight from `appBarTheme` — the same theme the real
/// app's AppBar renders with — instead of hand-copied color logic.
class const GalleryHeader({
  required final String title,
  required final Brightness brightness,
  required final ValueChanged<Brightness> onBrightnessChanged,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        Padding(
          padding: const .only(right: 16),
          child: AppSegmentedControl<Brightness>(
            value: brightness,
            segments: const [
              AppPickerOption(value: .light, label: 'Light'),
              AppPickerOption(value: .dark, label: 'Dark'),
            ],
            onChanged: onBrightnessChanged,
          ),
        ),
      ],
    );
  }
}
