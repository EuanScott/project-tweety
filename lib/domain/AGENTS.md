# Domain guidance

Read this only when mobile-owned policy justifies `lib/domain/`.

- Read the [domain template](../domain/_template/README.md) before adding artifacts.
- Entities are immutable and framework-light; use cases own the policy that justifies the layer.
- Domain does not import DTOs, datasource implementations, widgets, or BLoCs.
- A repository pass-through is not sufficient reason to add domain.
