# Layered Scaffold Contract

Use this reference when creating a new Project Tweety feature scaffold.

For `lib/domain/` and `lib/data/`, the repo currently groups files into nested folders by feature or entity name.
Match the current source tree even if older written docs still show flatter directories.

## Naming

- Feature names are usually plural for page-level flows: `cards`, `orders`, `profiles`
- Filenames use `feature_or_entity.role.dart`
- Use `_` inside the business name and `.` before the technical role
- Folder names under `lib/domain/` and `lib/data/` should mirror the nearest existing domain area, which may be singular even when some filenames are plural

Examples:
- `lib/domain/repositories/card/card.repository.dart`
- `lib/domain/usecases/card/get_card.usecase.dart`
- `lib/data/repositories/card/cards.repository_impl.dart`
- `lib/data/dtos/card/card.dto.dart`
- `lib/data/datasources/card/card.mock.dart`
- `cards.page.dart`
- `cards.bloc.dart`
- `cards.event.dart`
- `cards.state.dart`

Class naming:
- Page widgets should be named `<Feature>Page`, for example `CardsPage`
- BLoC, event, state, and status names should remain feature-scoped, for example `CardsBloc` and `CardsStatus`

## Domain Files

Create these files for the default minimal bootstrap scaffold:
- `lib/domain/repositories/<feature-or-entity>/<feature>.repository.dart`
- `lib/domain/usecases/<feature-or-entity>/fetch_<feature>.usecase.dart`

Defaults:
- repository contract can expose a payload-free method such as `Future<void> fetchOthers()`
- use case can mirror that same minimal bootstrap flow
- skip entities until the feature has a concrete domain payload

Add entity files or extra use cases only when the requested behavior needs them now:
- `lib/domain/entities/<entity>/<entity>.entity.dart`
- `lib/domain/usecases/<feature-or-entity>/create_<entity>.usecase.dart`
- `lib/domain/usecases/<feature-or-entity>/update_<entity>.usecase.dart`
- `lib/domain/usecases/<feature-or-entity>/delete_<entity>.usecase.dart`
- `lib/domain/usecases/<feature-or-entity>/get_<entity>.usecase.dart`

## Data Files

Default first-pass data files:
- `lib/data/repositories/<feature-or-entity>/<feature>.repository_impl.dart`

Defaults:
- do not create mock datasources or DTOs by default
- repository implementation can satisfy the bootstrap fetch with a simple successful `Future<void>`
- repository implementation is annotated as `@LazySingleton(as: ContractType)`

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
