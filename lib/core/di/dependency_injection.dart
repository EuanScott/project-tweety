import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'di.config.dart';

@InjectableInit(preferRelativeImports: true)
Future<void> configureCoreDependencies() async => GetIt.I.init();
