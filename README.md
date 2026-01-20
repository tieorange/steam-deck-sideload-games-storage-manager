# 🎮 Game Size Manager for Steam Deck

> **See how much space your games are taking up and manage storage easily!**

A beautiful app that shows you **all your installed games** from Steam, Heroic, Lutris, and more — with their **exact sizes** so you know what's eating your storage.

![Steam Deck Optimized](https://img.shields.io/badge/Steam%20Deck-Optimized-1a9fff?style=for-the-badge&logo=steam)
![Flutter](https://img.shields.io/badge/Flutter-Desktop-02569B?style=for-the-badge&logo=flutter)

---

## ✨ What It Does

| Feature | Description |
|---------|-------------|
| 📂 **All Games in One Place** | Steam, Heroic, Lutris, OpenGameInstaller unified |
| 📊 **Storage Breakdown** | See exactly how much each game uses |
| 🎮 **Steam Deck UI** | Touch-friendly, gamepad-ready, beautiful dark mode |
| ⚡ **Fast** | SQLite caching = instant load times |
| 🔍 **Smart Sorting** | Sort by size, name, or source |

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

---

## 🖼️ Screenshots

*Coming soon*

---

## 🛠️ For Developers

### Build from Source
 
> **Note for Contributors**: Please read [`.agent/rules/Agents.md`](.agent/rules/Agents.md) for detailed architecture, launcher integration specs, and AI agent guidelines.

**Requirements:** Docker Desktop (must be running).

```bash
# Clone the repo
git clone https://github.com/tieorange/steam-deck-sideload-games-storage-manager.git
cd steam-deck-sideload-games-storage-manager

# Build for Steam Deck (Linux) on macOS
# This uses Docker to compile the app and creates 'game_size_manager_linux.zip'
make build-linux
# OR directly:
./build_linux_on_mac.sh
```

### Remote Debug on Steam Deck

Quick deploy and test on your Steam Deck via SSH:

```bash
# One-time setup
make deck-setup

# Build + Deploy + Run with logs
make deck-debug

# Just re-run (no rebuild) 
make deck-debug-run
```

See all commands with `make help`.

---

## 📋 Supported Launchers

| Launcher | Status | Notes |
|----------|--------|-------|
| 🎮 Steam | ✅ Full | Reads from `libraryfolders.vdf` |
| 🦸 Heroic | ✅ Full | Epic + GOG games |
| 🍷 Lutris | ✅ Full | Reads from `pga.db` |
| 📦 OpenGameInstaller | ✅ Full | OGI library |

---

## 🤝 Contributing

PRs welcome! The app uses:
- **Flutter** with clean architecture
- **BLoC** for state management
- **SQLite** for local caching

---

## 📄 License

MIT License - do whatever you want with it! 🎉
