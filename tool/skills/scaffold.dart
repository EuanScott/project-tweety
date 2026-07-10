import 'dart:io';

import 'scaffold/scaffold.cli.dart';

Future<void> main(List<String> arguments) async {
  exitCode = await ScaffoldCli().run(arguments);
}
