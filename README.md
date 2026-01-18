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

## 🔧 Remote Debugging on Steam Deck

For developers: quickly deploy and debug the app on your Steam Deck via SSH.

### Prerequisites
1. **SSH enabled on Steam Deck**: Gaming Mode → Settings → Developer → Enable SSH
2. **Same network**: Your Mac and Steam Deck must be on the same WiFi/LAN
3. **Desktop Mode**: Switch to Desktop Mode for GUI app debugging
4. **Allow X display**: Run `xhost +` in Konsole on Steam Deck (once per session)

### Quick Start

```bash
# 1. One-time setup - generates SSH keys
make deck-setup

# 2. Build, deploy, and run with live logs
make deck-debug

# 3. Quick debug (skip build, with live logs) ⭐ MOST USED
make deck-debug-run
```

### All Commands

| Command | Build | Run Mode | Time | Use Case |
|---------|-------|----------|------|----------|
| `make deck` | - | Interactive menu | - | First time / exploration |
| `make deck-setup` | - | - | ~30s | One-time SSH key setup |
| `make deck-deploy` | ✅ | Deploy only | ~90s | Just deploy, don't run |
| `make deck-debug` | ✅ | Live logs | ~90s | After code changes |
| `make deck-debug-run` | ❌ | Live logs | ~5s | Quick re-run with logs |
| `make deck-run` | ❌ | Background | ~5s | Run without logs |
| `make deck-logs` | - | - | - | View logs of background app |
| `make deck-shell` | - | - | - | SSH into Steam Deck |

### Developer Workflow

#### Example 1: Initial Development
```bash
# Develop locally first (instant hot reload)
make run

# When ready to test on Steam Deck
make deck-debug
```

#### Example 2: Debugging a Crash
```bash
# App crashed, want to see what happened
make deck-debug-run   # Re-run with live logs (~5s)
```

#### Example 3: After Code Changes
```bash
# Made changes to lib/*.dart
make deck-debug       # Rebuild + deploy + run (~90s)
```

#### Example 4: Testing Same Build Multiple Times
```bash
# First run
make deck-debug

# App crashed, re-run same build
make deck-debug-run   # Skip build (~5s)

# Check stored logs
make deck-logs
```

### Configuration

Edit `scripts/steamdeck_deploy.dart` to change:
- `host` - Steam Deck hostname (default: `steamdeck.local`)
- `user` - SSH user (default: `deck`)
- `appDir` - Install location (default: `~/Applications/GameSizeManager`)

---

## 📜 License

This project is open source. Feel free to contribute!
