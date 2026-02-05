# Plan for Updating Agents.md

This document outlines all changes needed to bring `Agents.md` up to date with the current codebase after the recent feature implementations.

---

## Summary of Changes Made to Codebase

| Category | Files Created/Modified | Key Changes |
|----------|----------------------|-------------|
| Core Theme | `game_colors.dart`, `app_opacity.dart` | Centralized color/icon utilities |
| Core Services | `orphaned_data_service.dart`, `game_launch_service.dart`, `game_export_service.dart` | New service layer |
| Core Widgets | `skeleton_loading.dart`, `empty_state.dart` | Reusable UI components |
| Database | `game_database.dart` | v3 schema with tags, cache TTL, storage snapshots |
| State Management | `games_state.dart`, `settings_entity.dart` | New fields: sortOption, filterTag, lastRefresh, tag, appThemeMode |
| Entities | `game_tag.dart`, `sort_option.dart` | New enums for tagging and sorting |
| UI | Multiple widget files | GameColors consolidation, OLED theme, skeleton loading |

---

## Sections to ADD to Agents.md

### Section 8: Core Services

Add a new section documenting the services in `lib/core/services/`:

```markdown
## 8. Core Services

Services are singleton utilities registered in DI for cross-cutting concerns.

### OrphanedDataService
- **Purpose**: Detect and clean orphaned compatdata/shadercache from uninstalled games
- **Location**: `lib/core/services/orphaned_data_service.dart`
- **Key Methods**:
  - `scan(List<Game>)` - Returns `List<OrphanedData>` of orphaned directories
  - `cleanup(List<OrphanedData>)` - Returns `CleanupResult` with freed bytes
- **How It Works**:
  1. Scans ALL Steam library paths via `PlatformService.allSteamLibraryPaths`
  2. Reads appmanifest_*.acf files to get installed app IDs and game names
  3. Compares compatdata/shadercache folder IDs against installed IDs
  4. Orphaned = exists on disk but not in any manifest
  5. Detects symlinks (CryoUtilities) and skips them
  6. Non-Steam shortcuts have IDs > 10 digits
- **Warning**: Compatdata contains Proton prefixes with save files - must warn users

### GameLaunchService
- **Purpose**: Launch games via URI schemes
- **Location**: `lib/core/services/game_launch_service.dart`
- **URI Schemes**:
  - Steam: `steam://rungameid/{appid}`
  - Heroic: `heroic://launch/{id}`
  - Lutris: `lutris:rungame/{id}`
  - OGI: Not supported (returns null)

### GameExportService
- **Purpose**: Export game list for backup/sharing
- **Location**: `lib/core/services/game_export_service.dart`
- **Formats**: JSON, CSV
- **Output**: `~/Documents/game_list_export.{json|csv}`
```

### Section 9: Theme Utilities

```markdown
## 9. Theme Utilities

### GameColors (`lib/core/theme/game_colors.dart`)
Centralized source colors and icons - replaces duplicated `_getSourceColor()` methods.

- `GameColors.forSource(GameSource)` - Returns brand color for source
- `GameColors.iconForSource(GameSource)` - Returns icon for source
- `GameColors.nameForSource(GameSource)` - Returns display name
- `GameColors.forSize(int bytes)` - Returns color based on size (green/yellow/red)
- `GameColors.forStoragePercent(double)` - Returns color based on usage

**Rule**: All widgets MUST use GameColors instead of hardcoding colors.

### AppOpacity (`lib/core/theme/app_opacity.dart`)
Named constants replacing magic opacity values:

| Constant | Value | Use Case |
|----------|-------|----------|
| `subtle` | 0.1 | Very light backgrounds |
| `light` | 0.2 | Disabled states |
| `muted` | 0.5 | Secondary text |
| `overlay` | 0.6 | Modal overlays |
| `elevated` | 0.7 | Cards, containers |
| `prominent` | 0.8 | Important elements |
| `shadow` | 0.15 | Drop shadows |

