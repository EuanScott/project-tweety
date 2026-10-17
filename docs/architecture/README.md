# Architecture Overview

This document provides a high-level overview of the architectural patterns, design decisions, and structural conventions
used throughout Project Tweety. It serves as a reference for developers working on or reviewing the codebase.

For detailed rationale behind specific decisions, see
the [Architecture Decision Records (ADRs)](../decisions/README.md).

## Table of Contents

- [Layered Architecture](#layered-architecture)
- [Dependency Injection](#dependency-injection)
- [Repository Pattern](#repository-pattern)
- [State Management (BLoC/Cubit)](#state-management-bloccubit)
- [Facade Pattern](#facade-pattern)
- [DTO Pattern and Mapping](#dto-pattern-and-mapping)
- [Value Types](#value-types)
- [Navigation and Routing](#navigation-and-routing)
- [Storage](#storage)
- [Feature Flags](#feature-flags)
- [Testing Architecture](#testing-architecture)
- [File and Directory Conventions](#file-and-directory-conventions)

---

## Layered Architecture

The application follows a **Clean Architecture** variant with strictly separated layers. Dependencies flow inward only:
**Presentation → Data → Domain**. Inner layers have no knowledge of outer layers.

| Layer            | Responsibility                                                                        | Directory           |
|------------------|---------------------------------------------------------------------------------------|---------------------|
| **Domain**       | Business logic, entities, repository interfaces, use cases                            | `lib/domain/`       |
| **Data**         | Data sources, repository implementations, DTOs, services                              | `lib/data/`         |
| **Core**         | Cross-cutting concerns: DI, analytics, error reporting, storage, networking, platform | `lib/core/`         |
| **Presentation** | UI components, BLoC/Cubit, widgets, routing                                           | `lib/presentation/` |

### Domain Layer (`lib/domain/`)

- Contains **business entities** (e.g., `LogEntry`, `AppPreferences`)
- Defines **repository interfaces** (e.g., `LogsRepository`, `AppPreferencesRepository`)
- Houses **domain-specific value types** (e.g., `LogEntryDraft`)
- No dependencies on Flutter, data sources, or external packages

### Data Layer (`lib/data/`)

- Implements **repository interfaces** from the domain layer
- Manages **data sources** (local SQLite, mock, future remote)
- Handles **DTOs** (Data Transfer Objects) and mapping to/from domain entities
- Contains **services** (e.g., `LogEntryIdGenerator`)

### Core Layer (`lib/core/`)

Cross-cutting concerns that span the application:

| Subdirectory       | Purpose                                                 |
|--------------------|---------------------------------------------------------|
| `analytics/`       | Analytics tracking facade and services                  |
| `di/`              | Dependency injection configuration                      |
| `error_reporting/` | Error reporting facade and services                     |
| `feature_flags/`   | Feature flag service and keys                           |
| `networking/`      | HTTP services and clients                               |
| `platform/`        | Platform-specific services (orientation, text settings) |
| `storage/`         | Database and preferences storage                        |

### Presentation Layer (`lib/presentation/`)

- **Pages**: Screen-level widgets
- **Widgets**: Reusable UI components
- **BLoC/Cubit**: State management
- **Navigation**: Routing configuration, routes, policies
- **Extensions**: Flutter widget extensions

---

## Dependency Injection

The application uses **`get_it`** as the service locator and **`injectable`** for compile-time DI configuration.

### Configuration

- **Entry point**: `lib/core/di/dependency_injection.dart`
- **Generated config**: `lib/core/di/dependency_injection.config.dart` (auto-generated, do not edit)
- **Initialization**: Called via `dartInit()` in `lib/dart_init.dart`

### Usage Patterns

| Annotation                      | Lifetime                        | Use Case                                        |
|---------------------------------|---------------------------------|-------------------------------------------------|
| `@LazySingleton(as: Interface)` | Singleton, lazy initialization  | Services, repositories, data sources            |
| `@singleton`                    | Singleton, eager initialization | Configuration, constants                        |
| `@factory`                      | New instance per call           | BLoCs, Cubits (stateful, scoped to widget tree) |
| `@injectable`                   | Default (same as `@factory`)    | Classes that should be injected                 |

### Modules

Group related services using injectable modules:

```dart
@module
abstract class AnalyticsModule {
  @lazySingleton
  Iterable<AnalyticsService> analyticsServices(
    AnalyticsService firebaseAnalytics,
  ) => <AnalyticsService>[firebaseAnalytics];
}
```

### Testing

For tests, prefer **constructing subjects directly** rather than using `GetIt`. The shared test harness
(`test/support/`) provides fake implementations for whole-app widget tests.

---

## Repository Pattern

The repository pattern abstracts data access, providing a clean seam for testing and source switching.

### Structure

```
Domain Layer
├── lib/domain/repositories/logEntry/logs.repository.dart    # Abstract interface

Data Layer
├── lib/data/repositories/logEntry/logs.repository_impl.dart # Concrete implementation
└── lib/data/datasources/logEntry/                            # Data source contracts & impls
    ├── logs.datasource.dart                             # Abstract contract
    ├── logs_local.datasource.dart                       # SQLite implementation
    └── logs_mock.datasource.dart                        # Mock implementation
```

### Contract Example

```dart
// Domain: Abstract interface
abstract class LogsRepository {
  Future<List<LogEntry>> getLogs();
  Future<LogEntry?> getLogEntryById(String logEntryId);
  Future<LogEntry> createLogEntry(LogEntryDraft draft);
  Future<LogEntry> updateLogEntry({required String logEntryId, required LogEntryDraft draft});
  Future<void> deleteLogEntry(String logEntryId);
}

// Data: Concrete implementation
@LazySingleton(as: LogsRepository)
class LogsRepositoryImpl implements LogsRepository {
  LogsRepositoryImpl(this._dataSource, this._logEntryIdGenerator);
  
  final LogsDataSource _dataSource;
  final LogEntryIdGenerator _logEntryIdGenerator;
  
  // Implementations...
}
```

### Key Principles

- **Data Source is the Seam**: `LogsDataSource` is the abstraction point for switching between local SQLite, mock, or
  future remote implementations
- **Validation at Repository**: Business rule validation (e.g., `InvalidLogEntryDraftException`) happens in the repository
  implementation
- **Mapping at Boundaries**: Repository implementations map between DTOs and domain entities

---

## State Management (BLoC/Cubit)

State management uses the **BLoC pattern** via the `bloc` and `flutter_bloc` packages.

### When to Use Each

| Pattern   | Use Case                                                           | Location                                  |
|-----------|--------------------------------------------------------------------|-------------------------------------------|
| **BLoC**  | Complex state with multiple events, async operations, side effects | `lib/presentation/pages/<feature>/bloc/`  |
| **Cubit** | Simpler state with direct state mutations                          | `lib/presentation/pages/<feature>/cubit/` |

### BLoC Structure

```dart
// Events (sealed class via freezed)
part 'logs.event.dart';

// State (sealed class via freezed)
part 'logs.state.dart';

@injectable
class LogsBloc extends Bloc<LogsEvent, LogsState> {
  LogsBloc(this._logsRepository) : super(const LogsState()) {
    on<LogsStarted>(_onStarted);
    on<LogsCreateStarted>(_onCreateStarted);
    on<LogsDraftChanged>(_onDraftChanged);
    on<LogsCreateSubmitted>(_onCreateSubmitted);
    // ... event handlers
  }

  final LogsRepository _logsRepository;

// Event handlers...
}
```

### State Design

- **Immutable**: All state classes use `freezed`
- **Exhaustive**: Sealed unions for different state variants
- **Copy-based updates**: Use `copyWith` for state transitions

### Event Design

- **Fine-grained**: One event type per distinct user action
- **Immutable**: Events are data classes, never mutated
- **Sealed**: Use sealed classes for type-safe handling

### Integration with UI

```dart
// In widget tree
MultiBlocProvider(
  providers: [
    BlocProvider(
      create: (_) => GetIt.I<LogsBloc>()..add(const LogsStarted()),
    ),
  ],
  child: BlocBuilder<LogsBloc, LogsState>(
    builder: (context, state) {
      // Build UI based on state
    },
  ),
)
```

---

## Facade Pattern

The facade pattern is used for cross-cutting services that delegate to multiple underlying implementations. This
provides a **single, stable interface** while allowing flexibility in the implementations.

### Analytics Facade

```dart
@lazySingleton
class AnalyticsFacade {
  AnalyticsFacade(this._services);
  
  final Iterable<AnalyticsService> _services;
  
  Future<void> trackEvent(String name, Map<String, Object?>? params) async {
    for (final s in _services) {
      try {
        await s.trackEvent(name, params);
      } catch (_) {}
    }
  }
  
  Future<void> logScreenView({required String screenName, String? screenClass}) async {
    for (final s in _services) {
      try {
        await s.logScreenView(screenName, screenClass);
      } catch (_) {}
    }
  }
}
```

### Error Reporting Facade

```dart
@lazySingleton
class ErrorReportingFacade {
  ErrorReportingFacade(this._services);
  
  final List<ErrorReportingService> _services;
  
  Future<void> recordError(Object error, StackTrace? stackTrace, {
    Map<String, Object?>? metadata,
    bool fatal = false,
  }) async {
    await Future.wait(
      _services.map((s) async {
        try {
          await s.recordError(error, stackTrace, metadata: metadata, fatal: fatal);
        } catch (_) {}
      }),
    );
  }
}
```

### Key Characteristics

- **Fail-safe**: Errors in one service don't prevent others from executing
- **Concurrent**: Uses `Future.wait` for parallel execution
- **Extensible**: New services can be added via DI without changing facade code
- **Named registrations**: Services registered with names (e.g., `'crashlytics'`, `'coralogix'`)

---

## DTO Pattern and Mapping

Data Transfer Objects (DTOs) handle serialization and database persistence, while domain entities represent business
concepts.

### Structure

```
Data Layer (DTOs)
└── lib/data/dtos/logEntry/logEntry.dto.dart    # Database representation

Domain Layer (Entities)
└── lib/data/repositories/logEntry/logs.repository.dart  # Contains LogEntry entity
```

### DTO Example

```dart
class LogEntryDto {
  const LogEntryDto({
    required this.id,
    required this.title,
    required this.description,
    this.syncStatus = LogEntrySyncStatus.synced,
    this.updatedAt,
    this.lastSyncedAt,
    this.deletedAt,
  });
  
  final String id;
  final String title;
  final String description;
  final LogEntrySyncStatus syncStatus;
  final DateTime? updatedAt;
  final DateTime? lastSyncedAt;
  final DateTime? deletedAt;
  
  // To database row
  Map<String, Object?> toDatabaseRow() { ... }
  
  // From database row
  factory LogEntryDto.fromDatabaseRow(Map<String, Object?> row) { ... }
  
  // To domain entity
  LogEntry toValue() {
    return LogEntry(id: id, title: title, description: description);
  }
}
```

### Domain Entity Example

```dart
@freezed
abstract class LogEntry with _$LogEntry {
  const factory LogEntry({
    required String id,
    required String title,
    required String description,
  }) = _LogEntry;
}
```

### Mapping Flow

```
Database Row → LogEntryDto.fromDatabaseRow() → LogEntryDto → LogEntryDto.toValue() → LogEntry (Domain Entity)
LogEntry (Domain Entity) + LogEntryDraft → LogEntryDto (via repository) → Database Row
```

---

## Value Types

**ADR-0004** establishes `freezed` as the single mechanism for immutable value types across all layers.

### Why Freezed?

- Generates `copyWith`, `==`, `hashCode`, `toString`
- Supports sealed unions for exhaustive state handling
- Provides consistent behavior across all layers
- Eliminates hand-written sentinel values for nullable fields

### Usage Across Layers

| Layer        | Value Types             | Example                        |
|--------------|-------------------------|--------------------------------|
| Domain       | Entities                | `LogEntry`, `AppPreferences`       |
| Data         | DTOs, Repository types  | `LogEntryDto`, `LogEntryDraft`         |
| Presentation | BLoC state, events      | `LogsState`, `LogsEvent`     |
| Core         | Configuration, settings | `AppPreferencesStorage` models |

### Sealed Unions

Prefer sealed unions over status enums with nullable fields:

```dart
// Preferred: Sealed union
@freezed
abstract class LogsDetail with _$LogsDetail {
  const factory LogsDetail.loading() = _Loading;
  const factory LogsDetail.success(LogEntry logEntry) = _Success;
  const factory LogsDetail.notFound(String logEntryId) = _NotFound;
  const factory LogsDetail.failure(Object error) = _Failure;
}

// Avoid: Status enum with nullable fields
// class LogsDetail {
//   final LogsDetailStatus status;
//   final LogEntry? logEntry;  // Can be null, but success implies non-null
// }
```

---

## Navigation and Routing

Navigation uses **`go_router`** with a custom **`navigation`** package for tab-based routing.

### Structure

```
lib/presentation/navigation/
├── app.router.dart              # Main router configuration
├── app_routes.constants.dart    # Route paths and names
├── route_access.policy.dart     # Route guard policies
├── tabs/                        # Tab configuration
│   ├── app_tab.model.dart
│   └── app_tab_configs.constants.dart
└── analytics/                   # Navigation analytics
    ├── navigation_analytics.observer.dart
    └── navigation_analytics_tracker.service.dart
```

### Router Configuration

```dart
GoRouter createRouter({
  String initialLocation = AppRoutes.rootPath,
  AnalyticsFacade? analyticsFacade,
  bool canAccessSettings = true,
}) {
  final analyticsTracker = analyticsFacade == null
    ? null
    : NavigationAnalyticsTracker(analyticsFacade);
  final routeAccessPolicy = RouteAccessPolicy(
    canAccessSettings: canAccessSettings,
  );
  
  return createNavigationRouter<AppTab>(
    initialLocation: initialLocation,
    rootPath: AppRoutes.rootPath,
    rootRedirectPath: AppRoutes.homePath,
    tabs: appTabConfigs,
    branches: [
      // Home branch
      // Logs branch (with ShellRoute for split-pane layouts)
      // Settings branch
    ],
    observers: _navigationObservers(analyticsTracker),
    onTabRouteSelected: analyticsTracker?.trackScreenName,
  );
}
```

### Key Features

- **Tab-based navigation**: Uses `NavigationBranch<AppTab>` for each tab
- **Shell routes**: For shared UI (e.g., `PaneLayoutScope` for the Logs split-pane)
- **Route guards**: `RouteAccessPolicy` controls access to settings routes
- **Analytics**: Automatic screen view tracking via observers
- **Error handling**: Custom error pages with recovery actions

### Route Access Policy

```dart
class RouteAccessPolicy {
  RouteAccessPolicy({required this.canAccessSettings});
  
  final bool canAccessSettings;
  
  SettingsAccessDecision settingsAccessDecision() {
    if (canAccessSettings) {
      return SettingsAccessDecision.allowed();
    }
    return SettingsAccessDecision.denied(
      redirectPath: AppRoutes.accessDeniedPath,
    );
  }
}
```

---

## Storage

**ADR-0007** establishes local SQLite as the source of truth for log entries.

### Architecture

```
AppDatabase (Sqflite lifecycle)
└── LogsLocalDataSource (CRUD operations)
    └── LogsRepositoryImpl (business logic)
        └── LogsBloc (state management)
```

### Database Layer

- **`AppDatabase`**: Interface for database lifecycle and transactions
- **`SqfliteAppDatabase`**: Production implementation using `sqflite`
- **Migrations**: Versioned schema changes with seeding

### Sync Scaffolding

The database includes synchronization support even though Firestore sync is not yet implemented:

- **`LogEntrySyncStatus` enum**: `synced`, `created`, `updated`, `deleted`
- **Tombstone records**: Deleted log entries hidden from normal reads, preserved for sync
- **`getUnsyncedLogs()`**: Returns log entries awaiting synchronization
- **`markLogsSynced()`**: Acknowledges successful uploads

### Lifecycle Guarantees

- Concurrent callers share a pending database open
- Callers can retry after an open failure
- Writes commit atomically or roll back
- Close drains active callbacks; later callers reopen cleanly
- Downgrade attempts fail without modifying the database
- Close and reopen preserve log entries and their pending lifecycle state

### Testing

- Native process-relaunch smoke test verifies persistence across actual Android/iOS process restart
- Run with: `flutter test integration_test/logs_sqlite_smoke.flow_test.dart -d <device-id>`

---

## Feature Flags

Feature flags are managed via `FeatureFlagService`, currently a dormant stub awaiting Firebase Remote Config
integration.

### Structure

```dart
@injectable
class FeatureFlagService {
  // Future: Firebase Remote Config integration
  // Future<void> initialize() async { ... }
  // bool isFeatureEnabled() => _remoteConfig.getBool(...);
}
```

### Keys

Defined in `lib/core/feature_flags/feature_flag_keys.constants.dart`:

```dart
class FeatureFlagKeys {
  static const String isFeatureEnabled = 'is_feature_enabled';
}
```

---

## Testing Architecture

**ADR-0002** documents the testing conventions and directory structure.

### Test Directories

| Directory           | Execution Context               | Binding                                | Purpose                  |
|---------------------|---------------------------------|----------------------------------------|--------------------------|
| `test/`             | Host Dart VM, headless          | `TestWidgetsFlutterBinding`            | Unit tests, widget tests |
| `integration_test/` | Real device/emulator            | `IntegrationTestWidgetsFlutterBinding` | Device-only tests        |
| `test_driver/`      | Host machine (separate process) | None                                   | Integration test driver  |

### Shared Test Harness

Located in `test/support/`:

| File                                               | Purpose                                                                                       |
|----------------------------------------------------|-----------------------------------------------------------------------------------------------|
| `app_harness.dart`                                 | `useAppHarness()` for setup/teardown, `pumpApp()` for rendering `MyApp`, `currentRoutePath()` |
| `fake_logs_repository.dart`                       | Configurable `FakeLogsRepository` with error injection and call counting                     |
| `fake_app_preferences_repository.dart`             | `FakeAppPreferencesRepository` recording saves                                                |
| `in_memory_shared_preferences_async_platform.dart` | Platform fake for shared preferences                                                          |

### Typical Whole-App Test

```dart
void main() {
  group('Logs editor', () {
    useAppHarness();

    testWidgets('creates a log entry from the compact editor route', (tester) async {
      replaceLogsRepository(FakeLogsRepository(logs: const []));
      await pumpApp(tester, initialLocation: '${AppRoutes.logsPath}/new');
      // ... assertions
    });
  });
}
```

### Test Preferences

- **Default to constructing subjects directly** rather than through `GetIt`
- **Name files**: `<name>_test.dart` (singular; `_tests.dart` is silently skipped)
- **Role infix**: Mirror `lib/` convention (e.g., `logs.repository_impl_test.dart`)

---

## File and Directory Conventions

### Naming Conventions

- **Dart files**: `lowercase_with_underscores.dart`
- **Test files**: `<name>_test.dart` (exactly; plural forms are not collected)
- **Role infix**: Use dot-role for meaningful roles (e.g., `logs.bloc.dart`, `app_preferences.cubit.dart`)
- **Freezed files**: `*.freezed.dart` for generated code (never hand-edited)

### Directory Structure

```
lib/
├── core/                  # Cross-cutting concerns
│   ├── analytics/
│   ├── di/
│   ├── error_reporting/
│   ├── feature_flags/
│   ├── networking/
│   ├── platform/
│   └── storage/
├── data/                  # Data layer
│   ├── constants/
│   ├── datasources/
│   │   └── logEntry/
│   ├── dtos/
│   │   └── logEntry/
│   ├── repositories/
│   │   └── logEntry/
│   └── services/
│       └── logEntry/
├── domain/                # Domain layer
│   ├── entities/
│   │   └── app_preferences/
│   └── repositories/
│       └── app_preferences/
├── l10n/                  # Localization
├── presentation/          # Presentation layer
│   ├── extensions/
│   ├── navigation/
│   │   ├── analytics/
│   │   └── tabs/
│   └── pages/
│       ├── access_denied/
│       ├── app_preferences/
│       │   └── cubit/
│       ├── logs/
│       │   ├── bloc/
│       │   ├── log_entry_details/
│       │   │   └── widgets/
│       │   └── widgets/
│       ├── home/
│       │   ├── bloc/
│       │   └── widgets/
│       └── settings/
└── gen/                   # Generated code (ignored)
```

### Freezed Convention

All immutable value types use `@freezed` with part directives:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_preferences.entity.freezed.dart';

@freezed
abstract class AppPreferences with _$AppPreferences {
  const factory AppPreferences({ ... }) = _AppPreferences;
}
```

The generated `*.freezed.dart` files are **never hand-edited** (per `AGENTS.md`).

---

## Related Documentation

- [Testing Guide](../testing/README.md) — Test organization and conventions
- [Logs SQLite Foundation](./logs_sqlite_foundation.md) — log entry persistence details
- [Navigation Guide](../testing/navigation.md) — Deep links and route guards
- [ADR Index](../decisions/README.md) — Architecture Decision Records
