# Domain Scaffold Contract

Use this reference when creating only the domain layer for a Project Tweety feature.

## Source of Truth

- follow the current source tree when older docs disagree
- `lib/domain/` is nested by feature or entity key

## Default Paths

- repository contract: `lib/domain/repositories/<folder-key>/<feature>.repository.dart`
- use case: `lib/domain/usecases/<folder-key>/<action>_<feature>.usecase.dart`
- entity when needed: `lib/domain/entities/<entity>/<entity>.entity.dart`

## Defaults

- repository contracts stay small and intent-based
- use cases are thin wrappers around repository contracts
- use cases may use `call()` when nearby code does
- skip entities unless there is a real domain payload

## Out of Scope

- `lib/data/*`
- `lib/presentation/*`
- navigation and localization updates unless explicitly requested
