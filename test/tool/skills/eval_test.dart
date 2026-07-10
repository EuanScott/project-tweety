import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../../tool/skills/eval/eval.cli.dart';
import '../../../tool/skills/eval/eval.manifest.dart';
import '../../../tool/skills/eval/process.executor.dart';

void main() {
  group('skill evaluation CLI', () {
    test('run captures a Codex case as a self-contained result', () async {
      final sandbox = Directory.systemTemp.createTempSync('skill_eval_test_');
      addTearDown(() => sandbox.deleteSync(recursive: true));
      final workspace = Directory(p.join(sandbox.path, 'workspace'))
        ..createSync();
      File(p.join(workspace.path, 'README.md')).writeAsStringSync('fixture');
      File(p.join(workspace.path, 'packages/example/lib/kept.dart'))
        ..createSync(recursive: true)
        ..writeAsStringSync('const kept = true;');
      File(p.join(workspace.path, 'packages/example/build/ignored.txt'))
        ..createSync(recursive: true)
        ..writeAsStringSync('generated');
      File(p.join(workspace.path, 'packages/example/.dart_tool/ignored.txt'))
        ..createSync(recursive: true)
        ..writeAsStringSync('generated');
      final manifest = File(p.join(sandbox.path, 'cases.json'))
        ..writeAsStringSync(
          jsonEncode({
            'schemaVersion': 1,
            'tiers': {
              'smoke': {'defaultReplicas': 1},
            },
            'cases': [
              {
                'id': 'feature_positive',
                'skill': 'feature-scaffold',
                'category': 'positive_routing',
                'tier': 'smoke',
                'prompt': 'Create a BFF-backed eval_catalog page feature.',
                'invariants': [
                  {'id': 'exit', 'kind': 'exit_code', 'value': 0},
                  {'id': 'clean', 'kind': 'git_diff_empty'},
                  {
                    'id': 'usage',
                    'kind': 'output_contains',
                    'value': 'Complete',
                  },
                ],
              },
            ],
          }),
        );
      final output = Directory(p.join(sandbox.path, 'output'));
      final processExecutor = _FakeProcessExecutor(
        codexOutput: [
          jsonEncode({'type': 'thread.started', 'model': 'gpt-test'}),
          jsonEncode({
            'type': 'item.completed',
            'item': {
              'id': 'command-1',
              'type': 'command_execution',
              'command': 'rg --files .codex/skills',
            },
          }),
          jsonEncode({
            'type': 'item.completed',
            'item': {
              'id': 'message-1',
              'type': 'agent_message',
              'text': 'Complete.',
            },
          }),
          jsonEncode({
            'type': 'turn.completed',
            'usage': {
              'input_tokens': 100,
              'cached_input_tokens': 25,
              'output_tokens': 20,
            },
          }),
        ].join('\n'),
      );
      final messages = <String>[];
      final cli = EvalCli(
        processExecutor: processExecutor,
        writeLine: messages.add,
      );

      final exitCode = await cli.run([
        'run',
        '--label',
        'baseline',
        '--manifest',
        manifest.path,
        '--workspace',
        workspace.path,
        '--output',
        output.path,
        '--case',
        'feature_positive',
      ]);

      expect(exitCode, 0);
      final summary = _readJson(File(p.join(output.path, 'run_summary.json')));
      expect(summary['label'], 'baseline');
      expect(summary['runs'], hasLength(1));
      final run = (summary['runs'] as List).single as Map<String, dynamic>;
      expect(run['passed'], isTrue);
      expect(run['tier'], 'smoke');
      expect(run['replica'], 1);
      expect(run['usage'], {
        'inputTokens': 100,
        'cachedInputTokens': 25,
        'outputTokens': 20,
        'totalTokens': 120,
      });
      expect(run['toolCalls'], 1);
      expect(run['finalOutput'], 'Complete.');
      expect(run['commands'], ['rg --files .codex/skills']);
      expect(run['metadata'], containsPair('model', 'gpt-test'));
      expect(run['metadata'], containsPair('cliVersion', 'codex-cli 1.2.3'));
      expect(run['invariants'], everyElement(containsPair('passed', true)));

      final resultFile = File(p.join(output.path, run['resultFile'] as String));
      final eventsFile = File(p.join(output.path, run['eventsFile'] as String));
      expect(resultFile.existsSync(), isTrue);
      expect(eventsFile.readAsStringSync(), processExecutor.codexOutput);
      expect(
        _readJson(resultFile)['prompt'],
        'Create a BFF-backed eval_catalog page feature.',
      );
      expect(
        processExecutor.requests,
        contains(
          isA<ProcessRequest>()
              .having((request) => request.executable, 'executable', 'codex')
              .having((request) => request.arguments, 'arguments', [
                'exec',
                '--ephemeral',
                '--json',
                '--sandbox',
                'workspace-write',
                '-',
              ])
              .having(
                (request) => request.standardInput,
                'standardInput',
                'Create a BFF-backed eval_catalog page feature.',
              ),
        ),
      );
      expect(
        processExecutor.codexWorkspaceEntries,
        contains('packages/example/lib/kept.dart'),
      );
      expect(
        processExecutor.codexWorkspaceEntries,
        everyElement(
          isNot(anyOf(contains('/build/'), contains('/.dart_tool/'))),
        ),
      );
      expect(messages.single, contains(output.path));
    });

    test(
      'run rejects an output directory inside the source workspace',
      () async {
        final sandbox = Directory.systemTemp.createTempSync(
          'skill_eval_output_boundary_test_',
        );
        addTearDown(() => sandbox.deleteSync(recursive: true));
        final workspace = Directory(p.join(sandbox.path, 'workspace'))
          ..createSync();
        File(p.join(workspace.path, 'README.md')).writeAsStringSync('fixture');
        final manifest = _writeSingleCaseManifest(sandbox);
        final output = Directory(p.join(workspace.path, 'eval-artifacts'));
        final processExecutor = _FakeProcessExecutor(
          codexOutput: _successfulCodexOutput(),
        );
        final messages = <String>[];
        final cli = EvalCli(
          processExecutor: processExecutor,
          writeLine: messages.add,
        );

        final exitCode = await cli.run([
          'run',
          '--label',
          'invalid-output',
          '--manifest',
          manifest.path,
          '--workspace',
          workspace.path,
          '--output',
          output.path,
        ]);

        expect(exitCode, 64);
        expect(output.existsSync(), isFalse);
        expect(processExecutor.requests, isEmpty);
        expect(messages.single, contains('outside the source workspace'));
      },
    );

    test('run fails closed for malformed or incomplete Codex JSONL', () async {
      final fixtures = <String, ({String output, String expectedError})>{
        'unparsed': (
          output: '${_successfulCodexOutput()}\nnot-json',
          expectedError: 'unparsed JSONL',
        ),
        'missing-usage': (
          output: jsonEncode({
            'type': 'item.completed',
            'item': {
              'id': 'message-1',
              'type': 'agent_message',
              'text': 'Complete.',
            },
          }),
          expectedError: 'terminal usage',
        ),
        'missing-output': (
          output: jsonEncode({
            'type': 'turn.completed',
            'usage': {
              'input_tokens': 10,
              'cached_input_tokens': 0,
              'output_tokens': 5,
            },
          }),
          expectedError: 'final agent output',
        ),
      };

      for (final MapEntry(key: name, value: fixture) in fixtures.entries) {
        final sandbox = Directory.systemTemp.createTempSync(
          'skill_eval_jsonl_$name',
        );
        addTearDown(() => sandbox.deleteSync(recursive: true));
        final workspace = Directory(p.join(sandbox.path, 'workspace'))
          ..createSync();
        File(p.join(workspace.path, 'README.md')).writeAsStringSync('fixture');
        final manifest = _writeSingleCaseManifest(sandbox);
        final output = Directory(p.join(sandbox.path, 'artifacts'));
        final cli = EvalCli(
          processExecutor: _FakeProcessExecutor(codexOutput: fixture.output),
          writeLine: (_) {},
        );

        final exitCode = await cli.run([
          'run',
          '--label',
          name,
          '--manifest',
          manifest.path,
          '--workspace',
          workspace.path,
          '--output',
          output.path,
        ]);

        expect(exitCode, 1, reason: name);
        final summary = _readJson(
          File(p.join(output.path, 'run_summary.json')),
        );
        final run = (summary['runs'] as List).single as Map<String, dynamic>;
        expect(run['passed'], isFalse, reason: name);
        expect(
          run['harnessErrors'],
          contains(contains(fixture.expectedError)),
          reason: name,
        );
        expect(
          File(p.join(output.path, run['resultFile'] as String)).existsSync(),
          isTrue,
          reason: name,
        );
        expect(
          File(p.join(output.path, run['eventsFile'] as String)).existsSync(),
          isTrue,
          reason: name,
        );
      }
    });

    test('run rejects malformed terminal usage counters', () async {
      final malformedUsage = <String, Map<String, dynamic>>{
        'empty': {},
        'missing-input': {'output_tokens': 5},
        'missing-output': {'input_tokens': 10},
        'string-input': {'input_tokens': '10', 'output_tokens': 5},
        'negative-input': {'input_tokens': -1, 'output_tokens': 5},
        'fractional-output': {'input_tokens': 10, 'output_tokens': 2.5},
        'negative-cached': {
          'input_tokens': 10,
          'cached_input_tokens': -1,
          'output_tokens': 5,
        },
      };

      for (final MapEntry(key: name, value: usage) in malformedUsage.entries) {
        final sandbox = Directory.systemTemp.createTempSync(
          'skill_eval_usage_$name',
        );
        addTearDown(() => sandbox.deleteSync(recursive: true));
        final workspace = Directory(p.join(sandbox.path, 'workspace'))
          ..createSync();
        File(p.join(workspace.path, 'README.md')).writeAsStringSync('fixture');
        final manifest = _writeSingleCaseManifest(sandbox);
        final output = Directory(p.join(sandbox.path, 'artifacts'));
        final cli = EvalCli(
          processExecutor: _FakeProcessExecutor(
            codexOutput: _codexOutputWithUsage(usage),
          ),
          writeLine: (_) {},
        );

        final exitCode = await cli.run([
          'run',
          '--label',
          name,
          '--manifest',
          manifest.path,
          '--workspace',
          workspace.path,
          '--output',
          output.path,
        ]);

        expect(exitCode, 1, reason: name);
        final summary = _readJson(
          File(p.join(output.path, 'run_summary.json')),
        );
        final run = (summary['runs'] as List).single as Map<String, dynamic>;
        expect(run['passed'], isFalse, reason: name);
        expect(
          run['harnessErrors'],
          contains(contains('malformed terminal usage')),
          reason: name,
        );
      }
    });

    test('run accepts non-negative camel-case usage counters', () async {
      final sandbox = Directory.systemTemp.createTempSync(
        'skill_eval_camel_usage_test_',
      );
      addTearDown(() => sandbox.deleteSync(recursive: true));
      final workspace = Directory(p.join(sandbox.path, 'workspace'))
        ..createSync();
      File(p.join(workspace.path, 'README.md')).writeAsStringSync('fixture');
      final manifest = _writeSingleCaseManifest(sandbox);
      final output = Directory(p.join(sandbox.path, 'artifacts'));
      final cli = EvalCli(
        processExecutor: _FakeProcessExecutor(
          codexOutput: _codexOutputWithUsage({
            'inputTokens': 12,
            'cachedInputTokens': 3,
            'outputTokens': 4,
          }),
        ),
        writeLine: (_) {},
      );

      final exitCode = await cli.run([
        'run',
        '--label',
        'camel-usage',
        '--manifest',
        manifest.path,
        '--workspace',
        workspace.path,
        '--output',
        output.path,
      ]);

      expect(exitCode, 0);
      final summary = _readJson(File(p.join(output.path, 'run_summary.json')));
      final run = (summary['runs'] as List).single as Map<String, dynamic>;
      expect(run['usage'], {
        'inputTokens': 12,
        'cachedInputTokens': 3,
        'outputTokens': 4,
        'totalTokens': 16,
      });
    });

    test(
      'run applies case, tier, and safe-default timeouts without aborting',
      () async {
        final sandbox = Directory.systemTemp.createTempSync(
          'skill_eval_timeout_test_',
        );
        addTearDown(() => sandbox.deleteSync(recursive: true));
        final workspace = Directory(p.join(sandbox.path, 'workspace'))
          ..createSync();
        File(p.join(workspace.path, 'README.md')).writeAsStringSync('fixture');
        final manifest = File(p.join(sandbox.path, 'timeouts.json'))
          ..writeAsStringSync(
            jsonEncode({
              'schemaVersion': 1,
              'tiers': {
                'configured': {'defaultReplicas': 1, 'timeoutSeconds': 30},
                'defaulted': {'defaultReplicas': 1},
              },
              'cases': [
                {
                  'id': 'case_override',
                  'skill': 'feature-scaffold',
                  'category': 'behavior',
                  'tier': 'configured',
                  'timeoutSeconds': 1,
                  'prompt': 'times out',
                  'invariants': [
                    {'id': 'exit', 'kind': 'exit_code', 'value': 0},
                  ],
                },
                {
                  'id': 'tier_timeout',
                  'skill': 'feature-scaffold',
                  'category': 'behavior',
                  'tier': 'configured',
                  'prompt': 'uses tier timeout',
                  'invariants': [
                    {'id': 'exit', 'kind': 'exit_code', 'value': 0},
                  ],
                },
                {
                  'id': 'safe_default',
                  'skill': 'feature-scaffold',
                  'category': 'behavior',
                  'tier': 'defaulted',
                  'prompt': 'uses safe default',
                  'invariants': [
                    {'id': 'exit', 'kind': 'exit_code', 'value': 0},
                  ],
                },
              ],
            }),
          );
        final output = Directory(p.join(sandbox.path, 'artifacts'));
        final processExecutor = _TimeoutThenSuccessProcessExecutor();
        final cli = EvalCli(
          processExecutor: processExecutor,
          writeLine: (_) {},
        );

        final exitCode = await cli.run([
          'run',
          '--label',
          'timeouts',
          '--manifest',
          manifest.path,
          '--workspace',
          workspace.path,
          '--output',
          output.path,
        ]);

        expect(exitCode, 1);
        final summary = _readJson(
          File(p.join(output.path, 'run_summary.json')),
        );
        final runs = (summary['runs'] as List).cast<Map<String, dynamic>>();
        expect(runs, hasLength(3));
        expect(runs.first['passed'], isFalse);
        expect(runs.first['timedOut'], isTrue);
        expect(
          runs.first['harnessErrors'],
          contains(contains('timed out after 1s')),
        );
        expect(runs.skip(1), everyElement(containsPair('passed', true)));
        expect(
          processExecutor.codexRequests.map((request) => request.timeout),
          [
            const Duration(seconds: 1),
            const Duration(seconds: 30),
            const Duration(minutes: 10),
          ],
        );
        for (final run in runs) {
          expect(
            File(p.join(output.path, run['resultFile'] as String)).existsSync(),
            isTrue,
          );
          expect(
            File(p.join(output.path, run['eventsFile'] as String)).existsSync(),
            isTrue,
          );
        }
      },
    );

    test('system process executor terminates a timed-out process', () async {
      final process = _ControllableProcess();
      final executor = SystemProcessExecutor(
        processStarter: (executable, arguments, {workingDirectory}) async =>
            process,
      );

      final result = await executor.run(
        const ProcessRequest(
          executable: 'codex',
          arguments: ['exec'],
          workingDirectory: '/tmp',
          timeout: Duration(milliseconds: 1),
        ),
      );

      expect(result.timedOut, isTrue);
      expect(process.signals, [ProcessSignal.sigterm]);
    });

    test('compare aggregates cost deltas and invariant outcomes', () async {
      final sandbox = Directory.systemTemp.createTempSync(
        'skill_compare_test_',
      );
      addTearDown(() => sandbox.deleteSync(recursive: true));
      final baseline = Directory(p.join(sandbox.path, 'baseline'))
        ..createSync();
      final candidate = Directory(p.join(sandbox.path, 'candidate'))
        ..createSync();
      _writeSummary(
        baseline,
        label: 'baseline',
        runs: [
          _summaryRun(
            caseId: 'feature_positive',
            tier: 'smoke',
            passed: true,
            totalTokens: 100,
            toolCalls: 4,
            elapsedMs: 1000,
            invariants: {'exit': true, 'clean': true},
          ),
          _summaryRun(
            caseId: 'feature_routing',
            tier: 'high_risk',
            passed: false,
            totalTokens: 200,
            toolCalls: 6,
            elapsedMs: 2000,
            invariants: {'route': false},
          ),
        ],
      );
      _writeSummary(
        candidate,
        label: 'candidate',
        runs: [
          _summaryRun(
            caseId: 'feature_positive',
            tier: 'smoke',
            passed: true,
            totalTokens: 70,
            toolCalls: 2,
            elapsedMs: 800,
            invariants: {'exit': true, 'clean': true},
          ),
          _summaryRun(
            caseId: 'feature_routing',
            tier: 'high_risk',
            passed: true,
            totalTokens: 150,
            toolCalls: 4,
            elapsedMs: 1700,
            invariants: {'route': true},
          ),
        ],
      );
      final messages = <String>[];
      final cli = EvalCli(
        processExecutor: _FailingProcessExecutor(),
        writeLine: messages.add,
      );

      final exitCode = await cli.run([
        'compare',
        '--baseline',
        baseline.path,
        '--candidate',
        candidate.path,
      ]);

      expect(exitCode, 0);
      final comparison = _readJson(
        File(p.join(candidate.path, 'comparison.json')),
      );
      expect(comparison['baselineLabel'], 'baseline');
      expect(comparison['candidateLabel'], 'candidate');
      expect(comparison['matchedRuns'], 2);
      expect(comparison['baseline'], containsPair('passCount', 1));
      expect(comparison['candidate'], containsPair('passCount', 2));
      expect(comparison['delta'], {
        'passCount': 1,
        'totalTokens': -80,
        'medianTokens': -40,
        'totalToolCalls': -4,
        'medianToolCalls': -2,
        'totalElapsedMs': -500,
        'medianElapsedMs': -250,
      });
      expect(
        comparison['invariants'],
        containsPair('improvements', ['feature_routing#1:route']),
      );
      expect(comparison['invariants'], containsPair('regressions', <Object>[]));
      expect(
        comparison['tiers'],
        containsPair(
          'high_risk',
          containsPair('delta', containsPair('medianTokens', -50)),
        ),
      );
      expect(messages.single, contains('comparison.json'));
    });

    test(
      'compare reports pairwise run failures and removed invariants',
      () async {
        final sandbox = Directory.systemTemp.createTempSync(
          'skill_compare_pairwise_test_',
        );
        addTearDown(() => sandbox.deleteSync(recursive: true));
        final baseline = Directory(p.join(sandbox.path, 'baseline'))
          ..createSync();
        final candidate = Directory(p.join(sandbox.path, 'candidate'))
          ..createSync();
        _writeSummary(
          baseline,
          label: 'baseline',
          runs: [
            _summaryRun(
              caseId: 'case_a',
              tier: 'high_risk',
              passed: true,
              totalTokens: 100,
              toolCalls: 2,
              elapsedMs: 1000,
              invariants: {'shared': true, 'removed': true},
            ),
            _summaryRun(
              caseId: 'case_b',
              tier: 'high_risk',
              passed: false,
              totalTokens: 100,
              toolCalls: 2,
              elapsedMs: 1000,
              invariants: {'shared': true},
            ),
          ],
        );
        _writeSummary(
          candidate,
          label: 'candidate',
          runs: [
            _summaryRun(
              caseId: 'case_a',
              tier: 'high_risk',
              passed: false,
              totalTokens: 100,
              toolCalls: 2,
              elapsedMs: 1000,
              invariants: {'shared': true},
            ),
            _summaryRun(
              caseId: 'case_b',
              tier: 'high_risk',
              passed: true,
              totalTokens: 100,
              toolCalls: 2,
              elapsedMs: 1000,
              invariants: {'shared': true},
            ),
          ],
        );
        final cli = EvalCli(
          processExecutor: _FailingProcessExecutor(),
          writeLine: (_) {},
        );

        final exitCode = await cli.run([
          'compare',
          '--baseline',
          baseline.path,
          '--candidate',
          candidate.path,
        ]);

        expect(exitCode, 1);
        final comparison = _readJson(
          File(p.join(candidate.path, 'comparison.json')),
        );
        expect(comparison['runRegressions'], ['case_a#1']);
        expect(comparison['runImprovements'], ['case_b#1']);
        expect(
          (comparison['invariants'] as Map<String, dynamic>)['regressions'],
          contains('case_a#1:removed'),
        );
      },
    );

    test('case manifest covers every skill and representative risk', () {
      final manifest = EvalManifest.read(File('tool/skills/eval_cases.json'));
      const skills = {
        'app-performance-review',
        'data-scaffold',
        'domain-scaffold',
        'feature-scaffold',
        'page-scaffold',
        'shared-widget',
        'update-widget',
      };
      const requiredCategories = {
        'positive_routing',
        'sibling_negative',
        'safety_boundary',
      };
      const representativeCases = {
        'feature_no_domain',
        'feature_with_domain',
        'data_curl_redaction',
        'page_missing_dependencies',
        'page_bloc',
        'page_cubit',
        'shared_widget_missing_brief',
        'shared_widget_design_system_placement',
        'shared_widget_app_placement',
        'update_widget_missing_target',
        'update_widget_controlled',
        'update_widget_additive',
        'update_widget_successor',
        'performance_proactive_audit',
        'performance_regression',
        'performance_build_pipeline',
      };

      expect(manifest.cases.map((evalCase) => evalCase.skill).toSet(), skills);
      for (final skill in skills) {
        expect(
          manifest.cases
              .where((evalCase) => evalCase.skill == skill)
              .map((evalCase) => evalCase.category)
              .toSet(),
          containsAll(requiredCategories),
          reason: '$skill lacks a required evaluation category',
        );
      }
      expect(
        manifest.cases.map((evalCase) => evalCase.id),
        containsAll(representativeCases),
      );
      expect(manifest.tiers['high_risk']?.defaultReplicas, 3);
      expect(manifest.tiers['smoke']?.timeout, const Duration(minutes: 2));
      expect(manifest.tiers['standard']?.timeout, const Duration(minutes: 5));
      expect(manifest.tiers['high_risk']?.timeout, const Duration(minutes: 15));
      expect(
        manifest.cases
            .singleWhere(
              (evalCase) => evalCase.id == 'performance_proactive_audit',
            )
            .timeout,
        const Duration(minutes: 5),
      );
      expect(
        manifest.cases.where((evalCase) => evalCase.tier == 'high_risk'),
        isNotEmpty,
      );
      expect(
        manifest.cases.where((evalCase) => evalCase.category == 'help'),
        isEmpty,
      );
      expect(
        manifest.cases.map((evalCase) => evalCase.id),
        isNot(contains(matches(RegExp(r'_help$')))),
      );
    });

    test(
      'compare treats a missing candidate replica as a regression',
      () async {
        final sandbox = Directory.systemTemp.createTempSync(
          'skill_compare_missing_test_',
        );
        addTearDown(() => sandbox.deleteSync(recursive: true));
        final baseline = Directory(p.join(sandbox.path, 'baseline'))
          ..createSync();
        final candidate = Directory(p.join(sandbox.path, 'candidate'))
          ..createSync();
        _writeSummary(
          baseline,
          label: 'baseline',
          runs: [
            _summaryRun(
              caseId: 'feature_routing',
              tier: 'high_risk',
              passed: true,
              totalTokens: 100,
              toolCalls: 2,
              elapsedMs: 1000,
              invariants: {'route': true},
            ),
            _summaryRun(
              caseId: 'feature_routing',
              replica: 2,
              tier: 'high_risk',
              passed: true,
              totalTokens: 110,
              toolCalls: 2,
              elapsedMs: 1100,
              invariants: {'route': true},
            ),
          ],
        );
        _writeSummary(
          candidate,
          label: 'candidate',
          runs: [
            _summaryRun(
              caseId: 'feature_routing',
              tier: 'high_risk',
              passed: true,
              totalTokens: 80,
              toolCalls: 1,
              elapsedMs: 800,
              invariants: {'route': true},
            ),
          ],
        );
        final cli = EvalCli(
          processExecutor: _FailingProcessExecutor(),
          writeLine: (_) {},
        );

        final exitCode = await cli.run([
          'compare',
          '--baseline',
          baseline.path,
          '--candidate',
          candidate.path,
        ]);

        expect(exitCode, 1);
        final comparison = _readJson(
          File(p.join(candidate.path, 'comparison.json')),
        );
        expect(comparison['missingRuns'], ['feature_routing#2']);
        expect(comparison['newRuns'], isEmpty);
      },
    );

    test(
      'run fails closed when the post-run Git diff cannot be captured',
      () async {
        final sandbox = Directory.systemTemp.createTempSync(
          'skill_eval_diff_failure_test_',
        );
        addTearDown(() => sandbox.deleteSync(recursive: true));
        final workspace = Directory(p.join(sandbox.path, 'workspace'))
          ..createSync();
        File(p.join(workspace.path, 'README.md')).writeAsStringSync('fixture');
        final manifest = File(p.join(sandbox.path, 'cases.json'))
          ..writeAsStringSync(
            jsonEncode({
              'schemaVersion': 1,
              'tiers': {
                'smoke': {'defaultReplicas': 1},
              },
              'cases': [
                {
                  'id': 'feature_positive',
                  'skill': 'feature-scaffold',
                  'category': 'positive_routing',
                  'tier': 'smoke',
                  'prompt': 'Create a BFF-backed eval_catalog page feature.',
                  'invariants': [
                    {'id': 'exit', 'kind': 'exit_code', 'value': 0},
                    {'id': 'clean', 'kind': 'git_diff_empty'},
                  ],
                },
              ],
            }),
          );
        final output = Directory(p.join(sandbox.path, 'output'));
        final processExecutor = _FakeProcessExecutor(
          codexOutput: jsonEncode({
            'type': 'item.completed',
            'item': {
              'id': 'message-1',
              'type': 'agent_message',
              'text': 'Complete.',
            },
          }),
          gitDiffExitCode: 128,
          gitDiffStderr: 'fatal: not a git repository',
        );
        final cli = EvalCli(
          processExecutor: processExecutor,
          writeLine: (_) {},
        );

        final exitCode = await cli.run([
          'run',
          '--label',
          'broken-diff',
          '--manifest',
          manifest.path,
          '--workspace',
          workspace.path,
          '--output',
          output.path,
        ]);

        expect(exitCode, 1);
        final summary = _readJson(
          File(p.join(output.path, 'run_summary.json')),
        );
        final run = (summary['runs'] as List).single as Map<String, dynamic>;
        expect(run['passed'], isFalse);
        expect(
          run['harnessErrors'],
          contains(contains('fatal: not a git repository')),
        );
      },
    );
  });
}

