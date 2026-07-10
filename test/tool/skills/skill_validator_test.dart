import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/skills/skill.validator.dart';
import '../../../tool/skills/validate.dart' as cli;

void main() {
  group('SkillValidator', () {
    test('reports a missing local skill corpus as invalid', () async {
      final fixture = await _SkillFixture.create();
      addTearDown(fixture.dispose);

      final result = SkillValidator(
        repositoryRoot: fixture.repositoryRoot,
      ).validate();

      expect(result.isValid, isFalse);
      expect(result.diagnostics, hasLength(1));
      expect(
        result.diagnostics.single.toJson(),
        equals(<String, Object?>{
          'code': 'corpus.skills_root.missing',
          'message': 'Local skill corpus directory does not exist.',
          'path': '.codex/skills',
        }),
      );
    });

    test('accepts a valid local skill corpus', () async {
      final fixture = await _SkillFixture.create();
      addTearDown(fixture.dispose);
      await fixture.addSkill('valid-skill');

      final result = SkillValidator(
        repositoryRoot: fixture.repositoryRoot,
      ).validate();

      expect(result.isValid, isTrue);
      expect(result.diagnostics, isEmpty);
    });

    test('reports malformed SKILL.md frontmatter', () async {
      final fixture = await _SkillFixture.create();
      addTearDown(fixture.dispose);
      await fixture.addSkill('broken-skill');
      await fixture.writeSkillMarkdown('broken-skill', '''
---
name: [broken
---

# Broken Skill

## Workflow
''');

      final result = SkillValidator(
        repositoryRoot: fixture.repositoryRoot,
      ).validate();

      expect(
        result.diagnostics.map((diagnostic) => diagnostic.code),
        contains('skill.frontmatter.invalid'),
      );
    });

    test('allows only name and description frontmatter keys', () async {
      final fixture = await _SkillFixture.create();
      addTearDown(fixture.dispose);
      await fixture.addSkill('extra-frontmatter');
      await fixture.writeSkillMarkdown('extra-frontmatter', '''
---
name: extra-frontmatter
description: Validate a focused local workflow safely.
license: MIT
---

# Extra Frontmatter

## Workflow

Run the workflow safely.
''');

      final result = SkillValidator(
        repositoryRoot: fixture.repositoryRoot,
      ).validate();

      expect(
        result.diagnostics.map((diagnostic) => diagnostic.code),
        contains('skill.frontmatter.keys'),
      );
    });

    test('requires kebab-case directory and matching skill name', () async {
      final fixture = await _SkillFixture.create();
      addTearDown(fixture.dispose);
      await fixture.addSkill('invalid_name');

      final result = SkillValidator(
        repositoryRoot: fixture.repositoryRoot,
      ).validate();

      expect(
        result.diagnostics.map((diagnostic) => diagnostic.code),
        containsAll(<String>{'skill.directory.invalid', 'skill.name.invalid'}),
      );
    });

    test('reports duplicate frontmatter names across skills', () async {
      final fixture = await _SkillFixture.create();
      addTearDown(fixture.dispose);
      await fixture.addSkill('first-skill');
      await fixture.addSkill('second-skill');
      await fixture.writeSkillMarkdown(
        'second-skill',
        await fixture.readSkillMarkdown('first-skill'),
      );

      final result = SkillValidator(
        repositoryRoot: fixture.repositoryRoot,
      ).validate();

      expect(
        result.diagnostics.map((diagnostic) => diagnostic.code),
        contains('skill.name.duplicate'),
      );
    });

    test('enforces configurable description word budgets', () async {
      final fixture = await _SkillFixture.create();
      addTearDown(fixture.dispose);
      await fixture.addSkill(
        'first-skill',
        description: 'One two three four five.',
      );
      await fixture.addSkill(
        'second-skill',
        description: 'Six seven eight nine ten.',
      );

      final result = SkillValidator(
        repositoryRoot: fixture.repositoryRoot,
        budgets: const SkillValidationBudgets(
          descriptionWords: 4,
          descriptionCorpusWords: 9,
        ),
      ).validate();

      final codes = result.diagnostics.map((diagnostic) => diagnostic.code);
      expect(
        codes.where((code) => code == 'skill.description.words'),
        hasLength(2),
      );
      expect(codes, contains('corpus.description.words'));
    });

    test('enforces configurable body and activated-path budgets', () async {
      final fixture = await _SkillFixture.create();
      addTearDown(fixture.dispose);
      await fixture.addSkill('budget-skill');
      await fixture.writeSkillMarkdown('budget-skill', '''
---
name: budget-skill
description: Validate a focused local workflow safely.
---

# Budget Skill

## Workflow

One two three four five six seven eight.

Read [details](references/details.md).
''');
      await fixture.writeReference(
        'budget-skill',
        'details.md',
        'Nine ten eleven twelve thirteen fourteen fifteen sixteen.',
      );

      final result = SkillValidator(
        repositoryRoot: fixture.repositoryRoot,
        budgets: const SkillValidationBudgets(
          bodyWords: 10,
          activatedPathWords: 20,
        ),
      ).validate();

      expect(
        result.diagnostics.map((diagnostic) => diagnostic.code),
        containsAll(<String>{'skill.body.words', 'skill.activated_path.words'}),
      );
    });

    test(
      'rejects obsolete Help mode sections and --help instructions',
      () async {
        final fixture = await _SkillFixture.create();
        addTearDown(fixture.dispose);
        await fixture.addSkill('obsolete-help-section');
        await fixture.writeSkillMarkdown('obsolete-help-section', '''
---
name: obsolete-help-section
description: Validate a focused local workflow safely.
---

# Obsolete Help Section

## Help Mode

Return usage safely.
''');
        await fixture.addSkill('obsolete-help-flag');
        await fixture.writeSkillMarkdown('obsolete-help-flag', '''
---
name: obsolete-help-flag
description: Validate a focused local workflow safely.
---

# Obsolete Help Flag

## Workflow

When `--help` is present, return usage safely.
''');

        final result = SkillValidator(
          repositoryRoot: fixture.repositoryRoot,
        ).validate();

        expect(
          result.diagnostics.where(
            (diagnostic) => diagnostic.code == 'skill.help_mode.obsolete',
          ),
          hasLength(2),
        );
      },
    );

    test('validates OpenAI interface schema and invocation policy', () async {
      final fixture = await _SkillFixture.create();
      addTearDown(fixture.dispose);
      await fixture.addSkill('metadata-skill');
      await fixture.writeOpenAiMetadata('metadata-skill', '''
interface:
  display_name: 42
  short_description: "Too short"
  default_prompt: "Run the workflow without naming its skill."
policy:
  allow_implicit_invocation: "false"
''');

      final result = SkillValidator(
        repositoryRoot: fixture.repositoryRoot,
      ).validate();

      expect(
        result.diagnostics.map((diagnostic) => diagnostic.code),
        containsAll(<String>{
          'openai.display_name.invalid',
          'openai.short_description.length',
          'openai.default_prompt.skill',
          'openai.policy.invalid',
        }),
      );
    });

    test('requires lexically quoted OpenAI interface strings', () async {
      final fixture = await _SkillFixture.create();
      addTearDown(fixture.dispose);
      await fixture.addSkill('quoted-metadata');
      await fixture.writeOpenAiMetadata('quoted-metadata', '''
interface:
  display_name: Quoted Metadata
  short_description: Run the focused quoted metadata workflow
  default_prompt: Use \$quoted-metadata to process <request> safely.
policy:
  allow_implicit_invocation: false
''');

      final result = SkillValidator(
        repositoryRoot: fixture.repositoryRoot,
      ).validate();

      expect(
        result.diagnostics
            .where(
              (diagnostic) => diagnostic.code == 'openai.interface.unquoted',
            )
            .map((diagnostic) => diagnostic.message),
        hasLength(3),
      );
    });

    test('accepts single-quoted OpenAI interface strings', () async {
      final fixture = await _SkillFixture.create();
      addTearDown(fixture.dispose);
      await fixture.addSkill('single-quotes');
      await fixture.writeOpenAiMetadata('single-quotes', '''
interface:
  display_name: 'Single Quotes'
  short_description: 'Run the focused single quotes workflow'
  default_prompt: 'Use \$single-quotes to process <request> safely.'
policy:
  allow_implicit_invocation: false
''');

      final result = SkillValidator(
        repositoryRoot: fixture.repositoryRoot,
      ).validate();

      expect(
        result.diagnostics.where(
          (diagnostic) => diagnostic.code == 'openai.interface.unquoted',
        ),
        isEmpty,
      );
    });

    test('requires one-sentence prompts with an explicit input', () async {
      final fixture = await _SkillFixture.create();
      addTearDown(fixture.dispose);
      await fixture.addSkill('prompt-shape');
      await fixture.writeOpenAiMetadata('prompt-shape', '''
interface:
  display_name: "Prompt Shape"
  short_description: "Run the focused prompt shape workflow"
  default_prompt: "Use \$prompt-shape now. Then continue."
policy:
  allow_implicit_invocation: false
''');

      final result = SkillValidator(
        repositoryRoot: fixture.repositoryRoot,
      ).validate();

      expect(
        result.diagnostics.map((diagnostic) => diagnostic.code),
        containsAll(<String>{
          'openai.default_prompt.sentence',
          'openai.default_prompt.input',
        }),
      );
    });

    test('reports missing links and orphan Markdown references', () async {
      final fixture = await _SkillFixture.create();
      addTearDown(fixture.dispose);
      await fixture.addSkill('reference-skill');
      final skillMarkdown = await fixture.readSkillMarkdown('reference-skill');
      await fixture.writeSkillMarkdown(
        'reference-skill',
        '$skillMarkdown\nRead [missing details](references/missing.md).\n',
      );
      await fixture.writeReference(
        'reference-skill',
        'orphan.md',
        'This reference is not reachable from the skill.',
      );

      final result = SkillValidator(
        repositoryRoot: fixture.repositoryRoot,
      ).validate();

      expect(
        result.diagnostics.map((diagnostic) => diagnostic.code),
        containsAll(<String>{'reference.missing', 'reference.orphan'}),
      );
    });

    test('reports literal repository paths that do not exist', () async {
      final fixture = await _SkillFixture.create();
      addTearDown(fixture.dispose);
      await fixture.addSkill('path-skill');
      final skillMarkdown = await fixture.readSkillMarkdown('path-skill');
      await fixture.writeSkillMarkdown(
        'path-skill',
        '$skillMarkdown\nInspect `lib/missing_feature.dart`.\n',
      );

      final result = SkillValidator(
        repositoryRoot: fixture.repositoryRoot,
      ).validate();

      expect(
        result.diagnostics.map((diagnostic) => diagnostic.code),
        contains('repository.path.missing'),
      );
    });

    test(
      'reports missing repository paths in reachable shared references',
      () async {
        final fixture = await _SkillFixture.create();
        addTearDown(fixture.dispose);
        await fixture.addSkill('path-skill');
        final skillMarkdown = await fixture.readSkillMarkdown('path-skill');
        await fixture.writeSkillMarkdown(
          'path-skill',
          '$skillMarkdown\nRead [shared details](../references/shared.md).\n',
        );
        await fixture.addSkill('second-path-skill');
        final secondSkillMarkdown = await fixture.readSkillMarkdown(
          'second-path-skill',
        );
        await fixture.writeSkillMarkdown(
          'second-path-skill',
          '$secondSkillMarkdown\n'
              'Read [shared details](../references/shared.md).\n',
        );
        await fixture.writeSharedReference(
          'shared.md',
          'Inspect `lib/missing_shared_feature.dart` before continuing.\n',
        );

        final result = SkillValidator(
          repositoryRoot: fixture.repositoryRoot,
        ).validate();

        expect(
          result.diagnostics
              .where(
                (diagnostic) => diagnostic.code == 'repository.path.missing',
              )
              .map((diagnostic) => diagnostic.path),
          equals(<String>['.codex/skills/references/shared.md']),
        );
      },
    );

    test('reports substantial paragraphs duplicated in a reference', () async {
      final fixture = await _SkillFixture.create();
      addTearDown(fixture.dispose);
      await fixture.addSkill('duplicate-content');
      const paragraph =
          'This substantial paragraph repeats the same focused guidance across '
          'both instruction files deliberately.';
      final skillMarkdown = await fixture.readSkillMarkdown(
        'duplicate-content',
      );
      await fixture.writeSkillMarkdown(
        'duplicate-content',
        '$skillMarkdown\n$paragraph\n\nRead [details](references/details.md).\n',
      );
      await fixture.writeReference(
        'duplicate-content',
        'details.md',
        '# Details\n\n$paragraph\n',
      );

      final result = SkillValidator(
        repositoryRoot: fixture.repositoryRoot,
      ).validate();

      expect(
        result.diagnostics.map((diagnostic) => diagnostic.code),
        contains('content.paragraph.duplicate'),
      );
    });

    test(
      'reports corpus-wide duplicate paragraphs once across skill and references',
      () async {
        final fixture = await _SkillFixture.create();
        addTearDown(fixture.dispose);
        await fixture.addSkill('first-skill');
        await fixture.addSkill('second-skill');
        const skillParagraph =
            'This substantial routing paragraph deliberately repeats across '
            'two different skill instruction files for validation coverage.';
        const referenceParagraph =
            'This substantial reference paragraph deliberately repeats between '
            'a local reference and shared guidance for validation coverage.';
        final firstMarkdown = await fixture.readSkillMarkdown('first-skill');
        await fixture.writeSkillMarkdown(
          'first-skill',
          '$firstMarkdown\n$skillParagraph\n\n'
              'Read [local details](references/local.md).\n\n'
              'Read [shared details](../references/shared.md).\n',
        );
        final secondMarkdown = await fixture.readSkillMarkdown('second-skill');
        await fixture.writeSkillMarkdown(
          'second-skill',
          '$secondMarkdown\n$skillParagraph\n\n'
              'Read [shared details](../references/shared.md).\n',
        );
        await fixture.writeReference(
          'first-skill',
          'local.md',
          '# Local details\n\n$referenceParagraph\n',
        );
        await fixture.writeSharedReference(
          'shared.md',
          '# Shared details\n\n$referenceParagraph\n',
        );

        final result = SkillValidator(
          repositoryRoot: fixture.repositoryRoot,
        ).validate();

        final duplicates = result.diagnostics.where(
          (diagnostic) => diagnostic.code == 'content.paragraph.duplicate',
        );
        expect(duplicates, hasLength(2));
        expect(
          duplicates.map((diagnostic) => diagnostic.path).toSet(),
          equals(<String>{
            '.codex/skills/second-skill/SKILL.md',
            '.codex/skills/references/shared.md',
          }),
        );
      },
    );

    test('rejects README files inside skill directories', () async {
      final fixture = await _SkillFixture.create();
      addTearDown(fixture.dispose);
      await fixture.addSkill('readme-skill');
      await fixture.writeSkillFile(
        'readme-skill',
        'README.md',
        '# Duplicated skill documentation\n',
      );

      final result = SkillValidator(
        repositoryRoot: fixture.repositoryRoot,
      ).validate();

      expect(
        result.diagnostics.map((diagnostic) => diagnostic.code),
        contains('skill.readme.forbidden'),
      );
    });

    test(
      'CLI emits JSON and returns zero or nonzero from validation',
      () async {
        final fixture = await _SkillFixture.create();
        addTearDown(fixture.dispose);
        await fixture.addSkill('cli-skill');
        final validOutput = StringBuffer();

        final validExitCode = cli.runSkillValidationCli(
          const ['--json'],
          repositoryRoot: fixture.repositoryRoot,
          output: validOutput,
        );

        expect(validExitCode, 0);
        expect(jsonDecode(validOutput.toString()), containsPair('valid', true));

        await fixture.writeSkillFile(
          'cli-skill',
          'README.md',
          '# Invalid duplicate documentation\n',
        );
        final invalidOutput = StringBuffer();

        final invalidExitCode = cli.runSkillValidationCli(
          const ['--json'],
          repositoryRoot: fixture.repositoryRoot,
          output: invalidOutput,
        );

        expect(invalidExitCode, 1);
        expect(
          jsonDecode(invalidOutput.toString()),
          containsPair('valid', false),
        );
      },
    );

    test('accounts for corpus-level shared Markdown references', () async {
      final fixture = await _SkillFixture.create();
      addTearDown(fixture.dispose);
      await fixture.addSkill('first-skill');
      await fixture.writeSkillMarkdown('first-skill', '''
---
name: first-skill
description: Validate a focused local workflow safely.
---

# First

Read [shared guidance](../references/shared.md).
''');
      await fixture.addSkill('second-skill');
      await fixture.writeSkillMarkdown('second-skill', '''
---
name: second-skill
description: Validate another focused local workflow safely.
---

# Second

Read [shared guidance](../references/shared.md).
''');
      await fixture.writeSharedReference(
        'shared.md',
        'One two three four five six seven eight nine ten.',
      );
      await fixture.writeSharedReference(
        'orphan.md',
        'This shared reference has no incoming link.',
      );

      final result = SkillValidator(
        repositoryRoot: fixture.repositoryRoot,
        budgets: const SkillValidationBudgets(
          bodyWords: 100,
          activatedPathWords: 16,
        ),
      ).validate();

      expect(
        result.diagnostics.where(
          (diagnostic) => diagnostic.code == 'skill.activated_path.words',
        ),
        hasLength(2),
      );
      expect(
        result.diagnostics
            .where((diagnostic) => diagnostic.code == 'reference.orphan')
            .map((diagnostic) => diagnostic.path),
        equals(<String>['.codex/skills/references/orphan.md']),
      );
      expect(
        result.diagnostics.map((diagnostic) => diagnostic.path),
        isNot(contains('.codex/skills/references/SKILL.md')),
      );
    });
  });
}

