import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

const _decisionsPath = 'docs/decisions';
const _catalogPath = 'docs/decisions/README.md';
const _templateName = 'adr-template.md';
const _indexStart = '<!-- adr-index:start -->';
const _indexEnd = '<!-- adr-index:end -->';
const _requiredHeadings = <String>[
  'Context',
  'Decision Drivers',
  'Decision',
  'Options Considered',
  'Consequences',
  'Confirmation',
];
const _allowedStatuses = <String>{
  'proposed',
  'accepted',
  'rejected',
  'superseded',
  'deprecated',
};

final class AdrDiagnostic {
  const AdrDiagnostic({
    required this.code,
    required this.message,
    required this.path,
  });

  final String code;
  final String message;
  final String path;
}

final class AdrValidationResult {
  const AdrValidationResult(this.diagnostics);

  final List<AdrDiagnostic> diagnostics;

  bool get isValid => diagnostics.isEmpty;
}

final class AdrValidator {
  const AdrValidator({required this.repositoryRoot});

  final Directory repositoryRoot;

  AdrValidationResult validate() {
    final diagnostics = <AdrDiagnostic>[];
    final records = _readRecords(diagnostics);
    _validateRecords(records, diagnostics);
    _validateCatalog(records, diagnostics);
    return AdrValidationResult(diagnostics);
  }

  String generateCatalog() {
    final records = _readRecords(<AdrDiagnostic>[]);
    return _renderCatalog(records);
  }

  void writeCatalog() {
    final catalog = File(p.join(repositoryRoot.path, _catalogPath));
    if (!catalog.existsSync()) {
      throw StateError('ADR catalog does not exist at $_catalogPath.');
    }
    final contents = catalog.readAsStringSync();
    final expression = RegExp('$_indexStart\\n[\\s\\S]*?\\n$_indexEnd');
    if (!expression.hasMatch(contents)) {
      throw StateError('ADR catalog is missing $_indexStart and $_indexEnd.');
    }
    catalog.writeAsStringSync(
      contents.replaceFirst(expression, generateCatalog()),
    );
  }

  List<_AdrRecord> _readRecords(List<AdrDiagnostic> diagnostics) {
    final directory = Directory(p.join(repositoryRoot.path, _decisionsPath));
    if (!directory.existsSync()) {
      diagnostics.add(
        const AdrDiagnostic(
          code: 'adr.directory.missing',
          message: 'ADR directory does not exist.',
          path: _decisionsPath,
        ),
      );
      return const [];
    }
    final records = <_AdrRecord>[];
    final files =
        directory
            .listSync()
            .whereType<File>()
            .where((file) => p.basename(file.path) != _templateName)
            .where((file) => p.basename(file.path).endsWith('.md'))
            .where((file) => p.basename(file.path) != 'README.md')
            .toList()
          ..sort((left, right) => left.path.compareTo(right.path));
    for (final file in files) {
      final path = p.relative(file.path, from: repositoryRoot.path);
      final filename = p.basename(file.path);
      final match = RegExp(
        r'^(\d{4})-([a-z0-9]+(?:-[a-z0-9]+)*)\.md$',
      ).firstMatch(filename);
      if (match == null) {
        diagnostics.add(
          AdrDiagnostic(
            code: 'adr.filename.invalid',
            message: 'ADR filenames must use NNNN-short-title.md.',
            path: path,
          ),
        );
        continue;
      }
      final parsed = _parseRecord(file, path, match.group(1)!, diagnostics);
      if (parsed != null) {
        records.add(parsed);
      }
    }
    return records;
  }

