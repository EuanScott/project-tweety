# ADR-0004: Value type conventions

Status: proposed
Date: 2026-08-07
Decision maker: Euan Scott

## Context

The repository ran two immutable-value mechanisms side by side, split by layer
rather than by need:

- `freezed` was used only for presentation state — `cards.state.dart`,
  `home_state.dart`, `app_preferences.state.dart`. No generated `*.freezed.dart`
  existed under `lib/data` or `lib/core`.
- `equatable` covered bloc events, the domain entity, and the repository value
  types `Card` and `CardDraft`.
- Storage and settings models used neither, hand-writing `copyWith`.

`lib/presentation/pages/cards/bloc/cards.bloc.dart` imported both packages.

Two concrete costs, not stylistic ones:

- **Sentinel `copyWith`.** A hand-written `copyWith` cannot distinguish "leave
  this field alone" from "set this field to null". Two files independently
  reinvented the same fix — `const Object _unset = Object();` in
  `lib/domain/entities/app_preferences/app_preferences.entity.dart` and again in
  `lib/core/storage/app_preferences.storage.dart`. `AppPreferencesCubit`
  depends on that behaviour to clear `languageCode` back to system default.
- **A union typed out by hand.** `CardsDetail` in `cards.state.dart` was a
  private constructor plus four named factories over a `CardsDetailStatus` enum
  and two nullable fields — a sealed union without the exhaustiveness. Its
  consumer in `card_details.page.dart` carried a `card == null` fallback branch
  that could not be reached, because the type could not prove `success` implies
  a non-null card.

The storage-layer `AppPreferences` additionally declared no `==` at all, so two
structurally identical instances compared unequal.

A prior backlog entry recorded the layer split as though it were a decision,
while asking openly whether avoiding `freezed` in the data layer was deliberate
or incidental. It was incidental.

Relevant constraint: Dart's static metaprogramming (macros) work was cancelled
in 2025. Build-time code generation is the durable answer for this problem, not
a placeholder to be unwound later.

## Decision

**We will use `freezed` as the single mechanism for immutable value types
across every layer**, and we will remove the `equatable` dependency. This covers
repository value types, domain entities, storage models, bloc events, and bloc
and cubit state alike.

Sealed `freezed` unions are preferred over a status enum paired with nullable
fields wherever the variants carry different data.

## Alternatives

- **Dart 3 sealed classes and pattern matching alone** — solves unions and
  nothing else. It generates no `copyWith` and no `==`, which is the majority of
  what was actually needed here. Sealed classes remain the right tool *inside*
  the chosen approach; `freezed` emits them.
- **`equatable` everywhere, dropping `freezed`** — removes `build_runner` from
  the value-type path, but reinstates the `_unset` sentinel by hand on every
  class with a nullable field, including a 20-field state class. The failure
  mode is a silently ignored `copyWith` argument, not a compile error.
- **`dart_mappable`** — a credible competitor with better polymorphic JSON, but
  the repository does not serialize through its value types. DTO mapping is
  hand-written against database rows and deliberately defensive. No gain to
  offset a migration.
- **`built_value`** — heavier, and its ecosystem momentum has gone.
- **`json_serializable` for the storage model** — rejected for now. The
  `fromStorageValue` path tolerates malformed persisted data by falling back to
  defaults; generated deserialization would throw instead. The hand-written
  parse is the behaviour we want and it is retained alongside `freezed`.

## Consequences

- One idiom. `copyWith`, `==`, `hashCode`, and `toString` come from the same
  place in every layer, and `cards.bloc.dart` no longer imports two packages to
  get them.
- Both `_unset` sentinels are deleted. `copyWith(languageCode: null)` keeps its
  existing meaning because `freezed` generates the same sentinel correctly.
- `CardsDetail` is exhaustive. `card_details.page.dart` is a `switch` over four
  variants and the unreachable null branch is gone; adding a fifth variant is
  now a compile error at the consumer rather than a silent fallthrough.
- The storage `AppPreferences` gains real value equality it never had.
- `build_runner` is now on the critical path for `lib/data` and `lib/core`, not
  just `lib/presentation`. Adding a field to a value type requires regeneration
  before the code compiles. This is the main cost.
- Generated output grows. `*.freezed.dart` files are derived artifacts and are
  never hand-edited, per `AGENTS.md`.
- The bloc scaffold templates under
  `tool/templates/feature/presentation/pages/bloc/` were updated in the same
  change. Leaving them on `equatable` would have reintroduced the split on the
  next generated feature.
- Bloc events gained the least. `sealed class ... extends Equatable` was already
  idiomatic and events never need `copyWith`; they were converted so the
  dependency could be removed rather than half-removed.
- Re-evaluate if remote DTOs arrive and need real JSON serialization, at which
  point the `json_serializable` question reopens on its own merits.

## Confirmation

The conversion is behaviour-preserving. The existing suite is the evidence: 226
tests passed before and after with no semantic test changes.

```sh
flutter pub get
dart run build_runner build
flutter analyze
flutter test
```

For later changes, these must stay empty:

```sh
grep -rn "equatable" lib test packages tool pubspec.yaml
grep -rn "_unset" lib
```

A new immutable value type in any layer uses `@freezed`. A hand-written
`copyWith` with a sentinel, or a `props` override, means this record was
bypassed or has been superseded.
