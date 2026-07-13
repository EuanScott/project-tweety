# Domain Template

This is a structural reference for a feature that has a documented,
mobile-owned domain policy. It is not a default feature layer and contains no
invented business logic.

## Manifest

Create only the parts justified by the feature:

```text
lib/domain/
├── entities/<folder_key>/<entity>.entity.dart
├── repositories/<feature>/<feature>.repository.dart
└── usecases/<feature>/<action>_<feature>.usecase.dart
```

- Add an entity only for a real app-owned payload with a current consumer.
- Add a repository contract for the intent-based operations required by the
  policy. The implementation belongs in `lib/data/`.
- Add one or more use cases for the policy-bearing actions the presentation
  layer needs.

## Constraints

- Keep entities immutable and framework-light.
- Keep contracts cohesive and independent of transport details.
- Keep policy in use cases, not repositories or pages.
- Do not import DTOs, datasources, repository implementations, widgets, or
  BLoCs into domain.
- Do not create a use case that only forwards one repository call unchanged.

Read `lib/AGENTS.md` for naming conventions and
`lib/domain/AGENTS.md` for policy and boundary rules. Use `$domain-scaffold`
when the domain branch is justified.
