import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'app_design_platform.dart';

/// A selectable value shown by [AppPickerField].
class AppPickerOption<T> {
  /// Creates a picker option with a stable [value] and display [label].
  const AppPickerOption({required this.value, required this.label});

  /// The value emitted when this option is selected.
  final T value;

  /// The user-facing label for this option.
  final String label;
}

/// An app-level picker field that adapts to the active design language.
///
/// Material platforms render a dropdown form field. Cupertino platforms render
/// a tappable settings-style row that opens a wheel picker sheet.
class AppPickerField<T> extends StatelessWidget {
  /// Creates an adaptive picker field.
  const AppPickerField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.helperText,
    super.key,
  }) : assert(options.length > 0, 'options must not be empty');

  final String label;
  final T value;
  final List<AppPickerOption<T>> options;
  final ValueChanged<T> onChanged;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    if (AppDesignPlatform.of(context).isCupertino) {
      return CupertinoListTile(
        title: Text(label),
        subtitle: helperText == null ? null : Text(helperText!),
        additionalInfo: Text(_labelFor(value)),
        trailing: const CupertinoListTileChevron(),
        onTap: () => _showCupertinoPicker(context),
      );
    }

    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label, helperText: helperText),
      items: options
          .map(
            (option) => DropdownMenuItem<T>(
              value: option.value,
              child: Text(option.label),
            ),
          )
          .toList(growable: false),
      onChanged: (value) => onChanged(value as T),
    );
  }

  Future<void> _showCupertinoPicker(BuildContext context) async {
    final initialIndex = _selectedIndex;
    var selectedIndex = initialIndex;

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return Container(
          height: 320,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: CupertinoButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onChanged(options[selectedIndex].value);
                    },
                    child: const Text('Done'),
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 36,
                    scrollController: FixedExtentScrollController(
                      initialItem: initialIndex,
                    ),
                    onSelectedItemChanged: (index) {
                      selectedIndex = index;
                    },
                    children: options
                        .map((option) => Center(child: Text(option.label)))
                        .toList(growable: false),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int get _selectedIndex {
    final selectedIndex = options.indexWhere((option) => option.value == value);

    if (selectedIndex == -1) {
      return 0;
    }

    return selectedIndex;
  }

  String _labelFor(T value) {
    final selectedIndex = _selectedIndex;

    if (options[selectedIndex].value == value) {
      return options[selectedIndex].label;
    }

    return options.first.label;
  }
}
