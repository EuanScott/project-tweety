# ADR Backlog and Drafting Prompts

This backlog lists durable technical decisions that are already implemented in
`project-tweety` but have no Architecture Decision Record. It was derived from a
read-only sweep of the codebase on 2026-08-04; only `ADR-0001` existed at that
time, and it merely establishes the practice of recording ADRs.

Entries are drafted with the `write-adr` skill, one at a time, using the prompt
in [The prompt](#the-prompt).

Each entry names the decision as implemented, the file evidence, why it clears
the ADR bar defined in [the catalog](../decisions/README.md), and the open
questions that must be answered before drafting. The open questions are the
load-bearing part: the skill forbids inventing rationale, alternatives, or
approval, so an entry whose questions are unanswered cannot be drafted honestly.

The evidence was accurate on 2026-08-04. Re-verify it against the current code
before drafting.

## Why one at a time

1. **ID collision.** The skill allocates an ID by scanning for the highest
   existing one. Two drafts in flight both pick the same number.
2. **Index clobbering.** Every draft rewrites the catalog table between the
   `<!-- adr-index:start -->` and `<!-- adr-index:end -->` markers in
   `docs/decisions/README.md`. Concurrent writes race.
3. **Immutability.** Accepted and rejected bodies are frozen, and only a human
   moves a record out of `proposed`. Review each record before the next one
   builds on it.
4. **Cross-references.** Tier 2 and Tier 3 decisions sit downstream of Tier 1
   ones and should be able to cite them.
5. **Interview quality.** Each record needs real rationale and real rejected
   alternatives. Batching the interview degrades the answers.

## The prompt

Copy this, substitute the entry number and title, and run it:

```text
/write-adr

Draft the ADR for backlog entry #N from `docs/plans/adr_backlog.md`:
"<paste the entry title>".

Decision maker: Euan Scott.

Read that backlog entry first. It names the decision, the file evidence, and the
open questions. Re-verify the cited evidence against the current code before
drafting; the backlog was written on 2026-08-04 and the code may have moved.

Ask me the entry's open questions before you write anything. Do not invent
rationale, alternatives, approval, consultation, or verification results. If I
cannot answer something, record it as an explicit open question in the ADR
rather than guessing.

Allocate the next free ADR ID, set `Status: proposed`, use today's date, then run
`dart run tool/decisions/adr.dart generate-index` and
`dart run tool/decisions/adr.dart check`.

Finally, update entry #N's row in the backlog progress table with the allocated
ADR number.
```

The final instruction updates this document and sits outside the skill's own
steps.

## Recommended order

Work entries 1, 2, and 3 first. The layering rule, the storage boundary, and the
migration strategy are the decisions everything else sits downstream of.

Entries 10 and 12 are blocked. Resolve the underlying inconsistency before
drafting them, or the record will enshrine an accident as a decision. Each entry
says which.

## Progress

| # | Title | Tier | Status |
|---|-------|------|--------|
| 1 | Default to presentation and data, add domain only for mobile-owned policy | 1 | not started |
| 2 | Adopt sqflite behind a deliberately non-portable database boundary | 1 | not started |
| 3 | Migrate the database forward step by version and never destroy user data | 1 | not started |
| 4 | Adopt go_router with a stateful indexed-stack shell | 1 | not started |
| 5 | Own Material and Cupertino branching inside design-system primitives | 1 | not started |
| 6 | Standardise presentation state on bloc with freezed status-enum states | 1 | not started |
| 7 | Extract reusable mechanics into local path packages | 2 | not started |
| 8 | Model local writes as offline-first mutations with sync status and tombstones | 2 | not started |
| 9 | Compose dependencies with get_it and injectable | 2 | not started |
| 10 | Propagate failures as exceptions and convert them at the bloc boundary | 2 | blocked |
| 11 | Govern agent skills as validated repository artifacts | 2 | not started |
| 12 | Make repository documentation machine-checkable | 2 | blocked |
| 13 | Scaffold features from canonical templates via a deterministic CLI | 2 | not started |
| 14 | Localize from day one and treat right-to-left as a hard requirement | 2 | not started |
| 15 | Route telemetry through fan-out facades over swappable services | 3 | not started |
| 16 | Enforce route access at the router, never in pages | 3 | not started |
| 17 | Theme through a brand token struct with shared theme structure | 3 | not started |
| 18 | Standardise filenames on feature_or_entity.role.dart | 3 | not started |
| 19 | Hand-write data models and reserve freezed for presentation state | 3 | not started |
| 20 | Store settings as a single JSON blob and keep secrets out of app storage | 3 | not started |
| 21 | Define a tab-reselect and branch-reset protocol with an async veto | 3 | not started |
| 22 | Take a runtime font dependency instead of bundling fonts | 3 | not started |

---

# Tier 1

Structural, cross-cutting, and expensive to reverse. Everything else depends on
these.

### 1. Default to presentation and data, add domain only for mobile-owned policy

**Decision as implemented:** Features are organised layer-first, and the default
feature path is presentation plus data only, on the premise that a BFF owns
mobile-specific shaping and most business logic. `lib/domain` is opt-in per
feature, and a repository pass-through explicitly does not justify one.

**Evidence:** `AGENTS.md` and `lib/AGENTS.md` state the rule; `lib/domain/AGENTS.md`
and `lib/domain/_template/README.md` add "it is not a default feature layer" and
"do not create a use case that only forwards one repository call unchanged".
Both branches are live: Cards has no domain
(`lib/data/repositories/card/cards.repository_impl.dart` feeding
`lib/presentation/pages/cards/bloc/cards.bloc.dart:25`), AppPreferences does
(`lib/domain/usecases/app_preferences/get_app_preferences.usecase.dart`). Import
direction is enforced by convention only, not by lint or a dependency check.

**Why it clears the bar:** The single most cross-cutting structural choice in the
repo. It dictates every feature's layout and the scaffolding tool, and reversing
it touches every feature.

**Open questions:**

- What is the rationale for trusting a BFF here? The only endpoint in the code is
  `jsonplaceholder.typicode.com` (`lib/data/constants/api_endpoints.dart`,
  `lib/core/networking/services.dart`). Is this decision modelling a work
  environment rather than this app?
- `get_app_preferences.usecase.dart:11-13` is a pure pass-through, which
  contradicts the stated rule. Grandfathered exception, or violation?
- What is the concrete test for "mobile-owned policy justifies a domain layer"?
- What would trigger re-evaluation?

### 2. Adopt sqflite behind a deliberately non-portable database boundary

**Decision as implemented:** Relational data lives in native SQLite via `sqflite`,
accessed only through an app-owned `AppDatabase` facade exposing `read`, `write`,
and `close`. The facade is explicitly not a provider-neutral abstraction: its
executor interfaces leak `sqflite.ConflictAlgorithm`. It owns connection
lifecycle, transactional writes, shared pending opens, open-failure retry, and
drain-on-close.

**Evidence:** `lib/core/storage/app_database.storage.dart:9-56` for the contract,
with the sqflite type leak at `:44` and `:52`; `:112-167` for drain-and-close;
`:187-207` for open options. `lib/core/storage/README.md:6-25` states the
non-substitutability outright: "intentionally Sqflite-shaped… does not promise
that another database engine can be substituted without changes". Android and iOS
only; web and desktop factories are deferred
(`docs/architecture/cards_sqlite_foundation.md:72-74`).

**Why it clears the bar:** Cross-cutting for every persisted feature, expensive to
reverse, constrains supported platforms, and adds a hard third-party dependency.
The non-portable boundary is counter-intuitive enough that a future maintainer
will otherwise try to "fix" the leak.

**Open questions:**

- Were drift, isar, or hive actually considered, and rejected on what grounds?
- Is the absence of reactive or streaming queries an accepted consequence?
- Is the sqflite type leak in `AppDatabaseWriteExecutor` intentional or accepted
  debt?
- When web or desktop targets arrive, does the answer become "swap factories" or
  "swap engines"?

### 3. Migrate the database forward step by version and never destroy user data

**Decision as implemented:** A single migration loop replays one numbered step per
version from `oldVersion + 1` to `newVersion`, used for both `onCreate` (from
version 0) and `onUpgrade`, so a fresh install and an upgraded install traverse
identical code. A missing step throws rather than silently succeeding. Downgrades
use `onDatabaseVersionChangeError`; the app never deletes and recreates a user's
database.

**Evidence:** `lib/core/storage/app_database_migrations.storage.dart:7-24` for the
loop and the `StateError` default, `:26-69` for the three versioned steps
including conditional seeding at `:47-53`.
`lib/core/storage/app_database.storage.dart:191-200` wires `onCreate` through
`migrate(db, 0, version)` and sets `onDowngrade`.
`test/core/storage/app_database_migration_integration_test.dart:167-217` builds
real v1 and v2 database files and reopens them through production code.

**Why it clears the bar:** The most costly-to-reverse persistence decision, since
the failure mode is user data loss. The testing technique — materialise a real
historical-version database, reopen through production code — is a construction
convention that will rot silently if unwritten.

**Open questions:**

- Is "never destroy a database on downgrade" absolute, including for pre-release
  builds?
- Is seeding a legitimate migration responsibility? V3 seeds sample cards using
  `DateTime.now()` at `:54`, which makes the migration non-deterministic.
- Does every future migration require a fixture test at its predecessor version,
  or only additive-schema ones?
- What is the policy when a released step must be corrected?

### 4. Adopt go_router with a stateful indexed-stack shell

**Decision as implemented:** All navigation is declarative URL-based routing via
`go_router`, with a single root router whose structure is a `/` redirect plus one
`StatefulShellRoute.indexedStack` holding one branch per top-level tab, each with
its own navigator and preserved stack. Route strings live only in a central
`AppRoutes`, features navigate through `BuildContext` extensions, and restoration
scope ids are assigned at app, router, shell, and branch level.

**Evidence:** `packages/navigation/lib/src/navigation_router.dart:31-63`;
`lib/presentation/navigation/router.dart:39-131` including branch restoration ids
at `:47`, `:64`, `:103` and router and shell scope ids at `:125` and `:127`;
`lib/presentation/navigation/routes.dart`;
`lib/presentation/navigation/navigation_extensions.dart:10-45`;
`lib/main.dart:48-52` creating the router once so it survives theme and locale
rebuilds.

**Why it clears the bar:** Cross-cutting across every feature and expensive to
reverse: the route graph, deep links, per-tab state preservation, restoration
ids, and the web URL contract all follow from it.

**Open questions:**

- Why `go_router` over hand-rolled Navigator 2.0, `auto_route`, or `beamer`?
- Why `indexedStack`, which keeps all branches alive? Was memory considered?
- Is web or deep-link URL stability a hard requirement, making paths a public
  contract?
- Are the restoration ids a real commitment to Android state restoration, or
  incidental?
- Are `AppRoutes` and the context extensions meant to be enforced, or convention?

### 5. Own Material and Cupertino branching inside design-system primitives

**Decision as implemented:** Every platform-divergent control is an `App*`
primitive in the design system that resolves the design language internally and
renders the Material or Cupertino variant. Feature code chooses semantic intent
and never branches on platform. New raw controls must be promoted into the
package rather than repeated in pages.

**Evidence:** `packages/design_system/lib/src/adaptive/app_design_platform.dart:1-33`
collapses six target platforms into two design languages, with the doc comment
"callers should branch on design language, not on individual operating systems".
The primitives themselves are `app_button.dart`, `app_text_field.dart`,
`app_picker_field.dart`, `app_confirmation_dialog.dart`, `app_list_tile.dart`,
`app_loading_indicator.dart`, `app_refresh_indicator.dart`. The policy is stated
in `AGENTS.md` and `packages/design_system/AGENTS.md`. Enforcement is real:
`lib/presentation` contains essentially no raw Material buttons, fields, or
dialogs. `packages/design_system/test/adaptive_widgets_test.dart` pumps each
primitive under both platforms.

**Why it clears the bar:** Cross-cutting across every page; the intent vocabulary
is the package's public API; and it is a durable convention with an explicit
enforcement rule.

**Open questions:**

- `lib/presentation/widgets/page_scaffold.dart:98-150` branches on design platform
  and instantiates `CupertinoPageScaffold`, `CupertinoSliverNavigationBar`, and
  `CupertinoButton` directly in app code. Is "app shell and navigation chrome stay
  in `lib/`, only primitives are promoted" a deliberate carve-out, or drift? The
  record needs this boundary stated.
- Does the intent vocabulary stay closed, or may callers pass through styling
  escape hatches?
- The rule says promote before using raw controls "repeatedly". What is the actual
  threshold, and who enforces it?
- Related: there is one `MaterialApp` root and no `CupertinoApp`; Cupertino
  styling is derived from the Material `ColorScheme` via `ThemeData.platform`
  (`lib/main.dart:76`, `:114-121`). Decide whether that composition choice belongs
  in this record or its own.

### 6. Standardise presentation state on bloc with freezed status-enum states

**Decision as implemented:** Page state is a bloc with a sealed `Equatable` event
hierarchy and a freezed state carrying a status enum plus derived getters,
registered with `@injectable` and constructed at the widget layer via
`BlocProvider(create: (_) => GetIt.I<XBloc>())`. Cubit is a narrow exception for
simple app-wide state. Several `bloc_lint` rules are promoted to errors.

**Evidence:** the templates at
`tool/templates/feature/presentation/pages/bloc/_template.bloc.dart:11-38`,
`_template.event.dart:3-11`, `_template.state.dart:5-23`, and
`_template.page.dart:14-18`. Conformance at
`lib/presentation/pages/cards/bloc/cards.bloc.dart:11-25` and
`lib/presentation/pages/home/bloc/home_bloc.dart:15-20`. The cubit exception at
`lib/presentation/pages/app_preferences/cubit/app_preferences.cubit.dart:11-16`,
provided app-wide at `lib/main.dart:62-72`. Enforcement in
`analysis_options.yaml` under the `bloc:` block. Bloc scope is also a routing
decision: `CardsBloc` is provided by a shell route wrapping the whole cards
branch (`lib/presentation/navigation/router.dart:67-73`) so it outlives
individual pages.

**Why it clears the bar:** Cross-cutting construction technique and dependency
choice, enforced by both lint and a code generator, and prohibitively expensive
to reverse once every page follows it.

**Open questions:**

- What is the real rule for choosing bloc over cubit?
- Why service-locator lookup inside `BlocProvider.create` rather than constructor
  injection or `RepositoryProvider`?
- Why freezed state with a status enum rather than sealed state subclasses?
- `analysis_options.yaml` disables both `avoid_build_context_extensions` and
  `prefer_build_context_extensions`. What is the position being taken?
- Should the bloc scope rule (route-level versus page-level provision) be
  normative?
- Is `lib/features/dynamic_form/`, which uses raw `setState`, grandfathered or a
  violation?

---

# Tier 2

Strong candidates. Write these after Tier 1.

### 7. Extract reusable mechanics into local path packages

**Decision as implemented:** Reusable UI and navigation mechanics live in
versioned local packages consumed via path dependencies. The packages may not
depend on the app; the app owns route constants, localization, analytics, and
pages. Public API is funnelled through a single barrel and reaching into `src/`
is forbidden.

**Evidence:** `pubspec.yaml:10-14` for the path dependencies;
`packages/navigation/pubspec.yaml` depends only on Flutter and `go_router`;
`packages/navigation/lib/navigation.dart:1-16` for the barrel rule. The ownership
split is written down in `packages/navigation/README.md` and
`lib/presentation/navigation/README.md`. `packages/design_system/README.md` calls
itself "the beginning of the app modularization journey" and lists what does not
belong. The navigation package stays generic over `TTab`, and analytics is
injected via callbacks rather than imported.

**Why it clears the bar:** A module-boundary and dependency-direction decision
that sets the precedent for all future extraction and defines public interfaces.

**Open questions:**

- Is the driver real multi-app reuse, or enforcing a boundary inside one app?
- What is the extraction criterion — when does something graduate from
  `lib/presentation/widgets` to the design system?
- Who owns versioning and breaking changes for packages pinned at `0.1.0` with
  `publish_to: none`?
- `docs/agents/domain.md:23` says these packages should not get their own ADR
  trees unless published or consumed independently. Does this record live in
  `docs/decisions/` regardless?

### 8. Model local writes as offline-first mutations with sync status and tombstones

**Decision as implemented:** The cards table carries `sync_status`, `updated_at`,
`last_synced_at`, and `deleted_at`. Local writes mark rows created or updated;
deletes soft-delete into a hidden tombstone unless the row was never synced, in
which case it is hard-deleted; reads filter tombstones; and `getDirtyCards` plus
`markCardsSynced` form the upload-acknowledgement contract. Identities are
client-generated UUID v4 behind a `CardIdGenerator` seam, so a card is valid
before a server sees it. No remote transport exists yet.

**Evidence:** `lib/data/datasources/card/cards.datasource.dart:14-16`;
`lib/data/datasources/card/cards_local.datasource.dart:61-92`, `:94-119`, and
`:135-162`; `lib/data/dtos/card/card.dto.dart:3-20` for the status enum with a
defensive fallback; `lib/data/services/card/card_id.generator.dart:4-16`.
`docs/architecture/cards_sqlite_foundation.md:30-33` records that bulk upload,
sync UI, and conflict policy are deferred.

**Why it clears the bar:** An offline-capability requirement baked into the
schema and the datasource interface. Conflict policy and ID strategy are famously
expensive to change later, and this decision is currently half-made — the record
is where the deferred half gets an explicit boundary.

**Open questions:**

- Is last-write-wins assumed, or is conflict policy genuinely open?
- Do client UUIDs remain the server-side primary key, or will a server id be
  reconciled later, and where would that mapping live?
- What is the retention policy for tombstones that are never acknowledged?
- Should this be two records — offline mutation model, and client-generated
  identity?

### 9. Compose dependencies with get_it and injectable

**Decision as implemented:** All services, repositories, datasources, blocs, and
cubits are registered via injectable annotations into a single get_it root scope,
generated into `dependency_injection.config.dart`. Startup is a fixed two-step
sequence: configure DI, then run one ordered service initialiser. Constructor
injection is used below the widget tree; widgets pull from the service locator.

**Evidence:** `lib/core/di/dependency_injection.dart:6-7`;
`lib/dart_init.dart:6-16` and `lib/core/di/di_init.service.dart:11-23` for the
ordered orchestrator; `lib/main.dart:50` and `:65` plus
`tool/templates/feature/presentation/pages/_template.page.dart:15` for the widget
seam. Binding style is uniformly `@LazySingleton(as: X)` for repositories and
datasources and `@injectable` for blocs. The wiring is treated as a testable
contract in `test/core/di/dependency_injection_test.dart`, which also asserts that
`MockCardsDataSource` is not registered.

**Why it clears the bar:** Affects every construction site and every test setup;
swapping DI approaches is a whole-repo change.

**Open questions:**

- Why service-locator lookup in widgets rather than provider-based injection all
  the way down?
- Why is there no injectable environment or scope for mock versus real
  datasources? `MockCardsDataSource` is deliberately unannotated — is manual
  swapping the intended mechanism?
- Is a single root scope the long-term intent, or are feature scopes expected?

### 10. Propagate failures as exceptions and convert them at the bloc boundary

**Blocked.** Two contradictory paths exist in the code. Decide which is the
convention before drafting, or the record will enshrine an inconsistency.

**Decision as implemented:** There is no `Result` or `Either` type anywhere.
Repositories throw typed, feature-scoped exceptions; blocs wrap async calls in
`try`/`catch` and emit a status enum plus a user-facing message.

**Evidence:** typed exceptions declared alongside the repository contract at
`lib/data/repositories/card/cards.repository.dart:41-52`, thrown at
`cards.repository_impl.dart:54` and `:67`. Bloc-boundary conversion at
`lib/presentation/pages/cards/bloc/cards.bloc.dart:60-69`, and codified in
`tool/templates/feature/presentation/pages/bloc/_template.bloc.dart:25-37`.

**Why it clears the bar:** An interface convention on every seam in the app, baked
into the code generator. Retrofitting a `Result` type later touches every
repository, bloc, and test.

**Open questions:**

- `CardsBloc` calls `addError`, but no `BlocObserver`, `Bloc.observer`,
  `FlutterError.onError`, or `runZonedGuarded` is registered anywhere, so those
  errors go nowhere. Meanwhile `lib/presentation/pages/home/bloc/home_bloc.dart:22`
  and `:34-37` inject `ErrorReportingFacade` and call `recordError` then rethrow.
  Which is the convention?
- Where should uncaught errors be trapped?
- Was avoiding `Result` deliberate, and on what grounds?

### 11. Govern agent skills as validated repository artifacts

**Decision as implemented:** Project-local agent skills live in-repo as `SKILL.md`
plus `agents/openai.yaml` plus shared `references/`, governed by a scoped
constitution defining information ownership and hard word budgets, and enforced by
a Dart validator that checks frontmatter shape, budgets, invocation policy,
reference reachability, and that every repository path a skill cites actually
exists. Skill behaviour is separately regression-tested by a manifest-driven eval
harness that runs each case in a disposable temp git repo and grades declarative
invariants, keeping raw model artifacts outside the repository.

**Evidence:** `.codex/skills/AGENTS.md` for the constitution and budgets;
`tool/skills/skill.validator.dart:8-25` encoding exactly those numbers, with
diagnostic codes through `:78-672`; `tool/skills/validate.dart:19-37`;
`test/tool/skills/skill_validator_test.dart`. For evals:
`tool/skills/eval/eval.cli.dart:171-190` and `:358-370`,
`tool/skills/eval_cases.json:1-14` for schema version and replica and timeout
tiers, `tool/skills/eval/eval.comparator.dart:22-60`, and
`test/tool/skills/eval_test.dart`.

**Why it clears the bar:** Governs every agent interaction with the repo, encodes
a non-obvious safety property (never grade in place, never persist model output
in-repo), and introduces a hard dependency on an external CLI and its event
schema.

**Open questions:**

- Are the numeric budgets load-bearing or arbitrary starting points?
- `.codex/skills/` holds eight skills; `.claude/skills/` holds only `write-adr`.
  Deliberate, or an unfinished port? If both hosts are wanted, what is the single
  source of truth?
- Who decides `allow_implicit_invocation` per skill?
- Who runs evals, and when? Nothing automates them today.
- Where do baseline artifacts live if they must stay outside the repo, and how is
  a baseline pinned?
- Should this be split into two records — static governance, and behavioural
  evaluation?

### 12. Make repository documentation machine-checkable

**Blocked.** Decide whether this record describes the current state or the
intended state before drafting. See the last open question.

**Decision as implemented:** ADRs and agent-facing docs are structured data with
validators rather than prose. The ADR validator enforces filename and ID
agreement, allowed statuses, required headings, placeholder absence, duplicate
metadata rejection, and full supersession graph integrity including backlinks and
cycle detection, and regenerates the catalog table between markers. The context
validator enforces a line budget on scoped `AGENTS.md` files, resolves every local
Markdown link, requires the source map to exist, and asserts the canonical
template set is present with no generated Dart inside it.

**Evidence:** `tool/decisions/adr.validator.dart:5-11`, `:281-411`, `:427-472`;
`tool/decisions/adr.dart:8-28`; `tool/agent_context/context.validator.dart:11-15`,
`:60-66`, `:76-90`, `:92-127`, `:129-155`. The budget is respected: all scoped
`AGENTS.md` files are seven to nine lines. Tests at
`test/tool/decisions/adr_validator_test.dart` and
`test/tool/agent_context/context_validator_test.dart`.

**Why it clears the bar:** Documentation correctness becomes enforced rather than
aspirational, and it constrains how every future doc and ADR is written. The ADR
lifecycle — immutability plus supersession rather than editing — is itself a
durable convention.

**Open questions:**

- **The blocker:** none of these validators run in CI. `.github/workflows/ci.yml`
  runs pub get, build_runner, gen-l10n, `flutter analyze` with
  `continue-on-error: true`, and `flutter test`. `README.md` includes the context
  validator in the local loop but not the ADR or skill validators, which are
  invoked only from the `write-adr` skill's own steps. Should the record describe
  the current model-enforced arrangement, or the intended CI-gated one?
- Should `flutter analyze` stop being non-blocking?
- Is the scoped `AGENTS.md` line budget the real design intent? It currently
  forces near-empty pointer files.

### 13. Scaffold features from canonical templates via a deterministic CLI

**Decision as implemented:** `tool/templates/feature/**` is the single source of
truth for layered feature shape, rendered through a typed request, manifest, and
executor pipeline with dry-run, write, and check modes, JSON output, refusal to
overwrite, staged atomic replacement with rollback, and explicit drift statuses.
Templates are compilable Dart excluded from the analyzer and from code
generation. Agents render and review before writing, then re-verify with check —
file creation is delegated to the tool rather than to freehand writing.

**Evidence:** `tool/templates/feature_template_paths.dart`;
`tool/skills/scaffold/scaffold.models.dart:1-13`;
`tool/skills/scaffold/scaffold.cli.dart:21-56`;
`tool/skills/scaffold/scaffold.generator.dart`, including the cubit variant
derived by rewriting the bloc manifest at `:129-149`. Exclusions in `build.yaml`
and `analysis_options.yaml`. Workflow in `.codex/skills/feature-scaffold/SKILL.md:65-93`.
Tests at `test/tool/skills/scaffold_test.dart`.

**Why it clears the bar:** A construction technique that fixes the default feature
architecture in executable form, and is expensive to reverse once features are
generated from it.

**Open questions:**

- Should drift-check run in CI or as a pre-commit gate for already-scaffolded
  features?
- What is the intended lifecycle when a template changes after features were
  generated — regenerate, or accept drift permanently?
- Is "not crash-atomic across the multi-directory manifest" an accepted limitation
  or a known bug?
- Why templates-as-excluded-Dart rather than string templates or `mason` bricks?
  (`very_good_cli` was dropped as a dev dependency on 2026-08-07; the repository
  now standardises on `flutter test`, matching CI.)

### 14. Localize from day one and treat right-to-left as a hard requirement

**Decision as implemented:** All user-visible copy goes through ARB files compiled
by `flutter gen-l10n`. Three locales ship at full key parity, Hebrew makes
right-to-left a first-class supported layout, and the user can override the system
locale from in-app preferences, persisted. Generated localization Dart is derived
output and is never hand-edited.

**Evidence:** `l10n.yaml`; `pubspec.yaml` with `generate: true`,
`flutter_localizations`, and `intl`. Sixty-nine message keys in each of
`app_en.arb`, `app_es.arb`, and `app_he.arb`, with descriptions only in the
template. `lib/main.dart:86-93` for the locale override and all four delegates;
`lib/presentation/pages/app_preferences/app_language_options.dart:18-22` for the
supported list with native labels. Right-to-left is a test axis, not a nicety:
`test/widget_test.dart:207`, `:426`, `:445-446`, `:787`, `:815-816` assert
`TextDirection.rtl`, and the validation checklists list it alongside Material,
Cupertino, and compact and wide as a required coverage dimension. Process rules in
`lib/l10n/AGENTS.md` and `AGENTS.md`.

**Why it clears the bar:** A non-functional commitment plus a construction
technique, and adding right-to-left support after the fact is famously expensive.
The record captures why that cost was paid upfront.

**Open questions:**

- Why Spanish and Hebrew specifically? Hebrew reads as a deliberate
  right-to-left canary rather than a market.
- Generated localization Dart is committed. Intentional, for reviewability and CI
  simplicity?
- Is ARB key parity enforced anywhere, or only by convention? No parity check was
  found.
- Who writes the translations, and is machine translation acceptable?
- Is right-to-left required in every widget test, or only layout-sensitive
  surfaces? The design system itself has no locale or directionality tests despite
  owning the primitives.

---

# Tier 3

Cheap to write, and each prevents a specific drift.

### 15. Route telemetry through fan-out facades over swappable services

**Decision as implemented:** Analytics and error reporting are accessed only
through a facade that fans out to an injected collection of services. Concrete
vendors are registered behind named bindings via injectable modules, and
per-service failures are swallowed so telemetry can never break a caller.

**Evidence:** `lib/core/analytics/analytics_facade.dart:4-52`, including the
per-service `catch (_) {}`; `lib/core/error_reporting/error_reporting_facade.dart:5-59`
for the parallel fan-out and named composition. Vendor implementations are
currently log-only stand-ins behind the interface, which shows the seam is
intentional rather than incidental. Screen-view tracking is emitted from the
navigation layer and deliberately kept app-owned so the navigation package stays
analytics-agnostic (`lib/presentation/navigation/analytics/`).

**Why it clears the bar:** Fixes the interface every feature uses for telemetry
and dictates non-functional behaviour, including silent failure.

**Open questions:**

- Is silently swallowing telemetry failures intended in all environments, with no
  debug surfacing at all?
- Is multi-vendor fan-out a real requirement or speculative generality? The record
  needs the actual driver.

### 16. Enforce route access at the router, never in pages

**Decision as implemented:** Access decisions are made by a pure policy object
returning an allow-or-redirect decision, adapted into the router's redirect on
each guarded route, so a guarded page is never built when denied. An access-denied
route is a first-class fallback. The current policy input is a build-time define,
explicitly labelled a temporary stand-in for auth state.

**Evidence:** `lib/presentation/navigation/route_access_policy.dart:7-30`,
including the doc comment marking the define as temporary;
`lib/presentation/navigation/router.dart:35-37`, `:109-110`, `:116-117`, `:133-135`;
`lib/main.dart:31-34`. The durable rule is stated in
`lib/presentation/navigation/README.md`: "pages should not decide whether they are
allowed to render", along with a recovery-destination rubric. Tested at
`test/presentation/navigation/route_access_policy_test.dart`.

**Why it clears the bar:** Authorization posture is a non-functional requirement,
and "guards at the router, not in pages" is a durable convention every future
guarded journey inherits.

**Open questions:**

- Why a synchronous policy object rather than a refresh-listenable or async
  redirect driven by auth state? Does the eventual auth model fit?
- Should the intended location be preserved and replayed after sign-in? The README
  says yes; the code has no mechanism.
- Per-route redirect versus one top-level redirect as route count grows?
- What replaces the build-time define?

### 17. Theme through a brand token struct with shared theme structure

**Decision as implemented:** Themes are built from a token struct of colours,
producing one fixed theme structure. Two brands ship in-package, each component
theme is a separate builder fed a derived colour scheme, and Material 3 tonal
elevation is deliberately opted out of.

**Evidence:** `packages/design_system/lib/src/theme/design_brand.dart` for the
twenty-five required tokens, including semantic ones Material has no slot for and
a dedicated navigation-surface family; `design_brands.dart` for the two presets;
`design_color_schemes.dart` for the token-to-scheme mapping and the transparent
surface tint; `design_system_theme.dart` delegating to eight component builders.
Brand is passed explicitly at `lib/main.dart:79-84`.

**Why it clears the bar:** The token list is a public interface every future brand
and component theme must satisfy; adding or removing a token is a breaking change
across brands.

**Open questions:**

- The `success`, `warning`, and `info` tokens are defined but never mapped into a
  colour scheme or theme extension and are never read. How are they meant to be
  consumed?
- Why explicit tokens rather than seed-generated schemes? What is the contrast
  and accessibility story?
- In dark mode, `design_color_schemes.dart` maps `surface` to the variant token
  and `surfaceContainerHighest` to the base token, inverted relative to light.
  Intentional, or a bug the record must not enshrine?
- How is a brand selected at runtime — flavor, environment, remote config? It is
  hardcoded at the call site today.
- Related: theme values are exposed via `BuildContext` extensions with silent
  fallbacks rather than Flutter's `ThemeExtension`. Same record, or separate?

### 18. Standardise filenames on feature_or_entity.role.dart

**Decision as implemented:** Every Dart file is named with an underscore-separated
business name, a dot, and a technical role, drawn from a documented list of ten
suffixes. The convention is asserted in the root guidance, partly enforced by
`bloc_lint`, and baked into the scaffold generator's target paths and template
filenames.

**Evidence:** `AGENTS.md:46-58` for the rule and the suffix list;
`analysis_options.yaml:19` for `prefer_file_naming_conventions`;
`tool/skills/scaffold/scaffold.generator.dart:21-22`, `:80-92`, `:139-149`. In
practice the vocabulary is wider than the documented list, including `.storage`,
`.validator`, `.generator`, `.cli`, and `.executor`, for example
`lib/core/storage/app_database.storage.dart` and `tool/decisions/adr.validator.dart`.

**Why it clears the bar:** A repo-wide convention that a generator, a linter, and
every agent depend on. Reversing it is a mass rename plus tooling changes.

**Open questions:**

- Should the suffix list be closed and extended to cover the roles already in use
  outside `lib/`?
- Should a validator enforce it repo-wide, given `bloc_lint` only covers bloc and
  cubit files?
- What is the rule for test files?
- `home_bloc.dart`, `home_event.dart`, and `home_state.dart` violate the
  convention that `cards.bloc.dart` follows. Fix before or after recording?

### 19. Hand-write data models and reserve freezed for presentation state

**Decision as implemented:** Despite freezed being a dependency, no DTO or
repository value type uses it. DTOs are plain classes with explicit database-row
mapping and defensive parsing; value types use `Equatable`; settings hand-roll
`copyWith` with a sentinel for nullable-versus-absent. Freezed appears only in
presentation state files.

**Evidence:** generated freezed files exist only under `lib/presentation/pages/**`;
none under `lib/data` or `lib/core`. `lib/data/dtos/card/card.dto.dart:22-75` for
the hand-written DTO with storage-shaped mapping and a tolerant enum parse at
`:11-19`; `lib/core/storage/app_preferences.storage.dart:7`, `:22-67`, `:89-95` for
the sentinel `copyWith` and the fallback on malformed data;
`lib/data/repositories/card/cards.repository.dart:1-16` for the `Equatable` value
type. Related: repositories return app-facing value types, and DTOs never escape
`lib/data` (`lib/data/readme.md:8-18`).

**Why it clears the bar:** A construction convention affecting every future data
model, and currently invisible — the dependency is present, so a newcomer would
reasonably assume freezed is the house style everywhere. The corollary, that DTOs
map to database rows and parse defensively rather than throwing, is a durable
serialization convention.

**Open questions:**

- Was avoiding freezed in the data layer deliberate, or incidental? This one may
  simply not be a decision, in which case say so and drop the entry.
- Is `json_serializable` off the table for future remote DTOs?
- Should "tolerate bad stored data and fall back to a default" be universal, or
  should some corruption be loud?

### 20. Store settings as a single JSON blob and keep secrets out of app storage

**Decision as implemented:** All key-value settings go through one storage
singleton, serialized as a single JSON string under a single key rather than one
preference key per setting. Both storage mechanisms are explicitly declared
unsuitable for auth tokens or secrets, and preferences unsuitable for relational
or syncable data.

**Evidence:** `lib/core/storage/app_preferences.storage.dart:70-102`;
`lib/core/storage/README.md:48-72` for the split-by-shape rationale and the
explicit non-goals. `test/support/in_memory_shared_preferences_async_platform.dart`
is the standard test substitution. No secure-storage package is present.

**Why it clears the bar:** Draws a durable "which store for which data shape" line
that every future feature consults, and the no-secrets non-goal is a
security-relevant constraint that must survive personnel change.

**Open questions:**

- Does the single-blob shape scale, or does it need per-domain keys and a schema
  version? There is no version in the blob today.
- The stored key is still `app_cache.preferences`. Is renaming worth a migration?
- The README says startup initialization ensures defaults exist, but
  `lib/core/di/di_init.service.dart:22` calls `readPreferences()` and
  `ensureDefaultsExist()` has no callers at all. Dead code, or missed wiring?
  Resolve before drafting.

### 21. Define a tab-reselect and branch-reset protocol with an async veto

**Decision as implemented:** Tapping a navigation destination has three defined
behaviours: a different tab switches branches; the active tab on a nested route
resets that branch to its root, but only after an async guard for that tab
approves; the active tab already at its root runs the page-registered reselect
callback. Registration flows through an inherited scope and a controller registry,
with re-entrancy protection while a confirmation is pending.

**Evidence:** `packages/navigation/lib/src/navigation_shell.dart:153-177` for the
three-branch decision and the mounted-and-approved check;
`packages/navigation/lib/src/tab_reselect/tab_reselect_controller.dart`,
`tab_branch_reset_guard.dart:20-31`, `tab_reselect_scope.dart`, and
`tab_reselect_handler.dart:38-70`. Consumers at
`lib/presentation/pages/cards/cards.page.dart:63-65` and
`lib/presentation/pages/cards/draft_discard_guard.dart:28-106`. Dedicated tests in
`packages/navigation/test/`.

**Why it clears the bar:** A public interface between the shell package and every
root page, defining user-facing semantics, with a non-trivial unsaved-work veto.

**Open questions:**

- Why an inherited-widget registry rather than an event bus, router-level
  notification, or a declarative pop-scope-style API?
- Should the reset guard generalise into an app-wide unsaved-changes mechanism? It
  currently duplicates logic with the in-page discard path.
- Is rejecting while a confirmation is pending correct, versus queueing?

### 22. Take a runtime font dependency instead of bundling fonts

**Decision as implemented:** All typography comes from a runtime font package;
the design system's only third-party dependency is `google_fonts`, and no font
files are bundled.

**Evidence:** `packages/design_system/pubspec.yaml:14`;
`packages/design_system/lib/src/theme/components/design_system_text_theme.dart:134`
and `:143`, defining a fifteen-slot scale;
`packages/design_system/lib/src/theme/extensions/text_theme_extensions.dart:26-40`,
which re-resolves the font and detects the family by string match. No fonts
section in either pubspec and no font assets.

**Why it clears the bar:** A dependency and non-functional decision. By default
the package fetches over the network and caches, affecting first paint, offline
behaviour, and privacy posture, and it is the single style source for all text.

**Open questions:**

- Are fonts fetched at runtime, or is bundling with runtime fetching disabled the
  intent? Nothing configures it today, so runtime fetch is on. Is first-run
  flash-of-unstyled-text acceptable?
- Should the font family be a brand token so a second brand can differ?
- Is detecting the family by substring an acceptable long-term mechanism?

---

# Not ADR-ready

These look like decisions but are not. Each needs something to happen first.

**Networking.** `lib/core/networking/services.dart` wraps the raw HTTP package
with `dynamic`-returning methods, throws bare exceptions with no typed mapping,
hardcodes a placeholder base URL, and is not registered in DI; it is referenced
only by its own test. `lib/data/constants/api_endpoints.dart` has zero callers and
describes a different app's domain. The file's own doc comment credits an AI chat
tool. The transport decision has not been made — this reads as inherited
scaffolding. Triage it first. If networking is genuinely deferred, the honest
record is "defer the transport decision and register no HTTP client until the
sync API exists", which would pair naturally with entry 8.

**Feature flags.** `lib/core/feature_flags/feature_flag_service.dart` is entirely
commented out and the keys file holds one placeholder. The only real flag is the
compile-time define covered by entry 16. No decision is observable.

**`lib/features/dynamic_form/`.** A feature-first slice contradicting the
layer-first structure, marked deprecated in its own source as "just a tester".
This is an inconsistency to resolve, not a decision to record.

---

# Appendix: defects found during the sweep

Not ADRs. Recorded here so they are not lost; file them as issues per
[the issue tracker guide](../agents/issue-tracker.md).

- ~~`test/presentation/widgets/app_modal_widget_tests.dart` and
  `page_scaffold_widget_tests.dart` end in `_tests.dart`, not `_test.dart`, so
  `flutter test` never collects them.~~ Fixed 2026-08-07; both renamed to
  `*.widget_test.dart` and passing. Convention recorded in
  [ADR-0002](../decisions/0002-test-layer-conventions.md).
- `lib/presentation/widgets/app_modal.dart:173-177` — `AppModal.build` is a no-op
  passthrough that assigns the child to a local and returns it. The widget adds
  nothing; the real behaviour lives entirely in the static factories.
- `AppPreferencesStorage.ensureDefaultsExist()` has no callers in production or
  test, despite `lib/core/storage/README.md:56` claiming startup calls it.
- `DesignBrand.success`, `.warning`, and `.info` are defined and required on every
  brand but are never read anywhere.
- `lib/presentation/pages/home/bloc/home_bloc.dart` and its event and state files
  violate the `.bloc.dart` naming convention that `cards.bloc.dart` follows.
- `lib/presentation/widgets/webview_modal.dart:67-88` hardcodes English "Cancel"
  and "Confirm", bypassing localization.
- Breakpoint values are duplicated rather than shared: 600 and 1200 in
  `packages/navigation/lib/src/navigation_shell.dart:40-43`, and 600 again as a
  default in `lib/presentation/widgets/split_pane_layout.dart`.

# Appendix: testing follow-ups deferred on 2026-08-07

Deliberately left out of the test-structure change that produced
[ADR-0002](../decisions/0002-test-layer-conventions.md).

- The `sqfliteFfiInit` bootstrap plus temp-directory database fixture is
  copy-pasted across six files: `test/core/storage/app_database.storage_test.dart`,
  `app_database_migrations.storage_test.dart`,
  `app_database_migration_integration_test.dart`,
  `test/data/datasources/card/cards_local.datasource_test.dart`,
  `test/data/repositories/cards.repository_impl_test.dart`, and
  `test/core/di/dependency_injection_test.dart`. It belongs in `test/support/`
  alongside the app harness.
- The four tool-test fixtures (`_ContextFixture`, `_AdrFixture`,
  `_ScaffoldFixture`, `_SkillFixture`) are the same temp-directory shape written
  four times.
- `packages/design_system/test/adaptive_widgets_test.dart` is one flat file
  holding seven groups, while `test/adaptive/app_text_field_test.dart` sits in a
  mirrored subdirectory. The package's test layout is half-migrated.
- `integration_test/cards_sqlite_smoke_test.dart` never runs in CI. It needs an
  emulator job, which no workflow currently provides.
- 13 analyzer infos remain in `lib/` and `tool/`, which is why CI runs
  `flutter analyze --no-fatal-infos` rather than the bare command. Five are a
  genuine `Radio` to `RadioGroup` migration in
  `lib/features/dynamic_form/application/dynamic_form.dart`; three are
  `prefer_initializing_formals` false positives, since Dart forbids private
  named parameters.
- Coverage is collected and uploaded but not gated. Baseline on 2026-08-07 was
  80.5% of lines (1562/1941) across 71 files.
