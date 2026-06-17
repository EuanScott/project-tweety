import 'package:injectable/injectable.dart';
import 'package:project_tweety/domain/repositories/_template/_template.repository.dart';

@injectable
class FetchTemplateUseCase {
  const FetchTemplateUseCase(this._repository);

  final TemplateRepository _repository;

  Future<void> call() {
    return _repository.fetchTemplate();
  }
}
