import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'app_design_platform.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.controller,
    required this.label,
    required this.onChanged,
    this.enabled = true,
    this.errorText,
    this.minLines = 1,
    this.maxLines = 1,
    this.textInputAction,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final String? errorText;
  final int? minLines;
  final int? maxLines;
  final TextInputAction? textInputAction;

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

class _CupertinoTextField extends StatelessWidget {
  const _CupertinoTextField({
    required this.controller,
    required this.label,
    required this.onChanged,
    required this.enabled,
    required this.errorText,
    required this.minLines,
    required this.maxLines,
    required this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final String? errorText;
  final int? minLines;
  final int? maxLines;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final errorText = this.errorText;
    final theme = CupertinoTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
