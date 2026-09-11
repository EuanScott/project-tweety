# Does Firestore's offline persistence make the hand-rolled Cards sync machinery redundant?

**Direct answer: redundant.** Firestore's client SDK already durably queues local writes, replays them on reconnect, and lets the UI distinguish "written locally, unconfirmed" from "confirmed by server" — which is exactly the job the `CardSyncStatus` enum, `lastSyncedAt`/`deletedAt` columns, `getUnsyncedCards()`, and `markCardsSynced()` exist to do by hand. For a single-user, single-device playground app with no server sync loop ever built, running SQLite as a second, independently-durable offline store next to Firestore's own cache buys nothing and adds a second source of truth to keep consistent. The dirty-flag/tombstone design was built to compensate for *not having* a durable client SDK talking to the backend; if the backend becomes Firestore, that compensation is no longer needed.

---

## 1. Offline persistence defaults and cache scope

**Confirmed from Firebase docs** (checked 2026-09-09):
- Android and Apple platforms: "offline persistence is enabled by default." Web: disabled by default, requires `enablePersistence()`. Flutter follows the native-platform default — persistence is on by default on mobile. — https://firebase.google.com/docs/firestore/manage-data/enable-offline
- Firestore caches "every document received from the backend for offline access," along with query results — not a curated subset; whatever the client touches gets cached. — https://firebase.google.com/docs/firestore/manage-data/enable-offline
- Default cache size threshold is 100 MB, minimum configurable threshold 1 MB, and it can be set to unlimited (`FirestoreCacheSizeUnlimited` / `kFIRFirestoreCacheSizeUnlimited`) to disable cleanup entirely. Configured via `Settings(cacheSizeBytes: ...)` in the Flutter API. When the cache exceeds the threshold, Firestore "periodically attempts to clean up older, unused documents" (LRU-style garbage collection). — https://firebase.google.com/docs/firestore/manage-data/enable-offline
- `cloud_firestore` pub.dev listing describes itself as providing "live synchronization and offline support on Android and iOS" as a core feature of the plugin itself, not a bolt-on. — https://pub.dev/packages/cloud_firestore
- CHANGELOG confirms offline/cache features have existed and been iterated on for a long time: `Firestore.enablePersistence` (0.8.0), `cacheSizeBytes` support (0.12.3), `PersistenceSettings` + web `enablePersistence`/`clearPersistence` (0.14.3), deprecated persistence API update (4.8.1), `PersistentCacheIndexManager` for managing cache indexes (5.2.0). — https://pub.dev/packages/cloud_firestore/changelog

**Not stated in primary docs / inferred:** exact behavior of `cacheSizeBytes` interacting with `CardDto`-sized documents wasn't covered — irrelevant at this app's scale (cards are small, single-user).

## 2. Offline writes: local application, durable queue, reconnect behavior

**Confirmed from Firebase docs:**
- "When the device comes back online, Cloud Firestore synchronizes any local changes made by your app to the Cloud Firestore backend." — https://firebase.google.com/docs/firestore/manage-data/enable-offline
- Local writes invoke snapshot listeners immediately, before the write reaches the backend ("latency compensation") — meaning writes are applied to the local cache synchronously, not queued invisibly. — https://firebase.google.com/docs/firestore/query-data/listen

**Not stated in primary docs (gap, flagged explicitly):**
- The fetched pages did not contain an explicit sentence confirming the pending-write queue survives app restart/process death, nor explicit retry-count/backoff/ordering guarantees. This is a real documentation gap in what was retrievable via WebFetch, not a "no" answer.

**Inference / reasoning:** The queue is widely understood (and implied by the SDK's whole design — offline-first local database with an active sync engine, not a fire-and-forget in-memory buffer) to be backed by the same persistent on-device store used for the document/query cache, so it is reasonable to expect it survives restarts. But this document deliberately does not assert that as a "confirmed" fact since the primary-source text fetched did not state it in so many words. If this matters for a production decision, it should be re-verified directly against the SDK reference (not blog/SO) before relying on it.

## 3. Latency compensation and snapshot metadata

**Confirmed from Firebase docs:**
- "Local writes in your app will invoke snapshot listeners immediately... your listeners will be notified with the new data *before* the data is sent to the backend." — https://firebase.google.com/docs/firestore/query-data/listen
- `metadata.hasPendingWrites` distinguishes local vs. server-acknowledged data: `doc.metadata.hasPendingWrites ? "Local" : "Server"`. — https://firebase.google.com/docs/firestore/query-data/listen

**Not stated in primary docs / gap:** `metadata.isFromCache` (which flags "this data is stale, served from cache because we're offline/haven't gotten a fresh listen result yet") was not present in the two listen-doc fetches performed. It is a well-known, real field on `DocumentSnapshot.metadata` in the Firestore SDK, but it wasn't confirmed from the specific pages fetched in this research pass — flagged as a gap rather than asserted.

**Inference / reasoning:** Combining what *was* confirmed (`hasPendingWrites`) with the well-established shape of Firestore's metadata API, a UI can distinguish three states: (1) `hasPendingWrites == true` → "written locally, not yet confirmed" (equivalent to this repo's `created`/`updated` sync status), (2) `hasPendingWrites == false` and fresh → "confirmed by server" (equivalent to `synced`), (3) `isFromCache == true` while offline → "showing stale cached data." That third state has no equivalent concept at all in the current `CardSyncStatus` model — the local SQLite store doesn't know or care whether it's "stale," because it's the only store.

