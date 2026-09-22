# Project Tweety

[![Version](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2FEuanScott%2Fproject-tweety%2Fmain%2Fpubspec.yaml&query=%24.version&label=version&color=blue)](pubspec.yaml)
[![CI](https://github.com/EuanScott/project-tweety/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/EuanScott/project-tweety/actions/workflows/ci.yml)

A playground project to try out some ideas and work on some blockers that I face in my day job. I'm not really building
anything to serve a purpose here.

## Development Style

Historically, I've always used [Git FLow](https://www.gitkraken.com/learn/git/git-flow), specifically at work. However,
as this is a playground project, I will be using [Trunk Based Development](https://trunkbaseddevelopment.com/).

## Setup & Usage

Nothing fancy here, I'm just following the "Get started" guide on
the [Official Flutter Docs](https://docs.flutter.dev/get-started/install)

This project requires Flutter `3.47.0` (Dart `3.13.0`). After installing dependencies, enable the repo's git hooks once
per clone:

```sh
git config core.hooksPath .githooks
```

Then use the following validation loop:

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze --no-fatal-infos
dart run tool/agent_context/validate.dart
flutter test
```

Run one test file with:

```sh
flutter test test/path_test.dart
```

This loop is a superset of CI: CI runs analysis and tests, while the agent context validator is local-only. A green
local loop therefore means a green build, but not the reverse.

Native Android and iOS coverage remains an explicit device/simulator check:

```sh
flutter test integration_test/cards_sqlite_smoke_test.dart -d <device-id>
```

See [the testing guide](docs/testing/README.md) for what belongs in `test/`,
`integration_test/`, and `test_driver/`.

### Pre-commit hook

`.githooks/pre-commit` runs the three agent-tooling validators on every commit:

```sh
dart run tool/agent_context/validate.dart
dart run tool/skills/validate.dart
dart run tool/decisions/adr.dart check
```

These guard `AGENTS.md` line budgets, Markdown link integrity, skill word budgets, and ADR structure. They fail silently
in the sense that nothing else catches them, so the hook is the enforcement point.

Bypass with `git commit --no-verify`.

Two caveats. The validators read the working tree rather than the index, so a partially staged commit is checked against
what is on disk, not what is being committed. And the hook needs `dart` on `PATH`, which a GUI git client may not
provide.

### Versioning

`pubspec.yaml` is the version of record, and it is maintained by the commit message rather than by hand.
`.githooks/post-commit` reads the Conventional Commit type and amends the commit with the matching bump:

| Commit type                                                      | Bump                                           |
|------------------------------------------------------------------|------------------------------------------------|
| `feat`, `feature`                                                | minor                                          |
| `fix`, `perf`                                                    | patch                                          |
| `!` marker or `BREAKING CHANGE:` footer                          | minor while the major is `0`, otherwise major. |
| everything else (`chore`, `docs`, `refactor`, `test`, `ci`, ...) | none                                           |

Two things follow from the amending. The commit hash printed by `git commit` is stale, so read `git log -1` before
quoting
one. And `--no-verify` does not skip this hook — git does not pass that flag to `post-commit`. Use
`NO_VERSION_BUMP=1 git commit ...` instead. A version edited by hand in the same commit is never re-bumped, which is how
`1.0.0` and any deliberate correction get set.

The version badge at the top of this file reads `pubspec.yaml` from `main`, so it follows a push with no separate
release step.

The rationale, including why `pre-commit` and `commit-msg` cannot do this,
is [ADR-0009](docs/decisions/0009-conventional-commit-driven-versioning.md). The mapping itself lives in
`tool/hooks/bump_version.sh`.

## Project Docs

Broader project guides live under [`docs/`](docs/). Current guides include:

- [Navigation, deep links, and route guards](docs/testing/navigation.md)
- [Cards SQLite persistence and native smoke testing](docs/architecture/cards_sqlite_foundation.md)
- [Architecture Decision Records](docs/decisions/README.md)
- [Conventional-commit-driven versioning](docs/decisions/0009-conventional-commit-driven-versioning.md)

## API Documentation

This project uses Dart doc comments for generated API documentation.

To generate the docs locally:

```sh
dart doc --output doc/api
```

Then open the generated docs:

```sh
open doc/api/index.html
```

The generated `doc/api/` output is ignored by git.
