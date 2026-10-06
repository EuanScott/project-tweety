import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'app_design_platform.dart';
import 'app_list_section.dart';
import 'app_picker_field.dart';

/// A settings row that shows the selected option and opens a list to change
/// it.
///
/// Cupertino platforms show the selected label on the trailing side with a
/// chevron, and push a page with a checkmark list. Material platforms show
/// the selected label under the title with no chevron, and open a dialog with
/// a radio list. Choosing an option calls [onChanged] and closes the list.
///
/// The list is pushed on the nearest navigator, not through the app router.
class const AppSelectionRow<T>({
  required final String title,
  required final T value,
  required final List<AppPickerOption<T>> options,
  required final ValueChanged<T> onChanged,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final selectedLabel = _selectedIndex == null
        ? null
        : Text(options[_selectedIndex!].label);

    if (AppDesignPlatform.of(context).isCupertino) {
      return CupertinoListTile(
        title: Text(title),
        additionalInfo: selectedLabel,
        trailing: const CupertinoListTileChevron(),
        onTap: () => _showCupertinoList(context),
      );
    }

    return ListTile(
      title: Text(title),
      subtitle: selectedLabel,
      onTap: () => _showMaterialDialog(context),
    );
  }

  int? get _selectedIndex {
    final index = options.indexWhere((option) => option.value == value);

    return index == -1 ? null : index;
  }

  Future<void> _showCupertinoList(BuildContext context) async {
    final index = await Navigator.of(context).push<int>(
      CupertinoPageRoute(
        builder: (_) => _CupertinoSelectionPage(
          title: title,
          labels: [for (final option in options) option.label],
          selectedIndex: _selectedIndex,
        ),
      ),
    );

    if (index != null) {
      onChanged(options[index].value);
    }
  }

  Future<void> _showMaterialDialog(BuildContext context) async {
    final index = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        contentPadding: const .symmetric(vertical: 16),
        content: RadioGroup<int>(
          groupValue: _selectedIndex,
          onChanged: (index) => Navigator.of(context).pop(index),
          child: Column(
            mainAxisSize: .min,
            children: [
              for (final (index, option) in options.indexed)
                RadioListTile<int>(
                  value: index,
                  // Lets a tap on the selected option close the dialog too.
                  toggleable: true,
                  title: Text(option.label),
                ),
            ],
          ),
        ),
      ),
    );

    if (index != null) {
      onChanged(options[index].value);
    }
  }
}

/// The pushed iOS list. It pops with the index of the tapped option, so a
/// `null` option value stays distinct from a dismissed page.
class const _CupertinoSelectionPage({
  required final String title,
  required final List<String> labels,
  required final int? selectedIndex,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final checkColour = Theme.of(context).colorScheme.primary;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(title)),
      child: SafeArea(
        child: ListView(
          children: [
            AppListSection(
              children: [
                for (final (index, label) in labels.indexed)
                  CupertinoListTile(
                    title: Text(label),
                    trailing: index == selectedIndex
                        ? Icon(CupertinoIcons.check_mark, color: checkColour)
                        : null,
                    onTap: () => Navigator.of(context).pop(index),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
