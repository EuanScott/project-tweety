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
  String get cardsTab => 'Cards';

  @override
  String get settingsTab => 'Settings';

  @override
  String get settingsAppPreferencesTitle => 'Display and language';

  @override
  String get settingsAppPreferencesSubtitle =>
      'Theme, language, and text settings';

  @override
  String get appPreferencesTitle => 'Display and language';

  @override
  String get appPreferencesThemeLabel => 'Theme';

  @override
  String get appPreferencesThemeSystem => 'System';

  @override
  String get appPreferencesThemeLight => 'Light';

  @override
  String get appPreferencesThemeDark => 'Dark';

  @override
  String appPreferencesThemeSystemSelected(Object theme) {
    return 'System ($theme)';
  }

  @override
  String appPreferencesThemeApplied(Object theme) {
    return 'Currently applied: $theme';
  }

  @override
  String appPreferencesThemeFollowingSystem(Object theme) {
    return 'Following device setting: $theme';
  }

  @override
  String get appPreferencesLanguageLabel => 'Language';

  @override
  String get appPreferencesLanguageSystem => 'System default';

  @override
  String appPreferencesLanguageApplied(Object language) {
    return 'Currently applied: $language';
  }

  @override
  String appPreferencesLanguageFollowingSystem(Object language) {
    return 'Following device setting: $language';
  }

  @override
  String get appPreferencesDirectionLabel => 'Layout direction';

  @override
  String get appPreferencesDirectionLtr => 'LTR';

  @override
  String get appPreferencesDirectionRtl => 'RTL';

  @override
  String appPreferencesDirectionDescription(Object direction) {
    return 'Following active app language: $direction';
  }

  @override
  String get appPreferencesSystemTextTitle => 'Display and text settings';

  @override
  String get appPreferencesSystemTextDescription =>
      'Use your device settings for options like font size and bold text.';

  @override
  String get appPreferencesSystemTextButton => 'Open settings';

  @override
  String get appPreferencesSystemTextOpenFailed =>
      'Unable to open settings on this device.';

  @override
  String get appPreferencesRetry => 'Retry';
}
