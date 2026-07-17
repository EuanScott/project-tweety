import 'package:injectable/injectable.dart';

import '_template.repository.dart';

@LazySingleton(as: TemplateRepository)
class TemplateRepositoryImpl implements TemplateRepository {
  const TemplateRepositoryImpl();

  @override
  Future<void> fetchTemplate() async {}
}
