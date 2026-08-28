import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'app_design_platform.dart';
import 'app_picker_field.dart';

/// An app-level mutually-exclusive segmented toggle that renders with the
/// active platform design language.
///
/// Reuses [AppPickerOption] for `{value, label}` segments rather than
/// introducing a separate option type.
class const AppSegmentedControl<T extends Object>({
  required final T value,
  required final List<AppPickerOption<T>> segments,
  required final ValueChanged<T> onChanged,
  super.key,
}) extends StatelessWidget {
  this : assert(segments.length > 0, 'segments must not be empty');

  @override
  Widget build(BuildContext context) {
    if (AppDesignPlatform.of(context).isCupertino) {
      return CupertinoSlidingSegmentedControl<T>(
        groupValue: value,
        onValueChanged: (newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        children: {
          for (final segment in segments) segment.value: Text(segment.label),
        },
      );
    }

    return SegmentedButton<T>(
      segments: segments
          .map(
            (segment) => ButtonSegment(
              value: segment.value,
              label: Text(segment.label),
            ),
          )
          .toList(growable: false),
      selected: {value},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
