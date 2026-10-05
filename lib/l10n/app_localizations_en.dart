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
  String get cardDetailsTitle => 'Card details';

  @override
  String get cardDetailsIdLabel => 'ID';

  @override
  String get cardDetailsEmptyTitle => 'Select a card';

  @override
  String get cardDetailsEmptyDescription =>
      'Choose a card from the list to see details.';

  @override
  String get cardDetailsMissingTitle => 'Card not found';

  @override
  String get cardDetailsMissingDescription => 'This card is not available.';

  @override
  String get cardDetailsLoadFailedTitle => 'Unable to load card';

  @override
  String get cardDetailsLoadFailedDescription => 'Try opening the card again.';

  @override
  String get cardCreateTitle => 'New card';

  @override
  String get cardCreateAction => 'Create card';

  @override
  String get cardCreateTitleLabel => 'Title';

  @override
  String get cardCreateDescriptionLabel => 'Description';

  @override
  String get cardCreateTitleRequired => 'Enter a title.';

  @override
  String get cardCreateDescriptionRequired => 'Enter a description.';

  @override
  String get cardCreateEmptyTitle => 'No cards yet';

  @override
  String get cardCreateEmptyDescription =>
      'Create your first card to get started.';

  @override
  String get cardCreateFailed => 'Unable to save card. Try again.';

  @override
  String get cardEditTitle => 'Edit card';

  @override
  String get cardEditAction => 'Edit card';

  @override
  String get cardEditSaveAction => 'Save changes';

  @override
  String get cardEditCancelAction => 'Cancel';

  @override
  String get cardEditFailed => 'Unable to update card. Try again.';

  @override
  String get cardEditNotFound => 'Card no longer exists.';

  @override
  String get cardEditReturnToCardsAction => 'Return to cards';

  @override
  String get cardDiscardConfirmationTitle => 'Discard changes?';

  @override
  String get cardDiscardConfirmationDescription =>
      'Your unsaved changes will be lost.';

  @override
  String get cardDiscardCancelAction => 'Keep editing';

  @override
  String get cardDiscardAction => 'Discard changes';

  @override
  String get cardDeleteAction => 'Delete card';

  @override
  String get cardDeleteRetryAction => 'Retry deletion';

  @override
  String get cardDeleteCancelAction => 'Keep card';

  @override
  String get cardDeleteConfirmationTitle => 'Delete card?';

  @override
  String get cardDeleteConfirmationDescription =>
      'This card will be removed from your list.';

  @override
  String get cardDeleteFailed => 'Unable to delete card. Try again.';

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
  String appPreferencesThemeDeviceSetting(Object theme) {
    return 'Device setting: $theme';
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

  @override
  String get signInCompactSubtitle =>
      'Sign in to keep your Cards and back them up.';

  @override
  String get signInSceneSubtitle =>
      'Your Cards, on this device and backed up when you choose.';

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
      'Your Cards stay on this device until you sync them.';

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
      'Your Cards stay on this device when you sign out.';

  @override
  String get accountSignOutConfirmTitle => 'Sign out?';

  @override
  String get accountSignOutConfirmBody =>
      'Your Cards stay on this device. Sign in again to see them.';

  @override
  String get accountSignOutConfirmCancel => 'Cancel';

  @override
  String get accountSignOutConfirmAction => 'Sign out';
}
