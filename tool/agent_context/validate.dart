import 'dart:io';

import 'context.validator.dart';

void main() {
  final result = ContextValidator(repositoryRoot: Directory.current).validate();
  if (result.isValid) {
    stdout.writeln('Agent context validation passed.');
    return;
  }

  for (final diagnostic in result.diagnostics) {
    stdout.writeln(
      '${diagnostic.path} [${diagnostic.code}] ${diagnostic.message}',
    );
  }
  exitCode = 1;
}
