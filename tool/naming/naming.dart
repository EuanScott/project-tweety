import 'dart:io';

import 'naming.validator.dart';

void main(List<String> arguments) {
  if (arguments.singleOrNull != 'check') {
    stderr.writeln('Usage: dart run tool/naming/naming.dart check');
    exitCode = 64;
    return;
  }
  final indexed = Process.runSync('git', [
    'ls-files',
    '--cached',
    '--',
    '*.dart',
  ]);
  if (indexed.exitCode != 0) {
    stderr.write(indexed.stderr);
    exitCode = 1;
    return;
  }
  final paths = (indexed.stdout as String)
      .split('\n')
      .where((path) => path.isNotEmpty);
  final result = NamingValidator(
    repositoryRoot: Directory.current,
  ).validate(paths);
  if (result.isValid) {
    stdout.writeln('File naming validation passed.');
    return;
  }
  for (final diagnostic in result.diagnostics) {
    stdout.writeln(
      '${diagnostic.path} [${diagnostic.code}] ${diagnostic.message}',
    );
  }
  exitCode = 1;
}
