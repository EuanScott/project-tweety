import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'app_design_platform.dart';

/// An app-level icon button that renders with the active platform design
/// language.
///
/// Feature code should use this widget when it needs a compact, unlabelled
/// action control (e.g. a close affordance) and should not care whether the
/// current surface is Material or Cupertino.
class AppIconButton extends StatelessWidget {
  /// Shows [icon].
  const new({
    required IconData this.icon,
    required this.onPressed,
    this.semanticLabel,
    super.key,
  }) : child = null;

  /// Shows [child], for example an avatar, in the same touch target as an
  /// icon: 48 px on Material and 44 px on Cupertino. [semanticLabel] replaces
  /// any semantics inside [child].
  const new custom({
    required Widget this.child,
    required this.onPressed,
    this.semanticLabel,
    super.key,
  }) : icon = null;

  final IconData? icon;
  final Widget? child;

  /// Called when the button is tapped.
  final VoidCallback onPressed;

  /// Accessibility label announced by screen readers, and shown as a
  /// tooltip on Material.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    if (AppDesignPlatform.of(context).isCupertino) {
      return _buildCupertino(context);
    }

    return _buildMaterial(context);
  }

  Widget _buildMaterial(BuildContext context) {
    final child = this.child;

    return IconButton(
      icon: child == null ? Icon(icon) : ExcludeSemantics(child: child),
      onPressed: onPressed,
      tooltip: semanticLabel,
    );
  }

  Widget _buildCupertino(BuildContext context) {
    final child = this.child;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: child == null
          ? Icon(icon, semanticLabel: semanticLabel)
          : Semantics(
              label: semanticLabel,
              excludeSemantics: true,
              child: child,
            ),
    );
  }
}
