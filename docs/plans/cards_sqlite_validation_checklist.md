# Cards SQLite Implementation - Validation Checklist

This document provides a self-service checklist for validating the deferred items and open questions from the SQLite Cards implementation code review. Use this during testing to verify completeness.

---

## Deferred Items (Intentionally Not Implemented)

These items are **explicitly deferred** per the plan documents and should NOT be implemented yet. Confirm they are NOT present in the codebase.

| Item | Source Document | Deferred Status | Notes |
|------|----------------|-----------------|-------|
| Bulk upload API integration | `cards_sqlite_data_layer.md` (Deferred work), `cards_sqlite_implementation_prompts.md` (Assumptions) | ⏭️ Deferred | No API sync coordinator should exist |
| User-triggered sync UI | `cards_sqlite_data_layer.md` (Deferred work), `cards_sqlite_implementation_prompts.md` (Assumptions) | ⏭️ Deferred | No sync UI components expected |
| Conflict resolution policy | `cards_sqlite_data_layer.md` (Deferred work), `cards_sqlite_implementation_prompts.md` (Assumptions) | ⏭️ Deferred | No conflict handling logic expected |
| Event/outbox storage | `cards_sqlite_data_layer.md` (Deferred work) | ⏭️ Deferred | No outbox/event storage expected |
| Full domain layer separation | `cards_sqlite_data_layer.md` (Deferred work: "A domain layer, unless sync conflict behavior becomes mobile-owned policy") | ⏭️ Conditionally Deferred | Domain entities currently in data layer; only separate if sync conflicts become mobile-owned |

---

## Test Coverage Verification

Verify these test categories exist and cover the specified scenarios.

| Test Type | Source Requirement | Files to Check | Scenarios to Verify |
|-----------|-------------------|----------------|---------------------|
| Repository tests | `cards_sqlite_implementation_prompts.md` Prompt 2, `cards_sqlite_end_to_end_integration.md` Test Plan | `test/.../cards_repository_test.dart` | Deterministic UUID generation, trimming behavior, validation logic, returned persisted values, missing-update failure handling |
| Repository tests | `cards_sqlite_implementation_prompts.md` Prompt 2 | - | Mock datasource contract adherence, DI binding tests |
| BLoC tests | `cards_sqlite_implementation_prompts.md` Prompt 2-5, `cards_sqlite_end_to_end_integration.md` Test Plan | `test/.../cards_bloc_test.dart` | Loading states, draft changes, validation behavior, CRUD success paths, concurrent-action guards (ignore duplicates while pending), recoverable failures (retain draft) |
| BLoC tests | `cards_sqlite_implementation_prompts.md` Prompt 5 | - | Dirty draft state preservation across navigation |
| Widget tests | `cards_sqlite_implementation_prompts.md` Prompt 2-5, `cards_sqlite_end_to_end_integration.md` Test Plan | `test/.../cards_page_test.dart`, `test/.../card_details_page_test.dart` | Compact layout create/edit flows, wide layout create/edit flows, delete confirmation dialog, dirty-discard prompts, empty state rendering, navigation outcomes |
| Widget tests | `cards_sqlite_implementation_prompts.md` Prompt 2-5 | - | Material theme behavior, Cupertino theme behavior, RTL layout |
| SQLite tests | `cards_sqlite_end_to_end_integration.md` Test Plan, Architecture | `test/.../cards_local_datasource_test.dart` | Created → synced transitions, updated → synced transitions, deleted → tombstone transitions, tombstone visibility (hidden from normal reads), physical deletion of unsynced-created cards, persistence after database close/reopen |
| Integration tests | `cards_sqlite_end_to_end_integration.md` Task 7, Architecture | `integration_test/cards_sqlite_smoke_test.dart` | Create, edit, acknowledge, edit again, delete flows through production DI, list and detail UI assertions, close and rebuild composition, native process relaunch survival |

### Test Execution Commands