class _SkillFixture {
  _SkillFixture._(this.repositoryRoot);

  final Directory repositoryRoot;

  static Future<_SkillFixture> create() async {
    final repositoryRoot = await Directory.systemTemp.createTemp(
      'project_tweety_skill_validator_',
    );
    return _SkillFixture._(repositoryRoot);
  }

  Future<void> addSkill(
    String name, {
    String description = 'Validate a focused local workflow safely.',
  }) async {
    final skillDirectory = Directory(
      '${repositoryRoot.path}/.codex/skills/$name',
    );
    await Directory('${skillDirectory.path}/agents').create(recursive: true);

    await File('${skillDirectory.path}/SKILL.md').writeAsString('''
---
name: $name
description: $description
---

# ${_titleCase(name)}

## Workflow

Inspect the request, perform the focused workflow, and report verification.
''');

    await File('${skillDirectory.path}/agents/openai.yaml').writeAsString('''
interface:
  display_name: "${_titleCase(name)}"
  short_description: "Run the focused $name workflow safely"
  default_prompt: "Use \$$name to perform <request> through the focused workflow."
policy:
  allow_implicit_invocation: false
''');
  }

  Future<void> writeSkillMarkdown(String name, String contents) => File(
    '${repositoryRoot.path}/.codex/skills/$name/SKILL.md',
  ).writeAsString(contents);

