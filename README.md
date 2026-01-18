# Game Size Manager (Steam Deck)

A Flutter application designed for the Steam Deck to manage disk space for games installed via non-Steam launchers (Heroic, Lutris, etc.).

## Features
- **Unified Library**: View games from Steam, Heroic, Lutris, and OpenGameInstaller in one place.
- **Disk Insight**: See exact install sizes and visual disk usage breakdowns.
- **Steam Deck Optimized**: Controller support, touch-friendly UI, and dark mode.
- **Database Caching**: Fast loading times with local SQLite caching.
- **Filters & Search**: Quickly find games by size or source.

## Building for Steam Deck (Linux) on macOS

This project includes a Docker workflow to cross-compile the Linux version on macOS/Windows.

### Prerequisites
- Docker Desktop installed and running.

### Build Command
Run the build script from the project root:

```bash
./build_linux_docker.sh
```

This will:
1. Build a Docker image with all Linux dependencies (GTK, Flutter, etc.).
2. Compile the Flutter app in release mode.
3. Extract the build artifacts to `build/game-size-manager-linux.zip`.

## Installation on Steam Deck
1. Extract the zip file to a folder (e.g., `~/Applications/GameSizeManager`).
2. Run the binary `steam-deck-sideload-games-storage-manager`.
3. (Optional) Add to Steam as a Non-Steam Game for Gaming Mode access.
