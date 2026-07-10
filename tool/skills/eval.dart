import 'dart:io';

import 'eval/eval.cli.dart';

Future<void> main(List<String> arguments) async {
  exitCode = await EvalCli().run(arguments);
}
