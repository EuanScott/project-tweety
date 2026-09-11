# ADR-0009: Conventional-commit-driven versioning

Status: proposed
Date: 2026-09-11
Decision maker: Euan Scott

## Context

The repository had no version at all in practice. `pubspec.yaml` carried the
Flutter template default `version: 0.0.1` across the entire history, no git tag
had ever been created, and nothing in `.github/workflows/ci.yml` or `tool/`
referenced a version. The number was inert.

That is tolerable while a repository is a scratchpad and untenable once it
accumulates a history worth navigating. Reconstructing the number after the
fact is expensive: establishing that `0.16.0` was the honest current value meant
reading 116 commits spanning January to September 2026 and grouping roughly 59
feature-type commits into sixteen shipped capabilities by hand. Every month that
passes without a running version makes that reconstruction harder, and it is a
reconstruction that has to be redone from scratch every time the question is
asked.

The inputs for automating it were already present and already disciplined:

- Commit messages follow Conventional Commits. `.claude/CLAUDE.md` mandates the
  standard, and the last twelve months bear it out — 116 commits, of which all
  but three parse as `type: subject`.
- The type prefix already encodes exactly the distinction semantic versioning
  needs. `feat` versus `fix` versus `chore` is a statement about whether user-
  visible behaviour moved.
- `.githooks/` is an established enforcement seam with a tracked hook and a
  documented per-clone install step, per
  [ADR-0003](0003-pre-commit-validator-enforcement.md).

So the information required to maintain the version is already being produced
by hand on every commit, and then discarded. The only thing missing is the
machinery to read it.

A relevant constraint on that machinery: the project is not released. There is
no store listing, no published package — `publish_to: 'none'` — and no consumer
who breaks when an identifier changes. Whatever is chosen must therefore be
correct without being ceremonious, because there is no external party whose pain
would otherwise justify the ceremony.

### The hook seam is not free to choose

The obvious implementation — bump the version from a `pre-commit` or
`commit-msg` hook — does not work, and the reason is a property of git rather
than a defect in any particular script.

Git builds the commit tree from an **in-memory copy of the index**, snapshotted
before commit-time hooks run. A `git add` issued inside `pre-commit`,
`prepare-commit-msg`, or `commit-msg` updates `.git/index` on disk, but that
write is not consulted again when the commit object is written. The staged
change silently fails to reach the commit it was meant to accompany.

This was established empirically on git 2.55.0 rather than assumed. An
instrumented `commit-msg` hook reported `index now: version: BUMPED` while the
same commit's summary read `1 file changed` and the committed blob retained the
old version.

That constraint eliminates most of the candidate seams outright:

| Hook | Message available? | Staged change reaches the commit? |
|------|--------------------|-----------------------------------|
| `pre-commit` | No — the message does not exist yet | Yes |
| `prepare-commit-msg` | Only for `git commit -m` | No |
| `commit-msg` | Yes | No |
| `post-commit` | Yes | Yes, via `--amend` |

`prepare-commit-msg` deserves specific mention because it is the trap. It passed
an isolated test during this work and was nearly adopted on that evidence. A
fuller matrix caught it double-bumping — a `fix:` commit reported
`0.16.0 -> 0.16.1` while the resulting commit contained `0.16.2`, because the
hook's own bump had not landed and the fallback then bumped again on top of the
already-modified working tree. A single green test on this seam is not evidence.

## Decision

**We will derive the `pubspec.yaml` version from the Conventional Commit type on
every commit, applied by a tracked `.githooks/post-commit` hook that amends the
commit so the bump travels with the change that caused it.**

The mapping, implemented in `tool/hooks/bump_version.sh`:

- `feat`, `feature` — minor
- `fix`, `perf` — patch
- a `!` marker or a `BREAKING CHANGE:` footer — major
- every other type, including `chore`, `docs`, `refactor`, `test`, `style`, and
  `ci` — no change

While the major component is `0`, a breaking change is demoted to a minor bump
rather than advancing the major. The major moves to `1.0.0` exactly once, by
hand, when the project is deliberately declared live.

The starting point is `0.16.0`, reconstructed from the January–September 2026
history described above.

## Alternatives

- **A `post-commit` amend** (chosen): the only seam where the commit message is
  final *and* the index change is guaranteed to reach the commit. Its cost is
  that it rewrites the commit immediately after creating it.
- **`pre-commit`**: the seam this work was originally asked for. Rejected on a
  hard constraint rather than a preference — git does not pass the commit
  message to `pre-commit`, because at that point the message does not yet exist.
  No amount of care in the script recovers it.
- **`commit-msg`**: has the message, and was implemented and tested before being
  discarded. Rejected on the cached-index behaviour documented above. It cannot
  add a file to the commit it is validating.
- **`prepare-commit-msg`**: rejected on the same cached-index behaviour, and
  additionally because it fires before the message exists when a commit is
  written in an editor rather than via `-m`. Its capacity to pass a narrow test
  while being wrong makes it worse than `commit-msg`, not better.
