# Data Feature Template

This template pack generates the `data` layer skeleton for a new feature from a
`snake_case feature_name` and a `snake_case entity_name`.

See the shared overview in `tools/android_studio_templates/README.md`.

## Usage

Run the generator from the repository root:

```sh
tools/android_studio_templates/data/generate_data_feature.sh feature_name entity_name
```

Example:

```sh
tools/android_studio_templates/data/generate_data_feature.sh cards card_item
```

## Generated structure

The generator creates:

- `lib/data/datasources/mock_<feature_name>_data_source.dart`
- `lib/data/dtos/<entity_name>_dto.dart`
- `lib/data/repositories/<feature_name>_repository_impl.dart`

## Notes

- The script refuses to overwrite existing files.
- Feature names and entity names must be `snake_case`.
- The templates are intentionally generic starting points.
- The package name is read from `pubspec.yaml`, so imports are generated for the current project
  instead of being hard-coded.
- This template assumes the domain helper has already created:
  - `domain/entities/<entity_name>.dart`
  - `domain/repositories/<feature_name>_repository.dart`
- The generated DTO includes a `toEntity()` mapper to match the current repo pattern.
- The generated data source is a mock data source to match the current repo pattern.
- After generating a new feature, run:

```sh
dart run build_runner build --delete-conflicting-outputs
```

## Design choice

This follows the current repo data layout with:

- `datasources`
- `dtos`
- `repositories`

The mock data source is intentionally simple and returns placeholder DTOs until you wire in the real
source for the feature.

## Android Studio usage

This helper is intended to be launched from Android Studio later as an External Tool or shortcut,
but is safe to keep as a repo-local script while you validate the scaffolding shape.
