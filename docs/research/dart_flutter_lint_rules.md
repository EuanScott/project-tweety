# Dart/Flutter lint rules beyond `flutter_lints`

Research note. Primary sources are the published package YAML files, `dart.dev`,
and `pub.dev`. Every membership claim below was verified by reading the actual
resolved package in `~/.pub-cache`, and every impact number was measured by
running `flutter analyze` against this repo.

**Verified against**

| Thing | Version | How verified |
| --- | --- | --- |
| Flutter | 3.47.0 (stable, 2026-08-11) | `flutter --version` |
| Dart | 3.13.0 (stable, 2026-08-05) | `dart --version` |
| `flutter_lints` | 6.0.0 | `~/.pub-cache/hosted/pub.dev/flutter_lints-6.0.0/lib/flutter.yaml` |
| `lints` | 6.1.0 (transitive) | `~/.pub-cache/hosted/pub.dev/lints-6.1.0/lib/{core,recommended}.yaml` |
| `bloc_lint` | 0.4.2 | `~/.pub-cache/hosted/pub.dev/bloc_lint-0.4.2/lib/{all,recommended}.yaml` + `lib/src/rules/*.dart` |
| `very_good_analysis` | 10.3.0 | `~/.pub-cache/hosted/pub.dev/very_good_analysis-10.3.0/lib/analysis_options.10.3.0.yaml` |

Measurements were taken by temporarily swapping `analysis_options.yaml`, running
`flutter analyze`, and restoring the original file. The repo's config is
unchanged.

---

## Summary

`flutter_lints` 6.0.0 is a thin wrapper: it is `package:lints/recommended.yaml`
plus exactly ten Flutter-specific rules, and `lints/recommended.yaml` is
`lints/core.yaml` plus 56 more — 102 effective rules in total. This repo's
`analysis_options.yaml` includes both `lints/recommended` **and**
`flutter_lints/flutter`, which is a verified no-op: analysing the repo with and
without the `lints/recommended` line produces byte-identical output. Worse, it
makes the config depend on `lints`, which is only a *transitive* dependency
here.

The most valuable thing missing from this repo is not a lint rule at all. Turning
on `analyzer: language: strict-casts` surfaces **eight genuine type errors** —
implicit `dynamic` downcasts in `lib/core/networking/services.dart` and
`lib/features/dynamic_form/` where a `dynamic` value is silently flowing into a
typed slot. No lint rule list would have caught these. `strict-raw-types` is
free (zero new issues), and `strict-inference` costs five annotations.

Beyond that, a large set of real bug-catching lints — `unawaited_futures`,
`cancel_subscriptions`, `throw_in_finally`, `test_types_in_equals`,
`literal_only_boolean_expressions`, `no_adjacent_strings_in_list`,
`unnecessary_statements` and others — currently produce **zero violations** in
this codebase. They are free to adopt now and only pay off later.

Adopting `very_good_analysis` wholesale is not worth it here: it produces 638
issues, 299 of which (47%) are `public_member_api_docs` on a playground app, and
24 are `always_use_package_imports`, which directly contradicts this repo's
documented relative-import convention. It also ships three rules that Dart 3.13
now reports as *deprecated*.

Two traps to avoid. `use_if_null_to_convert_nulls_to_bools` is deprecated and
`avoid_returning_null_for_future` was removed in Dart 3.3.0 — neither should be
added despite appearing on many "recommended rules" lists. And do **not** add
`analyzer: exclude:` entries for generated files: every generated file in this
repo already carries `// ignore_for_file: type=lint`, and `exclude:` suppresses
real compile errors too, not just lints.

Finally, none of this is enforced today. CI runs
`flutter analyze --no-fatal-infos` under `continue-on-error: true`, and
`bloc_lint` does not run under `flutter analyze` at all — it needs the separate
`bloc lint` CLI from `bloc_tools`, which is not a dependency. **Rule selection is
secondary to fixing the enforcement gate.**

---

## Recommended changes for this repo

### Tier A — fix what's wrong today

Four defects, all verified.

**A1. The double `include:` is a no-op.** `flutter_lints/flutter.yaml` line 3 is
literally `include: package:lints/recommended.yaml`. Verified empirically: 13
issues with both includes, 13 identical issues with only `flutter_lints`.
`dart.dev` confirms later includes override earlier ones, so the second include
fully subsumes the first.

**A2. `package:lints` is only a transitive dependency.** `pubspec.lock` shows
`lints: dependency: transitive`. Referencing `package:lints/...` from
`analysis_options.yaml` while not declaring `lints` in `pubspec.yaml` works only
because pub writes every transitive package into `package_config.json`. It
breaks silently if `flutter_lints` ever stops depending on `lints`. Removing the
line (A1) resolves this too.

