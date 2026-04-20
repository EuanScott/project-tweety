import 'package:injectable/injectable.dart';
import 'package:project_tweety/domain/entities/app_preferences/app_preferences.entity.dart';
import 'package:project_tweety/domain/repositories/app_preferences/app_preferences.repository.dart';

@injectable
class SaveAppPreferencesUseCase {
  const SaveAppPreferencesUseCase(this._repository);

  final AppPreferencesRepository _repository;

  Future<void> call(AppPreferences appPreferences) {
    return _repository.saveAppPreferences(appPreferences);
  }
}
