import 'package:material_ui/material_ui.dart';

/// An app-level floating action button for a page's primary action.
///
/// This is a Material control. Cupertino has no floating action button: on
/// iOS, put the same action in the navigation bar instead.
class AppFloatingActionButton extends StatelessWidget {
  /// Shows [icon] in a floating action button.
  const new({
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    super.key,
  });

  final IconData icon;

  /// Called when the button is tapped.
  final VoidCallback onPressed;

  /// Accessibility label announced by screen readers and shown as a tooltip.
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: semanticLabel,
      child: Icon(icon),
    );
  }
}
