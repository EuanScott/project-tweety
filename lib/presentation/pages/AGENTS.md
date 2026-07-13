# AGENTS.md

## Scope

This guidance applies to pages and page BLoCs/Cubits under
`lib/presentation/pages/` and supplements the root and `lib/` guidance.

## Source of truth and routing

- Use `lib/presentation/pages/_template/` for the default page/BLoC shape.
- Prefer `$page-scaffold` when lower-layer contracts already exist.
- Use `$feature-scaffold` when the feature still needs its data layer; add
  domain only when mobile-owned policy justifies it.
- Use `/implement` for changes to an existing page, with TDD for behavior
  changes.

## Controller choice

- Prefer BLoC for meaningful events, multiple user intents, retry/refresh flows,
  or orchestration where event names add clarity.
- Use Cubit for direct commands, local UI state, or a simple single-load flow
  where events would only rename method calls.
- Keep one Freezed state with a feature-scoped status enum for either controller.
- Keep BLoC events small; a bootstrap flow normally starts with one
  `<Feature>Started` event.

## Page structure and wiring

- Place each page under `lib/presentation/pages/<feature>/`.
- Keep BLoC files under `bloc/` and Cubit files under `cubit/`.
- Follow the naming conventions in `lib/AGENTS.md` and use the local template
  for the concrete file manifest.
- Own the controller lifecycle with `BlocProvider(create: ...)` and resolve
  injected controllers with `GetIt.I<...>()`.
- Trigger initial loading during provider creation when required.
- Prefer `BlocBuilder` for rendering and `BlocConsumer` only when side effects
  are also required.

## Rendering and boundaries

- Render loading, failure, and success explicitly.
- Keep business policy in the controller or lower layer, not the page.
- Render app-facing repository values or domain entities, never DTOs.
- Use matching adaptive primitives from `package:design_system` for visible UI.
- Keep retry behavior event- or command-driven and pages small.

## Verification

- Add focused controller and widget tests for observable state and rendering.
- Regenerate Freezed/Injectable outputs from their inputs; never hand-edit
  generated files.
