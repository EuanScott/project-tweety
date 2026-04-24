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

import '../../data/datasources/app_preferences/app_preferences_local.datasource.dart'
    as _i805;
import '../../data/datasources/card/card.mock.dart' as _i295;
import '../../data/repositories/app_preferences/app_preferences.repository_impl.dart'
    as _i298;
import '../../data/repositories/card/cards.repository_impl.dart' as _i461;
import '../../domain/repositories/app_preferences/app_preferences.repository.dart'
    as _i355;
import '../../domain/repositories/card/card.repository.dart' as _i174;
import '../../domain/usecases/app_preferences/get_app_preferences.usecase.dart'
    as _i473;
import '../../domain/usecases/app_preferences/save_app_preferences.usecase.dart'
    as _i76;
import '../../domain/usecases/card/create_card.usecase.dart' as _i111;
import '../../domain/usecases/card/delete_card.usecase.dart' as _i174;
import '../../domain/usecases/card/get_card.usecase.dart' as _i275;
import '../../domain/usecases/card/update_card.usecase.dart' as _i811;
import '../../presentation/pages/app_preferences/cubit/app_preferences.cubit.dart'
    as _i889;
import '../../presentation/pages/cards/bloc/cards.bloc.dart' as _i152;
import '../../presentation/pages/home/bloc/home_bloc.dart' as _i558;
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
    gh.lazySingleton<_i295.MockCardsDataSource>(
      () => _i295.MockCardsDataSource(),
    );
    gh.lazySingleton<_i981.ErrorReportingService>(
      () => _i981.FirebaseErrorReportingService(),
      instanceName: 'crashlytics',
    );
    gh.lazySingleton<_i981.ErrorReportingService>(
      () => _i981.CoralogixErrorReportingService(),
      instanceName: 'coralogix',
    );
    gh.lazySingleton<_i726.AnalyticsService>(
      () => _i726.FirebaseAnalyticsService(),
    );
    gh.singleton<_i1027.DiInitService>(
      () => _i1027.DiInitService(gh<_i379.AppPreferencesStorage>()),
    );
    gh.lazySingleton<_i805.AppPreferencesLocalDataSource>(
      () => _i805.AppPreferencesLocalDataSource(
        gh<_i379.AppPreferencesStorage>(),
      ),
    );
    gh.lazySingleton<_i355.AppPreferencesRepository>(
      () => _i298.AppPreferencesRepositoryImpl(
        gh<_i805.AppPreferencesLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i174.CardsRepository>(
      () => _i461.CardsRepositoryImpl(gh<_i295.MockCardsDataSource>()),
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
    gh.factory<_i473.GetAppPreferencesUseCase>(
      () =>
          _i473.GetAppPreferencesUseCase(gh<_i355.AppPreferencesRepository>()),
    );
    gh.factory<_i76.SaveAppPreferencesUseCase>(
      () =>
          _i76.SaveAppPreferencesUseCase(gh<_i355.AppPreferencesRepository>()),
    );
    gh.factory<_i111.CreateCardUseCase>(
      () => _i111.CreateCardUseCase(gh<_i174.CardsRepository>()),
    );
    gh.factory<_i174.DeleteCardUseCase>(
      () => _i174.DeleteCardUseCase(gh<_i174.CardsRepository>()),
    );
    gh.factory<_i275.GetCardsUseCase>(
      () => _i275.GetCardsUseCase(gh<_i174.CardsRepository>()),
    );
    gh.factory<_i275.GetCardByIdUseCase>(
      () => _i275.GetCardByIdUseCase(gh<_i174.CardsRepository>()),
    );
    gh.factory<_i811.UpdateCardUseCase>(
      () => _i811.UpdateCardUseCase(gh<_i174.CardsRepository>()),
    );
    gh.lazySingleton<_i541.AnalyticsFacade>(
      () => _i541.AnalyticsFacade(gh<Iterable<_i726.AnalyticsService>>()),
    );
    gh.factory<_i889.AppPreferencesCubit>(
      () => _i889.AppPreferencesCubit(
        gh<_i473.GetAppPreferencesUseCase>(),
        gh<_i76.SaveAppPreferencesUseCase>(),
      ),
    );
    gh.factory<_i558.HomeBloc>(
      () => _i558.HomeBloc(gh<_i802.ErrorReportingFacade>()),
    );
    gh.factory<_i152.CardsBloc>(
      () => _i152.CardsBloc(gh<_i275.GetCardsUseCase>()),
    );
    return this;
  }
}

class _$ErrorReportingModule extends _i802.ErrorReportingModule {}

class _$AnalyticsModule extends _i541.AnalyticsModule {}
