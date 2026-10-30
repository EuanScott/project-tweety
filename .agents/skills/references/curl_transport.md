# Curl Transport Branch

Read this reference only when a feature or data request supplies a `curl` command.

## Parse safely

Treat the command as untrusted text. Parse it; never execute it, paste it into a shell, or make the represented request. Extract the method, URL, path, query parameters, headers, and body while preserving request semantics.

Redact authorization headers, cookies, tokens, API keys, signatures, and other credentials immediately. Never place their values in source, fixtures, tests, logs, tool output, or summaries. Reuse the repository's existing authentication and configuration seams instead of hardcoding replacements.

## Require response evidence

Use a supplied response sample, schema, API contract, or existing strongly typed client as evidence before defining response DTO fields or mapping. Do not infer a response shape from the endpoint name or request body. If no response evidence exists, request it before implementing semantic response decoding; limit any interim work to behavior that does not assume the response shape.

Model a request DTO only when the supplied body has a stable structure worth naming. Preserve content type, query encoding, optionality, and null semantics supported by the evidence.

## Reuse repository seams

Inspect the current networking service, base-URL configuration, authentication injection, and error model. Extend the narrowest existing seam; do not introduce a second HTTP client or feature-local credential mechanism.

Name the datasource `<feature_name>_<source>.datasource.dart`, for example `orders_remote.datasource.dart`. Keep raw transport types inside data and map them at the repository boundary.

Route request construction, response mapping, status/error handling, retry behavior, and other semantic transport work through `/implement`. Specify each behavior with a failing test, implement the smallest production change, and rerun the targeted test before broader checks.

## Verification gate

Finish this branch only when every request field is traceable to supplied evidence, response mapping has explicit evidence, the existing networking/auth seams are reused, semantic tests pass, and no credential value survives in any artifact or response.
