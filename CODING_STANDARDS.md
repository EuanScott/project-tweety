# Coding Standards

This file is the single source of truth for coding and process standards in
this repository. Directory-local rules live in the nearest `AGENTS.md`. The
reasons behind each rule live in the ADRs in [docs/decisions](docs/decisions/README.md).

## Git workflow

- Development is trunk-based. Commit directly on `main`, or on the branch the
  user has checked out.
- Create a branch or pull request only when the user asks for one.
- TODO(owner): decide whether short-lived spike or research branches
  (for example `spike/<topic>`) are allowed without an explicit request.
- Dependabot still opens its own pull requests for dependency updates
  ([ADR-0018](docs/decisions/0018-supply-chain-security-checks-in-ci.md)).
- Write every commit message as a Conventional Commit: `type(scope): subject`.
- The commit type sets the version. `.githooks/post-commit` bumps `version:`
  in `pubspec.yaml` and amends the commit, so the commit hash changes after
  `git commit`:
  - `feat`/`feature` and any breaking marker bump the minor while the major
    is `0`.
  - `fix`/`perf` bump the patch.
  - Every other type leaves the version alone.
  - A version you change by hand in the same commit is never re-bumped.
  - `NO_VERSION_BUMP=1 git commit ...` skips the bump. `--no-verify` does not.
  - The logic is in `tool/hooks/bump_version.sh`
    ([ADR-0009](docs/decisions/0009-conventional-commit-driven-versioning.md)).
- The hooks run only after `git config core.hooksPath .githooks` (once per
  clone). If `git config core.hooksPath` does not print `.githooks`, tell the
  user.
- `.githooks/pre-commit` runs the agent context, skill, ADR and file-naming
  validators, then `flutter analyze --no-fatal-infos` and
  `tool/hooks/bloc_lint.sh` on the staged Dart files. CI runs the same checks
  on the whole project and fails on any warning or error
  ([ADR-0010](docs/decisions/0010-pre-commit-analysis-and-ci-enforcement.md)).
- When a hook fails, fix the cause and commit again. Bypassing a hook with
  `--no-verify` is the user's decision.

## Design principles

These are judgement calls, not mechanical gates. Weigh them per change, and do
not cite one to justify either extreme.

- **YAGNI**: build a layer, abstraction or config surface only for a concrete
  need. A deeply layered module (for example `lib/domain`) earns its cost only
  when the current task requires it.
- **SOLID**: apply it where it reduces coupling or clarifies a
  responsibility.
- **KISS**: up to two branches (a simple `if`/`else`) stay inline in the
  calling method. A third branch justifies a helper method.
- **DRY**: two occurrences of a snippet may stay duplicated. The third
  occurrence justifies a shared helper.
- **Efficiency**: default to linear-time algorithms and single-pass data
  access. Use a map, set, index or single pass instead of a nested scan
  (for example `.where`/`.contains` inside another loop). Quadratic cost is
  acceptable only for small, bounded input (such as a fixed-size UI list) or
  when a linear rewrite clearly hurts readability; state the reason inline.

## Naming

Dart files are named `feature_or_entity.role.dart`: `_` inside the business
name, `.` before the role. Every hand-written Dart file in `lib/`, `test/`,
`integration_test/` and `tool/` has exactly one role from the closed list
below. `packages/` keep plain pub-style names. The meaning of each role is in
[ADR-0012](docs/decisions/0012-dart-file-roles-with-di-modules.md).

`tool/naming/naming.validator.dart` reads the roles between the markers, so
this list is the single source. The pre-commit hook and CI reject a name that
breaks it.

<!-- naming-roles:start -->
  - Layer roles: `.page`, `.widget`, `.bloc`, `.cubit`, `.event`, `.state`,
    `.entity`, `.dto`, `.repository`, `.repository_impl`, `.datasource`,
    `.usecase`
  - Support roles: `.service`, `.storage`, `.generator`, `.facade`,
    `.module`, `.observer`, `.policy`, `.extension`, `.router`,
    `.constants`, `.model`
  - Tooling roles, `tool/` and `test/tool/` only: `.validator`, `.cli`,
    `.executor`, `.evaluator`, `.comparator`, `.manifest`
  - Test role, before `_test` only: `.flow`
<!-- naming-roles:end -->

Rules the validator does not check:

- `.model` is a plain value type or enum. Use `.entity` in `lib/domain` and
  `.dto` in `lib/data` instead.
- A file has exactly one role. Split a file that fits two roles.
- A test of one file mirrors that file's name: `logs.bloc_test.dart`,
  `app_modal.widget_test.dart`. A test that drives several units uses the
  `flow` role: `logs_navigation.flow_test.dart`.

Exempt from roles: generated output (`*.g.dart`, `*.freezed.dart`,
`*.config.dart`, `lib/l10n/app_localizations*.dart`), non-test files that
declare a top-level `main`, `lib/dart_init.dart`,
`lib/core/di/dependency_injection.dart`, and everything under `test/support/`.

## Value types

- Immutable value types use `freezed` in every layer: entities, app-facing
  repository values, storage models, events and state.
- Model alternatives as a sealed `freezed` union, not a status enum plus
  nullable fields.
- Let `freezed` generate `copyWith` and equality; hand-written `copyWith`
  sentinels and `Equatable` `props` overrides are out
  ([ADR-0004](docs/decisions/0004-value-type-conventions.md)).

## Code style

- `analysis_options.yaml` and `bloc_lint` own lint rules. A suppression is
  listed explicitly with its reason.
- Imports: package imports for app entrypoints and shared modules; relative
  imports where they are already generated or established.
- Write a comment only to explain non-obvious behaviour that the code cannot
  express.

## UI

- Visible UI in pages and app-level shared widgets uses the adaptive
  primitives exported by `package:design_system` when a matching primitive
  exists.
- When a raw Material or Cupertino control is needed more than once, add an
  adaptive primitive to `packages/design_system` first. The primitive owns the
  Material/Cupertino branching; callers express app intent.
- Reusable app-wide theming lives in `packages/design_system`, not `lib/`.

## Generated files

Change the source, then regenerate. Generated files are never hand-edited.

- DI (`lib/core/di/dependency_injection.config.dart`) and `freezed` output:
  `dart run build_runner build --delete-conflicting-outputs`.
- Localization (`lib/l10n/app_localizations*.dart`): edit the ARB files, then
  run `flutter gen-l10n`.

## Platforms and dependencies

- Flutter and Dart are pinned exactly in every `pubspec.yaml` (the app,
  `packages/design_system` and `packages/navigation`). Change all three
  together.
- Minimum iOS is `17.0` and minimum Android is API level `34`. These values
  live in `ios/Runner.xcodeproj/project.pbxproj`, `android/app/build.gradle`
  and `flutter_launcher_icons.yaml`; keep them equal. The `NewLogControls`
  iOS extension targets iOS `18.0` as a stated exception
  ([ADR-0020](docs/decisions/0020-ios-control-extension-targets-ios-18.md)).
- iOS dependencies use Swift Package Manager only. Add only plugins that
  support Swift Package Manager, and keep the iOS project free of a `Podfile`.

## Testing

- The [testing guide](docs/testing/README.md) owns test types, placement,
  the shared harness and commands
  ([ADR-0002](docs/decisions/0002-test-layer-conventions.md)).
- Some existing tests are older scaffolded examples. Align new tests with
  current app behaviour, not with obsolete smoke tests.
