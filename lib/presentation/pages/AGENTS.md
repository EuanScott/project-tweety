# Page guidance

Read this for work under `lib/presentation/pages/`.

- Read the [page templates](../../../tool/templates/feature/presentation/pages/) for the default BLoC shape and [test references](../../../tool/templates/feature/tests/presentation/) before TDD.
- Use Cubit only for direct commands or simple local state; otherwise use BLoC with explicit events.
- Pages render app-facing values, own controller lifecycle, and keep policy below the page seam.
- Use adaptive design-system primitives for visible controls and feedback.
