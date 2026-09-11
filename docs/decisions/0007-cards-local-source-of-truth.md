# ADR-0007: Local SQLite remains the source of truth for Cards

Status: proposed
Date: 2026-09-09

## Context

Cards persist to local SQLite. That foundation was built with synchronization
scaffolding that has never run: a `CardSyncStatus` enum, `updatedAt`,
`lastSyncedAt` and `deletedAt` columns, tombstone rows hidden from normal reads,
and the `getUnsyncedCards()` / `markCardsSynced()` pair on `CardsDataSource`.
[The architecture record](../architecture/cards_sqlite_foundation.md) defers the
bulk upload API, the sync UI, and any conflict policy.

Adopting Firebase supplies the external record that scaffolding was waiting for.
It also raises the question of whether the scaffolding should exist at all.
`cloud_firestore` ships its own on-device cache and a durable mutation queue: it
applies writes locally before they reach the backend, replays them on reconnect,
and exposes `metadata.hasPendingWrites` so a caller can distinguish a local write
from a server-confirmed one. That is the same job the local sync columns do by
hand.

[Research into Firestore's offline persistence](../research/firestore-offline-persistence.md)
concluded the local machinery is redundant rather than complementary, and
recommended retiring the SQLite Cards path in favour of a Firestore-backed
datasource. Its deciding argument was that two independently durable offline
stores share no consistency mechanism, so they can diverge with no reconciliation
path.

Measured against the codebase, that retirement would delete or rewrite roughly
3,357 lines across 24 files: 717 lines of production code, 1,492 lines of tests
including the native process-relaunch smoke procedure, and 1,148 lines of
documentation. `AppDatabase` and `sqflite` have no consumer outside Cards, so the
entire storage layer would go with it.

Two forces cut against that measurement. This repository exists for exercising
patterns rather than shipping a product, so "this code is redundant" carries less
weight here than it would in production; writing the synchronization loop is
itself the thing being explored. The scope is also a single device and a single
writer, which is the case where Firestore's conflict handling has nothing to
resolve and its live `snapshots()` streams have nothing to push.

## Decision

**We will keep local SQLite as the source of truth for a Card and treat Firestore
as a driven replica**, written by a person-initiated, best-effort push of pending
local changes. Reads continue to be served locally, and no Card originates in
Firestore.

## Alternatives

**Firestore as the store, SQLite retired.** A remote datasource would implement
the existing contract and `cloud_firestore`'s cache would replace local
persistence entirely. This is the recommendation of the offline-persistence
research and is the correct choice for a production application: it removes a
whole class of divergence bugs and stops re-deriving durability guarantees the
SDK already provides. It was rejected because it deletes the local persistence
work this repository was built to exercise, in exchange for a robustness property
a single-user playground does not need. That rejection is a judgment about this
repository's purpose, not a rebuttal of the research.

**A hybrid, with SQLite as a read cache in front of Firestore.** Rejected as
caching a cache: both stores are local disk reads, so no measurable latency is
won, and a second store must still be kept coherent with the first.

**Firestore implementing `CardsDataSource`.** Rejected because the two are never
interchangeable under this decision. The local datasource is per-card CRUD; the
remote side wants batch operations — upload these dirty Cards, remove these
tombstoned ones, report what succeeded. Firestore therefore gets its own
`CardsRemoteDataSource` contract rather than implementing methods, such as
`getCardById`, that nothing would call on it.

**Stream-based contracts.** Rejected for this iteration. Firestore's
`snapshots()` streams exist to propagate changes from other writers, which the
single-device scope excludes. `CardsBloc` awaits a one-shot
`getCards()` today and continues to.

## Consequences

The existing sync scaffolding is used as designed rather than removed, and every
lifecycle guarantee in the SQLite foundation survives. The change is additive:
a remote datasource contract and implementation, a `syncCards()` method on
`CardsRepository`, a bloc event, and a control in the UI. No repository or
presentation contract changes, because the synchronization bookkeeping was
already contained below the datasource seam.

Cards keep working without a network, and the app keeps a store it fully
controls. A conflict policy remains unnecessary: one device, one writer,
push-only.

Against that, the application now maintains two stores whose consistency depends
on app code rather than on the SDK. Divergence is possible if a push partially
fails and is never retried, which is accepted deliberately — a sync is best
effort, so `markCardsSynced()` acknowledges only what landed and leaves the
remainder dirty for the next attempt. Firestore's cache still exists underneath
and is not managed, so its behaviour must not be relied on for correctness.
Restoring Cards from Firestore onto an empty local database is not supported,
which means the replica cannot yet be read back.

Re-evaluate if a second device or a second writer enters scope, if background or
scheduled synchronization is wanted, if live-updating UI becomes a goal, or if
divergence between the two stores turns into an actual defect rather than a
theoretical one. Any of those inverts the trade-off toward the retirement
alternative above.

## Confirmation

Repository tests continue to cover the local datasource, the migrations, and the
`AppDatabase` lifecycle, so a change that quietly moved truth to Firestore would
break them. Synchronization is covered at the repository seam: pushing a mixed
set of dirty Cards and tombstones, acknowledging a partial success, and
confirming the unacknowledged remainder stays dirty. A review that finds a Card
read served from Firestore, or a Card created there, contradicts this decision.
