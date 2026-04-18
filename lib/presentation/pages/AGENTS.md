# AGENTS.md

## Scope
- This file applies to all page and page-BLoC work under `lib/presentation/pages/`.
- Follow the broader guidance in `lib/AGENTS.md`, but prefer the rules here when working specifically on pages and their BLoCs.

## Page Structure
- Each BLoC-driven page should live under `lib/presentation/pages/<feature>/`.
- Keep BLoC files inside `lib/presentation/pages/<feature>/bloc/`.
- Prefer this file layout:
  - `<feature>.page.dart`
  - `bloc/<feature>.bloc.dart`
  - `bloc/<feature>.event.dart`
  - `bloc/<feature>.state.dart`
- Follow the repo-wide naming rule: use `_` inside the business name and `.` before the technical role.
- Keep page widgets small and focused; extract private widgets such as loading, error, and content sections when the page grows.

## BLoC State Pattern
- Prefer a single Freezed state per page BLoC.
- Include a feature-scoped status enum such as `CardsStatus`.
- Prefer derived getters like `isLoading`, `isFailure`, `hasItems`, and `hasError` for clearer rendering logic.
- Add `const MyState._();` when using derived getters on Freezed states.
- Do not add placeholder getters that throw `UnimplementedError()`.

## BLoC Event Pattern
- Keep event sets small.
- For simple page bootstrap flows, start with a single event such as `CardsStarted`.
- Only add more events when there is a real UI action or interaction to support.

## UI Wiring
- Prefer `BlocProvider(create: ...)` at the page root when the page owns the BLoC.
- Resolve injected BLoCs with `GetIt.I<YourBloc>()`.
- Trigger the initial load inline with creation, for example:
  - `GetIt.I<CardsBloc>()..add(const CardsStarted())`
- Prefer `BlocBuilder` for rendering-only pages.
- Use `BlocConsumer` only if the page must both rebuild and trigger side effects.

## Rendering Guidance
- Render loading, failure, and success states explicitly.
- Keep retry logic in the error widget simple and event-driven.
- Avoid putting business logic in the page; keep it in the BLoC or lower layers.
- The page should render domain entities, not DTOs.

## Feature Naming
- Use domain-meaningful feature names throughout the page and BLoC.
- Keep names aligned end-to-end, for example:
  - `Cards`
  - `CardsBloc`
  - `CardsState`
  - `CardsEvent`
  - `CardsStarted`
  - `CardsStatus`
- Preferred filenames are:
  - `cards.page.dart`
  - `cards.bloc.dart`
  - `cards.event.dart`
  - `cards.state.dart`

## Reference Implementation
- Use the `cards` page as the default example for future BLoC page implementations.