```bash
# Run all unit tests
flutter test

# Run with coverage
flutter test --coverage

# Run analysis
flutter analyze

# Native smoke tests (Android)
flutter test integration_test/cards_sqlite_smoke_test.dart -d <device-id>

# Native smoke tests (iOS)
flutter test integration_test/cards_sqlite_smoke_test.dart -d <device-id>
```

---

## Localization Verification

Verify all required ARB localization files exist and contain the referenced keys.

| Language | File | Required | Status |
|----------|------|----------|--------|
| English | `l10n/app_en.arb` | ✅ Required | |
| Spanish | `l10n/app_es.arb` | ✅ Required | |
| Hebrew | `l10n/app_he.arb` | ✅ Required | |

### Required Localization Keys

Verify these keys exist in ALL three ARB files (`app_en.arb`, `app_es.arb`, `app_he.arb`):

| Category | Key | Used In |
|----------|-----|---------|
| General | `cardsTab` | Cards page title |
| Create | `cardCreateTitle` | Create page title, editor title |
| Create | `cardCreateAction` | Add button, create submit button |
| Create | `cardCreateTitleLabel` | Title field label |
| Create | `cardCreateDescriptionLabel` | Description field label |
| Create | `cardCreateTitleRequired` | Title validation error |
| Create | `cardCreateDescriptionRequired` | Description validation error |
| Create | `cardCreateFailed` | Create failure message |
| Create | `cardCreateEmptyTitle` | Empty state title |
| Create | `cardCreateEmptyDescription` | Empty state description |
| Details | `cardDetailsTitle` | Details page title |
| Details | `cardDetailsIdLabel` | ID label in details |
| Details | `cardDetailsLoadFailedTitle` | Load failure title |
| Details | `cardDetailsLoadFailedDescription` | Load failure description |
| Details | `cardDetailsMissingTitle` | Missing card title |
| Details | `cardDetailsMissingDescription` | Missing card description |
| Details | `cardDetailsEmptyTitle` | Empty details title |
| Details | `cardDetailsEmptyDescription` | Empty details description |
| Edit | `cardEditTitle` | Edit page title |
| Edit | `cardEditAction` | Edit button label |
| Edit | `cardEditSaveAction` | Save button label |
| Edit | `cardEditCancelAction` | Cancel button label |
| Edit | `cardEditFailed` | Edit failure message |
| Edit | `cardEditNotFound` | Edit not-found message |
| Edit | `cardEditReturnToCardsAction` | Return to cards button |
| Delete | `cardDeleteAction` | Delete button label |
| Delete | `cardDeleteRetryAction` | Retry delete button |
| Delete | `cardDeleteConfirmationTitle` | Delete confirmation dialog title |
| Delete | `cardDeleteConfirmationDescription` | Delete confirmation dialog content |
| Delete | `cardDeleteCancelAction` | Delete confirmation cancel |
| Delete | `cardDeleteFailed` | Delete failure message |
| Guard | `cardDiscardConfirmationTitle` | Draft discard dialog title |
| Guard | `cardDiscardConfirmationDescription` | Draft discard dialog content |
| Guard | `cardDiscardAction` | Discard confirm button |
| Guard | `cardDiscardCancelAction` | Discard cancel button |

### Localization Regeneration

After adding or modifying ARB files, regenerate localization:

```bash
flutter gen-l10n
```

---

## Dependency Injection Verification

Verify all new services are properly registered in the DI system.

| Service | Interface | Implementation | DI Annotation | File |
|---------|-----------|----------------|---------------|------|
| Database | `AppDatabase` | `SqfliteAppDatabase` | `@LazySingleton(as: AppDatabase)` | `lib/core/storage/app_database.storage.dart` |
| Card ID Generator | `CardIdGenerator` | `UuidCardIdGenerator` | `@LazySingleton(as: CardIdGenerator)` | `lib/data/services/card/card_id.generator.dart` |
| Cards DataSource | `CardsDataSource` | `CardsLocalDataSource` | `@LazySingleton(as: CardsDataSource)` | `lib/data/datasources/card/cards_local.datasource.dart` |
| Cards Repository | `CardsRepository` | `CardsRepositoryImpl` | `@LazySingleton(as: CardsRepository)` | `lib/data/repositories/card/cards.repository_impl.dart` |
| Cards BLoC | `CardsBloc` | `CardsBloc` | `@injectable` | `lib/presentation/pages/cards/bloc/cards.bloc.dart` |

