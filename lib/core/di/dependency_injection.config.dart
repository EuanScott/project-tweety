// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../data/datasources/card.mock.dart' as _i905;
import '../../data/datasources/settings_local.datasource.dart' as _i167;
import '../../data/repositories/cards.repository_impl.dart' as _i939;
import '../../data/repositories/settings.repository_impl.dart' as _i104;
import '../../domain/repositories/card.repository.dart' as _i518;
import '../../domain/repositories/settings.repository.dart' as _i555;
import '../../domain/usecases/create_card.usecase.dart' as _i279;
import '../../domain/usecases/delete_card.usecase.dart' as _i738;
import '../../domain/usecases/get_card.usecase.dart' as _i670;
import '../../domain/usecases/get_settings.usecase.dart' as _i304;
import '../../domain/usecases/save_settings.usecase.dart' as _i810;
import '../../domain/usecases/update_card.usecase.dart' as _i729;
import '../../presentation/pages/cards/bloc/cards.bloc.dart' as _i152;
import '../../presentation/pages/home/bloc/home_bloc.dart' as _i558;
import '../../presentation/pages/settings/bloc/settings.cubit.dart' as _i94;
import '../analytics/analytics_facade.dart' as _i541;
import '../analytics/analytics_service.dart' as _i726;
import '../error_reporting/error_reporting_facade.dart' as _i802;
import '../error_reporting/error_reporting_service.dart' as _i981;
import '../feature_flags/feature_flag_service.dart' as _i349;
import '../storage/app_preferences.storage.dart' as _i379;
import 'di_init.service.dart' as _i1027;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final errorReportingModule = _$ErrorReportingModule();
    final analyticsModule = _$AnalyticsModule();
    gh.factory<_i349.FeatureFlagService>(() => _i349.FeatureFlagService());
    gh.lazySingleton<_i379.AppPreferencesStorage>(
      () => _i379.AppPreferencesStorage(),
    );
    gh.lazySingleton<_i905.MockCardsDataSource>(
      () => _i905.MockCardsDataSource(),
    );
    gh.lazySingleton<_i981.ErrorReportingService>(
      () => _i981.FirebaseErrorReportingService(),
      instanceName: 'crashlytics',
    );
    gh.lazySingleton<_i981.ErrorReportingService>(
      () => _i981.CoralogixErrorReportingService(),
      instanceName: 'coralogix',
    );
    gh.lazySingleton<_i518.CardsRepository>(
      () => _i939.CardsRepositoryImpl(gh<_i905.MockCardsDataSource>()),
    );
    gh.factory<_i279.CreateCardUseCase>(
      () => _i279.CreateCardUseCase(gh<_i518.CardsRepository>()),
    );
    gh.factory<_i738.DeleteCardUseCase>(
      () => _i738.DeleteCardUseCase(gh<_i518.CardsRepository>()),
    );
    gh.factory<_i670.GetCardsUseCase>(
      () => _i670.GetCardsUseCase(gh<_i518.CardsRepository>()),
    );
    gh.factory<_i670.GetCardByIdUseCase>(
      () => _i670.GetCardByIdUseCase(gh<_i518.CardsRepository>()),
    );
    gh.factory<_i729.UpdateCardUseCase>(
      () => _i729.UpdateCardUseCase(gh<_i518.CardsRepository>()),
    );
    gh.lazySingleton<_i726.AnalyticsService>(
      () => _i726.FirebaseAnalyticsService(),
    );
    gh.factory<_i152.CardsBloc>(
      () => _i152.CardsBloc(gh<_i670.GetCardsUseCase>()),
    );
    gh.singleton<_i1027.DiInitService>(
      () => _i1027.DiInitService(gh<_i379.AppPreferencesStorage>()),
    );
    gh.lazySingleton<_i167.SettingsLocalDataSource>(
      () => _i167.SettingsLocalDataSource(gh<_i379.AppPreferencesStorage>()),
    );
    gh.lazySingleton<Iterable<_i981.ErrorReportingService>>(
      () => errorReportingModule.errorReportingServices(
        gh<_i981.ErrorReportingService>(instanceName: 'crashlytics'),
        gh<_i981.ErrorReportingService>(instanceName: 'coralogix'),
      ),
    );
    gh.lazySingleton<Iterable<_i726.AnalyticsService>>(
      () => analyticsModule.analyticsServices(gh<_i726.AnalyticsService>()),
    );
    gh.lazySingleton<_i802.ErrorReportingFacade>(
      () => _i802.ErrorReportingFacade(
        gh<Iterable<_i981.ErrorReportingService>>(),
      ),
    );
    gh.lazySingleton<_i555.SettingsRepository>(
      () => _i104.SettingsRepositoryImpl(gh<_i167.SettingsLocalDataSource>()),
    );
    gh.lazySingleton<_i541.AnalyticsFacade>(
      () => _i541.AnalyticsFacade(gh<Iterable<_i726.AnalyticsService>>()),
    );
    gh.factory<_i558.HomeBloc>(
      () => _i558.HomeBloc(gh<_i802.ErrorReportingFacade>()),
    );
    gh.factory<_i304.GetSettingsUseCase>(
      () => _i304.GetSettingsUseCase(gh<_i555.SettingsRepository>()),
    );
    gh.factory<_i810.SaveSettingsUseCase>(
      () => _i810.SaveSettingsUseCase(gh<_i555.SettingsRepository>()),
    );
    gh.factory<_i94.SettingsCubit>(
      () => _i94.SettingsCubit(
        gh<_i304.GetSettingsUseCase>(),
        gh<_i810.SaveSettingsUseCase>(),
      ),
    );
    return this;
  }
}

class _$ErrorReportingModule extends _i802.ErrorReportingModule {}

class _$AnalyticsModule extends _i541.AnalyticsModule {}
