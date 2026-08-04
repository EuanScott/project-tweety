# Page guidance

Read this for work under `lib/presentation/pages/`.

- Read the [page templates](../../../tool/templates/feature/presentation/pages/) for the default BLoC shape and [test references](../../../tool/templates/feature/tests/presentation/) before TDD.
- Use Cubit only for direct commands or simple local state; otherwise use BLoC with explicit events.
- Pages render app-facing values, own controller lifecycle, and keep policy below the page seam.
- Keep the route entry, controller lifecycle, and the root state-routing view in `<feature>.page.dart`; the root view is the page body, not a helper.
- Keep that root view as a separate `const` widget class, not merged into the page class: it needs a context below any page-owned `BlocProvider`, and `const` makes it a rebuild barrier when the page rebuilds on inherited-widget changes.
- Put the pure UI helpers that view composes in `<feature>/widgets/<feature>_<widget>.widget.dart` as `part` files of the page library, not as extra top-level classes in the page file. They may read state and dispatch events, but never resolve DI, reach lower layers, or hold policy. `part` files carry no imports, so add them to the page.
- Promote a widget to `lib/presentation/widgets/` or `packages/design_system` once a second page needs it.
- Use adaptive design-system primitives for visible controls and feedback.
