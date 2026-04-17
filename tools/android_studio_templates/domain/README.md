# Domain Feature Template

This template pack generates the `domain` layer skeleton for a new feature from a
`snake_case feature_name` and a `snake_case entity_name`.

See the shared overview in `tools/android_studio_templates/README.md`.

## Usage

Run the generator from the repository root:

```sh
tools/android_studio_templates/domain/generate_domain_feature.sh feature_name entity_name
```

Example:

```sh
tools/android_studio_templates/domain/generate_domain_feature.sh cards card_item
```

## Generated structure

The generator creates:

- `lib/domain/entities/<entity_name>.dart`
- `lib/domain/repositories/<feature_name>_repository.dart`
- `lib/domain/usecases/get_<feature_name>_usecase.dart`

## Notes

- The script refuses to overwrite existing files.
- Feature names and entity names must be `snake_case`.
- The templates are intentionally generic starting points.
- The package name is read from `pubspec.yaml`, so imports are generated for the current project
  instead of being hard-coded.
- Generated files follow the current project convention used by the `cards` feature:
  - repository and use case names are feature-based
  - entity names are domain-based
- The generated entity starts with `title` and `description` fields to match the current
  presentation and DTO scaffolding.
- After generation, run:

```sh
dart run build_runner build --delete-conflicting-outputs
```

## Design choice

This follows the current repo layout with:

- `lib/domain/entities`
- `lib/domain/repositories`
- `lib/domain/usecases`

The generated use case wraps a single repository method as a simple starting point for page-driven
flows.

## Android Studio usage

This helper is intended to be launched from Android Studio later as an External Tool or shortcut,
but is safe to keep as a repo-local script while you validate the scaffolding shape.
