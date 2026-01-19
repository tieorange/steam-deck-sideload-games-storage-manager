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

### 🦸 Heroic Games Launcher (Epic & GOG)
*   **Source**: `lib/features/games/data/datasources/heroic_datasource.dart`
*   **Epic Games**: Parses `installed.json` (managed by Legendary).
    *   **Path**: `~/.config/heroic/legendaryConfig/legendary/installed.json`
*   **GOG**: Parses `gog_store/library.json` (Heroic's cache).

### 🍷 Lutris
*   **Source**: `lib/features/games/data/datasources/lutris_datasource.dart`
*   **Database**: SQLite file at `~/.local/share/lutris/pga.db`.
*   **Query**: Select from `games` table where `installed = 1` and `directory` is not null.

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
