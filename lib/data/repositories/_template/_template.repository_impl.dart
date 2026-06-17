import 'package:injectable/injectable.dart';
import 'package:project_tweety/domain/repositories/_template/_template.repository.dart';

@LazySingleton(as: TemplateRepository)
class TemplateRepositoryImpl implements TemplateRepository {
  const TemplateRepositoryImpl();

  @override
  Future<void> fetchTemplate() async {}
}
