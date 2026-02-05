# 🤖 Game Size Manager - AI Agent Guide

This document is the **Source of Truth** for AI agents working on this codebase. It defines the architecture, workflows, and technical details required to contribute effectively.

> **⚠️ CRITICAL RULE FOR AGENTS:**
> If you make changes to the Project Architecture, Build System, or key Technical Approaches (e.g. changing how a launcher is detected), **YOU MUST UPDATE THIS DOCUMENT**.
> Do not let this documentation drift from reality. Treat it as part of the code.

---

## 1. Project Overview

**Game Size Manager** is a Flutter desktop application for **Steam Deck** (Linux). It aggregates installed games from multiple launchers to help users visualize and manage their disk space.

*   **Tech Stack:** Flutter (macOS for dev, Linux for target), Dart.
*   **Target Device:** Steam Deck (Arch Linux-based SteamOS).
*   **Resolution:** Optimized for 1280x800 (16:10).

---

## 2. Architecture & Design Patterns

The project closely adheres to **Clean Architecture** principles to separate concerns and ensure testability. Usage of `UseCases` is **mandatory** for business logic.

### Layers
1.  **Presentation Layer** (`lib/features/*/presentation/`)
    *   **Pages/Widgets**: Dumb UI components.
    *   **Cubits**: State management (`flutter_bloc`).
        *   **Rule**: Cubits **NEVER** call Repositories directly. They must use **UseCases**.
        *   **Rule**: Cubits should emit `States` (freezed unions) to drive the UI.
2.  **Domain Layer** (`lib/features/*/domain/`)
    *   **Entities**: Pure Dart classes (e.g., `Game`).
    *   **Repositories (Interfaces)**: Abstract contracts (e.g., `GameRepository`).
    *   **UseCases**: Single-responsibility classes (e.g., `GetAllGamesUsecase`).
        *   **Rule**: Each UseCase should implement `call()` and return `Future<Either<Failure, Type>>`.
3.  **Data Layer** (`lib/features/*/data/`)
    *   **DataSources**: Low-level data fetching (e.g., reading VDF files, SQLite).
    *   **DTOs**: Data Transfer Objects (e.g., `SteamGameDto`).
    *   **Repositories (Implementation)**: Coordinates DataSources to return Domain Entities.
4.  **Services Layer** (`lib/core/services/`)
    *   Cross-cutting utilities: export, launch, cleanup, disk size.
    *   Registered as lazy singletons in DI.
    *   **Rule**: Services are stateless; Cubits are stateful.

### Dependency Injection (DI)
*   **Package**: `get_it` with `injectable` (manually registered in `lib/core/di/injection.dart`).
*   **Pattern**: Service Locator pattern used in `main.dart`, but Constructor Injection used everywhere else.
*   **Setup**:
    *   `sl()` is the global instance.
    *   Register `UseCases` as singletons.
    *   Register `Cubits` via `registerFactory`.
    *   Register `Services` as lazy singletons.

### Directory Structure
```
lib/
├── core/
│   ├── constants.dart          # App-wide constants
│   ├── database/
│   │   └── game_database.dart  # SQLite database (v3)
│   ├── di/
│   │   └── injection.dart      # Dependency injection setup
│   ├── extensions/             # Extension methods
│   ├── logging/
│   │   └── logger_service.dart
│   ├── platform/
│   │   └── platform_service.dart
│   ├── services/               # Cross-cutting services
│   │   ├── disk_size_service.dart
│   │   ├── game_export_service.dart
│   │   ├── game_launch_service.dart
│   │   ├── log_share_service.dart
│   │   ├── orphaned_data_service.dart
│   │   └── update_service.dart
│   ├── theme/
│   │   ├── app_theme.dart      # Theme definitions (light, dark, OLED)
│   │   ├── app_opacity.dart    # Named opacity constants
│   │   ├── game_colors.dart    # Centralized color/icon utilities
│   │   └── steam_deck_constants.dart
│   ├── utils/
│   │   └── game_utils.dart
│   └── widgets/                # Reusable core widgets
│       ├── animated_card.dart
│       ├── empty_state.dart    # Empty/error state widgets
│       ├── global_error_boundary.dart
│       └── skeleton_loading.dart
├── features/
│   ├── games/
│   │   ├── data/
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       ├── game_entity.dart
│   │   │       ├── game_tag.dart     # User tags enum
│   │   │       └── sort_option.dart  # Sort modes enum
│   │   └── presentation/
│   ├── settings/
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── settings_entity.dart  # Includes AppThemeMode
│   │   └── presentation/
│   └── storage/
└── main.dart
```

