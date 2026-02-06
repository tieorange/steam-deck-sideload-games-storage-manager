# 🎮 Game Size Manager for Steam Deck

> **See how much space your games are taking up and manage storage easily!**

A beautiful app that shows you **all your installed games** from Steam, Heroic, Lutris, and more — with their **exact sizes** so you know what's eating your storage.

![Steam Deck Optimized](https://img.shields.io/badge/Steam%20Deck-Optimized-1a9fff?style=for-the-badge&logo=steam)
![Flutter](https://img.shields.io/badge/Flutter-Desktop-02569B?style=for-the-badge&logo=flutter)
![License](https://img.shields.io/github/license/tieorange/steam-deck-sideload-games-storage-manager?style=for-the-badge)

---

## 📑 Table of Contents

- [Features](#-features)
- [Install on Steam Deck](#-install-on-steam-deck)
- [Screenshots](#️-screenshots)
- [Feature Details](#-feature-details)
- [Supported Launchers](#-supported-launchers)
- [Configuration](#️-configuration)
- [For Developers](#️-for-developers)
- [Contributing](#-contributing)
- [Troubleshooting](#-troubleshooting)
- [License](#-license)

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 📂 **All Games in One Place** | Steam, Heroic, Lutris, OpenGameInstaller unified |
| 📊 **Storage Breakdown** | See exactly how much each game uses |
| 🎮 **Steam Deck UI** | Touch-friendly, gamepad-ready interface |
| ⚡ **Fast** | SQLite caching = instant load times |
| 🔍 **Smart Sorting** | Sort by size, name, or source |
| 🏷️ **Game Tags** | Mark games as Playing, Completed, Backlog, Favorite, or Can Delete |
| 🧹 **Orphaned Data Cleanup** | Find and remove leftover data from uninstalled games |
| 🚀 **Quick Launch** | Launch games directly from the app |
| 📤 **Export Library** | Export your game list to JSON or CSV |
| 🌙 **OLED Theme** | True black theme for Steam Deck OLED displays |
| 💾 **SD Card Support** | Shows which games are on internal vs SD card |
| 📈 **Storage History** | Track storage usage over time |

---

## 📥 Install on Steam Deck

### One-Line Install ⚡

Open **Konsole** (Desktop Mode) and paste:

```bash
curl -fsSL https://raw.githubusercontent.com/tieorange/steam-deck-sideload-games-storage-manager/main/install.sh | bash
```

**Done!** The app will be in your application menu.

### Manual Install

1. Download the latest `.zip` from [Releases](https://github.com/tieorange/steam-deck-sideload-games-storage-manager/releases)
2. Extract to `~/Applications/GameSizeManager`
3. Run: `~/Applications/GameSizeManager/game_size_manager`

### Uninstall

```bash
rm -rf ~/Applications/GameSizeManager
rm -rf ~/.local/share/game_size_manager
rm -f ~/.local/share/applications/game-size-manager.desktop
```

---

## 🖼️ Screenshots

*Screenshots coming soon!*

<!--
TODO: Add screenshots
1. Main games list view
2. Game tags and filtering
3. Storage breakdown page
4. Orphaned data cleanup dialog
5. Settings with theme options
-->

---

## 🔎 Feature Details

### Game Management

- **Unified Library**: View all games from Steam, Heroic, Lutris, and OGI in one list
- **Smart Sorting**: Sort by size (largest first), name (A-Z), or source
- **Filtering**: Filter by launcher or by user-assigned tags
- **Search**: Quickly find games by typing their name
- **Game Tags**: Organize your library with tags:
  - 🟢 **Playing** - Currently playing
  - 🔵 **Completed** - Finished games
  - 🟠 **Backlog** - Want to play later
  - ⭐ **Favorite** - Your favorites
  - 🔴 **Can Delete** - Mark for removal

### Storage Analysis

- **Size Visualization**: Color-coded sizes help identify space hogs
  - 🟢 Green: < 10 GB
  - 🟠 Orange: 10-30 GB
  - 🔴 Red: > 30 GB
- **Storage Breakdown**: See total usage by launcher
- **SD Card Detection**: Know which games are on internal storage vs SD card
- **Storage Snapshots**: Track how your storage usage changes over time

### Cleanup Tools

- **Orphaned Data Detection**: Find `compatdata` (Proton prefixes) and `shadercache` folders left behind by uninstalled games
- **Selective Cleanup**: Choose exactly which folders to remove — no all-or-nothing
- **Save Data Warnings**: Clear warnings when deleting folders that may contain save files
- **Symlink Aware**: Respects folders managed by tools like CryoUtilities

### Theming

| Theme | Description |
|-------|-------------|
| 🌙 **Dark** | Default dark theme |
| ☀️ **Light** | Light theme for bright environments |
| ⬛ **OLED** | True black (#000000) for Steam Deck OLED |
| 🔄 **System** | Follows your system preference |

---

## 📋 Supported Launchers

| Launcher | Detection | Artwork | Launch | Notes |
|----------|:---------:|:-------:|:------:|-------|
| 🎮 **Steam** | ✅ | ✅ | ✅ | Reads `libraryfolders.vdf`, supports SD card libraries |
| 🦸 **Heroic** | ✅ | ✅ | ✅ | Epic Games + GOG via Legendary |
| 🍷 **Lutris** | ✅ | ✅ | ✅ | Reads `pga.db`, supports Flatpak installation |
| 📦 **OGI** | ✅ | ❌ | ❌ | OpenGameInstaller library |

---

## ⚙️ Configuration

Access settings from the gear icon in the app.

| Setting | Description | Default |
|---------|-------------|---------|
| **Theme** | Light, Dark, OLED, or System | Dark |
| **Sort Direction** | Ascending or descending by default | Descending |
| **View Mode** | List or Grid layout | List |
| **Confirm Before Uninstall** | Show confirmation dialog | On |
| **Custom Launcher Paths** | Override default paths for Steam, Heroic, Lutris, OGI | Auto-detected |

### Custom Paths

If your launchers are installed in non-standard locations, you can override paths in Settings:

- **Steam Path**: Default `~/.steam/steam`
- **Heroic Config**: Default `~/.config/heroic`
- **Lutris Database**: Default `~/.local/share/lutris/pga.db`
- **OGI Library**: Default location auto-detected

---

## 🛠️ For Developers

### Quick Start

> **Note for Contributors**: Please read [`.agent/rules/Agents.md`](.agent/rules/Agents.md) for detailed architecture, coding standards, and AI agent guidelines.

**Requirements:** Flutter SDK, Docker Desktop (for Linux builds on macOS)

**Platform Support:**
- **Linux / Steam Deck**: Full support (primary target)
- **macOS**: Development mode with mock data
- **Windows**: Not currently supported (code contains forward-looking placeholders)

```bash
# Clone the repo
git clone https://github.com/tieorange/steam-deck-sideload-games-storage-manager.git
cd steam-deck-sideload-games-storage-manager
```

### Development Commands

```bash
# macOS Development
make run              # Run app on macOS
make gen              # Generate freezed/json_serializable code
make watch            # Watch and auto-regenerate code
make analyze          # Run Flutter analyzer
make clean            # Clean build artifacts

# Building
make build-linux      # Build Linux release via Docker (for Steam Deck)

# Steam Deck Deployment (via SSH)
make deck-setup       # One-time: Setup SSH keys
make deck-debug       # Build + deploy + run with logs
make deck-debug-run   # Quick run (no rebuild)
make deck-logs        # Stream logs from Steam Deck
make deck-shell       # SSH into Steam Deck

# Hot Reload on Steam Deck
make deck-hot-setup   # One-time: Build debug version & deploy
make deck-hot-start   # Terminal 1: Start app on Deck
make deck-hot-attach  # Terminal 2: Attach Flutter for hot reload
```

Run `make help` to see all available commands.

### Architecture Overview

The app follows **Clean Architecture** with clear separation of concerns:

```
lib/
├── core/           # Shared utilities, services, theme, database
├── features/
│   ├── games/      # Game list, detection, management
│   ├── settings/   # App configuration
│   └── storage/    # Storage analysis, cleanup
└── main.dart
```

**Key patterns:**
- **BLoC/Cubit** for state management
- **UseCases** for business logic (Cubits never call Repositories directly)
- **SQLite** for local caching with migrations
- **get_it** for dependency injection

### External Package

Game detection logic lives in a separate package for reusability:
- **Package**: [`steam_deck_games_detector`](https://github.com/tieorange/steam_deck_games_detector)
- **Usage**: Path dependency during development, will be published to pub.dev

---

## 🤝 Contributing

PRs welcome! Here's how to contribute effectively:

### Before You Start

1. Read [`.agent/rules/Agents.md`](.agent/rules/Agents.md) — the source of truth for architecture
2. Run `make analyze` before submitting PRs
3. Follow existing code patterns

### Code Style Guidelines

```dart
// Use GameColors for launcher-related colors
final color = GameColors.forSource(game.source);  // ✅
final color = Colors.blue;                         // ❌

// Use AppOpacity constants
color.withValues(alpha: AppOpacity.muted)  // ✅
color.withValues(alpha: 0.5)               // ❌

// Use PlatformService for file paths
final path = _platform.steamPath;          // ✅
final path = '/home/deck/.steam';          // ❌

// Use Either for error handling in domain layer
Future<Either<Failure, List<Game>>> getGames();  // ✅
Future<List<Game>> getGames();                   // ❌ (throws exceptions)
```

### What We Use

- **Flutter** with Clean Architecture
- **flutter_bloc** for state management
- **freezed** for immutable state classes
- **dartz** for functional error handling
- **sqflite** for local database
- **get_it** + **injectable** for DI

---

## ❓ Troubleshooting

### Games not showing up?

1. **Check launcher installation**: Ensure the launcher is installed in the default location
2. **Refresh the list**: Pull down on the games list to refresh
3. **Check custom paths**: If using non-standard locations, set custom paths in Settings
4. **Check logs**: Go to Settings > Share Logs to see detailed error information

### Orphaned data scan finds nothing?

This is good! It means you have no leftover data from uninstalled games. The scan checks:
- `compatdata` folders (Proton prefixes)
- `shadercache` folders (shader caches)

Note: Non-Steam shortcuts may appear as "Non-Steam Shortcut (ID)" since they don't have manifest files.

### App crashes on startup?

1. **Reset app data**: Delete `~/.local/share/game_size_manager/` and relaunch
2. **Check for updates**: Ensure you have the latest version from [Releases](https://github.com/tieorange/steam-deck-sideload-games-storage-manager/releases)
3. **Report the issue**: Open an issue on GitHub with logs from Settings > Share Logs

### Game sizes showing as 0?

- Size calculation happens in the background after initial load
- Pull down to refresh and recalculate sizes
- Very large games may show size calculations taking a while in progress

### Can't launch games?

- **Steam**: Should work automatically via `steam://` protocol
- **Heroic**: Requires Heroic to be running or installed
- **Lutris**: Requires Lutris to be installed
- **OGI**: Launch not currently supported

---

## 📄 License

MIT License — do whatever you want with it! 🎉

---

<p align="center">
  Made with ❤️ for the Steam Deck community
</p>
