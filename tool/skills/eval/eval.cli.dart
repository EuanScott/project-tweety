import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'codex.events.dart';
import 'eval.comparator.dart';
import 'eval.manifest.dart';
import 'eval_invariant.evaluator.dart';
import 'process.executor.dart';

final class EvalCli {
  EvalCli({
    ProcessExecutor? processExecutor,
    void Function(String)? writeLine,
    DateTime Function()? now,
  }) : _processExecutor = processExecutor ?? SystemProcessExecutor(),
       _writeLine = writeLine ?? stdout.writeln,
       _now = now ?? DateTime.now;

  final ProcessExecutor _processExecutor;
  final void Function(String) _writeLine;
  final DateTime Function() _now;

  Future<int> run(List<String> arguments) async {
    if (arguments.isEmpty) {
      _writeLine(_usage);
      return 64;
    }
    try {
      return switch (arguments.first) {
        'run' => await _runCases(
          _ParsedOptions.parse(
            arguments.skip(1).toList(),
            supported: const {
              '--label',
              '--case',
              '--replicas',
              '--manifest',
              '--workspace',
              '--output',
            },
          ),
        ),
        'compare' => _compare(
          _ParsedOptions.parse(
            arguments.skip(1).toList(),
            supported: const {'--baseline', '--candidate'},
          ),
        ),
        _ => throw FormatException('Unknown command "${arguments.first}".'),
      };
    } on FormatException catch (error) {
      _writeLine('Error: ${error.message}\n\n$_usage');
      return 64;
    } on FileSystemException catch (error) {
      _writeLine('Error: ${error.message}');
      return 74;
    }
  }

  int _compare(_ParsedOptions options) {
    final outcome = const EvalComparator().compare(
      baselinePath: options.requireValue('--baseline'),
      candidatePath: options.requireValue('--candidate'),
    );
    _writeLine('Comparison artifact: ${outcome.outputFile.path}');
    return outcome.hasRegressions ? 1 : 0;
  }

  Future<int> _runCases(_ParsedOptions options) async {
    final label = options.requireValue('--label');
    final sourceWorkspace = Directory(
      options.value('--workspace') ?? Directory.current.path,
    ).absolute;
    if (!sourceWorkspace.existsSync()) {
      throw FormatException(
        'Workspace does not exist: ${sourceWorkspace.path}',
      );
    }
    final manifestFile = File(
      options.value('--manifest') ?? 'tool/skills/eval_cases.json',
    ).absolute;
    if (!manifestFile.existsSync()) {
      throw FormatException('Manifest does not exist: ${manifestFile.path}');
    }
    final manifest = EvalManifest.read(manifestFile);
    final selectedId = options.value('--case');
    final selectedCases = selectedId == null
        ? manifest.cases
        : manifest.cases
              .where((evalCase) => evalCase.id == selectedId)
              .toList();
    if (selectedCases.isEmpty) {
      throw FormatException('Unknown case "$selectedId".');
    }
    final replicaOverride = options.positiveInt('--replicas');
    final outputDirectory = _createOutputDirectory(
      sourceWorkspace: sourceWorkspace,
      requestedPath: options.value('--output'),
      label: label,
    );
    final startedAt = _now().toUtc();
    final cliVersionResult = await _processExecutor.run(
      ProcessRequest(
        executable: 'codex',
        arguments: const ['--version'],
        workingDirectory: sourceWorkspace.path,
      ),
    );
    final cliVersion = cliVersionResult.exitCode == 0
        ? cliVersionResult.stdout.trim()
        : null;
    final runs = <Map<String, dynamic>>[];

    for (final evalCase in selectedCases) {
      final tier = manifest.tiers[evalCase.tier]!;
      final replicas = replicaOverride ?? tier.defaultReplicas;
      for (var replica = 1; replica <= replicas; replica += 1) {
        runs.add(
          await _runCase(
            label: label,
            evalCase: evalCase,
            replica: replica,
            sourceWorkspace: sourceWorkspace,
            outputDirectory: outputDirectory,
            cliVersion: cliVersion,
            timeout: evalCase.timeout ?? tier.timeout,
          ),
        );
      }
    }

    final summary = {
      'schemaVersion': 1,
      'label': label,
      'manifest': manifestFile.path,
      'sourceWorkspace': sourceWorkspace.path,
      'outputDirectory': outputDirectory.path,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': _now().toUtc().toIso8601String(),
      if (cliVersion != null) 'cliVersion': cliVersion,
      'tiers': manifest.tiers.map(
        (name, tier) => MapEntry(name, tier.toJson()),
      ),
      'runs': runs,
    };
    _writeJson(File(p.join(outputDirectory.path, 'run_summary.json')), summary);
    _writeLine('Evaluation artifacts: ${outputDirectory.path}');
    return runs.every((run) => run['passed'] == true) ? 0 : 1;
  }

