# Shared widget guidance

Read this for reusable widgets under `lib/presentation/widgets/`.

- Keep the public interface narrow and caller-owned state outside the widget unless transient state is its purpose.
- Use existing design-system primitives; add a new adaptive primitive first when the need recurs.
- Preserve existing callers unless an intentional successor is requested.
