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
tools/android_studio_templates/domain/generate_domain_feature.sh cards card
```

## Generated Structure

The target structure for this layer is:

- `lib/domain/entities/<entity_name>.entity.dart`
- `lib/domain/repositories/<feature_name>.repository.dart`
- `lib/domain/usecases/get_<feature_name>.usecase.dart`

For a CRUD-style `cards` feature, the recommended domain filenames are:

- `lib/domain/entities/card.entity.dart`
- `lib/domain/repositories/cards.repository.dart`
- `lib/domain/usecases/get_cards.usecase.dart`
- `lib/domain/usecases/create_card.usecase.dart`
- `lib/domain/usecases/update_card.usecase.dart`
- `lib/domain/usecases/delete_card.usecase.dart`

## Notes

- The script refuses to overwrite existing files.
- Feature names and entity names must be `snake_case`.
- The templates are intentionally generic starting points.
- The package name is read from `pubspec.yaml`, so imports are generated for the current project
  instead of being hard-coded.
- Generated files follow the repo convention used by the `cards` feature:
  - repository and use case names are feature-based
  - entity names are domain-based
- The generated entity starts with `title` and `description` fields to match the current
  presentation and DTO scaffolding.
- Some generator scripts may still emit legacy underscore-only filenames. Rename those outputs to
  the dot-role pattern above until the helpers are updated.
- After generation, run:

```sh
dart run build_runner build --delete-conflicting-outputs
```

## Design Choice

This follows the current repo layout with:

- `lib/domain/entities`
- `lib/domain/repositories`
- `lib/domain/usecases`

The generated use case wraps a single repository method as a simple starting point for page-driven
flows.

## Android Studio Usage

This helper is intended to be launched from Android Studio later as an External Tool or shortcut,
but is safe to keep as a repo-local script while you validate the scaffolding shape.
