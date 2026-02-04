# Game Size Manager - Improvement Plan

Comprehensive plan based on deep analysis of the entire codebase (85 Dart files, all layers).

---

## 1. Codebase Refactoring

### 1.1 Eliminate Duplicated Color Logic
`_getSourceColor()` and `_getSizeColor()` are copy-pasted across `game_list_item.dart`, `game_grid_item.dart`, `game_details_page.dart`, and `dashboard_page.dart`. Extract into a `GameSource` extension or `GameColors` utility in `core/theme/`.

### 1.2 Fix SearchGamesUsecase Anti-Pattern
The only synchronous use case that takes the full games list as input instead of going through the repository. Either move filtering into the cubit directly (it's simple enough) or make it query the SQLite cache with a `LIKE` clause for consistency.

### 1.3 Batch Delete in GameLocalDatasource
`deleteGames()` loops individual DELETE queries. Replace with a single `DELETE FROM games WHERE id IN (...)` using a batch operation.

### 1.4 Concurrent Refresh Protection
`refreshGames()` can be called multiple times simultaneously, causing race conditions on the SQLite cache. Add an `_isRefreshing` flag or a `Completer` to deduplicate concurrent calls.

### 1.5 Store StorageLocation in SQLite
The `storageLocation` field (internal vs SD card) is lost when loading from cache - every game defaults to `StorageLocation.internal`. Add a `storage_location TEXT` column to the schema.

### 1.6 SQLite Transactions for Cache Updates
`insertGames()` doesn't wrap the batch in a transaction. If the app crashes mid-write, the cache is partially corrupted. Wrap in `db.transaction()`.

### 1.7 Extract Shared Widget Base for GameListItem / GameGridItem
These two widgets share ~80% of their logic (animation controllers, selection handling, source colors, icon rendering). Extract a `GameItemBase` mixin or shared builder.

### 1.8 Consolidate Opacity Magic Numbers
`.withValues(alpha: 0.1)`, `.withValues(alpha: 0.5)`, etc. scattered everywhere. Define named opacity constants in theme (e.g., `kSubtleOpacity`, `kMutedOpacity`).

---

## 2. New Features for Users

### 2.1 Game Cover Art Display (High Impact)
The app currently shows tiny fallback icons. The infrastructure for art fetching already exists in the detector package (Steam grid images, Heroic SHA256 cached art, Lutris coverart). Surface these as proper cover images:
- List view: show art thumbnail alongside game name
- Grid view: show full cover art card (like Steam library)
- Details page: hero banner with cover art background

### 2.2 Move Game to SD Card / Internal (Killer Feature)
The Storage page already has a "Move Games" button showing a "coming soon" dialog. Implement:
- Copy game directory to target drive
- Update launcher config files (Steam `libraryfolders.vdf`, Heroic config)
- Delete original after verified copy
- Show progress with transfer speed

### 2.3 Game Launch Integration
Add a "Play" button that launches games directly:
- Steam: `steam://rungameid/{appid}`
- Heroic: `heroic://launch/{app_name}`
- Lutris: `lutris:rungame/{slug}`
- Show last played date if available from launcher configs

### 2.4 Storage Predictions / "What If" Calculator
"If I uninstall these 3 games, I'll free 45GB - enough for Cyberpunk (40GB) but not Elden Ring (50GB)."
- Check-select games to see running total of freed space
- Compare against known game sizes from Steam API or local manifests

### 2.5 Game Categories / Tags
Allow users to tag games (e.g., "Playing", "Finished", "To Try", "Keep", "Can Delete"). Stored locally in SQLite. Filterable in the games list. Helps users decide what to uninstall.

### 2.6 Disk Usage Timeline / History
Track storage snapshots over time. Show a line chart of "disk usage over time" on the Dashboard. Helps users see trends.

### 2.7 Duplicate / Orphaned Data Detection
Scan for:
- Shader caches that can be safely deleted
- Proton/Wine prefixes for uninstalled games (orphaned compat data)
- Duplicate game installations across drives
- Show potential savings with one-click cleanup

### 2.8 Import / Export Game List
Export installed games list as CSV/JSON for:
- Backup before factory reset
- Sharing setup with friends
- Tracking collection across devices

### 2.9 Game Size Comparison with Store
For Steam games, fetch expected install size from Steam API and compare with actual disk usage. Flag games significantly larger than expected (shader caches, mods, etc.).

### 2.10 Notifications / Alerts
- Alert when disk usage exceeds threshold (e.g., 90%)
- Suggest games to uninstall based on size and last-played date
- Notify when games haven't been played in X days

---

## 3. UI/UX Improvements

### 3.1 Skeleton Loading States
Replace bare `CircularProgressIndicator` on Dashboard, Storage, and Settings pages with shimmer skeleton screens that match the final layout.

### 3.2 Better Empty States
"No games found" is not helpful. Replace with:
- Illustration/icon + explanation (no launchers detected?)
- Action button ("Refresh", "Check launcher paths in Settings")
- First-run onboarding explaining what the app does

### 3.3 Swipe Actions on Game List Items
- Swipe left: Quick uninstall
- Swipe right: Open game details
- Long press: Multi-select mode

### 3.4 Pull-to-Refresh on Games Page
Natural gesture for refreshing, in addition to the toolbar button.

### 3.5 Game Size Visualization
Replace plain text size with visual indicators:
- Color-coded size badges (green < 10GB, yellow < 30GB, red > 30GB)
- Proportional bar showing game size relative to total disk
- Treemap view option (rectangles sized by game - like WinDirStat)

### 3.6 Onboarding / First-Run Experience
- Welcome screen explaining what the app does
- Auto-detect which launchers are installed
- Show detected games count before main screen
- Quick tutorial overlay for key features

### 3.7 Responsive Layout for Desktop / Docked Mode
When Steam Deck is docked (1080p/4K), adapt:
- Two-column layout (games list + details side-by-side)
- Larger grid with more columns
- Use `LayoutBuilder` / `MediaQuery` for breakpoints

### 3.8 Sorting Options Expansion
Currently only "by size". Add:
- Alphabetical (A-Z, Z-A)
- By launcher source
- By storage location
- By install path

### 3.9 Batch Operations Bar Improvements
- Running total of selected games' size
- "Select all from [source]" quick action
- "Select games larger than X GB" filter

### 3.10 OLED Black Theme
True #000000 background for OLED Steam Deck - saves battery. Also add accent color picker.

### 3.11 Haptic Feedback
Vibration for selection toggle, uninstall confirmation, refresh complete, error states.

### 3.12 Accessibility
- `Semantics()` wrappers on all interactive widgets
- Screen reader labels for game items, sizes, actions
- High contrast mode support

---

## 4. Architecture & Technical

### 4.1 Add Test Coverage
Priority tests:
- Unit: `GameRepositoryImpl` (cache logic, error handling)
- Unit: All use cases
- Widget: `GameListItem`, `UninstallConfirmDialog`
- Integration: Full refresh -> display flow

### 4.2 Cache TTL / Staleness Detection
- `last_refresh` timestamp in database
- Auto-refresh if cache older than threshold
- Show "last updated X minutes ago" in UI

### 4.3 Throttle Parallel Size Calculations
`Future.wait()` for all games saturates I/O on SD cards. Use semaphore pattern to limit concurrent directory walks (max 4).

### 4.4 Localization Infrastructure
Set up `easy_localization` or Flutter `intl`. Extract all hardcoded strings. Even if English-only initially, enables future translations.

### 4.5 State Restoration
On restart, restore: scroll position, active filters, search query, view mode.

### 4.6 CI/CD Enhancements
- Add lint + test step to CI
- Automated changelog generation
- Artifact size tracking per release
- Flatpak build target

---

## 5. Performance

### 5.1 Lazy Size Calculation with Priority Queue
Calculate visible games first, then background-calculate the rest. Users see results faster.

### 5.2 Incremental Cache Updates
Diff detected games against cache instead of clear-and-refill. Only insert new, update changed, delete removed.

### 5.3 Image Caching for Game Art
Local file cache with thumbnails to avoid re-reading large images from disk.

---

## 6. Distribution & Reach

### 6.1 Flatpak Packaging
Distribute via Flathub for easier installation. More discoverable than curl-pipe-bash.

### 6.2 Decky Loader Plugin
Companion plugin for SteamOS Game Mode overlay - storage warnings without leaving a game.

### 6.3 AUR Package
For Arch Linux users, publish to AUR for `yay`/`paru` installation.

---

## Priority Matrix

| # | Item | Impact | Effort | Priority |
|---|------|--------|--------|----------|
| 1 | Game Cover Art Display | High | Medium | P0 |
| 2 | Orphaned Data Cleanup | High | Medium | P0 |
| 3 | Better Empty/Error States | Medium | Low | P1 |
| 4 | Extract duplicated color logic | Medium | Low | P1 |
| 5 | Concurrent refresh protection | Medium | Low | P1 |
| 6 | Game Categories/Tags | High | Medium | P1 |
| 7 | Skeleton Loading States | Medium | Low | P1 |
| 8 | Move Game to SD Card | High | High | P2 |
| 9 | OLED Black Theme | Medium | Low | P2 |
| 10 | Sorting Options | Medium | Low | P2 |
| 11 | Test Coverage | High | High | P2 |
| 12 | Cache TTL | Medium | Low | P2 |
| 13 | Game Launch Integration | High | Medium | P2 |
| 14 | Localization Infrastructure | Low | Medium | P3 |
| 15 | Flatpak Packaging | Medium | Medium | P3 |
