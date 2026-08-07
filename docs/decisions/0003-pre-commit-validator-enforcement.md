# ADR-0003: Pre-commit validator enforcement

Status: proposed
Date: 2026-08-07
Decision maker: Euan Scott

## Context

Three read-only validators live under `tool/`:

- `tool/agent_context/validate.dart` — `AGENTS.md` line budgets, Markdown link integrity, canonical template presence.
- `tool/skills/validate.dart` — description, body, and activated-path word budgets for `.codex/skills/**`.
- `tool/decisions/adr.dart check` — ADR headings, statuses, and catalog index.

Nothing ran them automatically. `.github/workflows/ci.yml` invokes none of them; it runs analysis and tests only.
Enforcement was prose aimed at agents:
`.codex/skills/AGENTS.md` instructs a run after every skill change, and
`.codex/skills/write-adr/SKILL.md` does the same for ADRs. `README.md` listed the context validator in its local loop
and asserted that loop matched CI, which was not the case.

23 of 115 commits touch the guarded paths, so the inputs change regularly. The failure mode is silent: an over-budget
skill description or a Markdown link pointing at a deleted file degrades the context every future agent loads, without
failing anything or surfacing at review.

The repository has a single committer, so there is no third-party pull request to gate. Measured cold, the three
validators complete in roughly one second combined.

## Decision

**We will run the three `tool/` validators from a tracked
`.githooks/pre-commit` hook**, enabled per clone with
`git config core.hooksPath .githooks`. All three run unconditionally on every commit; CI remains responsible for
analysis and tests only.

## Alternatives

- **A local pre-commit hook** (chosen): feedback in about a second on the machine making the change, with no new
  dependency and no CI minutes.
- **CI workflow steps**: the natural reflex, and the first option proposed. It gates the wrong seam here — with one
  committer there is no external contribution to catch, and the feedback arrives only after a push. Revisit if the
  repository gains other committers.
- **`husky` or `lefthook`**: both add a dependency and an install step to solve what one `git config` line already
  solves.
- **Filtering the validators on staged paths**: rejected as *incorrect*, not merely unnecessary. `_missingReferences` in
  `tool/agent_context/context.validator.dart` validates that every local Markdown link in every `AGENTS.md` and in
  `docs/source_map.md` resolves. The
  `reference.missing` diagnostic therefore fires from a change to the link *target* rather than the linking file, so a
  filter keyed on edited paths would miss the most likely real failure. `template.missing` behaves the same way for
  deletions under `tool/templates/`. At roughly one second total there is nothing to gain in exchange for that gap.
- **Closing the worktree/index gap with `git stash --keep-index`**: rejected. It is the classic hook footgun that can
  lose uncommitted work when a validator fails, and the guarded files are prose and configuration that are rarely staged
  in part.

## Consequences

- The rationale above is recorded rather than implicit. Wiring these validators into CI was proposed and rejected on
  cost during the originating session; the record exists so that decision is re-opened deliberately rather than by
  default.
- Enforcement is opt-in per clone. `core.hooksPath` is local configuration and cannot be committed, so a fresh clone is
  unenforced until the command is run. The install line is recorded in both `README.md` and `AGENTS.md`.
- The validators read the working tree, not the index. A partially staged commit is checked against what is on disk
  rather than what is being committed. This is accepted knowingly.
- The hook requires `dart` on `PATH`. A GUI git client may supply a minimal environment and fail with `dart: not found`;
  command-line commits are unaffected.
- Enforcement is bypassable by design with `git commit --no-verify`. The hook is a guard against forgetting, not a
  security control.
- The hook fires on rebase and amend, costing roughly a second each time.
- This decision is cheap to reverse — deleting one file and unsetting one config value. It is recorded for its
  rationale, not for its reversal cost.
- Re-evaluate if the repository gains other committers, at which point CI becomes the stronger seam, or if hook runtime
  grows enough to be felt.

## Confirmation

Verify the happy path, which exercises the hook script without creating a commit:

```sh
.githooks/pre-commit
```

Verify that git invokes the hook and that a failure aborts the commit. This creates nothing, because the commit never
completes:

```sh
printf '\nSee [nope](docs/nope.md).\n' >> lib/domain/AGENTS.md
git commit --allow-empty -m "probe"   # expect reference.missing, exit 1
git log --oneline -1                  # expect HEAD unchanged
git checkout -- lib/domain/AGENTS.md
```

Verify the documented bypass still works, and that `git commit --no-verify`
succeeds while an input is broken.

For later changes, adding a validator to `tool/` means adding it to
`.githooks/pre-commit` rather than to `.github/workflows/ci.yml`, unless this record is superseded.
