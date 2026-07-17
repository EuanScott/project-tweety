import 'dart:io';

import 'adr.validator.dart';

void main(List<String> arguments) {
  final validator = AdrValidator(repositoryRoot: Directory.current);
  switch (arguments.singleOrNull) {
    case 'check':
      final result = validator.validate();
      if (result.isValid) {
        stdout.writeln('ADR validation passed.');
        return;
      }
      for (final diagnostic in result.diagnostics) {
        stdout.writeln(
          '${diagnostic.path} [${diagnostic.code}] ${diagnostic.message}',
        );
      }
      exitCode = 1;
    case 'generate-index':
      validator.writeCatalog();
      stdout.writeln('ADR catalog generated.');
    default:
      stderr.writeln(
        'Usage: dart run tool/decisions/adr.dart <check|generate-index>',
      );
      exitCode = 64;
  }
}
