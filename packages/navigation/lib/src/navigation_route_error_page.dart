import 'package:material_ui/material_ui.dart';

/// Fallback page shown when `go_router` cannot resolve a route.
///
/// The consuming app provides localized text and decides where the primary
/// action should navigate.
class NavigationRouteErrorPage extends StatelessWidget {
  /// Creates a route error page.
  const NavigationRouteErrorPage({
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onActionPressed,
    this.error,
    super.key,
  });

  /// The router error that caused this page to render.
  final Exception? error;

  /// The title shown in the app bar and page body.
  final String title;

  /// The body text explaining the navigation error.
  final String description;

  /// The primary action label.
  final String actionLabel;

  /// Callback invoked by the primary action.
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(description, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: onActionPressed,
                  child: Text(actionLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
