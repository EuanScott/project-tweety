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

  /// Label for cards tab
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get cardsTab;

  /// Title for the card details page
  ///
  /// In en, this message translates to:
  /// **'Card details'**
  String get cardDetailsTitle;

  /// Label for the card id shown on the card details page
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get cardDetailsIdLabel;

  /// Title shown in the wide cards detail pane before a card is selected
  ///
  /// In en, this message translates to:
  /// **'Select a card'**
  String get cardDetailsEmptyTitle;

  /// Description shown in the wide cards detail pane before a card is selected
  ///
  /// In en, this message translates to:
  /// **'Choose a card from the list to see details.'**
  String get cardDetailsEmptyDescription;

  /// Title shown when a card details route references an unknown card id
  ///
  /// In en, this message translates to:
  /// **'Card not found'**
  String get cardDetailsMissingTitle;

  /// Description shown when a card details route references an unknown card id
  ///
  /// In en, this message translates to:
  /// **'This card is not available.'**
  String get cardDetailsMissingDescription;

  /// Title shown when card details fail to load
  ///
  /// In en, this message translates to:
  /// **'Unable to load card'**
  String get cardDetailsLoadFailedTitle;

  /// Description shown when card details fail to load
  ///
  /// In en, this message translates to:
  /// **'Try opening the card again.'**
  String get cardDetailsLoadFailedDescription;

  /// No description provided for @cardCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New card'**
  String get cardCreateTitle;

  /// No description provided for @cardCreateAction.
  ///
  /// In en, this message translates to:
  /// **'Create card'**
  String get cardCreateAction;

  /// No description provided for @cardCreateTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get cardCreateTitleLabel;

  /// No description provided for @cardCreateDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get cardCreateDescriptionLabel;

  /// No description provided for @cardCreateTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a title.'**
  String get cardCreateTitleRequired;

  /// No description provided for @cardCreateDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a description.'**
  String get cardCreateDescriptionRequired;

  /// No description provided for @cardCreateEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No cards yet'**
  String get cardCreateEmptyTitle;

  /// No description provided for @cardCreateEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Create your first card to get started.'**
  String get cardCreateEmptyDescription;

  /// No description provided for @cardCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to save card. Try again.'**
  String get cardCreateFailed;

  /// No description provided for @cardEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit card'**
  String get cardEditTitle;

  /// No description provided for @cardEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit card'**
  String get cardEditAction;

  /// No description provided for @cardEditSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get cardEditSaveAction;

  /// No description provided for @cardEditCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cardEditCancelAction;

  /// No description provided for @cardEditFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to update card. Try again.'**
  String get cardEditFailed;

  /// No description provided for @cardEditNotFound.
  ///
  /// In en, this message translates to:
  /// **'Card no longer exists.'**
  String get cardEditNotFound;

  /// No description provided for @cardEditReturnToCardsAction.
  ///
  /// In en, this message translates to:
  /// **'Return to cards'**
  String get cardEditReturnToCardsAction;

  /// No description provided for @cardDiscardConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get cardDiscardConfirmationTitle;

  /// No description provided for @cardDiscardConfirmationDescription.
  ///
  /// In en, this message translates to:
  /// **'Your unsaved changes will be lost.'**
  String get cardDiscardConfirmationDescription;

  /// No description provided for @cardDiscardCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get cardDiscardCancelAction;

  /// No description provided for @cardDiscardAction.
  ///
  /// In en, this message translates to:
  /// **'Discard changes'**
  String get cardDiscardAction;

  /// No description provided for @cardDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete card'**
  String get cardDeleteAction;

  /// No description provided for @cardDeleteRetryAction.
  ///
  /// In en, this message translates to:
  /// **'Retry deletion'**
  String get cardDeleteRetryAction;

  /// No description provided for @cardDeleteCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Keep card'**
  String get cardDeleteCancelAction;

  /// No description provided for @cardDeleteConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete card?'**
  String get cardDeleteConfirmationTitle;

  /// No description provided for @cardDeleteConfirmationDescription.
  ///
  /// In en, this message translates to:
  /// **'This card will be removed from your list.'**
  String get cardDeleteConfirmationDescription;

  /// No description provided for @cardDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete card. Try again.'**
  String get cardDeleteFailed;

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

  /// Title for the display and language settings entry
  ///
  /// In en, this message translates to:
  /// **'Display and language'**
  String get settingsAppPreferencesTitle;

  /// Subtitle for the display and language settings entry
  ///
  /// In en, this message translates to:
  /// **'Theme, language, and text settings'**
  String get settingsAppPreferencesSubtitle;

  /// Title for the display and language page
  ///
  /// In en, this message translates to:
  /// **'Display and language'**
  String get appPreferencesTitle;

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

  /// Helper text when theme follows the system setting
  ///
  /// In en, this message translates to:
  /// **'Following device setting: {theme}.'**
  String appPreferencesThemeFollowingSystem(Object theme);

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

  /// The two colours of the Fjord theme colour, shown after its name
  ///
  /// In en, this message translates to:
  /// **'Teal with plum'**
  String get themeColourFjordColours;

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

  /// The two colours of the Fynbos theme colour, shown after its name
  ///
  /// In en, this message translates to:
  /// **'Olive with protea pink'**
  String get themeColourFynbosColours;

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

  /// The two colours of the Kalahari theme colour, shown after its name
  ///
  /// In en, this message translates to:
  /// **'Red ochre with desert-sky blue'**
  String get themeColourKalahariColours;

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

  /// The two colours of the Lyng theme colour, shown after its name
  ///
  /// In en, this message translates to:
  /// **'Heather with cloudberry gold'**
  String get themeColourLyngColours;

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

  /// The two colours of the Whin theme colour, shown after its name
  ///
  /// In en, this message translates to:
  /// **'Gorse gold with slate blue'**
  String get themeColourWhinColours;

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

  /// The two colours of the Douro theme colour, shown after its name
  ///
  /// In en, this message translates to:
  /// **'Port wine with tile blue'**
  String get themeColourDouroColours;

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

  /// The two colours of the Cuillin theme colour, shown after its name
  ///
  /// In en, this message translates to:
  /// **'Mountain black with sea-loch blue'**
  String get themeColourCuillinColours;

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
  /// **'Sign in to keep your Cards and back them up.'**
  String get signInCompactSubtitle;

  /// Subtitle over the illustration on the split sign-in page
  ///
  /// In en, this message translates to:
  /// **'Your Cards, on this device and backed up when you choose.'**
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
  /// **'Your Cards stay on this device until you sync them.'**
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
  /// **'Your Cards stay on this device when you sign out.'**
  String get accountSignOutFootnote;

  /// Title of the sign-out confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get accountSignOutConfirmTitle;

  /// Body of the sign-out confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Your Cards stay on this device. Sign in again to see them.'**
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
