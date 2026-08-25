import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'app_design_platform.dart';

/// An app-level icon button that renders with the active platform design
/// language.
///
/// Feature code should use this widget when it needs a compact, unlabelled
/// action control (e.g. a close affordance) and should not care whether the
/// current surface is Material or Cupertino.
class const AppIconButton({
  /// The icon to show.
  required final IconData icon,

  /// Called when the button is tapped.
  required final VoidCallback onPressed,

  /// Accessibility label announced by screen readers, and shown as a
  /// tooltip on Material.
  final String? semanticLabel,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (AppDesignPlatform.of(context).isCupertino) {
      return _buildCupertino(context);
    }

    return _buildMaterial(context);
  }

  Widget _buildMaterial(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      tooltip: semanticLabel,
    );
  }

  Widget _buildCupertino(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Icon(icon, semanticLabel: semanticLabel),
    );
  }
}
