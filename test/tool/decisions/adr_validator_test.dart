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
---
type: ADR
id: "0002"
title: "Broken record"
status: active
date: invalid
superseded_by: "9999"
---

# ADR-0001: Different title

## Context

{placeholder}

## Decision

Do something.

## Consequences

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
          'adr.heading.title_mismatch',
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
        supersededBy: '0002',
      );
      await fixture.addAdr(
        id: '0002',
        title: 'Second decision',
        status: 'superseded',
        supersedes: '0001',
        supersededBy: '0001',
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
        supersededBy: '0002',
      );
      await fixture.addAdr(
        id: '0002',
        title: 'Replacement decision',
        status: 'proposed',
        supersedes: '0001',
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
    final fields = <String>[
      'type: ADR',
      'id: "$id"',
      'title: "$title"',
      'status: $status',
      'date: 2026-07-17',
      if (supersedes != null) 'supersedes: "$supersedes"',
      if (supersededBy != null) 'superseded_by: "$supersededBy"',
    ];
    final slug = title.toLowerCase().replaceAll(' ', '-');
    return write('docs/decisions/$id-$slug.md', '''
---
${fields.join('\n')}
---

# ADR-$id: $title

## Context

The current situation needs a durable decision.

## Decision Drivers

- Maintainability.

## Decision

We will use this decision.

## Options Considered

- This decision.

## Consequences

The team has a documented direction.

## Confirmation

Review this record with the change.
''');
  }

  Future<void> writeCatalog() async {
    final records =
        Directory(p.join(repositoryRoot.path, 'docs/decisions'))
            .listSync()
            .whereType<File>()
            .where((file) => p.basename(file.path) != 'adr-template.md')
            .where((file) => p.basename(file.path) != 'README.md')
            .toList()
          ..sort((left, right) => left.path.compareTo(right.path));
    final rows = records.map((file) {
      final text = file.readAsStringSync();
      final id = RegExp(r'id: "(\d{4})"').firstMatch(text)!.group(1)!;
      final title = RegExp(r'title: "([^"]+)"').firstMatch(text)!.group(1)!;
      final status = RegExp(r'status: (\w+)').firstMatch(text)!.group(1)!;
      return '| [$id](${p.basename(file.path)}) | $title | $status |';
    });
    await write('docs/decisions/README.md', '''
# Architecture Decision Records

<!-- adr-index:start -->
| ID | Title | Status |
|----|-------|--------|
${rows.join('\n')}
<!-- adr-index:end -->
''');
  }

  Future<void> write(String relativePath, String contents) async {
    final file = File(p.join(repositoryRoot.path, relativePath));
    await file.parent.create(recursive: true);
    await file.writeAsString(contents);
  }

  Future<void> dispose() => repositoryRoot.delete(recursive: true);
}
