import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'app_design_platform.dart';
import 'app_list_section.dart';

/// A labelled text field that adapts between iOS and Android forms.
///
/// Cupertino renders a form row: the label as an upper-case section header
/// over the field in an inset grouped card, as in iOS Settings. Material
/// renders a standard text field with a floating label. Both own their outer
/// spacing, so a form stacks fields with no padding of its own.
class const AppTextField({
  required final TextEditingController controller,
  required final String label,
  required final ValueChanged<String> onChanged,
  final bool enabled = true,
  final String? errorText,
  final int? minLines = 1,
  final int? maxLines = 1,
  final TextInputAction? textInputAction,

  /// Which letters the keyboard offers in upper case. Sentences suits the
  /// free text most fields hold; pass none for codes, emails and the like.
  final TextCapitalization textCapitalization = TextCapitalization.sentences,
  super.key,
}) extends StatelessWidget {
  static const EdgeInsetsGeometry _materialPadding = .symmetric(
    horizontal: 16,
    vertical: 8,
  );

  @override
  Widget build(BuildContext context) {
    if (AppDesignPlatform.of(context).isCupertino) {
      return _CupertinoTextField(
        controller: controller,
        label: label,
        onChanged: onChanged,
        enabled: enabled,
        errorText: errorText,
        minLines: minLines,
        maxLines: maxLines,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
      );
    }

    return Padding(
      padding: _materialPadding,
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        minLines: minLines,
        maxLines: maxLines,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label, errorText: errorText),
      ),
    );
  }
}

class const _CupertinoTextField({
  required final TextEditingController controller,
  required final String label,
  required final ValueChanged<String> onChanged,
  required final bool enabled,
  required final String? errorText,
  required final int? minLines,
  required final int? maxLines,
  required final TextInputAction? textInputAction,
  required final TextCapitalization textCapitalization,
}) extends StatelessWidget {
  static const EdgeInsetsGeometry _rowPadding = .fromSTEB(20, 12, 14, 12);

  @override
  Widget build(BuildContext context) {
    final errorText = this.errorText;
    final theme = CupertinoTheme.of(context);

    return AppListSection(
      header: label,
      children: [
        CupertinoTextField(
          controller: controller,
          enabled: enabled,
          minLines: minLines,
          maxLines: maxLines,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          onChanged: onChanged,
          decoration: null,
          padding: _rowPadding,
        ),
        if (errorText != null)
          Padding(
            padding: _rowPadding,
            child: Text(
              errorText,
              style: theme.textTheme.textStyle.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
