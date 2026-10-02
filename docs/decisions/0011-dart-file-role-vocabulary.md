# ADR-0011: Dart file role vocabulary

Status: superseded
Date: 2026-10-02
Decision maker: Euan Scott
Superseded by: [ADR-0012](0012-dart-file-roles-with-di-modules.md)

## Context

The project names Dart files `feature_or_entity.role.dart`. AGENTS.md listed
11 roles. The codebase used more, and many files used no role at all.

An inventory of tracked Dart files, with generated output removed, showed:

- `lib/` used four roles that AGENTS.md did not list: `.service`, `.storage`,
  `.generator` and `.cubit`.
- `tool/` used eight more: `.validator`, `.cli`, `.executor`, `.evaluator`,
  `.comparator`, `.manifest`, `.models` and `.events`.
- 34 files in `lib/`, 26 in `test/` and 7 in `tool/` had no role. Some map to
  a listed role directly (`home_bloc.dart`, `app_modal.dart`). Others have no
  natural role in the old list: `router.dart`, `routes.dart`,
  `api_endpoints.dart`, `modal_extension.dart`, `analytics_facade.dart`.
- Some test files test one file (`cards_list_test.dart`). Others drive a flow
  across several units (`cards_navigation_test.dart`, `app_shell_test.dart`).
- All 69 files in `packages/` used plain pub-style names, such as
  `app_button.dart`.

A planned pre-commit check will reject badly named files. It needs one agreed
list to check against. Without that list, humans, agents and the validator disagree about which names
are correct.

One constraint affects naming: injectable generates
`dependency_injection.config.dart`. The `.config.dart` suffix is therefore
reserved for generated output and cannot be a hand-written role.

## Decision

**We will require a role from one closed vocabulary on every hand-written Dart
file in `lib/`, `test/`, `integration_test/` and `tool/`, apart from a fixed
set of exemptions. `packages/` is out of scope.**

### Roles

Layer roles:

| Role               | Use for                               |
|--------------------|---------------------------------------|
| `.page`            | A routed page.                        |
| `.widget`          | Any other widget.                     |
| `.bloc`            | A `Bloc`.                             |
| `.cubit`           | A `Cubit`.                            |
| `.event`           | Bloc events.                          |
| `.state`           | Bloc or cubit state.                  |
| `.entity`          | A domain entity in `lib/domain`.      |
| `.dto`             | A data transfer object in `lib/data`. |
| `.repository`      | A repository contract.                |
| `.repository_impl` | A repository implementation.          |
| `.datasource`      | A datasource.                         |
| `.usecase`         | A domain use case.                    |

Support roles:

| Role         | Use for                                                                                 |
|--------------|-----------------------------------------------------------------------------------------|
| `.service`   | A long-lived or stateless app service, such as analytics, HTTP or a navigation tracker. |
| `.storage`   | A local persistence handle or its migrations.                                           |
| `.generator` | Code that produces values or files, such as IDs or scaffolds.                           |
| `.facade`    | A narrow interface in front of a service.                                               |
| `.observer`  | A framework observer, such as a `NavigatorObserver`.                                    |
| `.policy`    | A pure rule that decides access or behaviour.                                           |
| `.extension` | Dart extension methods.                                                                 |
| `.router`    | Router construction.                                                                    |
| `.constants` | Constant values only, such as route paths, endpoints, flag keys or a fixed config list. |
| `.model`     | A plain value type or enum that is not an entity or a DTO.                              |

A class that holds state or calls the platform is a `.service`, even when its
name contains "policy". For example, `orientation_policy.service.dart` stays a
`.service`.

Tooling roles, used in `tool/` only:

| Role          | Use for                                      |
|---------------|----------------------------------------------|
| `.validator`  | A rule checker run by the hooks or CI.       |
| `.cli`        | Command-line argument handling.              |
| `.executor`   | Code that runs processes or file operations. |
| `.evaluator`  | Code that scores a result.                   |
| `.comparator` | Code that compares two results.              |
| `.manifest`   | A manifest reader or writer.                 |

Test role, used before `_test` only:

