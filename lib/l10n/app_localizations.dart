import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_he.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('he'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Project Tweety'**
  String get appTitle;

  /// Label for home tab
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// Label for dynamic form tab
  ///
  /// In en, this message translates to:
  /// **'Form'**
  String get dynamicFormTab;

  /// Label for logs tab
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logsTab;

  /// Title for the log entry details page
  ///
  /// In en, this message translates to:
  /// **'Entry details'**
  String get logEntryDetailsTitle;

  /// Label for the log entry id shown on the log entry details page
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get logEntryDetailsIdLabel;

  /// Title shown in the wide logs detail pane before a log entry is selected
  ///
  /// In en, this message translates to:
  /// **'Select an entry'**
  String get logEntryDetailsEmptyTitle;

  /// Description shown in the wide logs detail pane before a log entry is selected
  ///
  /// In en, this message translates to:
  /// **'Choose an entry from the list to see details.'**
  String get logEntryDetailsEmptyDescription;

  /// Title shown when a log entry details route references an unknown log entry id
  ///
  /// In en, this message translates to:
  /// **'Entry not found'**
  String get logEntryDetailsMissingTitle;

  /// Description shown when a log entry details route references an unknown log entry id
  ///
  /// In en, this message translates to:
  /// **'This entry is not available.'**
  String get logEntryDetailsMissingDescription;

  /// Title shown when log entry details fail to load
  ///
  /// In en, this message translates to:
  /// **'Unable to load entry'**
  String get logEntryDetailsLoadFailedTitle;

  /// Description shown when log entry details fail to load
  ///
  /// In en, this message translates to:
  /// **'Try opening the entry again.'**
  String get logEntryDetailsLoadFailedDescription;

  /// No description provided for @logEntryCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New entry'**
  String get logEntryCreateTitle;

  /// No description provided for @logEntryCreateAction.
  ///
  /// In en, this message translates to:
  /// **'Create entry'**
  String get logEntryCreateAction;

  /// No description provided for @logEntryCreateTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get logEntryCreateTitleLabel;

  /// No description provided for @logEntryCreateDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get logEntryCreateDescriptionLabel;

  /// No description provided for @logEntryCreateTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a title.'**
  String get logEntryCreateTitleRequired;

  /// No description provided for @logEntryCreateDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a description.'**
  String get logEntryCreateDescriptionRequired;

  /// No description provided for @logEntryCreateEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get logEntryCreateEmptyTitle;

  /// No description provided for @logEntryCreateEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Create your first entry to get started.'**
  String get logEntryCreateEmptyDescription;

  /// No description provided for @logEntryCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to save entry. Try again.'**
  String get logEntryCreateFailed;

  /// No description provided for @logEntryEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get logEntryEditTitle;

  /// No description provided for @logEntryEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get logEntryEditAction;

  /// No description provided for @logEntryEditSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get logEntryEditSaveAction;

  /// No description provided for @logEntryEditCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get logEntryEditCancelAction;

  /// No description provided for @logEntryEditFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to update entry. Try again.'**
  String get logEntryEditFailed;

  /// No description provided for @logEntryEditNotFound.
  ///
  /// In en, this message translates to:
  /// **'Entry no longer exists.'**
  String get logEntryEditNotFound;

  /// No description provided for @logEntryEditReturnToLogsAction.
  ///
  /// In en, this message translates to:
  /// **'Return to logs'**
  String get logEntryEditReturnToLogsAction;

  /// No description provided for @logEntryDiscardConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get logEntryDiscardConfirmationTitle;

  /// No description provided for @logEntryDiscardConfirmationDescription.
  ///
  /// In en, this message translates to:
  /// **'Your unsaved changes will be lost.'**
  String get logEntryDiscardConfirmationDescription;

  /// No description provided for @logEntryDiscardCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get logEntryDiscardCancelAction;

  /// No description provided for @logEntryDiscardAction.
  ///
  /// In en, this message translates to:
  /// **'Discard changes'**
  String get logEntryDiscardAction;

  /// No description provided for @logEntryDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete entry'**
  String get logEntryDeleteAction;

  /// No description provided for @logEntryDeleteRetryAction.
  ///
  /// In en, this message translates to:
  /// **'Retry deletion'**
  String get logEntryDeleteRetryAction;

  /// No description provided for @logEntryDeleteCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Keep entry'**
  String get logEntryDeleteCancelAction;

  /// No description provided for @logEntryDeleteConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete entry?'**
  String get logEntryDeleteConfirmationTitle;

  /// No description provided for @logEntryDeleteConfirmationDescription.
  ///
  /// In en, this message translates to:
  /// **'This entry will be removed from your logs.'**
  String get logEntryDeleteConfirmationDescription;

  /// No description provided for @logEntryDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete entry. Try again.'**
  String get logEntryDeleteFailed;

  /// Label for settings tab
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// Title shown when navigation cannot resolve a route
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get navigationErrorTitle;

  /// Description shown when navigation cannot resolve a route
  ///
  /// In en, this message translates to:
  /// **'The page you were looking for is not available.'**
  String get navigationErrorDescription;

  /// Button label to return to the home page after a navigation error
  ///
  /// In en, this message translates to:
  /// **'Go home'**
  String get navigationErrorGoHome;

  /// Title shown when a guarded route denies access
  ///
  /// In en, this message translates to:
  /// **'Access denied'**
  String get accessDeniedTitle;

  /// Description shown when a guarded route denies access
  ///
  /// In en, this message translates to:
  /// **'You do not have access to this page.'**
  String get accessDeniedDescription;

  /// Button label to return home from the access denied page
  ///
  /// In en, this message translates to:
  /// **'Go home'**
  String get accessDeniedGoHome;

  /// Title for the Settings row that opens the personalisation page
  ///
  /// In en, this message translates to:
  /// **'Personalisation'**
  String get settingsAppPreferencesTitle;

  /// Subtitle for the Settings row that opens the personalisation page
  ///
  /// In en, this message translates to:
  /// **'Theme, language, and text settings'**
  String get settingsAppPreferencesSubtitle;

  /// Title for the personalisation page
  ///
  /// In en, this message translates to:
  /// **'Personalisation'**
  String get appPreferencesTitle;

  /// One sentence at the top of the personalisation page that says what the page changes
  ///
  /// In en, this message translates to:
  /// **'Change the appearance, theme colour, language and text of the app.'**
  String get appPreferencesIntro;

  /// Header for the appearance section, which holds the theme mode and theme colour
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appPreferencesThemeLabel;

  /// Label for the system theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get appPreferencesThemeSystem;

  /// Label for the light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get appPreferencesThemeLight;

  /// Label for the dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get appPreferencesThemeDark;

  /// Title line above the theme colour swatches
  ///
  /// In en, this message translates to:
  /// **'Theme colour'**
  String get appPreferencesThemeColourLabel;

  /// Name of the Fjord theme colour
  ///
  /// In en, this message translates to:
  /// **'Fjord'**
  String get themeColourFjord;

  /// Description of the Fjord theme colour, shown under the swatches
  ///
  /// In en, this message translates to:
  /// **'Teal water and plum dusk from Norway\'s deep sea inlets. Calm and clear, like a still morning on the water.'**
  String get themeColourFjordDescription;

  /// Name of the Fynbos theme colour
  ///
  /// In en, this message translates to:
  /// **'Fynbos'**
  String get themeColourFynbos;

  /// Description of the Fynbos theme colour, shown under the swatches
  ///
  /// In en, this message translates to:
  /// **'Olive green and protea pink from the wild shrubland of the Cape. Fresh, green and full of bloom.'**
  String get themeColourFynbosDescription;

  /// Name of the Kalahari theme colour
  ///
  /// In en, this message translates to:
  /// **'Kalahari'**
  String get themeColourKalahari;

  /// Description of the Kalahari theme colour, shown under the swatches
  ///
  /// In en, this message translates to:
  /// **'Red ochre dunes under a wide blue desert sky. Warm and earthy, from the great sands of southern Africa.'**
  String get themeColourKalahariDescription;

  /// Name of the Lyng theme colour
  ///
  /// In en, this message translates to:
  /// **'Lyng'**
  String get themeColourLyng;

  /// Description of the Lyng theme colour, shown under the swatches
  ///
  /// In en, this message translates to:
  /// **'Purple heather and cloudberry gold from the Norwegian hills. Soft and quiet, like late summer on the moor.'**
  String get themeColourLyngDescription;

  /// Name of the Whin theme colour
  ///
  /// In en, this message translates to:
  /// **'Whin'**
  String get themeColourWhin;

  /// Description of the Whin theme colour, shown under the swatches
  ///
  /// In en, this message translates to:
  /// **'Gorse gold from the Scottish hills, where the whin flowers almost all year. Sunny and bright, even on a grey day.'**
  String get themeColourWhinDescription;

  /// Name of the Douro theme colour
  ///
  /// In en, this message translates to:
  /// **'Douro'**
  String get themeColourDouro;

  /// Description of the Douro theme colour, shown under the swatches
  ///
  /// In en, this message translates to:
  /// **'Port-wine red and blue tiles from Portugal\'s Douro Valley. Rich and warm, like evening light on the vineyard terraces.'**
  String get themeColourDouroDescription;

  /// Name of the Cuillin theme colour
  ///
  /// In en, this message translates to:
  /// **'Cuillin'**
  String get themeColourCuillin;

  /// Description of the Cuillin theme colour, shown under the swatches
  ///
  /// In en, this message translates to:
  /// **'Black rock and grey mist from the mountains of Skye. Quiet and focused, with a touch of sea-loch blue.'**
  String get themeColourCuillinDescription;

  /// Label for the language selector
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get appPreferencesLanguageLabel;

  /// Label for the system language option
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get appPreferencesLanguageSystem;

  /// Helper text when language follows the system setting
  ///
  /// In en, this message translates to:
  /// **'Following device setting: {language}.'**
  String appPreferencesLanguageFollowingSystem(Object language);

  /// Text under the language section
  ///
  /// In en, this message translates to:
  /// **'Text direction follows the language.'**
  String get appPreferencesDirectionFooter;

  /// Header for the text and display section
  ///
  /// In en, this message translates to:
  /// **'Text and display'**
  String get appPreferencesTextDisplayHeader;

  /// Row that opens the device text size and bold text settings
  ///
  /// In en, this message translates to:
  /// **'Text size and bold text'**
  String get appPreferencesTextSizeRow;

  /// Text under the text and display section
  ///
  /// In en, this message translates to:
  /// **'Change font size and bold text in your device settings.'**
  String get appPreferencesTextSizeFooter;

  /// Error message shown when device settings cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Unable to open settings on this device.'**
  String get appPreferencesSystemTextOpenFailed;

  /// Retry button label for app preferences loading
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get appPreferencesRetry;

  /// Subtitle under the app name on the compact sign-in page
  ///
  /// In en, this message translates to:
  /// **'Sign in to keep your logs and back them up.'**
  String get signInCompactSubtitle;

  /// Subtitle over the illustration on the split sign-in page
  ///
  /// In en, this message translates to:
  /// **'Your logs, on this device and backed up when you choose.'**
  String get signInSceneSubtitle;

  /// Heading above the sign-in button on the split sign-in page
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInSplitTitle;

  /// Subtitle under the heading on the split sign-in page
  ///
  /// In en, this message translates to:
  /// **'Use your Google Account to continue.'**
  String get signInSplitSubtitle;

  /// Label of the Google sign-in button
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInGoogleButton;

  /// Label of the Google sign-in button while a sign-in attempt is in progress
  ///
  /// In en, this message translates to:
  /// **'Signing in…'**
  String get signInGoogleButtonInProgress;

  /// Title of the message shown when a sign-in attempt fails
  ///
  /// In en, this message translates to:
  /// **'Sign-in didn\'t work'**
  String get signInErrorTitle;

  /// Body of the sign-in failure message when the network failed
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get signInErrorNetwork;

  /// Body of the sign-in failure message for any failure other than the network
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get signInErrorOther;

  /// Footnote under the sign-in button
  ///
  /// In en, this message translates to:
  /// **'Your logs stay on this device until you sync them.'**
  String get signInFootnote;

  /// Screen reader description of the sign-in illustration
  ///
  /// In en, this message translates to:
  /// **'Dash, a blue bird in a green hoodie, wading in teal water and holding up a card.'**
  String get signInSceneDescription;

  /// Title of the account modal
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// Screen reader label of the toolbar button that opens the account modal
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountAvatarLabel;

  /// Screen reader label of the profile photo
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get accountPhotoLabel;

  /// Screen reader label of the circle shown when there is no profile photo
  ///
  /// In en, this message translates to:
  /// **'No profile photo'**
  String get accountNoPhotoLabel;

  /// Account modal heading when the Profile has no name and no email
  ///
  /// In en, this message translates to:
  /// **'Your Account'**
  String get accountFallbackHeading;

  /// Shown in place of the phone number when the Profile has none
  ///
  /// In en, this message translates to:
  /// **'No phone number on this Account'**
  String get accountNoPhone;

  /// Label of the email row in the account details
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get accountEmailLabel;

  /// Email row value when the email is verified
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get accountEmailVerified;

  /// Email row value when the email is not verified
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get accountEmailNotVerified;

  /// Email row value when the Profile has no email
  ///
  /// In en, this message translates to:
  /// **'No email on this Account'**
  String get accountNoEmail;

  /// Label of the row that names the sign-in provider
  ///
  /// In en, this message translates to:
  /// **'Signed in with'**
  String get accountSignedInWithLabel;

  /// Name of the Google sign-in provider
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get accountProviderGoogle;

  /// Label of the sign-out button
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get accountSignOut;

  /// Label of the sign-out button while signing out
  ///
  /// In en, this message translates to:
  /// **'Signing out…'**
  String get accountSigningOut;

  /// Footnote under the sign-out button
  ///
  /// In en, this message translates to:
  /// **'Your logs stay on this device when you sign out.'**
  String get accountSignOutFootnote;

  /// Title of the sign-out confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get accountSignOutConfirmTitle;

  /// Body of the sign-out confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Your logs stay on this device. Sign in again to see them.'**
  String get accountSignOutConfirmBody;

  /// Cancel action of the sign-out confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get accountSignOutConfirmCancel;

  /// Confirm action of the sign-out confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get accountSignOutConfirmAction;

  /// Sync row headline when no change waits to sync
  ///
  /// In en, this message translates to:
  /// **'All logs synced'**
  String get logsSyncUpToDateTitle;

  /// Sync row sub-line naming when the last sync finished
  ///
  /// In en, this message translates to:
  /// **'Last sync at {time}'**
  String logsSyncLastSynced(DateTime time);

  /// Sync row headline when changes wait to sync; deletions count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change on this device only} other{{count} changes on this device only}}'**
  String logsSyncPendingTitle(int count);

  /// Sync row sub-line when changes wait to sync
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Sync to save it to your Account} other{Sync to save them to your Account}}'**
  String logsSyncPendingSubtitle(int count);

  /// Sync row headline while a sync runs
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get logsSyncSyncingTitle;

  /// Sync row progress while a sync runs
  ///
  /// In en, this message translates to:
  /// **'{savedCount} of {changeCount} changes saved'**
  String logsSyncSyncingSubtitle(int savedCount, int changeCount);

  /// Sync row headline after every change synced
  ///
  /// In en, this message translates to:
  /// **'Synced just now'**
  String get logsSyncSyncedTitle;

  /// Sync row sub-line after every change synced
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change saved to your Account} other{{count} changes saved to your Account}}'**
  String logsSyncSyncedSubtitle(int count);

  /// Sync row headline after only some changes synced
  ///
  /// In en, this message translates to:
  /// **'{savedCount} of {changeCount} changes synced'**
  String logsSyncPartialTitle(int savedCount, int changeCount);

  /// Sync row sub-line naming the changes the next sync retries
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change will try again next sync} other{{count} changes will try again next sync}}'**
  String logsSyncPartialSubtitle(int count);

  /// Sync row headline when a sync failed for lack of network
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get logsSyncOfflineTitle;

  /// Sync row sub-line when a sync failed for lack of network
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change is safe on this device. Sync when you\'re back online.} other{{count} changes are safe on this device. Sync when you\'re back online.}}'**
  String logsSyncOfflineSubtitle(int count);

  /// Sync row headline when a sync failed for any reason other than the network
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sync'**
  String get logsSyncFailedTitle;

  /// Sync row sub-line when a sync failed for any other reason
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change is safe on this device. Try again later.} other{{count} changes are safe on this device. Try again later.}}'**
  String logsSyncFailedSubtitle(int count);

  /// Sync row headline after a sync with nothing to send
  ///
  /// In en, this message translates to:
  /// **'Already up to date'**
  String get logsSyncAlreadyUpToDateTitle;

  /// Sync row sub-line after a sync with nothing to send
  ///
  /// In en, this message translates to:
  /// **'Nothing to sync'**
  String get logsSyncAlreadyUpToDateSubtitle;

  /// Sync row headline while log entries missing from this device download
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Getting 1 entry from your Account…} other{Getting {count} entries from your Account…}}'**
  String logsSyncDownloadingTitle(int count);

  /// Sync row sub-line while log entries download
  ///
  /// In en, this message translates to:
  /// **'You can keep working'**
  String get logsSyncDownloadingSubtitle;

  /// Sync row headline after log entries downloaded
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 entry added from your Account} other{{count} entries added from your Account}}'**
  String logsSyncDownloadedTitle(int count);

  /// Sync row sub-line after log entries downloaded
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{It was made on another device} other{They were made on another device}}'**
  String logsSyncDownloadedSubtitle(int count);

  /// Sync row button that starts a sync
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get logsSyncAction;

  /// Sync row button that starts a sync after a failure
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get logsSyncRetryAction;

  /// Disabled sync row button while a sync runs
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get logsSyncInProgressAction;

  /// Marker on a log entry created since the last sync
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get logsUnsyncedCreated;

  /// Marker on a log entry edited since the last sync
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get logsUnsyncedUpdated;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'he'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'he':
      return AppLocalizationsHe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
