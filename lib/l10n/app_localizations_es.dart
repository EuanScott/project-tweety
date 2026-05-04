// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Proyecto Tweety';

  @override
  String get homeTab => 'Inicio';

  @override
  String get dynamicFormTab => 'Formulario';

  @override
  String get cardsTab => 'Tarjetas';

  @override
  String get settingsTab => 'Configuración';

  @override
  String get settingsAppPreferencesTitle => 'Preferencias de la aplicación';

  @override
  String get settingsAppPreferencesSubtitle => 'Tema e idioma';

  @override
  String get appPreferencesTitle => 'Preferencias de la aplicación';

  @override
  String get appPreferencesThemeLabel => 'Tema';

  @override
  String get appPreferencesThemeSystem => 'Sistema';

  @override
  String get appPreferencesThemeLight => 'Claro';

  @override
  String get appPreferencesThemeDark => 'Oscuro';

  @override
  String appPreferencesThemeSystemSelected(Object theme) {
    return 'Sistema ($theme)';
  }

  @override
  String appPreferencesThemeApplied(Object theme) {
    return 'Aplicado actualmente: $theme';
  }

  @override
  String appPreferencesThemeFollowingSystem(Object theme) {
    return 'Siguiendo la configuración del dispositivo: $theme';
  }

  @override
  String get appPreferencesLanguageLabel => 'Idioma';

  @override
  String get appPreferencesLanguageSystem => 'Predeterminado del sistema';

  @override
  String appPreferencesLanguageApplied(Object language) {
    return 'Aplicado actualmente: $language';
  }

  @override
  String appPreferencesLanguageFollowingSystem(Object language) {
    return 'Siguiendo la configuración del dispositivo: $language';
  }

  @override
  String get appPreferencesDirectionLabel => 'Dirección de la interfaz';

  @override
  String get appPreferencesDirectionLtr => 'LTR';

  @override
  String get appPreferencesDirectionRtl => 'RTL';

  @override
  String appPreferencesDirectionDescription(Object direction) {
    return 'Siguiendo el idioma activo de la aplicación: $direction';
  }

  @override
  String get appPreferencesRetry => 'Reintentar';
}
