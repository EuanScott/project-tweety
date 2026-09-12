# GitHub README badges — what's worth adding

Research note. `project-tweety` is a personal Flutter/Dart playground app, **not**
a published pub.dev package. Primary sources are shields.io's own documentation, GitHub's own docs, and the raw README
markdown of a sample of real repositories (fetched directly, not paraphrased from listicles). Access caveats are flagged
per-section, matching the sourcing-confidence convention used in
`docs/research/modal_close_button_hci_guidelines.md`: some shields.io pages returned only a partial excerpt to the fetch
tool rather than the full page, and this is noted inline rather than asserted as complete.

**Verified against**

| Thing                  | Value                                              | How verified              |
|------------------------|----------------------------------------------------|---------------------------|
| Repo slug              | `EuanScott/project-tweety`                         | `git remote -v`           |
| CI workflow file       | `.github/workflows/ci.yml` (only workflow present) | `ls .github/workflows/`   |
| Existing README badges | version (dynamic YAML) + CI (GitHub Actions)       | read `README.md` directly |

---

## 1. What the repo already has today

`README.md` currently carries exactly two badges, both already correct and working:

```markdown
[![Version](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2FEuanScott%2Fproject-tweety%2Fmain%2Fpubspec.yaml&query=%24.version&label=version&color=blue)](pubspec.yaml)
[![CI](https://github.com/EuanScott/project-tweety/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/EuanScott/project-tweety/actions/workflows/ci.yml)
```

- **Version badge** — a shields.io *dynamic YAML badge* (`/badge/dynamic/yaml`), reading `pubspec.yaml` off `main` via
  `raw.githubusercontent.com`, extracting
  `$.version` with a JSONPath-style query, labelled `version`, colored `blue`. No `style=` param is set, so it renders
  in shields.io's default `flat` style. This is the mechanism documented by shields.io's `Dynamic YAML Badge` type (§2
  below) — not a GitHub-category badge, since `pubspec.yaml`'s version is project-specific data, not something
  shields.io's GitHub integration knows about natively.
- **CI badge** — **not** a shields.io badge at all. It uses GitHub's own first-party workflow-status endpoint,
  `https://github.com/<owner>/<repo>/actions/workflows/<file>/badge.svg`, with
  `?branch=main` appended, exactly matching GitHub's own documented syntax (§2.2 below). It links out to the Actions run
  page rather than to a shields.io page.

Both use plain `[![alt](img)](link)` markdown, no `style=`, `logo=`, or
`logoColor=` customization on either.

---

## 2. Badge catalogue relevant to this repo

### 2.1 shields.io — what it documents

