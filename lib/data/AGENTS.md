# Data guidance

Read this for work under `lib/data/`.

- Read the [repository templates](../../tool/templates/feature/data/repositories/) before creating a default repository pair.
- Datasources stay close to a concrete source; DTOs stay inside data.
- Repositories hide transport and persistence details and return app-facing values.
- Data does not import presentation or own mobile business policy.
- Test mapping and datasource coordination through the repository contract seam.
