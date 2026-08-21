import 'package:get_it/get_it.dart';
import 'package:project_tweety/domain/entities/app_preferences/app_preferences.entity.dart';
import 'package:project_tweety/domain/repositories/app_preferences/app_preferences.repository.dart';

/// In-memory [AppPreferencesRepository] that records every save.
class FakeAppPreferencesRepository implements AppPreferencesRepository {
  new([
    AppPreferences currentPreferences = const AppPreferences(),
  ]) : _currentPreferences = currentPreferences;

  AppPreferences _currentPreferences;
  final List<AppPreferences> savedPreferences = <AppPreferences>[];

  @override
  Future<AppPreferences> getAppPreferences() async => _currentPreferences;

  @override
  Future<void> saveAppPreferences(AppPreferences appPreferences) async {
    _currentPreferences = appPreferences;
    savedPreferences.add(appPreferences);
  }
}

/// Swaps the registered [AppPreferencesRepository] for [repository].
void replaceAppPreferencesRepository(AppPreferencesRepository repository) {
  GetIt.I
    // GetIt.unregister returns FutureOr and completes synchronously here:
    // the fakes register no async disposers, so there is no future to await.
    // ignore: discarded_futures
    ..unregister<AppPreferencesRepository>()
    ..registerLazySingleton<AppPreferencesRepository>(() => repository);
}