Map<String, dynamic> _readJson(File file) =>
    jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

File _writeSingleCaseManifest(Directory directory) =>
    File(p.join(directory.path, 'single-case.json'))..writeAsStringSync(
      jsonEncode({
        'schemaVersion': 1,
        'tiers': {
          'smoke': {'defaultReplicas': 1},
        },
        'cases': [
          {
            'id': 'feature_positive',
            'skill': 'feature-scaffold',
            'category': 'positive_routing',
            'tier': 'smoke',
            'prompt': 'Create a BFF-backed eval_catalog page feature.',
            'invariants': [
              {'id': 'exit', 'kind': 'exit_code', 'value': 0},
            ],
          },
        ],
      }),
    );

String _successfulCodexOutput() => _codexOutputWithUsage({
  'input_tokens': 10,
  'cached_input_tokens': 0,
  'output_tokens': 5,
});

String _codexOutputWithUsage(Map<String, dynamic> usage) => [
  jsonEncode({
    'type': 'item.completed',
    'item': {'id': 'message-1', 'type': 'agent_message', 'text': 'Complete.'},
  }),
  jsonEncode({'type': 'turn.completed', 'usage': usage}),
].join('\n');

void _writeSummary(
  Directory directory, {
  required String label,
  required List<Map<String, dynamic>> runs,
}) {
  File(p.join(directory.path, 'run_summary.json')).writeAsStringSync(
    jsonEncode({
      'schemaVersion': 1,
      'label': label,
      'tiers': {
        'smoke': {'defaultReplicas': 1},
        'high_risk': {'defaultReplicas': 3},
      },
      'runs': runs,
    }),
  );
}

