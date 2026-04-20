# Page Scaffold Contract

Use this reference when creating only the presentation layer for a Project Tweety feature.

## Prerequisites

Verify an existing dependency target before scaffolding the page:
- preferably a use case under `lib/domain/usecases/`
- or another already-existing dependency that the BLoC should consume

Do not silently invent lower-layer behavior if the dependency is missing.

## Default Paths

- page: `lib/presentation/pages/<feature>/<feature>.page.dart`
- bloc: `lib/presentation/pages/<feature>/bloc/<feature>.bloc.dart`
- event: `lib/presentation/pages/<feature>/bloc/<feature>.event.dart`
- state: `lib/presentation/pages/<feature>/bloc/<feature>.state.dart`

## Defaults

- page widget name: `<Feature>Page`
- app bar stays minimal with title only
- BLoC is resolved with `GetIt.I<FeatureBloc>()`
- bootstrap event is `<Feature>Started`
- state uses `initial`, `loading`, `success`, `failure`
- default success UI is `Center(child: Text('<feature>'))`
- do not generate list cards or placeholder data views by default

## Out of Scope

- `lib/domain/*`
- `lib/data/*`
- navigation and localization updates unless explicitly requested
