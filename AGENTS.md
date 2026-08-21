# AGENTS.md

## Project Overview
- `project-tweety` is a Flutter playground app for exploring ideas, patterns, and experiments outside of production work.
- Prefer small, focused changes that fit the exploratory nature of the repo.
- Preserve the existing layered structure instead of introducing new architectural styles unless the task explicitly requires it.

## Tech Stack
- Flutter with Dart `>=3.11.5 <4.0.0`
- State management and DI packages include `bloc`, `flutter_bloc`, `get_it`, and `injectable`
- Code generation is used for DI and Flutter-generated assets/localization

## Repository Layout
- `packages/design_system`: shared Flutter design system package for reusable theming and UI-level primitives
- `lib/core`: cross-cutting concerns such as analytics, DI, error reporting, and feature flags
- `lib/data`: constants, DTOs, datasources, repositories, and services
- `lib/domain`: optional mobile-owned domain concepts, repository contracts, and use cases for features that need app-specific policy beyond BFF-shaped data
- `lib/features`: feature-scoped experiments; currently includes `dynamic_form`
- `lib/presentation`: pages, widgets, extensions, and UI helpers
- `lib/l10n`: ARB files and generated localization output
- `test`: widget and shared/unit tests

For cross-cutting orientation, read the [source map](docs/source_map.md).

## Skill Routing
- Users can work directly in the codebase without using any skill. Skills are optional accelerators, not a required workflow.
- Invocation policy lives in each skill's `agents/openai.yaml`; authoring and validation rules live in `.codex/skills/AGENTS.md`.
- For future layered feature work, treat `_template` as the source of truth for the BFF-backed layered architecture scaffold with optional domain:
  - `tool/templates/feature/data/repositories/_template.repository.dart`
  - `tool/templates/feature/data/repositories/_template.repository_impl.dart`
  - `lib/domain/_template/README.md` when a domain branch is justified
  - `tool/templates/feature/presentation/pages/_template.page.dart`
  - `tool/templates/feature/presentation/pages/widgets/_template_error.widget.dart`
  - `tool/templates/feature/presentation/pages/bloc/`
- Do not add a domain layer by default. Assume the BFF owns mobile-specific shaping and most business logic; add `lib/domain` only case-by-case for mobile-owned policy or custom app behavior, such as settings.
- Full feature scaffolds, new shared widgets, existing shared-widget updates, and proactive single-view performance audits may select their matching local skill implicitly.
- Layer-only `$data-scaffold`, `$domain-scaffold`, and `$page-scaffold` flows require explicit invocation. Ordinary behaviour changes stay in the normal implementation/TDD flow.

## Working Conventions

- Follow the existing lint rules in `analysis_options.yaml`. The workspace uses  `very_good_analysis` (not
  `flutter_lints`), with `strict-casts`,  `strict-inference`, and `strict-raw-types` enabled. Suppressions are listed
  explicitly with a reason.
- Match the current import style: package imports for app entrypoints and shared modules, relative imports where already generated or established.
- Treat this document as the source of truth for repository policy; use the
  referenced `_template` files as the source of truth for concrete scaffold
  structure.
- Visible UI in pages and app-level shared widgets must use the adaptive primitives exported by `package:design_system` when a matching primitive exists.
- Keep the route entry, `GetIt.I` resolution, provider lifecycle, and the root state-routing view in `<feature>.page.dart`. The root view is the page's body, not a helper; extracting it leaves a file that no longer shows what the route renders.
- Keep the root view as its own `const` widget class rather than merging it into the page class. It needs a `BuildContext` below any page-owned `BlocProvider`, or `context.read`/`context.watch` in the page's own `build` resolves above the provider and throws at callback time; `BlocBuilder` and `BlocListener` passed as a direct `child:` are exempt because they resolve from their own element. A `const` root view also stops the rebuild traversal when the page rebuilds on an inherited-widget dependency such as `AppLocalizations.of(context)`.
- Keep the pure UI helper widgets that root view composes in `lib/presentation/pages/<feature>/widgets/` as `part` files of the page library, named `<feature>_<widget>.widget.dart` with `part of '../<feature>.page.dart';`. They may consume state and dispatch events but must not resolve DI, reach lower layers, or hold business policy.
- Remember that `part` files cannot declare imports: every import a page-local widget needs belongs in the `.page.dart` file. Widgets reused across pages belong in `lib/presentation/widgets/` or `packages/design_system` instead.
- Add missing native/adaptive UI primitives to `packages/design_system` before using raw Material or Cupertino controls repeatedly in pages or shared widgets. The design-system primitive owns the Material/Cupertino branching; callers express app intent.
- Standardize filenames on `feature_or_entity.role.dart`.
- Use `_` inside the business name and `.` before the technical role.
- Preferred role suffixes are:
  - `.page.dart`
  - `.widget.dart`
  - `.bloc.dart`
  - `.event.dart`
  - `.state.dart`
  - `.entity.dart`
  - `.dto.dart`
  - `.repository.dart`
  - `.repository_impl.dart`
  - `.datasource.dart`
  - `.usecase.dart`
