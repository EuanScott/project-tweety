# Renamed Widget Successor Branch

Read this reference only when an update request names a successor, for example
`tool_bar -> compact_tool_bar`.

Treat the source widget, its tests, and its callers as the behavioural
baseline. Create the successor under the requested filename and class name.
Keep the source widget and existing callers unchanged unless migration is
explicitly included in the request.

Carry forward public constructors, fields, callbacks, state ownership, static
entrypoints, and result semantics unless the change brief identifies a precise
difference. Update copied documentation, examples, keys, and test names to the
successor terminology.

Specify each intentional difference with a failing successor test. Reuse or
parameterise existing behavioural tests where that keeps the source and
successor contract visibly aligned.

Finish when:

- the original diff is empty;
- existing callers still analyse unchanged;
- the successor's filename, class, docs, and tests use the requested name;
- preserved behaviour and intentional differences both have observable test
  coverage.
