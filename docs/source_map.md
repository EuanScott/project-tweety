# Project Tweety Source Map

Use this map to orient cross-cutting work. For local constraints, read the
nearest `AGENTS.md`; for feature details, prefer the linked focused guide.

## Start and compose the app

- [App entrypoint](../lib/main.dart) initializes Flutter, starts the app, and owns the root `MaterialApp.router`.
- [Startup orchestration](../lib/dart_init.dart) configures dependency injection, then initializes app-level services.
- [DI source](../lib/core/di/dependency_injection.dart) owns injectable initialization; its generated config is derived output.
- [Core guidance](../lib/core/AGENTS.md) covers infrastructure boundaries, while [storage](../lib/core/storage/README.md) documents persistence lifecycle and migrations.

## Route, render, and reuse UI

- [App navigation](../lib/presentation/navigation/router.dart) owns routes, page builders, access decisions, localization, and analytics wiring.
- [Navigation guide](../lib/presentation/navigation/README.md) explains the split with the reusable [navigation package](../packages/navigation/README.md).
- [Design system](../packages/design_system/README.md) owns adaptive UI primitives, themes, and brand tokens; pages and shared widgets consume its public package API.
- [Localization sources](../lib/l10n/) are ARB files; generated localization Dart remains derived output.

## Build features and data

- [App guidance](../lib/AGENTS.md) defines the default feature path: presentation plus data, adding domain only for mobile-owned policy.
- [Data guidance](../lib/data/AGENTS.md) owns DTOs, datasources, and repository implementations; repository tests cover mapping and source coordination.
- [Domain guidance](../lib/domain/AGENTS.md) applies only when an entity or use case expresses app-owned policy.
- [Page guidance](../lib/presentation/pages/AGENTS.md) owns page/controller composition and adaptive rendering.
- [Canonical feature templates](../tool/templates/feature/) define scaffold shape; tests belong under [test](../test/) beside the affected seam's existing coverage.

## Current focused architecture

- [Cards SQLite foundation](architecture/cards_sqlite_foundation.md) records the current local persistence design.
- [Navigation testing](testing/navigation.md) records deep-link, guard, and adaptive-shell coverage.
- [Project plans](plans/) provide historical implementation context, not active architectural authority.