  _AdrRecord? _parseRecord(
    File file,
    String path,
    String filenameId,
    List<AdrDiagnostic> diagnostics,
  ) {
    final text = file.readAsStringSync();
    final match = RegExp(
      r'^---\n([\s\S]*?)\n---\n?',
      multiLine: true,
    ).firstMatch(text);
    if (match == null) {
      diagnostics.add(
        AdrDiagnostic(
          code: 'adr.frontmatter.missing',
          message: 'ADR must start with YAML frontmatter.',
          path: path,
        ),
      );
      return null;
    }
    try {
      final frontmatter = loadYaml(match.group(1)!) as YamlMap;
      final id = frontmatter['id']?.toString();
      final title = frontmatter['title']?.toString();
      final status = frontmatter['status']?.toString();
      final date = frontmatter['date']?.toString();
      final supersedes = frontmatter['supersedes']?.toString();
      final supersededBy = frontmatter['superseded_by']?.toString();
      if (frontmatter['type']?.toString() != 'ADR') {
        diagnostics.add(
          AdrDiagnostic(
            code: 'adr.type.invalid',
            message: 'ADR frontmatter type must be ADR.',
            path: path,
          ),
        );
      }
      if (id == null || !RegExp(r'^\d{4}$').hasMatch(id)) {
        diagnostics.add(
          AdrDiagnostic(
            code: 'adr.id.invalid',
            message: 'ADR id must be a four-digit string.',
            path: path,
          ),
        );
      } else if (id != filenameId) {
        diagnostics.add(
          AdrDiagnostic(
            code: 'adr.id.filename_mismatch',
            message: 'ADR id must match its filename prefix.',
            path: path,
          ),
        );
      }
      if (title == null || title.trim().isEmpty) {
        diagnostics.add(
          AdrDiagnostic(
            code: 'adr.title.invalid',
            message: 'ADR title must be a non-empty string.',
            path: path,
          ),
        );
      }
      if (status == null || !_allowedStatuses.contains(status)) {
        diagnostics.add(
          AdrDiagnostic(
            code: 'adr.status.invalid',
            message:
                'ADR status must be one of ${_allowedStatuses.join(', ')}.',
            path: path,
          ),
        );
      }
      if (date == null || !_isIsoDate(date)) {
        diagnostics.add(
          AdrDiagnostic(
            code: 'adr.date.invalid',
            message: 'ADR date must use YYYY-MM-DD.',
            path: path,
          ),
        );
      }
      if (id != null && title != null) {
        final expectedHeading = '# ADR-$id: $title';
        if (!text.contains(expectedHeading)) {
          diagnostics.add(
            AdrDiagnostic(
              code: 'adr.heading.title_mismatch',
              message: 'ADR H1 must match its id and title.',
              path: path,
            ),
          );
        }
      }
      for (final heading in _requiredHeadings) {
        if (!text.contains('## $heading')) {
          diagnostics.add(
            AdrDiagnostic(
              code: 'adr.heading.missing',
              message: 'ADR is missing the $heading section.',
              path: path,
            ),
          );
        }
      }
      if (RegExp(r'\{[^}\n]+\}').hasMatch(text.substring(match.end))) {
        diagnostics.add(
          AdrDiagnostic(
            code: 'adr.placeholder.present',
            message: 'ADR must not retain template placeholders.',
            path: path,
          ),
        );
      }
      return _AdrRecord(
        id: id ?? filenameId,
        title: title ?? '',
        status: status ?? '',
        fileName: p.basename(file.path),
        path: path,
        supersedes: supersedes,
        supersededBy: supersededBy,
      );
    } on YamlException {
      diagnostics.add(
        AdrDiagnostic(
          code: 'adr.frontmatter.invalid',
          message: 'ADR frontmatter is not valid YAML.',
          path: path,
        ),
      );
      return null;
    }
  }

