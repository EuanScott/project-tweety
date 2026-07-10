import 'dart:convert';
import 'dart:io';

import 'skill.validator.dart';

void main(List<String> arguments) {
  exitCode = runSkillValidationCli(arguments);
}

/// Runs the skill validator CLI and returns the process exit status.
int runSkillValidationCli(
  List<String> arguments, {
  Directory? repositoryRoot,
  StringSink? output,
}) {
  final sink = output ?? stdout;
  final result = SkillValidator(
    repositoryRoot: repositoryRoot ?? Directory.current,
  ).validate();

  if (arguments.contains('--json')) {
    sink.writeln(jsonEncode(result.toJson()));
  } else if (result.isValid) {
    sink.writeln('Skill validation passed.');
  } else {
    for (final diagnostic in result.diagnostics) {
      sink.writeln(
        '${diagnostic.path} [${diagnostic.code}] ${diagnostic.message}',
      );
    }
    sink.writeln(
      'Skill validation failed with ${result.diagnostics.length} '
      'diagnostic(s).',
    );
  }

  return result.isValid ? 0 : 1;
}
