part of '../route_error.page.dart';

/// The heading and the line under it: centred below the scene on phones,
/// start-aligned beside it on tablets. The heading is the page title.
class _RouteErrorMessage extends StatelessWidget {
  const new({required this.isSplit});

  final bool isSplit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final align = isSplit ? TextAlign.start : TextAlign.center;

    return Column(
      crossAxisAlignment: isSplit ? .start : .center,
      spacing: 8,
      children: [
        Semantics(
          header: true,
          namesRoute: true,
          child: Text(
            l10n.navigationErrorTitle,
            textAlign: align,
            style: theme.textTheme.safeHeadlineSmall.copyWith(
              fontSize: isSplit ? 32 : 28,
              height: 1.18,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Text(
          l10n.navigationErrorDescription,
          textAlign: align,
          style: theme.textTheme.safeBodyLarge.copyWith(
            fontSize: 16,
            height: 1.45,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

/// The page's way out. It fills the column and is at least 48 px high on both
/// platforms; Cupertino buttons otherwise size to their label.
class _RouteErrorGoHome extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: double.infinity,
        minHeight: 48,
      ),
      child: AppButton.primary(
        onPressed: context.leaveNotFound,
        child: Text(AppLocalizations.of(context)!.navigationErrorGoHome),
      ),
    );
  }
}