- **`standard-version`, `semantic-release`, or `release-please`**: the
  industry-standard tools, and the correct answer for a repository that
  publishes. Rejected here because each assumes a release event to hang the
  version off — a tag, a changelog commit, a registry push — and this project has
  none. They would also add a Node toolchain to a Flutter repository whose only
  scripting dependency today is `dart`, contradicting the reasoning already
  recorded in [ADR-0003](0003-pre-commit-validator-enforcement.md) against
  `husky` and `lefthook`. Revisit when the project actually releases, at which
  point their changelog generation starts earning its cost.
- **A CI job that bumps and pushes**: rejected for the reason ADR-0003 gives for
  the validators — with a single committer there is no external contribution to
  gate, and a bot commit pushing back to `main` is a heavier mechanism than the
  problem warrants.
- **Continuing to set the version by hand**: the honest baseline. Rejected on the
  evidence of the preceding history, in which it was never once done across two
  and a half years.
- **Tagging each release instead of versioning each commit**: not an alternative
  so much as a later addition. It presumes releases exist. Nothing prevents
  adding tags on top of this once they do.

## Consequences

- The version becomes a side effect of describing work honestly, which was
  already required. No new discipline is introduced; an existing one is
  harvested.
- The README version badge reads `pubspec.yaml` from `main` over raw
  `githubusercontent`, so the published number follows a push with no separate
  step and no possibility of drifting from the file.
- **Commits are rewritten immediately after creation.** This is the principal
  cost. The commit identifier printed by `git commit` is stale — the amended
  commit has a different one. Copying an identifier from that output without
  checking `git log -1` first will reference a commit that no longer exists.
- A mistyped type degrades silently. `feet:` produces no bump and no warning,
  because the hook cannot distinguish a typo from an intentionally unmapped type
  such as `chore`. Rejecting non-conventional messages outright from
  `.githooks/pre-commit` would close this and was deliberately deferred.
- `--no-verify` does not bypass this hook, unlike the `pre-commit` validators.
  Git does not apply that flag to `post-commit`. The escape hatch is
  `NO_VERSION_BUMP=1 git commit ...`, which is a different mechanism from the one
  documented in ADR-0003 for the same repository — a genuine inconsistency,
  accepted because the alternative is a hook that cannot be skipped at all.
- A version staged by hand in the same commit is never overwritten. This is what
  makes the eventual `1.0.0` transition, and any deliberate correction,
  expressible without disabling the hook.
- The version now moves on most commits, so `pubspec.yaml` becomes a frequent
  participant in merge conflicts on any branch that lives long enough. Trunk-based
  development, which `README.md` records as the working style, keeps branches
  short enough that this stays theoretical.
- Enforcement is opt-in per clone, inheriting `core.hooksPath` from ADR-0003. A
  fresh clone silently stops versioning until `git config core.hooksPath
  .githooks` is run.
- The hook needs only POSIX `sh`, `awk`, and `sed`. Unlike the ADR-0003
  validators it does not require `dart` on `PATH`, so it survives the minimal
  environment a GUI git client may supply — though such a client may present the
  amended commit confusingly.
- The numbers carry no promise. `0.x` is the standard signal that nothing is
  stable, which is accurate for a playground and is the reason the major is held
  in reserve rather than advanced by breaking changes.
- Re-evaluate when the project releases, when a second committer appears, or if
  the amend behaviour proves disruptive to a tool in the loop.

## Confirmation

Verify the mapping without creating commits in this repository. The hook and the
bump script are self-contained, so a scratch repository exercises them exactly:

```sh
tmp=$(mktemp -d) && cd "$tmp"
git init -q . && git config core.hooksPath .githooks
mkdir -p .githooks tool/hooks
cp "$OLDPWD/.githooks/post-commit" .githooks/
cp "$OLDPWD/tool/hooks/bump_version.sh" tool/hooks/
printf 'name: probe\nversion: 0.16.0\n' > pubspec.yaml
git add -A && git commit -q -m "init" --no-verify

for m in "fix: a" "feat: b" "chore: c" "feat(x)!: d"; do
  echo "$RANDOM" >> f.txt && git add f.txt && git commit -q -m "$m"
  printf '%-20s %s\n' "$m" "$(sed -n 's/^version: //p' pubspec.yaml)"
done
# expect 0.16.1, 0.17.0, 0.17.0, 0.18.0
```

Verify that the bump reaches the commit rather than only the working tree. This
is the specific failure that eliminated three candidate hooks, so it is the
assertion most worth keeping:

```sh
git show --stat --format= HEAD   # expect pubspec.yaml listed alongside the code change
git status --porcelain           # expect empty
```

Verify the escape hatch and the hand-set override:

```sh
NO_VERSION_BUMP=1 git commit -q -m "feat: skipped"   # expect version unchanged
```

For later changes, a bump rule belongs in `tool/hooks/bump_version.sh`. Moving
this logic into `pre-commit`, `prepare-commit-msg`, or `commit-msg` means this
record was bypassed — those seams cannot add a file to the commit they run
against, and a passing test on one of them is not evidence to the contrary.
