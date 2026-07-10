import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// Configurable limits enforced by [SkillValidator].
final class SkillValidationBudgets {
  const SkillValidationBudgets({
    this.descriptionWords = 35,
    this.descriptionCorpusWords = 175,
    this.bodyWords = 900,
    this.activatedPathWords = 1200,
    this.shortDescriptionMinCharacters = 25,
    this.shortDescriptionMaxCharacters = 64,
    this.substantialParagraphWords = 12,
  });

  final int descriptionWords;
  final int descriptionCorpusWords;
  final int bodyWords;
  final int activatedPathWords;
  final int shortDescriptionMinCharacters;
  final int shortDescriptionMaxCharacters;
  final int substantialParagraphWords;
}

/// Machine-readable validation issue.
final class SkillDiagnostic {
  const SkillDiagnostic({
    required this.code,
    required this.message,
    required this.path,
  });

  final String code;
  final String message;
  final String path;

  Map<String, Object?> toJson() => {
    'code': code,
    'message': message,
    'path': path,
  };
}

/// Result returned from validating a local skill corpus.
final class SkillValidationResult {
  const SkillValidationResult(this.diagnostics);

  final List<SkillDiagnostic> diagnostics;

  bool get isValid => diagnostics.isEmpty;

  Map<String, Object?> toJson() => {
    'valid': isValid,
    'diagnostics': diagnostics
        .map((diagnostic) => diagnostic.toJson())
        .toList(),
  };
}

/// Validates all skills under `.codex/skills` in [repositoryRoot].
final class SkillValidator {
  const SkillValidator({
    required this.repositoryRoot,
    this.budgets = const SkillValidationBudgets(),
  });

  final Directory repositoryRoot;
  final SkillValidationBudgets budgets;