  Future<Map<String, dynamic>> _runCase({
    required String label,
    required EvalCase evalCase,
    required int replica,
    required Directory sourceWorkspace,
    required Directory outputDirectory,
    required String? cliVersion,
    required Duration timeout,
  }) async {
    final caseDirectory = Directory(
      p.join(
        outputDirectory.path,
        'cases',
        _safeSegment(evalCase.id),
        'replica-$replica',
      ),
    )..createSync(recursive: true);
    final disposableWorkspace = Directory.systemTemp.createTempSync(
      'project-tweety-skill-eval-workspace-',
    );
    try {
      _copyWorkspace(sourceWorkspace, disposableWorkspace);
      await _initializeGit(disposableWorkspace);
      final startedAt = _now().toUtc();
      final stopwatch = Stopwatch()..start();
      final codexResult = await _processExecutor.run(
        ProcessRequest(
          executable: 'codex',
          arguments: const [
            'exec',
            '--ephemeral',
            '--json',
            '--sandbox',
            'workspace-write',
            '-',
          ],
          workingDirectory: disposableWorkspace.path,
          standardInput: evalCase.prompt,
          timeout: timeout,
        ),
      );
      stopwatch.stop();
      final stageResult = await _runGit(disposableWorkspace, const [
        'add',
        '--all',
      ]);
      final diffResult = await _runGit(disposableWorkspace, const [
        'diff',
        '--binary',
        'HEAD',
        '--',
      ]);
      final eventSummary = CodexEventSummary.parse(codexResult.stdout);
      final harnessErrors = <String>[
        ...eventSummary.harnessErrors,
        if (codexResult.timedOut)
          'Codex timed out after ${_formatDuration(timeout)}.',
        if (stageResult.exitCode != 0)
          'git add failed (${stageResult.exitCode}): ${stageResult.stderr.trim()}',
        if (diffResult.exitCode != 0)
          'git diff failed (${diffResult.exitCode}): ${diffResult.stderr.trim()}',
      ];
      final metadata = <String, dynamic>{
        ...eventSummary.metadata,
        if (cliVersion != null) 'cliVersion': cliVersion,
      };
      final invariantContext = InvariantContext(
        exitCode: codexResult.exitCode,
        gitDiff: diffResult.stdout,
        finalOutput: eventSummary.finalOutput,
        commands: eventSummary.commands,
        toolCalls: eventSummary.toolCalls,
      );
      final invariants = evalCase.invariants
          .map(
            (invariant) => const InvariantEvaluator()
                .evaluate(invariant, invariantContext)
                .toJson(),
          )
          .toList(growable: false);
      final passed =
          harnessErrors.isEmpty &&
          invariants.every((invariant) => invariant['passed'] == true);
      final relativeDirectory = p.relative(
        caseDirectory.path,
        from: outputDirectory.path,
      );
      final resultFile = p.join(relativeDirectory, 'result.json');
      final eventsFile = p.join(relativeDirectory, 'events.jsonl');
      final result = <String, dynamic>{
        'schemaVersion': 1,
        'label': label,
        'caseId': evalCase.id,
        'skill': evalCase.skill,
        'category': evalCase.category,
        'tier': evalCase.tier,
        'replica': replica,
        'prompt': evalCase.prompt,
        'startedAt': startedAt.toIso8601String(),
        'elapsedMs': stopwatch.elapsedMilliseconds,
        'exitCode': codexResult.exitCode,
        'timedOut': codexResult.timedOut,
        'timeoutMs': timeout.inMilliseconds,
        'passed': passed,
        'usage': eventSummary.usage.toJson(),
        'toolCalls': eventSummary.toolCalls,
        'commands': eventSummary.commands,
        'finalOutput': eventSummary.finalOutput,
        'metadata': metadata,
        'gitDiff': diffResult.stdout,
        'harnessErrors': harnessErrors,
        'gitCapture': {
          'stageExitCode': stageResult.exitCode,
          'diffExitCode': diffResult.exitCode,
        },
        'stderr': codexResult.stderr,
        'workspace': disposableWorkspace.path,
        'resultFile': resultFile,
        'eventsFile': eventsFile,
        'invariants': invariants,
      };
      File(
        p.join(outputDirectory.path, eventsFile),
      ).writeAsStringSync(codexResult.stdout);
      _writeJson(File(p.join(outputDirectory.path, resultFile)), result);
      return result;
    } finally {
      if (disposableWorkspace.existsSync()) {
        disposableWorkspace.deleteSync(recursive: true);
      }
    }
  }

  Future<void> _initializeGit(Directory workspace) async {
    for (final arguments in const [
      ['init'],
      ['config', 'user.email', 'skill-eval@localhost'],
      ['config', 'user.name', 'Skill Eval'],
      ['add', '--all'],
      ['commit', '--quiet', '-m', 'skill-eval baseline'],
    ]) {
      final result = await _runGit(workspace, arguments);
      if (result.exitCode != 0) {
        throw FileSystemException(
          'Could not prepare disposable Git workspace: ${result.stderr}',
          workspace.path,
        );
      }
    }
  }

  Future<ProcessExecution> _runGit(
    Directory workspace,
    List<String> arguments,
  ) => _processExecutor.run(
    ProcessRequest(
      executable: 'git',
      arguments: arguments,
      workingDirectory: workspace.path,
    ),
  );

