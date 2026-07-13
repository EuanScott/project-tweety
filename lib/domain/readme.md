# Domain Layer

The domain layer contains mobile-owned concepts, contracts, and policy. It is
optional: ordinary BFF-shaped flows should use data repositories directly.

## Canonical guidance

- Implementation rules: [AGENTS.md](AGENTS.md)
- Structural reference: [_template](_template/README.md)
- Domain-only scaffolding: `$domain-scaffold`

Use domain for meaningful app-owned decisions, validation, orchestration,
stateful concepts, or custom behavior. Keep DTOs, transport, persistence, and
presentation details outside the layer.
