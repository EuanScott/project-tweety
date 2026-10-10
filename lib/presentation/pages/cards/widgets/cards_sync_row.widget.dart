part of '../cards.page.dart';

/// Where sync stands, always shown above the Cards, with the action that
/// starts a sync.
///
/// Only the words, icon and button change between states; the row itself
/// never appears or disappears. State colours go on the icon alone, so the
/// words keep the theme's text colours in every state.
class const _CardsSyncRow() extends StatelessWidget {
  static const double _indicatorSize = 24;
  static const EdgeInsets _padding = .fromLTRB(16, 12, 12, 12);

  /// Below this width the button moves under the words, so a narrow pane or
  /// large text never squeezes the words to nothing.
  static const double _buttonBesideMinWidth = 280;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final sync = context.select((CardsBloc bloc) => bloc.state.sync);
    final (:icon, :iconColor, :title, :subtitle) = _describe(sync, l10n, theme);

    return Card(
      margin: _CardsList._cardMargin,
      child: Padding(
        padding: _padding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final status = Row(
              spacing: 12,
              children: [
                if (sync.isBusy)
                  const SizedBox.square(
                    dimension: _indicatorSize,
                    child: AppLoadingIndicator(),
                  )
                else
                  Icon(icon, color: iconColor),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(title, style: theme.textTheme.titleSmall),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );

            if (constraints.maxWidth < _buttonBesideMinWidth) {
              return Column(
                crossAxisAlignment: .end,
                children: [
                  status,
                  _SyncButton(sync: sync),
                ],
              );
            }

            return Row(
              spacing: 12,
              children: [
                Expanded(child: status),
                _SyncButton(sync: sync),
              ],
            );
          },
        ),
      ),
    );
  }

  ({IconData icon, Color iconColor, String title, String? subtitle}) _describe(
    CardsSync sync,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final primary = theme.colorScheme.primary;
    final success = DesignStatusColors.of(theme).success;
    final error = theme.colorScheme.error;

    return switch (sync) {
      CardsSyncUpToDate(:final lastSyncedAt) => (
        icon: Icons.cloud_done_outlined,
        iconColor: primary,
        title: l10n.cardsSyncUpToDateTitle,
        subtitle: lastSyncedAt == null
            ? null
            : l10n.cardsSyncLastSynced(lastSyncedAt),
      ),
      CardsSyncPending(:final changeCount) => (
        icon: Icons.cloud_upload_outlined,
        iconColor: primary,
        title: l10n.cardsSyncPendingTitle(changeCount),
        subtitle: l10n.cardsSyncPendingSubtitle(changeCount),
      ),
      CardsSyncSyncing(:final savedCount, :final changeCount) => (
        icon: Icons.cloud_upload_outlined,
        iconColor: primary,
        title: l10n.cardsSyncSyncingTitle,
        subtitle: l10n.cardsSyncSyncingSubtitle(savedCount, changeCount),
      ),
      CardsSyncSynced(:final changeCount) => (
        icon: Icons.cloud_done_outlined,
        iconColor: success,
        title: l10n.cardsSyncSyncedTitle,
        subtitle: l10n.cardsSyncSyncedSubtitle(changeCount),
      ),
      // Partial success keeps the neutral colour: nothing is lost, and the
      // next sync retries the rest.
      CardsSyncPartial(:final savedCount, :final changeCount) => (
        icon: Icons.cloud_upload_outlined,
        iconColor: primary,
        title: l10n.cardsSyncPartialTitle(savedCount, changeCount),
        subtitle: l10n.cardsSyncPartialSubtitle(changeCount - savedCount),
      ),
      CardsSyncOffline(:final changeCount) => (
        icon: Icons.cloud_off_outlined,
        iconColor: error,
        title: l10n.cardsSyncOfflineTitle,
        subtitle: l10n.cardsSyncOfflineSubtitle(changeCount),
      ),
      CardsSyncFailed(:final changeCount) => (
        icon: Icons.error_outline,
        iconColor: error,
        title: l10n.cardsSyncFailedTitle,
        subtitle: l10n.cardsSyncFailedSubtitle(changeCount),
      ),
      CardsSyncAlreadyUpToDate() => (
        icon: Icons.cloud_done_outlined,
        iconColor: success,
        title: l10n.cardsSyncAlreadyUpToDateTitle,
        subtitle: l10n.cardsSyncAlreadyUpToDateSubtitle,
      ),
      CardsSyncDownloading(:final cardCount) => (
        icon: Icons.cloud_download_outlined,
        iconColor: primary,
        title: l10n.cardsSyncDownloadingTitle(cardCount),
        subtitle: l10n.cardsSyncDownloadingSubtitle,
      ),
      CardsSyncDownloaded(:final cardCount) => (
        icon: Icons.cloud_download_outlined,
        iconColor: success,
        title: l10n.cardsSyncDownloadedTitle(cardCount),
        subtitle: l10n.cardsSyncDownloadedSubtitle(cardCount),
      ),
    };
  }
}

class const _SyncButton({required final CardsSync sync})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onPressed = sync.isBusy
        ? null
        : () => context.read<CardsBloc>().add(const CardsSyncRequested());

    return switch (sync) {
      CardsSyncSyncing() => AppButton.text(
        onPressed: null,
        fillsWidth: false,
        child: Text(l10n.cardsSyncInProgressAction),
      ),
      CardsSyncOffline() || CardsSyncFailed() => AppButton.primary(
        onPressed: onPressed,
        fillsWidth: false,
        child: Text(l10n.cardsSyncRetryAction),
      ),
      CardsSyncPending() || CardsSyncPartial() => AppButton.primary(
        onPressed: onPressed,
        fillsWidth: false,
        child: Text(l10n.cardsSyncAction),
      ),
      _ => AppButton.text(
        onPressed: onPressed,
        fillsWidth: false,
        child: Text(l10n.cardsSyncAction),
      ),
    };
  }
}
