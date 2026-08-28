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
          SegmentedButton<Brightness>(
            segments: const [
              ButtonSegment(value: .light, label: Text('Light')),
              ButtonSegment(value: .dark, label: Text('Dark')),
            ],
            selected: {brightness},
            onSelectionChanged: (selection) =>
                onBrightnessChanged(selection.first),
          ),
        ],
      ),
    );
  }
}
