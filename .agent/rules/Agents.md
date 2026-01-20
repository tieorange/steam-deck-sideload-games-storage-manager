# 🤖 Game Size Manager - AI Agent Guide

This document is the **Source of Truth** for AI agents working on this codebase. It defines the architecture, workflows, and technical details required to contribute effectively.

> **⚠️ CRITICAL RULE FOR AGENTS:**
> If you make changes to the Project Architecture, Build System, or key Technical Approaches (e.g. changing how a launcher is detected), **YOU MUST UPDATE THIS DOCUMENT**.
> Do not let this documentation drift from reality. Treat it as part of the code.

---

## 1. Project Overview

**Game Size Manager** is a Flutter desktop application for **Steam Deck** (Linux). It aggregates installed games from multiple launchers to help users visualize and manage their disk performance.

*   **Tech Stack:** Flutter (MacOS for dev, Linux for target), Dart.
*   **Target Device:** Steam Deck (Arch Linux-based SteamOS).
*   **Resolution:** Optimized for 1280x800 (16:10).

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
*   **Setup**:
    *   `sl()` is the global instance.
    *   Register `UseCases` as singletons.
    *   Register `Cubits` via `registerFactory`.

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
    *   **Priority 2 (Default)**: Checks `appcache/librarycache` for cached images (e.g., `[APPID]_library_600x900.jpg`).

### 🦸 Heroic Games Launcher (Epic & GOG)
*   **Source**: `lib/features/games/data/datasources/heroic_datasource.dart`
*   **Epic Games**: Parses `installed.json` (managed by Legendary).
    *   **Path**: `~/.config/heroic/legendaryConfig/legendary/installed.json`
*   **GOG**: Parses `gog_store/library.json` (Heroic's cache).
*   **Art Fetching**:
    *   **SHA256 Hashing**: Heroic caches images using the **SHA256 hash of the image URL** as the filename.
    *   **Metadata Source**: We read `store_cache/legendary_library.json` (Epic) to look up the `art_square` URL, hash it, and check `~/.config/heroic/images-cache`.
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