| Role    | Use for                                                          |
|---------|------------------------------------------------------------------|
| `.flow` | A test that drives several units. See [Test files](#test-files). |

Two roles in use are marked for renaming:

- `.models` becomes `.model`. Roles are singular, like the rest of the list.
- `.events` becomes `.model`. The file holds parsed tool output, not bloc
  events, so `.event` would mislead.

### One role per file

A file has exactly one role. A file that fits two roles is split. For example,
`app_language_options.dart` holds a value type and a list of constants, so it
becomes `app_language_option.model.dart` and
`app_language_options.constants.dart`.

### Test files

A test that tests one file mirrors that file's name, followed by `_test`:
`cards.bloc.dart` is tested by `cards.bloc_test.dart`.

A test that drives several units uses the `flow` role:
`cards_navigation.flow_test.dart`. This applies to navigation, app-shell,
localization and integration tests.

### Exemptions

These files need no role:

1. Generated output: `*.g.dart`, `*.freezed.dart`, `*.config.dart` and
   `lib/l10n/app_localizations*.dart`.
2. Entry points: a non-test file that declares a top-level `main`. This
   covers `lib/main.dart`, the `tool/` scripts run with `dart run`, and
   `test_driver/integration_test.dart`.
3. App bootstrap: `lib/dart_init.dart` and
   `lib/core/di/dependency_injection.dart`. Injectable derives the generated
   file name from the second file, so a rename would also rename generated
   output.
4. Shared test support: everything under `test/support/`.
5. Everything under `packages/`.

Barrel files inside the scope are not exempt, and no role fits them. Code
imports the real files instead. The rename work removes the two barrels in
scope:
`lib/features/dynamic_form/data/data.dart` and
`tool/skills/scaffold/scaffold.dart`.

## Alternatives

- **Role optional.** A file could have no role, but any role it has must be
  official. The vocabulary is smaller. The validator then cannot catch
  `home_bloc.dart` or `app_modal.dart`, which are exactly the mistakes this
  convention exists to prevent. Rejected.
- **Role required only in layer folders.** Require a role in `lib/data`,
  `lib/domain` and `lib/presentation`, but not in `lib/core` or navigation.
  This gives two rules to remember and a boundary that moves when folders
  move. Rejected.
- **Rename `card_id.generator.dart` to a `.service`.** This removes one role
  from `lib/`. `tool/` still needs `.generator` for the scaffold generator, so
  the vocabulary does not get smaller. Rejected.
- **Apply the convention to `packages/`.** This adds about 69 renames and
  changes file paths that package users import. The packages expose their API
  through a barrel file, and pub-style plain names are the norm for published
  Dart packages. Rejected.
- **Exempt `tool/`.** `tool/` already uses roles for most files. Exempting it
  would discard a convention that is already followed. Rejected.
- **Exempt tests, or let multi-unit tests omit the role.** A validator cannot
  tell a forgotten role from a deliberate flow test. The `flow` role makes
  every test name checkable. Rejected.

## Consequences

- Every hand-written file in scope has one checkable name. A pre-commit check
  can enforce the rule with a closed list and a short exemption list.
- The vocabulary grows from 11 roles to 29. More roles mean more choices. The
  "Use for" column limits that cost.
- `.model`, `.entity` and `.dto` are close in meaning. A reviewer must check
  that a value type uses the role of its layer: `.entity` in `lib/domain`,
  `.dto` in `lib/data`, and `.model` elsewhere.
- About 56 files must change to comply. 53 role-less files that are not
  exempt are renamed. The `.models` and `.events` files are renamed. One
  file, `app_language_options.dart`, is split in two. Two barrel files are
  removed. This record renames nothing; a separate change does the renames.
- `packages/` keeps a different naming style from the app. Contributors must
  know which rule applies where.
- Re-evaluate if a new file type fits no role, if `packages/` stop exposing
  their API only through barrel files, or if the vocabulary grows past about
  35 roles.

## Confirmation

Until the pre-commit check exists, reviewers check new file names against the
[Naming section in AGENTS.md](../../AGENTS.md#naming). The AGENTS.md list and
this record must contain the same roles.

After the check exists, the pre-commit hook and CI reject a staged Dart file whose
name breaks this convention. A file that passes only because someone added a
new exemption or role means this record was bypassed or needs a successor.
