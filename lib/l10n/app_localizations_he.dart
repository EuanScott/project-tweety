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
  String get cardDetailsTitle => 'פרטי כרטיס';

  @override
  String get cardDetailsIdLabel => 'מזהה';

  @override
  String get cardDetailsEmptyTitle => 'בחר כרטיס';

  @override
  String get cardDetailsEmptyDescription =>
      'בחר כרטיס מהרשימה כדי לראות פרטים.';

  @override
  String get cardDetailsMissingTitle => 'הכרטיס לא נמצא';

  @override
  String get cardDetailsMissingDescription => 'הכרטיס הזה אינו זמין.';

  @override
  String get cardDetailsLoadFailedTitle => 'לא ניתן לטעון את הכרטיס';

  @override
  String get cardDetailsLoadFailedDescription => 'נסה לפתוח את הכרטיס שוב.';

  @override
  String get cardCreateTitle => 'כרטיס חדש';

  @override
  String get cardCreateAction => 'צור כרטיס';

  @override
  String get cardCreateTitleLabel => 'כותרת';

  @override
  String get cardCreateDescriptionLabel => 'תיאור';

  @override
  String get cardCreateTitleRequired => 'הזן כותרת.';

  @override
  String get cardCreateDescriptionRequired => 'הזן תיאור.';

  @override
  String get cardCreateEmptyTitle => 'אין עדיין כרטיסים';

  @override
  String get cardCreateEmptyDescription => 'צור את הכרטיס הראשון כדי להתחיל.';

  @override
  String get cardCreateFailed => 'לא ניתן לשמור את הכרטיס. נסה שוב.';

  @override
  String get cardEditTitle => 'עריכת כרטיס';

  @override
  String get cardEditAction => 'עריכת כרטיס';

  @override
  String get cardEditSaveAction => 'שמירת שינויים';

  @override
  String get cardEditCancelAction => 'ביטול';

  @override
  String get cardEditFailed => 'לא ניתן לעדכן את הכרטיס. נסה שוב.';

  @override
  String get cardEditNotFound => 'הכרטיס כבר לא קיים.';

  @override
  String get cardEditReturnToCardsAction => 'חזרה לכרטיסים';

  @override
  String get cardDiscardConfirmationTitle => 'לבטל את השינויים?';

  @override
  String get cardDiscardConfirmationDescription => 'השינויים שלא נשמרו יאבדו.';

  @override
  String get cardDiscardCancelAction => 'להמשיך לערוך';

  @override
  String get cardDiscardAction => 'ביטול שינויים';

  @override
  String get cardDeleteAction => 'מחק כרטיס';

  @override
  String get cardDeleteRetryAction => 'נסה למחוק שוב';

  @override
  String get cardDeleteCancelAction => 'השאר כרטיס';

  @override
  String get cardDeleteConfirmationTitle => 'למחוק את הכרטיס?';

  @override
  String get cardDeleteConfirmationDescription => 'הכרטיס יוסר מהרשימה שלך.';

  @override
  String get cardDeleteFailed => 'לא ניתן למחוק את הכרטיס. נסה שוב.';

  @override
  String get settingsTab => 'הגדרות';

  @override
  String get navigationErrorTitle => 'העמוד לא נמצא';

  @override
  String get navigationErrorDescription => 'העמוד שחיפשת אינו זמין.';

  @override
  String get navigationErrorGoHome => 'עבור לבית';

  @override
  String get accessDeniedTitle => 'הגישה נדחתה';

  @override
  String get accessDeniedDescription => 'אין לך גישה לעמוד הזה.';

  @override
  String get accessDeniedGoHome => 'עבור לבית';

  @override
  String get settingsAppPreferencesTitle => 'תצוגה ושפה';

  @override
  String get settingsAppPreferencesSubtitle => 'ערכת נושא, שפה והגדרות טקסט';

  @override
  String get appPreferencesTitle => 'תצוגה ושפה';

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
  String appPreferencesThemeDeviceSetting(Object theme) {
    return 'הגדרת המכשיר: $theme';
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
  String get appPreferencesSystemTextTitle => 'הגדרות תצוגה וטקסט';

  @override
  String get appPreferencesSystemTextDescription =>
      'השתמש בהגדרות המכשיר עבור אפשרויות כמו גודל טקסט וטקסט מודגש.';

  @override
  String get appPreferencesSystemTextButton => 'פתח הגדרות';

  @override
  String get appPreferencesSystemTextOpenFailed =>
      'לא ניתן לפתוח את ההגדרות במכשיר הזה.';

  @override
  String get appPreferencesRetry => 'נסה שוב';
}
