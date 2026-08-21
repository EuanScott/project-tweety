import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'app_design_platform.dart';

class const AppTextField({
  required final TextEditingController controller,
  required final String label,
  required final ValueChanged<String> onChanged,
  final bool enabled = true,
  final String? errorText,
  final int? minLines = 1,
  final int? maxLines = 1,
  final TextInputAction? textInputAction,
  super.key,
}) extends StatelessWidget {
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
      );
    }

    return TextFormField(
      controller: controller,
      enabled: enabled,
      minLines: minLines,
      maxLines: maxLines,
      textInputAction: textInputAction,
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label, errorText: errorText),
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
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final errorText = this.errorText;
    final theme = CupertinoTheme.of(context);

    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(label, style: theme.textTheme.textStyle),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: controller,
          enabled: enabled,
          minLines: minLines,
          maxLines: maxLines,
          textInputAction: textInputAction,
          onChanged: onChanged,
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText,
            style: theme.textTheme.textStyle.copyWith(
              color: CupertinoColors.systemRed.resolveFrom(context),
            ),
          ),
        ],
      ],
    );
  }
}
