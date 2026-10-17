// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Project Tweety';

  @override
  String get homeTab => 'Home';

  @override
  String get dynamicFormTab => 'Form';

  @override
  String get logsTab => 'Logs';

  @override
  String get logEntryDetailsTitle => 'Entry details';

  @override
  String get logEntryDetailsIdLabel => 'ID';

  @override
  String get logEntryDetailsEmptyTitle => 'Select an entry';

  @override
  String get logEntryDetailsEmptyDescription =>
      'Choose an entry from the list to see details.';

  @override
  String get logEntryDetailsMissingTitle => 'Entry not found';

  @override
  String get logEntryDetailsMissingDescription =>
      'This entry is not available.';

  @override
  String get logEntryDetailsLoadFailedTitle => 'Unable to load entry';

  @override
  String get logEntryDetailsLoadFailedDescription =>
      'Try opening the entry again.';

  @override
  String get logEntryCreateTitle => 'New entry';

  @override
  String get logEntryCreateAction => 'Create entry';

  @override
  String get logEntryCreateTitleLabel => 'Title';

  @override
  String get logEntryCreateDescriptionLabel => 'Description';

  @override
  String get logEntryCreateTitleRequired => 'Enter a title.';

  @override
  String get logEntryCreateDescriptionRequired => 'Enter a description.';

  @override
  String get logEntryCreateEmptyTitle => 'No entries yet';

  @override
  String get logEntryCreateEmptyDescription =>
      'Create your first entry to get started.';

  @override
  String get logEntryCreateFailed => 'Unable to save entry. Try again.';

  @override
  String get logEntryEditTitle => 'Edit entry';

  @override
  String get logEntryEditAction => 'Edit entry';

  @override
  String get logEntryEditSaveAction => 'Save changes';

  @override
  String get logEntryEditCancelAction => 'Cancel';

  @override
  String get logEntryEditFailed => 'Unable to update entry. Try again.';

  @override
  String get logEntryEditNotFound => 'Entry no longer exists.';

  @override
  String get logEntryEditReturnToLogsAction => 'Return to logs';

  @override
  String get logEntryDiscardConfirmationTitle => 'Discard changes?';

  @override
  String get logEntryDiscardConfirmationDescription =>
      'Your unsaved changes will be lost.';

  @override
  String get logEntryDiscardCancelAction => 'Keep editing';

  @override
  String get logEntryDiscardAction => 'Discard changes';

  @override
  String get logEntryDeleteAction => 'Delete entry';

  @override
  String get logEntryDeleteRetryAction => 'Retry deletion';

  @override
  String get logEntryDeleteCancelAction => 'Keep entry';

  @override
  String get logEntryDeleteConfirmationTitle => 'Delete entry?';

  @override
  String get logEntryDeleteConfirmationDescription =>
      'This entry will be removed from your logs.';

  @override
  String get logEntryDeleteFailed => 'Unable to delete entry. Try again.';

  @override
  String get settingsTab => 'Settings';

  @override
  String get navigationErrorTitle => 'Page not found';

  @override
  String get navigationErrorDescription =>
      'The page you were looking for is not available.';

  @override
  String get navigationErrorGoHome => 'Go home';

  @override
  String get accessDeniedTitle => 'Access denied';

  @override
  String get accessDeniedDescription => 'You do not have access to this page.';

  @override
  String get accessDeniedGoHome => 'Go home';

  @override
  String get settingsAppPreferencesTitle => 'Personalisation';

  @override
  String get settingsAppPreferencesSubtitle =>
      'Theme, language, and text settings';

  @override
  String get appPreferencesTitle => 'Personalisation';

  @override
  String get appPreferencesIntro =>
      'Change the appearance, theme colour, language and text of the app.';

  @override
  String get appPreferencesThemeLabel => 'Appearance';

  @override
  String get appPreferencesThemeSystem => 'System';

  @override
  String get appPreferencesThemeLight => 'Light';

  @override
  String get appPreferencesThemeDark => 'Dark';

  @override
  String get appPreferencesThemeColourLabel => 'Theme colour';

  @override
  String get themeColourFjord => 'Fjord';

  @override
  String get themeColourFjordDescription =>
      'Teal water and plum dusk from Norway\'s deep sea inlets. Calm and clear, like a still morning on the water.';

  @override
  String get themeColourFynbos => 'Fynbos';

  @override
  String get themeColourFynbosDescription =>
      'Olive green and protea pink from the wild shrubland of the Cape. Fresh, green and full of bloom.';

  @override
  String get themeColourKalahari => 'Kalahari';

  @override
  String get themeColourKalahariDescription =>
      'Red ochre dunes under a wide blue desert sky. Warm and earthy, from the great sands of southern Africa.';

  @override
  String get themeColourLyng => 'Lyng';

  @override
  String get themeColourLyngDescription =>
      'Purple heather and cloudberry gold from the Norwegian hills. Soft and quiet, like late summer on the moor.';

  @override
  String get themeColourWhin => 'Whin';

  @override
  String get themeColourWhinDescription =>
      'Gorse gold from the Scottish hills, where the whin flowers almost all year. Sunny and bright, even on a grey day.';

  @override
  String get themeColourDouro => 'Douro';

  @override
  String get themeColourDouroDescription =>
      'Port-wine red and blue tiles from Portugal\'s Douro Valley. Rich and warm, like evening light on the vineyard terraces.';

  @override
  String get themeColourCuillin => 'Cuillin';

  @override
  String get themeColourCuillinDescription =>
      'Black rock and grey mist from the mountains of Skye. Quiet and focused, with a touch of sea-loch blue.';

  @override
  String get appPreferencesLanguageLabel => 'Language';

  @override
  String get appPreferencesLanguageSystem => 'System default';

  @override
  String appPreferencesLanguageFollowingSystem(Object language) {
    return 'Following device setting: $language.';
  }

  @override
  String get appPreferencesDirectionFooter =>
      'Text direction follows the language.';

  @override
  String get appPreferencesTextDisplayHeader => 'Text and display';

  @override
  String get appPreferencesTextSizeRow => 'Text size and bold text';

  @override
  String get appPreferencesTextSizeFooter =>
      'Change font size and bold text in your device settings.';

  @override
  String get appPreferencesSystemTextOpenFailed =>
      'Unable to open settings on this device.';

  @override
  String get signInCompactSubtitle =>
      'Sign in to keep your logs and back them up.';

  @override
  String get signInSceneSubtitle =>
      'Your logs, on this device and backed up when you choose.';

  @override
  String get signInSplitTitle => 'Sign in';

  @override
  String get signInSplitSubtitle => 'Use your Google Account to continue.';

  @override
  String get signInGoogleButton => 'Sign in with Google';

  @override
  String get signInGoogleButtonInProgress => 'Signing in…';

  @override
  String get signInErrorTitle => 'Sign-in didn\'t work';

  @override
  String get signInErrorNetwork => 'Check your connection and try again.';

  @override
  String get signInErrorOther => 'Something went wrong. Please try again.';

  @override
  String get signInFootnote =>
      'Your logs stay on this device until you sync them.';

  @override
  String get signInSceneDescription =>
      'Dash, a blue bird in a green hoodie, wading in teal water and holding up a card.';

  @override
  String get accountTitle => 'Account';

  @override
  String get accountAvatarLabel => 'Account';

  @override
  String get accountPhotoLabel => 'Profile photo';

  @override
  String get accountNoPhotoLabel => 'No profile photo';

  @override
  String get accountFallbackHeading => 'Your Account';

  @override
  String get accountNoPhone => 'No phone number on this Account';

  @override
  String get accountEmailLabel => 'Email';

  @override
  String get accountEmailVerified => 'Verified';

  @override
  String get accountEmailNotVerified => 'Not verified';

  @override
  String get accountNoEmail => 'No email on this Account';

  @override
  String get accountSignedInWithLabel => 'Signed in with';

  @override
  String get accountProviderGoogle => 'Google';

  @override
  String get accountSignOut => 'Sign out';

  @override
  String get accountSigningOut => 'Signing out…';

  @override
  String get accountSignOutFootnote =>
      'Your logs stay on this device when you sign out.';

  @override
  String get accountSignOutConfirmTitle => 'Sign out?';

  @override
  String get accountSignOutConfirmBody =>
      'Your logs stay on this device. Sign in again to see them.';

  @override
  String get accountSignOutConfirmCancel => 'Cancel';

  @override
  String get accountSignOutConfirmAction => 'Sign out';

  @override
  String get logsSyncUpToDateTitle => 'All logs synced';

  @override
  String logsSyncLastSynced(DateTime time) {
    final intl.DateFormat timeDateFormat = intl.DateFormat.jm(localeName);
    final String timeString = timeDateFormat.format(time);

    return 'Last sync at $timeString';
  }

  @override
  String logsSyncPendingTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes on this device only',
      one: '1 change on this device only',
    );
    return '$_temp0';
  }

  @override
  String logsSyncPendingSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sync to save them to your Account',
      one: 'Sync to save it to your Account',
    );
    return '$_temp0';
  }

  @override
  String get logsSyncSyncingTitle => 'Syncing…';

  @override
  String logsSyncSyncingSubtitle(int savedCount, int changeCount) {
    return '$savedCount of $changeCount changes saved';
  }

  @override
  String get logsSyncSyncedTitle => 'Synced just now';

  @override
  String logsSyncSyncedSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes saved to your Account',
      one: '1 change saved to your Account',
    );
    return '$_temp0';
  }

  @override
  String logsSyncPartialTitle(int savedCount, int changeCount) {
    return '$savedCount of $changeCount changes synced';
  }

  @override
  String logsSyncPartialSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes will try again next sync',
      one: '1 change will try again next sync',
    );
    return '$_temp0';
  }

  @override
  String get logsSyncOfflineTitle => 'You\'re offline';

  @override
  String logsSyncOfflineSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count changes are safe on this device. Sync when you\'re back online.',
      one: '1 change is safe on this device. Sync when you\'re back online.',
    );
    return '$_temp0';
  }

  @override
  String get logsSyncFailedTitle => 'Couldn\'t sync';

  @override
  String logsSyncFailedSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes are safe on this device. Try again later.',
      one: '1 change is safe on this device. Try again later.',
    );
    return '$_temp0';
  }

  @override
  String get logsSyncAlreadyUpToDateTitle => 'Already up to date';

  @override
  String get logsSyncAlreadyUpToDateSubtitle => 'Nothing to sync';

  @override
  String logsSyncDownloadingTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Getting $count entries from your Account…',
      one: 'Getting 1 entry from your Account…',
    );
    return '$_temp0';
  }

  @override
  String get logsSyncDownloadingSubtitle => 'You can keep working';

  @override
  String logsSyncDownloadedTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries added from your Account',
      one: '1 entry added from your Account',
    );
    return '$_temp0';
  }

  @override
  String logsSyncDownloadedSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'They were made on another device',
      one: 'It was made on another device',
    );
    return '$_temp0';
  }

  @override
  String get commonRetryAction => 'Retry';

  @override
  String get logsSyncAction => 'Sync';

  @override
  String get logsLoadFailedMessage => 'Unable to load logs right now.';

  @override
  String get logsSyncInProgressAction => 'Syncing';

  @override
  String get logsUnsyncedCreated => 'New';

  @override
  String get logsUnsyncedUpdated => 'Edited';
}
