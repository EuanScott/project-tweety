# ADR-0018: Supply-chain security is checked in CI by OSV-Scanner, OpenSSF Scorecard and Dependabot

Status: accepted
Date: 2026-10-08
Decision maker: Euan Scott

## Context

This repository is public. Before this decision, it had one workflow,
`.github/workflows/ci.yml`, for analysis and tests. Nothing scanned the
dependencies for known vulnerabilities. There was no security policy. The
README showed no security signal. Workflow actions were referenced by version
tags such as `@v4`, and the workflow token had the default permissions.

A version tag is a movable label. The owner of an action, or anyone who takes
over the owner's account, can point the tag at different code. In March 2025
this happened to `tj-actions/changed-files`. Thousands of repositories ran the
changed code on their next build, and it printed their secrets into public
logs.

CodeQL, GitHub's code scanner, does not support Dart. It would scan only the
default Android and iOS platform code.

The project has one maintainer, who uses trunk-based development and pushes
directly to `main`.

[ADR-0010](0010-pre-commit-analysis-and-ci-enforcement.md) makes CI the
enforcing check. This decision adds security checks to CI on the same terms.

This decision came from a ticket to add vulnerability scanning, OpenSSF
Scorecard and a security badge.

## Decision

**We will scan dependencies with OSV-Scanner, grade the project with OpenSSF
Scorecard, keep dependencies current with Dependabot, and pin every workflow
action to a commit hash.**

The parts of the decision are:

- **Vulnerability scan.** `.github/workflows/security.yml` runs OSV-Scanner on
  every push to `main`, on every pull request, and weekly. It reads every
  lockfile that OSV-Scanner recognises and uploads the results to the GitHub
  Security tab. It has its own workflow, so its badge and its failures mean one
  thing.
- **Trust badge.** `.github/workflows/scorecard.yml` publishes an OpenSSF
  Scorecard result weekly and on every push to `main`. The README shows the
  Scorecard badge next to the version and CI badges.
- **Weekly schedule at off-peak minutes.** Both scheduled workflows run on
  Monday morning UTC, at minutes that are not on the hour or the half hour
  (`17 6 * * 1` and `29 6 * * 1`). GitHub's scheduler is busiest at those times
  and delays runs most then. The two workflows run at different minutes.
- **Pinned actions.** Every `uses:` line names a full commit hash, followed by
  the release tag as a comment, for example
  `actions/checkout@<hash> # v4.4.0`. Only hashes that a release tag points to
  are used.
- **Read-only tokens.** Every workflow sets read-only token permissions at the
  top level. A job adds write access only where it needs it.
- **Dependabot.** `.github/dependabot.yml` proposes weekly updates for pub (the
  app, `packages/design_system` and `packages/navigation`), Gradle and GitHub
  Actions. Minor and patch updates are grouped into one pull request per
  ecosystem. A version must be 7 days old before Dependabot proposes it.
- **Security policy.** `SECURITY.md` tells reporters to use GitHub's private
  vulnerability reporting. Secret scanning and push protection are on.
- **`main` ruleset.** A ruleset blocks force-push to `main` and deletion of
  `main`. It does not require pull requests, so direct pushes still work.
- **Accepted low scores.** Scorecard's Code-Review check scores 0, and its
  Branch-Protection check scores low. The project does not add pull requests
  only to raise the score. The README explains why.

## Alternatives

- **CodeQL as the scanner.** Rejected. It does not support Dart, which is most
  of this code. OSV-Scanner reads `pubspec.lock` directly.
- **A "0 vulnerabilities" badge.** Rejected. It shows only that a scanner runs.
  Scorecard grades how the project is run: pinned dependencies, token
  permissions, a security policy and dependency updates. That is what "can I
  trust this project" asks.
- **Scan on push and pull request only.** Rejected. New vulnerabilities are
  published when the code does not change. The weekly run finds them.
- **Schedules on the hour and the half hour** (`0 6` and `30 6`). Rejected.
  These are the busiest scheduler times, so runs start later and less
  predictably.
- **Pin actions to version tags.** Rejected. A tag can be moved to different
  code with no change in this repository. A commit hash is calculated from the
  content, so it cannot be moved.
- **Pin to a hash with no version comment.** Rejected. A bare hash tells a
  reader nothing. Dependabot reads the comment to find the current version, and
  updates the hash and the comment together.
- **Dependabot with no cooldown.** Rejected. A compromised release is usually
  found and removed within days. A 7-day wait keeps it out of the project in
  that time.
- **One pull request per dependency update.** Rejected. The app alone has about
  200 locked packages. Grouping keeps the review load small for one maintainer.
  Major updates stay separate, because they can change behaviour.
- **Pull requests for every change, to raise Code-Review.** Rejected. With one
  maintainer, a pull request has no second reviewer. It adds work but no
  review.

## Consequences

- Vulnerable pub and iOS Swift package dependencies are reported in the
  Security tab within a week of publication, even with no code change.
- **Android Gradle dependencies are not scanned for vulnerabilities.**
  OSV-Scanner reads only Gradle lockfiles, and the Android build has none.
  Dependabot still proposes Gradle version updates. Gradle dependency locking
  would close the gap, but its lockfiles must be regenerated whenever an
  Android dependency changes.
- A pinned action gets no fixes until its hash changes. Dependabot opens a
  weekly pull request for each newer release. Merging that pull request is the
  point where the maintainer checks the new code.
- The version comment is not checked by any tool. If a hash changes and its
  comment does not, the comment is wrong and nothing warns. The hash is always
  what runs.
- The OSV-Scanner workflow fails when it finds a vulnerability. A pull request
  can therefore fail for a vulnerability that it did not add.
- GitHub turns off scheduled workflows after 60 days with no repository
  activity. GitHub sends an email, and the schedule must then be turned on
  again by hand.
- The Scorecard API rejects a published result if `scorecard.yml` has top-level
  write permissions or runs unapproved steps. Changes to that workflow must keep
  to the steps that Scorecard allows.
- The expected Scorecard score is about 6 to 7 out of 10.
- Secret scanning reports the Firebase client keys. Those keys are covered by
  [ADR-0013](0013-firebase-config-committed-with-restricted-keys.md). Close
  those alerts only after the key restrictions in that ADR are confirmed.
- Re-evaluate when a second maintainer joins, when Android dependencies need a
  vulnerability scan, or when CodeQL supports Dart.

## Confirmation

From the repository root, check the workflows and their pinning:

```sh
actionlint .github/workflows/*.yml
zizmor --offline .github/
```

Both must report no findings. `zizmor` reports any action that is not pinned
to a hash, any token with broad permissions, and any Dependabot entry with no
cooldown.

Check that a pinned hash matches the tag in its comment:

```sh
gh api repos/actions/checkout/commits/v4.4.0 --jq .sha
```

On GitHub, check that:

- the Security tab shows OSV-Scanner and Scorecard results after the first
  Monday run
- Settings → Rules → Rulesets shows an active ruleset on `main` that blocks
  force-push and deletion
- Settings → Code security shows secret scanning, push protection and private
  vulnerability reporting as on
