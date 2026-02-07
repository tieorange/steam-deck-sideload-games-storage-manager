# Research: Building a Standalone Meta Quest Game Sideloader

This document captures all research findings from analyzing the VRPirates/rookie sideloader and the QRookie alternative, along with Meta Quest platform research. It is intended as context for AI coding assistants (Claude Code, Cursor) building a Flutter-based Quest app.

---

## Table of Contents

1. [Source Repositories Analyzed](#1-source-repositories-analyzed)
2. [Rookie Sideloader Architecture (Windows/C#)](#2-rookie-sideloader-architecture)
3. [QRookie Architecture (Linux-macOS/C++/Qt)](#3-qrookie-architecture)
4. [The Exact Wire Protocol](#4-the-exact-wire-protocol)
5. [Game List Data Format](#5-game-list-data-format)
6. [Download Protocol Deep Dive](#6-download-protocol-deep-dive)
7. [Extraction Protocol](#7-extraction-protocol)
8. [Installation Protocol (ADB-based — for reference only)](#8-installation-protocol)
9. [Meta Quest Platform Research](#9-meta-quest-platform-research)
10. [Flutter on Meta Quest](#10-flutter-on-meta-quest)
11. [APK Installation from Within an Android App](#11-apk-installation-from-within-an-android-app)
12. [OBB File Placement from Within an Android App](#12-obb-file-placement)
13. [Existing Precedent Tools](#13-existing-precedent-tools)
14. [Key Technical Decisions for the Flutter App](#14-key-technical-decisions)
15. [Critical Gotchas and Pitfalls](#15-critical-gotchas)
16. [Open Questions and Risks](#16-open-questions-and-risks)

---

## 1. Source Repositories Analyzed

### VRPirates/rookie (Rookie Sideloader)
- **URL:** https://github.com/VRPirates/rookie
- **Language:** C# (.NET Framework 4.5.2)
- **UI:** Windows Forms (WinForms)
- **Platform:** Windows only
- **Version analyzed:** 3.0
- **License:** GPL
- **Key source files analyzed:**
  - `Program.cs` — Entry point
  - `MainForm.cs` (358KB) — Main UI controller, download/install pipeline
  - `Sideloader.cs` — Core sideloading logic (APK install, OBB push, uninstall)
  - `ADB.cs` (37KB) — Android Debug Bridge wrapper using AdvancedSharpAdbClient
  - `RCLONE.cs` (16KB) — rclone process wrapper for cloud storage download/upload
  - `Sideloader/RCLONE.cs` — Game list initialization, metadata management, mirror handling
  - `Sideloader/GetDependencies.cs` (16KB) — Dependency download (ADB, rclone, WebView2)
  - `Models/PublicConfig.cs` — JSON config model with base64 password decoding
  - `Utilities/DnsHelper.cs` (20KB) — DNS fallback with Cloudflare proxy
  - `Utilities/Zip.cs` — 7z extraction wrapper
  - `Utilities/SettingsManager.cs` (13KB) — JSON-based settings persistence

### glaumar/QRookie
- **URL:** https://github.com/glaumar/QRookie
- **Language:** C++ with Qt/QML
- **Platform:** Linux, macOS (Flatpak available)
- **License:** GPL-3.0
- **Key source files analyzed:**
  - `src/vrp_public.cpp` — Config fetching and parsing
  - `src/vrp_manager.cpp` — Main orchestration (metadata, download, extract, install pipeline)
  - `src/http_downloader.cpp` — HTTP download engine with resume support
  - `src/device_manager.cpp` — ADB-based device management and APK installation
  - `src/models/game_info.h` — Game data structure

**QRookie is the most valuable reference** because it reimplements the same protocol in a non-Windows environment using plain HTTP instead of rclone configs, proving the protocol can be consumed without rclone.

---

## 2. Rookie Sideloader Architecture

### High-Level Pipeline
```
[Fetch Config] → [Download Metadata] → [Parse Game List] → [Download Game Archives] → [Extract 7z] → [Install APK via ADB] → [Push OBB via ADB]
```

### Dependencies (all Windows-only)
| Dependency | Purpose | Version |
|-----------|---------|---------|
| rclone.exe | Cloud storage download/upload | v1.72.1 |
| adb.exe | Android device communication | bundled platform-tools |
| 7z.exe / 7z64.exe | Archive extraction | bundled |
| WebView2 | Embedded browser for trailers | Microsoft Edge runtime |
| AdvancedSharpAdbClient | .NET ADB protocol client | v3.5.15 |
| Newtonsoft.Json | JSON parsing | v13.0.3 |

### Config System
Rookie supports two modes:
1. **Public Config mode** — Uses `vrp-public.json` from GitHub, downloads via HTTP through rclone's `:http:` remote
2. **Private mirror mode** — Uses `vrp.download.config` rclone config file with named remotes (Google Drive, etc.)

The public config mode is simpler and is what QRookie reimplements. This is the mode our Flutter app should target.

### Key Code: Config Fetching (GetDependencies.cs:17-61)
```
Primary URL:   https://raw.githubusercontent.com/vrpyou/quest/main/vrp-public.json
Fallback URL:  https://vrpirates.wiki/downloads/vrp-public.json
```

### Key Code: Metadata Download (Sideloader/RCLONE.cs:58-64)
```csharp
// Public config path — downloads meta.7z via rclone HTTP remote
string rclonecommand = $"sync \":http:/meta.7z\" \"{Environment.CurrentDirectory}\"";
RCLONE.runRcloneCommand_PublicConfig(rclonecommand);
// This is equivalent to: HTTP GET {baseUri}/meta.7z with User-Agent: rclone
```

### Key Code: Game ID Hash Computation (MainForm.cs:3821-3833)
```csharp
string gameNameHash = string.Empty;
using (MD5 md5 = MD5.Create())
{
    byte[] bytes = Encoding.UTF8.GetBytes(gameName + "\n");  // gameName = release_name
    byte[] hash = md5.ComputeHash(bytes);
    StringBuilder sb = new StringBuilder();
    foreach (byte b in hash)
    {
        _ = sb.Append(b.ToString("x2"));
    }
    gameNameHash = sb.ToString();
}
```

**CRITICAL:** The `gameName` variable here contains the **release_name** from the game list (e.g., "Beat Saber v1.35.0 +2OBBs"), and the trailing `\n` (newline) is appended before hashing. This is confirmed in both Rookie and QRookie.

### Key Code: Game Download (MainForm.cs:3893-3898)
```csharp
// Public config download path
string rclonecommand =
    $"copy \":http:/{gameNameHash}/\" \"{downloadDirectory}\" {extraArgs} --progress --rc {bandwidthLimit}";
gameDownloadOutput = RCLONE.runRcloneCommand_PublicConfig(rclonecommand);
// Equivalent to: HTTP GET {baseUri}/{gameNameHash}/{filename} for each file
```

### Key Code: Extraction (MainForm.cs:4133)
```csharp
Zip.ExtractFile($"{settings.DownloadDir}\\{gameNameHash}\\{gameNameHash}.7z.001", $"{settings.DownloadDir}", PublicConfigFile.Password);
// Calls 7z.exe with: x archive.7z.001 -aoa -o{outputDir} -p{password}
```

### Key Code: Mirror Switching (MainForm.cs:3269-3315)
When download fails with quota/auth errors, Rookie cycles through available mirrors by incrementing `remotesList.SelectedIndex`. After exhausting all mirrors, it shows an error and exits.

### Column Indices (Sideloader/RCLONE.cs:17-24)
```csharp
public static int GameNameIndex = 0;
public static int ReleaseNameIndex = 1;
public static int PackageNameIndex = 2;
public static int VersionCodeIndex = 3;
public static int ReleaseAPKPathIndex = 4;
public static int VersionNameIndex = 5;   // Also used as size in some contexts
public static int DownloadsIndex = 6;
public static int InstalledVersion = 7;
```

Note: In `VRP-GameList.txt` (the public metadata), the columns are slightly different from the private mirror format. The public format has `size` at index 5 (see QRookie parsing below).

---

## 3. QRookie Architecture

### Pipeline
```
[Fetch vrp-public.json] → [Download meta.7z] → [Extract meta.7z] → [Parse VRP-GameList.txt]
                                                                          ↓
[Compute game MD5 ID] → [Fetch directory listing] → [Download .7z parts] → [Extract with password] → [Install via ADB]
```

### Key Difference from Rookie
QRookie does NOT use rclone at all. It uses plain HTTP requests with `User-Agent: rclone/v1.65.2` header. This proves the entire protocol can be consumed with standard HTTP clients.

### Data Structure (game_info.h)
```cpp
struct GameInfo {
    QString name;           // Display name (e.g., "Beat Saber")
    QString release_name;   // Full release name (e.g., "Beat Saber v1.35.0 +2OBBs")
    QString package_name;   // Android package (e.g., "com.beatgames.beatsaber")
    QString version_code;   // Numeric version (e.g., "1350")
    QString last_updated;   // Date string (e.g., "2024-01-15")
    QString size;           // Size in MB as string (e.g., "2048")
};
```

### Status State Machine (vrp_manager.cpp)
QRookie tracks game status through these states:
```
Downloadable → Queued → Downloading → Decompressing → Local/Installable → Installing → InstalledAndLocally
                                  ↘ DownloadError      ↘ DecompressionError    ↘ InstallError

Also: UpdatableRemotely, UpdatableLocally, InstalledAndRemotely
```

### Persistence
QRookie saves game status to `{data_path}/games_info.json` — a JSON array of game objects with their current status. On restart, it loads this and resumes any queued downloads.

---

## 4. The Exact Wire Protocol

### Step 1: Fetch Public Config

**Request:**
```http
GET https://vrpirates.wiki/downloads/vrp-public.json HTTP/1.1
```

**Response:**
```json
{
  "baseUri": "https://some-mirror-server.example.com",
  "password": "c29tZXBhc3N3b3Jk"
}
```

- `baseUri` — HTTP base URL. All subsequent file downloads use this as the root URL.
- `password` — **Base64-encoded** string. Decode it to get the 7z archive password.

**Source evidence:**
- QRookie `vrp_public.cpp:37` uses URL `https://vrpirates.wiki/downloads/vrp-public.json`
- QRookie `vrp_public.cpp:89` decodes: `QString(QByteArray::fromBase64(obj["password"].toString().toUtf8()))`
- Rookie `GetDependencies.cs:26` uses primary URL `https://raw.githubusercontent.com/vrpyou/quest/main/vrp-public.json` with fallback to `https://vrpirates.wiki/downloads/vrp-public.json`
- Rookie `PublicConfig.cs:19` decodes: `Encoding.UTF8.GetString(Convert.FromBase64String(value))`

### Step 2: Download Metadata Archive

**Request:**
```http
GET {baseUri}/meta.7z HTTP/1.1
User-Agent: rclone/v1.65.2
```

**Response:** Binary 7z archive file.

**Source evidence:**
- QRookie `http_downloader.cpp:68` sets header: `request.setHeader(QNetworkRequest::UserAgentHeader, "rclone/v1.65.2")`
- QRookie `vrp_manager.cpp:142` downloads: `http_downloader_.download("meta.7z")`
- Rookie `Sideloader/RCLONE.cs:61-63` uses rclone command: `sync ":http:/meta.7z" "{dir}"`
- The `--http-url` flag in Rookie's `RCLONE.cs:282` passes `baseUri` to rclone, which makes it `GET {baseUri}/meta.7z`

### Step 3: Extract Metadata

**Command:**
```bash
7za x meta.7z -aoa -o{dataDir} -p{decodedPassword}
```

- `-aoa` — Overwrite all existing files without prompt
- `-o{dir}` — Output directory
- `-p{pw}` — Archive password (the decoded base64 string from Step 1)

**Output files:**
```
{dataDir}/VRP-GameList.txt              ← Main game catalog
{dataDir}/.meta/thumbnails/{pkg}.jpg    ← Game thumbnail images
{dataDir}/.meta/notes/{pkg}.txt         ← Game descriptions (optional)
{dataDir}/.meta/nouns                   ← Additional metadata (optional)
```

**Source evidence:**
- QRookie `vrp_manager.cpp:147-150`: `p7za.start(P7ZA, {"x", "{cache}/meta.7z", "-aoa", "-o{data}", "-p{password}"})`
- Rookie `Sideloader/RCLONE.cs:100`: `Zip.ExtractFile(metaArchive, metaRoot, MainForm.PublicConfigFile.Password)`

### Step 4: Parse Game List

**File:** `VRP-GameList.txt`

**Format:** Semicolon-separated values. First line is a header (skip it).

```
Game Name;Release Name;Package Name;Version Code;Last Updated;Size
Beat Saber;Beat Saber v1.35.0 +2OBBs;com.beatgames.beatsaber;1350;2024-01-15;2048
Superhot VR;Superhot VR v1.0.0;com.superhot.vr;100;2023-06-01;1024
```

**Columns (0-indexed):**
| Index | Field | Example | Notes |
|-------|-------|---------|-------|
| 0 | name | Beat Saber | Human-readable display name |
| 1 | release_name | Beat Saber v1.35.0 +2OBBs | Full release identifier — **used for hash computation** |
| 2 | package_name | com.beatgames.beatsaber | Android package name |
| 3 | version_code | 1350 | Numeric version code for comparison |
| 4 | last_updated | 2024-01-15 | Date string |
| 5 | size | 2048 | Size in MB (as string) |

**Source evidence:**
- QRookie `vrp_manager.cpp:190-214` — Splits line by `;`, reads parts[0] through parts[5]
- Rookie `Sideloader/RCLONE.cs:128-142` — Same: `line.Split(';')`, skips header, adds to list

**Note:** Rookie's `Sideloader/RCLONE.cs` defines indices 0-7 (`GameNameIndex=0` through `InstalledVersion=7`), but the public VRP-GameList.txt only has 6 columns (0-5). The extra columns (6-7) appear to be used only in the private mirror format or populated at runtime.

### Step 5: Compute Game Download ID

**Algorithm:** MD5 hash of `release_name + "\n"` (UTF-8 encoded)

```
Input:  "Beat Saber v1.35.0 +2OBBs\n"   (literal newline appended)
Output: "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6"  (32-char hex string)
```

**Source evidence (BOTH codebases agree exactly):**
- QRookie `vrp_manager.cpp:228-232`:
  ```cpp
  QCryptographicHash hash(QCryptographicHash::Md5);
  hash.addData((release_name + "\n").toUtf8());
  return hash.result().toHex();
  ```
- Rookie `MainForm.cs:3822-3832`:
  ```csharp
  byte[] bytes = Encoding.UTF8.GetBytes(gameName + "\n");
  byte[] hash = md5.ComputeHash(bytes);
  // ... format as lowercase hex
  ```

**CRITICAL: The trailing newline `\n` is required.** Without it, the hash won't match and downloads will fail.

### Step 6: List Game Files (Directory Listing)

**Request:**
```http
GET {baseUri}/{gameId}/ HTTP/1.1
User-Agent: rclone/v1.65.2
```

**Response:** HTML page with a `<pre>` tag containing a directory listing.

Example content inside `<pre>`:
```
../
a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6.7z.001           18-Dec-2023 01:46   524288000
a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6.7z.002           18-Dec-2023 01:48   524288000
a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6.7z.003           18-Dec-2023 01:50   123456789
```

**Parsing regex:**
```
^(../)?([0-9a-z]+\.7z\.\d+)\s+.*\s+(\d+)$
```
- Capture group 1: Optional `../` (ignore)
- Capture group 2: Filename (e.g., `a1b2c3d4.7z.001`)
- Capture group 3: File size in bytes

**Source evidence:**
- QRookie `http_downloader.cpp:113-148`:
  ```cpp
  QUrl url = base_url_ + dir_path + "/";  // Note trailing slash
  request.setHeader(QNetworkRequest::UserAgentHeader, "rclone/v1.65.2");
  // Parse <pre> tag, apply regex
  QRegularExpression re(R"_(^(../)?([0-9a-z]+\.7z\.\d+)+.*\s+(\d+)$)_");
  ```

### Step 7: Download Game Archive Parts

For each file from the directory listing:

**Request:**
```http
GET {baseUri}/{gameId}/{filename} HTTP/1.1
User-Agent: rclone/v1.65.2
Range: bytes={offset}-         ← Only if resuming a partial download
```

**Resume support:**
- QRookie saves files as `{filename}.tmp` during download
- On resume, checks `.tmp` file size and sends `Range: bytes={size}-` header
- After complete download, renames `.tmp` to final filename

**Source evidence:**
- QRookie `http_downloader.cpp:39-111`:
  ```cpp
  QUrl url = base_url_ + file_path;
  request.setHeader(QNetworkRequest::UserAgentHeader, "rclone/v1.65.2");
  if (downloaded_bytes_ > 0) {
      request.setRawHeader("Range", QString("bytes=%1-").arg(downloaded_bytes_).toUtf8());
  }
  ```

**Download directory structure:**
```
{cacheDir}/{gameId}/
    {gameId}.7z.001    (up to ~500MB each)
    {gameId}.7z.002
    {gameId}.7z.003
    ...
```

### Step 8: Extract Game Archive

**Command:**
```bash
7za x {cacheDir}/{gameId}/{gameId}.7z.001 -aoa -o{dataDir} -p{password}
```

**Important:** Only pass the `.7z.001` file. The `7za` tool automatically finds `.7z.002`, `.7z.003`, etc.

**Output structure:**
```
{dataDir}/{release_name}/
    {package_name}.apk              ← Main APK (always present)
    {package_name}/                 ← OBB directory (optional)
        main.{versionCode}.{package_name}.obb
    install.txt                     ← Custom install commands (rare)
```

**Source evidence:**
- QRookie `vrp_manager.cpp:359-362`:
  ```cpp
  p7za.start(P7ZA, {"x",
      QString("%1/%2/%2.7z.001").arg(cache_path_, getGameId(game.release_name)),
      "-aoa",
      QString("-o%1").arg(data_path_),
      QString("-p%1").arg(vrp_public_.password())});
  ```
- Rookie `MainForm.cs:4133`:
  ```csharp
  Zip.ExtractFile($"{settings.DownloadDir}\\{gameNameHash}\\{gameNameHash}.7z.001",
                  $"{settings.DownloadDir}", PublicConfigFile.Password);
  ```

### Step 9: Install APK and Copy OBB (via ADB — reference only)

QRookie uses ADB from a PC to install on a connected Quest:

```bash
# Install APK
adb -s {serial} install -r {path}/{package_name}.apk

# If signature mismatch, uninstall first then retry
adb -s {serial} uninstall {package_name}
adb -s {serial} install -r {path}/{package_name}.apk

# Push OBB files
adb -s {serial} shell rm -rf /sdcard/Android/obb/{package_name}
adb -s {serial} shell mkdir /sdcard/Android/obb/{package_name}
adb -s {serial} push {local_obb_path} /sdcard/Android/obb/{package_name}/{filename}
```

**For the Flutter Quest app, ADB is NOT needed.** The app runs ON the Quest and uses:
- `PackageInstaller` API for APK installation
- `File.copy()` for OBB placement

---

## 5. Game List Data Format

### VRP-GameList.txt Detailed Format

```
Game Name;Release Name;Package Name;Version Code;Last Updated;Size
```

**Field details:**

| Field | Type | Notes |
|-------|------|-------|
| Game Name | String | Human-readable, may contain spaces and special chars |
| Release Name | String | Unique identifier. Format: `{GameName} v{version} {extras}`. Examples: `Beat Saber v1.35.0 +2OBBs`, `Superhot VR v1.0.0`. **Used for MD5 hash computation.** |
| Package Name | String | Standard Android package format: `com.developer.appname` |
| Version Code | String/Int | Numeric, monotonically increasing. Used for update comparison: `newVersionCode > installedVersionCode` means update available. |
| Last Updated | String | Date format varies. Used for sorting by newest. |
| Size | String/Int | Size in megabytes. Used for storage space calculations. |

### Thumbnails

Located at: `{dataDir}/.meta/thumbnails/{package_name}.jpg`

These are standard JPEG images, one per game, named by package name. Typically small (10-50 KB each).

---

## 6. Download Protocol Deep Dive

### Full URL Construction

Given:
- `baseUri` = `https://mirror.example.com`
- `release_name` = `Beat Saber v1.35.0 +2OBBs`
- `gameId` = `MD5("Beat Saber v1.35.0 +2OBBs\n")` = `abc123def456...`

**Metadata:** `https://mirror.example.com/meta.7z`
**Directory listing:** `https://mirror.example.com/abc123def456.../`
**Archive part 1:** `https://mirror.example.com/abc123def456.../abc123def456....7z.001`
**Archive part 2:** `https://mirror.example.com/abc123def456.../abc123def456....7z.002`

### HTTP Headers Required

All requests to the mirror server MUST include:
```
User-Agent: rclone/v1.65.2
```

The server may reject requests without this header or with a different User-Agent.

### Archive Part Sizes

- Parts are typically ~500MB each (524,288,000 bytes)
- The last part is usually smaller
- Total game sizes range from ~50MB to ~10GB+

### Download Progress Tracking

QRookie tracks progress per-directory (all parts combined):
- Total size = sum of all part sizes from directory listing
- Bytes received = cumulative bytes downloaded across all parts
- Progress = bytes_received / total_size

---

## 7. Extraction Protocol

### 7za Binary

- **Official source:** https://www.7-zip.org/ or p7zip project
- **Required architecture:** ARM64 (aarch64) Linux static binary for Quest
- **Command syntax:** `7za x {archive} -aoa -o{outdir} -p{password}`
- **Split archive handling:** Automatic. Pass only `.7z.001`, tool finds rest.
- **Password:** Decoded base64 string from vrp-public.json

### Extraction Output

The extracted content varies per game but generally follows this structure:
```
{release_name}/
├── {package_name}.apk          ← Always present. The main application.
├── {package_name}/             ← Present for games with OBB data.
│   ├── main.{vc}.{pkg}.obb    ← Main OBB file
│   └── patch.{vc}.{pkg}.obb   ← Patch OBB (sometimes)
└── install.txt                 ← Rare. Custom ADB commands for special installs.
```

Some games may have multiple APK files (split APKs), in which case all `.apk` files in the directory should be installed.

---

## 8. Installation Protocol

### How QRookie Installs (ADB from PC — for reference)

```cpp
// device_manager.cpp:658-773

// 1. Find APK files
QStringList apk_files = apk_dir.entryList(QStringList() << "*.apk", QDir::Files);

// 2. Install each APK
adb.start(ADB, {"-s", serial, "install", "-r", apk_path});

// 3. Handle signature mismatch
if (err_msg.contains("signatures do not match previously installed version")) {
    // Uninstall first, then retry
    uninstallApk(package_name, false);
    adb.start(ADB, {"-s", serial, "install", "-r", apk_path});
}

// 4. Push OBB files
// Check if {path}/{package_name}/ directory exists
if (obb_dir.exists()) {
    adb.start(ADB, {"-s", serial, "shell", "rm", "-rf", "/sdcard/Android/obb/" + pkg_name});
    adb.start(ADB, {"-s", serial, "shell", "mkdir", "/sdcard/Android/obb/" + pkg_name});
    for (const QString &obb_file : obb_files) {
        adb.start(ADB, {"-s", serial, "push", src, "/sdcard/Android/obb/" + pkg_name + "/" + dst_file_name});
    }
}
```

### How the Flutter App Should Install (PackageInstaller API)

See section 11 below.

---

## 9. Meta Quest Platform Research

### Operating System
- Based on Android Open Source Project (AOSP), branded "Meta Horizon OS" since April 2024
- Quest 2: Originally Android 10 base
- Quest 3/3S: Android 12L base
- Meta abandoned their custom "XROS" OS project; Quest will continue running Android

### Android API Levels
| Setting | Value |
|---------|-------|
| minSdkVersion (for development) | API 26 (Android 8.0) — but API 29 recommended |
| targetSdkVersion (Meta Store requirement) | API 32 (Android 12L) |
| SDK Build Tools | v28.0.3+ |

### Hardware
| Device | SoC | RAM | Storage |
|--------|-----|-----|---------|
| Quest 2 | Snapdragon XR2 Gen 1 | 6 GB | 64/128/256 GB |
| Quest 3 | Snapdragon XR2 Gen 2 | 8 GB | 128/512 GB |
| Quest 3S | Snapdragon XR2 Gen 2 | 8 GB | 128/256 GB |

### 2D Panel Apps
- Android apps run as floating 2D panels in Horizon OS
- Default panel size: **1024dp × 640dp** (landscape)
- Minimum panel size: 384dp × 500dp
- Sideloaded apps appear under "Unknown Sources" in app library
- Developer Mode required for sideloading (one-time setup via phone app)

### Panel Size Configuration (Android Manifest)
```xml
<meta-data android:name="com.oculus.display_width" android:value="1024" />
<meta-data android:name="com.oculus.display_height" android:value="640" />
<meta-data android:name="com.oculus.supportedDevices" android:value="quest2|questpro|quest3|quest3s" />
```

### Key Constraints
- **No Google Play Services** — Don't depend on any GMS APIs
- **No SD card** — All storage is internal
- **Controller pointer input** — Like a mouse, not touch. Large tap targets needed (56dp+)
- **Reading distance** — Text must be readable at arm's length in VR. Minimum 16sp body text.
- **No cellular** — WiFi only

---

## 10. Flutter on Meta Quest

### Status: Works, with caveats

**What works:**
- Building APK with `flutter build apk --release --target-platform android-arm64`
- Installing via `adb install` or SideQuest
- App renders as 2D panel in Quest environment
- Controller pointer acts as mouse input
- Standard Material widgets work

**Known issues (mostly resolved):**
- Flutter GitHub issue #103234: IDE-based `flutter run` caused app to hang (3 white dots on black). **Marked as fixed** in newer Flutter versions.
- Workaround if it recurs: build APK manually, install via `adb install`, launch via `adb shell monkey -p {package} 1`

**What doesn't work / not recommended:**
- Flutter is NOT officially listed by Meta as a supported framework (they list Java, Kotlin, Jetpack)
- Plugins depending on Google Play Services will fail
- VR-specific features (hand tracking, spatial audio) are not accessible from Flutter
- Don't use app bundles (`.aab`) — Quest needs plain `.apk`

### Meta's Official Statement on Flutter
Meta's Spatial Simulator documentation mentions you can "start by bringing in your existing Java, Kotlin, React Native, or **Flutter** app." This is the closest to official support.

### Build Configuration for Quest
```groovy
android {
    compileSdkVersion 33
    defaultConfig {
        minSdkVersion 29
        targetSdkVersion 32
        ndk {
            abiFilters 'arm64-v8a'  // Quest is ARM64 only
        }
    }
}
```

---

## 11. APK Installation from Within an Android App

### PackageInstaller API (Recommended)

Since Android 5.0 (API 21), `PackageInstaller` is the standard API for programmatic APK installation. It works on Quest.

**Required permission:**
```xml
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
```

**User experience:** First time, Quest prompts user to allow "Install Unknown Apps" for your app. This is a one-time toggle in Settings > Apps > Unknown Sources.

**Flow:**
1. Get `PackageInstaller` from `context.packageManager.packageInstaller`
2. Create session: `PackageInstaller.SessionParams(MODE_FULL_INSTALL)`
3. Open session, stream APK data into it
4. Commit with a PendingIntent for result callback
5. Handle `STATUS_PENDING_USER_ACTION` — Android shows a confirmation dialog
6. Handle `STATUS_SUCCESS` or error statuses

**Flutter integration:** Use a platform channel (MethodChannel) to call Kotlin code. The `android_package_installer` pub.dev package exists but custom implementation is more reliable on Quest.

### Available Flutter Packages (for reference)
| Package | Last Updated | Notes |
|---------|-------------|-------|
| `android_package_installer` | May 2025 | Uses PackageInstaller API. Most popular. |
| `flutter_app_installer` | July 2025 | Supports silent install on rooted devices. |
| `flutter_android_package_installer` | Aug 2024 | Fork using Intent.ACTION_VIEW fallback. |

**Recommendation:** Write a custom platform channel (~80 lines of Kotlin). The pub.dev packages may not handle Quest's specific Android fork correctly.

---

## 12. OBB File Placement

### Target Path
```
/sdcard/Android/obb/{package_name}/
```

### Permissions Required
```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />
```

Also in `<application>` tag:
```xml
android:requestLegacyExternalStorage="true"
```

### Android Scoped Storage Considerations
- Quest 2 (Android 10): `requestLegacyExternalStorage="true"` bypasses scoped storage
- Quest 3 (Android 12L): May need `MANAGE_EXTERNAL_STORAGE` permission
- Since the app is sideloaded, not from Meta Store or Play Store, there is no policy enforcement blocking `MANAGE_EXTERNAL_STORAGE`
- ManageXR (enterprise MDM) confirms OBB placement works on current Quest firmware

### Implementation
```dart
// Dart side
final obbDir = Directory('/sdcard/Android/obb/$packageName');
if (!await obbDir.exists()) {
  await obbDir.create(recursive: true);
}
// Copy each OBB file from extracted directory to obbDir
```

---

## 13. Existing Precedent Tools

These tools prove every component of the Quest-native app is technically viable:

### Quest APK Installer (Anagan79)
- **URL:** https://anagan79.itch.io/quest-apk-installer
- **What it does:** Scans headset for APK/XAPK files, installs them via PackageInstaller
- **Proves:** APK installation from a sideloaded Quest app works, including XAPK+OBB handling
- **Works on:** Quest firmware v74+ (Feb 2025)

### QRookie (glaumar)
- **URL:** https://github.com/glaumar/QRookie
- **What it does:** Downloads from VRP public mirrors, extracts, installs via ADB
- **Proves:** The HTTP protocol can be consumed without rclone, from a non-Windows client
- **Platform:** Linux/macOS (Flatpak)

### QuestSide (HAX05)
- **URL:** https://github.com/HAX05/QuestSide---APK-OBB-Installer-for-Mobile
- **What it does:** Android phone app that connects to Quest via USB OTG + ADB to install APK/OBB
- **Proves:** APK + OBB installation pipeline works from an Android app

### RCX / Round-Sync
- **URLs:** https://github.com/x0b/rcx / https://github.com/newhinton/Round-Sync
- **What they do:** Run rclone on Android (ARM64), manage cloud storage
- **Proves:** rclone ARM64 binary runs on Android devices (backup option if plain HTTP isn't sufficient)

### SideQuest In-Headset
- **What it does:** Full app store running natively on Quest
- **Proves:** Complete download → install pipeline works as a sideloaded Quest app

### APKPure via Quest Browser
- **What it does:** Download APKs from web browser, install on Quest
- **Proves:** The most basic case: download file → install APK works with zero special tools

---

## 14. Key Technical Decisions

### For the Flutter Quest App

| Component | Decision | Rationale |
|-----------|----------|-----------|
| **Language** | Dart (Flutter) + Kotlin (platform channel) | User preference. Flutter works on Quest as 2D panel app. |
| **HTTP Client** | `dio` package | Supports download progress, HTTP Range (resume), interceptors, cancellation |
| **State Management** | flutter_bloc | Clean separation of UI and business logic |
| **Local Storage** | Hive (game catalog cache), SharedPreferences (settings) | Fast, no SQL overhead |
| **Archive Extraction** | Bundled `7za` ARM64 binary via `Process.run()` | Native performance for multi-GB extractions |
| **APK Installation** | Custom Kotlin platform channel using PackageInstaller API | Most reliable on Quest's Android fork |
| **OBB Placement** | `dart:io` File operations | Simple file copy, no special API needed |
| **Thumbnails** | `cached_network_image` or local file loading | Thumbnails come from meta.7z, not network |
| **Build Target** | `arm64-v8a` only | Quest hardware is exclusively ARM64 |

### What We Do NOT Need
- **rclone binary** — The public mirror protocol is plain HTTP. rclone is unnecessary.
- **ADB** — The app runs ON the Quest. No external device communication needed.
- **Google Play Services** — Not available on Quest.
- **VR SDK (OpenXR, etc.)** — This is a 2D panel app, not a VR experience.
- **Split APK support** — Most Quest games are single APK + OBB. Rare edge case for v2.

---

## 15. Critical Gotchas

1. **Game ID hash MUST include trailing newline.**
   - Correct: `md5("Beat Saber v1.35.0 +2OBBs\n")`
   - Wrong: `md5("Beat Saber v1.35.0 +2OBBs")`
   - Both Rookie and QRookie append `"\n"` before hashing.

2. **User-Agent header MUST be `rclone/v1.65.2`.**
   - The server may reject or behave differently without it.
   - Set on ALL requests to `baseUri`.

3. **Password is base64-encoded in JSON, must be decoded before use.**
   - The decoded string is passed to 7za as-is.

4. **Archives are split into multiple parts.**
   - Files: `{id}.7z.001`, `{id}.7z.002`, etc.
   - Only pass `.7z.001` to 7za — it automatically finds the rest.
   - All parts must be in the same directory.

5. **OBB directory must match package name exactly.**
   - Path: `/sdcard/Android/obb/{package_name}/`
   - The `package_name` directory must be created if it doesn't exist.
   - Delete any existing OBB directory before copying new files (QRookie does `rm -rf` then `mkdir`).

6. **Directory listing is HTML, not JSON.**
   - The server returns an HTML page with `<pre>` tag containing file listing.
   - Must parse with regex, not JSON.

7. **Quest panel apps need large UI elements.**
   - Minimum tap target: 48dp (prefer 56dp)
   - Minimum body text: 16sp
   - Dark theme looks best (OLED black on Quest panels)

8. **No app bundles for Quest.**
   - Build with: `flutter build apk --release --target-platform android-arm64`
   - NOT: `flutter build appbundle`

9. **Storage is limited and internal-only.**
   - Always check available space before downloading (games can be 2-10 GB).
   - Extraction requires ~2x the archive size temporarily.
   - Clean up archives immediately after extraction.

10. **First line of VRP-GameList.txt is a header — skip it.**
    - Both codebases explicitly skip line 1.

11. **PackageInstaller STATUS_PENDING_USER_ACTION must be handled.**
    - When Android needs user confirmation, it sends this status with an Intent.
    - You MUST launch that Intent (as a new activity) for the installation dialog to appear.
    - Failing to handle this results in silent installation failure.

12. **The `baseUri` can change.**
    - Always fetch `vrp-public.json` at app startup to get the current `baseUri`.
    - Don't hardcode it.

---

## 16. Open Questions and Risks

### Questions to Resolve During Development

1. **Does Flutter's `Process.run()` work on Quest for executing bundled binaries?**
   - Should work (it's standard Dart/Android), but needs testing.
   - Fallback: use platform channel to invoke binary from Kotlin.

2. **How to bundle the 7za binary in a Flutter APK?**
   - Option A: Place in `android/app/src/main/assets/bin/7za`, copy to filesDir on first launch
   - Option B: Place as `android/app/src/main/jniLibs/arm64-v8a/lib7za.so` (auto-extracted by Android despite .so extension)
   - Option B is cleaner but requires the binary to be named `lib*.so`.

3. **Does `MANAGE_EXTERNAL_STORAGE` permission grant access to `/sdcard/Android/obb/` on Quest 3?**
   - Works on Quest 2 with `requestLegacyExternalStorage`.
   - Quest 3 (Android 12L) may be stricter. Needs testing.
   - If it doesn't work, fall back to SAF (Storage Access Framework).

4. **Can the app run a foreground service for background downloads?**
   - Quest may kill background apps aggressively.
   - A foreground service with notification should keep downloads alive.

5. **How does the app handle Quest going to sleep during large downloads?**
   - Need `WAKE_LOCK` permission and a partial wake lock during downloads.

### Risks

1. **Meta firmware updates** could break sideloading capabilities. However, this would affect ALL sideloading tools (SideQuest, etc.), making it unlikely.

2. **Mirror availability** — The VRP mirrors may experience downtime or quota issues. The app should handle errors gracefully and inform the user.

3. **7za extraction performance** — Multi-GB archives on mobile ARM CPU may be slow. Quest XR2 Gen 2 should handle it, but expect 1-5 minutes for large games.

4. **Flutter on Quest stability** — While it works, Flutter is not officially supported by Meta. Firmware updates could introduce regressions.

---

## Appendix A: Useful Links

- Rookie source: https://github.com/VRPirates/rookie
- QRookie source: https://github.com/glaumar/QRookie
- Quest APK Installer: https://anagan79.itch.io/quest-apk-installer
- QuestSide: https://github.com/HAX05/QuestSide---APK-OBB-Installer-for-Mobile
- RCX (rclone for Android): https://github.com/x0b/rcx
- Round-Sync: https://github.com/newhinton/Round-Sync
- Android PackageInstaller API: https://developer.android.com/reference/android/content/pm/PackageInstaller
- Meta Quest 2D Panel Apps: https://developers.meta.com/horizon/documentation/android-apps/horizon-os-apps/
- Meta Panel Sizing: https://developers.meta.com/horizon/documentation/android-apps/panel-sizing/
- Meta Android Manifest Settings: https://developers.meta.com/horizon/documentation/native/android/mobile-native-manifest/
- Flutter GitHub Issue #103234 (Quest hang): https://github.com/flutter/flutter/issues/103234
- `android_package_installer` package: https://pub.dev/packages/android_package_installer
- vvb2060 PackageInstaller: https://github.com/vvb2060/PackageInstaller

## Appendix B: Dart Pseudocode for Full Pipeline

```dart
// 1. Fetch config
final configJson = await dio.get('https://vrpirates.wiki/downloads/vrp-public.json');
final baseUri = configJson['baseUri'];
final password = utf8.decode(base64Decode(configJson['password']));

// 2. Download metadata
await dio.download('$baseUri/meta.7z', '$cacheDir/meta.7z',
    options: Options(headers: {'User-Agent': 'rclone/v1.65.2'}));

// 3. Extract metadata
await Process.run('7za', ['x', '$cacheDir/meta.7z', '-aoa', '-o$dataDir', '-p$password']);

// 4. Parse game list
final lines = File('$dataDir/VRP-GameList.txt').readAsLinesSync();
final games = lines.skip(1)  // skip header
    .where((l) => l.isNotEmpty)
    .map((l) => l.split(';'))
    .where((parts) => parts.length >= 6)
    .map((parts) => GameInfo(
        name: parts[0], releaseName: parts[1], packageName: parts[2],
        versionCode: parts[3], lastUpdated: parts[4], sizeMb: parts[5]))
    .toList();

// 5. Download a game
final gameId = md5.convert(utf8.encode('${game.releaseName}\n')).toString();
final listingHtml = await dio.get('$baseUri/$gameId/',
    options: Options(headers: {'User-Agent': 'rclone/v1.65.2'}));
final files = parseDirectoryListing(listingHtml.data);
for (final (filename, size) in files) {
    await dio.download('$baseUri/$gameId/$filename', '$cacheDir/$gameId/$filename',
        options: Options(headers: {'User-Agent': 'rclone/v1.65.2'}),
        onReceiveProgress: (received, total) { /* update UI */ });
}

// 6. Extract game
await Process.run('7za', ['x', '$cacheDir/$gameId/$gameId.7z.001', '-aoa', '-o$dataDir', '-p$password']);

// 7. Install APK (via platform channel)
final apkFiles = Directory('$dataDir/${game.releaseName}')
    .listSync().whereType<File>().where((f) => f.path.endsWith('.apk'));
for (final apk in apkFiles) {
    await platformChannel.invokeMethod('installApk', {'apkPath': apk.path});
}

// 8. Copy OBB
final obbSourceDir = Directory('$dataDir/${game.releaseName}/${game.packageName}');
if (await obbSourceDir.exists()) {
    final obbTargetDir = Directory('/sdcard/Android/obb/${game.packageName}');
    await obbTargetDir.create(recursive: true);
    for (final file in obbSourceDir.listSync().whereType<File>()) {
        await file.copy('${obbTargetDir.path}/${file.uri.pathSegments.last}');
    }
}

// 9. Cleanup
Directory('$cacheDir/$gameId').deleteSync(recursive: true);
```