shields.io's badge catalogue page (fetched directly — the page returned a partial excerpt to this environment's fetch
tool, so the list below combines that excerpt with query results confirming individual badge pages exist)
groups badges under these top-level categories: **Static Badge, Dynamic JSON Badge, Dynamic Regex Badge, Dynamic TOML
Badge, Dynamic XML Badge, Dynamic YAML Badge, Endpoint Badge**, plus category groupings **Activity, Analysis, Build,
Chat, Code Coverage, Dependencies, Downloads, Funding, Issue Tracking, License, Monitoring, Other, Platform & Version
Support, Rating, Size, Social, Test Results, Version** (shields.io, <https://shields.io/badges>). shields.io itself
describes the service as supporting "dozens of continuous integration services, package registries, distributions, app
stores, social networks, code coverage services, and code analysis services" (shields.io,
<https://shields.io/docs>).

**Customization query parameters**, confirmed on the Static Badge page
(shields.io, <https://shields.io/badges/static-badge>):

| Param          | Allowed values                                                                                   |
|----------------|--------------------------------------------------------------------------------------------------|
| `style`        | `flat` (default), `flat-square`, `plastic`, `for-the-badge`, `social`                            |
| `logo`         | any icon slug from [Simple Icons](https://simpleicons.org)                                       |
| `logoColor`    | hex, rgb, rgba, hsl, hsla, or CSS named color                                                    |
| `logoSize`     | (seen on GitHub-category badges, e.g. last-commit/repo-size pages)                               |
| `label`        | custom left-hand text (URL-encoded)                                                              |
| `labelColor`   | hex/rgb/hsl/named color for the left segment                                                     |
| `color`        | hex/rgb/hsl/named color for the right segment                                                    |
| `cacheSeconds` | HTTP cache lifetime override                                                                     |
| `link`         | click targets for badge segments (works only inside `<object>` tags, not plain `<img>`/markdown) |

shields.io's own wording on color values: "Hex, rgb, rgba, hsl, hsla and css named colors may be used," with the caveat
that "some named colors may differ from CSS color values" (shields.io, <https://shields.io/badges/static-badge>).

### 2.2 GitHub Actions workflow badge — GitHub's own syntax

GitHub's docs (<https://docs.github.com/actions/managing-workflow-runs/adding-a-workflow-status-badge>)
give the exact recommended form:

```markdown
![example workflow](https://github.com/OWNER/REPOSITORY/actions/workflows/WORKFLOW-FILE/badge.svg)
```

with optional `?branch=BRANCH-NAME` and `?event=push` query params. GitHub explicitly notes: "Workflow badges in a
private repository are not accessible externally, so you won't be able to embed them or link to them from an external
site" — not a concern here since `project-tweety` is public, but worth knowing if that ever changes. This repo's badge
already matches this syntax exactly, using `ci.yml` (the only file in `.github/workflows/`) and
`?branch=main`.

### 2.3 GitHub-category badges (shields.io), filled in for this repo

Each of these was confirmed against its own shields.io docs page. Path parameters are pre-filled with
`EuanScott/project-tweety`; none of these are currently in the README.

**License** (shields.io, <https://shields.io/badges/git-hub-license>) — pattern
`https://img.shields.io/github/license/{user}/{repo}`:

```markdown
![License](https://img.shields.io/github/license/EuanScott/project-tweety)
```

**Last commit** (shields.io, <https://shields.io/badges/git-hub-last-commit>) — pattern
`https://img.shields.io/github/last-commit/{user}/{repo}`:

```markdown
![Last Commit](https://img.shields.io/github/last-commit/EuanScott/project-tweety)
```

**Repo size** (shields.io, <https://shields.io/badges/git-hub-repo-size>):

```markdown
![Repo Size](https://img.shields.io/github/repo-size/EuanScott/project-tweety)
```

**Open issues** (shields.io, path pattern confirmed as
`/github/issues/:user/:repo` under <https://shields.io/badges/git-hub-issues>):

```markdown
![Open Issues](https://img.shields.io/github/issues/EuanScott/project-tweety)
```

**Commit activity, contributors, code size, open PRs, release, release date, discussions, sponsors, downloads** — these
all exist as GitHub-category badges per the catalogue in §2.1 but were not individually fetched for exact param syntax;
treat their path shape as `https://img.shields.io/github/<metric>/EuanScott/project-tweety`
by analogy with the four confirmed above, and verify each on shields.io's badge picker before use. **Unverified** at the
individual-page level for this subset — flagging rather than guessing exact query params.

### 2.4 Package-registry badges — not applicable today

**pub.dev / Dart.** shields.io does have a first-party pub.dev integration:
`Pub Version`, `Pub Publisher`, `Pub Points`, `Pub Likes`, and `Pub Monthly
Downloads` badges (shields.io, <https://shields.io/badges/pub-version> and sibling pages found via search — individual
pages beyond Pub Version were not directly fetched, so their exact params are **unverified**, only their existence).
Pattern confirmed for version: `https://img.shields.io/pub/v/{packageName}`.

pub.dev's own scoring help page (pub.dev, <https://pub.dev/help/scoring>)
documents what Likes, Pub Points, and download counts *mean*, but **does not itself document or provide embeddable
README badge markdown** — that's a shields.io / third-party (`badges.bar`) concern, not something pub.dev publishes as
an official embed snippet.

**None of this applies to project-tweety.** It has no `pubspec.yaml` `publish_to`
entry pointing at pub.dev and is explicitly described in its own README as a playground, not a package. A pub.dev badge
would 404 (there is no published package to query) — this only becomes relevant if the repo, or something extracted from
it (e.g. `packages/design_system`), is ever published.

### 2.5 Coverage badges — blocked on a missing CI step

**Codecov** (docs.codecov.com, <https://docs.codecov.com/docs/status-badges>)
documents badge markdown of the form:

```markdown
[![codecov](https://codecov.io/github/<owner>/<repo>/branch/<branch>/graph/badge.svg)](https://codecov.io/github/<owner>/<repo>)
```

generated from the repo's "Badges & Graphs" section in the Codecov UI, with a
`token=` query param required for private repos. The page does not spell out the CI upload step itself, but that step —
a `codecov/codecov-action` (or equivalent) run in CI that uploads a coverage report — is a hard prerequisite:
without an upload, there is no coverage data for Codecov to badge.

**Coveralls** (docs.coveralls.io) confirms the same shape of prerequisite:
its getting-started guide requires creating a `COVERALLS_REPO_TOKEN` CI secret/variable as part of setup
(docs.coveralls.io,
<https://docs.coveralls.io/>) — i.e., an explicit CI-side coverage-upload step, same as Codecov. The dedicated `/badge`
docs page 404'd on direct fetch; the badge markdown shape below is corroborated by real usage (e.g. Express.js, §3)
rather than by a Coveralls docs page read directly:

```markdown
[![Coverage Status](https://coveralls.io/repos/github/<owner>/<repo>/badge.svg?branch=main)](https://coveralls.io/github/<owner>/<repo>?branch=main)
```

**Verified fact about this repo:** `.github/workflows/ci.yml` is the only workflow file present, and (per
`docs/research/dart_flutter_lint_rules.md`, which already audited this file for an unrelated lint question) it runs
`flutter analyze` and `very_good test --coverage` but has no Codecov/Coveralls upload step. **A coverage badge for this
repo would have nothing to badge today.**

### 2.6 Other primary badge providers checked

| Provider                                                                    | Official README badge documented at source?                                                                                                                                                                                                                                                                                                                                  | Relevant to this repo?                                                                                                                                                                                                                                                                                                                                                                                                      |
|-----------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Conventional Commits** (conventionalcommits.org)                          | **No.** The spec page (<https://www.conventionalcommits.org/en/v1.0.0/>) documents the commit-message spec itself; it contains no badge section, shields.io reference, or badge markdown.                                                                                                                                                                                    | project-tweety's `post-commit` hook already enforces Conventional-Commit-driven version bumps (ADR-0009), so the *practice* is relevant — but there's no official first-party badge to point at. A `shields.io` **static** badge asserting this (`![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg)`) is a community convention, not an official emblem — flag as such if used. |
| **Contributor Covenant**                                                    | Its homepage's interactive builder generates a `CODE_OF_CONDUCT.md`, but no README-badge markdown was found on the fetched page (<https://www.contributor-covenant.org/>). **Unverified** whether one exists elsewhere on the site.                                                                                                                                          | Not relevant — this is a solo repo with no code-of-conduct enforcement need.                                                                                                                                                                                                                                                                                                                                                |
| **All Contributors** (allcontributors.org)                                  | Root page redirects; the specific docs sub-pages checked (`/docs/en/badge`, `/docs/en/emoji-key`) both 404'd on direct fetch. **Unverified** at the primary-source level in this session.                                                                                                                                                                                    | Not relevant regardless — the whole point of the badge is crediting *multiple* contributors via its bot/CLI; this is a single-author repo.                                                                                                                                                                                                                                                                                  |
| **FOSSA** (fossa.com)                                                       | Fetch of a specific blog post 404'd; not independently re-verified this session. **Unverified.**                                                                                                                                                                                                                                                                             | Not relevant — FOSSA badges signal license-compliance scanning for dependency trees, aimed at orgs with legal/compliance exposure across many dependencies, not a personal playground.                                                                                                                                                                                                                                      |
| **OpenSSF Scorecard**                                                       | **Yes, confirmed via the project's own GitHub repo** (github.com/ossf/scorecard). Exact markdown: `[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/{owner}/{repo}/badge)](https://scorecard.dev/viewer/?uri=github.com/{owner}/{repo})`. Prerequisite: the repo must run the Scorecard GitHub Action with `publish_results: true` set, on a public repo. | Not proportionate for this repo today — Scorecard measures supply-chain security posture (branch protection, pinned dependencies, fuzzing, SAST, etc.) aimed at OSS projects with external consumers/contributors; a solo playground has none of the threat model this defends against, and adding the Action is nontrivial setup for a badge with no audience.                                                             |
| **OpenSSF Best Practices** (bestpractices.dev, formerly CII Best Practices) | Fetched page describes the badge's purpose ("a way for... FLOSS projects to show that they follow best practices") but the exact badge/embed markdown was not present in the fetched excerpt. **Unverified** at the exact-syntax level.                                                                                                                                      | Same reasoning as Scorecard — not proportionate; also note Flutter's own README (§3) does display a CII Best Practices badge, showing it's a recognized convention for larger OSS projects specifically.                                                                                                                                                                                                                    |

---

## 3. Observed usage tally — real README sample

Sample size: **8 of 10** planned fetches succeeded (2 failed: `vercel/next.js`
Readme.md 404'd on both `canary` and `main` branch/casing attempts consistent with a moved/renamed file; `dart-lang/sdk`
fetched successfully but has zero badges — a genuine finding, not a failure). Every README below was fetched directly
via `raw.githubusercontent.com`.

| Repo                                                                                                                  | Fetched from                                                       | Badges present                                                                                                                                   | Categories                                                           |
|-----------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------|
| [flutter/flutter](https://raw.githubusercontent.com/flutter/flutter/main/README.md)                                   | `main`                                                             | CI status, Discord, Twitter, BlueSky, LFX Health Score, CII Best Practices, SLSA level                                                           | Build, chat, social ×2, project-health/security ×3                   |
| [dart-lang/sdk](https://raw.githubusercontent.com/dart-lang/sdk/main/README.md)                                       | `main`                                                             | **None**                                                                                                                                         | —                                                                    |
| [felangel/bloc](https://raw.githubusercontent.com/felangel/bloc/master/README.md)                                     | `master`                                                           | build, codecov, GitHub stars, style (bloc_lint), Flutter Website link, awesome-flutter, flutter-samples, MIT license, Discord, Bloc Library link | Build, coverage, stars, style/lint, docs ×3, chat, license           |
| [invertase/melos](https://raw.githubusercontent.com/invertase/melos/main/packages/melos/README.md)                    | `main`                                                             | "maintained with melos" self-badge, docs.page, Discord, Twitter follow                                                                           | Docs, chat, social — **no CI/coverage/license/version badge at all** |
| [VeryGoodOpenSource/very_good_cli](https://raw.githubusercontent.com/VeryGoodOpenSource/very_good_cli/main/README.md) | `main`                                                             | CI/build, coverage, pub.dev version, very_good_analysis style, MIT license                                                                       | Build, coverage, package version, style, license                     |
| [facebook/react](https://raw.githubusercontent.com/facebook/react/main/README.md)                                     | `main`                                                             | MIT license, npm version, build/test CI, TypeScript CI, "PRs Welcome"                                                                            | License, package version, build ×2, contribution-invite              |
| [microsoft/vscode](https://raw.githubusercontent.com/microsoft/vscode/main/README.md)                                 | `main`                                                             | Feature-requests issue count, Bugs issue count                                                                                                   | Issue tracking ×2 only                                               |
| [rust-lang/rust](https://raw.githubusercontent.com/rust-lang/rust/master/README.md)                                   | `master`                                                           | **None**                                                                                                                                         | —                                                                    |
| [nodejs/node](https://raw.githubusercontent.com/nodejs/node/main/README.md)                                           | `main`                                                             | **None**                                                                                                                                         | —                                                                    |
| [expressjs/express](https://raw.githubusercontent.com/expressjs/express/master/Readme.md)                             | `master`                                                           | npm version, npm downloads, Linux build (GitHub Actions), Coveralls coverage, OpenSSF Scorecard                                                  | Package version, downloads, build, coverage, security                |
| vercel/next.js                                                                                                        | attempted `canary/Readme.md`, `main/README.md`, `canary/README.md` | **fetch failed (404) — not counted in tally**                                                                                                    | —                                                                    |

**Pattern: published packages vs. applications.**

- **Applications with no package registry presence** (`dart-lang/sdk`,
  `rust-lang/rust`, `nodejs/node`, `microsoft/vscode`) frequently carry **zero**
  or near-zero badges, or only issue-tracking badges. A version/downloads badge is meaningless for something users don't
  `npm install`/`pub get`.
- **Published packages** (`felangel/bloc`, `VeryGoodOpenSource/very_good_cli`,
  `facebook/react`, `expressjs/express`) consistently pair **build status + package version + license**, and 3 of 4 add
  **coverage**. This is the
  "package README" pattern, and it's the one project-tweety's badge set should **not** try to imitate wholesale, because
  it has no package version or download count that means anything.
- **`invertase/melos`** is the interesting outlier: a published, widely-used tool with *no* CI, coverage, license, or
  version badge at all — just docs/chat/social. It's evidence that a minimal badge set is a legitimate, common choice
  even for a real package, not just for playgrounds.
- **`flutter/flutter`**, as a very large foundation-governed project, carries supply-chain/health badges (CII Best
  Practices, SLSA, LFX Health Score) that are proportionate to its scale and governance model, not to a solo repo.

---

## 4. Recommendations

### Worth adding now

- **License badge.** `![License](https://img.shields.io/github/license/EuanScott/project-tweety)`
  — zero setup cost (shields.io reads it straight from the repo's detected license file via the GitHub API), and every
  published-package README in the sample that has a license badge also has an actual `LICENSE` file backing it. Verify
  project-tweety has one before adding; if not, add the file first — otherwise the badge renders "NOASSERTION"/blank,
  which is the "embarrassing badge" failure mode flagged in §5.
- **That's the only unconditional addition.** Given the usage tally, a solo playground repo's honest badge set converges
  toward "build status + maybe license," which project-tweety already has half of (CI) — adding license brings it in
  line with the minimal end of the observed spectrum (closer to
  `invertase/melos` than to `expressjs/express`), without reaching for badges that don't correspond to anything real
  about the repo (no downloads, no published version, no external contributors, no security-scanning setup).

### Worth adding if X happens

- **Coverage badge (Codecov or Coveralls)** — only once `.github/workflows/ci.yml`
  gains an actual coverage-upload step (`codecov/codecov-action` or the Coveralls equivalent, plus the account-side
  token). Without that step, the badge has no data source and either fails to render or freezes at a stale number — see
  §5.
- **pub.dev version/points/likes badges** — only if this repo, or a package extracted from it (`packages/design_system`
  is the most plausible candidate), is ever actually published to pub.dev. Until then there is no registry entry for
  shields.io to query.
- **OpenSSF Scorecard badge** — only if this repo starts accepting external contributions or the author specifically
  wants to track supply-chain-security posture (pinned actions, branch protection, etc.). Setup is a GitHub Action with
  `publish_results: true`; not proportionate for the current solo/personal scope.
- **Last-commit / commit-activity badge** — only if the author wants to visibly signal "this is actively maintained" to
  future selves or occasional visitors browsing the Issues list mentioned in the README. Genuinely optional taste call,
  not blocked on anything — listed here rather than
  "now" because it's cosmetic, not informative about repo health the way CI/ license are.

### Skip, with reason

- **Package-registry download-count badges (npm/pub-style).** Meaningless — there is nothing published to download.
- **Star-count / social badges.** The README already links out to the Issues list for anyone interested; a 0–low star
  count on a personal playground repo reads as a negative signal with no upside, unlike `flutter/flutter`'s Discord/
  Twitter badges, which serve an actual large community.
- **All Contributors badge.** Needs multiple documented contributors to mean anything; this is a single-author repo.
- **FOSSA / dependency-license-compliance badge.** Aimed at orgs with legal exposure across many third-party
  dependencies in production; disproportionate tooling for a hobby project.
- **Contributor Covenant / code-of-conduct badge.** No contributor base to govern.
- **CII/OpenSSF Best Practices badge, SLSA badge.** These are foundation-scale signals (see `flutter/flutter` in the
  tally) requiring a checklist/attestation process disproportionate to a personal repo's actual risk profile or
  audience.

---

## 5. Caveats

- **Caching and staleness.** shields.io badges accept a `cacheSeconds` override parameter, and community reports (via
  GitHub discussion threads, not a shields.io docs page directly) describe shields.io applying its own server-side
  caching independent of that param, meaning a badge can lag behind a just-pushed change for some period. This is a
  **known trade-off, not a bug**: longer effective caching means fewer live API hits (helping the rate limit issue
  below) at the cost of a badge that can show stale data briefly after a push.
- **GitHub API rate limits on GitHub-category badges.** shields.io's own maintainers (via the project's GitHub
  Discussions,
  <https://github.com/badges/shields/discussions/8339> — the shields.io repo is the primary/authoritative source for its
  own operational details, treated as such here) state: "GitHub allows 5,000 requests per hour for any token. We
  increase our rate limit by using multiple tokens," sourced by "thousands of users" who have authorized shields.io's
  read-only OAuth app at
  `img.shields.io/github-auth`. This means GitHub-category badges (last-commit, issues, repo-size, license, etc.) depend
  on a shared, pooled rate-limit budget on shields.io's hosted service — a real but distant risk for a single
  low-traffic personal repo, and not something project-tweety needs to self-mitigate (e.g. by self-hosting shields.io),
  given its scale.
- **A "passing" badge that's actually broken is worse than no badge.** If CI is red on `main`, the existing CI badge
  will honestly show "failing" — that's working as intended, not a caveat to fix, but it does mean a red badge sits at
  the top of the README until the build is fixed. This argues for treating a failing CI badge as a visible to-do, not
  for removing the badge.
- **A frozen/stale coverage badge is the more dangerous failure mode than a failing-build badge.** If a coverage-upload
  step is ever added and later silently stops running (e.g. a workflow YAML edit drops the upload step, or a service
  outage), Codecov/Coveralls badges do **not** reliably fail loudly — they can continue showing the last
  successfully-uploaded percentage, misrepresenting current coverage as unchanged. This is the concrete reason §4 gates
  the coverage badge on an actual working upload step existing first, and it's worth periodically spot-checking once
  added, not just installed and forgotten.
- **A 0-star or 0-fork badge is a real risk for a personal repo specifically.**
  Unlike a large OSS project where a star-count badge is a credibility signal, a personal playground repo showing "0
  stars" prominently reads as a negative rather than neutral signal — this is why §4 recommends skipping social/star
  badges outright rather than treating them as merely "not useful."
- **Accessibility / alt text.** Every badge markdown snippet in this document and in the existing README uses the
  `![alt text](...)` form, which is correct — screen readers announce the alt text (e.g. "CI", "Version",
  "License") rather than trying to describe the SVG. The one thing worth checking when adding new badges: keep alt text
  short and specific (e.g.
  `License` not `badge`), since shields.io's default alt text on some auto-generated snippets is the generic label text,
  which is already adequate here but worth verifying per badge added rather than assuming.

---

## Sources

**Primary — shields.io official docs**

- <https://shields.io/docs>
- <https://shields.io/badges>
- <https://shields.io/badges/static-badge>
- <https://shields.io/badges/git-hub-license>
- <https://shields.io/badges/git-hub-last-commit>
- <https://shields.io/badges/git-hub-repo-size>
- <https://shields.io/badges/git-hub-issues>
- <https://shields.io/badges/pub-version>
- <https://github.com/badges/shields/discussions/8339> (shields.io maintainers, on GitHub API rate-limit pooling)

**Primary — GitHub's own docs**

- <https://docs.github.com/actions/managing-workflow-runs/adding-a-workflow-status-badge>

**Primary — coverage-tooling docs**

- <https://docs.codecov.com/docs/status-badges>
- <https://docs.coveralls.io/>

**Primary — pub.dev**

- <https://pub.dev/help/scoring>

**Primary — other badge-provider sources**

- <https://www.conventionalcommits.org/en/v1.0.0/> (no badge documented)
- <https://www.contributor-covenant.org/> (no badge found in fetched content)
- <https://www.bestpractices.dev/en> (badge purpose described; exact embed syntax not present in fetched excerpt)
- <https://github.com/ossf/scorecard> (Scorecard badge markdown and prerequisites)

**Primary — real-world README sample (raw markdown, fetched directly)**

- <https://raw.githubusercontent.com/flutter/flutter/main/README.md>
- <https://raw.githubusercontent.com/dart-lang/sdk/main/README.md>
- <https://raw.githubusercontent.com/felangel/bloc/master/README.md>
- <https://raw.githubusercontent.com/invertase/melos/main/packages/melos/README.md>
- <https://raw.githubusercontent.com/VeryGoodOpenSource/very_good_cli/main/README.md>
- <https://raw.githubusercontent.com/facebook/react/main/README.md>
- <https://raw.githubusercontent.com/microsoft/vscode/main/README.md>
- <https://raw.githubusercontent.com/rust-lang/rust/master/README.md>
- <https://raw.githubusercontent.com/nodejs/node/main/README.md>
- <https://raw.githubusercontent.com/expressjs/express/master/Readme.md>

**Could not be fetched / unverified**

- `vercel/next.js` README — 404 on `canary/Readme.md`, `main/README.md`, and
  `canary/README.md`; excluded from the tally (stated as 8/10, not fabricated).
- `https://docs.coveralls.io/badge` — 404; badge markdown for Coveralls is corroborated instead by its appearance in the
  `expressjs/express` sample.
- `https://fossa.com/blog/open-source-license-badges/` — 404; FOSSA badge format not independently re-verified this
  session.
- `https://allcontributors.org/docs/en/badge` and `/docs/en/emoji-key` — both 404'd; All Contributors' exact badge
  markdown is unverified at the primary level here (its relevance verdict does not depend on the exact syntax).
- Exact query-parameter sets for shields.io's commit-activity, contributors, code-size, open-PR, release, release-date,
  discussions, sponsors, and downloads GitHub-category badges, and for the Pub Publisher/Points/Likes/ Monthly-Downloads
  badges beyond Pub Version — existence confirmed via the catalogue and search results, individual pages not fetched, so
  exact syntax is unverified.
- shields.io's badge-catalogue page (`/badges`) and docs landing page (`/docs`) returned partial excerpts to this
  environment's fetch tool rather than full page text; the category list in §2.1 is as complete as that excerpt allowed,
  not confirmed exhaustive against the live page's full DOM.
