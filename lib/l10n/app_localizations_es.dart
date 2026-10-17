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
  String get logsTab => 'Registros';

  @override
  String get logEntryDetailsTitle => 'Detalles de la entrada';

  @override
  String get logEntryDetailsIdLabel => 'ID';

  @override
  String get logEntryDetailsEmptyTitle => 'Selecciona una entrada';

  @override
  String get logEntryDetailsEmptyDescription =>
      'Elige una entrada de la lista para ver los detalles.';

  @override
  String get logEntryDetailsMissingTitle => 'Entrada no encontrada';

  @override
  String get logEntryDetailsMissingDescription =>
      'Esta entrada no está disponible.';

  @override
  String get logEntryDetailsLoadFailedTitle => 'No se pudo cargar la entrada';

  @override
  String get logEntryDetailsLoadFailedDescription =>
      'Intenta abrir la entrada de nuevo.';

  @override
  String get logEntryCreateTitle => 'Nueva entrada';

  @override
  String get logEntryCreateAction => 'Crear entrada';

  @override
  String get logEntryCreateTitleLabel => 'Título';

  @override
  String get logEntryCreateDescriptionLabel => 'Descripción';

  @override
  String get logEntryCreateTitleRequired => 'Ingresa un título.';

  @override
  String get logEntryCreateDescriptionRequired => 'Ingresa una descripción.';

  @override
  String get logEntryCreateEmptyTitle => 'Aún no hay entradas';

  @override
  String get logEntryCreateEmptyDescription =>
      'Crea tu primera entrada para comenzar.';

  @override
  String get logEntryCreateFailed =>
      'No se pudo guardar la entrada. Inténtalo de nuevo.';

  @override
  String get logEntryEditTitle => 'Editar entrada';

  @override
  String get logEntryEditAction => 'Editar entrada';

  @override
  String get logEntryEditSaveAction => 'Guardar cambios';

  @override
  String get logEntryEditCancelAction => 'Cancelar';

  @override
  String get logEntryEditFailed =>
      'No se pudo actualizar la entrada. Inténtalo de nuevo.';

  @override
  String get logEntryEditNotFound => 'La entrada ya no existe.';

  @override
  String get logEntryEditReturnToLogsAction => 'Volver a los registros';

  @override
  String get logEntryDiscardConfirmationTitle => '¿Descartar cambios?';

  @override
  String get logEntryDiscardConfirmationDescription =>
      'Se perderán los cambios sin guardar.';

  @override
  String get logEntryDiscardCancelAction => 'Seguir editando';

  @override
  String get logEntryDiscardAction => 'Descartar cambios';

  @override
  String get logEntryDeleteAction => 'Eliminar entrada';

  @override
  String get logEntryDeleteRetryAction => 'Reintentar eliminación';

  @override
  String get logEntryDeleteCancelAction => 'Conservar entrada';

  @override
  String get logEntryDeleteConfirmationTitle => '¿Eliminar entrada?';

  @override
  String get logEntryDeleteConfirmationDescription =>
      'Esta entrada se eliminará de tus registros.';

  @override
  String get logEntryDeleteFailed =>
      'No se pudo eliminar la entrada. Inténtalo de nuevo.';

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
  String get settingsAppPreferencesTitle => 'Personalización';

  @override
  String get settingsAppPreferencesSubtitle =>
      'Tema, idioma y ajustes de texto';

  @override
  String get appPreferencesTitle => 'Personalización';

  @override
  String get appPreferencesIntro =>
      'Cambia la apariencia, el color del tema, el idioma y el texto de la aplicación.';

  @override
  String get appPreferencesThemeLabel => 'Apariencia';

  @override
  String get appPreferencesThemeSystem => 'Sistema';

  @override
  String get appPreferencesThemeLight => 'Claro';

  @override
  String get appPreferencesThemeDark => 'Oscuro';

  @override
  String get appPreferencesThemeColourLabel => 'Color del tema';

  @override
  String get themeColourFjord => 'Fiordo';

  @override
  String get themeColourFjordDescription =>
      'Agua turquesa y atardecer ciruela de los fiordos de Noruega. Tranquilo y claro, como una mañana en calma sobre el agua.';

  @override
  String get themeColourFynbos => 'Fynbos';

  @override
  String get themeColourFynbosDescription =>
      'Verde oliva y rosa protea del matorral silvestre del Cabo. Fresco, verde y lleno de flores.';

  @override
  String get themeColourKalahari => 'Kalahari';

  @override
  String get themeColourKalahariDescription =>
      'Dunas de ocre rojo bajo un amplio cielo azul del desierto. Cálido y terroso, de las grandes arenas del sur de África.';

  @override
  String get themeColourLyng => 'Brezo';

  @override
  String get themeColourLyngDescription =>
      'Brezo morado y oro de camemoro de las colinas noruegas. Suave y sereno, como el final del verano en el páramo.';

  @override
  String get themeColourWhin => 'Tojo';

  @override
  String get themeColourWhinDescription =>
      'El oro del tojo de las colinas escocesas, que florece casi todo el año. Soleado y luminoso, incluso en un día gris.';

  @override
  String get themeColourDouro => 'Duero';

  @override
  String get themeColourDouroDescription =>
      'Rojo vino de Oporto y azulejos azules del valle del Duero, en Portugal. Intenso y cálido, como la luz del atardecer en las terrazas de viñedos.';

  @override
  String get themeColourCuillin => 'Cuillin';

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
  String get signInCompactSubtitle =>
      'Inicia sesión para conservar tus registros y hacer una copia de seguridad.';

  @override
  String get signInSceneSubtitle =>
      'Tus registros, en este dispositivo y con copia de seguridad cuando tú decidas.';

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
      'Tus registros se quedan en este dispositivo hasta que los sincronices.';

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
      'Tus registros se quedan en este dispositivo cuando cierras sesión.';

  @override
  String get accountSignOutConfirmTitle => '¿Cerrar sesión?';

  @override
  String get accountSignOutConfirmBody =>
      'Tus registros se quedan en este dispositivo. Vuelve a iniciar sesión para verlos.';

  @override
  String get accountSignOutConfirmCancel => 'Cancelar';

  @override
  String get accountSignOutConfirmAction => 'Cerrar sesión';

  @override
  String get logsSyncUpToDateTitle => 'Todos los registros sincronizados';

  @override
  String logsSyncLastSynced(DateTime time) {
    final intl.DateFormat timeDateFormat = intl.DateFormat.jm(localeName);
    final String timeString = timeDateFormat.format(time);

    return 'Última sincronización a las $timeString';
  }

  @override
  String logsSyncPendingTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cambios solo en este dispositivo',
      one: '1 cambio solo en este dispositivo',
    );
    return '$_temp0';
  }

  @override
  String logsSyncPendingSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sincroniza para guardarlos en tu Cuenta',
      one: 'Sincroniza para guardarlo en tu Cuenta',
    );
    return '$_temp0';
  }

  @override
  String get logsSyncSyncingTitle => 'Sincronizando…';

  @override
  String logsSyncSyncingSubtitle(int savedCount, int changeCount) {
    return '$savedCount de $changeCount cambios guardados';
  }

  @override
  String get logsSyncSyncedTitle => 'Sincronizado ahora mismo';

  @override
  String logsSyncSyncedSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cambios guardados en tu Cuenta',
      one: '1 cambio guardado en tu Cuenta',
    );
    return '$_temp0';
  }

  @override
  String logsSyncPartialTitle(int savedCount, int changeCount) {
    return '$savedCount de $changeCount cambios sincronizados';
  }

  @override
  String logsSyncPartialSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cambios se reintentarán en la próxima sincronización',
      one: '1 cambio se reintentará en la próxima sincronización',
    );
    return '$_temp0';
  }

  @override
  String get logsSyncOfflineTitle => 'Sin conexión';

  @override
  String logsSyncOfflineSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count cambios están a salvo en este dispositivo. Sincroniza cuando vuelvas a tener conexión.',
      one: '1 cambio está a salvo en este dispositivo. Sincroniza cuando vuelvas a tener conexión.',
    );
    return '$_temp0';
  }

  @override
  String get logsSyncFailedTitle => 'No se pudo sincronizar';

  @override
  String logsSyncFailedSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count cambios están a salvo en este dispositivo. Inténtalo más tarde.',
      one: '1 cambio está a salvo en este dispositivo. Inténtalo más tarde.',
    );
    return '$_temp0';
  }

  @override
  String get logsSyncAlreadyUpToDateTitle => 'Ya está todo al día';

  @override
  String get logsSyncAlreadyUpToDateSubtitle => 'Nada que sincronizar';

  @override
  String logsSyncDownloadingTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Obteniendo $count entradas de tu Cuenta…',
      one: 'Obteniendo 1 entrada de tu Cuenta…',
    );
    return '$_temp0';
  }

  @override
  String get logsSyncDownloadingSubtitle => 'Puedes seguir trabajando';

  @override
  String logsSyncDownloadedTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entradas añadidas desde tu Cuenta',
      one: '1 entrada añadida desde tu Cuenta',
    );
    return '$_temp0';
  }

  @override
  String logsSyncDownloadedSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se crearon en otro dispositivo',
      one: 'Se creó en otro dispositivo',
    );
    return '$_temp0';
  }

  @override
  String get commonRetryAction => 'Reintentar';

  @override
  String get logsSyncAction => 'Sincronizar';

  @override
  String get logsLoadFailedMessage =>
      'No se pudieron cargar los registros ahora mismo.';

  @override
  String get logsSyncInProgressAction => 'Sincronizando';

  @override
  String get logsUnsyncedCreated => 'Nueva';

  @override
  String get logsUnsyncedUpdated => 'Editada';
}
