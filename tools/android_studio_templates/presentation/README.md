# Presentation Feature Template

This template pack generates the `presentation` layer skeleton for a new feature from a
`snake_case feature_name` and a `snake_case entity_name`.

## Why This Is Script-Backed

JetBrains file templates are great for generating a single file, but they are awkward for creating a
complete Flutter feature tree in one action. This generator keeps the workflow to one command while
still behaving like a reusable template pack that can later be wired into Android Studio however you
prefer.

See the shared overview in `tools/android_studio_templates/README.md`.

## Usage

Run the generator from the repository root:

```sh
tools/android_studio_templates/presentation/generate_presentation_feature.sh feature_name entity_name
```

Example:

```sh
tools/android_studio_templates/presentation/generate_presentation_feature.sh cards card
```

## Generated Structure

The target structure for this layer is:

- `lib/presentation/pages/<feature_name>/<feature_name>.page.dart`
- `lib/presentation/pages/<feature_name>/bloc/<feature_name>.bloc.dart`
- `lib/presentation/pages/<feature_name>/bloc/<feature_name>.event.dart`
- `lib/presentation/pages/<feature_name>/bloc/<feature_name>.state.dart`

For `cards`, that means:

- `lib/presentation/pages/cards/cards.page.dart`
- `lib/presentation/pages/cards/bloc/cards.bloc.dart`
- `lib/presentation/pages/cards/bloc/cards.event.dart`
- `lib/presentation/pages/cards/bloc/cards.state.dart`

## Notes

- The script refuses to overwrite existing files.
- Feature names and entity names must be `snake_case`.
- The templates are intentionally generic starting points.
- The package name is read from `pubspec.yaml`, so imports are generated for the current project
  instead of being hard-coded.
- The generated page follows the current repo pattern used by `cards`, `home`, and `settings`:
  - top-level page widget only
  - no nested `Scaffold`
  - page-owned `BlocProvider(create: ...)`
  - loading, failure, and success rendering in one file
- This template assumes the domain helper has already created:
  - `lib/domain/entities/<entity_name>.entity.dart`
  - `lib/domain/usecases/get_<feature_name>.usecase.dart`
- Some generator scripts may still emit legacy underscore-only filenames. Rename those outputs to
  the dot-role pattern above until the helpers are updated.
- Generated bloc and state files use Freezed and injectable annotations, so run:

```sh
dart run build_runner build --delete-conflicting-outputs
```

## Android Studio Usage

The fastest way to use this inside Android Studio is to add it as an External Tool or a terminal
shortcut and pass the required arguments. That keeps the workflow quick while still letting the
generator build the full presentation directory structure in one go.
