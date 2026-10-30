# Controlled Widget Branch

Read this reference only when the widget renders caller-owned selection,
toggle, ordered collection, or repeated stateful children.

## Contract

Keep the durable value in the caller. Accept the current value and emit the
next value through a typed callback such as `ValueChanged<T>`. Local state is
reserved for transient interaction that is itself the widget's responsibility.

Expose stable identifiers when display labels are not unique. Prefer typed
options or domain identifiers over loosely related parallel lists.

Use constructor assertions for invalid contracts the Dart type system cannot
express, including empty option sets, selected values absent from the options,
invalid ranges, or mutually exclusive combinations. Keep messages short and
actionable. Runtime data failures remain normal runtime states rather than
constructor assertions.

Use stable `ValueKey` values derived from durable identifiers when Flutter must
preserve identity across insertion, removal, or reordering. Index keys fit only
fixed-order collections. `UniqueKey` in `build` intentionally discards identity
and therefore requires an explicit behavioural reason.

## Verification gate

Specify the contract with a failing widget test before production changes.
Finish when the test proves:

- the caller-provided value is rendered;
- interaction emits the typed next value without taking durable ownership;
- invalid contracts fail at construction when assertions are warranted;
- repeated stateful children retain the intended identity across reordering.
