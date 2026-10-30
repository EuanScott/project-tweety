import 'dart:io';

import 'package:path/path.dart' as p;

import '../templates/feature_template_paths.constants.dart';

const _sourceMapPath = 'docs/source_map.md';
const _rootInstructionsPath = 'AGENTS.md';
const _rootMarkdownPaths = ['CODING_STANDARDS.md', 'GLOSSARY.md', 'README.md'];

final class ContextValidationBudgets {
  const new({this.rootLines = 40, this.scopedLines = 50});

  final int rootLines;
  final int scopedLines;
}

final class ContextDiagnostic {
  const new({required this.code, required this.message, required this.path});

  final String code;
  final String message;
  final String path;
}

final class ContextValidationResult {
  const new(this.diagnostics);

  final List<ContextDiagnostic> diagnostics;

  bool get isValid => diagnostics.isEmpty;
}

const _excludedDirectorySegments = {'.dart_tool', '.claude', '.git', 'build'};

const _featureTemplateLayers = {'data', 'domain', 'presentation', 'test'};

final class ContextValidator {
  const new({
    required this.repositoryRoot,
    this.budgets = const ContextValidationBudgets(),
  });

  final Directory repositoryRoot;
  final ContextValidationBudgets budgets;

  ContextValidationResult validate() {
    final diagnostics = <ContextDiagnostic>[];
    final instructionFiles =
        repositoryRoot
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => p.basename(file.path) == 'AGENTS.md')
            .where(
              (file) =>
                  !p.split(file.path).any(_excludedDirectorySegments.contains),
            )
            .toList()
          ..sort((left, right) => left.path.compareTo(right.path));

    for (final file in instructionFiles) {
      final relativePath = p.relative(file.path, from: repositoryRoot.path);
      final lineCount = file.readAsLinesSync().length;
      final isRoot = relativePath == _rootInstructionsPath;
      final budget = isRoot ? budgets.rootLines : budgets.scopedLines;
      final hasBudget = relativePath != '.agents/skills/AGENTS.md';
      if (hasBudget && lineCount > budget) {
        diagnostics.add(
          ContextDiagnostic(
            code: isRoot ? 'agents.lines.root' : 'agents.lines.scoped',
            message:
                'Instruction file has $lineCount lines; maximum is $budget.',
            path: relativePath,
          ),
        );
      }
      diagnostics.addAll(_missingReferences(file, relativePath));
    }

    final sourceMap = File(p.join(repositoryRoot.path, _sourceMapPath));
    if (!sourceMap.existsSync()) {
      diagnostics.add(
        const ContextDiagnostic(
          code: 'source-map.missing',
          message: 'Required source map does not exist.',
          path: _sourceMapPath,
        ),
      );
    } else {
      diagnostics.addAll(_missingReferences(sourceMap, _sourceMapPath));
    }

    for (final relativePath in _rootMarkdownPaths) {
      final file = File(p.join(repositoryRoot.path, relativePath));
      if (file.existsSync()) {
        diagnostics.addAll(_missingReferences(file, relativePath));
      }
    }

    final docsRoot = Directory(p.join(repositoryRoot.path, 'docs'));
    if (docsRoot.existsSync()) {
      final docFiles =
          docsRoot
              .listSync(recursive: true)
              .whereType<File>()
              .where((file) => file.path.endsWith('.md'))
              .toList()
            ..sort((left, right) => left.path.compareTo(right.path));
      for (final file in docFiles) {
        final relativePath = p.relative(file.path, from: repositoryRoot.path);
        if (relativePath == _sourceMapPath) {
          continue;
        }
        diagnostics.addAll(_missingReferences(file, relativePath));
      }
    }

    final templatesRoot = Directory(
      p.join(repositoryRoot.path, 'tool', 'templates'),
    );
    if (!templatesRoot.existsSync()) {
      diagnostics.add(
        const ContextDiagnostic(
          code: 'template.root.missing',
          message: 'Canonical tool template directory does not exist.',
          path: 'tool/templates',
        ),
      );
    } else {
      for (final file
          in templatesRoot.listSync(recursive: true).whereType<File>()) {
        if (file.path.endsWith('.g.dart') ||
            file.path.endsWith('.freezed.dart')) {
          diagnostics.add(
            ContextDiagnostic(
              code: 'template.generated.forbidden',
              message: 'Generated Dart must not live with canonical templates.',
              path: p.relative(file.path, from: repositoryRoot.path),
            ),
          );
        }
      }
      final featureRoot = Directory(p.join(templatesRoot.path, 'feature'));
      if (featureRoot.existsSync()) {
        for (final directory in featureRoot.listSync().whereType<Directory>()) {
          final layer = p.basename(directory.path);
          if (!_featureTemplateLayers.contains(layer)) {
            diagnostics.add(
              ContextDiagnostic(
                code: 'template.layer.unknown',
                message:
                    'Feature templates mirror lib layers; '
                    '"$layer" is not one of $_featureTemplateLayers.',
                path: p.relative(directory.path, from: repositoryRoot.path),
              ),
            );
          }
        }
      }
      for (final path in [
        ...featureProductionTemplatePaths,
        ...featureTestReferenceTemplatePaths,
        ...domainTemplatePaths,
      ]) {
        if (!File(p.join(repositoryRoot.path, path)).existsSync()) {
          diagnostics.add(
            ContextDiagnostic(
              code: 'template.missing',
              message: 'Canonical template is missing.',
              path: path,
            ),
          );
        }
      }
    }

    return ContextValidationResult(diagnostics);
  }

  List<ContextDiagnostic> _missingReferences(File file, String relativePath) {
    final diagnostics = <ContextDiagnostic>[];
    final source = file
        .readAsStringSync()
        .replaceAll(RegExp(r'```[\s\S]*?```'), '')
        .replaceAll(RegExp(r'<!--[\s\S]*?-->'), '')
        .replaceAll(RegExp(r'`[^`\n]*\]\([^`\n]*`'), '');
    final expression = RegExp(r'\[[^\]]+\]\(([^)]+)\)');
    for (final match in expression.allMatches(source)) {
      final target = match.group(1)!;
      if (target.startsWith('http') || target.startsWith('#')) {
        continue;
      }
      final targetPath = target.split('#').first;
      final resolved = File(p.normalize(p.join(file.parent.path, targetPath)));
      if (!resolved.existsSync() && !Directory(resolved.path).existsSync()) {
        diagnostics.add(
          ContextDiagnostic(
            code: 'reference.missing',
            message: 'Local Markdown reference "$target" does not exist.',
            path: relativePath,
          ),
        );
      }
    }
    return diagnostics;
  }
}
