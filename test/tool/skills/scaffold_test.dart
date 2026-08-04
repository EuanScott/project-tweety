import 'dart:convert';
import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../../tool/templates/feature_template_paths.dart';
import '../../../tool/skills/scaffold/scaffold.dart';
import '../../../tool/skills/scaffold/scaffold.cli.dart';

void main() {
  group('ScaffoldGenerator', () {
    test(
      'renders the ordered no-domain BLoC manifest from canonical templates',
      () async {
        final fixture = await _ScaffoldFixture.create();
        addTearDown(fixture.dispose);

        final manifest =
            await ScaffoldGenerator(
              repositoryRoot: fixture.repositoryRoot,
            ).render(
              const ScaffoldRequest(
                feature: 'order_history',
                layers: {ScaffoldLayer.data, ScaffoldLayer.presentation},
                initialLoadOperation: 'load_orders',
              ),
            );

        expect(manifest.files.map((file) => file.path), [
          'lib/data/repositories/order_history/order_history.repository.dart',
          'lib/data/repositories/order_history/order_history.repository_impl.dart',
          'lib/presentation/pages/order_history/order_history.page.dart',
          'lib/presentation/pages/order_history/widgets/order_history_view.widget.dart',
          'lib/presentation/pages/order_history/bloc/order_history.bloc.dart',
          'lib/presentation/pages/order_history/bloc/order_history.event.dart',
          'lib/presentation/pages/order_history/bloc/order_history.state.dart',
        ]);
        expect(
          manifest.files.first.content,
          '''abstract class OrderHistoryRepository {
  Future<void> loadOrders();
}
''',
        );
        expect(
          manifest.files[1].content,
          contains("import 'order_history.repository.dart';"),
        );
        expect(
          manifest.files[2].content,
          allOf(
            contains("part 'widgets/order_history_view.widget.dart';"),
            isNot(contains('class _OrderHistoryView')),
          ),
        );
        expect(
          manifest.files[3].content,
          allOf(
            contains("part of '../order_history.page.dart';"),
            contains('class _OrderHistoryView extends StatelessWidget'),
            contains('BlocBuilder<OrderHistoryBloc, OrderHistoryState>'),
          ),
        );
        expect(
          manifest.files[4].content,
          contains(
            "import 'package:project_tweety/data/repositories/order_history/"
            "order_history.repository.dart';",
          ),
        );
        expect(
          manifest.files[4].content,
          contains('await _repository.loadOrders();'),
        );
        expect(
          manifest.files.every((file) => !file.path.endsWith('.freezed.dart')),
          isTrue,
        );
        expect(
          manifest.files.every(
            (file) =>
                !file.content.contains('Template') &&
                !file.content.contains('_template'),
          ),
          isTrue,
        );
      },
    );

    test(
      'rejects domain scaffolding before reading or writing any file',
      () async {
        final repositoryRoot = await Directory.systemTemp.createTemp(
          'project_tweety_scaffold_domain_',
        );
        addTearDown(() => repositoryRoot.delete(recursive: true));

        await expectLater(
          ScaffoldGenerator(repositoryRoot: repositoryRoot).render(
            const ScaffoldRequest(
              feature: 'order_history',
              layers: {
                ScaffoldLayer.data,
                ScaffoldLayer.presentation,
                ScaffoldLayer.domain,
              },
              initialLoadOperation: 'load_orders',
              domainReason: 'The app owns offline ordering policy.',
            ),
          ),
          throwsA(
            isA<ScaffoldException>()
                .having(
                  (error) => error.code,
                  'code',
                  'domain_not_deterministic',
                )
                .having(
                  (error) => error.message,
                  'message',
                  allOf(contains(r'$domain-scaffold'), contains('/implement')),
                ),
          ),
        );
        expect(await repositoryRoot.list(recursive: true).toList(), isEmpty);
      },
    );

    test(
      'rejects unsafe feature, folder, and initial load operation names',
      () async {
        final repositoryRoot = await Directory.systemTemp.createTemp(
          'project_tweety_scaffold_names_',
        );
        addTearDown(() => repositoryRoot.delete(recursive: true));
        final generator = ScaffoldGenerator(repositoryRoot: repositoryRoot);
        final invalidRequests = [
          const ScaffoldRequest(
            feature: '../orders',
            layers: {ScaffoldLayer.data, ScaffoldLayer.presentation},
            initialLoadOperation: 'load_orders',
          ),
          const ScaffoldRequest(
            feature: 'orders',
            folderKey: 'order/history',
            layers: {ScaffoldLayer.data, ScaffoldLayer.presentation},
            initialLoadOperation: 'load_orders',
          ),
          const ScaffoldRequest(
            feature: 'orders',
            layers: {ScaffoldLayer.data, ScaffoldLayer.presentation},
            initialLoadOperation: 'load__orders',
          ),
          const ScaffoldRequest(
            feature: 'orders',
            layers: {ScaffoldLayer.data, ScaffoldLayer.presentation},
            initialLoadOperation: 'class',
          ),
          const ScaffoldRequest(
            feature: 'orders',
            layers: {ScaffoldLayer.data, ScaffoldLayer.presentation},
            initialLoadOperation: 'to_string',
          ),
          const ScaffoldRequest(
            feature: 'orders',
            layers: {ScaffoldLayer.data, ScaffoldLayer.presentation},
            initialLoadOperation: 'hash_code',
          ),
          const ScaffoldRequest(
            feature: 'orders',
            layers: {ScaffoldLayer.data, ScaffoldLayer.presentation},
            initialLoadOperation: 'runtime_type',
          ),
          const ScaffoldRequest(
            feature: 'orders',
            layers: {ScaffoldLayer.data, ScaffoldLayer.presentation},
            initialLoadOperation: 'no_such_method',
          ),
        ];

        for (final request in invalidRequests) {
          await expectLater(
            generator.render(request),
            throwsA(
              isA<ScaffoldException>().having(
                (error) => error.code,
                'code',
                'invalid_name',
              ),
            ),
          );
        }
        expect(await repositoryRoot.list(recursive: true).toList(), isEmpty);
      },
    );

    test(
      'rejects unsupported layer sets and misplaced domain reasons',
      () async {
        final repositoryRoot = await Directory.systemTemp.createTemp(
          'project_tweety_scaffold_layers_',
        );
        addTearDown(() => repositoryRoot.delete(recursive: true));
        final generator = ScaffoldGenerator(repositoryRoot: repositoryRoot);

        await expectLater(
          generator.render(
            const ScaffoldRequest(
              feature: 'orders',
              layers: {ScaffoldLayer.data},
              initialLoadOperation: 'load_orders',
            ),
          ),
          throwsA(
            isA<ScaffoldException>().having(
              (error) => error.code,
              'code',
              'unsupported_layers',
            ),
          ),
        );
        await expectLater(
          generator.render(
            const ScaffoldRequest(
              feature: 'orders',
              layers: {ScaffoldLayer.data, ScaffoldLayer.presentation},
              initialLoadOperation: 'load_orders',
              domainReason: 'Offline ordering.',
            ),
          ),
          throwsA(
            isA<ScaffoldException>().having(
              (error) => error.code,
              'code',
              'domain_reason_without_domain',
            ),
          ),
        );
        expect(await repositoryRoot.list(recursive: true).toList(), isEmpty);
      },
    );

    test('renders the explicit Cubit manifest without BLoC artifacts', () async {
      final fixture = await _ScaffoldFixture.create();
      addTearDown(fixture.dispose);

      final manifest =
          await ScaffoldGenerator(
            repositoryRoot: fixture.repositoryRoot,
          ).render(
            const ScaffoldRequest(
              feature: 'order_history',
              layers: {ScaffoldLayer.data, ScaffoldLayer.presentation},
              initialLoadOperation: 'load_orders',
              controller: ScaffoldController.cubit,
            ),
          );

      expect(manifest.files.map((file) => file.path), [
        'lib/data/repositories/order_history/order_history.repository.dart',
        'lib/data/repositories/order_history/order_history.repository_impl.dart',
        'lib/presentation/pages/order_history/order_history.page.dart',
        'lib/presentation/pages/order_history/widgets/order_history_view.widget.dart',
        'lib/presentation/pages/order_history/cubit/order_history.cubit.dart',
        'lib/presentation/pages/order_history/cubit/order_history.state.dart',
      ]);
      expect(
        manifest.files[2].content,
        allOf(
          contains("import 'cubit/order_history.cubit.dart';"),
          contains('GetIt.I<OrderHistoryCubit>()..loadOrders()'),
          contains("part 'widgets/order_history_view.widget.dart';"),
        ),
      );
      expect(
        manifest.files[3].content,
        allOf(
          contains("part of '../order_history.page.dart';"),
          contains('BlocBuilder<OrderHistoryCubit, OrderHistoryState>'),
        ),
      );
      expect(
        manifest.files[4].content,
        allOf(
          contains('class OrderHistoryCubit extends Cubit<OrderHistoryState>'),
          contains('Future<void> loadOrders() async'),
          contains('await _repository.loadOrders();'),
          contains("part 'order_history.cubit.freezed.dart';"),
        ),
      );
      expect(
        manifest.files.every(
          (file) =>
              !file.path.endsWith('.bloc.dart') &&
              !file.path.endsWith('.event.dart') &&
              !file.path.endsWith('.freezed.dart'),
        ),
        isTrue,
      );
      final formatter = DartFormatter(
        languageVersion: DartFormatter.latestLanguageVersion,
      );
      for (final file in manifest.files) {
        expect(
          formatter.format(file.content, uri: file.path),
          file.content,
          reason: '${file.path} must be formatter-stable for --check',
        );
      }
    });

    test(
      'reports the first missing canonical template deterministically',
      () async {
        final repositoryRoot = await Directory.systemTemp.createTemp(
          'project_tweety_scaffold_missing_template_',
        );
        addTearDown(() => repositoryRoot.delete(recursive: true));

        await expectLater(
          ScaffoldGenerator(repositoryRoot: repositoryRoot).render(
            const ScaffoldRequest(
              feature: 'orders',
              layers: {ScaffoldLayer.data, ScaffoldLayer.presentation},
              initialLoadOperation: 'load_orders',
            ),
          ),
          throwsA(
            isA<ScaffoldException>()
                .having((error) => error.code, 'code', 'template_missing')
                .having((error) => error.paths, 'paths', [
                  featureRepositoryContractTemplate,
                ]),
          ),
        );
      },
    );

    test('uses the explicit folder key in canonical BLoC imports', () async {
      final fixture = await _ScaffoldFixture.create();
      addTearDown(fixture.dispose);

      final manifest =
          await ScaffoldGenerator(
            repositoryRoot: fixture.repositoryRoot,
          ).render(
            const ScaffoldRequest(
              feature: 'orders',
              folderKey: 'commerce',
              layers: {ScaffoldLayer.data, ScaffoldLayer.presentation},
              initialLoadOperation: 'load_orders',
            ),
          );

      expect(
        manifest.files[4].content,
        contains(
          "import 'package:project_tweety/data/repositories/commerce/"
          "orders.repository.dart';",
        ),
      );
    });

    test(
      'does not reprocess replacement tokens inside supplied names',
      () async {
        final fixture = await _ScaffoldFixture.create();
        addTearDown(fixture.dispose);

        final manifest =
            await ScaffoldGenerator(
              repositoryRoot: fixture.repositoryRoot,
            ).render(
              const ScaffoldRequest(
                feature: 'my_template',
                folderKey: 'template_tools',
                layers: {ScaffoldLayer.data, ScaffoldLayer.presentation},
                initialLoadOperation: 'load_template',
              ),
            );

        expect(
          manifest.files.first.path,
          'lib/data/repositories/template_tools/my_template.repository.dart',
        );
        expect(
          manifest.files.first.content,
          contains('Future<void> loadTemplate();'),
        );
        expect(
          manifest.files[4].content,
          contains(
            "import 'package:project_tweety/data/repositories/template_tools/"
            "my_template.repository.dart';",
          ),
        );
        expect(
          manifest.files.every(
            (file) =>
                !file.content.contains('loadMyTemplate') &&
                !file.content.contains('mymy_template'),
          ),
          isTrue,
        );
      },
    );

    test(
      'rejects initial load operations that collide with inherited Cubit members',
      () async {
        final fixture = await _ScaffoldFixture.create();
        addTearDown(fixture.dispose);
        const operations = [
          'emit',
          'state',
          'stream',
          'add_error',
          'is_closed',
          'close',
          'on_change',
          'on_error',
        ];
        final generator = ScaffoldGenerator(
          repositoryRoot: fixture.repositoryRoot,
        );

        for (final operation in operations) {
          await expectLater(
            generator.render(
              ScaffoldRequest(
                feature: 'orders',
                layers: const {ScaffoldLayer.data, ScaffoldLayer.presentation},
                initialLoadOperation: operation,
                controller: ScaffoldController.cubit,
              ),
            ),
            throwsA(
              isA<ScaffoldException>().having(
                (error) => error.code,
                'code',
                'invalid_name',
              ),
            ),
            reason: operation,
          );
        }
      },
    );

    test('rejects destructive operations as automatic initial loads', () async {
      final fixture = await _ScaffoldFixture.create();
      addTearDown(fixture.dispose);
      const operations = [
        'delete_orders',
        'save_orders',
        'update_orders',
        'create_order',
        'submit_order',
      ];
      final generator = ScaffoldGenerator(
        repositoryRoot: fixture.repositoryRoot,
      );

      for (final operation in operations) {
        await expectLater(
          generator.render(
            ScaffoldRequest(
              feature: 'orders',
              layers: const {ScaffoldLayer.data, ScaffoldLayer.presentation},
              initialLoadOperation: operation,
            ),
          ),
          throwsA(
            isA<ScaffoldException>().having(
              (error) => error.code,
              'code',
              'unsafe_initial_load_operation',
            ),
          ),
          reason: operation,
        );
      }
    });

    test('accepts supported read-only initial load verbs', () async {
      final fixture = await _ScaffoldFixture.create();
      addTearDown(fixture.dispose);
      const verbs = [
        'load',
        'fetch',
        'get',
        'list',
        'read',
        'watch',
        'refresh',
      ];
      final generator = ScaffoldGenerator(
        repositoryRoot: fixture.repositoryRoot,
      );

      for (final verb in verbs) {
        final manifest = await generator.render(
          ScaffoldRequest(
            feature: 'orders',
            layers: const {ScaffoldLayer.data, ScaffoldLayer.presentation},
            initialLoadOperation: '${verb}_orders',
          ),
        );
        final expectedMethod = '${verb}Orders';
        expect(
          manifest.files.first.content,
          contains('Future<void> $expectedMethod();'),
          reason: verb,
        );
        expect(
          manifest.files[4].content,
          contains('await _repository.$expectedMethod();'),
          reason: verb,
        );
      }
    });
  });

  group('ScaffoldExecutor', () {
    test('defaults to a side-effect-free dry run', () async {
      final fixture = await _ScaffoldFixture.create();
      addTearDown(fixture.dispose);
      final manifest = await fixture.renderOrders();

      final result = await ScaffoldExecutor(
        repositoryRoot: fixture.repositoryRoot,
      ).execute(manifest);

      expect(result.mode, ScaffoldMode.dryRun);
      expect(result.status, ScaffoldStatus.planned);
      expect(result.manifest, same(manifest));
      for (final artifact in manifest.files) {
        expect(
          File(p.join(fixture.repositoryRoot.path, artifact.path)).existsSync(),
          isFalse,
        );
      }
    });

    test('writes every rendered source file with exact content', () async {
      final fixture = await _ScaffoldFixture.create();
      addTearDown(fixture.dispose);
      final manifest = await fixture.renderOrders();

      final result = await ScaffoldExecutor(
        repositoryRoot: fixture.repositoryRoot,
      ).execute(manifest, mode: ScaffoldMode.write);

      expect(result.status, ScaffoldStatus.written);
      for (final artifact in manifest.files) {
        final target = File(p.join(fixture.repositoryRoot.path, artifact.path));
        expect(target.readAsStringSync(), artifact.content);
      }
    });

    test(
      'default commit renames staged content over the reserved target',
      () async {
        final fixture = await _ScaffoldFixture.create();
        addTearDown(fixture.dispose);
        final manifest = ScaffoldManifest([
          const ScaffoldFile(
            path: 'generated/source.dart',
            content: 'staged content',
          ),
        ]);
        RandomAccessFile? reservedHandle;
        addTearDown(() async {
          await reservedHandle?.close();
        });
        final executor = ScaffoldExecutor(
          repositoryRoot: fixture.repositoryRoot,
          reserve: (target) async {
            await target.create(exclusive: true);
            reservedHandle = await target.open(mode: FileMode.read);
          },
        );

        await executor.execute(manifest, mode: ScaffoldMode.write);

        final target = File(
          p.join(fixture.repositoryRoot.path, 'generated/source.dart'),
        );
        expect(target.readAsStringSync(), 'staged content');
        expect(await reservedHandle!.length(), 0);
      },
    );

    test(
      'preflights every target and makes no partial write on conflict',
      () async {
        final fixture = await _ScaffoldFixture.create();
        addTearDown(fixture.dispose);
        final manifest = await fixture.renderOrders();
        final conflict = File(
          p.join(fixture.repositoryRoot.path, manifest.files.last.path),
        );
        await conflict.parent.create(recursive: true);
        await conflict.writeAsString('user-owned');

        await expectLater(
          ScaffoldExecutor(
            repositoryRoot: fixture.repositoryRoot,
          ).execute(manifest, mode: ScaffoldMode.write),
          throwsA(
            isA<ScaffoldException>()
                .having((error) => error.code, 'code', 'targets_exist')
                .having((error) => error.paths, 'paths', [
                  manifest.files.last.path,
                ]),
          ),
        );

        for (final artifact in manifest.files.take(manifest.files.length - 1)) {
          expect(
            File(
              p.join(fixture.repositoryRoot.path, artifact.path),
            ).existsSync(),
            isFalse,
          );
        }
        expect(conflict.readAsStringSync(), 'user-owned');
      },
    );

    test('rejects manifest paths that escape the repository root', () async {
      final fixture = await _ScaffoldFixture.create();
      addTearDown(fixture.dispose);
      final escaped = File(
        p.join(fixture.repositoryRoot.parent.path, 'escaped.dart'),
      );
      addTearDown(() async {
        if (await escaped.exists()) {
          await escaped.delete();
        }
      });
      final manifest = ScaffoldManifest([
        const ScaffoldFile(path: '../escaped.dart', content: 'unsafe'),
      ]);

      await expectLater(
        ScaffoldExecutor(
          repositoryRoot: fixture.repositoryRoot,
        ).execute(manifest, mode: ScaffoldMode.write),
        throwsA(
          isA<ScaffoldException>().having(
            (error) => error.code,
            'code',
            'invalid_manifest_path',
          ),
        ),
      );
      expect(await escaped.exists(), isFalse);
    });

    test('preflights parent paths before committing any target', () async {
      final fixture = await _ScaffoldFixture.create();
      addTearDown(fixture.dispose);
      final blockedParent = File(
        p.join(fixture.repositoryRoot.path, 'blocked'),
      );
      await blockedParent.writeAsString('not-a-directory');
      final manifest = ScaffoldManifest([
        const ScaffoldFile(path: 'targets/first.dart', content: 'first'),
        const ScaffoldFile(path: 'blocked/second.dart', content: 'second'),
      ]);

      await expectLater(
        ScaffoldExecutor(
          repositoryRoot: fixture.repositoryRoot,
        ).execute(manifest, mode: ScaffoldMode.write),
        throwsA(
          isA<ScaffoldException>().having(
            (error) => error.code,
            'code',
            'parent_not_directory',
          ),
        ),
      );
      expect(
        File(
          p.join(fixture.repositoryRoot.path, 'targets/first.dart'),
        ).existsSync(),
        isFalse,
      );
      expect(blockedParent.readAsStringSync(), 'not-a-directory');
    });

    test('rolls back targets when a staged commit fails', () async {
      final fixture = await _ScaffoldFixture.create();
      addTearDown(fixture.dispose);
      final manifest = ScaffoldManifest([
        const ScaffoldFile(path: 'generated/first.dart', content: 'first'),
        const ScaffoldFile(path: 'generated/second.dart', content: 'second'),
      ]);
      var commits = 0;
      final executor = ScaffoldExecutor(
        repositoryRoot: fixture.repositoryRoot,
        commit: (staged, target) async {
          commits++;
          if (commits == 2) {
            throw const FileSystemException('synthetic commit failure');
          }
          await staged.rename(target.path);
        },
      );

      await expectLater(
        executor.execute(manifest, mode: ScaffoldMode.write),
        throwsA(
          isA<ScaffoldException>().having(
            (error) => error.code,
            'code',
            'write_failed',
          ),
        ),
      );
      expect(
        File(
          p.join(fixture.repositoryRoot.path, 'generated/first.dart'),
        ).existsSync(),
        isFalse,
      );
      expect(
        File(
          p.join(fixture.repositoryRoot.path, 'generated/second.dart'),
        ).existsSync(),
        isFalse,
      );
      expect(
        fixture.repositoryRoot.listSync().where(
          (entry) => p.basename(entry.path).startsWith('.scaffold_stage_'),
        ),
        isEmpty,
      );
    });

    test(
      'rollback preserves a competing target that was never reserved',
      () async {
        final fixture = await _ScaffoldFixture.create();
        addTearDown(fixture.dispose);
        final manifest = ScaffoldManifest([
          const ScaffoldFile(path: 'generated/first.dart', content: 'first'),
          const ScaffoldFile(path: 'generated/second.dart', content: 'second'),
        ]);
        var reservations = 0;
        final executor = ScaffoldExecutor(
          repositoryRoot: fixture.repositoryRoot,
          reserve: (target) async {
            reservations++;
            if (reservations == 2) {
              await target.writeAsString('competing writer');
              throw const FileSystemException('target won by another writer');
            }
            await target.create(exclusive: true);
          },
        );

        await expectLater(
          executor.execute(manifest, mode: ScaffoldMode.write),
          throwsA(
            isA<ScaffoldException>().having(
              (error) => error.code,
              'code',
              'write_failed',
            ),
          ),
        );
        expect(
          File(
            p.join(fixture.repositoryRoot.path, 'generated/first.dart'),
          ).existsSync(),
          isFalse,
        );
        expect(
          File(
            p.join(fixture.repositoryRoot.path, 'generated/second.dart'),
          ).readAsStringSync(),
          'competing writer',
        );
      },
    );

    test('check reports ordered source drift without changing files', () async {
      final fixture = await _ScaffoldFixture.create();
      addTearDown(fixture.dispose);
      final manifest = await fixture.renderOrders();
      final executor = ScaffoldExecutor(repositoryRoot: fixture.repositoryRoot);
      await executor.execute(manifest, mode: ScaffoldMode.write);

      final clean = await executor.execute(manifest, mode: ScaffoldMode.check);
      expect(clean.status, ScaffoldStatus.clean);
      expect(clean.drift, isEmpty);

      final mismatch = File(
        p.join(fixture.repositoryRoot.path, manifest.files[1].path),
      );
      final missing = File(
        p.join(fixture.repositoryRoot.path, manifest.files[4].path),
      );
      await mismatch.writeAsString('user edit');
      await missing.delete();

      final drifted = await executor.execute(
        manifest,
        mode: ScaffoldMode.check,
      );

      expect(drifted.status, ScaffoldStatus.drift);
      expect(drifted.drift.map((drift) => (drift.path, drift.kind)), [
        (manifest.files[1].path, ScaffoldDriftKind.contentMismatch),
        (manifest.files[4].path, ScaffoldDriftKind.missing),
      ]);
      expect(mismatch.readAsStringSync(), 'user edit');
      expect(missing.existsSync(), isFalse);
    });
  });

  group('ScaffoldCli', () {
    test(
      'defaults to dry-run and emits a deterministic JSON manifest',
      () async {
        final fixture = await _ScaffoldFixture.create();
        addTearDown(fixture.dispose);
        final output = <String>[];
        final errors = <String>[];

        final exitCode =
            await ScaffoldCli(
              repositoryRoot: fixture.repositoryRoot,
              writeOutput: output.add,
              writeError: errors.add,
            ).run([
              '--feature',
              'orders',
              '--layers',
              'data,presentation',
              '--initial-load-operation',
              'load_orders',
            ]);

        expect(exitCode, 0);
        expect(errors, isEmpty);
        expect(output, hasLength(1));
        final result = jsonDecode(output.single) as Map<String, dynamic>;
        expect(result, containsPair('ok', true));
        expect(result, containsPair('mode', 'dryRun'));
        expect(result, containsPair('status', 'planned'));
        expect(
          (result['files'] as List).cast<Map<String, dynamic>>().map(
            (file) => file['path'],
          ),
          [
            'lib/data/repositories/orders/orders.repository.dart',
            'lib/data/repositories/orders/orders.repository_impl.dart',
            'lib/presentation/pages/orders/orders.page.dart',
            'lib/presentation/pages/orders/widgets/orders_view.widget.dart',
            'lib/presentation/pages/orders/bloc/orders.bloc.dart',
            'lib/presentation/pages/orders/bloc/orders.event.dart',
            'lib/presentation/pages/orders/bloc/orders.state.dart',
          ],
        );
        expect(
          File(
            p.join(fixture.repositoryRoot.path, 'lib/data/repositories/orders'),
          ).existsSync(),
          isFalse,
        );
      },
    );

    test('writes and checks the explicit folder and Cubit variant', () async {
      final fixture = await _ScaffoldFixture.create();
      addTearDown(fixture.dispose);
      final output = <String>[];
      final errors = <String>[];
      final cli = ScaffoldCli(
        repositoryRoot: fixture.repositoryRoot,
        writeOutput: output.add,
        writeError: errors.add,
      );
      const baseArguments = [
        '--feature',
        'orders',
        '--folder-key',
        'commerce',
        '--layers',
        'data,presentation',
        '--initial-load-operation',
        'load_orders',
        '--controller',
        'cubit',
      ];

      expect(await cli.run([...baseArguments, '--write']), 0);
      expect(errors, isEmpty);
      expect(
        File(
          p.join(
            fixture.repositoryRoot.path,
            'lib/data/repositories/commerce/orders.repository.dart',
          ),
        ).existsSync(),
        isTrue,
      );
      final cubit = File(
        p.join(
          fixture.repositoryRoot.path,
          'lib/presentation/pages/orders/cubit/orders.cubit.dart',
        ),
      );
      expect(cubit.existsSync(), isTrue);
      await cubit.writeAsString('drift');
      output.clear();

      expect(await cli.run([...baseArguments, '--check']), 1);
      final result = jsonDecode(output.single) as Map<String, dynamic>;
      expect(result, containsPair('status', 'drift'));
      expect(result['drift'], [
        {
          'path': 'lib/presentation/pages/orders/cubit/orders.cubit.dart',
          'kind': 'contentMismatch',
        },
      ]);
      expect(cubit.readAsStringSync(), 'drift');
    });

    test(
      'rejects domain writes with a structured error and zero targets',
      () async {
        final fixture = await _ScaffoldFixture.create();
        addTearDown(fixture.dispose);
        final output = <String>[];
        final errors = <String>[];

        final exitCode =
            await ScaffoldCli(
              repositoryRoot: fixture.repositoryRoot,
              writeOutput: output.add,
              writeError: errors.add,
            ).run([
              '--feature',
              'orders',
              '--layers',
              'data,presentation,domain',
              '--initial-load-operation',
              'load_orders',
              '--domain-reason',
              'The app owns offline ordering policy.',
              '--write',
            ]);

        expect(exitCode, 1);
        expect(output, isEmpty);
        final error = jsonDecode(errors.single) as Map<String, dynamic>;
        expect(
          error['error'],
          containsPair('code', 'domain_not_deterministic'),
        );
        expect(
          File(p.join(fixture.repositoryRoot.path, 'lib/domain')).existsSync(),
          isFalse,
        );
        expect(
          File(
            p.join(fixture.repositoryRoot.path, 'lib/data/repositories/orders'),
          ).existsSync(),
          isFalse,
        );
      },
    );

    test('returns usage errors for ambiguous or unknown options', () async {
      final fixture = await _ScaffoldFixture.create();
      addTearDown(fixture.dispose);
      final errors = <String>[];
      final cli = ScaffoldCli(
        repositoryRoot: fixture.repositoryRoot,
        writeOutput: (_) {},
        writeError: errors.add,
      );

      final exitCode = await cli.run([
        '--feature',
        'orders',
        '--layers',
        'data,presentation',
        '--initial-load-operation',
        'load_orders',
        '--controller',
        'not-a-controller',
        '--dry-run',
        '--write',
      ]);

      expect(exitCode, 64);
      final error = jsonDecode(errors.single) as Map<String, dynamic>;
      expect(error['error'], containsPair('code', 'invalid_arguments'));
    });

    test('rejects the old generic operation option', () async {
      final fixture = await _ScaffoldFixture.create();
      addTearDown(fixture.dispose);
      final errors = <String>[];

      final exitCode =
          await ScaffoldCli(
            repositoryRoot: fixture.repositoryRoot,
            writeOutput: (_) {},
            writeError: errors.add,
          ).run([
            '--feature',
            'orders',
            '--layers',
            'data,presentation',
            '--operation',
            'load_orders',
          ]);

      expect(exitCode, 64);
      final error = jsonDecode(errors.single) as Map<String, dynamic>;
      expect(error['error'], containsPair('code', 'invalid_arguments'));
    });
  });
}

class _ScaffoldFixture {
  _ScaffoldFixture._(this.repositoryRoot);

  final Directory repositoryRoot;

  static Future<_ScaffoldFixture> create() async {
    final repositoryRoot = await Directory.systemTemp.createTemp(
      'project_tweety_scaffold_',
    );
    final fixture = _ScaffoldFixture._(repositoryRoot);
    await fixture._copyCanonicalTemplates();
    return fixture;
  }

  Future<void> dispose() => repositoryRoot.delete(recursive: true);

  Future<ScaffoldManifest> renderOrders() =>
      ScaffoldGenerator(repositoryRoot: repositoryRoot).render(
        const ScaffoldRequest(
          feature: 'orders',
          layers: {ScaffoldLayer.data, ScaffoldLayer.presentation},
          initialLoadOperation: 'load_orders',
        ),
      );

  Future<void> _copyCanonicalTemplates() async {
    const paths = featureProductionTemplatePaths;

    for (final path in paths) {
      final target = File(p.join(repositoryRoot.path, path));
      await target.parent.create(recursive: true);
      await File(path).copy(target.path);
    }
  }
}
