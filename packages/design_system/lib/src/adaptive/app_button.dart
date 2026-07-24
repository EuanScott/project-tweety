import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_design_platform.dart';

/// An app-level button that renders with the active platform design language.
///
/// Feature code should use this widget when it needs a standard action button
/// and should not care whether the current surface is Material or Cupertino.
class AppButton extends StatelessWidget {
  /// Creates the primary action button.
  const AppButton.primary({
    required this.onPressed,
    required this.child,
    super.key,
  }) : _variant = _AppButtonVariant.primary;

  /// Creates the secondary action button.
  const AppButton.secondary({
    required this.onPressed,
    required this.child,
    super.key,
  }) : _variant = _AppButtonVariant.secondary;

  /// Creates the low-emphasis text action button.
  const AppButton.text({
    required this.onPressed,
    required this.child,
    super.key,
  }) : _variant = _AppButtonVariant.text;

  /// Creates an action button for irreversible or destructive operations.
  const AppButton.destructive({
    required this.onPressed,
    required this.child,
    super.key,
  }) : _variant = _AppButtonVariant.destructive;

  final VoidCallback? onPressed;
  final Widget child;
  final _AppButtonVariant _variant;

  @override
  Widget build(BuildContext context) {
    if (AppDesignPlatform.of(context).isCupertino) {
      return _buildCupertino(context);
    }

    return _buildMaterial(context);
  }

  Widget _buildMaterial(BuildContext context) {
    switch (_variant) {
      case _AppButtonVariant.primary:
        return ElevatedButton(onPressed: onPressed, child: child);
      case _AppButtonVariant.secondary:
        return OutlinedButton(onPressed: onPressed, child: child);
      case _AppButtonVariant.text:
        return TextButton(onPressed: onPressed, child: child);
      case _AppButtonVariant.destructive:
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          child: child,
        );
    }
  }

  Widget _buildCupertino(BuildContext context) {
    final isPrimary = _variant == _AppButtonVariant.primary;
    final isSecondary = _variant == _AppButtonVariant.secondary;
    final isDestructive = _variant == _AppButtonVariant.destructive;
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = CupertinoTheme.of(context).primaryColor;
    final foregroundColor = isPrimary
        ? colorScheme.onPrimary
        : isDestructive
        ? CupertinoColors.white
        : primaryColor;
    final button = CupertinoButton(
      onPressed: onPressed,
      color: isPrimary
          ? primaryColor
          : isDestructive
          ? CupertinoColors.systemRed.resolveFrom(context)
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: IconTheme(
        data: IconThemeData(color: foregroundColor),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: foregroundColor),
          child: child,
        ),
      ),
    );

    if (!isSecondary) {
      return button;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: primaryColor.withAlpha(31),
        borderRadius: BorderRadius.circular(12),
      ),
      child: button,
    );
  }
}

enum _AppButtonVariant { primary, secondary, text, destructive }
