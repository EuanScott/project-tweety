# Page guidance

Read this for work under `lib/presentation/pages/`.

- Read the [page templates](../../../tool/templates/feature/presentation/pages/) for the default BLoC shape and [test references](../../../tool/templates/feature/tests/presentation/) before TDD.
- Use Cubit only for direct commands or simple local state; otherwise use BLoC with explicit events.
- Pages render app-facing values, own controller lifecycle, and keep policy below the page seam.
- Keep the route entry, `GetIt.I` resolution, provider lifecycle, and the root state-routing view in `<feature>.page.dart`; the root view is the page's body, not a helper — extracting it leaves a file that no longer shows what the route renders.
- Keep that root view as its own `const` widget class rather than merging it into the page class. It needs a `BuildContext` below any page-owned `BlocProvider`, or `context.read`/`context.watch` in the page's own `build` resolves above the provider and throws at callback time; `BlocBuilder` and `BlocListener` passed as a direct `child:` are exempt because they resolve from their own element. A `const` root view also stops the rebuild traversal when the page rebuilds on an inherited-widget dependency such as `AppLocalizations.of(context)`.
- Put the pure UI helpers that view composes in `<feature>/widgets/<feature>_<widget>.widget.dart` as `part` files of the page library (`part of '../<feature>.page.dart';`), not as extra top-level classes in the page file. They may read state and dispatch events, but never resolve DI, reach lower layers, or hold policy.
- `part` files cannot declare imports: every import a page-local widget needs belongs in the `.page.dart` file.
- Promote a widget to `lib/presentation/widgets/` or `packages/design_system` once a second page needs it.
- Use adaptive design-system primitives for visible controls and feedback.
