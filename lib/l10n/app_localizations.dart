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

  /// Label for settings tab
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

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

  /// Label for the theme selector
  ///
  /// In en, this message translates to:
  /// **'Theme'**
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

  /// Selected label for the system theme option
  ///
  /// In en, this message translates to:
  /// **'System ({theme})'**
  String appPreferencesThemeSystemSelected(Object theme);

  /// Helper text for an explicitly selected theme
  ///
  /// In en, this message translates to:
  /// **'Currently applied: {theme}'**
  String appPreferencesThemeApplied(Object theme);

  /// Helper text when theme follows the system setting
  ///
  /// In en, this message translates to:
  /// **'Following device setting: {theme}'**
  String appPreferencesThemeFollowingSystem(Object theme);

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

  /// Helper text for an explicitly selected language
  ///
  /// In en, this message translates to:
  /// **'Currently applied: {language}'**
  String appPreferencesLanguageApplied(Object language);

  /// Helper text when language follows the system setting
  ///
  /// In en, this message translates to:
  /// **'Following device setting: {language}'**
  String appPreferencesLanguageFollowingSystem(Object language);

  /// Label for the current layout direction
  ///
  /// In en, this message translates to:
  /// **'Layout direction'**
  String get appPreferencesDirectionLabel;

  /// Short label for left-to-right layout
  ///
  /// In en, this message translates to:
  /// **'LTR'**
  String get appPreferencesDirectionLtr;

  /// Short label for right-to-left layout
  ///
  /// In en, this message translates to:
  /// **'RTL'**
  String get appPreferencesDirectionRtl;

  /// Helper text for the current layout direction
  ///
  /// In en, this message translates to:
  /// **'Following active app language: {direction}'**
  String appPreferencesDirectionDescription(Object direction);

  /// Title for the display and text settings section
  ///
  /// In en, this message translates to:
  /// **'Display and text settings'**
  String get appPreferencesSystemTextTitle;

  /// Description for the display and text settings section
  ///
  /// In en, this message translates to:
  /// **'Use your device settings for options like font size and bold text.'**
  String get appPreferencesSystemTextDescription;

  /// Button label to open device settings
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get appPreferencesSystemTextButton;

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