Map<String, dynamic> _summaryRun({
  required String caseId,
  int replica = 1,
  required String tier,
  required bool passed,
  required int totalTokens,
  required int toolCalls,
  required int elapsedMs,
  required Map<String, bool> invariants,
}) => {
  'caseId': caseId,
  'replica': replica,
  'tier': tier,
  'passed': passed,
  'usage': {
    'inputTokens': totalTokens - 10,
    'cachedInputTokens': 0,
    'outputTokens': 10,
    'totalTokens': totalTokens,
  },
  'toolCalls': toolCalls,
  'elapsedMs': elapsedMs,
  'invariants': invariants.entries
      .map(
        (entry) => {
          'id': entry.key,
          'kind': 'fixture',
          'passed': entry.value,
          'message': 'fixture',
        },
      )
      .toList(),
};

final class _FakeProcessExecutor implements ProcessExecutor {
  _FakeProcessExecutor({
    required this.codexOutput,
    this.gitDiffExitCode = 0,
    this.gitDiffStderr = '',
  });

  final String codexOutput;
  final int gitDiffExitCode;
  final String gitDiffStderr;
  final List<ProcessRequest> requests = [];
  List<String> codexWorkspaceEntries = [];

  @override
  Future<ProcessExecution> run(ProcessRequest request) async {
    requests.add(request);
    if (request.executable == 'codex' &&
        request.arguments.length == 1 &&
        request.arguments.single == '--version') {
      return const ProcessExecution(
        exitCode: 0,
        stdout: 'codex-cli 1.2.3\n',
        stderr: '',
      );
    }
    if (request.executable == 'codex') {
      codexWorkspaceEntries = Directory(request.workingDirectory)
          .listSync(recursive: true)
          .whereType<File>()
          .map((file) => p.relative(file.path, from: request.workingDirectory))
          .toList(growable: false);
      return ProcessExecution(exitCode: 0, stdout: codexOutput, stderr: '');
    }
    if (request.executable == 'git' && request.arguments.contains('diff')) {
      return ProcessExecution(
        exitCode: gitDiffExitCode,
        stdout: '',
        stderr: gitDiffStderr,
      );
    }
    return const ProcessExecution(exitCode: 0, stdout: '', stderr: '');
  }
}

