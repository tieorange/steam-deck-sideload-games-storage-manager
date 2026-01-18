---
description: Steam Deck Hot Reload Setup
---

# Steam Deck Fast Iteration Workflow

This enables **fast code-change-to-test cycles** when developing on Steam Deck.

> **Note**: True Flutter hot reload (pressing `r`) requires Flutter installed on Steam Deck and a debug build. This workflow provides a faster alternative using incremental Docker builds and rsync.

---

## Quick Start

### One-Time Setup

```bash
make deck-hot-setup
```

This builds and deploys the app to Steam Deck.

---

## Development Workflow

### Two Terminals Pattern

**Terminal 1: Keep app running with logs**
```bash
make deck-hot-start
```

**Terminal 2: Rebuild and deploy changes**
```bash
make deck-hot-attach
```

### After Making Changes

Just run `make deck-hot-attach` again! It will:
1. Rebuild (Docker layer caching makes this fast ~10-20s)
2. Sync only changed files via rsync  
3. Kill and restart the app automatically

---

## What Makes This Fast?

1. **Docker layer caching** - Only your Dart code rebuilds, not the entire Flutter SDK
2. **rsync** - Only transfers changed files (~2s for code changes)
3. **Automatic restart** - App restarts immediately after sync

---

## Alternative: Single Command

If you prefer one command that does everything:

```bash
make deck-debug
```

This builds, deploys, runs, and streams logs all in one terminal.

---

## Troubleshooting

**"Cannot connect to Steam Deck"**
- Check Steam Deck is in Desktop Mode
- Verify: `ping steamdeck.local`
- Check SSH: `make deck-shell`

**Build is slow**
- First build is slow (~60s), subsequent builds are faster (~15-30s)
- Docker caches Flutter SDK layers

**Want to view logs?**
```bash
make deck-logs
```
