# AGENTS.md

## Scope
- This file applies to all page and page state-management work under `lib/presentation/pages/`.
- Follow the broader guidance in `lib/AGENTS.md`, but prefer the rules here when working specifically on pages and their BLoCs or Cubits.

## Skill Hints
- Users can build pages and BLoCs/Cubits directly. `$page-scaffold` is an optional helper for the common repo pattern.
- For raw page and BLoC scaffolds, mirror `_template`:
  - `lib/presentation/pages/_template/_template.page.dart`
  - `lib/presentation/pages/_template/bloc/_template.bloc.dart`
  - `lib/presentation/pages/_template/bloc/_template.event.dart`
  - `lib/presentation/pages/_template/bloc/_template.state.dart`
- Keep the initial page payload-free: loading, failure, and success states only.
- Prefer `$page-scaffold` when adding a new page and BLoC/Cubit flow on top of existing lower-layer work.
- If the lower layers do not exist yet, prefer `$feature-scaffold` or `$data-scaffold` for the default BFF-backed path. Add `$domain-scaffold` only when mobile-owned domain behavior is justified.
- If the user wants to see the supported inputs and examples, run `$page-scaffold --help`.

## Page Structure
- Each BLoC- or Cubit-driven page should live under `lib/presentation/pages/<feature>/`.
- Keep BLoC files inside `lib/presentation/pages/<feature>/bloc/` and Cubit files inside `lib/presentation/pages/<feature>/cubit/`.
- Prefer this file layout:
  - `<feature>.page.dart`
  - `bloc/<feature>.bloc.dart`
  - `bloc/<feature>.event.dart`
  - `bloc/<feature>.state.dart`
- Follow the repo-wide naming rule: use `_` inside the business name and `.` before the technical role.
- Keep page widgets small and focused; extract private widgets such as loading, error, and content sections when the page grows.

## BLoC State Pattern
- Prefer a single Freezed state per page BLoC.
- Include a feature-scoped status enum such as `OrdersStatus`.
- Prefer derived getters like `isLoading`, `isFailure`, `hasItems`, and `hasError` for clearer rendering logic.
- Add `const MyState._();` when using derived getters on Freezed states.
- Do not add placeholder getters that throw `UnimplementedError()`.

## Cubit Pattern
- Cubit is allowed when state changes are simple commands rather than meaningful events.
- Prefer Cubit for small preference screens, local UI state, or single-load flows where events would only rename method calls.
- Keep Cubit state shape aligned with the BLoC state guidance: one Freezed state with status and explicit error fields when loading can fail.

## BLoC Event Pattern
- Keep event sets small.
- For simple page bootstrap flows, start with a single event such as `OrdersStarted`.
- Only add more events when there is a real UI action or interaction to support.

## UI Wiring
- Prefer `BlocProvider(create: ...)` at the page root when the page owns the BLoC.
- Resolve injected BLoCs/Cubits with `GetIt.I<YourBloc>()` or `GetIt.I<YourCubit>()`.
- Trigger the initial load inline with creation, for example:
  - `GetIt.I<FeatureBloc>()..add(const FeatureStarted())`
- Prefer `BlocBuilder` for rendering-only pages.
- Use `BlocConsumer` only if the page must both rebuild and trigger side effects.

## Rendering Guidance
- Render loading, failure, and success states explicitly.
- Keep retry logic in the error widget simple and event-driven.
- Avoid putting business logic in the page; keep it in the BLoC or lower layers.
- The page should render app-facing values, not DTOs. These may come from data repositories by default or domain entities when an optional domain layer exists.
- Use app/design-system primitives for visible UI controls and feedback when they exist. For example, render loading with `AppLoadingIndicator`, actions with `AppButton`, rows with `AppListTile`, and selection fields with `AppPickerField`.
- Do not add raw Material or Cupertino controls directly to pages for reusable UI patterns. Add or extend a narrow primitive in `packages/design_system` first so native platform branching stays centralized.

## Feature Naming
- Use product-meaningful feature names throughout the page and BLoC.
- Keep names aligned end-to-end, for example:
  - `<Feature>`
  - `<Feature>Bloc`
  - `<Feature>Cubit`
  - `<Feature>State`
  - `<Feature>Event`
  - `<Feature>Started`
  - `<Feature>Status`
- Preferred filenames are:
  - `<feature>.page.dart`
  - `<feature>.bloc.dart`
  - `<feature>.cubit.dart`
  - `<feature>.event.dart`
  - `<feature>.state.dart`

## Example
- Raw scaffold examples include `TemplatePage`, `TemplateBloc`, and `_template.page.dart`.
- If an existing page differs from this document, follow the documented convention unless the deviation is intentional and documented.
