# 🎮 Game Size Manager (Steam Deck)

> **Manage your sideloaded game storage with ease.**  
> Compatible with **Steam**, **Heroic**, **Lutris**, and **OpenGameInstaller**.

A Flutter application designed specifically for the **Steam Deck** to help you visualize, sort, and manage disk space for all your games in one unified library.

---

## ✨ Features

- **📂 Unified Library**  
  View games from Steam, Heroic, Lutris, and OpenGameInstaller in a single list.

- **📊 Storage Visualization**  
  See exact installation sizes and get a visual breakdown of your disk usage.

- **🎮 Steam Deck Optimized**  
  Designed with the Deck in mind:
  - Full controller/gamepad navigation support.
  - Touch-friendly UI interface.
  - Beautiful dark mode aesthetics.

- **🚀 Performance**  
  Built with local SQLite caching for instant load times.

- **🔍 Smart Filtering**  
  Quickly find games by size ("Largest First"), source, or name.

---

## 📥 Installation on Steam Deck

You can install the latest version with a single command! 🚀  
Open the **Konsole** (terminal) and run:

```bash
curl -fsSL https://raw.githubusercontent.com/tieorange/steam-deck-sideload-games-storage-manager/main/install.sh | bash
```

**What this does:**
1. 📥 Downloads the latest release from GitHub.
2. 🔨 Installs it to `~/Applications/GameSizeManager`.
3. 🖥️ Creates a shortcut in your application menu for easy access.

---

## 🛠️ Building for Steam Deck (Linux) on macOS

If you want to contribute or build it yourself, this project includes a Docker workflow to cross-compile the Linux version on macOS Apple Silicon.

### Prerequisites
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running.

### Build Command
Run the build script from the project root:

```bash
./build_linux_docker.sh
```

**The Build Process:**
1. 🐳 Builds a Docker image with all Linux dependencies (GTK, Flutter, etc.).
2. ⚙️ Compiles the Flutter app in **release mode** (x64 architecture).
3. 📦 Extracts the build artifacts to `build/game-size-manager-linux.zip`.

---

## 📜 License

This project is open source. Feel free to contribute!
