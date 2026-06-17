# Layered Scaffold Contract

Use this reference when creating a new Project Tweety feature scaffold for BFF-backed layered architecture with optional domain.

For `lib/data/` and optional `lib/domain/`, the repo currently groups files into nested folders by feature or entity name.
Match the current source tree even if older written docs still show flatter directories.

## Naming

- Feature names are usually plural for page-level flows
- Filenames use `feature_or_entity.role.dart`
- Use `_` inside the business name and `.` before the technical role
- Folder names under `lib/data/` and optional `lib/domain/` should mirror the nearest existing feature or entity area

Examples:
- `lib/data/repositories/<feature>/<feature>.repository.dart`
- `lib/data/repositories/<feature>/<feature>.repository_impl.dart`
- `lib/data/dtos/<entity>/<entity>.dto.dart`
- `lib/data/datasources/<feature>/<source>_<feature>.datasource.dart`
- `<feature>.page.dart`
- `<feature>.bloc.dart`
- `<feature>.event.dart`
- `<feature>.state.dart`

Class naming:
- Page widgets should be named `<Feature>Page`
- BLoC, event, state, and status names should remain feature-scoped

## Optional Domain Files

Do not create domain files for the default minimal bootstrap scaffold.
Assume the BFF handles mobile-specific shaping and common business logic.
Create domain only when mobile-owned behavior justifies it.

When domain is justified, create:
- `lib/domain/repositories/<feature-or-entity>/<feature>.repository.dart`
- `lib/domain/usecases/<feature-or-entity>/fetch_<feature>.usecase.dart`

Defaults:
- repository contract can expose a payload-free method such as `Future<void> fetchOthers()`
- use case can mirror that same minimal bootstrap flow
- skip entities until the feature has a concrete domain payload

If a `curl` request is supplied:
- prefer a concrete repository operation over a payload-free bootstrap method
- create a domain entity when the request/response shape justifies one

Add entity files or extra use cases only when the requested behavior needs them now:
- `lib/domain/entities/<entity>/<entity>.entity.dart`
- `lib/domain/usecases/<feature-or-entity>/create_<entity>.usecase.dart`
- `lib/domain/usecases/<feature-or-entity>/update_<entity>.usecase.dart`
- `lib/domain/usecases/<feature-or-entity>/delete_<entity>.usecase.dart`
- `lib/domain/usecases/<feature-or-entity>/get_<entity>.usecase.dart`

## Data Files

Default first-pass data files:
- `lib/data/repositories/<feature-or-entity>/<feature>.repository.dart`
- `lib/data/repositories/<feature-or-entity>/<feature>.repository_impl.dart`

Defaults:
- do not create mock datasources or DTOs by default
- repository implementation can satisfy the bootstrap fetch with a simple successful `Future<void>`
- repository implementation is annotated as `@LazySingleton(as: ContractType)`
- the BLoC may depend directly on the data-layer repository contract when no domain layer exists

If a `curl` request is supplied:
- create a datasource by default
- use the request method, URL, headers, query params, and request body as the transport source of truth
- create DTOs when the request body or sample response has a real structure

Add these only when the feature has a real data shape:
- `lib/data/datasources/<feature-or-entity>/<source>.datasource.dart`
- `lib/data/dtos/<entity>/<entity>.dto.dart`

## Presentation Files

Default page files:
- `lib/presentation/pages/<feature>/<feature>.page.dart`
- `lib/presentation/pages/<feature>/bloc/<feature>.bloc.dart`
- `lib/presentation/pages/<feature>/bloc/<feature>.event.dart`
- `lib/presentation/pages/<feature>/bloc/<feature>.state.dart`

Defaults:
- page owns the BLoC with `BlocProvider(create: ...)`
- BLoC is resolved with `GetIt.I<FeatureBloc>()`
- bootstrap event is `<Feature>Started`
- state uses a feature-scoped enum with `initial`, `loading`, `success`, `failure`
- state is a single Freezed type with no payload fields by default
- page app bar stays minimal with just the title
- page success UI is `Center(child: Text('<feature>'))`
- do not scaffold list views or item cards in the default first pass

## Out of Scope

Do not use this scaffold contract for:
- `lib/features/*` experiments
- `packages/design_system`
- app-wide navigation wiring unless explicitly requested
- localization work unless explicitly requested

## Post-Scaffold Checks

Run these only when the corresponding inputs changed:
- `dart run build_runner build --delete-conflicting-outputs` after Freezed or Injectable changes
- `flutter gen-l10n` after ARB changes

Prefer targeted tests over broad validation when tests are added as part of the scaffold task.
