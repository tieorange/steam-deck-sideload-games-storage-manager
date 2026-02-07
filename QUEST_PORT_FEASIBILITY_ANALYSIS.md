# Feasibility Analysis: Porting Rookie Sideloader to a Standalone Meta Quest App

## Executive Summary

**Verdict: YES, it is technically feasible** to create a standalone Android app for Meta Quest 2/3 that replicates the core functionality of Rookie Sideloader (browsing, downloading, and installing Quest games directly from the headset without a PC). However, it requires a complete rewrite — not a port — due to fundamental platform differences. Several working precedents already exist (Quest APK Installer, APKPure in-headset, etc.), proving the concept is viable.

---

## 1. What Rookie Sideloader Actually Does (Architecture Breakdown)

After deep analysis of the source code, Rookie's pipeline is:

```
[Game Catalog] → [Download via rclone] → [Extract 7z] → [Install APK via ADB] → [Push OBB files via ADB]
```

### Core Components Analyzed

| Component | File | What It Does |
|-----------|------|--------------|
| **Game Catalog** | `MainForm.cs` | Fetches `vrp-public.json` config from GitHub/fallback, then uses rclone to list games from cloud storage. Games stored as semicolon-delimited metadata (name, package, version, size). |
| **Config/Mirror System** | `PublicConfig.cs`, `GetDependencies.cs` | Downloads `vrp-public.json` with `baseUri` and base64-encoded password. Mirrors auto-switch on quota errors. |
| **Download Engine** | `RCLONE.cs` | Shells out to `rclone.exe` (Windows binary) with HTTP config pointing to cloud mirrors. Uses `--rc` flag for progress stats via localhost:5572 API. |
| **Extraction** | `Zip.cs` | Uses 7z.exe/7z.dll to extract password-protected `.7z.001` split archives. |
| **APK Installation** | `ADB.cs`, `Sideloader.cs` | Installs APKs via `adb install` / `AdvancedSharpAdbClient`. Pushes OBB files to `/sdcard/Android/obb/<package>/`. |
| **UI** | `MainForm.cs`, `GalleryView.cs` | Windows Forms (WinForms) — completely Windows-specific. |

### Key Insight: Every Single Component is Windows-Specific
- **rclone.exe** — Windows x86/x64 binary
- **7z.exe / 7z.dll** — Windows native libraries
- **adb.exe** — Windows platform-tools
- **WinForms UI** — Zero Android compatibility
- **System.Management** (WMI) — Windows-only API
- **.NET Framework 4.5.2** — Not available on Android

---

## 2. What Needs to Change for a Quest-Native App

### 2.1 Download Engine (replacing rclone)

**Rookie's approach:** Shells out to `rclone.exe` with cloud storage configs (Google Drive, HTTP mirrors).

**Quest-native replacement options:**

