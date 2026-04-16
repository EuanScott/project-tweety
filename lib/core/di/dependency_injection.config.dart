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

import '../../data/datasources/mock_cards_data_source.dart' as _i898;
import '../../data/repositories/cards_repository_impl.dart' as _i443;
import '../../domain/repositories/cards_repository.dart' as _i118;
import '../../domain/usecases/get_cards_usecase.dart' as _i68;
import '../../presentation/pages/cards/bloc/cards_bloc.dart' as _i658;
import '../../presentation/pages/home/bloc/home_bloc.dart' as _i558;
import '../analytics/analytics_facade.dart' as _i541;
import '../analytics/analytics_service.dart' as _i726;
import '../error_reporting/error_reporting_facade.dart' as _i802;
import '../error_reporting/error_reporting_service.dart' as _i981;
import '../feature_flags/feature_flag_service.dart' as _i349;
import 'di_init_service.dart' as _i1027;

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
    gh.singleton<_i1027.DiInitService>(() => _i1027.DiInitService());
    gh.lazySingleton<_i898.MockCardsDataSource>(
      () => _i898.MockCardsDataSource(),
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
    gh.lazySingleton<Iterable<_i981.ErrorReportingService>>(
      () => errorReportingModule.errorReportingServices(
        gh<_i981.ErrorReportingService>(instanceName: 'crashlytics'),
        gh<_i981.ErrorReportingService>(instanceName: 'coralogix'),
      ),
    );
    gh.lazySingleton<_i118.CardsRepository>(
      () => _i443.CardsRepositoryImpl(gh<_i898.MockCardsDataSource>()),
    );
    gh.lazySingleton<Iterable<_i726.AnalyticsService>>(
      () => analyticsModule.analyticsServices(gh<_i726.AnalyticsService>()),
    );
    gh.factory<_i68.GetCardsUseCase>(
      () => _i68.GetCardsUseCase(gh<_i118.CardsRepository>()),
    );
    gh.lazySingleton<_i802.ErrorReportingFacade>(
      () => _i802.ErrorReportingFacade(
        gh<Iterable<_i981.ErrorReportingService>>(),
      ),
    );
    gh.factory<_i658.CardsBloc>(
      () => _i658.CardsBloc(gh<_i68.GetCardsUseCase>()),
    );
    gh.lazySingleton<_i541.AnalyticsFacade>(
      () => _i541.AnalyticsFacade(gh<Iterable<_i726.AnalyticsService>>()),
    );
    gh.factory<_i558.HomeBloc>(
      () => _i558.HomeBloc(gh<_i802.ErrorReportingFacade>()),
    );
    return this;
  }
}

class _$ErrorReportingModule extends _i802.ErrorReportingModule {}

class _$AnalyticsModule extends _i541.AnalyticsModule {}
