# Testing

How tests are organised in this repository, and which kind to reach for.

The durable rationale is recorded in
[ADR-0002](../decisions/0002-test-layer-conventions.md).

## The three directories

They cannot be merged. Each is a different execution context, enforced by
Flutter tooling rather than by convention.

| Directory | Runs where | Runner | Binding |
|---|---|---|---|
| `test/` | Host Dart VM, headless, no device | `flutter test` | `TestWidgetsFlutterBinding` |
| `integration_test/` | A real device, emulator, or browser | `flutter test integration_test -d <device>` | `IntegrationTestWidgetsFlutterBinding` |
| `test_driver/` | The host machine, in a **separate process**, alongside the running app | `flutter drive --driver=…` | none — a plain Dart program |

`integration_test/` must sit outside `test/` because a bare `flutter test` globs
everything under `test/` and runs it on the host VM. `cards_sqlite_smoke_test.dart`
needs a real device and real platform channels; inside `test/` it would be
collected by every CI run and fail.

`test_driver/integration_test.dart` is not setup, and not a test. It is a second
Dart program that runs on your machine and talks to the app running on the
device. Two processes means two entrypoints, so two directories. Its entire
content is:

```dart
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
```

It is the modern `integration_test` shim, not the legacy `flutter_driver` style.
You only need it for `flutter drive`, which is required for web (ChromeDriver
coordination), Firebase Test Lab on iOS, and driver-side screenshot capture.
Nothing in this repository does any of those today, so the file is dormant —
kept because it is three lines and is the sole prerequisite for web integration
testing.

## Naming

Every collected test file ends `_test.dart`, singular. The Dart test runner
globs exactly that; a file named `_tests.dart` is silently skipped and its
assertions never run.

The dot-role infix mirrors the `lib/` `feature_or_entity.role.dart` convention
from [AGENTS.md](../../AGENTS.md) and is preferred where a role is meaningful:

```text
app_database.storage_test.dart
cards_local.datasource_test.dart
cards.repository_impl_test.dart
cards.bloc_test.dart
app_modal.widget_test.dart
```

Plain `<name>_test.dart` is fine where no role applies.

## Which test for which layer

| What you are changing | What to write | Where |
|---|---|---|
| `lib/data/datasources/**`, `lib/data/repositories/**`, `lib/core/**` | Plain `test()`, construct the subject directly | `test/` mirroring `lib/` |
| `lib/presentation/pages/**/bloc/**` | `blocTest` from `bloc_test`, fake repository passed to the constructor | `test/presentation/pages/<feature>/bloc/` |
| A page, a shared widget, or a `packages/design_system` primitive | `testWidgets` | `test/presentation/**` or the package's own `test/` |
| Whole-app routing, deep links, locale, preferences | `testWidgets` against `MyApp` via `pumpApp` | `test/presentation/**` |
| Real SQLite on a real device, or persistence across a process relaunch | `testWidgets` with the integration binding | `integration_test/` |

Note that a test named `*_integration_test.dart` under `test/` is not a device
test — `test/core/storage/app_database_migration_integration_test.dart` runs on
the host through `sqflite_common_ffi`.

## Dependency injection

**Default to constructing the subject directly.** Most tests in this repository
do, and it is the healthier pattern — the dependency is visible in the test, and
there is no global container to reset.

```dart
final bloc = CardsBloc(FakeCardsRepository(cards: const [card]));
```

Reach for the real container only when the test drives `MyApp`, which resolves
its own dependencies from `GetIt`. In that case use the shared harness rather
than open-coding the reset cycle.

## The shared harness

`test/support/` holds the fixtures used by whole-app widget tests.

- `app_harness.dart` — `useAppHarness()` registers the `setUp`/`tearDown` pair
  (in-memory shared preferences, the system-text-settings channel stub, a real
  DI container with a working cards fake). `pumpApp(tester, …)` renders `MyApp`
  at a chosen surface size, locale, platform, and brightness.
  `currentRoutePath(tester)` reads the active `go_router` location.
- `fake_cards_repository.dart` — one configurable `FakeCardsRepository` backed by
  a mutable list. Pass `readError`, `createError`, `updateError`, or
  `deleteError` to make a single operation fail; read `collectionReadCount`,
  `createRequestCount`, and friends to assert call counts.
  `FakeCardsRepository.collectionOnly(loader)` treats any detail read as a
  failure, for tests asserting that details derive from the loaded collection.
  `FakeCardsRepository.gated()` leaves writes pending until the test completes
  them, for asserting in-flight state.
- `fake_app_preferences_repository.dart` — `FakeAppPreferencesRepository`, which
  records every save in `savedPreferences`.
- `in_memory_shared_preferences_async_platform.dart` — the platform fake behind
  `useAppHarness()`.

A typical whole-app test:

```dart
void main() {
  group('Cards editor', () {
    useAppHarness();

    testWidgets('creates a card from the compact editor route', (tester) async {
      replaceCardsRepository(FakeCardsRepository(cards: const []));

      await pumpApp(tester, initialLocation: '${AppRoutes.cardsPath}/new');
      // …
    });
  });
}
```

Prefer adding a parameter to `FakeCardsRepository` over writing a new fake
class. The five variants it replaced were each a one-method override, and they
had already been duplicated across two files.

## Commands

The local validation loop, matching CI exactly:

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze --no-fatal-infos
dart run tool/agent_context/validate.dart
flutter test
```

One file:

```sh
flutter test test/presentation/pages/cards/cards_editor_test.dart
```

One test by name:

```sh
flutter test test/presentation/navigation/app_shell_test.dart \
  --plain-name "explains denied settings deep links"
```

Coverage — CI collects this on every run and uploads `coverage/lcov.info` as a
build artifact. There is no threshold gate yet:

```sh
flutter test --coverage
```

On a device, which CI does not do:

```sh
flutter test integration_test/cards_sqlite_smoke_test.dart -d <device-id>
```

Through the driver, for web:

```sh
chromedriver --port=4444
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/cards_sqlite_smoke_test.dart \
  -d chrome
```

## Related guides

- [Navigation, deep links, and route guards](navigation.md)
- [Cards SQLite persistence and native smoke testing](../architecture/cards_sqlite_foundation.md)
