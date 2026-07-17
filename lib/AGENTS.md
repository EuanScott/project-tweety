# App feature guidance

Read this only for work under `lib/`.

- For a new BFF-backed feature, read the relevant scoped guidance and the [production templates](../tool/templates/feature/).
- For TDD examples, read the [test references](../tool/templates/feature/tests/); adapt them to real behaviour rather than copying placeholders.
- Default to data plus presentation. Add domain only for mobile-owned policy, orchestration, or stateful app concepts.
- Feature names describe business intent; filenames use `feature_or_entity.role.dart`.
- Regenerate outputs only after changing their source annotations or ARB inputs.