---

## 3. Launchers & Technical Details

When working on datasources, understand how we detect games for each launcher:

### 🎮 Steam
*   **Source**: `lib/features/games/data/datasources/steam_datasource.dart`
*   **Discovery**: Reads `libraryfolders.vdf` to find all Steam library paths.
*   **Game Metadata**: Parses `appmanifest_[APPID].acf` files in `steamapps/`.
    *   **Key Fields**: `appid`, `name`, `installdir`, `SizeOnDisk`.
*   **Launch Options**: Parsed from `localconfig.vdf`. Careful: simpler regex parsing is preferred over full VDF parsing for performance.
*   **Art Fetching**:
    *   **Priority 1 (Custom)**: Checks `userdata/<user_id>/config/grid` for PNGs (e.g., `[APPID]p.png` for cover). Common for SteamGridDB.
    *   **Priority 2 (Default)**: Checks `appcache/librarycache` for cached images.
        *   **Structure**: `<librarycache_path>/[APPID]/library_600x900.jpg` (subdirectory per app).
        *   **Subdirectory Files**: `library_600x900.jpg` (cover), `library_hero.jpg` (header), `logo.png` (logo).

### 🦸 Heroic Games Launcher (Epic & GOG)
*   **Source**: `lib/features/games/data/datasources/heroic_datasource.dart`
*   **Epic Games**: Parses `installed.json` (managed by Legendary).
    *   **Path**: `~/.config/heroic/legendaryConfig/legendary/installed.json`
