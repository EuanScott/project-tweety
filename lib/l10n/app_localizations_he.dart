// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get appTitle => 'פרויקט טוויטי';

  @override
  String get homeTab => 'בית';

  @override
  String get dynamicFormTab => 'טופס';

  @override
  String get cardsTab => 'כרטיסים';

  @override
  String get settingsTab => 'הגדרות';

  @override
  String get settingsAppPreferencesTitle => 'העדפות האפליקציה';

  @override
  String get settingsAppPreferencesSubtitle => 'ערכת נושא ושפה';

  @override
  String get appPreferencesTitle => 'העדפות האפליקציה';

  @override
  String get appPreferencesThemeLabel => 'ערכת נושא';

  @override
  String get appPreferencesThemeSystem => 'מערכת';

  @override
  String get appPreferencesThemeLight => 'בהיר';

  @override
  String get appPreferencesThemeDark => 'כהה';

  @override
  String appPreferencesThemeSystemSelected(Object theme) {
    return 'מערכת ($theme)';
  }

  @override
  String appPreferencesThemeApplied(Object theme) {
    return 'מוחל כעת: $theme';
  }

  @override
  String appPreferencesThemeFollowingSystem(Object theme) {
    return 'בהתאם להגדרת המכשיר: $theme';
  }

  @override
  String get appPreferencesLanguageLabel => 'שפה';

  @override
  String get appPreferencesLanguageSystem => 'ברירת המחדל של המערכת';

  @override
  String appPreferencesLanguageApplied(Object language) {
    return 'מוחל כעת: $language';
  }

  @override
  String appPreferencesLanguageFollowingSystem(Object language) {
    return 'בהתאם להגדרת המכשיר: $language';
  }

  @override
  String get appPreferencesDirectionLabel => 'כיוון פריסה';

  @override
  String get appPreferencesDirectionLtr => 'LTR';

  @override
  String get appPreferencesDirectionRtl => 'RTL';

  @override
  String appPreferencesDirectionDescription(Object direction) {
    return 'בהתאם לשפת האפליקציה הפעילה: $direction';
  }

  @override
  String get appPreferencesRetry => 'נסה שוב';
}