## 4. Conflict behavior on reconnect

**Confirmed from Firebase docs:**
- "For multiple changes to the same document, it's last write wins." — https://firebase.google.com/docs/firestore/manage-data/enable-offline

**Inference / reasoning:** This statement is about concurrent multi-client writes to the same document, which is a *non-issue* for this app: single-user, single-device, no auth, no second writer exists. There is no "conflict" to resolve here in any meaningful sense — the entire conflict-resolution question the docs address (and that a server-side bulk-upload endpoint with a "conflict policy... deferred" was presumably going to need to solve) evaporates once there's only ever one client. This is precisely the situation where hand-rolling a conflict policy is *wasted* work relative to just letting Firestore's last-write-wins default apply, because it will never actually be exercised by more than one writer.

## 5. Delete propagation and tombstones

**Confirmed from Firebase docs:**
- Deletes go through the standard write path described for enable-offline generally (queued, applied to cache immediately, synced when back online) — the docs don't carve out deletes as a special case; delete-data docs discuss delete *syntax* (`delete()`, field deletion via `FieldValue.delete()`) without a distinct offline-durability discussion. — https://firebase.google.com/docs/firestore/manage-data/delete-data

**Not stated in primary docs / gap:** The delete-data page fetched did not explicitly restate "deletes queue and retry exactly like other writes." This wasn't contradicted either — it's simply not spelled out on that specific page.

**Inference / reasoning:** There's no concept of a client-visible "tombstone" in Firestore's model — a deleted document is just gone from the cache and the backend once the delete syncs; nothing resembling this repo's `sync_status = 'deleted'` hidden-row pattern exists or is needed, because Firestore's own client-side document cache already tracks "this document has a pending delete" internally as part of the same mutation queue that handles creates and updates. The entire tombstone mechanism in `CardsLocalDataSource.deleteCard()`/`markCardsSynced()` is solving the problem of "how do I know an unsent delete hasn't been undone by a later read, and how do I know when it's safe to purge the local row" — the exact problem Firestore's mutation queue + cache already owns end-to-end.

## 6. Security Rules shape: per-user subcollection vs flat collection + ownerId

**Confirmed from Firebase docs:**
- Path-based ownership match is the documented idiom: `match /users/{userId} { allow read, update, delete: if request.auth != null && request.auth.uid == userId; }` — the wildcard segment is compared directly to `request.auth.uid`. — https://firebase.google.com/docs/firestore/security/rules-conditions
- Rules apply only at the matched path and do not cascade to subcollections — subcollections need their own explicit match blocks even when nested under an owned document. — https://firebase.google.com/docs/firestore/security/rules-structure
- For flat collections without path-encoded ownership, the documented alternative is field-based validation (`resource.data.ownerId == request.auth.uid`), with an explicit caveat: **security rules operate per-document and do not filter query results** — a query without a matching `where()` clause will simply be rejected if it *could* return documents the rule would deny, rather than being silently filtered. So the flat+`ownerId` approach requires the client to always issue `where('ownerId', '==', uid)` and the rule to require that filter; the query can't rely on rules alone to prevent leakage. — https://firebase.google.com/docs/firestore/security/rules-conditions

**Not stated in primary docs / gap:** The fetched rules-conditions/rules-structure pages did not explicitly discuss composite-index requirements for the `ownerId`+other-field `where()` combination, nor collection-group query mechanics, in the text retrieved. (Collection-group queries are Firestore's mechanism for querying across all subcollections of a given name regardless of parent — relevant if a per-user-subcollection design ever needed a cross-user admin view — but this wasn't confirmed from the pages fetched.)