  SkillValidationResult validate() {
    final diagnostics = <SkillDiagnostic>[];
    final skillsRoot = Directory('${repositoryRoot.path}/.codex/skills');
    if (!skillsRoot.existsSync()) {
      return const SkillValidationResult([
        SkillDiagnostic(
          code: 'corpus.skills_root.missing',
          message: 'Local skill corpus directory does not exist.',
          path: '.codex/skills',
        ),
      ]);
    }

    final skillDirectories =
        skillsRoot
            .listSync()
            .whereType<Directory>()
            .where(
              (directory) =>
                  !_basename(directory.path).startsWith('.') &&
                  _basename(directory.path) != 'references',
            )
            .toList()
          ..sort((left, right) => left.path.compareTo(right.path));
    final namePaths = <String, String>{};
    final reachableSharedReferencePaths = <String>{};
    final markdownSourcesByPath = <String, ({File file, String markdown})>{};
    var descriptionCorpusWords = 0;

    for (final skillDirectory in skillDirectories) {
      final directoryName = _basename(skillDirectory.path);
      if (!_isKebabCase(directoryName)) {
        diagnostics.add(
          SkillDiagnostic(
            code: 'skill.directory.invalid',
            message: 'Skill directories must use kebab-case.',
            path: _relativePath(skillDirectory.path),
          ),
        );
      }
      for (final readme
          in skillDirectory
              .listSync(recursive: true)
              .whereType<File>()
              .where(
                (file) => _basename(file.path).toLowerCase() == 'readme.md',
              )) {
        diagnostics.add(
          SkillDiagnostic(
            code: 'skill.readme.forbidden',
            message: 'README.md is not allowed inside a skill directory.',
            path: _relativePath(readme.path),
          ),
        );
      }

      final skillFile = File('${skillDirectory.path}/SKILL.md');
      if (!skillFile.existsSync()) {
        diagnostics.add(
          SkillDiagnostic(
            code: 'skill.frontmatter.invalid',
            message: 'SKILL.md is missing.',
            path: _relativePath(skillFile.path),
          ),
        );
        continue;
      }

      try {
        final document = _parseSkillDocument(skillFile.readAsStringSync());
        final frontmatterKeys = document.frontmatter.keys.toSet();
        if (frontmatterKeys.length != 2 ||
            !frontmatterKeys.contains('name') ||
            !frontmatterKeys.contains('description')) {
          diagnostics.add(
            SkillDiagnostic(
              code: 'skill.frontmatter.keys',
              message:
                  'Frontmatter must contain exactly "name" and "description".',
              path: _relativePath(skillFile.path),
            ),
          );
        }
        final name = document.frontmatter['name'];
        if (name is! String || !_isKebabCase(name) || name != directoryName) {
          diagnostics.add(
            SkillDiagnostic(
              code: 'skill.name.invalid',
              message:
                  'Frontmatter name must be kebab-case and match the directory.',
              path: _relativePath(skillFile.path),
            ),
          );
        }
        if (name is String) {
          final firstPath = namePaths[name];
          if (firstPath == null) {
            namePaths[name] = _relativePath(skillFile.path);
          } else {
            diagnostics.add(
              SkillDiagnostic(
                code: 'skill.name.duplicate',
                message:
                    'Skill name "$name" is already declared in $firstPath.',
                path: _relativePath(skillFile.path),
              ),
            );
          }
        }
        final description = document.frontmatter['description'];
        if (description is! String || description.trim().isEmpty) {
          diagnostics.add(
            SkillDiagnostic(
              code: 'skill.description.invalid',
              message: 'Frontmatter description must be a non-empty string.',
              path: _relativePath(skillFile.path),
            ),
          );
        } else {
          final descriptionWords = _wordCount(description);
          descriptionCorpusWords += descriptionWords;
          if (descriptionWords > budgets.descriptionWords) {
            diagnostics.add(
              SkillDiagnostic(
                code: 'skill.description.words',
                message:
                    'Description has $descriptionWords words; maximum is '
                    '${budgets.descriptionWords}.',
                path: _relativePath(skillFile.path),
              ),
            );
          }
        }
        final bodyWords = _wordCount(document.body);
        if (_containsObsoleteHelpMode(document.body)) {
          diagnostics.add(
            SkillDiagnostic(
              code: 'skill.help_mode.obsolete',
              message:
                  'Help mode is obsolete; remove Help mode sections and '
                  '--help instructions.',
              path: _relativePath(skillFile.path),
            ),
          );
        }
        if (bodyWords > budgets.bodyWords) {
          diagnostics.add(
            SkillDiagnostic(
              code: 'skill.body.words',
              message:
                  'SKILL.md body has $bodyWords words; maximum is '
                  '${budgets.bodyWords}.',
              path: _relativePath(skillFile.path),
            ),
          );
        }

        final referenceInspection = _inspectReferences(
          skillsRoot: skillsRoot,
          skillDirectory: skillDirectory,
          skillFile: skillFile,
          skillBody: document.body,
          reachableSharedReferencePaths: reachableSharedReferencePaths,
          diagnostics: diagnostics,
        );
        markdownSourcesByPath[p.normalize(skillFile.path)] = (
          file: skillFile,
          markdown: document.body,
        );
        for (final reference in referenceInspection.reachableMarkdownFiles) {
          markdownSourcesByPath.putIfAbsent(
            p.normalize(reference.path),
            () => (file: reference, markdown: reference.readAsStringSync()),
          );
        }
        final localReferencesDirectory = Directory(
          '${skillDirectory.path}/references',
        );
        if (localReferencesDirectory.existsSync()) {
          for (final reference
              in localReferencesDirectory
                  .listSync(recursive: true)
                  .whereType<File>()
                  .where((file) => file.path.toLowerCase().endsWith('.md'))) {
            markdownSourcesByPath.putIfAbsent(
              p.normalize(reference.path),
              () => (file: reference, markdown: reference.readAsStringSync()),
            );
          }
        }
        final activatedPathWords =
            bodyWords +
            referenceInspection.reachableMarkdownFiles.fold(
              0,
              (total, reference) =>
                  total + _wordCount(reference.readAsStringSync()),
            );
        if (activatedPathWords > budgets.activatedPathWords) {
          diagnostics.add(
            SkillDiagnostic(
              code: 'skill.activated_path.words',
              message:
                  'Activated guidance has $activatedPathWords words; maximum '
                  'is ${budgets.activatedPathWords}.',
              path: _relativePath(skillFile.path),
            ),
          );
        }
        _validateOpenAiMetadata(
          skillDirectory: skillDirectory,
          skillName: name is String ? name : directoryName,
          diagnostics: diagnostics,
        );
      } on YamlException catch (error) {
        diagnostics.add(
          SkillDiagnostic(
            code: 'skill.frontmatter.invalid',
            message: 'Frontmatter is not valid YAML: ${error.message}',
            path: _relativePath(skillFile.path),
          ),
        );
      } on FormatException catch (error) {
        diagnostics.add(
          SkillDiagnostic(
            code: 'skill.frontmatter.invalid',
            message: error.message,
            path: _relativePath(skillFile.path),
          ),
        );
      }
    }

    final markdownSources = markdownSourcesByPath.values.toList()
      ..sort((left, right) => left.file.path.compareTo(right.file.path));
    _inspectLiteralRepositoryPaths(
      markdownSources: markdownSources,
      diagnostics: diagnostics,
    );
    _inspectDuplicateParagraphs(
      markdownSources: markdownSources,
      diagnostics: diagnostics,
    );

    _inspectSharedReferenceOrphans(
      skillsRoot: skillsRoot,
      reachablePaths: reachableSharedReferencePaths,
      diagnostics: diagnostics,
    );

    if (descriptionCorpusWords > budgets.descriptionCorpusWords) {
      diagnostics.add(
        SkillDiagnostic(
          code: 'corpus.description.words',
          message:
              'Skill descriptions contain $descriptionCorpusWords words; '
              'maximum is ${budgets.descriptionCorpusWords}.',
          path: _relativePath(skillsRoot.path),
        ),
      );
    }

    return SkillValidationResult(List.unmodifiable(diagnostics));
  }

