# ADR-0021: Root agent context holds guardrails and pointers; standards live in CODING_STANDARDS.md

Status: accepted
Date: 2026-10-30
Decision maker: Euan Scott

## Context

`CLAUDE.md` imports the root `AGENTS.md`, so every line of it is in context on
every agent turn. The root file had grown to 156 lines. Most of those lines
were one of three kinds: facts that one lookup reveals (`pubspec.yaml`, the
directory layout, `tool/templates/feature_template_paths.constants.dart`),
rules that a validator already enforces with a clear message, or rules that
only some tasks need. The file-name role list had to stay in the root because
`tool/naming/naming.validator.dart` read it from there.

Commits were also expected to follow a trunk-based flow, but nothing stated it.
The agent harness default ("if on the default branch, branch first") then won
at every commit.

## Decision

**We will keep the root `AGENTS.md` to hard guardrails plus context pointers,
and move coding and process standards to a root `CODING_STANDARDS.md`.**
`CODING_STANDARDS.md` holds the file-name role list between the
`naming-roles` markers, and the naming check reads it from there. The git
guardrails (trunk-based on `main`, branches and pull requests only on request,
Conventional Commits) stay inline in the root, because they must beat a harness
default that fires at every commit without any lookup.

## Consequences

- The always-loaded root drops from 156 to about 30 lines. The context
  validator gives the root a 40-line budget so it cannot grow back unnoticed.
- An agent reaches standards only through the "Dart code" pointer. If agents
  start to name files, build value types or pick dependencies against the
  standards, sharpen that pointer first, then move the rule back inline.
- ADR-0012's role list location changes; its role vocabulary does not.
- Re-evaluate when short-lived spike branches are decided (a TODO in
  `CODING_STANDARDS.md`).

## Confirmation

The pre-commit hook and CI run `dart run tool/agent_context/validate.dart`
(root line budget, links in `CODING_STANDARDS.md`) and
`dart run tool/naming/naming.dart check` (role list read from
`CODING_STANDARDS.md`).
