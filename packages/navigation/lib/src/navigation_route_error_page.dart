import 'package:material_ui/material_ui.dart';

/// Fallback page shown when `go_router` cannot resolve a route.
///
/// The consuming app provides localized text and decides where the primary
/// action should navigate.
/// Creates a route error page.
class const NavigationRouteErrorPage({
  /// The title shown in the app bar and page body.
  required final String title,

  /// The body text explaining the navigation error.
  required final String description,

  /// The primary action label.
  required final String actionLabel,

  /// Callback invoked by the primary action.
  required final VoidCallback onActionPressed,

  /// The router error that caused this page to render.
  final Exception? error,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const .all(24),
            child: Column(
              mainAxisSize: .min,
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
                  textAlign: .center,
                ),
                const SizedBox(height: 8),
                Text(description, textAlign: .center),
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
