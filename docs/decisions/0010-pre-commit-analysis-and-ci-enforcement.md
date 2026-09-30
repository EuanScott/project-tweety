# ADR-0010: Pre-commit analysis and CI enforcement

Status: accepted
Date: 2026-09-30
Decision maker: Euan Scott
Supersedes: [ADR-0003](0003-pre-commit-validator-enforcement.md)

## Context

ADR-0003 put the three `tool/` validators in a local pre-commit hook and left CI responsible for analysis and tests
only. It rejected CI for the validators because the repository has one committer, and said to re-evaluate if that
changed.

Three facts changed the balance:

- CI could not fail on analysis. Every `flutter analyze` step ran under `continue-on-error: true`, so analysis was
  advisory everywhere.
- The `bloc:` rules in `analysis_options.yaml` ran nowhere. `flutter analyze` ignores them; only the `bloc lint`
  command from `bloc_tools` applies them, and nothing invoked it.
- The repository now also serves as a trial of this enforcement set-up for a multi-developer team, and as a
  feedback loop for agent-written changes. Both need a check that a skipped hook cannot bypass.

`bloc lint` exits non-zero on any issue, including infos, and has no option equivalent to `--no-fatal-infos`.

## Decision

**We will analyze staged Dart files in the pre-commit hook, and make CI the enforcing check.** The hook keeps the
three validators and adds `flutter analyze --no-fatal-infos` and `bloc lint` on the staged Dart files. CI runs the
three validators, full-project analysis and full-project `bloc lint`, and a failure in any of them fails the build.
Infos never block, in either place.

## Alternatives

- **Hook analyzes staged files, CI analyzes everything** (chosen): the hook gives feedback in seconds on the files
  being committed; CI catches everything the hook cannot see.
- **Hook analyzes the whole project**: complete, but slower on every commit, and it reports problems in unrelated
  files. CI already gives full coverage.
- **Staged-file filtering, reconsidered**: ADR-0003 rejected filtering the validators by staged path, because their
  failures come from changes to link targets, not linking files. The same gap exists for analysis: a changed
  signature breaks callers that are not staged. It is accepted here because blocking CI now closes it. The validators
  stay unfiltered.
- **Validators in the hook only** (the ADR-0003 position): rejected, because `--no-verify` and unconfigured clones skip
  the hook. CI is the only check that holds for every committer.
- **`bloc_tools` as a global install**: rejected in favour of a pinned development dependency. The version is locked
  in `pubspec.lock` and every clone gets it from `flutter pub get`, with no separate install step.
- **Promote the two info-level bloc rules to warnings**: rejected; it changes rule policy to work around a tool
  limitation. A wrapper script fails only on warnings and errors instead.

## Consequences

- Analysis errors, analysis warnings, bloc warnings and bloc errors now fail CI. Infos are reported but never block.
- CI runs one root `flutter analyze`, which also covers `packages/`. Every package must run `flutter pub get` first,
  so CI resolves every tracked `pubspec.yaml` before analysis.
- `tool/hooks/bloc_lint.sh` depends on the text format of `bloc lint` output (lines starting `warning[` or `error[`).
  `bloc_tools` is a pre-release, pinned to an exact version for this reason. Check the script when upgrading it.
- A commit that stages Dart files takes several seconds longer, mainly for analyzer start-up. Commits with no Dart
  files are unchanged.
- The hook runs `flutter analyze --no-pub`, so a commit never changes `pubspec.lock`. The cost: after a dependency
  change, the hook analyzes against the old resolution until `flutter pub get` runs. CI always resolves first.
- The hook still reads the working tree, not the index. A partly staged file is analyzed as it is on disk. This is
  accepted knowingly, as in ADR-0003.
- The hook stays opt-in per clone through `core.hooksPath`, and bypassable with `git commit --no-verify`. CI is the
  enforcement point; the hook is fast feedback.

## Confirmation

Verify that the hook blocks a warning but not an info. This creates nothing, because the commit never completes:

```sh
printf "import 'dart:async';\n" > lib/zz_probe.dart
git add lib/zz_probe.dart
git commit -m "probe"          # expect unused_import warning, exit 1
git reset -q -- lib/zz_probe.dart && rm lib/zz_probe.dart
```

Verify the CI checks locally from the repository root:

```sh
flutter analyze --no-fatal-infos --no-pub
tool/hooks/bloc_lint.sh lib test packages
```

For later changes, a new validator or linter goes into both `.githooks/pre-commit` and `.github/workflows/ci.yml`,
unless this record is superseded.
