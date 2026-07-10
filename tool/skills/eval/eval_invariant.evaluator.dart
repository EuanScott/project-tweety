import 'eval.manifest.dart';

final class InvariantContext {
  const InvariantContext({
    required this.exitCode,
    required this.gitDiff,
    required this.finalOutput,
    required this.commands,
    required this.toolCalls,
  });

  final int exitCode;
  final String gitDiff;
  final String finalOutput;
  final List<String> commands;
  final int toolCalls;
}

final class InvariantResult {
  const InvariantResult({
    required this.id,
    required this.kind,
    required this.passed,
    required this.message,
  });

  final String id;
  final String kind;
  final bool passed;
  final String message;

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind,
    'passed': passed,
    'message': message,
  };
}

final class InvariantEvaluator {
  const InvariantEvaluator();

  InvariantResult evaluate(EvalInvariant invariant, InvariantContext context) {
    final configuration = invariant.configuration;
    final (passed, message) = switch (invariant.kind) {
      'exit_code' => _equals(
        context.exitCode,
        configuration['value'],
        'exit code',
      ),
      'git_diff_empty' => (
        context.gitDiff.trim().isEmpty,
        context.gitDiff.trim().isEmpty
            ? 'Git diff is empty.'
            : 'Git diff is not empty.',
      ),
      'output_contains' => _contains(
        context.finalOutput,
        configuration['value'],
        shouldContain: true,
      ),
      'output_contains_any' => _containsAny(
        context.finalOutput,
        configuration['values'],
      ),
      'output_excludes' => _contains(
        context.finalOutput,
        configuration['value'],
        shouldContain: false,
      ),
      'git_diff_contains' => _contains(
        context.gitDiff,
        configuration['value'],
        shouldContain: true,
      ),
      'git_diff_excludes' => _contains(
        context.gitDiff,
        configuration['value'],
        shouldContain: false,
      ),
      'max_tool_calls' => _maximum(
        context.toolCalls,
        configuration['value'],
        'tool calls',
      ),
      'no_commands_matching' => _noCommandsMatching(
        context.commands,
        configuration['values'],
      ),
      _ => (false, 'Unsupported invariant kind "${invariant.kind}".'),
    };
    return InvariantResult(
      id: invariant.id,
      kind: invariant.kind,
      passed: passed,
      message: message,
    );
  }

  static (bool, String) _equals(Object? actual, Object? expected, String name) {
    final passed = actual == expected;
    return (passed, '$name was $actual; expected $expected.');
  }

  static (bool, String) _contains(
    String haystack,
    Object? rawNeedle, {
    required bool shouldContain,
  }) {
    if (rawNeedle is! String) {
      return (false, 'Invariant value must be a string.');
    }
    final contains = haystack.toLowerCase().contains(rawNeedle.toLowerCase());
    final passed = shouldContain ? contains : !contains;
    return (
      passed,
      '${shouldContain ? 'Expected' : 'Did not expect'} "$rawNeedle".',
    );
  }

  static (bool, String) _containsAny(String haystack, Object? rawNeedles) {
    if (rawNeedles is! List || rawNeedles.whereType<String>().isEmpty) {
      return (false, 'Invariant values must contain strings.');
    }
    final needles = rawNeedles.whereType<String>().toList(growable: false);
    final lowerHaystack = haystack.toLowerCase();
    final passed = needles.any(
      (needle) => lowerHaystack.contains(needle.toLowerCase()),
    );
    return (passed, 'Expected one of ${needles.join(', ')}.');
  }

  static (bool, String) _maximum(
    Object actual,
    Object? rawMaximum,
    String name,
  ) {
    if (actual is! num || rawMaximum is! num) {
      return (false, 'Maximum invariant requires numeric values.');
    }
    return (actual <= rawMaximum, '$name was $actual; maximum is $rawMaximum.');
  }

  static (bool, String) _noCommandsMatching(
    List<String> commands,
    Object? rawPatterns,
  ) {
    if (rawPatterns is! List || rawPatterns.whereType<String>().isEmpty) {
      return (false, 'Invariant values must contain command fragments.');
    }
    final patterns = rawPatterns.whereType<String>().toList(growable: false);
    final match = commands.where((command) {
      final lowerCommand = command.toLowerCase();
      return patterns.any(
        (pattern) => lowerCommand.contains(pattern.toLowerCase()),
      );
    }).firstOrNull;
    return (
      match == null,
      match == null ? 'No forbidden command ran.' : 'Forbidden command: $match',
    );
  }
}