### DI Regeneration

After modifying DI-annotated classes, regenerate the DI module:

```bash
flutter pub run build_runner build
# Or for a full rebuild
flutter pub run build_runner build --delete-conflicting-outputs
```

### DI Verification Checklist

- [ ] All `@LazySingleton` and `@injectable` annotations are present
- [ ] `dependency_injection.config.dart` includes all new types
- [ ] `build_runner` completes without errors
- [ ] `flutter analyze` shows no DI-related warnings
- [ ] Production DI binds `CardsLocalDataSource` (not mock)
- [ ] Mock datasource exists but is NOT production-registered

---

## Native Smoke Test Verification

Verify the native relaunch smoke test infrastructure exists.

| Component | File | Purpose |
|-----------|------|---------|
| Smoke test | `integration_test/cards_sqlite_smoke_test.dart` | End-to-end SQLite persistence test |
| Test driver | `test_driver/integration_test.dart` | Integration test driver |
| Architecture doc | `docs/architecture/cards_sqlite_foundation.md` | Smoke test instructions |

### Smoke Test Execution (Android)

```bash
# Prerequisite: Uninstall first
adb uninstall com.example.project_tweety

# Phase 1: Run smoke test with app left installed
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/cards_sqlite_smoke_test.dart \
  -d <device-id> \
  --dart-define=PRESERVE_SQLITE_SMOKE_TOMBSTONE=true \
  --keep-app-running

# Force stop the app
adb -s <device-id> shell am force-stop com.example.project_tweety

# Phase 2: Rebuild with verifier
flutter build apk \
  --debug \
  --target=integration_test/cards_sqlite_smoke_test.dart \
  --dart-define=EXPECT_EXISTING_SQLITE_SMOKE_CARD=true

# Reinstall
adb -s <device-id> install -r build/app/outputs/flutter-apk/app-debug.apk

# Relaunch
adb -s <device-id> shell monkey -p com.example.project_tweety 1
```

### Smoke Test Execution (iOS)

```bash
# Prerequisite: Uninstall first
xcrun simctl uninstall <device-id> com.example.projectTweety

# Phase 1: Run smoke test with app left installed
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/cards_sqlite_smoke_test.dart \
  -d <device-id> \
  --dart-define=PRESERVE_SQLITE_SMOKE_TOMBSTONE=true \
  --keep-app-running

# Terminate the app
xcrun simctl terminate <device-id> com.example.projectTweety

# Phase 2: Rebuild with verifier
flutter build ios \
  --simulator \
  --debug \
  --no-codesign \
  --target=integration_test/cards_sqlite_smoke_test.dart \
  --dart-define=EXPECT_EXISTING_SQLITE_SMOKE_CARD=true

# Reinstall and launch
xcrun simctl install <device-id> build/ios/iphonesimulator/Runner.app
xcrun simctl launch <device-id> com.example.projectTweety
```

### Expected Smoke Test Output

- [ ] First phase: Creates smoke card, verifies `created` status
- [ ] First phase: Edits card, verifies `updated` status
- [ ] First phase: Acknowledges sync, verifies `synced` status
- [ ] First phase: Edits again, verifies `updated` status
- [ ] First phase: Deletes card, verifies `deleted` tombstone
- [ ] First phase: Closes and rebuilds composition
- [ ] First phase: Tombstone persists after internal reopen
- [ ] Second phase (relaunch): Verifies tombstone still exists
- [ ] Second phase: Outputs "SQLite native relaunch verified"

---

