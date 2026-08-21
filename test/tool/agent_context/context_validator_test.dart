import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/agent_context/context.validator.dart';
import '../../../tool/templates/feature_template_paths.dart';

void main() {
  group('ContextValidator', () {
    test('accepts a lean linked context hierarchy', () async {
      final fixture = await _ContextFixture.create();
      addTearDown(fixture.dispose);

      final result = ContextValidator(repositoryRoot: fixture.repositoryRoot)
          .validate();

      expect(result.isValid, isTrue);
    });

    test('rejects an instruction file that exceeds its budget', () async {
      final fixture = await _ContextFixture.create();
      addTearDown(fixture.dispose);
      await fixture.write('lib/AGENTS.md', List.filled(51, 'Rule').join('\n'));

      final result = ContextValidator(repositoryRoot: fixture.repositoryRoot)
          .validate();

      expect(
        result.diagnostics.map((diagnostic) => diagnostic.code),
        contains('agents.lines.scoped'),
      );
    });

    test(
      'leaves skill-governance instructions outside the line budget',
      () async {
        final fixture = await _ContextFixture.create();
        addTearDown(fixture.dispose);
        await fixture.write(
          '.codex/skills/AGENTS.md',
          List.filled(51, 'Skill guidance').join('\n'),
        );

        final result = ContextValidator(repositoryRoot: fixture.repositoryRoot)
            .validate();

        expect(result.isValid, isTrue);
      },
    );

    test('rejects a broken local Markdown reference', () async {
      final fixture = await _ContextFixture.create();
      addTearDown(fixture.dispose);
      await fixture.write('lib/AGENTS.md', '[Missing](../docs/missing.md)');

      final result = ContextValidator(repositoryRoot: fixture.repositoryRoot)
          .validate();

      expect(
        result.diagnostics.map((diagnostic) => diagnostic.code),
        contains('reference.missing'),
      );
    });

    test('rejects a broken root Markdown reference', () async {
      final fixture = await _ContextFixture.create();
      addTearDown(fixture.dispose);
      await fixture.write('AGENTS.md', '[Missing](docs/missing.md)');

      final result = ContextValidator(repositoryRoot: fixture.repositoryRoot)
          .validate();

      expect(
        result.diagnostics.map((diagnostic) => diagnostic.code),
        contains('reference.missing'),
      );
    });

    test('rejects a missing source map', () async {
      final fixture = await _ContextFixture.create();
      addTearDown(fixture.dispose);
      await File('${fixture.repositoryRoot.path}/docs/source_map.md').delete();

      final result = ContextValidator(repositoryRoot: fixture.repositoryRoot)
          .validate();

      expect(
        result.diagnostics.map((diagnostic) => diagnostic.code),
        contains('source-map.missing'),
      );
    });

    test('rejects a broken source map Markdown reference', () async {
      final fixture = await _ContextFixture.create();
      addTearDown(fixture.dispose);
      await fixture.write('docs/source_map.md', '[Missing](missing.md)');

      final result = ContextValidator(repositoryRoot: fixture.repositoryRoot)
          .validate();

      expect(
        result.diagnostics.map((diagnostic) => diagnostic.code),
        contains('reference.missing'),
      );
    });

    test('rejects generated Dart beneath canonical templates', () async {
      final fixture = await _ContextFixture.create();
      addTearDown(fixture.dispose);
      await fixture.write(
        'tool/templates/feature/_template.freezed.dart',
        '// generated',
      );

      final result = ContextValidator(repositoryRoot: fixture.repositoryRoot)
          .validate();

      expect(
        result.diagnostics.map((diagnostic) => diagnostic.code),
        contains('template.generated.forbidden'),
      );
    });

    test('rejects a missing canonical template', () async {
      final fixture = await _ContextFixture.create();
      addTearDown(fixture.dispose);
      await File('${fixture.repositoryRoot.path}/$featurePageTemplate')
          .delete();

      final result = ContextValidator(repositoryRoot: fixture.repositoryRoot)
          .validate();

      expect(
        result.diagnostics.map((diagnostic) => diagnostic.code),
        contains('template.missing'),
      );
    });
  });
}

final class _ContextFixture {
  new _(this.repositoryRoot);

  final Directory repositoryRoot;

  static Future<_ContextFixture> create() async {
    final root = await Directory.systemTemp.createTemp(
      'project_tweety_context_',
    );
    final fixture = _ContextFixture._(root);
    await fixture.write(
      'AGENTS.md',
      '[Feature template](tool/templates/feature/data/repositories/_template.repository.dart)',
    );
    await fixture.write('lib/AGENTS.md', '[Project guide](../AGENTS.md)');
    await fixture.write('docs/guide.md', '# Guide');
    await fixture.write('docs/source_map.md', '[Guide](guide.md)');
    for (final path in [
      ...featureProductionTemplatePaths,
      ...featureTestReferenceTemplatePaths,
    ]) {
      await fixture.write(path, '');
    }
    return fixture;
  }

  Future<void> write(String path, String contents) async {
    final file = File('${repositoryRoot.path}/$path');
    await file.parent.create(recursive: true);
    await file.writeAsString(contents);
  }

  Future<void> dispose() => repositoryRoot.delete(recursive: true);
}
