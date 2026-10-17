part of '../logs.page.dart';

/// Where sync stands, always shown above the log entries, with the action that
/// starts a sync.
///
/// Only the words, icon and button change between states; the row itself
/// never appears or disappears. State colours go on the icon alone, so the
/// words keep the theme's text colours in every state.
class const _LogsSyncRow() extends StatelessWidget {
  static const double _indicatorSize = 24;
  static const EdgeInsets _padding = .fromLTRB(16, 12, 12, 12);

  /// Below this width the button moves under the words, so a narrow pane or
  /// large text never squeezes the words to nothing.
  static const double _buttonBesideMinWidth = 280;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final sync = context.select((LogsBloc bloc) => bloc.state.sync);
    final (:icon, :iconColor, :title, :subtitle) = _describe(sync, l10n, theme);

    return Card(
      margin: _LogsList._logEntryMargin,
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
    LogsSync sync,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final primary = theme.colorScheme.primary;
    final success = DesignStatusColors.of(theme).success;
    final error = theme.colorScheme.error;

    return switch (sync) {
      LogsSyncUpToDate(:final lastSyncedAt) => (
        icon: Icons.cloud_done_outlined,
        iconColor: primary,
        title: l10n.logsSyncUpToDateTitle,
        subtitle: lastSyncedAt == null
            ? null
            : l10n.logsSyncLastSynced(lastSyncedAt),
      ),
      LogsSyncPending(:final changeCount) => (
        icon: Icons.cloud_upload_outlined,
        iconColor: primary,
        title: l10n.logsSyncPendingTitle(changeCount),
        subtitle: l10n.logsSyncPendingSubtitle(changeCount),
      ),
      LogsSyncSyncing(:final savedCount, :final changeCount) => (
        icon: Icons.cloud_upload_outlined,
        iconColor: primary,
        title: l10n.logsSyncSyncingTitle,
        subtitle: l10n.logsSyncSyncingSubtitle(savedCount, changeCount),
      ),
      LogsSyncSynced(:final changeCount) => (
        icon: Icons.cloud_done_outlined,
        iconColor: success,
        title: l10n.logsSyncSyncedTitle,
        subtitle: l10n.logsSyncSyncedSubtitle(changeCount),
      ),
      // Partial success keeps the neutral colour: nothing is lost, and the
      // next sync retries the rest.
      LogsSyncPartial(:final savedCount, :final changeCount) => (
        icon: Icons.cloud_upload_outlined,
        iconColor: primary,
        title: l10n.logsSyncPartialTitle(savedCount, changeCount),
        subtitle: l10n.logsSyncPartialSubtitle(changeCount - savedCount),
      ),
      LogsSyncOffline(:final changeCount) => (
        icon: Icons.cloud_off_outlined,
        iconColor: error,
        title: l10n.logsSyncOfflineTitle,
        subtitle: l10n.logsSyncOfflineSubtitle(changeCount),
      ),
      LogsSyncFailed(:final changeCount) => (
        icon: Icons.error_outline,
        iconColor: error,
        title: l10n.logsSyncFailedTitle,
        subtitle: l10n.logsSyncFailedSubtitle(changeCount),
      ),
      LogsSyncAlreadyUpToDate() => (
        icon: Icons.cloud_done_outlined,
        iconColor: success,
        title: l10n.logsSyncAlreadyUpToDateTitle,
        subtitle: l10n.logsSyncAlreadyUpToDateSubtitle,
      ),
      LogsSyncDownloading(:final logEntryCount) => (
        icon: Icons.cloud_download_outlined,
        iconColor: primary,
        title: l10n.logsSyncDownloadingTitle(logEntryCount),
        subtitle: l10n.logsSyncDownloadingSubtitle,
      ),
      LogsSyncDownloaded(:final logEntryCount) => (
        icon: Icons.cloud_download_outlined,
        iconColor: success,
        title: l10n.logsSyncDownloadedTitle(logEntryCount),
        subtitle: l10n.logsSyncDownloadedSubtitle(logEntryCount),
      ),
    };
  }
}

class const _SyncButton({required final LogsSync sync})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onPressed = sync.isBusy
        ? null
        : () => context.read<LogsBloc>().add(const LogsSyncRequested());

    return switch (sync) {
      LogsSyncSyncing() => AppButton.text(
        onPressed: null,
        fillsWidth: false,
        child: Text(l10n.logsSyncInProgressAction),
      ),
      LogsSyncOffline() || LogsSyncFailed() => AppButton.primary(
        onPressed: onPressed,
        fillsWidth: false,
        child: Text(l10n.logsSyncRetryAction),
      ),
      LogsSyncPending() || LogsSyncPartial() => AppButton.primary(
        onPressed: onPressed,
        fillsWidth: false,
        child: Text(l10n.logsSyncAction),
      ),
      _ => AppButton.text(
        onPressed: onPressed,
        fillsWidth: false,
        child: Text(l10n.logsSyncAction),
      ),
    };
  }
}