**A3. CI cannot fail on analysis.** `.github/workflows/ci.yml` runs
`flutter analyze --no-fatal-infos` with `continue-on-error: true`, for all three
packages. Every lint below is currently advisory. This is a known, deliberate
deferral (see the repo's memory note on `continue-on-error`), but it means
**adding rules changes nothing until this is addressed.** The migration path is
to promote a chosen subset to `warning`/`error` via `analyzer: errors:` and drop
`continue-on-error`, rather than flipping `--no-fatal-infos` and inheriting all
102 rules as blocking at once.

**A4. `bloc_lint` is not wired into any gate.** `bloclibrary.dev` states the
linter runs "through your IDE or the `bloc command-line tools` with the
`bloc lint` command". `bloc_tools` is not in `pubspec.yaml`, and neither CI nor
`.githooks/pre-commit` invokes it. The `bloc:` block in `analysis_options.yaml`
is IDE-only today. (It currently passes: `bloc lint .` reports `0 issues found,
Analyzed 189 files`.)

```yaml
# analysis_options.yaml — Tier A
# A1/A2: flutter.yaml already includes package:lints/recommended.yaml.
include: package:flutter_lints/flutter.yaml
```

```yaml
# .github/workflows/ci.yml — Tier A3
      - name: Analyze
        run: flutter analyze          # drop --no-fatal-infos once Tier B is clean
      # remove: continue-on-error: true
```

```yaml
# pubspec.yaml — Tier A4, if bloc rules should be enforced rather than advisory
dev_dependencies:
  bloc_tools: ^0.1.0   # then add `bloc lint .` to .githooks/pre-commit and CI
```

### Tier B — high-value bug-catching rules to add

Split by what they actually cost this repo today. Measured, not guessed.

**B1 — free right now (0 violations).** Adopt immediately; they are pure future
insurance.

```yaml
linter:
  rules:
    # Async correctness
    unawaited_futures: true              # 0 — fire-and-forget futures in async bodies
    cancel_subscriptions: true           # 0 — leaked StreamSubscription
    # Correctness
    throw_in_finally: true               # 0 — throw in finally discards the original error
    test_types_in_equals: true           # 0 — unguarded cast in operator ==
    literal_only_boolean_expressions: true  # 0 — conditions that are constant
    no_adjacent_strings_in_list: true    # 0 — missing comma silently concatenates
    unnecessary_statements: true         # 0 — expression statements with no effect
    # Dart 3 pattern/class-modifier correctness
    unnecessary_breaks: true             # 0 — leftover C-style breaks in switch
    # Flutter widget hygiene
    use_colored_box: true                # 0 — Container(color:) -> ColoredBox
    use_decorated_box: true              # 0 — Container(decoration:) -> DecoratedBox
```

**B2 — the strict language modes.** These are the highest-signal change
available, and they are analyzer *language* settings, not lints.

```yaml
analyzer:
  language:
    strict-raw-types: true   # +0 issues on this repo. Free.
    strict-casts: true       # +8 ERRORS. See below — these are real bugs.
```

`strict-casts` output on this repo:

```
error • A value of type 'dynamic' can't be returned from the method 'postData'
        because it has a return type of 'Future<Map<String, dynamic>>'
        • lib/core/networking/services.dart:47:12 • return_of_invalid_type
        (same for putData:85, deleteData:108)
error • A value of type 'dynamic' can't be assigned to a variable of type 'String?'
        • lib/core/networking/services.dart:135:21 • invalid_assignment
error • The argument type 'dynamic' can't be assigned to the parameter type 'String'
        • lib/features/dynamic_form/application/dynamic_form.dart:131,147,148,149
        • argument_type_not_assignable
```

These are genuine holes: `services.dart` is decoding JSON into `dynamic` and
returning it from methods declared `Future<Map<String, dynamic>>`, so a
malformed response fails at an arbitrary later call site rather than at the
boundary. Fixing them is a small, contained job in two files.

`strict-inference: true` is deferred to Tier C — it costs 5 annotations
(`inference_failure_on_function_return_type` ×2,
`inference_failure_on_collection_literal` ×2,
`inference_failure_on_function_invocation` ×1) and catches style, not bugs.

**B3 — small, real cleanups (1 violation each).**

```yaml
linter:
  rules:
    avoid_dynamic_calls: true       # 1 — test/core/networking/services_test.dart:73
    close_sinks: true               # 1 — test/tool/skills/eval_test.dart:1106
    only_throw_errors: true         # 1 — test/core/storage/app_database.storage_test.dart:241
    always_declare_return_types: true  # 1 — lib/core/networking/services.dart:187
```

`avoid_dynamic_calls` pairs naturally with `strict-casts`: strict-casts stops
`dynamic` leaking *out*, `avoid_dynamic_calls` stops you calling methods *on* it.

**B4 — worth it, but do the cleanup first.**

```yaml
linter:
  rules:
    discarded_futures: true    # 15 violations — futures started in sync functions
    avoid_slow_async_io: true  #  9 violations — all in tool/ and test/, sync IO is faster
    sort_pub_dependencies: true #  2 violations — pubspec ordering
```

`discarded_futures` is the one with real bug-catching value (15 sites, including
`lib/main.dart:95` and several `.widget.dart` callbacks where a `Future` is
started and its errors are dropped). The fix is usually wrapping in
`unawaited(...)` and deciding deliberately, which is exactly the point. Note the
9 `avoid_slow_async_io` hits are entirely in `tool/` and `test/` — if those
aren't worth changing, scope the rule with a nested `analysis_options.yaml`
rather than not adopting it.

### Tier C — opinionated/style rules to consider

Defensible, but they are taste, not correctness. Listed with measured cost.

```yaml
analyzer:
  language:
    strict-inference: true             # 5 — forces annotations the inferrer can't derive
linter:
  rules:
    prefer_final_locals: true          # 8 — immutability by default
    prefer_final_in_for_each: true     # 0 — same, free
    unnecessary_lambdas: true          # 3 — tear-offs over closures
    unnecessary_parenthesis: true      # 2
    use_named_constants: true          # 0
    use_setters_to_change_properties: true  # 0
    comment_references: true           # 1 — catches stale doc-comment links
    require_trailing_commas: true      # 0 — but see note below
    directives_ordering: true          # 28 — import ordering; high churn, low value
```

Notes:

- `require_trailing_commas` reports 0 because `dart_style` 3.x already formats
  this way. It is effectively already satisfied by the formatter; adding it is
  belt-and-braces, not a behaviour change.
- `comment_references` finds one real stale reference at
  `lib/presentation/widgets/tool_bar.dart:20`. Cheap win, but it is noisy on
  codebases that reference external types in docs.
- `directives_ordering` at 28 violations is the classic "big diff, no bugs
  found" rule. Skip unless import ordering is actively causing review friction.

**Experimental — adopt with eyes open.** `dart.dev` marks these
`science Experimental`; they can change or be withdrawn.

```yaml
    implicit_reopen: true         # 0 — experimental
    invalid_case_patterns: true   # 0 — experimental, "Released in Dart 3.0"
    unnecessary_async: true       # 0 — experimental
```

All three are free today. `invalid_case_patterns` is the most useful of the
three given this repo's heavy `freezed` sealed-union usage.

### Tier D — rules to deliberately NOT enable, and why

| Rule | Why not |
| --- | --- |
| `use_if_null_to_convert_nulls_to_bools` | **Deprecated.** `flutter analyze` emits `deprecated_lint: The lint rule 'use_if_null_to_convert_nulls_to_bools' is deprecated and shouldn't be enabled`, and dart.dev shows a Deprecated badge. It appears on many blog "recommended" lists — ignore them. |
| `avoid_returning_null_for_future` | **Removed in Dart 3.3.0.** Verified: `removed_lint: 'avoid_returning_null_for_future' was removed in Dart '3.3.0'`. Non-nullable futures made it redundant. |
| `always_use_package_imports` | Contradicts AGENTS.md, which mandates relative imports "where already generated or established" — and `part` files require them. Costs 24 violations. Also **mutually incompatible** with `prefer_relative_imports`: the analyzer emits `incompatible_lint` if both are on. Pick at most one; for this repo, neither. |
| `public_member_api_docs` | 299 violations (47% of the whole `very_good_analysis` run). Justified for a published package; not for a playground app with no external consumers. |
| `lines_longer_than_80_chars` | `dart_style` already enforces the page width. A lint that duplicates the formatter only fires where the formatter *couldn't* wrap (long string literals, URLs), which is exactly where you don't want to be nagged. |
| `avoid_catches_without_on_clauses` | 13 violations. Legitimate at boundaries — repository/datasource layers deliberately catch broadly to map to a failure state. Would be mostly suppressed. |
| `avoid_types_on_closure_parameters` | 54 violations, pure style, and it fights `strict-inference` (Tier C) which wants *more* annotations. |
| `sort_constructors_first`, `always_put_required_named_parameters_first`, `avoid_redundant_argument_values`, `prefer_int_literals` | Member-ordering and literal-style churn. 9/13/19/3 violations, zero bugs. |
| `flutter_style_todos` | 16 violations. The repo already uses `TODO(Euan):` in `analysis_options.yaml`; enforcing the exact format across the tree is not worth the diff. |
| `avoid_private_typedef_functions`, `one_member_abstracts`, `unnecessary_await_in_return` | **Deprecated in Dart 3.13.** All three still ship in `very_good_analysis` 10.3.0 — see Q3. |
| `analyzer: exclude:` for generated files | Unnecessary *and* harmful — see Q4. Generated files already self-suppress via `// ignore_for_file: type=lint`. |

### Consolidated proposed config

Tier A + Tier B, which is the change I'd actually make.

```yaml
# flutter.yaml already includes package:lints/recommended.yaml, which includes
# package:lints/core.yaml. 102 effective rules.
include: package:flutter_lints/flutter.yaml

analyzer:
  language:
    strict-casts: true       # implicit dynamic downcasts become errors
    strict-raw-types: true   # raw generic types become warnings

  exclude:
    - tool/templates/**
    - build/**
    - android/**
    - ios/**
    - web/**
    - windows/**
    - macos/**
    - linux/**
    # Deliberately NOT excluding *.g.dart / *.freezed.dart / l10n / DI config:
    # they already carry `// ignore_for_file: type=lint`, and `exclude:` would
    # also hide genuine compile errors in generated output.

linter:
  rules:
    avoid_print: true
    prefer_single_quotes: true

    # --- async correctness ---
    unawaited_futures: true
    cancel_subscriptions: true
    close_sinks: true
    discarded_futures: true

    # --- type / logic correctness ---
    avoid_dynamic_calls: true
    always_declare_return_types: true
    only_throw_errors: true
    throw_in_finally: true
    test_types_in_equals: true
    literal_only_boolean_expressions: true
    no_adjacent_strings_in_list: true
    unnecessary_statements: true
    unnecessary_breaks: true

    # --- Flutter widget hygiene ---
    use_colored_box: true
    use_decorated_box: true

    # --- housekeeping ---
    avoid_slow_async_io: true
    sort_pub_dependencies: true

bloc:
  rules:
    avoid_build_context_extensions: false
    avoid_flutter_imports: error
    avoid_public_bloc_methods: error
    avoid_public_fields: warning
    prefer_build_context_extensions: false
    prefer_file_naming_conventions: false
    prefer_void_public_cubit_methods: info
    # prefer_bloc / prefer_cubit deliberately omitted: mutually exclusive by
    # design, and this repo uses both patterns.
```

The two sibling packages (`packages/design_system`, `packages/navigation`)
should get the same `analyzer:` and `linter:` blocks minus the `bloc:` section.
Their current header comment says they "mirror the root" — after Tier A they
genuinely will, since the root's extra `lints/recommended` line was the only
difference and it was inert.

---

## Rule-by-rule reference table

`flutter_lints v6` = present in the 102-rule transitive closure of
`flutter_lints 6.0.0` (verified by parsing `flutter.yaml`, `recommended.yaml`,
`core.yaml`). `VGA` = `very_good_analysis` 10.3.0. "Count" = violations measured
on this repo.

| Rule | Catches | In flutter_lints v6? | In VGA 10.3.0? | Bug or style | Count | Recommend? |
| --- | --- | --- | --- | --- | --- | --- |
| `always_declare_return_types` | Methods/functions with no declared return type | No | Yes | Style (aids inference) | 1 | **Yes** (B3) |
| `avoid_dynamic_calls` | Method call / property access on a `dynamic` target | No | Yes | **Bug** | 1 | **Yes** (B3) |
| `avoid_slow_async_io` | Async `dart:io` calls that are slower than their sync form | No | Yes | Perf | 9 | Yes (B4) |
| `cancel_subscriptions` | `StreamSubscription` never cancelled — leak | No | Yes | **Bug** | 0 | **Yes** (B1) |
| `close_sinks` | `Sink`/`StreamController` never closed — leak | No | **No** (and set to `ignore` in VGA's `errors:`) | **Bug** | 1 | **Yes** (B3) |
| `comment_references` | Doc-comment `[Identifier]` not in scope — stale docs | No | Yes | Style | 1 | Consider (C) |
| `discarded_futures` | Future-returning call in a *non-async* function | No | Yes | **Bug** | 15 | Yes (B4) |
| `unawaited_futures` | Un-awaited future in an *async* body | No | Yes | **Bug** | 0 | **Yes** (B1) |
| `only_throw_errors` | `throw` of something that isn't `Exception`/`Error` | No | Yes | **Bug** | 1 | **Yes** (B3) |
| `prefer_final_locals` | Locals never reassigned but not `final` | No | Yes | Style | 8 | Consider (C) |
| `prefer_final_in_for_each` | Same, for `for-in` variables | No | Yes | Style | 0 | Consider (C) |
| `require_trailing_commas` | Missing trailing commas | No | Yes | Style | 0 | Low value — formatter already does this |
| `sort_pub_dependencies` | Unsorted `pubspec.yaml` deps | No | Yes | Style | 2 | Yes (B4) |
| `test_types_in_equals` | `operator ==` casting without a type test | No | Yes | **Bug** | 0 | **Yes** (B1) |
| `throw_in_finally` | `throw` inside `finally` — swallows original error | No | Yes | **Bug** | 0 | **Yes** (B1) |
| `unnecessary_lambdas` | Closure where a tear-off works | No | Yes | Style | 3 | Consider (C) |
| `unnecessary_parenthesis` | Redundant parens | No | Yes | Style | 2 | Consider (C) |
| `unnecessary_statements` | Expression statement with no effect | No | Yes | **Bug** | 0 | **Yes** (B1) |
| `use_if_null_to_convert_nulls_to_bools` | `nullableBool == true` → `?? false` | No | **No** | Style | 2 | **No — DEPRECATED** |
| `use_named_constants` | Re-constructing a value that has a named constant | No | Yes | Style | 0 | Consider (C) |
| `use_setters_to_change_properties` | `void setX(v)` that should be a setter | No | Yes | Style | 0 | Consider (C) |
| `avoid_returning_null_for_future` | — | No | **No** | — | n/a | **No — REMOVED in Dart 3.3.0** |
| `literal_only_boolean_expressions` | Conditions built only from literals — always-true/false | No | Yes | **Bug** | 0 | **Yes** (B1) |
| `no_adjacent_strings_in_list` | Missing comma silently concatenates two strings | No | Yes | **Bug** | 0 | **Yes** (B1) |
| `collection_methods_unrelated_type` | `list.contains(wrongType)` etc. | **Yes** (core) | Yes | **Bug** | 0 | Already on |
| `implicit_reopen` | Subtype silently reopens a `sealed`/`final` class | No | Yes | **Bug** | 0 | Consider — *experimental* |
| `invalid_case_patterns` | Case expressions invalid under Dart 3 semantics | No | Yes | **Bug** | 0 | Consider — *experimental* |
| `unnecessary_breaks` | C-style `break` in a Dart 3 `switch` | No | Yes | Style | 0 | **Yes** (B1) |
| `use_build_context_synchronously` | `BuildContext` used across an `await` | **Yes** (flutter) | Yes | **Bug** | 0 | Already on |
| `sized_box_for_whitespace` | `Container` used purely for spacing | **Yes** (flutter) | Yes | Perf | 0 | Already on |
| `use_colored_box` | `Container(color:)` → `ColoredBox` | No | Yes | Perf | 0 | **Yes** (B1) |
| `use_decorated_box` | `Container(decoration:)` → `DecoratedBox` | No | **No** | Perf | 0 | **Yes** (B1) |
| `use_key_in_widget_constructors` | Public widget ctor with no `Key` param | **Yes** (flutter) | Yes | **Bug** | 0 | Already on |
| `avoid_unnecessary_containers` | `Container` with a single child and no config | **Yes** (flutter) | Yes | Perf | 0 | Already on |
| `prefer_const_constructors` | Missing `const` | **No** — *removed in flutter_lints 5.0.0* | Yes | Perf | — | See Q6 |
| `prefer_const_declarations` | Missing `const` on locals | **No** — removed in 5.0.0 | Yes | Perf | — | See Q6 |
| `prefer_const_literals_to_create_immutables` | Missing `const` on collection literals | **No** — removed in 5.0.0 | Yes | Perf | — | See Q6 |
| `prefer_const_constructors_in_immutables` | `@immutable` class without a `const` ctor | **Yes** (flutter) | Yes | **Bug** | 0 | Already on |
| `always_use_package_imports` | Relative imports | No | Yes | Style | 24 | **No** — conflicts with repo convention |
| `prefer_relative_imports` | Package imports within own lib | No | No | Style | — | **No** — incompatible with the above |
| `public_member_api_docs` | Undocumented public members | No | Yes | Style | 299 | **No** |
| `lines_longer_than_80_chars` | Long lines | No | Yes | Style | — | **No** — formatter's job |
| `unnecessary_async` | `async` function with no `await` | No | **No** | Perf | 0 | Consider — *experimental* |
| `strict_top_level_inference` | Top-level decl needing an explicit type | **Yes** (core, added in v6) | Yes | Style | 1 | Already on |

---

## Findings by question

### Q1 — Baseline layering: `lints/core` vs `lints/recommended` vs `flutter_lints`

The relationship is strict containment, verified by reading the YAML:

```
package:lints/core.yaml           36 rules, no include
  └─ package:lints/recommended.yaml   include: package:lints/core.yaml  + 56 rules
       └─ package:flutter_lints/flutter.yaml  include: package:lints/recommended.yaml + 10 rules
```

`flutter_lints 6.0.0/lib/flutter.yaml` in full:

```yaml
# Recommended lints for Flutter apps, packages, and plugins.

include: package:lints/recommended.yaml

linter:
  rules:
    - avoid_print
    - avoid_unnecessary_containers
    - avoid_web_libraries_in_flutter
    - no_logic_in_create_state
    - prefer_const_constructors_in_immutables
    - sized_box_for_whitespace
    - sort_child_properties_last
    - use_build_context_synchronously
    - use_full_hex_values_for_flutter_colors
    - use_key_in_widget_constructors
```

Effective total: **102 unique rules**.

`core.yaml` describes itself as "a set of core lints used to identify critical
issues"; `recommended.yaml` adds "lints that help identify additional issues
that might lead to problems when running or consuming Dart code, as well as
lints that enforce writing Dart using a single, idiomatic style".

**Is including both redundant? Yes — verified two ways.**

1. By source: `flutter.yaml` line 3 *is* `include: package:lints/recommended.yaml`.
2. Empirically: analysing this repo with
   `include: [package:lints/recommended.yaml, package:flutter_lints/flutter.yaml]`
   and with `include: package:flutter_lints/flutter.yaml` produced **identical**
   diagnostic output (13 issues, `diff` clean).

Ordering makes it doubly moot: dart.dev states "Options in an included file can
be overridden in the including file, as well as by subsequent included files" —
`flutter_lints` is listed second, so it wins regardless.

The one non-cosmetic cost is A2: `pubspec.lock` records
`lints: dependency: transitive`. The config references a package the project
doesn't declare.

Also note `flutter_lints 6.0.0` pins `lints: ^6.0.0` but resolves to `lints
6.1.0` here — so `core.yaml` includes `strict_top_level_inference` and
`unnecessary_underscores`, added in the 6.x line, which is where this repo's one
`strict_top_level_inference` diagnostic comes from.

Sources: package YAML in `~/.pub-cache` (primary);
<https://dart.dev/tools/analysis>; <https://pub.dev/packages/flutter_lints>.

### Q2 — What `flutter_lints` deliberately leaves out

`flutter_lints` is intentionally conservative — it is the default for
`flutter create`, so it only carries rules that are near-universally correct.
Everything in the requested list except `collection_methods_unrelated_type`,
`use_build_context_synchronously`, `sized_box_for_whitespace`,
`use_key_in_widget_constructors` and `avoid_unnecessary_containers` is **absent**
from flutter_lints v6. See the reference table above for the per-rule verdict.

Two entries on that list are traps:

- **`use_if_null_to_convert_nulls_to_bools` is deprecated.** Enabling it makes
  `flutter analyze` emit
  `warning • The lint rule 'use_if_null_to_convert_nulls_to_bools' is deprecated
  and shouldn't be enabled • deprecated_lint`. dart.dev shows a Deprecated
  badge.
- **`avoid_returning_null_for_future` was removed.** `dart analyze` reports
  `'avoid_returning_null_for_future' was removed in Dart '3.3.0'` —
  `removed_lint`. Null safety made a `null` `Future` unrepresentable.

Three are marked `science Experimental` on dart.dev and were confirmed on their
individual rule pages: `implicit_reopen`, `invalid_case_patterns`
("Experimental… Released in Dart 3.0"), and `unnecessary_async` ("Experimental",
description: "No await no async").

The genuinely high-value bug-catchers absent from `flutter_lints` are, roughly in
order: `discarded_futures` / `unawaited_futures` (dropped async errors),
`avoid_dynamic_calls`, `cancel_subscriptions` / `close_sinks` (resource leaks),
`only_throw_errors`, `throw_in_finally`, `test_types_in_equals`,
`literal_only_boolean_expressions`, `no_adjacent_strings_in_list`,
`unnecessary_statements`.

The `discarded_futures` / `unawaited_futures` pair is worth understanding as a
pair — they are complementary, not alternatives. `unawaited_futures` fires on an
un-awaited future inside an `async` body; `discarded_futures` fires on a
future-returning call inside a *synchronous* function. Widget callbacks
(`onPressed: () { repo.save(); }`) are synchronous, so `discarded_futures` is the
one that catches the common Flutter mistake — which is exactly what the 15 hits
in this repo are (`lib/main.dart:95`,
`lib/presentation/pages/.../card_details_editor.widget.dart:39`, etc.).

Sources: <https://dart.dev/tools/linter-rules> (primary) plus individual rule
pages; membership verified against package YAML rather than the docs table.

### Q3 — `very_good_analysis`

**Framing check, as requested: `very_good_analysis` is NOT a dependency of this
repo.** `grep very_good_analysis pubspec.lock` returns nothing. Only
`very_good_cli` is present, as a `direct dev` dependency, and CI additionally
does `dart pub global activate very_good_cli`. `very_good_cli` is a scaffolding
and test-runner CLI (`very_good test --coverage` in CI); it does not put
`very_good_analysis` into this project's include chain. The framing in the task
brief is accurate. (Version 10.3.0 is present in the local pub cache from an
unrelated global activation, which is why it was readable here.)

**Latest version and SDK.** 10.3.0, released 2026-06-18 per its CHANGELOG.
`pubspec.yaml` declares `environment: sdk: ^3.12.0`. This repo is on Dart 3.13.0,
so it would resolve.

**Flutter-specific or Dart-only?** The package describes itself as "Lint rules
for **Dart and Flutter** used internally at Very Good Ventures", and its
`pubspec.yaml` has no Flutter dependency (like `lints` and `flutter_lints`, it
contains no code). It ships Flutter-only rules — `use_key_in_widget_constructors`,
`sized_box_for_whitespace`, `avoid_unnecessary_containers`, `use_colored_box`,
`sized_box_shrink_expand`, `no_logic_in_create_state`,
`use_full_hex_values_for_flutter_colors` — so it is usable for both, but a
pure-Dart package will simply never trigger the Flutter subset.

**What it turns on beyond `flutter_lints`.** 212 rules versus 102 — roughly
double. Structurally it does *not* `include:` `lints` or `flutter_lints`; it is a
single flat list that re-declares everything it wants. It also configures things
`flutter_lints` doesn't touch at all:

```yaml
analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
  errors:
    close_sinks: ignore
    unrelated_type_equality_checks: warning
    collection_methods_unrelated_type: warning
    missing_return: error
    missing_required_param: error
    record_literal_one_positional_no_trailing_comma: error
formatter:
  trailing_commas: preserve
```

Note `close_sinks: ignore` — VGA does not enable `close_sinks` as a lint *and*
explicitly pins it to `ignore`, a strong signal they consider it false-positive
prone. It fires exactly once on this repo, in a test, so the risk here is low.

**Friction points, measured on this repo.** A wholesale adoption produces
**638 issues**:

| Rule | Count | Comment |
| --- | --- | --- |
| `public_member_api_docs` | 299 | 47% of the total. Playground app, no external consumers. |
| `avoid_types_on_closure_parameters` | 54 | Pure style; fights `strict-inference`. |
| `directives_ordering` | 28 | Import churn. |
| `always_use_package_imports` | 24 | Contradicts AGENTS.md relative-import convention. |
| `avoid_redundant_argument_values` | 19 | |
| `flutter_style_todos` | 16 | |
| `discarded_futures` | 15 | Genuinely useful — already in Tier B4. |
| `avoid_catches_without_on_clauses` | 13 | Fights the layered error-mapping pattern. |
| `always_put_required_named_parameters_first` | 13 | |

Two further friction points not usually mentioned:

1. **VGA 10.3.0 ships three rules Dart 3.13 reports as deprecated** —
   `avoid_private_typedef_functions`, `one_member_abstracts`,
   `unnecessary_await_in_return`. Adopting it means inheriting three permanent
   `deprecated_lint` warnings until VGA catches up.
2. **Its `errors:` block references a diagnostic that no longer exists.**
   `missing_return: error` — `missing_return` was removed with null safety;
   `dart analyze` confirms `'missing_return' isn't a recognized lint rule`. The
   analyzer silently accepts unknown codes under `errors:`, so this is a dead
   entry nobody noticed.

`always_use_package_imports` deserves a specific warning: the analyzer treats it
and `prefer_relative_imports` as **mutually incompatible** and will say so —
`incompatible_lint: The rule 'always_use_package_imports' is incompatible with
'prefer_relative_imports'`. If you adopt VGA and then try to re-enable relative
imports to match this repo's convention, you get an analyzer error, not a
silent override. You must disable VGA's rule with
`always_use_package_imports: false`.

**Verdict for this repo:** cherry-pick, don't adopt. The valuable ~15% of VGA is
captured by Tier B above; the other 85% is 500+ style diagnostics on a
playground app.

Sources: `analysis_options.10.3.0.yaml` + `pubspec.yaml` + `CHANGELOG.md` from
the published package (primary);
<https://github.com/VeryGoodOpenSource/very_good_analysis>.

### Q4 — The analyzer `errors:` section and language settings

**Promoting lints to errors/warnings.** dart.dev: "You can globally change the
severity of a particular rule. This technique works for regular analysis issues
as well as for lints." Values are `ignore`, `info`, `warning`, `error`. Verified:
with `errors: avoid_print: error`, the analyzer reports
`error - Don't invoke 'print' in production code`. This is the right mechanism
for Tier A3 — promote a chosen subset to `error` and let CI fail on it, rather
than making all 102 rules fatal at once with `--fatal-infos`.

**`exclude:` vs `// ignore_for_file:` for generated files.** These are not
equivalent, and the difference matters.

dart.dev describes `exclude:` as excluding *files* from static analysis: "To
exclude files from static analysis, use the `exclude:` analyzer option… All
usages of glob patterns should be relative to the directory containing the
`analysis_options.yaml` file."

**Confirmed: `exclude:` suppresses everything, including real compile errors —
not just lints.** Test case: a file `lib/thing.g.dart` containing both a lint
violation and `int x = "not an int";`.

- Without `exclude`: `error - A value of type 'String' can't be assigned to a
  variable of type 'int' - invalid_assignment`, plus the lints.
- With `exclude: ["**/*.g.dart"]`: **all** of it disappears, the type error
  included.

`// ignore_for_file: type=lint` is the precise tool: dart.dev notes "To suppress
all linter rules, add a `type=lint` specifier". It kills lints only and leaves
genuine errors visible.

**This repo needs neither.** Every generated file already self-suppresses:

```
lib/core/di/dependency_injection.config.dart : // ignore_for_file: type=lint
lib/*.freezed.dart                           : // ignore_for_file: type=lint, type=warning, ...
lib/l10n/app_localizations.dart              : // ignore_for_file: type=lint
```

So adding `- "**/*.g.dart"` to `exclude:` would buy nothing and would hide
broken codegen output from `flutter analyze`. Recommendation: don't.

**`analyzer: language:` strict modes.** dart.dev definitions:

- `strict-casts` — "ensures that the type inference engine never implicitly
  casts from `dynamic` to a more specific type."
- `strict-inference` — "ensures that the type inference engine never chooses the
  `dynamic` type when it can't determine a static type."
- `strict-raw-types` — "ensures that the type inference engine never chooses the
  `dynamic` type when it can't determine a static type due to omitted type
  arguments."

All three default to `false`.

**Are they recommended by the Dart team?** Honest answer: **not explicitly.**
The dart.dev analysis page presents them as optional strictness knobs and does
not endorse them. `lints` and `flutter_lints` do not enable them. So "the Dart
team recommends strict-casts" is **[unverified]** — I found no such statement.
What *is* verifiable is that `very_good_analysis` enables all three, and that on
this specific repo `strict-casts` finds 8 real type errors that no lint rule
catches. The argument for enabling it here is evidential, not appeal-to-authority.

Measured independently on this repo (each flag alone, over the flutter_lints
baseline of 13):

| Flag | New diagnostics | Severity | Kinds |
| --- | --- | --- | --- |
| `strict-raw-types` | **0** | — | free |
| `strict-casts` | **8** | **error** | `argument_type_not_assignable` ×4, `return_of_invalid_type` ×3, `invalid_assignment` ×1 |
| `strict-inference` | 5 | warning | `inference_failure_on_function_return_type` ×2, `inference_failure_on_collection_literal` ×2, `inference_failure_on_function_invocation` ×1 |

**`// ignore:` comments.** dart.dev: "To suppress a specific non-error diagnostic
on a specific line of Dart code, put an `ignore` comment above the line" —
`// ignore: rule_name`, comma-separated for several. Note "non-error": `ignore`
comments cannot suppress compile errors, which is another reason they're the
safer tool than `exclude:`.

Source: <https://dart.dev/tools/analysis> (primary), plus direct experiment.

### Q5 — Bloc-specific (`bloc_lint` 0.4.2)

`https://bloclibrary.dev/lint/` returned HTTP 403 to automated fetching, so this
section is sourced from the **package source itself** (`bloc_lint 0.4.2` in the
pub cache) and the **documentation source in the bloc repository**
(`felangel/bloc`, `docs/src/content/docs/lint/`), both primary.

**How it runs — the important bit.** From the bloc docs: "Bloc has a built-in
linter, which can be used through your IDE or the
[`bloc command-line tools`](https://pub.dev/packages/bloc_tools) with the
`bloc lint` command." It is **not** an analyzer plugin — `dart analyze` and
`flutter analyze` do not evaluate the `bloc:` section at all. This repo's
baseline `flutter analyze` output contains no `bloc_*` diagnostics, confirming
it.

Also: "By default, the bloc linter will not report any diagnostics unless you
have explicitly configured a project's analysis options." There is no implicit
default set — rules are opt-in via `bloc: rules:` or
`include: package:bloc_lint/recommended.yaml`.

**Full rule list** (`package:bloc_lint/all.yaml`, all 9):

| Rule | Default severity | In `recommended.yaml`? | In this repo's config? |
| --- | --- | --- | --- |
| `avoid_build_context_extensions` | `warning` | No | Yes — `false` |
| `avoid_flutter_imports` | `warning` | **Yes** | Yes — `error` |
| `avoid_public_bloc_methods` | `warning` | **Yes** | Yes — `error` |
| `avoid_public_fields` | `warning` | **Yes** | Yes — `warning` |
| `prefer_bloc` | `info` | No | **Not mentioned** |
| `prefer_build_context_extensions` | `warning` | No | Yes — `false` |
| `prefer_cubit` | `info` | No | **Not mentioned** |
| `prefer_file_naming_conventions` | `info` | **Yes** | Yes — `false` |
| `prefer_void_public_cubit_methods` | `warning` | **Yes** | Yes — `info` |

Default severities read from the rule constructors, e.g.
`AvoidFlutterImports([Severity? severity]) : super(name: rule, severity: severity ?? Severity.warning)`.

**Severity options.** From the `LinterRuleState` enum: `true` (enabled at the
rule's default severity), `false` (disabled), `info`, `warning`, `error`,
`hint`. This repo uses `false` / `info` / `warning` / `error`; **`hint` is
available and unused.**

**Rules the repo's config does not mention: `prefer_bloc` and `prefer_cubit`.**
This is the correct call, and the docs say why: "lint rules don't have to agree
with each other. For example, some developers might prefer to use blocs
(`prefer_bloc`) while others might prefer to use cubits (`prefer_cubit`)." This
repo uses both (`cards.bloc.dart`, `app_preferences.cubit.dart`), so enabling
either would generate noise. Leaving both off is right — worth an inline comment
so the omission reads as deliberate rather than as an oversight.

**Current state:** `bloc lint .` reports `0 issues found. Analyzed 189 files`.
The config is correct and passing; it just isn't gated (Tier A4).

Sources: `~/.pub-cache/hosted/pub.dev/bloc_lint-0.4.2/` (primary);
`https://github.com/felangel/bloc/tree/master/docs/src/content/docs/lint/`
(primary); `https://bloclibrary.dev/lint/` (403 to automated fetch).

### Q6 — Flutter-specific quality rules

Confirmed against `flutter_lints 6.0.0` — all ten of its Flutter rules:
`avoid_print`, `avoid_unnecessary_containers`, `avoid_web_libraries_in_flutter`,
`no_logic_in_create_state`, `prefer_const_constructors_in_immutables`,
`sized_box_for_whitespace`, `sort_child_properties_last`,
`use_build_context_synchronously`, `use_full_hex_values_for_flutter_colors`,
`use_key_in_widget_constructors`.

So of the rules asked about: `use_build_context_synchronously`,
`use_key_in_widget_constructors`, `sized_box_for_whitespace` and
`avoid_unnecessary_containers` are **already on** in this repo. Nothing to do.

**`prefer_const_constructors` and friends are the interesting case.** They are
**not** in flutter_lints v6 — and, importantly, they *used to be*. The
`flutter_lints` CHANGELOG for 5.0.0 states:

> Removes the following lints (see <https://github.com/flutter/packages/issues/…>
> — tracked as dart-lang/lints#205):
> `prefer_const_constructors`, `prefer_const_declarations`,
> `prefer_const_literals_to_create_immutables`

This is a deliberate reversal by the Flutter team, so any blog post
older than flutter_lints 5.0.0 recommending them reflects the old default.
`very_good_analysis` still enables all three. I did not find the Dart/Flutter
team's full rationale in the CHANGELOG itself beyond the issue link, so the
*reason* for removal is **[unverified]** here — but the removal is confirmed by
the CHANGELOG and by their absence from `flutter.yaml`.

Practical consequence: if `const` propagation matters for this app's rebuild
behaviour — and AGENTS.md explicitly leans on it ("A `const` root view also stops
the rebuild traversal") — then `prefer_const_constructors` is worth considering
*despite* Flutter having dropped it. I left it out of Tiers A–C because it wasn't
in the measured set; it is the one rule I'd suggest measuring separately before
deciding.

The two `Container`-narrowing rules `use_colored_box` and `use_decorated_box` are
not in flutter_lints either and are free here (0 violations each) — both are in
Tier B1.

Sources: `flutter_lints-6.0.0/lib/flutter.yaml` and
`flutter_lints-6.0.0/CHANGELOG.md` (primary).

### Q7 — Community consensus *(secondary sourcing — clearly labelled)*

**This section is weaker evidence than the rest of the document.** Rule-set
membership above came from reading YAML; the popularity and preference claims
here did not, and should be treated as orientation only.

- **`flutter_lints`** *(primary-verified)* — the default from `flutter create`,
  maintained by the Flutter team in `flutter/packages`. Deliberately minimal.
- **`very_good_analysis`** *(primary-verified)* — Very Good Ventures' internal
  set, 212 rules, the main "strict" alternative. See Q3.
- **`lint` (by passsy)** — a third widely-cited set positioned between the two.
  I did **not** verify its current version, rule list, or maintenance status
  from source. **[unverified]**
- **`dart_code_metrics`** *(primary-verified)* — **discontinued.** Its pub.dev
  page carries the banner "This package has been discontinued and is no longer
  maintained." Latest version 5.7.6, roughly three years old. It did not die; it
  went commercial — the page directs users to <https://dcm.dev/pricing/>. DCM is
  now a paid product offering the metrics and custom-rule capabilities the OSS
  package used to. **Any guide recommending `dart_code_metrics` is out of date**,
  and there is no free drop-in replacement for its custom-rule engine.

The rough consensus shape — `flutter_lints` as floor, `very_good_analysis` as the
strict option, cherry-picking as the pragmatic middle — matches what the source
evidence supports, but I am asserting the *popularity* of that view from general
familiarity rather than a surveyed source. **[unverified]**

Sources: <https://pub.dev/packages/dart_code_metrics> (primary, for the
discontinuation); remainder secondary/unverified.

---

## Sources

**Primary — package source read directly from `~/.pub-cache` (highest trust)**

- `flutter_lints-6.0.0/lib/flutter.yaml`, `pubspec.yaml`, `CHANGELOG.md`
- `lints-6.1.0/lib/core.yaml`, `lib/recommended.yaml`, `pubspec.yaml`
- `bloc_lint-0.4.2/lib/all.yaml`, `lib/recommended.yaml`,
  `lib/src/rules/*.dart`, `lib/src/analysis_options.dart`, `pubspec.yaml`
- `very_good_analysis-10.3.0/lib/analysis_options.10.3.0.yaml`, `pubspec.yaml`,
  `CHANGELOG.md`

**Primary — direct experiment against Flutter 3.47.0 / Dart 3.13.0**

- `flutter analyze` / `dart analyze` runs against this repo and against scratch
  probe packages, for: include redundancy, `exclude:` semantics, strict-mode
  costs, rule deprecation/removal status, `incompatible_lint` behaviour, and all
  violation counts in this document.

**Primary — official documentation**

- <https://dart.dev/tools/analysis> — `errors:`, `exclude:`, `language:`,
  `ignore` comments, `include:` resolution order
- <https://dart.dev/tools/linter-rules> — rule index, set badges, status badges
- <https://dart.dev/tools/linter-rules/unnecessary_async> — experimental status
- <https://dart.dev/tools/linter-rules/invalid_case_patterns> — experimental status
- <https://dart.dev/tools/linter-rules/use_if_null_to_convert_nulls_to_bools> —
  deprecated status
- <https://github.com/felangel/bloc/tree/master/docs/src/content/docs/lint> —
  bloc linter overview, configuration, customizing rules
- <https://pub.dev/packages/dart_code_metrics> — discontinuation notice
- <https://pub.dev/packages/flutter_lints>, <https://pub.dev/packages/lints>,
  <https://pub.dev/packages/bloc_lint>
- <https://github.com/VeryGoodOpenSource/very_good_analysis>

**Could not be fetched**

- <https://bloclibrary.dev/lint/> — HTTP 403 to automated fetch. Substituted with
  the bloc repository's documentation source, which is the same content upstream.

**Secondary / unverified**

- Community preference and popularity claims in Q7.
- The Dart/Flutter team's *rationale* for removing the `prefer_const_*` rules in
  `flutter_lints` 5.0.0 (the removal itself is primary-verified).
- Whether the Dart team *recommends* the strict language modes — no endorsement
  found in the docs.
- `lint` (passsy) package status — not verified from source.