  static void _copyWorkspace(Directory source, Directory destination) {
    const excludedSegments = {'.dart_tool', '.git', '.idea', 'build', 'Pods'};
    for (final entity in source.listSync(recursive: true, followLinks: false)) {
      final relative = p.relative(entity.path, from: source.path);
      if (p.split(relative).any(excludedSegments.contains)) {
        continue;
      }
      final targetPath = p.join(destination.path, relative);
      if (entity is Directory) {
        Directory(targetPath).createSync(recursive: true);
      } else if (entity is File) {
        File(targetPath).parent.createSync(recursive: true);
        entity.copySync(targetPath);
      } else if (entity is Link) {
        Link(targetPath)
          ..parent.createSync(recursive: true)
          ..createSync(entity.targetSync());
      }
    }
  }

  static void _writeJson(File file, Object value) {
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(value));
  }

  static Directory _createOutputDirectory({
    required Directory sourceWorkspace,
    required String? requestedPath,
    required String label,
  }) {
    if (requestedPath != null) {
      final output = Directory(requestedPath).absolute;
      _ensureOutsideSourceWorkspace(sourceWorkspace, output);
      return output..createSync(recursive: true);
    }

    _ensureOutsideSourceWorkspace(sourceWorkspace, Directory.systemTemp);
    return Directory.systemTemp.createTempSync(
      'project-tweety-skill-eval-${_safeSegment(label)}-',
    );
  }

  static void _ensureOutsideSourceWorkspace(
    Directory sourceWorkspace,
    Directory outputDirectory,
  ) {
    final sourcePath = _resolvedDirectoryPath(sourceWorkspace);
    final outputPath = _resolvedDirectoryPath(outputDirectory);
    if (p.equals(sourcePath, outputPath) ||
        p.isWithin(sourcePath, outputPath)) {
      throw const FormatException(
        'Evaluation artifacts must be outside the source workspace.',
      );
    }
  }

  static String _resolvedDirectoryPath(Directory directory) {
    var existingAncestor = directory.absolute;
    final missingSegments = <String>[];
    while (!existingAncestor.existsSync()) {
      missingSegments.add(p.basename(existingAncestor.path));
      final parent = existingAncestor.parent;
      if (p.equals(parent.path, existingAncestor.path)) {
        break;
      }
      existingAncestor = parent;
    }
    final resolvedAncestor = existingAncestor.existsSync()
        ? existingAncestor.resolveSymbolicLinksSync()
        : existingAncestor.path;
    return p.normalize(
      p.joinAll([resolvedAncestor, ...missingSegments.reversed]),
    );
  }

  static String _safeSegment(String value) {
    final safe = value.replaceAll(RegExp('[^a-zA-Z0-9._-]'), '_');
    return safe.isEmpty ? 'evaluation' : safe;
  }

  static String _formatDuration(Duration duration) {
    if (duration.inMilliseconds % Duration.millisecondsPerSecond == 0) {
      return '${duration.inSeconds}s';
    }
    return '${duration.inMilliseconds}ms';
  }

  static const _usage = '''
Usage:
  dart run tool/skills/eval.dart run --label <label> [--case <id>] [--replicas <n>]
  dart run tool/skills/eval.dart compare --baseline <dir> --candidate <dir>

Options:
  --workspace <dir>  Source workspace copied for each run (default: current directory)
  --manifest <file>  JSON case manifest (default: tool/skills/eval_cases.json)
  --output <dir>     Artifact directory (default: a new system temporary directory)
''';
}

final class _ParsedOptions {
  _ParsedOptions(this._values);

  factory _ParsedOptions.parse(
    List<String> arguments, {
    required Set<String> supported,
  }) {
    final values = <String, String>{};
    for (var index = 0; index < arguments.length; index += 1) {
      final argument = arguments[index];
      if (!argument.startsWith('--')) {
        throw FormatException('Unexpected argument "$argument".');
      }
      if (index + 1 >= arguments.length ||
          arguments[index + 1].startsWith('--')) {
        throw FormatException('Missing value for "$argument".');
      }
      if (values.containsKey(argument)) {
        throw FormatException('Duplicate option "$argument".');
      }
      values[argument] = arguments[index + 1];
      index += 1;
    }
    final unknown = values.keys.where((key) => !supported.contains(key));
    if (unknown.isNotEmpty) {
      throw FormatException('Unknown option "${unknown.first}".');
    }
    return _ParsedOptions(values);
  }

  final Map<String, String> _values;

  String? value(String name) => _values[name];

  String requireValue(String name) {
    final result = value(name);
    if (result == null || result.trim().isEmpty) {
      throw FormatException('Missing required option "$name".');
    }
    return result;
  }

  int? positiveInt(String name) {
    final raw = value(name);
    if (raw == null) {
      return null;
    }
    final parsed = int.tryParse(raw);
    if (parsed == null || parsed < 1) {
      throw FormatException('Option "$name" must be a positive integer.');
    }
    return parsed;
  }
}
