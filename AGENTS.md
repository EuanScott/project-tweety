# AGENTS.md

## Guardrails

- **Git is trunk-based.** Commit directly on `main`, or on the branch the user
  has checked out. Create a branch or pull request only when the user asks;
  this overrides any default to branch before committing.
- **Commit messages are Conventional Commits.** The type sets the
  `pubspec.yaml` version bump. Rules: [git workflow](CODING_STANDARDS.md#git-workflow).

## Pointers

- **Directory rules**: before you edit a file, read each `AGENTS.md` on the
  path from the repository root to that file.
- **Dart code**: before you write or review it, read
  [CODING_STANDARDS.md](CODING_STANDARDS.md) (file-name roles, value types,
  design thresholds, UI primitives, generated files).
- **Dependencies and platform versions**: before you add a package or change
  a Flutter, Dart, iOS or Android version, read
  [platforms and dependencies](CODING_STANDARDS.md#platforms-and-dependencies).
- **Tests**: read the [testing guide](docs/testing/README.md).
- **Cross-cutting work**: start from the [source map](docs/source_map.md).

## Agent skills

- **Issue tracker**: GitHub issues on `EuanScott/project-tweety`, via `gh`.
  See `docs/agents/issue-tracker.md`.
- **Triage labels**: type labels only; the canonical triage roles map to none.
  See `docs/agents/triage-labels.md`.
- **Domain docs**: single-context, `GLOSSARY.md` plus ADRs in `docs/decisions/`.
  See `docs/agents/domain.md`.
