import 'app_language_option.model.dart';

class AppLanguageOptions {
  new _();

  static const supported = <AppLanguageOption>[
    AppLanguageOption(languageCode: 'en', nativeLabel: 'English'),
    AppLanguageOption(languageCode: 'es', nativeLabel: 'Español'),
    AppLanguageOption(languageCode: 'he', nativeLabel: 'עברית'),
  ];

  static AppLanguageOption? byLanguageCode(String? languageCode) {
    if (languageCode == null) {
      return null;
    }

    for (final option in supported) {
      if (option.languageCode == languageCode) {
        return option;
      }
    }

    return null;
  }

  static String labelForLanguageCode(String? languageCode) {
    return byLanguageCode(languageCode)?.nativeLabel ?? languageCode ?? '';
  }
}
