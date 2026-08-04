# Domain Docs

How the engineering skills should consume this repo's domain documentation when exploring the codebase.

## Before exploring, read these

- **`CONTEXT.md`** at the repo root, if it exists.
- **`docs/decisions/`** — this repo's ADRs live here (not `docs/adr/`). Read ADRs that touch the area you're about to work in. See `docs/decisions/adr-template.md` for the format and `tool/decisions/adr.dart` / `tool/decisions/adr.validator.dart` for the tooling that manages them.

If `CONTEXT.md` doesn't exist yet, **proceed silently**. Don't flag its absence; don't suggest creating it upfront. The `/domain-modeling` skill (reached via `/grill-with-docs` and `/improve-codebase-architecture`) creates it lazily when terms or decisions actually get resolved.

## File structure (single-context)

```
/
├── CONTEXT.md
├── docs/decisions/
│   ├── adr-template.md
│   └── 0001-....md
└── lib/
```

`packages/design_system` and `packages/navigation` are supporting packages of this one app, not separate contexts — don't treat them as needing their own `CONTEXT.md`/ADR trees unless that changes materially (e.g. either package is published/consumed independently).

## Use the glossary's vocabulary

When your output names a domain concept (in an issue title, a refactor proposal, a hypothesis, a test name), use the term as defined in `CONTEXT.md`. Don't drift to synonyms the glossary explicitly avoids.

If the concept you need isn't in the glossary yet, that's a signal — either you're inventing language the project doesn't use (reconsider) or there's a real gap (note it for `/domain-modeling`).

## Flag ADR conflicts

If your output contradicts an existing ADR under `docs/decisions/`, surface it explicitly rather than silently overriding:

> _Contradicts ADR-0007 (event-sourced orders) — but worth reopening because…_
