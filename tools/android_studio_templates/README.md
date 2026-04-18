# Android Studio Feature Helpers

These script-backed helpers generate the boilerplate for new feature layers in this repo.

## Available Helpers

- `presentation/generate_presentation_feature.sh`
- `domain/generate_domain_feature.sh`
- `data/generate_data_feature.sh`

## Recommended Order

For a brand new feature, generate in this order:

1. `domain`
2. `data`
3. `presentation`

`data` depends on the `domain` entity and repository contract already existing. `presentation`
depends on the `domain` entity and use case already existing.

All three helpers read the package name from `pubspec.yaml`, so generated imports match the current
project automatically.

## Naming Convention

These helpers are intended to follow the repo-wide filename pattern `feature_or_entity.role.dart`.

- use `_` inside the business name
- use `.` before the technical role

Example naming:

- domain
  - `card.entity.dart`
  - `cards.repository.dart`
  - `get_cards.usecase.dart`
  - `create_card.usecase.dart`
  - `update_card.usecase.dart`
  - `delete_card.usecase.dart`
- data
  - `card.dto.dart`
  - `mock_cards.datasource.dart`
  - `cards.repository_impl.dart`
- presentation
  - `cards.page.dart`
  - `cards.bloc.dart`
  - `cards.event.dart`
  - `cards.state.dart`

## Example

```sh
tools/android_studio_templates/domain/generate_domain_feature.sh cards card
tools/android_studio_templates/data/generate_data_feature.sh cards card
tools/android_studio_templates/presentation/generate_presentation_feature.sh cards card
dart run build_runner build --delete-conflicting-outputs
```

Each helper takes:

1. `feature_name` for page, bloc, repository, and use-case naming
2. `entity_name` for the domain entity and DTO naming

This documentation defines the intended repo pattern. In the example above, the feature is `cards`
and the entity is `card`.

## Current Scope

These helpers currently generate only the source scaffolding under:

- `lib/domain`
- `lib/data`
- `lib/presentation/pages`

Test files are intentionally left until later in the feature workflow.

## Migration Note

Some helper scripts and templates may still emit older underscore-style filenames. Treat the naming
convention in this README as the source of truth for the repo and update or rename generated files
to match it until the generators are fully aligned.

## Why These Are Script-Backed

JetBrains file templates are good for single files but clumsy for creating a full multi-file Flutter
feature skeleton in one step. These helpers keep the generation logic versioned in the repo and can
later be launched from Android Studio as External Tools or shortcuts.
