import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../../tool/naming/naming.validator.dart';

void main() {
  group('NamingValidator', () {
    test('accepts an official role and rejects a name without one', () async {
      final fixture = await _NamingFixture.create();
      addTearDown(fixture.dispose);
      await fixture.write('lib/cards/cards.page.dart');
      await fixture.write('lib/home/home_bloc.dart');

      final result = fixture.validate([
        'lib/cards/cards.page.dart',
        'lib/home/home_bloc.dart',
      ]);

      expect(result.isValid, isFalse);
      expect(result.diagnostics, hasLength(1));
      final diagnostic = result.diagnostics.single;
      expect(diagnostic.code, 'naming.role.missing');
      expect(diagnostic.path, 'lib/home/home_bloc.dart');
      expect(diagnostic.message, contains('feature_or_entity.role.dart'));
    });

    test('rejects a role that AGENTS.md does not list', () async {
      final fixture = await _NamingFixture.create();
      addTearDown(fixture.dispose);
      await fixture.write('lib/about/about.prototype.dart');

      final result = fixture.validate(['lib/about/about.prototype.dart']);

      expect(result.diagnostics.single.code, 'naming.role.unknown');
      expect(result.diagnostics.single.message, contains('.prototype'));
    });

    test('accepts tooling roles only under tool/', () async {
      final fixture = await _NamingFixture.create();
      addTearDown(fixture.dispose);
      await fixture.write('tool/naming/naming.validator.dart');
      await fixture.write('lib/forms/form.validator.dart');

      final result = fixture.validate([
        'tool/naming/naming.validator.dart',
        'lib/forms/form.validator.dart',
      ]);

      expect(result.diagnostics.single.code, 'naming.role.tool_only');
      expect(result.diagnostics.single.path, 'lib/forms/form.validator.dart');
    });

    test('checks the role before _test and keeps flow for tests', () async {
      final fixture = await _NamingFixture.create();
      addTearDown(fixture.dispose);
      const paths = [
        'test/cards/cards.bloc_test.dart',
        'test/cards/navigation.flow_test.dart',
        'test/tool/naming/naming.validator_test.dart',
        'test/cards/cards_list_test.dart',
        'lib/app/startup.flow.dart',
      ];
      for (final path in paths) {
        await fixture.write(path);
      }

      final result = fixture.validate(paths);

      expect(
        result.diagnostics.map((d) => (d.code, d.path)),
        unorderedEquals([
          ('naming.role.missing', 'test/cards/cards_list_test.dart'),
          ('naming.role.test_only', 'lib/app/startup.flow.dart'),
        ]),
      );
    });

    test('exempts generated output', () async {
      final fixture = await _NamingFixture.create();
      addTearDown(fixture.dispose);
      const paths = [
        'lib/home/bloc/home.bloc.freezed.dart',
        'lib/data/cards.dto.g.dart',
        'lib/core/di/dependency_injection.config.dart',
        'lib/l10n/app_localizations.dart',
        'lib/l10n/app_localizations_en.dart',
      ];
      for (final path in paths) {
        await fixture.write(path);
      }

      expect(fixture.validate(paths).diagnostics, isEmpty);
    });

    test('exempts entry points but not tests that declare main', () async {
      final fixture = await _NamingFixture.create();
      addTearDown(fixture.dispose);
      await fixture.write('lib/main.dart', 'Future<void> main() async {}\n');
      await fixture.write(
        'tool/skills/validate.dart',
        'void main(List<String> arguments) {}\n',
      );
      await fixture.write('test/cards/legacy_test.dart', 'void main() {}\n');

      final result = fixture.validate([
        'lib/main.dart',
        'tool/skills/validate.dart',
        'test/cards/legacy_test.dart',
      ]);

      expect(result.diagnostics.single.path, 'test/cards/legacy_test.dart');
    });

    test('exempts bootstrap files and tests that mirror them', () async {
      final fixture = await _NamingFixture.create();
      addTearDown(fixture.dispose);
      const paths = [
        'lib/dart_init.dart',
        'lib/core/di/dependency_injection.dart',
        'test/core/di/dependency_injection_test.dart',
      ];
      for (final path in paths) {
        await fixture.write(path);
      }

      expect(fixture.validate(paths).diagnostics, isEmpty);
    });

    test('exempts shared test support', () async {
      final fixture = await _NamingFixture.create();
      addTearDown(fixture.dispose);
      await fixture.write('test/support/app_harness.dart');

      final result = fixture.validate(['test/support/app_harness.dart']);

      expect(result.diagnostics, isEmpty);
    });

    test(
      'ignores paths outside lib, test, integration_test and tool',
      () async {
        final fixture = await _NamingFixture.create();
        addTearDown(fixture.dispose);
        const paths = [
          'packages/design_system/lib/src/app_button.dart',
          'test_driver/integration_test.dart',
        ];
        for (final path in paths) {
          await fixture.write(path);
        }

        expect(fixture.validate(paths).diagnostics, isEmpty);
      },
    );

    test('reports missing role markers in AGENTS.md', () async {
      final fixture = await _NamingFixture.create();
      addTearDown(fixture.dispose);
      await fixture.write('AGENTS.md', '# AGENTS.md\n');
      await fixture.write('lib/cards/cards.page.dart');

      final result = fixture.validate(['lib/cards/cards.page.dart']);

      expect(result.diagnostics.single.code, 'naming.roles.missing');
      expect(result.diagnostics.single.path, 'AGENTS.md');
    });

    test('accepts a role as soon as AGENTS.md lists it', () async {
      final fixture = await _NamingFixture.create();
      addTearDown(fixture.dispose);
      await fixture.write('lib/core/analytics/analytics.module.dart');
      const paths = ['lib/core/analytics/analytics.module.dart'];

      expect(fixture.validate(paths).isValid, isFalse);

      await fixture.write('AGENTS.md', '''
<!-- naming-roles:start -->
  - Support roles: `.module`
  - Tooling roles, `tool/` only: `.validator`
  - Test role, before `_test` only: `.flow`
<!-- naming-roles:end -->
''');

      expect(fixture.validate(paths).isValid, isTrue);
    });

    test('rejects a dot inside the business name', () async {
      final fixture = await _NamingFixture.create();
      addTearDown(fixture.dispose);
      await fixture.write('lib/cards/cards.bloc.widget.dart');

      final result = fixture.validate(['lib/cards/cards.bloc.widget.dart']);

      expect(result.diagnostics.single.code, 'naming.name.dotted');
    });

    test('accepts tooling roles in tests only under test/tool/', () async {
      final fixture = await _NamingFixture.create();
      addTearDown(fixture.dispose);
      await fixture.write('test/presentation/form.validator_test.dart');

      final result = fixture.validate([
        'test/presentation/form.validator_test.dart',
      ]);

      expect(result.diagnostics.single.code, 'naming.role.tool_only');
    });

    test('exempts a bootstrap mirror only at the mirrored path', () async {
      final fixture = await _NamingFixture.create();
      addTearDown(fixture.dispose);
      await fixture.write('test/anywhere/dart_init_test.dart');

      final result = fixture.validate(['test/anywhere/dart_init_test.dart']);

      expect(result.diagnostics.single.code, 'naming.role.missing');
    });

    test('reports a role-less file that is missing from disk', () async {
      final fixture = await _NamingFixture.create();
      addTearDown(fixture.dispose);

      final result = fixture.validate(['tool/skills/removed.dart']);

      expect(result.diagnostics.single.code, 'naming.role.missing');
    });

    test('recognises every top-level main signature', () async {
      final fixture = await _NamingFixture.create();
      addTearDown(fixture.dispose);
      await fixture.write('tool/a.dart', 'Future<int> main() async => 0;\n');
      await fixture.write('tool/b.dart', 'main(List<String> arguments) {}\n');
      await fixture.write('tool/c.dart', 'void notMain() {}\n');

      final result = fixture.validate([
        'tool/a.dart',
        'tool/b.dart',
        'tool/c.dart',
      ]);

      expect(result.diagnostics.single.path, 'tool/c.dart');
    });

    test('reports a renamed tooling or test label in AGENTS.md', () async {
      final fixture = await _NamingFixture.create();
      addTearDown(fixture.dispose);
      await fixture.write('AGENTS.md', '''
<!-- naming-roles:start -->
  - Layer roles: `.page`
  - Tools: `.validator`
  - Test role, before `_test` only: `.flow`
<!-- naming-roles:end -->
''');

      final result = fixture.validate(const []);

      expect(result.diagnostics.single.code, 'naming.roles.group_missing');
      expect(result.diagnostics.single.message, contains('Tooling roles'));
    });
  });
}

final class _NamingFixture {
  new _(this.repositoryRoot);

  final Directory repositoryRoot;

  static Future<_NamingFixture> create() async {
    final root = await Directory.systemTemp.createTemp(
      'project_tweety_naming_',
    );
    final fixture = _NamingFixture._(root);
    await fixture.write('AGENTS.md', '''
# AGENTS.md

### Naming

<!-- naming-roles:start -->
  - Layer roles: `.page`, `.widget`, `.bloc`
  - Support roles: `.service`, `.model`
  - Tooling roles, `tool/` only: `.validator`, `.cli`
  - Test role, before `_test` only: `.flow`
<!-- naming-roles:end -->
''');
    return fixture;
  }

  NamingValidationResult validate(List<String> paths) =>
      NamingValidator(repositoryRoot: repositoryRoot).validate(paths);

  Future<void> write(String relativePath, [String contents = '']) async {
    final file = File(p.join(repositoryRoot.path, relativePath));
    await file.parent.create(recursive: true);
    await file.writeAsString(contents);
  }

  Future<void> dispose() => repositoryRoot.delete(recursive: true);
}
