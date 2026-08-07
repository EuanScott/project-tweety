# ADR-0002: Test layer conventions

Status: proposed
Date: 2026-08-07
Decision maker: Euan Scott

## Context

The repository has three top-level test directories — `test/`,
`integration_test/`, and `test_driver/` — with nothing recording why. Their
roles read as arbitrary, and the question of collapsing them into one directory
has been raised more than once.

They are not stylistic. Each is a distinct execution context enforced by Flutter
tooling. `test/` runs on the host Dart VM under `TestWidgetsFlutterBinding`.
`integration_test/` runs on a real device under
`IntegrationTestWidgetsFlutterBinding`, and must sit outside `test/` because a
bare `flutter test` globs everything under `test/` and would run
`cards_sqlite_smoke_test.dart` on the host, where it has no platform channels.
`test_driver/` holds a separate Dart program that runs on the host machine
alongside the app, which `flutter drive` needs for web and Firebase Test Lab.

The absence of a written rule also let two defects survive. Two widget test
files were named `*_widget_tests.dart` rather than `*_test.dart`, so the Dart
test runner never collected them and 958 lines of assertions went unexecuted for
their entire lifetime. Separately, `test/widget_test.dart` accumulated to 1413
lines holding every whole-app widget test plus six private fake repositories,
duplicating fakes that already existed in the Cards bloc test.

## Decision

**We will treat `test/`, `integration_test/`, and `test_driver/` as three fixed
execution contexts, name every collected test file `<name>_test.dart`, and
default to constructing a system under test directly rather than through
`GetIt`.** The layer-to-test-type mapping and the shared harness in
`test/support/` are documented in [the testing guide](../testing/README.md).

## Alternatives

- **Three directories with a written standard** (chosen): matches what Flutter's
  tooling enforces and makes the reason legible.
- **One `test/` directory**: not possible. `flutter test` would collect
  device-only tests and run them on the host.
- **Delete `test_driver/`**: nothing invokes `flutter drive` today, but the file
  is three lines and is the sole prerequisite for web integration testing.
  Keeping it costs nothing; re-deriving it later costs a documentation hunt.
- **Adopt `mockito` or `mocktail`**: rejected. Hand-written fakes consolidated
  into one configurable class give the same leverage without a code-generation
  step or a new dependency, and encourage state-based rather than
  interaction-based assertions.

## Consequences

- A misnamed test file is now a reviewable defect rather than an invisible one.
- Test fakes live in `test/support/` and are shared, so a change to the fake's
  behaviour is felt by every caller at once — which is the point, and also means
  changes there need care.
- Widget tests are distributed across files mirroring `lib/`, so the file a
  failure lands in identifies the concern.
- Re-evaluate if the app grows a second product surface, if `melos` or a
  workspace layout is adopted, or if `integration_test/` starts running in CI
  and needs its own directory conventions.

## Confirmation

`flutter test` collects every intended file — verify the reported test count
after adding a file rather than trusting a green run. `flutter analyze
--no-fatal-infos` and `flutter test` both gate CI without `continue-on-error`.
Validate this record with `dart run tool/decisions/adr.dart check`.
