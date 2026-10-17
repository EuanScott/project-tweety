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
  String get logsTab => 'יומן';

  @override
  String get logEntryDetailsTitle => 'פרטי רשומה';

  @override
  String get logEntryDetailsIdLabel => 'מזהה';

  @override
  String get logEntryDetailsEmptyTitle => 'בחר רשומה';

  @override
  String get logEntryDetailsEmptyDescription =>
      'בחר רשומה מהרשימה כדי לראות פרטים.';

  @override
  String get logEntryDetailsMissingTitle => 'הרשומה לא נמצאה';

  @override
  String get logEntryDetailsMissingDescription => 'הרשומה הזו אינה זמינה.';

  @override
  String get logEntryDetailsLoadFailedTitle => 'לא ניתן לטעון את הרשומה';

  @override
  String get logEntryDetailsLoadFailedDescription => 'נסה לפתוח את הרשומה שוב.';

  @override
  String get logEntryCreateTitle => 'רשומה חדשה';

  @override
  String get logEntryCreateAction => 'צור רשומה';

  @override
  String get logEntryCreateTitleLabel => 'כותרת';

  @override
  String get logEntryCreateDescriptionLabel => 'תיאור';

  @override
  String get logEntryCreateTitleRequired => 'הזן כותרת.';

  @override
  String get logEntryCreateDescriptionRequired => 'הזן תיאור.';

  @override
  String get logEntryCreateEmptyTitle => 'אין עדיין רשומות';

  @override
  String get logEntryCreateEmptyDescription =>
      'צור את הרשומה הראשונה כדי להתחיל.';

  @override
  String get logEntryCreateFailed => 'לא ניתן לשמור את הרשומה. נסה שוב.';

  @override
  String get logEntryEditTitle => 'עריכת רשומה';

  @override
  String get logEntryEditAction => 'עריכת רשומה';

  @override
  String get logEntryEditSaveAction => 'שמירת שינויים';

  @override
  String get logEntryEditCancelAction => 'ביטול';

  @override
  String get logEntryEditFailed => 'לא ניתן לעדכן את הרשומה. נסה שוב.';

  @override
  String get logEntryEditNotFound => 'הרשומה כבר לא קיימת.';

  @override
  String get logEntryEditReturnToLogsAction => 'חזרה ליומן';

  @override
  String get logEntryDiscardConfirmationTitle => 'לבטל את השינויים?';

  @override
  String get logEntryDiscardConfirmationDescription =>
      'השינויים שלא נשמרו יאבדו.';

  @override
  String get logEntryDiscardCancelAction => 'להמשיך לערוך';

  @override
  String get logEntryDiscardAction => 'ביטול שינויים';

  @override
  String get logEntryDeleteAction => 'מחק רשומה';

  @override
  String get logEntryDeleteRetryAction => 'נסה למחוק שוב';

  @override
  String get logEntryDeleteCancelAction => 'השאר רשומה';

  @override
  String get logEntryDeleteConfirmationTitle => 'למחוק את הרשומה?';

  @override
  String get logEntryDeleteConfirmationDescription => 'הרשומה תוסר מהיומן שלך.';

  @override
  String get logEntryDeleteFailed => 'לא ניתן למחוק את הרשומה. נסה שוב.';

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
  String get settingsAppPreferencesTitle => 'התאמה אישית';

  @override
  String get settingsAppPreferencesSubtitle => 'ערכת נושא, שפה והגדרות טקסט';

  @override
  String get appPreferencesTitle => 'התאמה אישית';

  @override
  String get appPreferencesIntro =>
      'שנה את המראה, צבע ערכת הנושא, השפה והטקסט של האפליקציה.';

  @override
  String get appPreferencesThemeLabel => 'מראה';

  @override
  String get appPreferencesThemeSystem => 'מערכת';

  @override
  String get appPreferencesThemeLight => 'בהיר';

  @override
  String get appPreferencesThemeDark => 'כהה';

  @override
  String get appPreferencesThemeColourLabel => 'צבע ערכת הנושא';

  @override
  String get themeColourFjord => 'פיורד';

  @override
  String get themeColourFjordDescription =>
      'מים בגוון טורקיז ודמדומים בצבע שזיף מהפיורדים של נורווגיה. רגוע וצלול, כמו בוקר שקט על המים.';

  @override
  String get themeColourFynbos => 'פינבוס';

  @override
  String get themeColourFynbosDescription =>
      'ירוק זית וורוד פרוטאה מהצמחייה הפראית של הכף. רענן, ירוק ומלא פריחה.';

  @override
  String get themeColourKalahari => 'קלהרי';

  @override
  String get themeColourKalahariDescription =>
      'דיונות באדום אוקר תחת שמי מדבר כחולים ורחבים. חם וארצי, מהחולות הגדולים של דרום אפריקה.';

  @override
  String get themeColourLyng => 'אברש';

  @override
  String get themeColourLyngDescription =>
      'אברש סגול וזהב פטל צפוני מגבעות נורווגיה. רך ושקט, כמו סוף הקיץ בערבה.';

  @override
  String get themeColourWhin => 'אולקס';

  @override
  String get themeColourWhinDescription =>
      'זהב האולקס מגבעות סקוטלנד, שפורח כמעט כל השנה. שמשי ומואר, גם ביום אפור.';

  @override
  String get themeColourDouro => 'דורו';

  @override
  String get themeColourDouroDescription =>
      'אדום יין פורט ואריחים כחולים מעמק הדורו שבפורטוגל. עשיר וחם, כמו אור ערב על טרסות הכרמים.';

  @override
  String get themeColourCuillin => 'קולין';

  @override
  String get themeColourCuillinDescription =>
      'סלע שחור וערפל אפור מהרי האי סקיי. שקט וממוקד, עם נגיעה של כחול מפרץ ים.';

  @override
  String get appPreferencesLanguageLabel => 'שפה';

  @override
  String get appPreferencesLanguageSystem => 'ברירת המחדל של המערכת';

  @override
  String appPreferencesLanguageFollowingSystem(Object language) {
    return 'בהתאם להגדרת המכשיר: $language.';
  }

  @override
  String get appPreferencesDirectionFooter => 'כיוון הטקסט נקבע לפי השפה.';

  @override
  String get appPreferencesTextDisplayHeader => 'טקסט ותצוגה';

  @override
  String get appPreferencesTextSizeRow => 'גודל טקסט וטקסט מודגש';

  @override
  String get appPreferencesTextSizeFooter =>
      'שינוי גודל הגופן והטקסט המודגש בהגדרות המכשיר.';

  @override
  String get appPreferencesSystemTextOpenFailed =>
      'לא ניתן לפתוח את ההגדרות במכשיר הזה.';

  @override
  String get appPreferencesRetry => 'נסה שוב';

  @override
  String get signInCompactSubtitle =>
      'התחבר כדי לשמור את היומן שלך ולגבות אותו.';

  @override
  String get signInSceneSubtitle => 'היומן שלך, במכשיר הזה ומגובה מתי שתבחר.';

  @override
  String get signInSplitTitle => 'כניסה';

  @override
  String get signInSplitSubtitle => 'השתמש בחשבון Google שלך כדי להמשיך.';

  @override
  String get signInGoogleButton => 'כניסה באמצעות Google';

  @override
  String get signInGoogleButtonInProgress => 'מתחבר…';

  @override
  String get signInErrorTitle => 'הכניסה לא הצליחה';

  @override
  String get signInErrorNetwork => 'בדוק את החיבור שלך ונסה שוב.';

  @override
  String get signInErrorOther => 'משהו השתבש. נסה שוב.';

  @override
  String get signInFootnote => 'היומן שלך נשאר במכשיר הזה עד שתסנכרן אותו.';

  @override
  String get signInSceneDescription =>
      'דאש, ציפור כחולה בקפוצ\'ון ירוק, משכשך במים בצבע טורקיז ומחזיק כרטיס.';

  @override
  String get accountTitle => 'חשבון';

  @override
  String get accountAvatarLabel => 'חשבון';

  @override
  String get accountPhotoLabel => 'תמונת פרופיל';

  @override
  String get accountNoPhotoLabel => 'אין תמונת פרופיל';

  @override
  String get accountFallbackHeading => 'החשבון שלך';

  @override
  String get accountNoPhone => 'אין מספר טלפון בחשבון הזה';

  @override
  String get accountEmailLabel => 'אימייל';

  @override
  String get accountEmailVerified => 'מאומת';

  @override
  String get accountEmailNotVerified => 'לא מאומת';

  @override
  String get accountNoEmail => 'אין אימייל בחשבון הזה';

  @override
  String get accountSignedInWithLabel => 'מחובר באמצעות';

  @override
  String get accountProviderGoogle => 'Google';

  @override
  String get accountSignOut => 'התנתק';

  @override
  String get accountSigningOut => 'מתנתק…';

  @override
  String get accountSignOutFootnote => 'היומן שלך נשאר במכשיר הזה כשאתה מתנתק.';

  @override
  String get accountSignOutConfirmTitle => 'להתנתק?';

  @override
  String get accountSignOutConfirmBody =>
      'היומן שלך נשאר במכשיר הזה. התחבר שוב כדי לראות אותו.';

  @override
  String get accountSignOutConfirmCancel => 'ביטול';

  @override
  String get accountSignOutConfirmAction => 'התנתק';

  @override
  String get logsSyncUpToDateTitle => 'כל הרשומות מסונכרנות';

  @override
  String logsSyncLastSynced(DateTime time) {
    final intl.DateFormat timeDateFormat = intl.DateFormat.jm(localeName);
    final String timeString = timeDateFormat.format(time);

    return 'סנכרון אחרון ב-$timeString';
  }

  @override
  String logsSyncPendingTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count שינויים רק במכשיר הזה',
      one: 'שינוי אחד רק במכשיר הזה',
    );
    return '$_temp0';
  }

  @override
  String logsSyncPendingSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'סנכרן כדי לשמור אותם בחשבון שלך',
      one: 'סנכרן כדי לשמור אותו בחשבון שלך',
    );
    return '$_temp0';
  }

  @override
  String get logsSyncSyncingTitle => 'מסנכרן…';

  @override
  String logsSyncSyncingSubtitle(int savedCount, int changeCount) {
    return '$savedCount מתוך $changeCount שינויים נשמרו';
  }

  @override
  String get logsSyncSyncedTitle => 'סונכרן הרגע';

  @override
  String logsSyncSyncedSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count שינויים נשמרו בחשבון שלך',
      one: 'שינוי אחד נשמר בחשבון שלך',
    );
    return '$_temp0';
  }

  @override
  String logsSyncPartialTitle(int savedCount, int changeCount) {
    return '$savedCount מתוך $changeCount שינויים סונכרנו';
  }

  @override
  String logsSyncPartialSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count שינויים ינוסו שוב בסנכרון הבא',
      one: 'שינוי אחד ינוסה שוב בסנכרון הבא',
    );
    return '$_temp0';
  }

  @override
  String get logsSyncOfflineTitle => 'אין חיבור לרשת';

  @override
  String logsSyncOfflineSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count שינויים שמורים בבטחה במכשיר הזה. סנכרן כשתחזור לרשת.',
      one: 'שינוי אחד שמור בבטחה במכשיר הזה. סנכרן כשתחזור לרשת.',
    );
    return '$_temp0';
  }

  @override
  String get logsSyncFailedTitle => 'לא ניתן לסנכרן';

  @override
  String logsSyncFailedSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count שינויים שמורים בבטחה במכשיר הזה. נסה שוב מאוחר יותר.',
      one: 'שינוי אחד שמור בבטחה במכשיר הזה. נסה שוב מאוחר יותר.',
    );
    return '$_temp0';
  }

  @override
  String get logsSyncAlreadyUpToDateTitle => 'הכול כבר מעודכן';

  @override
  String get logsSyncAlreadyUpToDateSubtitle => 'אין מה לסנכרן';

  @override
  String logsSyncDownloadingTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'מוריד $count רשומות מהחשבון שלך…',
      one: 'מוריד רשומה אחת מהחשבון שלך…',
    );
    return '$_temp0';
  }

  @override
  String get logsSyncDownloadingSubtitle => 'אפשר להמשיך לעבוד';

  @override
  String logsSyncDownloadedTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count רשומות נוספו מהחשבון שלך',
      one: 'רשומה אחת נוספה מהחשבון שלך',
    );
    return '$_temp0';
  }

  @override
  String logsSyncDownloadedSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'הם נוצרו במכשיר אחר',
      one: 'הוא נוצר במכשיר אחר',
    );
    return '$_temp0';
  }

  @override
  String get logsSyncAction => 'סנכרן';

  @override
  String get logsSyncRetryAction => 'נסה שוב';

  @override
  String get logsSyncInProgressAction => 'מסנכרן';

  @override
  String get logsUnsyncedCreated => 'חדשה';

  @override
  String get logsUnsyncedUpdated => 'נערכה';
}
