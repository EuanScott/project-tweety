import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../../tool/decisions/adr.validator.dart';

void main() {
  group('AdrValidator', () {
    test('accepts matching records and generated catalog', () async {
      final fixture = await _AdrFixture.create();
      addTearDown(fixture.dispose);
      await fixture.addAdr(
        id: '0001',
        title: 'Record architecture decisions',
        status: 'proposed',
      );
      await fixture.addAdr(
        id: '0002',
        title: 'Use local SQLite storage',
        status: 'accepted',
      );
      await fixture.writeCatalog();

      final result = AdrValidator(
        repositoryRoot: fixture.repositoryRoot,
      ).validate();

      expect(result.isValid, isTrue);
      expect(result.diagnostics, isEmpty);
    });

    test('reports record and lifecycle contract violations', () async {
      final fixture = await _AdrFixture.create();
      addTearDown(fixture.dispose);
      await fixture.write('docs/decisions/0001-broken.md', '''
# ADR-0002: Different title

Status: active
Date: invalid
Superseded by: [ADR-9999](9999-missing.md)

## Context

{placeholder}

## Decision

Do something.

Unknown.
''');
      await fixture.writeCatalog();

      final result = AdrValidator(
        repositoryRoot: fixture.repositoryRoot,
      ).validate();
      final codes = result.diagnostics.map((diagnostic) => diagnostic.code);

      expect(result.isValid, isFalse);
      expect(
        codes,
        containsAll(<String>{
          'adr.id.filename_mismatch',
          'adr.status.invalid',
          'adr.date.invalid',
          'adr.heading.missing',
          'adr.placeholder.present',
          'adr.supersession.status',
          'adr.supersession.target_missing',
        }),
      );
    });

    test('requires bidirectional, acyclic supersession links', () async {
      final fixture = await _AdrFixture.create();
      addTearDown(fixture.dispose);
      await fixture.addAdr(
        id: '0001',
        title: 'First decision',
        status: 'superseded',
        supersededBy: '[ADR-0002](0002-second-decision.md)',
      );
      await fixture.addAdr(
        id: '0002',
        title: 'Second decision',
        status: 'superseded',
        supersedes: '[ADR-0001](0001-first-decision.md)',
        supersededBy: '[ADR-0001](0001-first-decision.md)',
      );
      await fixture.writeCatalog();

      final result = AdrValidator(
        repositoryRoot: fixture.repositoryRoot,
      ).validate();
      final codes = result.diagnostics.map((diagnostic) => diagnostic.code);

      expect(codes, contains('adr.supersession.cycle'));
    });

    test('requires an accepted ADR to supersede a predecessor', () async {
      final fixture = await _AdrFixture.create();
      addTearDown(fixture.dispose);
      await fixture.addAdr(
        id: '0001',
        title: 'First decision',
        status: 'superseded',
        supersededBy: '[ADR-0002](0002-replacement-decision.md)',
      );
      await fixture.addAdr(
        id: '0002',
        title: 'Replacement decision',
        status: 'proposed',
        supersedes: '[ADR-0001](0001-first-decision.md)',
      );
      await fixture.writeCatalog();

      final result = AdrValidator(
        repositoryRoot: fixture.repositoryRoot,
      ).validate();

      expect(
        result.diagnostics.map((diagnostic) => diagnostic.code),
        contains('adr.supersession.successor_status'),
      );
    });

    test(
      'requires a supersession successor to be accepted and link back',
      () async {
        final fixture = await _AdrFixture.create();
        addTearDown(fixture.dispose);
        await fixture.addAdr(
          id: '0001',
          title: 'First decision',
          status: 'superseded',
          supersededBy: '[ADR-0002](0002-replacement-decision.md)',
        );
        await fixture.addAdr(
          id: '0002',
          title: 'Replacement decision',
          status: 'proposed',
        );
        await fixture.writeCatalog();

        final result = AdrValidator(
          repositoryRoot: fixture.repositoryRoot,
        ).validate();

        expect(
          result.diagnostics.map((diagnostic) => diagnostic.code),
          containsAll(<String>{
            'adr.supersession.successor_status',
            'adr.supersession.backlink_missing',
          }),
        );
      },
    );

    test('rejects malformed and duplicate required metadata lines', () async {
      final fixture = await _AdrFixture.create();
      addTearDown(fixture.dispose);
      await fixture.write('docs/decisions/0001-broken-metadata.md', '''
# ADR-0001: Broken metadata

Status: proposed
Status: accepted
Date:

## Context

The current situation needs a durable decision.

## Decision

We will use this decision.

## Consequences

The team has a documented direction.
''');
      await fixture.writeCatalog();

      final result = AdrValidator(
        repositoryRoot: fixture.repositoryRoot,
      ).validate();

      expect(
        result.diagnostics.map((diagnostic) => diagnostic.code),
        containsAll(<String>{'adr.metadata.duplicate', 'adr.date.invalid'}),
      );
    });

    test(
      'rejects supersession links whose filename does not match the target',
      () async {
        final fixture = await _AdrFixture.create();
        addTearDown(fixture.dispose);
        await fixture.addAdr(
          id: '0001',
          title: 'First decision',
          status: 'superseded',
          supersededBy: '[ADR-0002](0002-wrong-name.md)',
        );
        await fixture.addAdr(
          id: '0002',
          title: 'Replacement decision',
          status: 'accepted',
          supersedes: '[ADR-0001](0001-first-decision.md)',
        );
        await fixture.writeCatalog();

        final result = AdrValidator(
          repositoryRoot: fixture.repositoryRoot,
        ).validate();

        expect(
          result.diagnostics.map((diagnostic) => diagnostic.code),
          contains('adr.supersession.target_mismatch'),
        );
      },
    );
  });
}

final class _AdrFixture {
  _AdrFixture._(this.repositoryRoot);

  final Directory repositoryRoot;

  static Future<_AdrFixture> create() async {
    final root = await Directory.systemTemp.createTemp('project_tweety_adr_');
    final fixture = _AdrFixture._(root);
    await fixture.write('docs/decisions/adr-template.md', '# ADR template');
    await fixture.write('docs/decisions/README.md', '''
# Architecture Decision Records

<!-- adr-index:start -->
<!-- adr-index:end -->
''');
    return fixture;
  }

  Future<void> addAdr({
    required String id,
    required String title,
    required String status,
    String? supersedes,
    String? supersededBy,
  }) {
    final slug = title.toLowerCase().replaceAll(' ', '-');
    return write('docs/decisions/$id-$slug.md', '''
# ADR-$id: $title

Status: $status
Date: 2026-07-17
${supersedes == null ? '' : 'Supersedes: $supersedes'}
${supersededBy == null ? '' : 'Superseded by: $supersededBy'}

## Context

The current situation needs a durable decision.

## Decision

We will use this decision.

## Consequences

The team has a documented direction.
''');
  }

  Future<void> writeCatalog() async {
    final index = AdrValidator(
      repositoryRoot: repositoryRoot,
    ).generateCatalog();
    await write('docs/decisions/README.md', '''
# Architecture Decision Records

$index
''');
  }

  Future<void> write(String relativePath, String contents) async {
    final file = File(p.join(repositoryRoot.path, relativePath));
    await file.parent.create(recursive: true);
    await file.writeAsString(contents);
  }

  Future<void> dispose() => repositoryRoot.delete(recursive: true);
}