*   **GOG**: Parses `gog_store/library.json` (Heroic's cache).
*   **Art Fetching**:
    *   **SHA256 Hashing**: Heroic caches images using the **SHA256 hash of the full image URL** as the filename.
    *   **Resolution Strategy**:
        1.  In `HeroicDatasource`, we fetch `art_square`, `art_cover`, and `box_art` URLs from `legendary_library.json`.
        2.  Compute SHA256 hash for *each* URL.
        3.  Check `~/.config/heroic/images-cache` (or Flatpak equivalent) for existence of that hash.
        4.  Use the URL corresponding to the *first existing file* found. (Heroic often caches `art_cover` but not `art_square`).
    *   **Fallback**: Scanning the directory for `[AppName].jpg` (unreliable).

### 🍷 Lutris
*   **Source**: `lib/features/games/data/datasources/lutris_datasource.dart`
*   **Database**: SQLite file at `~/.local/share/lutris/pga.db`.
*   **Query**: Select from `games` table where `installed = 1` and `directory` is not null.
*   **Art Fetching**:
    *   **Path**: Checks `coverart` and `banners` directories.
    *   **Flatpak Quirk**: Lutris Flatpak stores data in `~/.var/app/.../data/lutris` (XDG_DATA_HOME), NOT `cache`.
    *   **Filename**: `{slug}.jpg`. Slug is derived from game info.

### 📦 OpenGameInstaller (OGI)
*   **Source**: `lib/features/games/data/datasources/ogi_datasource.dart`
*   **Metadata**: Parses JSON files in OGI games directory.
*   **Detection**: Validates `installLocation` path exists.

### Orphaned Data Paths

When detecting orphaned data (compatdata/shadercache from uninstalled games), scan these directories across **all** Steam library paths:

*   **CompatData**: `{steamapps}/compatdata/{appid}/` - Proton prefixes (may contain save files!)
*   **ShaderCache**: `{steamapps}/shadercache/{appid}/` - Pre-compiled shaders (safe to delete, regenerates)

Where `{steamapps}` comes from `PlatformService.allSteamLibraryPaths` (includes internal storage AND SD card).

**AppID Formats:**
*   Steam games: 6 digits or fewer (e.g., `1174180`)
*   Non-Steam shortcuts: 10+ digits (e.g., `2596741234567890`)

**Game Name Resolution:**
Read `appmanifest_{appid}.acf` files to extract game names:
```
"appid"  "1174180"
"name"   "Red Dead Redemption 2"
```

**Symlink Detection:**
Tools like CryoUtilities create symlinks to move data to SD card. The `OrphanedDataService` detects symlinks and skips them (size = 0, labeled as "managed externally").

---

## 4. Workflows

### 💻 Mac Development (Host)
*   `make run` -> Runs app on macOS.
*   `make build-linux` -> Builds Linux Release via Docker (Required for Steam Deck compatibility).
*   `make gen` -> Runs `build_runner` for freezed/json_serializable code generation.
    *   **Important**: After changing entity fields (adding `@freezed` classes or JSON-serializable fields), run this to regenerate `.freezed.dart` and `.g.dart` files.
*   `make watch` -> Watches for changes and auto-regenerates code.
*   `make analyze` -> Runs Flutter analyzer.

### 🎮 Steam Deck Development (Target)
*   **Connect**: `make deck-setup` (SSH Keygen).
*   **Debug**: `make deck-debug` (Deploy & Stream Logs).
*   **Quick Debug**: `make deck-debug-run` (Skip build, just deploy & run with logs).
*   **Hot Reload**:
    1.  `make deck-hot-setup` (Builds & Deploys)
    2.  `make deck-hot-start` (Starts app on Deck)
    3.  `make deck-hot-attach` (Connects Flutter Debugger)

---

## 5. Coding Standards

*   **Error Handling**: Use `Either<Failure, T>` from `dartz`. Do not throw exceptions in the Domain layer.
*   **Logging**: Use `LoggerService.instance`.
    *   `_logger.debug()`: Verbose details (looping through files).
    *   `_logger.info()`: High-level checkpoints ("Loaded 500 games").
    *   `_logger.error()`: Actual failures with stack traces.
*   **Paths**: Always access files via `PlatformService` (never hardcode `/home/deck`).

### Concurrency Patterns

**Completer for Deduplication:**
When a method can be called multiple times concurrently (like refresh), use a Completer to prevent duplicate work:
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
When doing I/O-heavy operations (size calculations, disk scans), limit concurrency:
```dart
const batchSize = 4; // or 8 for lighter operations
for (var i = 0; i < items.length; i += batchSize) {
  await Future.wait(items.skip(i).take(batchSize).map(process));
}
```

### Color Usage

**Always use GameColors:**
```dart
// GOOD
final color = GameColors.forSource(game.source);
final icon = GameColors.iconForSource(game.source);

// BAD - don't duplicate color logic
final color = switch (game.source) {
  GameSource.steam => Colors.blue,
  // ...
};
```

### Opacity Usage

**Always use AppOpacity constants:**
```dart
// GOOD
color.withValues(alpha: AppOpacity.muted)

// BAD - magic numbers
color.withValues(alpha: 0.5)
```

---

## 6. Releasing & Publishing

### Step 1: Update Version
1.  Open `pubspec.yaml`.
2.  Increment `version: x.y.z+n` (e.g., `1.0.1+2` -> `1.0.2+3`).
3.  Run `flutter pub get`.

### Step 2: Build Linux Release (Docker)
Since we are on Mac, we **MUST** use Docker to build the Linux binary (to link against the correct GLIBC version for Steam Deck).

```bash
make build-linux
```
*   **Input**: Source code in current directory.
*   **Output**: `build/game_size_manager_linux.zip`.
*   **Mechanism**: Runs `build_linux_on_mac.sh`, which uses a `linux/amd64` Docker container to compile.

### Step 3: Publish to GitHub
1.  Go to **GitHub Releases**.
2.  Draft a new release.
3.  **Tag**: `vX.Y.Z` (matching pubspec).
4.  **Title**: `vX.Y.Z - [Codename/Feature]`.
5.  **Description**: Add a changelog.
6.  **Attachments**: Upload the `game_size_manager_linux.zip` created in Step 2.
7.  **Publish**.

### Step 4: Verify Install Command
Users install via the "1-click" command in README. Ensure `install.sh` in the repository main branch is up to date if you changed installation logic.

**User Command**:
```bash
curl -fsSL https://raw.githubusercontent.com/tieorange/steam-deck-sideload-games-storage-manager/main/install.sh | bash
```

---

## 7. External Packages & Modules

### `steam_deck_games_detector`

The core game detection logic has been extracted into a separate Dart package to allow for reusability and cleaner architecture.

*   **Location**: `../steam_deck_games_detector` (relative to the app root).
*   **Repo**: [steam_deck_games_detector](https://github.com/tieorange/steam_deck_games_detector)
*   **Purpose**: Handles all logic for finding games, parsing manifests, and reading databases from Steam, Heroic, Lutris, etc.

#### How to Work With It (Local Development)

The app's `pubspec.yaml` uses a **path dependency** to allow for simultaneous development of the app and the package.

```yaml
dependencies:
  steam_deck_games_detector:
    path: ../steam_deck_games_detector
```

#### Workflow: Making Changes

1.  **Edit the Package**:
    *   Open `../steam_deck_games_detector` in your editor.
    *   Make changes to datasources, repositories, or entities.
    *   If you changed dependencies in the package, run `dart pub get` inside the package folder.

2.  **Apply Changes in App**:
    *   Because it's a path dependency, **changes are immediate**.
    *   **Hot Reload** in the main app often works, but if you changed method signatures or added new files, you likely need a **Hot Restart** or a full rebuild.
    *   If you added new exports to the package, run `flutter pub get` in the main app to refresh the analysis server.

3.  **Clean Architecture Mapping**:
    *   The App's `GameRepositoryImpl` (`lib/features/games/data/repositories/game_repository_impl.dart`) is the bridge.
    *   It calls `SteamDeckGamesDetector.getAllGames()`.
    *   It converts `package:steam_deck_games_detector` entities into the App's internal entities (if they differ, though we aim for 1:1 parity).

#### Publication
*   Eventually, this package will be published to `pub.dev`.
*   When that happens, we will switch `pubspec.yaml` from `path: ...` to `version: ^1.0.0`.

---

## 8. Core Services

Services are singleton utilities registered in DI for cross-cutting concerns. Located in `lib/core/services/`.

### OrphanedDataService
*   **Purpose**: Detect and clean orphaned compatdata/shadercache from uninstalled games.
*   **Location**: `lib/core/services/orphaned_data_service.dart`
*   **Key Methods**:
    *   `scan(List<Game>)` - Returns `List<OrphanedData>` of orphaned directories
    *   `cleanup(List<OrphanedData>)` - Returns `CleanupResult` with freed bytes
*   **How It Works**:
    1.  Scans ALL Steam library paths via `PlatformService.allSteamLibraryPaths`
    2.  Reads `appmanifest_*.acf` files to get installed app IDs and game names
    3.  Compares compatdata/shadercache folder IDs against installed IDs
    4.  Orphaned = exists on disk but not in any manifest
    5.  Detects symlinks (CryoUtilities) and skips them
    6.  Non-Steam shortcuts have IDs > 10 digits
*   **Warning**: Compatdata contains Proton prefixes with save files - must warn users!

### GameLaunchService
*   **Purpose**: Launch games via URI schemes.
*   **Location**: `lib/core/services/game_launch_service.dart`
*   **URI Schemes**:
    *   Steam: `steam://rungameid/{appid}`
    *   Heroic: `heroic://launch/{id}`
    *   Lutris: `lutris:rungame/{id}`
    *   OGI: Not supported (returns null)
*   **Key Methods**:
    *   `getLaunchUri(Game)` - Returns URI string or null
    *   `launch(Game)` - Launches via `xdg-open` (Linux) or `open` (macOS)
    *   `canLaunch(Game)` - Checks if launch is supported

### GameExportService
*   **Purpose**: Export game list for backup/sharing.
*   **Location**: `lib/core/services/game_export_service.dart`
*   **Formats**: JSON, CSV
*   **Output**: `~/Documents/game_library_{timestamp}.{json|csv}`
*   **Key Methods**:
    *   `exportToJson(List<Game>)` - Returns File
    *   `exportToCsv(List<Game>)` - Returns File

### DiskSizeService
*   **Purpose**: Calculate directory sizes efficiently.
*   **Location**: `lib/core/services/disk_size_service.dart`
*   **Method**: Uses `du -sb` on Linux for fast calculation, falls back to recursive file walk.

### UpdateService
*   **Purpose**: Check for and download app updates from GitHub releases.
*   **Location**: `lib/core/services/update_service.dart`

---

## 9. Theme Utilities

### GameColors (`lib/core/theme/game_colors.dart`)

Centralized source colors and icons - replaces duplicated `_getSourceColor()` methods.

| Method | Purpose |
|--------|---------|
| `GameColors.forSource(GameSource)` | Returns brand color for source |
| `GameColors.iconForSource(GameSource)` | Returns icon for source |
| `GameColors.nameForSource(GameSource)` | Returns display name |
| `GameColors.forSize(int bytes)` | Returns color based on size (green < 10GB, orange < 30GB, red >= 30GB) |
| `GameColors.forStoragePercent(double)` | Returns color based on usage percentage |

**Source Colors:**
*   Steam: `#1B2838` (dark blue)
*   Heroic: `#7B2D8B` (purple)
*   Lutris: `#FF6600` (orange)
*   OGI: `#2E7D32` (green)

**Rule**: All widgets MUST use GameColors instead of hardcoding colors.

### AppOpacity (`lib/core/theme/app_opacity.dart`)

Named constants replacing magic opacity values:

| Constant | Value | Use Case |
|----------|-------|----------|
| `subtle` | 0.1 | Very light backgrounds, source color tints |
| `light` | 0.2 | Disabled states, light borders |
| `muted` | 0.5 | Secondary text, inactive elements |
| `overlay` | 0.6 | Modal overlays, progress overlays |
| `elevated` | 0.7 | Selected states, container backgrounds |
| `prominent` | 0.8 | Active nav items, important backgrounds |
| `shadow` | 0.15 | Drop shadows |

### AppThemeMode (OLED Support)

Extended theme mode enum in `lib/features/settings/domain/entities/settings_entity.dart`:

| Mode | Description |
|------|-------------|
| `system` | Follow system preference |
| `light` | Always light theme |
| `dark` | Standard dark (`#1e1e1e` backgrounds) |
| `oled` | True black (`#000000`) for OLED displays |

OLED theme defined in `app_theme.dart` as `AppTheme.oledTheme`.

---

## 10. Core Widgets

Reusable UI components in `lib/core/widgets/`.

### Skeleton Loading (`skeleton_loading.dart`)

Shimmer skeleton placeholders for loading states:

| Widget | Purpose |
|--------|---------|
| `SkeletonLoading` | Base shimmer container with customizable width/height |
| `GameListItemSkeleton` | Single game list item skeleton |
| `GamesPageSkeleton` | Full games page skeleton (filter chips + 8 items) |
| `DashboardCardSkeleton` | Dashboard card loading state |
| `StoragePageSkeleton` | Storage page loading state |

**Rule**: Use skeletons instead of bare `CircularProgressIndicator` for better UX.

### Empty/Error States (`empty_state.dart`)

| Widget | Purpose |
|--------|---------|
| `EmptyState` | Icon + title + description + optional action button |
| `ErrorState` | Error icon + message + retry button |

Used when no data or errors occur. Always provide actionable next step.

---

## 11. Database Schema (v3)

**Location**: `lib/core/database/game_database.dart`

### Tables

#### `games`
| Column | Type | Notes |
|--------|------|-------|
| `id` | TEXT PRIMARY KEY | Game ID (e.g., `steam_1174180`) |
| `title` | TEXT NOT NULL | Display name |
| `source` | TEXT NOT NULL | Launcher enum name |
| `install_path` | TEXT NOT NULL | Full path |
| `size_bytes` | INTEGER NOT NULL | Disk usage |
| `icon_path` | TEXT | Nullable |
| `storage_location` | TEXT NOT NULL | `internal` or `sdcard` (default: `internal`) |
| `tag` | TEXT | User tag enum name (nullable) |

#### `cache_metadata`
| Column | Type | Notes |
|--------|------|-------|
| `key` | TEXT PRIMARY KEY | e.g., `last_refresh` |
| `value` | TEXT NOT NULL | Timestamp or other value |

#### `storage_snapshots`
| Column | Type | Notes |
|--------|------|-------|
| `id` | INTEGER PRIMARY KEY | Auto-increment |
| `timestamp` | TEXT NOT NULL | ISO 8601 datetime |
| `total_bytes` | INTEGER NOT NULL | Total disk space |
| `used_bytes` | INTEGER NOT NULL | Used disk space |
| `free_bytes` | INTEGER NOT NULL | Free disk space |
| `game_count` | INTEGER NOT NULL | Number of games |
| `games_total_size` | INTEGER NOT NULL | Total size of all games |

### Migrations

*   **v1 → v2**: Added `storage_location` column, `tag` column, `cache_metadata` table
*   **v2 → v3**: Added `storage_snapshots` table

### Key Methods

```dart
// Games CRUD
insertGames(List<Game>)      // Batch insert with transaction
deleteGame(String id)
deleteGamesBatch(List<String> ids)  // Efficient batch delete
clearGames()
getAllGames()

// Tags
updateGameTag(String gameId, GameTag? tag)

// Cache Metadata (TTL)
setMetadata(String key, String value)
getMetadata(String key)
getLastRefreshTime()
updateLastRefreshTime()

// Storage Snapshots
insertStorageSnapshot(...)
getStorageSnapshots({int limit = 30})
```

---

## 12. State Management

### GamesState (`lib/features/games/presentation/cubit/games_state.dart`)

Freezed union with states: `initial`, `loading`, `loaded`, `error`.

**GamesLoaded fields:**
| Field | Type | Default | Purpose |
|-------|------|---------|---------|
| `games` | `List<Game>` | required | All games |
| `filterSource` | `GameSource?` | null | Active source filter |
| `sortDescending` | `bool` | true | Sort direction |
| `searchQuery` | `String?` | null | Search text |
| `refreshProgress` | `RefreshProgressState?` | null | Refresh progress |
| `sortOption` | `SortOption` | `size` | Current sort mode |
| `filterTag` | `GameTag?` | null | Active tag filter |
| `lastRefresh` | `DateTime?` | null | Last refresh timestamp |

**Computed getters:**
| Getter | Returns | Purpose |
|--------|---------|---------|
| `displayedGames` | `List<Game>` | Filtered and sorted games |
| `allGames` | `List<Game>` | Unfiltered list (for operations like orphan scan) |
| `selectedGames` | `List<Game>` | Games with `isSelected=true` |
| `hasSelection` | `bool` | Any games selected? |
| `selectedSizeBytes` | `int` | Total size of selected games |

### SettingsState (`lib/features/settings/presentation/cubit/settings_state.dart`)

Freezed union with states: `initial`, `loading`, `loaded`, `error`.

**Settings entity fields:**
| Field | Type | Default | Purpose |
|-------|------|---------|---------|
| `themeMode` | `ThemeMode` | `dark` | Flutter theme mode |
| `appThemeMode` | `AppThemeMode` | `dark` | Extended theme (includes OLED) |
| `heroicConfigPath` | `String?` | null | Custom Heroic path override |
| `lutrisDbPath` | `String?` | null | Custom Lutris path override |
| `steamPath` | `String?` | null | Custom Steam path override |
| `ogiLibraryPath` | `String?` | null | Custom OGI path override |
| `confirmBeforeUninstall` | `bool` | true | Show confirmation dialog |
| `sortBySizeDescending` | `bool` | true | Default sort direction |
| `defaultViewMode` | `String` | `list` | `list` or `grid` |

---

## 13. Domain Entities

### GameTag (`lib/features/games/domain/entities/game_tag.dart`)

User-assignable categories for games:

| Tag | Label | Color | Icon |
|-----|-------|-------|------|
| `playing` | "Playing" | Green | `play_circle_outline` |
| `completed` | "Completed" | Blue | `check_circle_outline` |
| `backlog` | "Backlog" | Orange | `queue_outlined` |
| `favorite` | "Favorite" | Gold | `star_outline` |
| `canDelete` | "Can Delete" | Red | `delete_outline` |

Stored in SQLite `games.tag` column, preserved across refreshes.

### SortOption (`lib/features/games/domain/entities/sort_option.dart`)

Sort modes for games list:

| Option | Label | Behavior |
|--------|-------|----------|
| `size` | "Size" | By disk usage (default) |
| `name` | "Name" | Alphabetical |
| `source` | "Source" | By launcher |

### OrphanedData / OrphanedDataType

From `lib/core/services/orphaned_data_service.dart`:

**OrphanedDataType enum:**
| Type | Label | Risk |
|------|-------|------|
| `compatData` | "Proton Prefix (compatdata)" | **HIGH** - Contains save files! |
| `shaderCache` | "Shader Cache" | Low - Regenerates automatically |

**OrphanedData class fields:**
| Field | Type | Purpose |
|-------|------|---------|
| `path` | String | Full filesystem path |
| `appId` | String | Steam app ID |
| `gameName` | String | Resolved from manifest (may be empty) |
| `type` | OrphanedDataType | compatData or shaderCache |
| `sizeBytes` | int | Directory size |
| `isNonSteamShortcut` | bool | ID has 10+ digits |
| `libraryPath` | String | Which Steam library it's in |
| `isSymlink` | bool | Managed by CryoUtilities etc. |

**Computed properties:**
*   `label` - Display name (game name, or "Non-Steam Shortcut (ID)", or "AppID X")
*   `hasSaveDataRisk` - True if compatData type

---

## 14. Game Entity

The `Game` entity (`lib/features/games/domain/entities/game_entity.dart`) is the core domain model.

### Fields

| Field | Type | Default | Purpose |
|-------|------|---------|---------|
| `id` | `String` | required | Unique ID (e.g., `steam_1174180`) |
| `title` | `String` | required | Display name |
| `source` | `GameSource` | required | Launcher enum |
| `installPath` | `String` | required | Full path |
| `sizeBytes` | `int` | required | Disk usage (0 if not calculated) |
| `iconPath` | `String?` | null | Path to game icon |
| `launchOptions` | `String?` | null | Custom launch options |
| `protonVersion` | `String?` | null | Proton version |
| `storageLocation` | `StorageLocation` | `internal` | `internal` or `sdcard` |
| `isSelected` | `bool` | false | Selected for batch operations |
| `tag` | `GameTag?` | null | User-assigned tag |

### Extension Methods

**GameExtensions:**
*   `toggleSelected()` - Returns copy with flipped `isSelected`

**GameListExtensions:**
*   `totalSizeBytes` - Sum of all game sizes
*   `selectedGames` - Filter to `isSelected=true`
*   `selectedSizeBytes` - Total size of selected
*   `sortedBySize()` - Sort by size descending
*   `sortedBy(SortOption)` - Sort by given option
*   `filterBySource(GameSource?)` - Filter by launcher
*   `filterByTag(GameTag?)` - Filter by tag