  Future<String> readSkillMarkdown(String name) => File(
    '${repositoryRoot.path}/.codex/skills/$name/SKILL.md',
  ).readAsString();

  Future<void> writeReference(
    String skillName,
    String referenceName,
    String contents,
  ) async {
    final referenceDirectory = Directory(
      '${repositoryRoot.path}/.codex/skills/$skillName/references',
    );
    await referenceDirectory.create(recursive: true);
    await File(
      '${referenceDirectory.path}/$referenceName',
    ).writeAsString(contents);
  }

  Future<void> writeOpenAiMetadata(String skillName, String contents) => File(
    '${repositoryRoot.path}/.codex/skills/$skillName/agents/openai.yaml',
  ).writeAsString(contents);

  Future<void> writeSkillFile(
    String skillName,
    String relativePath,
    String contents,
  ) => File(
    '${repositoryRoot.path}/.codex/skills/$skillName/$relativePath',
  ).writeAsString(contents);

  Future<void> writeSharedReference(String name, String contents) async {
    final directory = Directory(
      '${repositoryRoot.path}/.codex/skills/references',
    );
    await directory.create(recursive: true);
    await File('${directory.path}/$name').writeAsString(contents);
  }

  Future<void> dispose() => repositoryRoot.delete(recursive: true);
}

String _titleCase(String value) => value
    .split('-')
    .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
    .join(' ');
