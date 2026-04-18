import 'package:injectable/injectable.dart';
import 'package:project_tweety/domain/entities/settings.entity.dart';
import 'package:project_tweety/domain/repositories/settings.repository.dart';

@injectable
class GetSettingsUseCase {
  const GetSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  Future<Settings> call() {
    return _repository.getSettings();
  }
}
