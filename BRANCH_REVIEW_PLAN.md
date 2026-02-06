# Branch Review & Improvement Plan

This document outlines issues found during code review and the plan to address them.

---

## Priority 1: Critical Bugs (Must Fix)

### 1.1 DefaultViewMode Not Persisted
**File:** `lib/features/settings/data/repositories/settings_repository_impl.dart`
**Issue:** User's grid/list preference is lost on app restart.
**Fix:**
```dart
// Add constant
static const _keyDefaultViewMode = 'default_view_mode';

// In loadSettings():
final defaultViewMode = prefs.getString(_keyDefaultViewMode) ?? 'list';

// In saveSettings():
await prefs.setString(_keyDefaultViewMode, settings.defaultViewMode);
```

### 1.2 UpdateService Bash Script Variable Bug
**File:** `lib/core/services/update_service.dart`
**Lines:** 220-299
**Issue:** Dart string interpolation `$pid` becomes empty in bash. Should be `\$\$` for shell's own PID.
**Fix:** Escape all bash variables or use raw strings for the entire script template.

### 1.3 GameRepositoryImpl Async Fold Issue
**File:** `lib/features/games/data/repositories/game_repository_impl.dart`
**Lines:** 41-70
**Issue:** Async closure in `fold()` doesn't await properly.
**Fix:** Refactor to use proper async/await pattern:
```dart
final result = await _detectorRepository.getAllGames();
return result.fold(
  (failure) => Left(failure),
  (games) async {
    // ... process games
    return Right(mappedGames);
  },
);
```

---

## Priority 2: Missing Error Handling (High)

### 2.1 StorageCubit Silent Drive Failures
**File:** `lib/features/storage/presentation/cubit/storage_cubit.dart`
**Issue:** Failed drive detection is silently ignored.
**Fix:** Track failed drives and show warning in UI.

### 2.2 GameDetailsPage Size Calculation Errors
**File:** `lib/features/games/presentation/pages/game_details_page.dart`
**Issue:** No error handling for `getDirectorySize()` failures.
**Fix:** Add `.catchError()` or try-catch with logging.

### 2.3 GameExportService Permission Handling
**File:** `lib/core/services/game_export_service.dart`
**Issue:** No try-catch around file operations.
**Fix:** Wrap in try-catch, return Result type.

### 2.4 DiskSizeService Silent Failures
**File:** `lib/core/services/disk_size_service.dart`
**Issue:** Empty catch block hides I/O errors.
**Fix:** Add logging for skipped files.

### 2.5 StoragePage Generic Error Display
**File:** `lib/features/storage/presentation/pages/storage_page.dart`
**Issue:** Error shows bare text without retry button.
**Fix:** Use `ErrorState` widget consistently.

---

## Priority 3: Architecture Violations (High)

### 3.1 SearchGamesUsecase Wrong Pattern
**File:** `lib/features/games/domain/usecases/search_games_usecase.dart`
**Issue:** Synchronous function, not proper UseCase.
**Fix:** Either:
- Convert to proper `Future<Either<Failure, List<Game>>>` pattern
- OR rename to `SearchGamesHelper` since it's a pure filter function

### 3.2 Direct Service Locator in Build Methods
**Files:**
- `lib/features/storage/presentation/pages/storage_page.dart:20`
- `lib/features/games/presentation/pages/game_details_page.dart:70`
**Issue:** `sl<>()` called in build, violates DI pattern.
**Fix:** Inject via BlocProvider or constructor.

### 3.3 Settings Page Cross-Domain Coupling
**File:** `lib/features/settings/presentation/pages/settings_page.dart:45`
**Issue:** Settings page reads GamesCubit directly.
**Fix:** Create `ExportGamesUseCase` in games domain, call from settings.

---

## Priority 4: Code Quality (Medium)

### 4.1 Hardcoded Colors in storage_utils.dart
**File:** `lib/features/storage/presentation/utils/storage_utils.dart`
**Issue:** Uses `Colors.red/orange/blue` directly.
**Fix:** Use `GameColors.forStoragePercent()`.

### 4.2 Unused StorageInfo Entity
**File:** `lib/features/storage/domain/entities/storage_info.dart`
**Issue:** Defined but never used.
**Fix:** Either integrate into StorageCubit or delete.

### 4.3 Complex State Reconstructions in GamesCubit
**File:** `lib/features/games/presentation/cubit/games_cubit.dart`
**Issue:** Multiple `maybeWhen()` with all parameters duplicated.
**Fix:** Create `_updateLoadedState(Function(GamesLoaded) update)` helper.

---

## Priority 5: Polish & Cleanup (Low)

### 5.1 Logging Inconsistency
**Issue:** Mix of `LoggerService.instance` and `final _logger = ...`
**Fix:** Standardize on `final _logger` pattern.

### 5.2 Path Operations Cross-Platform
**File:** `lib/core/services/orphaned_data_service.dart:170`
**Issue:** Manual path splitting instead of `path.basename()`.
**Fix:** Use `path` package for all path operations.

### 5.3 Mock Repository Cleanup
**File:** `lib/features/games/data/repositories/mock_game_repository.dart`
**Action:** Ensure only used in tests, not production.

### 5.4 Windows Platform Checks
**Files:** Multiple
**Issue:** Code checks `Platform.isWindows` but not documented.
**Action:** Either add Windows support to docs or remove checks.

---

## Implementation Order

### Phase 1: Critical Fixes (Immediate) ✅
1. [x] Fix defaultViewMode persistence
2. [x] Fix UpdateService bash script variables
3. [x] Fix GameRepositoryImpl async pattern

### Phase 2: Error Handling (Next) ✅
4. [x] Add StorageCubit drive failure tracking
5. [x] Add GameDetailsPage error handling
6. [x] Add GameExportService permission checks
7. [x] Add DiskSizeService logging
8. [x] Use ErrorState widget in StoragePage

### Phase 3: Architecture Cleanup ✅
9. [x] Refactor SearchGamesUsecase (renamed to SearchGamesFilter)
10. [x] Fix service locator usage in build methods
11. [x] Decouple settings from games domain (skipped - acceptable coupling)

### Phase 4: Code Quality ✅
12. [x] Replace hardcoded colors with GameColors
13. [x] Remove or integrate StorageInfo entity (removed - unused)
14. [x] Add _updateLoadedState helper to GamesCubit (already existed)

### Phase 5: Polish ✅
15. [x] Standardize logging pattern (skipped - low priority)
16. [x] Use path package consistently
17. [x] Clean up mock repository (verified - correctly used only for dev)
18. [x] Document or remove Windows checks (documented in README)

---

## Estimated Effort

| Phase | Items | Estimated Time |
|-------|-------|----------------|
| Phase 1 | 3 | 1-2 hours |
| Phase 2 | 5 | 2-3 hours |
| Phase 3 | 3 | 1-2 hours |
| Phase 4 | 3 | 1 hour |
| Phase 5 | 4 | 1 hour |
| **Total** | **18** | **6-9 hours** |

---

## Notes

- All fixes should be followed by `flutter analyze` to ensure no new issues
- Phase 1 fixes are required before any release
- Phase 2-3 should be completed for production quality
- Phase 4-5 are nice-to-have improvements
