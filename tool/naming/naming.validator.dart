import 'dart:io';

import 'package:path/path.dart' as p;

const _agentsPath = 'AGENTS.md';
const _rolesStart = '<!-- naming-roles:start -->';
const _rolesEnd = '<!-- naming-roles:end -->';
const _testSuffix = '_test';
const _toolingLabel = 'Tooling roles';
const _testLabel = 'Test role';
const _scopedDirectories = <String>['lib', 'test', 'integration_test', 'tool'];
const _generatedSuffixes = <String>['.g.dart', '.freezed.dart', '.config.dart'];
const _localizationPrefix = 'lib/l10n/app_localizations';
const _testSupportDirectory = 'test/support';
const _bootstrapFiles = <String>{
  'lib/dart_init.dart',
  'lib/core/di/dependency_injection.dart',
};
final _topLevelMain = RegExp(
  r'^(?:[\w<>?, ]+\s)?main\s*\(',
  multiLine: true,
);

final class NamingDiagnostic {
  const new({
    required this.code,
    required this.message,
    required this.path,
  });

  final String code;
  final String message;
  final String path;
}

final class NamingValidationResult {
  const new(this.diagnostics);

  final List<NamingDiagnostic> diagnostics;

  bool get isValid => diagnostics.isEmpty;
}

typedef _Roles = ({
  Set<String> general,
  Set<String> tooling,
  Set<String> test,
});

final class NamingValidator {
  const new({required this.repositoryRoot});

  final Directory repositoryRoot;

  NamingValidationResult validate(Iterable<String> paths) {
    final roles = _readRoles();
    if (roles == null) {
      return const NamingValidationResult([
        NamingDiagnostic(
          code: 'naming.roles.missing',
          message:
              '$_agentsPath has no role list between $_rolesStart and '
              '$_rolesEnd.',
          path: _agentsPath,
        ),
      ]);
    }
    final missingGroups = [
      if (roles.tooling.isEmpty) _toolingLabel,
      if (roles.test.isEmpty) _testLabel,
    ];
    if (missingGroups.isNotEmpty) {
      return NamingValidationResult([
        for (final label in missingGroups)
          NamingDiagnostic(
            code: 'naming.roles.group_missing',
            message:
                '$_agentsPath role list has no "- $label" line, or it lists '
                'no roles.',
            path: _agentsPath,
          ),
      ]);
    }
    return NamingValidationResult([
      for (final path in paths) ?_checkPath(path, roles),
    ]);
  }

  NamingDiagnostic? _checkPath(String path, _Roles roles) {
    if (!_scopedDirectories.any((directory) => p.isWithin(directory, path)) ||
        _isExempt(path)) {
      return null;
    }
    final fullStem = p.basenameWithoutExtension(path);
    final isTest = fullStem.endsWith(_testSuffix);
    final stem = isTest
        ? fullStem.substring(0, fullStem.length - _testSuffix.length)
        : fullStem;
    if (!stem.contains('.')) {
      if (isTest ? _mirrorsBootstrap(path) : _declaresMain(path)) {
        return null;
      }
      return _diagnostic(path, 'naming.role.missing', 'File name has no role.');
    }
    if (stem.indexOf('.') != stem.lastIndexOf('.')) {
      return _diagnostic(
        path,
        'naming.name.dotted',
        'Business name contains a dot. Use _ inside the name.',
      );
    }
    final role = stem.substring(stem.lastIndexOf('.') + 1);
    if (roles.test.contains(role)) {
      return isTest
          ? null
          : _diagnostic(
              path,
              'naming.role.test_only',
              'Role .$role is allowed only before _test.',
            );
    }
    if (roles.tooling.contains(role)) {
      return p.isWithin(isTest ? 'test/tool' : 'tool', path)
          ? null
          : _diagnostic(
              path,
              'naming.role.tool_only',
              'Role .$role is allowed only under tool/ and test/tool/.',
            );
    }
    if (!roles.general.contains(role)) {
      return _diagnostic(
        path,
        'naming.role.unknown',
        'Role .$role is not listed in $_agentsPath.',
      );
    }
    return null;
  }

  NamingDiagnostic _diagnostic(String path, String code, String problem) {
    return NamingDiagnostic(
      code: code,
      message:
          '$problem Expected feature_or_entity.role.dart with a role from '
          '$_agentsPath.',
      path: path,
    );
  }

  bool _mirrorsBootstrap(String path) {
    return _bootstrapFiles.any(
      (bootstrap) =>
          path ==
          p.posix.join(
            'test',
            p.posix
                .relative(bootstrap, from: 'lib')
                .replaceFirst(
                  RegExp(r'\.dart$'),
                  '_test.dart',
                ),
          ),
    );
  }

  bool _declaresMain(String path) {
    final file = File(p.join(repositoryRoot.path, path));
    return file.existsSync() && _topLevelMain.hasMatch(file.readAsStringSync());
  }

  bool _isExempt(String path) {
    return _generatedSuffixes.any(path.endsWith) ||
        path.startsWith(_localizationPrefix) ||
        _bootstrapFiles.contains(path) ||
        p.isWithin(_testSupportDirectory, path);
  }

  _Roles? _readRoles() {
    final contents = File(
      p.join(repositoryRoot.path, _agentsPath),
    ).readAsStringSync();
    final start = contents.indexOf(_rolesStart);
    final end = contents.indexOf(_rolesEnd);
    if (start < 0 || end < start) {
      return null;
    }
    final general = <String>{};
    final tooling = <String>{};
    final test = <String>{};
    for (final line in contents.substring(start, end).split('\n')) {
      final roles = RegExp(
        r'`\.(\w+)`',
      ).allMatches(line).map((match) => match.group(1)!);
      final label = line.trimLeft();
      if (label.startsWith('- $_toolingLabel')) {
        tooling.addAll(roles);
      } else if (label.startsWith('- $_testLabel')) {
        test.addAll(roles);
      } else {
        general.addAll(roles);
      }
    }
    return (general: general, tooling: tooling, test: test);
  }
}
