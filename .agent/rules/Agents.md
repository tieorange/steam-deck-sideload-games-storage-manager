# 🤖 Game Size Manager - AI Agent Guide

This document is the **Source of Truth** for AI agents working on this codebase. It defines the architecture, workflows, and technical details required to contribute effectively.

> **⚠️ CRITICAL RULE FOR AGENTS:**
> 1. **Read-First**: Always read this document at the start of a task to understand the architecture.
> 2. **Auto-Maintain**: If you modify the Project Architecture, Build System, or key implementation details (e.g., add a new GameSource, change how icons work, or modify native code), **YOU MUST UPDATE THIS DOCUMENT** before finishing your task.
>    - Do not let this documentation drift from reality.
>    - Treat this file as code. If the code changes, this file must change.

---

## 1. Project Overview

**Game Size Manager** is a Flutter application for **Steam Deck** (Linux) and **Oculus Quest** (Android). It aggregates installed games/apps to help users visualize and manage their disk usage.

*   **Tech Stack**: Flutter (MacOS for dev, Linux/Android for targets), Dart, Kotlin (Android native).
*   **Target Devices**:
    *   Steam Deck (Arch Linux-based SteamOS) - 1280x800 (16:10)
    *   Oculus Quest 2/3 (Android 14) - 2D panel app (Landscape, Tablet-like layout)
    *   Android phones/tablets

---

## 2. Architecture & Design Patterns

The project closely adheres to **Clean Architecture** principles to separate concerns and ensure testability. usage of `UseCases` is **mandatory** for business logic.

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

### Dependency Injection (DI)
*   **Package**: `get_it` with `injectable` (manually registered in `lib/core/di/injection.dart`).
*   **Pattern**: Service Locator pattern used in `main.dart`, but Constructor Injection used everywhere else.
*   **Platform Detection**: DI uses `Platform.isLinux` / `Platform.isAndroid` to register correct implementations.
*   **Setup**:
    *   `sl()` is the global instance.
    *   Register `UseCases` as singletons.
    *   Register `Cubits` via `registerFactory`.

### Platform Abstraction (GameSourceService)
The app uses a platform abstraction layer to support different game sources:

*   **Interface**: `lib/core/services/game_source_service.dart`
*   **Impementations**:
    *   **Linux**: `SteamDeckGameSource` wraps `steam_deck_games_detector` package
    *   **Android**: `QuestGameSource` uses MethodChannel to native Kotlin
*   **Architecture**: `GameRepositoryImpl` depends on abstract `GameSourceService`, not concrete implementations

---

## 3. Launchers & technical Details

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

### 🥽 Android / Oculus Quest
*   **Source**: `lib/features/games/data/datasources/quest_game_source.dart`
*   **Native Code**: `android/app/src/main/kotlin/.../MainActivity.kt`
*   **Detection Method**:
    *   Uses `PackageManager.getInstalledApplications()` to list all apps
    *   Filters out system apps without launchers
*   **Source Classification**:
    *   `getInstallerPackageName()` returns:
        *   `com.oculus.mobilestore` / `com.oculus.ocms` → **Meta Store**
        *   `null` / `com.android.shell` → **Sideloaded**
        *   `com.android.vending` → **Play Store**
*   **Size Retrieval**:
    *   Uses `StorageStatsManager.queryStatsForPackage()` (API 26+)
    *   Returns `appBytes + dataBytes + cacheBytes`
    *   Fallback: APK file size if Usage Stats permission not granted
*   **App Icons**:
    *   Fetches via `PackageManager.getApplicationIcon()`, encoded as base64 PNG.
    *   **Managed via**: `flutter_launcher_icons` (Material Design).
*   **Uninstall**:
    *   Supported via `Intent(Intent.ACTION_DELETE)`.
    *   Requires `GameSourceService.uninstallGame()` to delegate to native method.
*   **Required Permissions** (in `AndroidManifest.xml`):
    *   `QUERY_ALL_PACKAGES` - enumerate all installed packages (Android 11+)
    *   `PACKAGE_USAGE_STATS` - access StorageStatsManager (requires user grant in Settings)

---

## 4. Workflows

### 💻 Mac Development (Host)
*   `make run` -> Runs app on MacOS.
*   `make build-linux` -> Builds Linux Release via Docker (Required for Steam Deck compatibility).
*   `make gen` -> Runs `build_runner` (freezed/json_serializable).

### 🎮 Steam Deck Development (Target)
*   **Connect**: `make deck-setup` (SSH Keygen).
*   **Debug**: `make deck-debug` (Deploy & Stream Logs).
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
*   **Mechanism**: Runs `build_linux_docker.sh`, which uses a `linux/amd64` Docker container to compile.

### Step 3: Publish to GitHub
1.  Go to **GitHub Releases**.
2.  Draft a new release.
3.  **Tag**: `vX.Y.Z` (matching pubspec).
4.  **Title**: `vX.Y.Z - [Codename/Feature]`.
5.  **Description**: Add a changelog (use emojis!).
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

#### workflow: Making Changes

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
