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
  String get appPreferencesThemeLabel => 'Apariencia';

  @override
  String get appPreferencesThemeSystem => 'Sistema';

  @override
  String get appPreferencesThemeLight => 'Claro';

  @override
  String get appPreferencesThemeDark => 'Oscuro';

  @override
  String appPreferencesThemeFollowingSystem(Object theme) {
    return 'Siguiendo la configuración del dispositivo: $theme.';
  }

  @override
  String get appPreferencesThemeColourLabel => 'Color del tema';

  @override
  String get themeColourFjord => 'Fiordo';

  @override
  String get themeColourFjordColours => 'Turquesa con ciruela';

  @override
  String get themeColourFjordDescription =>
      'Agua turquesa y atardecer ciruela de los fiordos de Noruega. Tranquilo y claro, como una mañana en calma sobre el agua.';

  @override
  String get themeColourFynbos => 'Fynbos';

  @override
  String get themeColourFynbosColours => 'Oliva con rosa protea';

  @override
  String get themeColourFynbosDescription =>
      'Verde oliva y rosa protea del matorral silvestre del Cabo. Fresco, verde y lleno de flores.';

  @override
  String get themeColourKalahari => 'Kalahari';

  @override
  String get themeColourKalahariColours =>
      'Ocre rojo con azul cielo del desierto';

  @override
  String get themeColourKalahariDescription =>
      'Dunas de ocre rojo bajo un amplio cielo azul del desierto. Cálido y terroso, de las grandes arenas del sur de África.';

  @override
  String get themeColourLyng => 'Brezo';

  @override
  String get themeColourLyngColours => 'Brezo con oro de camemoro';

  @override
  String get themeColourLyngDescription =>
      'Brezo morado y oro de camemoro de las colinas noruegas. Suave y sereno, como el final del verano en el páramo.';

  @override
  String get themeColourWhin => 'Tojo';

  @override
  String get themeColourWhinColours => 'Oro de tojo con azul pizarra';

  @override
  String get themeColourWhinDescription =>
      'El oro del tojo de las colinas escocesas, que florece casi todo el año. Soleado y luminoso, incluso en un día gris.';

  @override
  String get themeColourDouro => 'Duero';

  @override
  String get themeColourDouroColours => 'Vino de Oporto con azul azulejo';

  @override
  String get themeColourDouroDescription =>
      'Rojo vino de Oporto y azulejos azules del valle del Duero, en Portugal. Intenso y cálido, como la luz del atardecer en las terrazas de viñedos.';

  @override
  String get themeColourCuillin => 'Cuillin';

  @override
  String get themeColourCuillinColours =>
      'Negro de montaña con azul de lago marino';

  @override
  String get themeColourCuillinDescription =>
      'Roca negra y niebla gris de las montañas de Skye. Sereno y concentrado, con un toque azul de lago marino.';

  @override
  String get appPreferencesLanguageLabel => 'Idioma';

  @override
  String get appPreferencesLanguageSystem => 'Predeterminado del sistema';

  @override
  String appPreferencesLanguageFollowingSystem(Object language) {
    return 'Siguiendo la configuración del dispositivo: $language.';
  }

  @override
  String get appPreferencesDirectionFooter =>
      'La dirección del texto sigue al idioma.';

  @override
  String get appPreferencesTextDisplayHeader => 'Texto y pantalla';

  @override
  String get appPreferencesTextSizeRow => 'Tamaño del texto y negrita';

  @override
  String get appPreferencesTextSizeFooter =>
      'Cambia el tamaño de letra y la negrita en los ajustes del dispositivo.';

  @override
  String get appPreferencesSystemTextOpenFailed =>
      'No se pudo abrir la configuración en este dispositivo.';

  @override
  String get appPreferencesRetry => 'Reintentar';

  @override
  String get signInCompactSubtitle =>
      'Inicia sesión para conservar tus Tarjetas y hacer una copia de seguridad.';

  @override
  String get signInSceneSubtitle =>
      'Tus Tarjetas, en este dispositivo y con copia de seguridad cuando tú decidas.';

  @override
  String get signInSplitTitle => 'Iniciar sesión';

  @override
  String get signInSplitSubtitle => 'Usa tu cuenta de Google para continuar.';

  @override
  String get signInGoogleButton => 'Iniciar sesión con Google';

  @override
  String get signInGoogleButtonInProgress => 'Iniciando sesión…';

  @override
  String get signInErrorTitle => 'No se pudo iniciar sesión';

  @override
  String get signInErrorNetwork =>
      'Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get signInErrorOther => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get signInFootnote =>
      'Tus Tarjetas se quedan en este dispositivo hasta que las sincronices.';

  @override
  String get signInSceneDescription =>
      'Dash, un pájaro azul con una sudadera verde, vadeando en agua turquesa y sosteniendo una tarjeta.';

  @override
  String get accountTitle => 'Cuenta';

  @override
  String get accountAvatarLabel => 'Cuenta';

  @override
  String get accountPhotoLabel => 'Foto de perfil';

  @override
  String get accountNoPhotoLabel => 'Sin foto de perfil';

  @override
  String get accountFallbackHeading => 'Tu Cuenta';

  @override
  String get accountNoPhone => 'No hay número de teléfono en esta Cuenta';

  @override
  String get accountEmailLabel => 'Correo electrónico';

  @override
  String get accountEmailVerified => 'Verificado';

  @override
  String get accountEmailNotVerified => 'Sin verificar';

  @override
  String get accountNoEmail => 'No hay correo electrónico en esta Cuenta';

  @override
  String get accountSignedInWithLabel => 'Sesión iniciada con';

  @override
  String get accountProviderGoogle => 'Google';

  @override
  String get accountSignOut => 'Cerrar sesión';

  @override
  String get accountSigningOut => 'Cerrando sesión…';

  @override
  String get accountSignOutFootnote =>
      'Tus Tarjetas se quedan en este dispositivo cuando cierras sesión.';

  @override
  String get accountSignOutConfirmTitle => '¿Cerrar sesión?';

  @override
  String get accountSignOutConfirmBody =>
      'Tus Tarjetas se quedan en este dispositivo. Vuelve a iniciar sesión para verlas.';

  @override
  String get accountSignOutConfirmCancel => 'Cancelar';

  @override
  String get accountSignOutConfirmAction => 'Cerrar sesión';
}