  void _validateRecords(
    List<_AdrRecord> records,
    List<AdrDiagnostic> diagnostics,
  ) {
    final byId = <String, _AdrRecord>{};
    for (final record in records) {
      final existing = byId[record.id];
      if (existing != null) {
        diagnostics.add(
          AdrDiagnostic(
            code: 'adr.id.duplicate',
            message: 'ADR id ${record.id} is already used by ${existing.path}.',
            path: record.path,
          ),
        );
      } else {
        byId[record.id] = record;
      }
    }
    for (final record in records) {
      final supersededBy = record.supersededBy;
      if (supersededBy != null) {
        if (record.status != 'superseded') {
          diagnostics.add(
            AdrDiagnostic(
              code: 'adr.supersession.status',
              message: 'Only superseded ADRs may declare superseded_by.',
              path: record.path,
            ),
          );
        }
        if (!byId.containsKey(supersededBy)) {
          diagnostics.add(
            AdrDiagnostic(
              code: 'adr.supersession.target_missing',
              message: 'superseded_by must reference an existing ADR.',
              path: record.path,
            ),
          );
        }
      } else if (record.status == 'superseded') {
        diagnostics.add(
          AdrDiagnostic(
            code: 'adr.supersession.target_missing',
            message: 'Superseded ADRs must declare superseded_by.',
            path: record.path,
          ),
        );
      }
      final supersedes = record.supersedes;
      if (supersedes != null) {
        if (record.status != 'accepted') {
          diagnostics.add(
            AdrDiagnostic(
              code: 'adr.supersession.successor_status',
              message: 'Only accepted ADRs may supersede a predecessor.',
              path: record.path,
            ),
          );
        }
        final predecessor = byId[supersedes];
        if (predecessor == null) {
          diagnostics.add(
            AdrDiagnostic(
              code: 'adr.supersession.target_missing',
              message: 'supersedes must reference an existing ADR.',
              path: record.path,
            ),
          );
        } else if (predecessor.supersededBy != record.id) {
          diagnostics.add(
            AdrDiagnostic(
              code: 'adr.supersession.backlink_missing',
              message: 'Superseding ADRs require a matching predecessor link.',
              path: record.path,
            ),
          );
        }
      }
    }
    if (_hasSupersessionCycle(byId)) {
      diagnostics.add(
        const AdrDiagnostic(
          code: 'adr.supersession.cycle',
          message: 'Supersession links must not form a cycle.',
          path: _decisionsPath,
        ),
      );
    }
  }

  void _validateCatalog(
    List<_AdrRecord> records,
    List<AdrDiagnostic> diagnostics,
  ) {
    final catalog = File(p.join(repositoryRoot.path, _catalogPath));
    if (!catalog.existsSync()) {
      diagnostics.add(
        const AdrDiagnostic(
          code: 'adr.catalog.missing',
          message: 'ADR catalog does not exist.',
          path: _catalogPath,
        ),
      );
      return;
    }
    final contents = catalog.readAsStringSync();
    final expression = RegExp('$_indexStart\\n[\\s\\S]*?\\n$_indexEnd');
    final actual = expression.firstMatch(contents)?.group(0);
    if (actual == null) {
      diagnostics.add(
        const AdrDiagnostic(
          code: 'adr.catalog.markers_missing',
          message: 'ADR catalog must contain generated-index markers.',
          path: _catalogPath,
        ),
      );
      return;
    }
    if (actual != _renderCatalog(records)) {
      diagnostics.add(
        const AdrDiagnostic(
          code: 'adr.catalog.stale',
          message: 'ADR catalog does not match the decision records.',
          path: _catalogPath,
        ),
      );
    }
  }

  String _renderCatalog(List<_AdrRecord> records) {
    final byId = {for (final record in records) record.id: record};
    final sorted = [...records]
      ..sort((left, right) => left.id.compareTo(right.id));
    final rows = sorted.map((record) {
      var status = record.status;
      final successor = record.supersededBy;
      if (record.status == 'superseded' && successor != null) {
        final successorRecord = byId[successor];
        if (successorRecord != null) {
          status = 'superseded → [$successor](${successorRecord.fileName})';
        }
      }
      return '| [${record.id}](${record.fileName}) | ${record.title} | $status |';
    });
    return <String>[
      _indexStart,
      '| ID | Title | Status |',
      '|----|-------|--------|',
      ...rows,
      _indexEnd,
    ].join('\n');
  }

  bool _hasSupersessionCycle(Map<String, _AdrRecord> records) {
    final visiting = <String>{};
    final visited = <String>{};
    bool visit(String id) {
      if (!visiting.add(id)) {
        return true;
      }
      if (!visited.add(id)) {
        visiting.remove(id);
        return false;
      }
      final successor = records[id]?.supersededBy;
      final hasCycle = successor != null && records.containsKey(successor)
          ? visit(successor)
          : false;
      visiting.remove(id);
      return hasCycle;
    }

    return records.keys.any(visit);
  }

  bool _isIsoDate(String value) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      return false;
    }
    return DateTime.tryParse(value) != null;
  }
}

final class _AdrRecord {
  const _AdrRecord({
    required this.id,
    required this.title,
    required this.status,
    required this.fileName,
    required this.path,
    required this.supersedes,
    required this.supersededBy,
  });

  final String id;
  final String title;
  final String status;
  final String fileName;
  final String path;
  final String? supersedes;
  final String? supersededBy;
}
