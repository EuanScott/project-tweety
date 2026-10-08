import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'app_design_platform.dart';

/// An app-level button that renders with the active platform design language.
///
/// Feature code should use this widget when it needs a standard action button
/// and should not care whether the current surface is Material or Cupertino.
class AppButton extends StatelessWidget {
  /// Creates the primary action button.
  const new primary({
    required this.onPressed,
    required this.child,
    this.fillsWidth = true,
    super.key,
  }) : _variant = .primary;

  /// Creates the secondary action button.
  const new secondary({
    required this.onPressed,
    required this.child,
    this.fillsWidth = true,
    super.key,
  }) : _variant = .secondary;

  /// Creates the low-emphasis text action button.
  const new text({
    required this.onPressed,
    required this.child,
    this.fillsWidth = true,
    super.key,
  }) : _variant = .text;

  /// Creates an action button for irreversible or destructive operations.
  const new destructive({
    required this.onPressed,
    required this.child,
    this.fillsWidth = true,
    super.key,
  }) : _variant = .destructive;

  /// A 6% primary tint: the strongest that keeps primary text at 4.5:1 on it
  /// in every theme colour.
  static const int _secondaryTintAlpha = 15;

  /// Keeps the theme's 48-point tap height while sizing to the label.
  static const ButtonStyle _labelWidthStyle = ButtonStyle(
    minimumSize: WidgetStatePropertyAll(Size(0, 48)),
  );

  final VoidCallback? onPressed;
  final Widget child;

  /// Whether the button fills the width it is given, as the theme sets.
  ///
  /// Turn it off for a button beside other content in a row. Cupertino
  /// buttons always size to their label, so only Material reads it.
  final bool fillsWidth;
  final _AppButtonVariant _variant;

  @override
  Widget build(BuildContext context) {
    if (AppDesignPlatform.of(context).isCupertino) {
      return _buildCupertino(context);
    }

    return _buildMaterial(context);
  }

  Widget _buildMaterial(BuildContext context) {
    final style = fillsWidth ? null : _labelWidthStyle;

    switch (_variant) {
      case .primary:
        return ElevatedButton(onPressed: onPressed, style: style, child: child);
      case .secondary:
        return OutlinedButton(onPressed: onPressed, style: style, child: child);
      case .text:
        return TextButton(onPressed: onPressed, style: style, child: child);
      case .destructive:
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ).merge(style),
          child: child,
        );
    }
  }

  Widget _buildCupertino(BuildContext context) {
    final isPrimary = _variant == .primary;
    final isSecondary = _variant == .secondary;
    final isDestructive = _variant == .destructive;
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
      padding: const .symmetric(horizontal: 16, vertical: 12),
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
        color: primaryColor.withAlpha(_secondaryTintAlpha),
        borderRadius: .circular(12),
      ),
      child: button,
    );
  }
}

enum _AppButtonVariant { primary, secondary, text, destructive }