### AppThemeMode (OLED Support)
Added `AppThemeMode` enum in `settings_entity.dart`:
- `system` - Follow system preference
- `light` - Always light
- `dark` - Standard dark (#1e1e1e backgrounds)
- `oled` - True black (#000000) for OLED displays

OLED theme defined in `app_theme.dart` as `AppTheme.oledTheme`.
```

### Section 10: Reusable Widgets

```markdown
## 10. Core Widgets

### Skeleton Loading (`lib/core/widgets/skeleton_loading.dart`)
Shimmer skeleton placeholders for loading states:

- `SkeletonLoading` - Base shimmer container
- `GameListItemSkeleton` - Single game list item skeleton
- `GamesPageSkeleton` - Full games page skeleton (8 items)
- `DashboardCardSkeleton` - Dashboard loading state
- `StoragePageSkeleton` - Storage page loading state

**Rule**: Use skeletons instead of bare `CircularProgressIndicator`.

### Empty/Error States (`lib/core/widgets/empty_state.dart`)
- `EmptyState` - Illustration + message + optional action button
- `ErrorState` - Error icon + message + retry button

Used when no data or errors occur. Always provide actionable next step.
```

---

## Sections to UPDATE in Agents.md

### Section 2: Architecture & Design Patterns

**Add Services Layer:**
```markdown
4.  **Services Layer** (`lib/core/services/`)
    *   Cross-cutting utilities: export, launch, cleanup
    *   Registered as lazy singletons in DI
    *   **Rule**: Services are stateless, cubits are stateful
```

**Add new file locations:**
```
lib/core/
├── di/
├── services/           # NEW: Cross-cutting services
│   ├── disk_size_service.dart
│   ├── game_export_service.dart
│   ├── game_launch_service.dart
│   └── orphaned_data_service.dart
├── theme/
│   ├── app_theme.dart
│   ├── app_opacity.dart      # NEW
│   ├── game_colors.dart      # NEW
│   └── steam_deck_constants.dart
├── widgets/
│   ├── empty_state.dart      # NEW
│   └── skeleton_loading.dart # NEW
└── ...
```

### Section 3: Launchers & Technical Details

**Add Orphaned Data Paths:**
```markdown
### Orphaned Data Paths
When detecting orphaned data, scan these directories:
- **CompatData**: `{steamapps}/compatdata/{appid}/`
- **ShaderCache**: `{steamapps}/shadercache/{appid}/`

Where `{steamapps}` comes from `PlatformService.allSteamLibraryPaths`.

**AppID Formats:**
- Steam games: 6 digits or less (e.g., `1174180`)
- Non-Steam shortcuts: 10+ digits (e.g., `2596741234567890`)

**Game Name Resolution:**
Read `appmanifest_{appid}.acf` files to extract game names:
```
"appid" "1174180"
"name" "Red Dead Redemption 2"
```
```

### Section 4: Workflows

**Add new make targets (if added to Makefile):**
```markdown
### Development Commands
*   `make gen` -> Runs build_runner for freezed/json_serializable
    *   **Important**: After changing entity fields, run this to regenerate .freezed.dart and .g.dart files
```

---

## New Entities/Enums to Document

Add to Section 2 or create new subsection:

```markdown
### New Domain Entities

#### GameTag (`lib/features/games/domain/entities/game_tag.dart`)
User-assignable categories for games:
- `playing` - Currently playing
- `completed` - Finished games
- `backlog` - Want to play
- `favorite` - Favorites
- `canDelete` - Safe to remove

Stored in SQLite `games.tag` column, preserved across refreshes.

#### SortOption (`lib/features/games/domain/entities/sort_option.dart`)
Sort modes for games list:
- `size` - By disk usage (default)
- `name` - Alphabetical
- `source` - By launcher

#### OrphanedData / OrphanedDataType
From `orphaned_data_service.dart`:
- `compatData` - Proton prefix (has save data risk!)
- `shaderCache` - Can be safely deleted, regenerates automatically
```

---

## Database Schema Update (Section to Add)

```markdown
## Database Schema (v3)

Location: `lib/core/database/game_database.dart`

### Tables

#### `games`
| Column | Type | Notes |
|--------|------|-------|
| id | TEXT PRIMARY KEY | Game ID (e.g., `steam_1174180`) |
| title | TEXT | Display name |
| source | TEXT | Launcher enum |
| install_path | TEXT | Full path |
| size_bytes | INTEGER | Disk usage |
| icon_path | TEXT | Nullable |
| launch_options | TEXT | Nullable |
| proton_version | TEXT | Nullable |
| storage_location | TEXT | NEW: `internal` or `sdcard` |
| tag | TEXT | NEW: User tag enum |

#### `cache_metadata` (NEW)
| Column | Type | Notes |
|--------|------|-------|
| key | TEXT PRIMARY KEY | e.g., `last_refresh` |
| value | TEXT | Timestamp or other value |

#### `storage_snapshots` (NEW)
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PRIMARY KEY | Auto-increment |
| timestamp | INTEGER | Unix epoch |
| total_bytes | INTEGER | Total disk |
| used_bytes | INTEGER | Used disk |

### Migrations
- v1 → v2: Added `storage_location` column
- v2 → v3: Added `tag` column, `cache_metadata` table, `storage_snapshots` table
```

---

## State Management Updates

```markdown
### GamesState Updates

New fields in `GamesLoaded`:
- `sortOption` (SortOption) - Current sort mode
- `filterTag` (GameTag?) - Active tag filter
- `lastRefresh` (DateTime?) - When data was last refreshed

New getters on `GamesState`:
- `displayedGames` - Filtered and sorted game list
- `allGames` - Unfiltered list (use for operations like orphan scan)
- `selectedGames` - Games with isSelected=true
- `hasSelection` - Any games selected?
- `selectedSizeBytes` - Total size of selected games

### SettingsState Updates

New field in `Settings`:
- `appThemeMode` (AppThemeMode) - Extended theme mode with OLED support
```

---

## Coding Standards Additions

Add to Section 5:

```markdown
### Concurrency Patterns

**Completer for Deduplication:**
When a method can be called multiple times concurrently (like refresh), use a Completer:
```dart
Completer<Result>? _refreshCompleter;

Future<Result> refresh() async {
  if (_refreshCompleter != null) return _refreshCompleter!.future;
  _refreshCompleter = Completer();
  try {
    final result = await _doRefresh();
    _refreshCompleter!.complete(result);
    return result;
  } finally {
    _refreshCompleter = null;
  }
}
```

**Batch Size Limits:**
When doing I/O-heavy operations (size calculations), limit concurrency:
```dart
const batchSize = 4;
for (var i = 0; i < items.length; i += batchSize) {
  await Future.wait(items.skip(i).take(batchSize).map(process));
}
```

### Color Usage

**Always use GameColors:**
```dart
// GOOD
final color = GameColors.forSource(game.source);

// BAD
final color = switch (game.source) {
  GameSource.steam => Colors.blue,
  // ...
};
```
```

---

## Implementation Status (vs IMPROVEMENT_PLAN.md)

| Item | Status | Notes |
|------|--------|-------|
| 1.1 Eliminate Duplicated Color Logic | DONE | `GameColors` utility |
| 1.3 Batch Delete in GameLocalDatasource | DONE | `deleteGamesBatch()` |
| 1.4 Concurrent Refresh Protection | DONE | Completer pattern |
| 1.5 Store StorageLocation in SQLite | DONE | DB v2 migration |
| 1.6 SQLite Transactions | DONE | `db.transaction()` |
| 1.8 Consolidate Opacity Magic Numbers | DONE | `AppOpacity` class |
| 2.3 Game Launch Integration | DONE | `GameLaunchService` |
| 2.5 Game Categories / Tags | DONE | `GameTag` enum |
| 2.7 Orphaned Data Detection | DONE | `OrphanedDataService` |
| 2.8 Import / Export Game List | DONE | `GameExportService` |
| 3.1 Skeleton Loading States | DONE | `skeleton_loading.dart` |
| 3.2 Better Empty States | DONE | `empty_state.dart` |
| 3.4 Pull-to-Refresh | DONE | `RefreshIndicator` on games page |
| 3.8 Sorting Options Expansion | DONE | `SortOption` enum |
| 3.10 OLED Black Theme | DONE | `AppThemeMode.oled` |
| 4.2 Cache TTL | DONE | `cache_metadata` table |
| 4.3 Throttle Parallel Size Calculations | DONE | Batch of 4 |
| 2.1 Game Cover Art Display | NOT DONE | Infrastructure exists, UI not wired |
| 2.2 Move Game to SD Card | NOT DONE | High effort |
| 4.1 Add Test Coverage | NOT DONE | Per user request |
| 3.3 Swipe Actions | NOT DONE | |
| 3.6 Onboarding | NOT DONE | |
| 3.7 Responsive Layout | NOT DONE | |
| 3.11 Haptic Feedback | NOT DONE | |
| 3.12 Accessibility | NOT DONE | |
| 4.4 Localization | NOT DONE | |

---

## Action Items

1. [ ] Add Section 8: Core Services
2. [ ] Add Section 9: Theme Utilities
3. [ ] Add Section 10: Core Widgets
4. [ ] Update Section 2 with services layer and new file locations
5. [ ] Update Section 3 with orphaned data paths
6. [ ] Add Database Schema section
7. [ ] Update State Management documentation
8. [ ] Add Concurrency Patterns to Coding Standards
9. [ ] Add Implementation Status section referencing IMPROVEMENT_PLAN.md
10. [ ] Update any outdated paths or descriptions
