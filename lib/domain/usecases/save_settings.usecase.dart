import 'package:injectable/injectable.dart';
import 'package:project_tweety/domain/entities/settings.entity.dart';
import 'package:project_tweety/domain/repositories/settings.repository.dart';

@injectable
class SaveSettingsUseCase {
  const SaveSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  Future<void> call(Settings settings) {
    return _repository.saveSettings(settings);
  }
}