## Implementation Files Reference

Quick reference to all implemented files for cross-checking.

### Core Storage
| File | Purpose |
|------|---------|
| `lib/core/storage/app_database.storage.dart` | AppDatabase abstract interface + SqfliteAppDatabase implementation |
| `lib/core/storage/app_database_migrations.storage.dart` | Schema migrations v1-3 |

### Data Layer - DTOs
| File | Purpose |
|------|---------|
| `lib/data/dtos/card/card.dto.dart` | CardDto with sync metadata, serialization |

### Data Layer - DataSources
| File | Purpose |
|------|---------|
| `lib/data/datasources/card/cards.datasource.dart` | Abstract CardsDataSource contract |
| `lib/data/datasources/card/cards_local.datasource.dart` | SQLite implementation |
| `lib/data/datasources/card/cards_mock.datasource.dart` | Mock implementation for testing |

### Data Layer - Repositories
| File | Purpose |
|------|---------|
| `lib/data/repositories/card/cards.repository.dart` | Domain entities (Card, CardDraft) + exceptions + CardsRepository interface |
| `lib/data/repositories/card/cards.repository_impl.dart` | Repository implementation |

### Data Layer - Services
| File | Purpose |
|------|---------|
| `lib/data/services/card/card_id.generator.dart` | UUID v4 CardIdGenerator |

### Presentation Layer - BLoC
| File | Purpose |
|------|---------|
| `lib/presentation/pages/cards/bloc/cards.bloc.dart` | CardsBloc state management |
| `lib/presentation/pages/cards/bloc/cards.state.dart` | State definitions (freezed) |
| `lib/presentation/pages/cards/bloc/cards.event.dart` | Event definitions |
| `lib/presentation/pages/cards/bloc/cards.bloc.freezed.dart` | Generated freezed code |

### Presentation Layer - Pages
| File | Purpose |
|------|---------|
| `lib/presentation/pages/cards/cards.page.dart` | Main cards list page |
| `lib/presentation/pages/cards/card_details/card_details.page.dart` | Card details page |
| `lib/presentation/pages/cards/draft_discard_guard.dart` | Draft discard navigation guard |

### Navigation Package
| File | Purpose |
|------|---------|
| `packages/navigation/lib/src/tab_reselect/tab_branch_reset_guard.dart` | Generic tab branch reset guard |
| `packages/navigation/lib/src/tab_reselect/tab_reselect_controller.dart` | Tab reselect controller |
| `packages/navigation/test/tab_branch_reset_guard_test.dart` | Package tests |

---

## Quick Validation Commands

Run these commands to quickly validate the implementation:

```bash
# 1. Check all required files exist
find lib -name "*.dart" | grep -E "(cards|app_database)" | sort

# 2. Verify dependencies
grep -E "(sqflite|uuid|path|sqflite_common_ffi)" pubspec.yaml

# 3. Check DI annotations
grep -r "@LazySingleton\|@injectable" lib/ --include="*.dart" | grep -E "(AppDatabase|Cards|CardId)" | sort

# 4. Verify localization files
ls -la l10n/app_*.arb

# 5. Check for deferred items (should NOT exist)
grep -r "sync.*upload\|bulk.*upload\|sync.*coordinator\|conflict.*resolution\|outbox" lib/ --include="*.dart" | grep -v "test\|//" | head -20

# 6. Run analysis
flutter analyze

# 7. Run tests
flutter test

# 8. Run tests with coverage
flutter test --coverage
```

---

## Document References

| Document | Purpose |
|----------|---------|
| `docs/plans/cards_sqlite_data_layer.md` | Original data layer plan |
| `docs/plans/cards_sqlite_implementation_prompts.md` | Implementation prompts and order |
| `docs/plans/cards_sqlite_end_to_end_integration.md` | End-to-end integration plan |
| `docs/architecture/cards_sqlite_foundation.md` | Architecture decision record |
| `docs/CONTEXT.md` | Cards feature glossary and definitions |