  String _relativePath(String path) {
    final prefix = '${repositoryRoot.path}/';
    return path.startsWith(prefix) ? path.substring(prefix.length) : path;
  }

  void _validateOpenAiMetadata({
    required Directory skillDirectory,
    required String skillName,
    required List<SkillDiagnostic> diagnostics,
  }) {
    final metadataFile = File('${skillDirectory.path}/agents/openai.yaml');
    final relativePath = _relativePath(metadataFile.path);
    if (!metadataFile.existsSync()) {
      diagnostics.add(
        SkillDiagnostic(
          code: 'openai.file.missing',
          message: 'agents/openai.yaml is required.',
          path: relativePath,
        ),
      );
      return;
    }

    final metadataSource = metadataFile.readAsStringSync();
    Object? yaml;
    try {
      yaml = loadYaml(metadataSource);
    } on YamlException catch (error) {
      diagnostics.add(
        SkillDiagnostic(
          code: 'openai.yaml.invalid',
          message: 'Metadata is not valid YAML: ${error.message}',
          path: relativePath,
        ),
      );
      return;
    }
    if (yaml is! YamlMap) {
      diagnostics.add(
        SkillDiagnostic(
          code: 'openai.schema.invalid',
          message: 'OpenAI metadata must be a YAML map.',
          path: relativePath,
        ),
      );
      return;
    }

    final interface = yaml['interface'];
    final displayName = interface is YamlMap ? interface['display_name'] : null;
    if (displayName is! String || displayName.trim().isEmpty) {
      diagnostics.add(
        SkillDiagnostic(
          code: 'openai.display_name.invalid',
          message: 'interface.display_name must be a non-empty string.',
          path: relativePath,
        ),
      );
    } else if (!_hasQuotedInterfaceScalar(metadataSource, 'display_name')) {
      diagnostics.add(
        SkillDiagnostic(
          code: 'openai.interface.unquoted',
          message: 'interface.display_name must use a quoted YAML scalar.',
          path: relativePath,
        ),
      );
    }

    final shortDescription = interface is YamlMap
        ? interface['short_description']
        : null;
    if (shortDescription is! String) {
      diagnostics.add(
        SkillDiagnostic(
          code: 'openai.short_description.invalid',
          message: 'interface.short_description must be a string.',
          path: relativePath,
        ),
      );
    } else {
      if (!_hasQuotedInterfaceScalar(metadataSource, 'short_description')) {
        diagnostics.add(
          SkillDiagnostic(
            code: 'openai.interface.unquoted',
            message:
                'interface.short_description must use a quoted YAML scalar.',
            path: relativePath,
          ),
        );
      }
      final length = shortDescription.trim().runes.length;
      if (length < budgets.shortDescriptionMinCharacters ||
          length > budgets.shortDescriptionMaxCharacters) {
        diagnostics.add(
          SkillDiagnostic(
            code: 'openai.short_description.length',
            message:
                'interface.short_description has $length characters; expected '
                '${budgets.shortDescriptionMinCharacters}-'
                '${budgets.shortDescriptionMaxCharacters}.',
            path: relativePath,
          ),
        );
      }
    }

    final defaultPrompt = interface is YamlMap
        ? interface['default_prompt']
        : null;
    if (defaultPrompt is! String || !defaultPrompt.contains('\$$skillName')) {
      diagnostics.add(
        SkillDiagnostic(
          code: 'openai.default_prompt.skill',
          message: 'interface.default_prompt must mention \$$skillName.',
          path: relativePath,
        ),
      );
    }
    if (defaultPrompt is String) {
      if (!_hasQuotedInterfaceScalar(metadataSource, 'default_prompt')) {
        diagnostics.add(
          SkillDiagnostic(
            code: 'openai.interface.unquoted',
            message: 'interface.default_prompt must use a quoted YAML scalar.',
            path: relativePath,
          ),
        );
      }
      final trimmedPrompt = defaultPrompt.trim();
      final sentenceTerminators = RegExp(
        r'[.!?](?=\s|$)',
      ).allMatches(trimmedPrompt);
      if (sentenceTerminators.length != 1 ||
          !RegExp(r'[.!?]$').hasMatch(trimmedPrompt)) {
        diagnostics.add(
          SkillDiagnostic(
            code: 'openai.default_prompt.sentence',
            message: 'interface.default_prompt must be exactly one sentence.',
            path: relativePath,
          ),
        );
      }
      if (!RegExp(r'<[A-Za-z0-9][A-Za-z0-9_ -]*>').hasMatch(defaultPrompt)) {
        diagnostics.add(
          SkillDiagnostic(
            code: 'openai.default_prompt.input',
            message:
                'interface.default_prompt must include an explicit '
                '<input> placeholder.',
            path: relativePath,
          ),
        );
      }
    }

    final policy = yaml['policy'];
    final allowImplicitInvocation = policy is YamlMap
        ? policy['allow_implicit_invocation']
        : null;
    if (allowImplicitInvocation is! bool) {
      diagnostics.add(
        SkillDiagnostic(
          code: 'openai.policy.invalid',
          message:
              'policy.allow_implicit_invocation must be an intentional boolean.',
          path: relativePath,
        ),
      );
    }
  }

