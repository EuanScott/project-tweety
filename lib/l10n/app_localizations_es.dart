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
  String get settingsAppPreferencesTitle => 'Pantalla e idioma';

  @override
  String get settingsAppPreferencesSubtitle =>
      'Tema, idioma y ajustes de texto';

  @override
  String get appPreferencesTitle => 'Pantalla e idioma';

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
  String get appPreferencesSystemTextTitle => 'Ajustes de pantalla y texto';

  @override
  String get appPreferencesSystemTextDescription =>
      'Usa la configuración del dispositivo para opciones como el tamaño del texto y el texto en negrita.';

  @override
  String get appPreferencesSystemTextButton => 'Abrir configuración';

  @override
  String get appPreferencesSystemTextOpenFailed =>
      'No se pudo abrir la configuración en este dispositivo.';

  @override
  String get appPreferencesRetry => 'Reintentar';
}
