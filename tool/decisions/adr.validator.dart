import 'dart:io';

import 'package:path/path.dart' as p;

const _decisionsPath = 'docs/decisions';
const _catalogPath = 'docs/decisions/README.md';
const _templateName = 'adr-template.md';
const _indexStart = '<!-- adr-index:start -->';
const _indexEnd = '<!-- adr-index:end -->';
const _requiredHeadings = <String>['Context', 'Decision', 'Consequences'];
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
    final heading = RegExp(
      r'^# ADR-(\d{4}): (.+)$',
      multiLine: true,
    ).firstMatch(text);
    if (heading == null || text.substring(0, heading.start).trim().isNotEmpty) {
      diagnostics.add(
        AdrDiagnostic(
          code: 'adr.heading.invalid',
          message: 'ADR must start with an H1 in the form # ADR-NNNN: Title.',
          path: path,
        ),
      );
      return null;
    }
    final id = heading.group(1)!;
    final title = heading.group(2)!.trim();
    final metadata = _readMetadata(
      text.substring(heading.end),
      path,
      diagnostics,
    );
    final status = metadata['Status'];
    final date = metadata['Date'];
    final supersedes = _parseReference(
      metadata['Supersedes'],
      'Supersedes',
      path,
      diagnostics,
    );
    final supersededBy = _parseReference(
      metadata['Superseded by'],
      'Superseded by',
      path,
      diagnostics,
    );

    if (id != filenameId) {
      diagnostics.add(
        AdrDiagnostic(
          code: 'adr.id.filename_mismatch',
          message: 'ADR H1 id must match its filename prefix.',
          path: path,
        ),
      );
    }
    if (status == null) {
      diagnostics.add(
        AdrDiagnostic(
          code: 'adr.status.missing',
          message: 'ADR must declare Status: <value> below its H1.',
          path: path,
        ),
      );
    } else if (!_allowedStatuses.contains(status)) {
      diagnostics.add(
        AdrDiagnostic(
          code: 'adr.status.invalid',
          message: 'ADR status must be one of ${_allowedStatuses.join(', ')}.',
          path: path,
        ),
      );
    }
    if (date == null) {
      diagnostics.add(
        AdrDiagnostic(
          code: 'adr.date.missing',
          message: 'ADR must declare Date: YYYY-MM-DD below its H1.',
          path: path,
        ),
      );
    } else if (!_isIsoDate(date)) {
      diagnostics.add(
        AdrDiagnostic(
          code: 'adr.date.invalid',
          message: 'ADR date must use YYYY-MM-DD.',
          path: path,
        ),
      );
    }
    for (final requiredHeading in _requiredHeadings) {
      if (!text.contains('## $requiredHeading')) {
        diagnostics.add(
          AdrDiagnostic(
            code: 'adr.heading.missing',
            message: 'ADR is missing the $requiredHeading section.',
            path: path,
          ),
        );
      }
    }
    if (RegExp(r'\{[^}\n]+\}').hasMatch(text.substring(heading.end))) {
      diagnostics.add(
        AdrDiagnostic(
          code: 'adr.placeholder.present',
          message: 'ADR must not retain template placeholders.',
          path: path,
        ),
      );
    }
    return _AdrRecord(
      id: id,
      title: title,
      status: status ?? '',
      fileName: p.basename(file.path),
      path: path,
      supersedes: supersedes,
      supersededBy: supersededBy,
    );
  }

  Map<String, String> _readMetadata(
    String source,
    String path,
    List<AdrDiagnostic> diagnostics,
  ) {
    final bodyStart = RegExp(r'^## ', multiLine: true).firstMatch(source);
    final header = bodyStart == null
        ? source
        : source.substring(0, bodyStart.start);
    final metadata = <String, String>{};
    final lineExpression = RegExp(
      r'^(Status|Date|Decision maker|Supersedes|Superseded by):[ \t]*(.*)$',
      multiLine: true,
    );
    for (final match in lineExpression.allMatches(header)) {
      final key = match.group(1)!;
      if (metadata.containsKey(key)) {
        diagnostics.add(
          AdrDiagnostic(
            code: 'adr.metadata.duplicate',
            message: 'ADR metadata must not declare $key more than once.',
            path: path,
          ),
        );
        continue;
      }
      metadata[key] = match.group(2)!.trim();
    }
    return metadata;
  }

  _AdrReference? _parseReference(
    String? value,
    String label,
    String path,
    List<AdrDiagnostic> diagnostics,
  ) {
    if (value == null) {
      return null;
    }
    final match = RegExp(
      r'^\[ADR-(\d{4})\]\(([^/()]+\.md)\)$',
    ).firstMatch(value);
    if (match == null) {
      diagnostics.add(
        AdrDiagnostic(
          code: 'adr.supersession.link_invalid',
          message: '$label must use [ADR-NNNN](NNNN-short-title.md).',
          path: path,
        ),
      );
      return null;
    }
    return _AdrReference(id: match.group(1)!, fileName: match.group(2)!);
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
        final successor = byId[supersededBy.id];
        if (successor == null) {
          diagnostics.add(
            AdrDiagnostic(
              code: 'adr.supersession.target_missing',
              message: 'Superseded by must reference an existing ADR.',
              path: record.path,
            ),
          );
        } else if (successor.fileName != supersededBy.fileName) {
          diagnostics.add(
            AdrDiagnostic(
              code: 'adr.supersession.target_mismatch',
              message:
                  'Superseded by link must target the referenced ADR file.',
              path: record.path,
            ),
          );
        } else {
          if (successor.status != 'accepted') {
            diagnostics.add(
              AdrDiagnostic(
                code: 'adr.supersession.successor_status',
                message: 'A supersession successor must be accepted.',
                path: record.path,
              ),
            );
          }
          if (successor.supersedes?.id != record.id) {
            diagnostics.add(
              AdrDiagnostic(
                code: 'adr.supersession.backlink_missing',
                message: 'Superseded ADRs require a matching successor link.',
                path: record.path,
              ),
            );
          }
        }
      } else if (record.status == 'superseded') {
        diagnostics.add(
          AdrDiagnostic(
            code: 'adr.supersession.target_missing',
            message: 'Superseded ADRs must declare Superseded by.',
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
        final predecessor = byId[supersedes.id];
        if (predecessor == null) {
          diagnostics.add(
            AdrDiagnostic(
              code: 'adr.supersession.target_missing',
              message: 'Supersedes must reference an existing ADR.',
              path: record.path,
            ),
          );
        } else if (predecessor.fileName != supersedes.fileName) {
          diagnostics.add(
            AdrDiagnostic(
              code: 'adr.supersession.target_mismatch',
              message: 'Supersedes link must target the referenced ADR file.',
              path: record.path,
            ),
          );
        } else if (predecessor.supersededBy?.id != record.id) {
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
        final successorRecord = byId[successor.id];
        if (successorRecord != null) {
          status =
              'superseded → [${successor.id}](${successorRecord.fileName})';
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
      final successor = records[id]?.supersededBy?.id;
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
  final _AdrReference? supersedes;
  final _AdrReference? supersededBy;
}

final class _AdrReference {
  const _AdrReference({required this.id, required this.fileName});

  final String id;
  final String fileName;
}
