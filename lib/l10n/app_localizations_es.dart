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
  String get cardDetailsTitle => 'Detalles de la tarjeta';

  @override
  String get cardDetailsIdLabel => 'ID';

  @override
  String get cardDetailsEmptyTitle => 'Selecciona una tarjeta';

  @override
  String get cardDetailsEmptyDescription =>
      'Elige una tarjeta de la lista para ver los detalles.';

  @override
  String get cardDetailsMissingTitle => 'Tarjeta no encontrada';

  @override
  String get cardDetailsMissingDescription =>
      'Esta tarjeta no está disponible.';

  @override
  String get cardDetailsLoadFailedTitle => 'No se pudo cargar la tarjeta';

  @override
  String get cardDetailsLoadFailedDescription =>
      'Intenta abrir la tarjeta de nuevo.';

  @override
  String get cardCreateTitle => 'Nueva tarjeta';

  @override
  String get cardCreateAction => 'Crear tarjeta';

  @override
  String get cardCreateTitleLabel => 'Título';

  @override
  String get cardCreateDescriptionLabel => 'Descripción';

  @override
  String get cardCreateTitleRequired => 'Ingresa un título.';

  @override
  String get cardCreateDescriptionRequired => 'Ingresa una descripción.';

  @override
  String get cardCreateEmptyTitle => 'Aún no hay tarjetas';

  @override
  String get cardCreateEmptyDescription =>
      'Crea tu primera tarjeta para comenzar.';

  @override
  String get cardCreateFailed =>
      'No se pudo guardar la tarjeta. Inténtalo de nuevo.';

  @override
  String get cardEditTitle => 'Editar tarjeta';

  @override
  String get cardEditAction => 'Editar tarjeta';

  @override
  String get cardEditSaveAction => 'Guardar cambios';

  @override
  String get cardEditCancelAction => 'Cancelar';

  @override
  String get cardEditFailed =>
      'No se pudo actualizar la tarjeta. Inténtalo de nuevo.';

  @override
  String get cardEditNotFound => 'La tarjeta ya no existe.';

  @override
  String get cardEditReturnToCardsAction => 'Volver a las tarjetas';

  @override
  String get cardDiscardConfirmationTitle => '¿Descartar cambios?';

  @override
  String get cardDiscardConfirmationDescription =>
      'Se perderán los cambios sin guardar.';

  @override
  String get cardDiscardCancelAction => 'Seguir editando';

  @override
  String get cardDiscardAction => 'Descartar cambios';

  @override
  String get cardDeleteAction => 'Eliminar tarjeta';

  @override
  String get cardDeleteRetryAction => 'Reintentar eliminación';

  @override
  String get cardDeleteCancelAction => 'Conservar tarjeta';

  @override
  String get cardDeleteConfirmationTitle => '¿Eliminar tarjeta?';

  @override
  String get cardDeleteConfirmationDescription =>
      'Esta tarjeta se eliminará de tu lista.';

  @override
  String get cardDeleteFailed =>
      'No se pudo eliminar la tarjeta. Inténtalo de nuevo.';

  @override
  String get settingsTab => 'Configuración';

  @override
  String get navigationErrorTitle => 'Página no encontrada';

  @override
  String get navigationErrorDescription =>
      'La página que buscabas no está disponible.';

  @override
  String get navigationErrorGoHome => 'Ir al inicio';

  @override
  String get accessDeniedTitle => 'Acceso denegado';

  @override
  String get accessDeniedDescription => 'No tienes acceso a esta página.';

  @override
  String get accessDeniedGoHome => 'Ir al inicio';

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
  String appPreferencesThemeDeviceSetting(Object theme) {
    return 'Configuración del dispositivo: $theme';
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