**Inference / reasoning:** For this app, `users/{uid}/cards/{cardId}` is simpler to secure correctly (one path-equality condition, no way to author a rule that accidentally omits the owner check) and simpler to query safely (every read is inherently scoped, no risk of forgetting the `where()` clause). The flat+`ownerId` shape only earns its complexity when something needs to query across owners (rare, and typically an admin/server operation better done from privileged server code that bypasses client rules entirely). Since there's no auth/multi-device story in this app yet, this is forward-looking rather than an immediate decision, but if/when Firestore is adopted, the subcollection shape is the lower-risk default.

## 7. Local SQLite mirror alongside Firestore's own cache — documented pattern?

**Confirmed from Firebase docs:** Silent. Nothing in the fetched pages (enable-offline, listen, delete-data, rules pages, pub.dev listing/changelog) discusses or endorses running a second independent local database alongside Firestore's client-side cache. This is expected — it's not something Firestore's own docs would have a reason to cover, since the SDK is designed to be the client's sole persistence layer.

**Inference / reasoning (not a doc claim):** Running SQLite and Firestore's cache side by side means two independently-durable offline stores with no shared consistency mechanism between them:
- **Divergent state**: if a write lands in SQLite but the (not-yet-built) bulk-upload step fails or is skipped, SQLite and Firestore disagree indefinitely with no reconciliation path.
- **Double-buffered writes**: a create would need to be written to SQLite immediately, then separately queued for Firestore — two write paths to keep transactionally coupled, doubling the surface for partial-failure bugs.
- **No single source-of-truth reads**: a `getCards()` call has to decide whether to read SQLite, Firestore's cache, or reconcile both — versus Firestore alone, where one stream (`snapshots()`) is definitionally the current state, online or offline.
- **Doubled write latency perception**: a UI update after a local write already reflects immediately in Firestore's cache (latency compensation, section 3) with no bulk-upload round trip required — SQLite's dirty-flag design exists specifically to defer that round trip to a batch job that doesn't exist yet.
- **No shared "confirmed vs. pending" signal**: `hasPendingWrites` already gives the UI the exact boolean the `CardSyncStatus` enum's `created`/`updated`/`synced` states were built to approximate, for free, without app code maintaining it.

---

## Closing: recommendation on architecture (a) / (b) / (c)

This section is **my recommendation**, not a documented Firebase fact.

- **(a) SQLite as source of truth, Firestore as a driven replica (finish the current dirty-flag/tombstone design, sync SQLite → Firestore):** Keeps a bulk-upload endpoint that doesn't exist and a conflict policy that's explicitly deferred, to solve a multi-client conflict problem this app doesn't have (section 4), while duplicating durability, latency-compensation, and pending/confirmed state tracking that Firestore's SDK already provides for free (sections 2, 3, 5). This is strictly more code for less capability than (b).
- **(b) Firestore as the store, with a new remote `CardsDataSource` implementation on `cloud_firestore` using its own offline cache, and SQLite retired:** `CardSyncStatus`, `lastSyncedAt`, `deletedAt`, `getUnsyncedCards()`, and `markCardsSynced()` all disappear — replaced by `metadata.hasPendingWrites` for "is this confirmed yet" and Firestore's own mutation queue for the retry/durability the tombstone dance was hand-building. `CardsRepository`'s existing app-facing surface (`getCards`, `getCardById`, `createCard(CardDraft)`, `updateCard`, `deleteCard`) is unaffected — the sync bookkeeping was already fully contained below the datasource contract, per the repo's own layering, so this swap is a datasource-layer replacement, not a repository or presentation change.
- **(c) Hybrid (e.g. SQLite for something, Firestore for something else, or SQLite as a write-through cache in front of Firestore):** Concretely this would mean keeping SQLite as a fast local read cache with Firestore behind it doing its own caching — i.e., caching Firestore's cache. There is no scenario in a single-device app where SQLite's read latency meaningfully beats Firestore's own on-device cache (both are local disk reads), so this only adds a second store to keep coherent with the first, for no measurable win.

**Recommendation: (b).** The deciding tradeoff: **maintaining two independently-durable offline stores with no shared conflict/consistency mechanism, versus adopting a client SDK whose entire cache and mutation-queue system already solves the exact problem the `CardSyncStatus` dirty-flag columns and tombstone rows exist to solve.** The current design is scaffolding for a sync problem Firestore's client already ships solved; finishing it (a) means re-deriving, in app code, guarantees (durable write queue, retry-on-reconnect, pending-vs-confirmed signaling) that section 2/3/5 show Firestore provides out of the box. For a single-user playground app with no multi-client conflict case (section 4) and no documented use case for a second local store (section 7), (b) is the only option that doesn't carry dead-weight machinery built for a scenario (multi-writer conflicts, a bulk-upload API) that doesn't exist here.
