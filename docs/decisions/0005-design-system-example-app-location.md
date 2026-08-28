# ADR-0005: design_system example app lives inside the package

Status: proposed
Date: 2026-08-28
Decision maker: Euan Scott

## Context

design_system is being built out as an increasingly self-contained package —
presentation-only, independent of project_tweety per its own AGENTS.md — with
an eventual possibility of moving to its own repository. A component gallery
app is being added so widgets can be visually evaluated in isolation. The
repo's other multi-app precedent would suggest a top-level `apps/` directory,
sibling to `packages/`.

## Decision

**We will place the gallery app at `packages/design_system/example/`**,
following the standard Flutter/pub.dev package convention, rather than at a
top-level `apps/design_system_gallery/`.

## Alternatives

- **`apps/design_system_gallery/`** — reads as "another product in this
  workspace" and scales better if a second consumer app ever appears.
  Rejected because it would need to be manually re-homed if `design_system`
  is extracted to its own repository; `example/` travels with the package
  automatically.

## Consequences

- If `design_system` is ever split out, the gallery moves with zero extra
  work.
- Deviates from the `apps/`-sibling-to-`packages/` shape a reader might
  otherwise expect elsewhere in this monorepo; this ADR is the answer to "why
  is it nested in here."

## Confirmation

`packages/design_system/example/pubspec.yaml` depends on `design_system` via
a relative path dependency, not a workspace-root reference.
