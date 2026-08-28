import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'app_design_platform.dart';

/// An app-level on/off switch that renders with the active platform design
/// language.
class const AppSwitch({
  required final bool value,
  required final ValueChanged<bool>? onChanged,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (AppDesignPlatform.of(context).isCupertino) {
      return CupertinoSwitch(value: value, onChanged: onChanged);
    }

    return Switch(value: value, onChanged: onChanged);
  }
}