  _ReferenceInspection _inspectReferences({
    required Directory skillsRoot,
    required Directory skillDirectory,
    required File skillFile,
    required String skillBody,
    required Set<String> reachableSharedReferencePaths,
    required List<SkillDiagnostic> diagnostics,
  }) {
    final sharedReferencesDirectory = Directory(
      '${skillsRoot.path}/references',
    );
    final reachablePaths = <String>{};
    final missingPaths = <String>{};
    final pending = <({File file, String markdown})>[
      (file: skillFile, markdown: skillBody),
    ];

    while (pending.isNotEmpty) {
      final current = pending.removeLast();
      for (final target in _localMarkdownTargets(current.markdown)) {
        final targetPath = p.normalize(
          p.join(p.dirname(current.file.path), target),
        );
        final targetFile = File(targetPath);
        if (!targetFile.existsSync()) {
          if (missingPaths.add(targetPath)) {
            diagnostics.add(
              SkillDiagnostic(
                code: 'reference.missing',
                message: 'Linked Markdown reference does not exist.',
                path: _relativePath(targetPath),
              ),
            );
          }
          continue;
        }

        final isLocalReference = p.isWithin(skillDirectory.path, targetPath);
        final isSharedReference = p.isWithin(
          sharedReferencesDirectory.path,
          targetPath,
        );
        if (!isLocalReference && !isSharedReference) {
          continue;
        }
        if (isSharedReference) {
          reachableSharedReferencePaths.add(targetPath);
        }
        if (!reachablePaths.add(targetPath)) {
          continue;
        }
        pending.add((
          file: targetFile,
          markdown: targetFile.readAsStringSync(),
        ));
      }
    }

    final referencesDirectory = Directory('${skillDirectory.path}/references');
    if (referencesDirectory.existsSync()) {
      final markdownReferences = referencesDirectory
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.toLowerCase().endsWith('.md'));
      for (final reference in markdownReferences) {
        final referencePath = p.normalize(reference.path);
        if (!reachablePaths.contains(referencePath)) {
          diagnostics.add(
            SkillDiagnostic(
              code: 'reference.orphan',
              message: 'Markdown reference is not reachable from SKILL.md.',
              path: _relativePath(referencePath),
            ),
          );
        }
      }
    }

