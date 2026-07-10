import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

final class ComparisonOutcome {
  const ComparisonOutcome({
    required this.outputFile,
    required this.hasRegressions,
  });

  final File outputFile;
  final bool hasRegressions;
}

final class EvalComparator {
  const EvalComparator();

  ComparisonOutcome compare({
    required String baselinePath,
    required String candidatePath,
  }) {
    final baselineFile = _summaryFile(baselinePath);
    final candidateFile = _summaryFile(candidatePath);
    final baseline = _readJson(baselineFile);
    final candidate = _readJson(candidateFile);
    final baselineRuns = _runs(baseline, baselineFile);
    final candidateRuns = _runs(candidate, candidateFile);
    final baselineByKey = {for (final run in baselineRuns) _runKey(run): run};
    final candidateByKey = {for (final run in candidateRuns) _runKey(run): run};
    final matchedKeys =
        baselineByKey.keys
            .where(candidateByKey.containsKey)
            .toList(growable: false)
          ..sort();
    final missingRuns =
        baselineByKey.keys
            .where((key) => !candidateByKey.containsKey(key))
            .toList(growable: false)
          ..sort();
    final newRuns =
        candidateByKey.keys
            .where((key) => !baselineByKey.containsKey(key))
            .toList(growable: false)
          ..sort();
    final runRegressions = matchedKeys
        .where(
          (key) =>
              baselineByKey[key]!['passed'] == true &&
              candidateByKey[key]!['passed'] != true,
        )
        .toList(growable: false);
    final runImprovements = matchedKeys
        .where(
          (key) =>
              baselineByKey[key]!['passed'] != true &&
              candidateByKey[key]!['passed'] == true,
        )
        .toList(growable: false);

    final baselineMetrics = _metrics(baselineRuns);
    final candidateMetrics = _metrics(candidateRuns);
    final invariantComparison = _compareInvariants(
      matchedKeys: matchedKeys,
      baselineByKey: baselineByKey,
      candidateByKey: candidateByKey,
    );
    final tierNames = <String>{
      ...baselineRuns.map((run) => run['tier']).whereType<String>(),
      ...candidateRuns.map((run) => run['tier']).whereType<String>(),
    }.toList(growable: false)..sort();
    final tiers = <String, dynamic>{};
    for (final tierName in tierNames) {
      final baselineTierRuns = baselineRuns
          .where((run) => run['tier'] == tierName)
          .toList(growable: false);
      final candidateTierRuns = candidateRuns
          .where((run) => run['tier'] == tierName)
          .toList(growable: false);
      final baselineTierMetrics = _metrics(baselineTierRuns);
      final candidateTierMetrics = _metrics(candidateTierRuns);
      tiers[tierName] = {
        'baselineDefaultReplicas': _tierReplicas(baseline, tierName),
        'candidateDefaultReplicas': _tierReplicas(candidate, tierName),
        'baseline': baselineTierMetrics,
        'candidate': candidateTierMetrics,
        'delta': _delta(baselineTierMetrics, candidateTierMetrics),
      };
    }

    final comparison = <String, dynamic>{
      'schemaVersion': 1,
      'baselineLabel': baseline['label'],
      'candidateLabel': candidate['label'],
      'baselineSummary': baselineFile.absolute.path,
      'candidateSummary': candidateFile.absolute.path,
      'matchedRuns': matchedKeys.length,
      'missingRuns': missingRuns,
      'newRuns': newRuns,
      'runRegressions': runRegressions,
      'runImprovements': runImprovements,
      'baseline': baselineMetrics,
      'candidate': candidateMetrics,
      'delta': _delta(baselineMetrics, candidateMetrics),
      'percentDelta': _percentDelta(baselineMetrics, candidateMetrics),
      'invariants': invariantComparison,
      'tiers': tiers,
    };
    final outputFile = File(
      p.join(candidateFile.parent.path, 'comparison.json'),
    );
    outputFile.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(comparison),
    );
    final regressions = invariantComparison['regressions']!;
    return ComparisonOutcome(
      outputFile: outputFile,
      hasRegressions:
          missingRuns.isNotEmpty ||
          runRegressions.isNotEmpty ||
          regressions.isNotEmpty ||
          candidateMetrics['passCount']! < baselineMetrics['passCount']!,
    );
  }

  static File _summaryFile(String path) {
    final type = FileSystemEntity.typeSync(path);
    final file = type == FileSystemEntityType.directory
        ? File(p.join(path, 'run_summary.json'))
        : File(path);
    if (!file.existsSync()) {
      throw FormatException('Run summary does not exist: ${file.path}');
    }
    return file;
  }

  static Map<String, dynamic> _readJson(File file) {
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is! Map<String, dynamic> || decoded['schemaVersion'] != 1) {
      throw FormatException('Invalid run summary: ${file.path}');
    }
    return decoded;
  }

  static List<Map<String, dynamic>> _runs(
    Map<String, dynamic> summary,
    File source,
  ) {
    final value = summary['runs'];
    if (value is! List) {
      throw FormatException('Run summary has no runs: ${source.path}');
    }
    return value
        .map((run) {
          if (run is! Map<String, dynamic>) {
            throw FormatException(
              'Run summary contains an invalid run: ${source.path}',
            );
          }
          return run;
        })
        .toList(growable: false);
  }

  static String _runKey(Map<String, dynamic> run) =>
      '${run['caseId']}#${run['replica']}';

  static Map<String, num> _metrics(List<Map<String, dynamic>> runs) {
    final tokens = runs.map(_tokens).toList(growable: false);
    final toolCalls = runs.map(_toolCalls).toList(growable: false);
    final elapsed = runs.map(_elapsedMs).toList(growable: false);
    return {
      'runCount': runs.length,
      'passCount': runs.where((run) => run['passed'] == true).length,
      'totalTokens': tokens.fold(0, (sum, value) => sum + value),
      'medianTokens': _median(tokens),
      'totalToolCalls': toolCalls.fold(0, (sum, value) => sum + value),
      'medianToolCalls': _median(toolCalls),
      'totalElapsedMs': elapsed.fold(0, (sum, value) => sum + value),
      'medianElapsedMs': _median(elapsed),
    };
  }

  static int _tokens(Map<String, dynamic> run) {
    final usage = run['usage'];
    return usage is Map<String, dynamic> && usage['totalTokens'] is num
        ? (usage['totalTokens'] as num).toInt()
        : 0;
  }

  static int _toolCalls(Map<String, dynamic> run) {
    final value = run['toolCalls'];
    return value is num ? value.toInt() : 0;
  }

  static int _elapsedMs(Map<String, dynamic> run) {
    final value = run['elapsedMs'];
    return value is num ? value.toInt() : 0;
  }

  static num _median(List<int> values) {
    if (values.isEmpty) {
      return 0;
    }
    final sorted = [...values]..sort();
    final midpoint = sorted.length ~/ 2;
    if (sorted.length.isOdd) {
      return sorted[midpoint];
    }
    final result = (sorted[midpoint - 1] + sorted[midpoint]) / 2;
    return result == result.roundToDouble() ? result.toInt() : result;
  }

  static Map<String, num> _delta(
    Map<String, num> baseline,
    Map<String, num> candidate,
  ) => {
    'passCount': candidate['passCount']! - baseline['passCount']!,
    'totalTokens': candidate['totalTokens']! - baseline['totalTokens']!,
    'medianTokens': candidate['medianTokens']! - baseline['medianTokens']!,
    'totalToolCalls':
        candidate['totalToolCalls']! - baseline['totalToolCalls']!,
    'medianToolCalls':
        candidate['medianToolCalls']! - baseline['medianToolCalls']!,
    'totalElapsedMs':
        candidate['totalElapsedMs']! - baseline['totalElapsedMs']!,
    'medianElapsedMs':
        candidate['medianElapsedMs']! - baseline['medianElapsedMs']!,
  };

  static Map<String, num?> _percentDelta(
    Map<String, num> baseline,
    Map<String, num> candidate,
  ) {
    num? percentage(String key) {
      final original = baseline[key]!;
      if (original == 0) {
        return null;
      }
      return ((candidate[key]! - original) / original) * 100;
    }

    return {
      'totalTokens': percentage('totalTokens'),
      'medianTokens': percentage('medianTokens'),
      'totalToolCalls': percentage('totalToolCalls'),
      'medianToolCalls': percentage('medianToolCalls'),
      'totalElapsedMs': percentage('totalElapsedMs'),
      'medianElapsedMs': percentage('medianElapsedMs'),
    };
  }

  static Map<String, List<String>> _compareInvariants({
    required List<String> matchedKeys,
    required Map<String, Map<String, dynamic>> baselineByKey,
    required Map<String, Map<String, dynamic>> candidateByKey,
  }) {
    final regressions = <String>[];
    final improvements = <String>[];
    final unchanged = <String>[];
    final newInvariants = <String>[];
    for (final runKey in matchedKeys) {
      final baseline = _invariants(baselineByKey[runKey]!);
      final candidate = _invariants(candidateByKey[runKey]!);
      final baselineIds = baseline.keys.toList()..sort();
      for (final id in baselineIds) {
        final key = '$runKey:$id';
        if (!candidate.containsKey(id)) {
          regressions.add(key);
        } else if (baseline[id] == true && candidate[id] == false) {
          regressions.add(key);
        } else if (baseline[id] == false && candidate[id] == true) {
          improvements.add(key);
        } else {
          unchanged.add(key);
        }
      }
      final candidateOnlyIds =
          candidate.keys.where((id) => !baseline.containsKey(id)).toList()
            ..sort();
      newInvariants.addAll(candidateOnlyIds.map((id) => '$runKey:$id'));
    }
    return {
      'regressions': regressions,
      'improvements': improvements,
      'unchanged': unchanged,
      'new': newInvariants,
    };
  }

  static Map<String, bool> _invariants(Map<String, dynamic> run) {
    final raw = run['invariants'];
    if (raw is! List) {
      return const {};
    }
    return {
      for (final invariant in raw.whereType<Map<String, dynamic>>())
        if (invariant['id'] is String && invariant['passed'] is bool)
          invariant['id'] as String: invariant['passed'] as bool,
    };
  }

  static int? _tierReplicas(Map<String, dynamic> summary, String tierName) {
    final tiers = summary['tiers'];
    if (tiers is! Map<String, dynamic>) {
      return null;
    }
    final tier = tiers[tierName];
    if (tier is! Map<String, dynamic>) {
      return null;
    }
    final value = tier['defaultReplicas'];
    return value is num ? value.toInt() : null;
  }
}
