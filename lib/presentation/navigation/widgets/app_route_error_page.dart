import 'package:flutter/material.dart';
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/navigation/navigation_extensions.dart';

/// Fallback page shown when `go_router` cannot resolve a route.
///
/// The page gives users a localized explanation and a direct action back to the
/// home tab.
class AppRouteErrorPage extends StatelessWidget {
  /// Creates a route error page for [error].
  const AppRouteErrorPage({this.error, super.key});

  /// The router error that caused this page to render.
  final Exception? error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navigationErrorTitle)),
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
                  l10n.navigationErrorTitle,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.navigationErrorDescription,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: context.goHome,
                  child: Text(l10n.navigationErrorGoHome),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