    return _ReferenceInspection(
      reachableMarkdownFiles: reachablePaths.map(File.new).toList(),
    );
  }

  void _inspectSharedReferenceOrphans({
    required Directory skillsRoot,
    required Set<String> reachablePaths,
    required List<SkillDiagnostic> diagnostics,
  }) {
    final referencesDirectory = Directory('${skillsRoot.path}/references');
    if (!referencesDirectory.existsSync()) {
      return;
    }
    final markdownReferences =
        referencesDirectory
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.toLowerCase().endsWith('.md'))
            .toList()
          ..sort((left, right) => left.path.compareTo(right.path));
    for (final reference in markdownReferences) {
      final referencePath = p.normalize(reference.path);
      if (!reachablePaths.contains(referencePath)) {
        diagnostics.add(
          SkillDiagnostic(
            code: 'reference.orphan',
            message: 'Shared Markdown reference is not reachable from a skill.',
            path: _relativePath(referencePath),
          ),
        );
      }
    }
  }

  void _inspectLiteralRepositoryPaths({
    required List<({File file, String markdown})> markdownSources,
    required List<SkillDiagnostic> diagnostics,
  }) {
    final reportedPaths = <String>{};
    for (final source in markdownSources) {
      for (final literalPath in _literalRepositoryPaths(source.markdown)) {
        final targetPath = p.normalize(
          p.join(repositoryRoot.path, literalPath),
        );
        if (!FileSystemEntity.typeSync(targetPath).isNotFound) {
          continue;
        }
        final reportKey = '${source.file.path}\n$literalPath';
        if (!reportedPaths.add(reportKey)) {
          continue;
        }
        diagnostics.add(
          SkillDiagnostic(
            code: 'repository.path.missing',
            message:
                'Referenced repository path "$literalPath" does not exist.',
            path: _relativePath(source.file.path),
          ),
        );
      }
    }
  }

  void _inspectDuplicateParagraphs({
    required List<({File file, String markdown})> markdownSources,
    required List<SkillDiagnostic> diagnostics,
  }) {
    final firstSourceByParagraph = <String, String>{};
    final reportedParagraphs = <String>{};
    for (final source in markdownSources) {
      for (final paragraph in source.markdown.split(RegExp(r'\r?\n\s*\r?\n'))) {
        if (_wordCount(paragraph) < budgets.substantialParagraphWords) {
          continue;
        }
        final normalized = paragraph
            .replaceAll(RegExp(r'[`*_>#\[\]()]'), '')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim()
            .toLowerCase();
        final firstSource = firstSourceByParagraph[normalized];
        if (firstSource == null) {
          firstSourceByParagraph[normalized] = source.file.path;
        } else if (firstSource != source.file.path &&
            reportedParagraphs.add(normalized)) {
          diagnostics.add(
            SkillDiagnostic(
              code: 'content.paragraph.duplicate',
              message:
                  'Substantial paragraph duplicates guidance in '
                  '${_relativePath(firstSource)}.',
              path: _relativePath(source.file.path),
            ),
          );
        }
      }
    }
  }
}

_SkillDocument _parseSkillDocument(String source) {
  final match = RegExp(
    r'^---\r?\n([\s\S]*?)\r?\n---(?:\r?\n|$)',
  ).firstMatch(source);
  if (match == null) {
    throw const FormatException(
      'SKILL.md must start with YAML frontmatter delimited by --- lines.',
    );
  }

  final yaml = loadYaml(match.group(1)!);
  if (yaml is! YamlMap) {
    throw const FormatException('SKILL.md frontmatter must be a YAML map.');
  }
  return _SkillDocument(frontmatter: yaml, body: source.substring(match.end));
}

