# Data Layer

The data layer retrieves, coordinates, and shapes external or persisted data
for the rest of the app.

## Typical flows

Without mobile-owned domain policy:

```text
DataSource -> DTO -> Repository -> Repository value -> BLoC/Cubit
```

With justified domain policy:

```text
DataSource -> DTO -> RepositoryImpl -> Domain entity -> Use case -> BLoC/Cubit
```

## Canonical guidance

- Implementation rules: [AGENTS.md](AGENTS.md)
- Repository baseline: [repositories/_template](repositories/_template/)
- Data-only scaffolding: `$data-scaffold`

DTOs stay inside data. Repositories return app-facing values or implement a
domain contract when domain is justified. Older features may use legacy names;
new work follows the scoped guidance.