- Immutable value types use `freezed` in every layer — entities, app-facing
  repository values, storage models, events, and state. Never hand-write a
  `copyWith` sentinel or an `Equatable` `props` override. Prefer a sealed
  `freezed` union over a status enum plus nullable fields. See
  [ADR-0004](docs/decisions/0004-value-type-conventions.md).
- Test files always end `_test.dart`, singular. The Dart runner globs exactly
  that, so a file named `_tests.dart` is silently never collected. Combine the
  role suffix with it where a role applies: `cards.bloc_test.dart`,
  `app_modal.widget_test.dart`.
- Do not add inline comments unless they clarify non-obvious behavior that cannot be expressed cleanly in code.

## Generated Files
- Treat generated files as derived artifacts unless the task explicitly targets generation output.
- Do not hand-edit these files unless absolutely necessary:
  - `lib/core/di/dependency_injection.config.dart`
  - `lib/l10n/app_localizations.dart`
  - `lib/l10n/app_localizations_en.dart`
  - `lib/l10n/app_localizations_es.dart`
- If source annotations, ARB files, or generation inputs change, regenerate instead of patching generated output directly.

## Common Commands
- Install dependencies: `flutter pub get`
- Enable the repo git hooks (once per clone): `git config core.hooksPath .githooks`
- Run the app: `flutter run`
- Run tests: `flutter test`
- Regenerate DI/build_runner output: `dart run build_runner build --delete-conflicting-outputs`
- Refresh localization output after ARB changes: `flutter gen-l10n`
- `.githooks/pre-commit` runs the agent context, skill, and ADR validators on every commit; bypass with `git commit --no-verify`.

## Testing Guidance
- Read the [testing guide](docs/testing/README.md) for the three test execution
  contexts, the layer-to-test-type mapping, and the shared harness in
  `test/support/`. The rationale is [ADR-0002](docs/decisions/0002-test-layer-conventions.md).
- Default to constructing the subject under test directly. Use `GetIt` only for
  tests that drive `MyApp`, and go through `useAppHarness()` when you do.
- Prefer adding a parameter to `FakeCardsRepository` over writing a new fake.
- Prefer targeted tests first, then broader validation if needed.
- Add or update tests near the affected area when the repo already has an appropriate test pattern.
- Avoid fixing unrelated failing tests as part of a focused task.
- Existing tests may include older scaffolded examples; align new tests with the current app behavior rather than preserving obsolete smoke tests.

## Change Scope
- Keep changes surgical and relevant to the requested task.
- Avoid committing build artifacts or platform-specific output unless the user explicitly asks for them.
- Prefer editing source files under `lib/`, `test/`, and project config files over touching generated directories like `build/`, `.dart_tool/`, `android/build/`, or `ios/Pods/`.
- Prefer placing reusable app-wide theming in `packages/design_system` instead of recreating it under `lib/`.


## Agent skills

### Issue tracker

Issues are tracked as GitHub issues on `EuanScott/project-tweety`, via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Default canonical triage labels (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `CONTEXT.md` at the repo root (create lazily) + ADRs under `docs/decisions/`. See `docs/agents/domain.md`.