final class _SkillDocument {
  const _SkillDocument({required this.frontmatter, required this.body});

  final YamlMap frontmatter;
  final String body;
}

String _basename(String path) => path.replaceAll('\\', '/').split('/').last;

bool _isKebabCase(String value) =>
    RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(value);

bool _containsObsoleteHelpMode(String markdown) {
  final normalized = markdown.replaceAll('\r\n', '\n');
  return RegExp(
        r'^##\s+Help mode\s*$',
        caseSensitive: false,
        multiLine: true,
      ).hasMatch(normalized) ||
      normalized.contains('--help');
}

int _wordCount(String value) =>
    RegExp(r"[A-Za-z0-9]+(?:[-'][A-Za-z0-9]+)*").allMatches(value).length;

Iterable<String> _localMarkdownTargets(String markdown) sync* {
  final links = RegExp(r'!?\[[^\]]*\]\(([^)\s]+)(?:\s+[^)]*)?\)');
  for (final match in links.allMatches(markdown)) {
    final target = match.group(1)!;
    final uri = Uri.tryParse(target);
    if (uri == null ||
        uri.hasScheme ||
        uri.hasAuthority ||
        uri.path.isEmpty ||
        p.isAbsolute(uri.path)) {
      continue;
    }
    if (uri.path.toLowerCase().endsWith('.md')) {
      yield Uri.decodeComponent(uri.path);
    }
  }
}

final class _ReferenceInspection {
  const _ReferenceInspection({required this.reachableMarkdownFiles});

  final List<File> reachableMarkdownFiles;
}

Iterable<String> _literalRepositoryPaths(String markdown) sync* {
  const pathPrefixes = <String>[
    '.codex/',
    'android/',
    'assets/',
    'docs/',
    'ios/',
    'lib/',
    'linux/',
    'macos/',
    'packages/',
    'test/',
    'tool/',
    'web/',
    'windows/',
  ];
  const rootPaths = <String>{
    'AGENTS.md',
    'analysis_options.yaml',
    'pubspec.lock',
    'pubspec.yaml',
  };
  final inlineCode = RegExp(r'(?<!`)`([^`\n]+)`(?!`)');
  for (final match in inlineCode.allMatches(markdown)) {
    var candidate = match.group(1)!.trim();
    candidate = candidate.replaceFirst(RegExp(r'#[^/]*$'), '');
    candidate = candidate.replaceFirst(RegExp(r':\d+$'), '');
    if (candidate.isEmpty ||
        candidate.contains(RegExp(r'[<>{}*\[\]$|]')) ||
        candidate.contains('...') ||
        candidate.contains(' ') ||
        p.isAbsolute(candidate)) {
      continue;
    }
    if (rootPaths.contains(candidate) ||
        pathPrefixes.any(candidate.startsWith)) {
      yield candidate;
    }
  }
}

bool _hasQuotedInterfaceScalar(String yamlSource, String key) {
  final lines = yamlSource.replaceAll('\r\n', '\n').split('\n');
  int? interfaceIndent;
  for (final line in lines) {
    final trimmed = line.trim();
    if (interfaceIndent == null) {
      final interfaceMatch = RegExp(
        r'^(\s*)interface:\s*(?:#.*)?$',
      ).firstMatch(line);
      if (interfaceMatch != null) {
        interfaceIndent = interfaceMatch.group(1)!.length;
      }
      continue;
    }
    if (trimmed.isEmpty || trimmed.startsWith('#')) {
      continue;
    }
    final indentation = line.length - line.trimLeft().length;
    if (indentation <= interfaceIndent) {
      return false;
    }
    final scalarMatch = RegExp(
      '^\\s*${RegExp.escape(key)}:\\s*(.*)\$',
    ).firstMatch(line);
    if (scalarMatch == null) {
      continue;
    }
    final scalar = scalarMatch.group(1)!.trim();
    return RegExp(r'^"(?:[^"\\]|\\.)*"\s*(?:#.*)?$').hasMatch(scalar) ||
        RegExp(r"^'(?:[^']|'')*'\s*(?:#.*)?$").hasMatch(scalar);
  }
  return false;
}

extension on FileSystemEntityType {
  bool get isNotFound => this == FileSystemEntityType.notFound;
}
