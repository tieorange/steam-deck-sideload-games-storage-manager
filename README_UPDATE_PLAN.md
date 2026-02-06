# README.md Update Plan

This document outlines all the changes needed to bring README.md up to date with the current feature set.

---

## 1. Features Section - Major Updates Needed

The current "What It Does" section is missing many new features. Update the table:

### Current Features (keep):
- All Games in One Place
- Storage Breakdown
- Steam Deck UI
- Fast (SQLite caching)
- Smart Sorting

### Missing Features (add):

| Feature | Description |
|---------|-------------|
| 🏷️ **Game Tags** | Mark games as Playing, Completed, Backlog, Favorite, or Can Delete |
| 🧹 **Orphaned Data Cleanup** | Find and remove leftover compatdata/shadercache from uninstalled games |
| 🚀 **Quick Launch** | Launch games directly from the app (Steam, Heroic, Lutris) |
| 📤 **Export Library** | Export your game list to JSON or CSV |
| 🌙 **OLED Theme** | True black theme for OLED Steam Deck displays |
| 🔍 **Search & Filter** | Search by name, filter by launcher or tag |
| 💾 **SD Card Support** | Shows which games are on internal vs SD card storage |
| 📈 **Storage History** | Track storage usage over time with snapshots |

---

## 2. Screenshots Section

Current: "Coming soon"

**Action**: Either:
- Add actual screenshots (recommended)
- Remove section until screenshots are available
- Add placeholder text explaining what the app looks like

Suggested screenshots:
1. Main games list view
2. Game details/actions
3. Storage page
4. Settings page with theme options
5. Orphaned data cleanup dialog

---

## 3. New Section: Key Features Detail

Add a more detailed breakdown after the quick features table:

### 3.1 Game Management
- View all games from all launchers in one unified list
- Sort by size, name, or source
- Filter by launcher (Steam, Heroic, Lutris, OGI)
- Filter by user tags
- Search games by name

### 3.2 Storage Analysis
- See exact disk usage per game
- Color-coded sizes (green < 10GB, orange < 30GB, red >= 30GB)
- Total storage breakdown by launcher
- SD card vs internal storage distinction

### 3.3 Cleanup Tools
- **Orphaned Data Detection**: Find compatdata and shadercache folders from uninstalled games
- **Selective Cleanup**: Choose exactly which folders to remove
- **Safe Warnings**: Clear warnings when save data might be at risk

### 3.4 Theming
- Dark mode (default)
- Light mode
- OLED mode (true black for Steam Deck OLED)
- System preference following

---

## 4. Supported Launchers Section - Expand

Current table is good but could add:
- SD card detection note
- Art/icon support status
- Launch support status

| Launcher | Detection | Art | Launch | Notes |
|----------|-----------|-----|--------|-------|
| 🎮 Steam | ✅ | ✅ | ✅ | Reads libraryfolders.vdf, supports SD card |
| 🦸 Heroic | ✅ | ✅ | ✅ | Epic + GOG via Legendary |
| 🍷 Lutris | ✅ | ✅ | ✅ | Reads pga.db, supports Flatpak |
| 📦 OGI | ✅ | ❌ | ❌ | OpenGameInstaller library |

---

## 5. Installation Section - Minor Updates

Current instructions are good. Consider adding:
- Minimum SteamOS version (if any)
- Note about Desktop Mode requirement for install
- Uninstall instructions

---

## 6. For Developers Section - Expand

### 6.1 Add Quick Start Commands
```bash
# Development (macOS)
make run              # Run on macOS
make gen              # Generate freezed/json code
make watch            # Watch and auto-regenerate
make analyze          # Run Flutter analyzer

# Steam Deck Deployment
make deck-setup       # One-time SSH setup
make deck-debug       # Build + deploy + run with logs
make deck-debug-run   # Quick run (no rebuild)
make deck-hot-setup   # Setup hot reload
make deck-hot-attach  # Attach for hot reload
```

### 6.2 Add Architecture Overview
Brief mention of:
- Clean Architecture with UseCases
- BLoC/Cubit state management
- SQLite caching with migrations
- Separate game detection package

### 6.3 Link to Agents.md
Already there, but emphasize it's the source of truth for contributors.

---

## 7. Contributing Section - Expand

Current is minimal. Add:

### Before Contributing
- Read `.agent/rules/Agents.md` for architecture details
- Run `make analyze` before submitting PRs
- Follow existing code patterns

### Code Style
- Use `GameColors` for all source-related colors
- Use `AppOpacity` constants instead of magic numbers
- Use `PlatformService` for all file paths
- Use `Either<Failure, T>` for error handling in domain layer

---

## 8. New Section: Configuration

Add a section about app settings:

| Setting | Description | Default |
|---------|-------------|---------|
| Theme | Light, Dark, OLED, or System | Dark |
| Sort Direction | Ascending or descending | Descending |
| View Mode | List or Grid | List |
| Confirm Uninstall | Show confirmation dialog | On |
| Custom Paths | Override default launcher paths | None |

---

## 9. New Section: Troubleshooting / FAQ

### Games not showing up?
- Ensure the launcher is installed in the default location
- Try refreshing the game list (pull down)
- Check if custom paths are needed in Settings

### Orphaned data scan finds nothing?
- This is good! It means no leftover data from uninstalled games
- Non-Steam shortcuts may show as "Non-Steam Shortcut (ID)"

### App crashes on startup?
- Delete `~/.local/share/game_size_manager/` and relaunch
- Report the issue with logs from Settings > Share Logs

---

## 10. Badges Section - Add More

Consider adding:
- ![Version](https://img.shields.io/github/v/release/...)
- ![License](https://img.shields.io/github/license/...)
- ![Downloads](https://img.shields.io/github/downloads/...)
- ![Last Commit](https://img.shields.io/github/last-commit/...)

---

## 11. General Improvements

### 11.1 Add Table of Contents
For easier navigation in longer README.

### 11.2 Add GIF/Video
A short demo GIF would be more engaging than static screenshots.

### 11.3 Consistent Emoji Usage
Current emojis are good, maintain consistency.

### 11.4 Links
- Link to GitHub Issues for bug reports
- Link to Discussions for feature requests
- Link to Releases for changelog

---

## Action Items Checklist

- [ ] Update features table with new features (tags, cleanup, launch, export, OLED)
- [ ] Add or remove screenshots section
- [ ] Add detailed features breakdown section
- [ ] Expand supported launchers table with art/launch columns
- [ ] Add uninstall instructions
- [ ] Expand developer commands section
- [ ] Expand contributing guidelines
- [ ] Add configuration/settings section
- [ ] Add troubleshooting/FAQ section
- [ ] Add more badges (version, license, downloads)
- [ ] Add table of contents
- [ ] Review and update all links

---

## Priority Order

1. **High**: Update features table (users need to know what the app does)
2. **High**: Add screenshots or remove placeholder
3. **Medium**: Expand developer section (for contributors)
4. **Medium**: Add troubleshooting section (reduces support burden)
5. **Low**: Add more badges (cosmetic)
6. **Low**: Add table of contents (nice-to-have for longer README)
