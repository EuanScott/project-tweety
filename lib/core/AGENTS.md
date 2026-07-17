# Core guidance

Read this for app-wide infrastructure under `lib/core/`.

- Keep core independent of feature pages, BLoCs, repositories, DTOs, and app business policy.
- Register services through injectable source annotations; regenerate `di/dependency_injection.config.dart` instead of editing it.
- Keep startup sequencing in `dart_init.dart`; add a lifecycle step only when it must finish before the app renders.
- Read the [storage guide](storage/README.md) before changing persistence lifecycle or migrations.
- Test lifecycle and coordination through the facade or service seam that callers use.