final class _FailingProcessExecutor implements ProcessExecutor {
  @override
  Future<ProcessExecution> run(ProcessRequest request) {
    throw StateError('compare must not execute processes');
  }
}

final class _TimeoutThenSuccessProcessExecutor implements ProcessExecutor {
  final List<ProcessRequest> codexRequests = [];

  @override
  Future<ProcessExecution> run(ProcessRequest request) async {
    if (request.executable == 'codex' &&
        request.arguments == const ['--version']) {
      return const ProcessExecution(
        exitCode: 0,
        stdout: 'codex-cli test',
        stderr: '',
      );
    }
    if (request.executable == 'codex') {
      codexRequests.add(request);
      final timedOut = codexRequests.length == 1;
      return ProcessExecution(
        exitCode: timedOut ? 143 : 0,
        stdout: _successfulCodexOutput(),
        stderr: timedOut ? 'terminated' : '',
        timedOut: timedOut,
      );
    }
    return const ProcessExecution(exitCode: 0, stdout: '', stderr: '');
  }
}

final class _ControllableProcess implements Process {
  final Completer<int> _exitCode = Completer<int>();
  final List<ProcessSignal> signals = [];

  @override
  final IOSink stdin = IOSink(_DiscardStreamConsumer());

  @override
  Stream<List<int>> get stdout => const Stream.empty();

  @override
  Stream<List<int>> get stderr => const Stream.empty();

  @override
  Future<int> get exitCode => _exitCode.future;

  @override
  int get pid => 42;

  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
    signals.add(signal);
    if (!_exitCode.isCompleted) {
      _exitCode.complete(143);
    }
    return true;
  }
}

final class _DiscardStreamConsumer implements StreamConsumer<List<int>> {
  @override
  Future<void> addStream(Stream<List<int>> stream) async {
    await stream.drain<void>();
  }

  @override
  Future<void> close() async {}
}