| Option | Feasibility | Notes |
|--------|------------|-------|
| **rclone ARM64 binary** | HIGH | rclone has official Linux ARM64 builds that work on Android. Projects like [RCX](https://github.com/x0b/rcx) and [Round-Sync](https://github.com/newhinton/Round-Sync) already run rclone on Android. Could shell out to the binary or embed it. |
| **OkHttp / Retrofit** | HIGH | For the HTTP/public mirror path, standard Android HTTP clients work. The public config uses simple HTTP downloads — no special rclone protocol needed. |
| **Android DownloadManager** | MEDIUM | System-level download manager. Handles large files, progress, resume. But less control. |

**Recommendation:** For the public mirror path (`:http:` rclone remote), plain HTTP downloads via OkHttp are sufficient. The rclone config just wraps an HTTP base URL + password. For private mirror configs, embed the rclone ARM64 binary.

### 2.2 Extraction (replacing 7z.exe)

**Rookie's approach:** Uses `7z.exe` / `7z64.exe` to extract password-protected split 7z archives.

**Quest-native replacement options:**

| Option | Feasibility | Notes |
|--------|------------|-------|
| **Apache Commons Compress** | HIGH | Java library supporting 7z format including password-protected archives. |
| **p7zip / 7zip ARM64** | HIGH | Native ARM64 builds of 7-zip exist for Linux/Android. Can be bundled and invoked via `ProcessBuilder`. |
| **NDK wrapper around LZMA SDK** | MEDIUM | Build native extraction using the LZMA SDK C code via Android NDK. More work but maximum control. |

**Recommendation:** Bundle a `7za` ARM64 binary (widely available) or use Apache Commons Compress for pure Java extraction.

### 2.3 APK Installation (replacing ADB)

This is the most critical difference. **Rookie installs via ADB from a PC to a connected device. A Quest-native app installs locally on itself.**

**Quest-native approach:**

| Method | Feasibility | Notes |
|--------|------------|-------|
| **Android `PackageInstaller` API** | HIGH | Standard Android API since API 21. Creates a session, streams APK data, commits. User gets a confirmation prompt. Requires `REQUEST_INSTALL_PACKAGES` permission. **Already proven to work on Quest** (Quest APK Installer by Anagan79 does exactly this). |
| **`ACTION_INSTALL_PACKAGE` Intent** | HIGH | Simpler legacy approach. Launches system installer UI. Works on Quest. |
| **Root-based `pm install`** | LOW | Quest isn't rooted by default. Not viable for general use. |

**Key permission:** `REQUEST_INSTALL_PACKAGES` in `AndroidManifest.xml`. On first use, Quest prompts the user to allow "Install Unknown Apps" for your app. This is a one-time toggle in Settings.

### 2.4 OBB File Placement (replacing `adb push`)

**Rookie's approach:** `adb push` files to `/sdcard/Android/obb/<package>/`

**Quest-native approach:**

| Method | Feasibility | Notes |
|--------|------------|-------|
| **Standard File I/O** | HIGH on Android ≤12 | Before Android 13, apps with `WRITE_EXTERNAL_STORAGE` can write to `/sdcard/Android/obb/`. Quest 2 runs Android 10-based firmware. |
| **`MANAGE_EXTERNAL_STORAGE`** | HIGH | For Android 11+ scoped storage. Grants broad file access. User must grant in settings. |
| **SAF (Storage Access Framework)** | MEDIUM | More complex but works across all Android versions. |

**Quest-specific note:** Since Quest runs a modified Android, and sideloaded apps already operate in "developer mode," file access to `/sdcard/Android/obb/` has been confirmed to work with proper permissions. ManageXR and similar enterprise tools do this routinely.

### 2.5 UI (replacing WinForms)

Complete rewrite required. Options:

| Framework | Suitability for Quest |
|-----------|----------------------|
| **Native Android (Kotlin/Java)** | Best. Runs as 2D panel app in Quest home. Proven by Quest APK Installer, SideQuest in-headset, etc. |
| **Jetpack Compose** | Good. Modern Android UI toolkit. Works as 2D Quest app. |
| **Flutter** | Possible but untested on Quest specifically. |
| **React Native** | Possible but adds complexity. |
| **Unity/Unreal (VR-native)** | Overkill for a file manager. Would create a full 3D environment for what is essentially a list + download buttons. |

**Recommendation:** Native Android with Jetpack Compose. Runs as a standard 2D Android app on Quest, appearing in "Unknown Sources." Simple, lightweight, proven.

---

## 3. Proof That This Works: Existing Precedents

Several tools already prove each piece of this puzzle works on Quest:

| Tool | What It Proves |
|------|---------------|
| **[Quest APK Installer](https://anagan79.itch.io/quest-apk-installer)** (Anagan79) | Installing APK + XAPK/OBB directly from headset works. Scans local storage, installs via PackageInstaller. Works on firmware v74+. |
| **APKPure (via Quest Browser)** | Downloading APKs from the web and installing them on Quest works without PC. |
| **[QRookie](https://github.com/glaumar/QRookie)** | A Linux/macOS alternative that downloads from the same VRP public mirrors. Proves the API/mirror system can be consumed by non-Windows clients. |
| **[RCX](https://github.com/x0b/rcx) / [Round-Sync](https://github.com/newhinton/Round-Sync)** | rclone runs on Android ARM64. Cloud storage download on Android is solved. |
| **SideQuest In-Headset** | Full app store running natively on Quest. Downloads and installs apps. |
| **ManageXR** | Enterprise MDM that pushes APKs + OBBs to Quest programmatically. Confirms OBB file placement works. |

---

## 4. Technical Architecture for a Quest-Native App

```
┌─────────────────────────────────────────┐
│          Quest-Native App (Kotlin)       │
│                                          │
│  ┌──────────┐  ┌─────────┐  ┌────────┐ │
│  │ Game      │  │Download │  │Install │ │
│  │ Browser   │  │Manager  │  │Manager │ │
│  │ (Compose) │  │(OkHttp) │  │(PkgInst│ │
│  └─────┬────┘  └────┬────┘  └───┬────┘ │
│        │            │            │       │
│  ┌─────▼────────────▼────────────▼────┐ │
│  │         Core Service Layer          │ │
│  │  - Fetch vrp-public.json (HTTP)     │ │
│  │  - Parse game catalog (rclone cat)  │ │
│  │  - Download archives (HTTP/rclone)  │ │
│  │  - Extract 7z (7za ARM64 binary)    │ │
│  │  - Install APK (PackageInstaller)   │ │
│  │  - Copy OBB (File I/O)             │ │
│  └────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

### Step-by-Step Flow

1. **Startup:** Fetch `vrp-public.json` from GitHub raw URL (plain HTTPS GET)
2. **Load catalog:** Use rclone ARM64 binary or HTTP to fetch `games.meta` (semicolon-delimited game list)
3. **Display:** Show game list in a Jetpack Compose LazyColumn with search/filter
4. **Download:** HTTP GET from `baseUri + "/" + gameNameHash + "/"` — download the `.7z.001` split archives
5. **Extract:** Invoke bundled `7za` ARM64 binary with password from config
6. **Install APK:** Use Android `PackageInstaller` session API — user confirms via system dialog
7. **Place OBB:** Copy OBB files to `/sdcard/Android/obb/<package.name>/` via standard file I/O
8. **Cleanup:** Delete downloaded archives

### Required Android Permissions

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

---

## 5. Challenges and Risks

### 5.1 Storage Space
- Quest 2 has 64/128/256 GB. Quest 3 has 128/512 GB.
- VR games can be 2-10+ GB. Need to download + extract (2x space temporarily).
- **Mitigation:** Stream extraction, delete archives immediately after extraction, show clear space warnings (Rookie already does this logic).

### 5.2 Android Scoped Storage (Android 11+)
- Newer Quest firmware may tighten OBB directory access.
- **Mitigation:** Use `MANAGE_EXTERNAL_STORAGE` permission. Since the app is sideloaded (not from Meta Store), there's no Play Store policy enforcement blocking this permission.

### 5.3 Meta Firmware Updates
- Meta could block `REQUEST_INSTALL_PACKAGES` for sideloaded apps, or restrict "Unknown Sources."
- **Mitigation:** This would break ALL sideloading tools (SideQuest, etc.), so it's unlikely. Quest APK Installer by Anagan79 explicitly confirmed it works on firmware v74 (Feb 2025).

### 5.4 Mirror/API Stability
- The VRP public mirror system uses rclone HTTP configs with base64-encoded passwords.
- **Mitigation:** The QRookie project (Linux/macOS) already consumes these same mirrors without Windows rclone, proving cross-platform viability.

### 5.5 Performance
- ARM processors on Quest are mobile-class (Snapdragon XR2 Gen 1/2).
- 7z extraction of multi-GB archives is CPU-intensive.
- **Mitigation:** Use native ARM64 7za binary (not Java extraction). Run on background thread. Quest XR2 Gen 2 is quite capable.

### 5.6 No ADB Needed
- The entire ADB layer in Rookie becomes unnecessary since the app runs ON the Quest.
- `PackageInstaller` replaces `adb install`.
- `File.copy()` replaces `adb push`.
- This actually **simplifies** the architecture significantly.

---

## 6. Effort Estimate (Rough Component Breakdown)

| Component | Complexity | Notes |
|-----------|-----------|-------|
| Config fetcher (vrp-public.json) | Low | Simple HTTP GET + JSON parse |
| Game catalog parser | Low | Parse semicolon-delimited text |
| Game browser UI | Medium | LazyColumn with search, filter, gallery |
| Download manager | Medium | OkHttp + progress tracking + resume support |
| 7z extraction | Low-Medium | Bundle 7za ARM64, invoke via ProcessBuilder |
| APK installer | Medium | PackageInstaller session API with user confirmation |
| OBB file manager | Low | File copy to known path |
| Mirror switching | Low | Error detection + URL swap logic |
| Settings/persistence | Low | SharedPreferences or DataStore |
| **Total** | **Medium** | ~3000-5000 lines of Kotlin |

---

## 7. Conclusion

Creating a standalone Quest app that replicates Rookie's functionality is **clearly feasible** and is arguably **easier** than the PC version because:

1. **No ADB complexity** — the app installs directly on itself
2. **No driver issues** — no USB debugging, no Windows drivers
3. **Simpler user experience** — browse → tap → install, all in VR
4. **Proven precedents** — Quest APK Installer, QRookie, and others already demonstrate every individual capability

The main work is a **clean rewrite in Kotlin/Android**, not a port of the C#/WinForms code. The Rookie codebase is valuable as a **reference for understanding the mirror/download protocol**, but none of its actual code can be reused.

### Key Technical Decisions

1. **Language:** Kotlin (standard Android)
2. **UI:** Jetpack Compose (2D panel app on Quest)
3. **Downloads:** OkHttp for HTTP mirrors; optionally bundle rclone ARM64 for private configs
4. **Extraction:** Bundle `7za` ARM64 binary
5. **Installation:** Android `PackageInstaller` API
6. **OBB:** Direct file I/O with `MANAGE_EXTERNAL_STORAGE`

---

## Sources & References

- [Quest APK Installer by Anagan79](https://anagan79.itch.io/quest-apk-installer)
- [QRookie - Linux/macOS alternative to Rookie](https://github.com/glaumar/QRookie)
- [RCX - Rclone for Android](https://github.com/x0b/rcx)
- [Round-Sync - Android cloud file manager powered by rclone](https://github.com/newhinton/Round-Sync)
- [Android PackageInstaller API](https://developer.android.com/reference/android/content/pm/PackageInstaller)
- [Meta Quest Apps Must Target Android 12L](https://developers.meta.com/horizon/blog/meta-quest-apps-android-12l-june-30/)
- [Meta Quest 3 Android API Level](https://techoverflow.net/2025/02/09/meta-quest-3-which-android-api-level-sdk-version-to-use/)
- [QuestSide - APK/OBB Installer for Mobile](https://github.com/HAX05/QuestSide---APK-OBB-Installer-for-Mobile)
- [How to Install Android Apps on Meta Quest 3/3s](https://www.ytechb.com/how-to-install-android-apps-on-meta-quest-3-3s/)
- [vvb2060/PackageInstaller](https://github.com/vvb2060/PackageInstaller)
- [VRPirates/rookie source code](https://github.com/VRPirates/rookie)
