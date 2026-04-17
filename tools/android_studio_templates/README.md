# Android Studio Feature Helpers

These script-backed helpers generate the boilerplate for new feature layers in this repo.

## Available helpers

- `presentation/generate_presentation_feature.sh`
- `domain/generate_domain_feature.sh`
- `data/generate_data_feature.sh`

## Recommended order

For a brand new feature, generate in this order:

1. `domain`
2. `data`
3. `presentation`

`data` depends on the `domain` entity and repository contract already existing. `presentation`
depends on the `domain` entity and use case already existing.

All three helpers read the package name from `pubspec.yaml`, so generated imports match the current
project automatically.

## Example

```sh
tools/android_studio_templates/domain/generate_domain_feature.sh cards card_item
tools/android_studio_templates/data/generate_data_feature.sh cards card_item
tools/android_studio_templates/presentation/generate_presentation_feature.sh cards card_item
dart run build_runner build --delete-conflicting-outputs
```

Each helper takes:

1. `feature_name` for page, bloc, repository, and use-case naming
2. `entity_name` for the domain entity and DTO naming

This matches the current repo pattern where a feature such as `cards` renders an entity such as
`card_item`.

## Current scope

These helpers currently generate only the source scaffolding under:

- `lib/domain`
- `lib/data`
- `lib/presentation/pages`

Test files are intentionally left until later in the feature workflow.

## Why these are script-backed

JetBrains file templates are good for single files but clumsy for creating a full multi-file Flutter
feature skeleton in one step. These helpers keep the generation logic versioned in the repo and can
later be launched from Android Studio as External Tools or shortcuts.
