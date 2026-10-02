# ADR-0012: Dart file roles, with dependency-injection modules

Status: accepted
Date: 2026-10-02
Decision maker: Euan Scott
Supersedes: [ADR-0011](0011-dart-file-role-vocabulary.md)

## Context

[ADR-0011](0011-dart-file-role-vocabulary.md) gave every Dart file a role,
chosen from a fixed list of 29. All files in scope were renamed to match. A
naming check now runs in the pre-commit hook and in CI.

Two files still held two kinds of code each:

- `analytics.facade.dart` held `AnalyticsFacade` and `AnalyticsModule`.
- `error_reporting.facade.dart` held `ErrorReportingFacade` and
  `ErrorReportingModule`.

A module class is a small piece of dependency-injection setup. The injectable
package reads it to learn how to build objects. Here, each module collects
one feature's services into a list and gives that list to the feature's
facade. For example, `ErrorReportingModule` combines the Crashlytics and
Coralogix reporters.

The rule is one role per file, so each module needs its own file. But no role
in the list describes a module.

The naming check also enforces three rules that ADR-0011 did not write down:

- A business name must not contain a dot.
- A test with a tooling role must live under `test/tool/`.
- A test of a bootstrap file must use the exact matching path.

## Decision

**We will add a `.module` role for dependency-injection modules. Each module
file lives in the same folder as the feature it sets up.**

This record replaces ADR-0011. It repeats every rule from ADR-0011, so that
one record holds the complete rule set. The only changes are the new
`.module` role and the three rules above.

The role list in the [AGENTS.md Naming section](../../AGENTS.md#naming) is the
copy that the naming check reads. It sits between the `naming-roles` markers.
That list and the tables below must always contain the same roles.

### Scope

Every hand-written Dart file in `lib/`, `test/`, `integration_test/` and
`tool/` needs a role. A short list of files is exempt; see
[Exemptions](#exemptions). Files in `packages/` keep their own naming style.

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
| `.module`    | Dependency-injection setup for one feature.                                             |
| `.observer`  | A framework observer, such as a `NavigatorObserver`.                                    |
| `.policy`    | A pure rule that decides access or behaviour.                                           |
| `.extension` | Dart extension methods.                                                                 |
| `.router`    | Router construction.                                                                    |
| `.constants` | Constant values only, such as route paths, endpoints, flag keys or a fixed config list. |
| `.model`     | A plain value type or enum that is not an entity or a DTO.                              |

Two notes on support roles:

- A class that holds state or calls the platform is a `.service`, even if
  its name contains "policy". For example, `orientation_policy.service.dart`
  is a `.service`.
- A `.module` file sits beside the feature it sets up. For example,
  `analytics.module.dart` sits beside `analytics.facade.dart`. The app-wide
  setup in `lib/core/di/` holds no feature modules.

Tooling roles, used only in `tool/` and `test/tool/`:

| Role          | Use for                                      |
|---------------|----------------------------------------------|
| `.validator`  | A rule checker run by the hooks or CI.       |
| `.cli`        | Command-line argument handling.              |
| `.executor`   | Code that runs processes or file operations. |
| `.evaluator`  | Code that scores a result.                   |
| `.comparator` | Code that compares two results.              |
| `.manifest`   | A manifest reader or writer.                 |

Test role, used only just before `_test`:

| Role    | Use for                                                          |
|---------|------------------------------------------------------------------|
| `.flow` | A test that drives several units. See [Test files](#test-files). |

### Name shape

A file name has the form `feature_or_entity.role.dart`:

- The business name joins words with `_`. It never contains a dot.
- Exactly one dot comes before the role.

### One role per file

Each file has exactly one role. If a file fits two roles, split it into two
files. For example, `app_language_options.dart` held a value type and a list
of constants. It became `app_language_option.model.dart` and
`app_language_options.constants.dart`.

### Test files

A test of one file copies that file's name and adds `_test`. For example,
`cards.bloc.dart` is tested by `cards.bloc_test.dart`.

A test of a `tool/` file lives under `test/tool/`.

A test that drives several units uses the `flow` role, such as
`cards_navigation.flow_test.dart`. Navigation, app-shell, localization and
integration tests use this role.

### Exemptions

These files need no role:

1. **Generated output:** `*.g.dart`, `*.freezed.dart`, `*.config.dart` and
   `lib/l10n/app_localizations*.dart`.
2. **Entry points:** any file, other than a test, that declares a top-level
   `main`. Examples are `lib/main.dart` and the `tool/` scripts that you run
   with `dart run`.
3. **App bootstrap:** `lib/dart_init.dart` and
   `lib/core/di/dependency_injection.dart`. Injectable names its generated
   file after the second one, so renaming it would rename generated output
   too.
4. **Bootstrap tests:** a test at the exact matching path of a bootstrap
   file, such as `test/core/di/dependency_injection_test.dart`.
5. **Shared test support:** everything under `test/support/`.
6. **Files outside the scope:** everything outside `lib/`, `test/`,
   `integration_test/` and `tool/`. This includes `packages/` and
   `test_driver/`.

Barrel files, which only re-export other files, are not exempt. No role fits
them, so code imports the real files instead.

## Alternatives

- **Put both modules in `lib/core/di/`, and exempt that folder.** All the
  setup would sit in one place. But core code would then depend on every
  feature's code, when features should depend on core. The exemption would
  also let any future file in that folder skip the naming check. Rejected.
- **Put both modules in `lib/core/di/`, with a `.module` role.** This avoids
  the exemption. Core code would still depend on feature code. Rejected.
- **Name module files with an existing role, such as `.service`.** A module
  does not provide a service. It only tells injectable how to build services
  that exist elsewhere. The name would mislead readers. Rejected.
- **Remove the modules, and inject each service into its facade by name.**
  Injectable cannot inject every registered service of one type as a list.
  So each facade would have to name its services one by one. That changes
  the design to solve a naming problem. Rejected.

ADR-0011 rejected five other options, and those reasons still apply. The
options were: an optional role, a role only in layer folders, roles in
`packages/`, exempting `tool/`, and exempting tests.

## Consequences

- `AnalyticsModule` and `ErrorReportingModule` move into
  `analytics.module.dart` and `error_reporting.module.dart`. Every file in
  scope then has exactly one role.
- The role list grows from 29 to 30.
- The naming check needs no code change. It reads the role list from
  AGENTS.md.
- A new feature that needs a module puts a `.module` file in its own folder.
  To find a feature's setup, look in that feature's folder.
- This record and the naming check now describe the same rules.
- Review this decision again if one module starts to set up more than one
  feature, if a new kind of file fits no role, or if the list grows past
  about 35 roles.

## Confirmation

The pre-commit hook and CI run the naming check:

```sh
dart run tool/naming/naming.dart check
```

If a file passes only because someone added a new role or exemption, this
record was bypassed or needs a successor. The AGENTS.md role list and the
tables in this record must always match.
