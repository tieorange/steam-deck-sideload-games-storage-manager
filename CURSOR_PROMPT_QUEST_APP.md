# Cursor / Claude Code Prompt: Build a Flutter App for Meta Quest Game Sideloading

> Copy everything below this line into Cursor IDE or Claude Code as your initial prompt.
> Put the RULES section into `.cursorrules` or `CLAUDE.md` file at the root of your project.

---

## RULES

You are building a Flutter Android app called **"Quest Game Manager"** that runs as a sideloaded 2D panel app on Meta Quest 2/3/3S headsets. The app allows users to browse, download, and install Quest games directly from the headset — no PC required.

### Tech Stack (STRICT — do not deviate)
- **Flutter 3.24+** with Dart 3.5+
- **Target:** Android only (no iOS, no web, no desktop)
- **minSdkVersion:** 29 (Android 10 — Quest 2 base)
- **targetSdkVersion:** 32 (Android 12L — Meta requirement)
- **Architecture:** Clean Architecture (3-layer: Data → Domain → Presentation)
- **State management:** `flutter_bloc` (BLoC for complex features, Cubit for simple ones)
- **DI:** `get_it` + `injectable` (auto-wired dependency injection)
- **HTTP:** `dio` (with download progress, HTTP Range resume, interceptors, cancellation)
- **Error handling:** `fpdart` (`Either<Failure, T>`) — type-safe, no exception swallowing
- **Immutable models:** `freezed` + `json_serializable` for sealed union states, copyWith, and pattern matching
- **Local storage:** `shared_preferences` for settings, `hive` for game catalog cache + download queue
- **JSON:** `dart:convert` (built-in)
- **File operations:** `dart:io`
- **Crypto:** `crypto` package (for MD5 hashing)
- **APK installation:** Custom Kotlin platform channel to Android's `PackageInstaller` API (NOT a pub.dev plugin — they are unreliable on Quest)
- **7z extraction:** Bundled `7za` ARM64 Linux binary invoked via `Process.run()`
- **Permissions:** `permission_handler` package

### Architecture Rules
- Follow Clean Architecture: `data/` → `domain/` → `presentation/`
- **Domain layer** has ZERO external dependencies — pure Dart, no Flutter imports
- **Data layer** implements domain interfaces — depends on `dio`, `hive`, platform channels
- **Presentation layer** consumes domain use cases via BLoCs — depends on `flutter_bloc`
- Feature-first folder structure: every feature gets its own folder under each layer
- BLoC for complex features (catalog, download, installer), Cubit for simple ones (settings)
- Repository pattern: abstract interfaces in domain, implementations in data
- Use `fpdart` `Either<Failure, T>` as return type for all repository methods — never throw exceptions from repositories
- All BLoC states and events defined as `freezed` sealed classes with Dart 3 pattern matching in UI
- All network calls must be cancellable and have timeout handling
- All file operations must check available storage space before proceeding
- DI with `get_it` + `injectable` — annotate with `@injectable`, `@lazySingleton`, `@Injectable(as: ...)`

### UI Rules
- The app runs as a **2D floating panel** in Quest's Horizon OS
- Default panel size: **1024dp wide × 640dp tall** (landscape)
- Design for controller pointer input (like a mouse), NOT touch gestures
- Use Material 3 with a dark theme (OLED black background — Quest panels look best dark)
- Large text (minimum 16sp body, 20sp titles) — text must be readable in VR at arm's length
- Large tap targets (minimum 48dp, prefer 56dp) — pointer precision in VR is lower than touch
- No small icons without labels
- Show download progress with percentage, speed (MB/s), and ETA
- Show storage space remaining on device at all times

### Code Style
- Dart analysis: use `very_good_analysis` lint rules
- Name files in snake_case
- Name classes in PascalCase
- Prefer const constructors everywhere possible
- Always specify types explicitly (no `var` for class fields)
- Write doc comments for all public APIs
- Keep methods under 40 lines — extract helpers if longer

---

## PROJECT SPECIFICATION

### What This App Does

A standalone Meta Quest app that:
1. Fetches a game catalog from a remote server
2. Shows games in a browsable, searchable gallery with thumbnails
3. Downloads selected games (multi-GB archives) with progress tracking
4. Extracts password-protected 7z archives
5. Installs the APK directly on the Quest headset
6. Copies OBB data files to the correct location
7. Cleans up downloaded archives to save space

### The Exact Server Protocol (CRITICAL — must match exactly)

The app communicates with an HTTP server. Here is the exact protocol, reverse-engineered from the open-source QRookie project (https://github.com/glaumar/QRookie):

#### Step 1: Fetch Public Config

```
GET https://raw.githubusercontent.com/vrpyou/quest/main/vrp-public.json
```

Response JSON:
```json
{
  "baseUri": "https://theserver.example.com",
  "password": "BASE64_ENCODED_STRING"
}
```

- `baseUri` — The HTTP base URL for all subsequent downloads
- `password` — Base64-encoded. Decode it: `utf8.decode(base64Decode(password))`. This decoded string is the 7z archive password.

Fallback URL if GitHub fails:
```
GET https://vrpirates.wiki/downloads/vrp-public.json
```

#### Step 2: Download Game Metadata

```
GET {baseUri}/meta.7z
```

Required HTTP header:
```
User-Agent: rclone/v1.65.2
```

This downloads a password-protected 7z archive. Extract it with the password from Step 1:
```bash
7za x meta.7z -aoa -o{outputDir} -p{password}
```

This produces a file called `VRP-GameList.txt` and a `.meta/thumbnails/` directory.

#### Step 3: Parse Game List

`VRP-GameList.txt` format — semicolon-separated values:
```
Game Name;Release Name;Package Name;Version Code;Last Updated;Size
Beat Saber;Beat Saber v1.35.0 +2OBBs;com.beatgames.beatsaber;1350;2024-01-15;2048
```

- **Line 1** is the header — skip it
- **Columns:** name (0), release_name (1), package_name (2), version_code (3), last_updated (4), size_mb (5)
- **Thumbnails** are at: `{extractedDir}/.meta/thumbnails/{package_name}.jpg`

#### Step 4: Download a Game

First, compute the game's directory hash:
```dart
import 'package:crypto/crypto.dart';
import 'dart:convert';

String gameId = md5.convert(utf8.encode('$releaseName\n')).toString();
// IMPORTANT: the input is release_name + literal newline character "\n"
```

Then, list the game's files:
```
GET {baseUri}/{gameId}/
User-Agent: rclone/v1.65.2
```

This returns an HTML directory listing in a `<pre>` tag. Parse it with regex:
```dart
RegExp(r'^(?:\.\./)?([0-9a-f]+\.7z\.\d+)\s+.*\s+(\d+)$', multiLine: true)
```

Each match gives you a filename (e.g., `a1b2c3d4.7z.001`) and its size in bytes.

Download each file:
```
GET {baseUri}/{gameId}/{filename}
User-Agent: rclone/v1.65.2
```

Support **HTTP Range** for resumable downloads:
```
Range: bytes={alreadyDownloaded}-
```

Save to: `{appCacheDir}/{gameId}/{filename}`

#### Step 5: Extract the Downloaded Game

```bash
7za x {cacheDir}/{gameId}/{gameId}.7z.001 -aoa -o{dataDir} -p{password}
```

This produces a directory named after the release_name containing:
- One or more `.apk` files
- Optionally: `{package_name}/` directory with OBB files inside
- Optionally: `install.txt` with custom install commands (rare — can ignore for v1)

#### Step 6: Install APK

Use Android's `PackageInstaller` API via a platform channel:
1. Find all `.apk` files in the extracted directory
2. For each APK, create a PackageInstaller session
3. Stream the APK data into the session
4. Commit the session — Android shows a confirmation dialog to the user
5. Handle the result (success, failure, user cancelled)

#### Step 7: Copy OBB Files

If the extracted directory contains a subfolder named `{package_name}/`:
1. Create directory: `/sdcard/Android/obb/{package_name}/`
2. Copy all files from the extracted `{package_name}/` folder into it

#### Step 8: Cleanup

Delete the downloaded archive files from cache after successful extraction.
Optionally delete the extracted files after successful installation.

---

## FOLDER STRUCTURE

```
quest_game_manager/
├── android/
│   └── app/
│       ├── src/main/
│       │   ├── AndroidManifest.xml
│       │   ├── kotlin/com/questgamemanager/
│       │   │   ├── MainActivity.kt
│       │   │   └── PackageInstallerChannel.kt    ← Platform channel
│       │   └── assets/
│       │       └── bin/
│       │           └── 7za                        ← ARM64 binary (bundled)
│       └── build.gradle
├── lib/
│   ├── main.dart
│   ├── app.dart                                   ← MaterialApp, theme, routes
│   ├── core/
│   │   ├── constants.dart                         ← URLs, User-Agent, etc.
│   │   ├── errors/
│   │   │   ├── failures.dart
│   │   │   └── exceptions.dart
│   │   ├── utils/
│   │   │   ├── file_utils.dart                    ← Storage space checks
│   │   │   ├── archive_utils.dart                 ← 7za extraction wrapper
│   │   │   └── hash_utils.dart                    ← MD5 game ID computation
│   │   └── theme/
│   │       └── app_theme.dart                     ← Dark theme for Quest
│   ├── data/
│   │   ├── models/
│   │   │   ├── public_config_model.dart
│   │   │   ├── game_info_model.dart
│   │   │   └── download_progress_model.dart
│   │   ├── datasources/
│   │   │   ├── vrp_remote_datasource.dart         ← HTTP calls (config, meta, game files)
│   │   │   └── game_local_datasource.dart         ← Cached game list, thumbnails
│   │   └── repositories/
│   │       ├── game_repository_impl.dart
│   │       └── installer_repository_impl.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── game.dart
│   │   │   └── download_state.dart
│   │   ├── repositories/
│   │   │   ├── game_repository.dart               ← Abstract
│   │   │   └── installer_repository.dart          ← Abstract
│   │   └── usecases/
│   │       ├── fetch_game_catalog.dart
│   │       ├── download_game.dart
│   │       ├── install_game.dart
│   │       └── search_games.dart
│   └── presentation/
│       ├── screens/
│       │   ├── home/
│       │   │   ├── home_screen.dart
│       │   │   ├── home_bloc.dart
│       │   │   ├── home_event.dart
│       │   │   └── home_state.dart
│       │   ├── game_detail/
│       │   │   ├── game_detail_screen.dart
│       │   │   ├── game_detail_bloc.dart
│       │   │   ├── game_detail_event.dart
│       │   │   └── game_detail_state.dart
│       │   ├── downloads/
│       │   │   ├── downloads_screen.dart
│       │   │   ├── downloads_bloc.dart
│       │   │   ├── downloads_event.dart
│       │   │   └── downloads_state.dart
│       │   └── settings/
│       │       ├── settings_screen.dart
│       │       └── settings_bloc.dart
│       └── widgets/
│           ├── game_card.dart                     ← Gallery tile with thumbnail
│           ├── game_list_tile.dart                ← List view row
│           ├── download_progress_bar.dart
│           ├── storage_indicator.dart             ← Shows free space
│           └── search_bar.dart
├── assets/
│   └── (app icons, placeholder images)
├── pubspec.yaml
└── analysis_options.yaml
```

---

## ANDROID MANIFEST (CRITICAL)

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.questgamemanager.app">

    <!-- Internet for downloads -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <!-- Install other APKs -->
    <uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />

    <!-- File access for OBB placement -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />

    <!-- Keep downloads running when screen sleeps -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />

    <application
        android:label="Quest Game Manager"
        android:requestLegacyExternalStorage="true"
        android:largeHeap="true">

        <!-- Meta Quest device support -->
        <meta-data
            android:name="com.oculus.supportedDevices"
            android:value="quest2|questpro|quest3|quest3s" />

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:launchMode="singleTop"
            android:windowSoftInputMode="adjustResize">

            <!-- Default panel size for Quest 2D apps: landscape 1024x640 -->
            <meta-data android:name="com.oculus.display_width" android:value="1024" />
            <meta-data android:name="com.oculus.display_height" android:value="640" />

            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <!-- Required for PackageInstaller result callback -->
        <receiver
            android:name=".InstallResultReceiver"
            android:exported="false" />
    </application>
</manifest>
```

---

## PLATFORM CHANNEL: APK INSTALLER (Kotlin Side)

File: `android/app/src/main/kotlin/com/questgamemanager/PackageInstallerChannel.kt`

```kotlin
package com.questgamemanager.app

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageInstaller
import android.os.Build
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream

class PackageInstallerChannel(private val context: Context) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL_NAME = "com.questgamemanager/installer"
        private const val ACTION_INSTALL_RESULT = "com.questgamemanager.INSTALL_RESULT"
    }

    private var pendingResult: MethodChannel.Result? = null

    private val installReceiver = object : BroadcastReceiver() {
        override fun onReceive(ctx: Context, intent: Intent) {
            val status = intent.getIntExtra(PackageInstaller.EXTRA_STATUS, PackageInstaller.STATUS_FAILURE)
            val message = intent.getStringExtra(PackageInstaller.EXTRA_STATUS_MESSAGE) ?: ""

            when (status) {
                PackageInstaller.STATUS_PENDING_USER_ACTION -> {
                    // User confirmation required — launch the confirmation intent
                    val confirmIntent = intent.getParcelableExtra<Intent>(Intent.EXTRA_INTENT)
                    confirmIntent?.let {
                        it.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        ctx.startActivity(it)
                    }
                }
                PackageInstaller.STATUS_SUCCESS -> {
                    pendingResult?.success(mapOf("success" to true, "message" to "Installed"))
                    pendingResult = null
                }
                else -> {
                    pendingResult?.success(mapOf("success" to false, "message" to "Error $status: $message"))
                    pendingResult = null
                }
            }
        }
    }

    fun register() {
        val filter = IntentFilter(ACTION_INSTALL_RESULT)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(installReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            context.registerReceiver(installReceiver, filter)
        }
    }

    fun unregister() {
        try { context.unregisterReceiver(installReceiver) } catch (_: Exception) {}
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "installApk" -> {
                val apkPath = call.argument<String>("apkPath")
                    ?: return result.error("INVALID_ARG", "apkPath required", null)
                pendingResult = result
                installApk(File(apkPath))
            }
            "canInstallPackages" -> {
                result.success(context.packageManager.canRequestPackageInstalls())
            }
            else -> result.notImplemented()
        }
    }

    private fun installApk(apkFile: File) {
        val installer = context.packageManager.packageInstaller
        val params = PackageInstaller.SessionParams(PackageInstaller.SessionParams.MODE_FULL_INSTALL)
        params.setSize(apkFile.length())

        val sessionId = installer.createSession(params)
        val session = installer.openSession(sessionId)

        // Stream APK into session
        session.openWrite("app.apk", 0, apkFile.length()).use { out ->
            FileInputStream(apkFile).use { input ->
                input.copyTo(out)
            }
            session.fsync(out)
        }

        // Commit with pending intent for result
        val intent = Intent(ACTION_INSTALL_RESULT).setPackage(context.packageName)
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S)
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        else PendingIntent.FLAG_UPDATE_CURRENT

        val pi = PendingIntent.getBroadcast(context, sessionId, intent, flags)
        session.commit(pi.intentSender)
    }
}
```

Wire it up in `MainActivity.kt`:
```kotlin
class MainActivity : FlutterActivity() {
    private lateinit var installerChannel: PackageInstallerChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        installerChannel = PackageInstallerChannel(this)
        installerChannel.register()
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PackageInstallerChannel.CHANNEL_NAME)
            .setMethodCallHandler(installerChannel)
    }

    override fun onDestroy() {
        installerChannel.unregister()
        super.onDestroy()
    }
}
```

---

## KEY DART IMPLEMENTATIONS

### constants.dart
```dart
class AppConstants {
  static const String configUrl = 'https://raw.githubusercontent.com/vrpyou/quest/main/vrp-public.json';
  static const String configFallbackUrl = 'https://vrpirates.wiki/downloads/vrp-public.json';
  static const String userAgent = 'rclone/v1.65.2';
  static const String metaArchiveName = 'meta.7z';
  static const String gameListFileName = 'VRP-GameList.txt';
  static const String thumbnailsPath = '.meta/thumbnails';
}
```

### hash_utils.dart
```dart
import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Computes the game directory ID used in download URLs.
/// CRITICAL: The input MUST be release_name followed by a literal newline.
String computeGameId(String releaseName) {
  final bytes = utf8.encode('$releaseName\n');
  return md5.convert(bytes).toString();
}
```

### archive_utils.dart
```dart
import 'dart:io';

/// Extracts a 7z archive using the bundled 7za ARM64 binary.
/// Returns true on success.
Future<bool> extract7z({
  required String archivePath,
  required String outputDir,
  required String password,
  void Function(String line)? onProgress,
}) async {
  // The 7za binary is bundled in assets and copied to app's native lib dir on first run
  final binary = await _get7zaBinaryPath();

  final result = await Process.run(
    binary,
    ['x', archivePath, '-aoa', '-o$outputDir', '-p$password'],
    stdoutEncoding: systemEncoding,
    stderrEncoding: systemEncoding,
  );

  if (result.exitCode != 0) {
    throw Exception('7z extraction failed (exit ${result.exitCode}): ${result.stderr}');
  }
  return true;
}
```

### Parsing the HTML directory listing
```dart
/// Parses the HTML directory listing returned by the server.
/// Returns list of (filename, sizeInBytes) pairs.
List<(String, int)> parseDirectoryListing(String html) {
  final regex = RegExp(r'(?:\.\./)?([0-9a-f]+\.7z\.\d+)\s+.*\s+(\d+)$', multiLine: true);
  return regex.allMatches(html).map((m) {
    return (m.group(1)!, int.parse(m.group(2)!));
  }).toList();
}
```

---

## IMPLEMENTATION ORDER (build in this exact sequence)

### Phase 1: Foundation (do this first)
1. `flutter create quest_game_manager --org com.questgamemanager --platforms android`
2. Set up `pubspec.yaml` with all dependencies
3. Configure `build.gradle` with minSdk 29, targetSdk 32, NDK abiFilters for arm64-v8a only
4. Set up the Android manifest as specified above
5. Create the folder structure
6. Set up app theme (dark, Material 3, large text)
7. Create the basic app shell with bottom navigation (Home, Downloads, Settings)

### Phase 2: Backend / Data Layer
8. Implement `public_config_model.dart` — fetch and parse vrp-public.json
9. Implement `vrp_remote_datasource.dart` — dio client with User-Agent header
10. Implement config fetching with fallback URL
11. Implement meta.7z download
12. Bundle 7za ARM64 binary in assets, copy to writable location on first launch
13. Implement archive extraction (archive_utils.dart)
14. Implement game list parsing from VRP-GameList.txt
15. Implement game info model and local caching with Hive

### Phase 3: Game Browser UI
16. Implement home screen with game grid (GameCard widgets with thumbnails)
17. Implement search/filter functionality
18. Implement game detail screen showing name, size, version, thumbnail
19. Add "Installed" badge detection (query installed packages via platform channel)
20. Add pull-to-refresh for catalog updates

### Phase 4: Download Engine
21. Implement game ID hash computation (MD5 of release_name + newline)
22. Implement directory listing fetch and parse
23. Implement multi-file download with dio (progress callback, HTTP Range resume)
24. Implement download queue (sequential downloads, max 1 concurrent)
25. Implement downloads screen showing active/queued/completed downloads
26. Add storage space checks before starting download
27. Add foreground service notification for background downloads

### Phase 5: Installation Pipeline
28. Implement the PackageInstaller platform channel (Kotlin side)
29. Implement the Dart side of the platform channel
30. Implement OBB file copying to /sdcard/Android/obb/{package}/
31. Implement the full pipeline: extract → find APK → install → copy OBB → cleanup
32. Handle permission flows (REQUEST_INSTALL_PACKAGES, MANAGE_EXTERNAL_STORAGE)

### Phase 6: Polish
33. Add error handling and retry logic for all network operations
34. Add "installed games" view (query device packages)
35. Add settings screen (clear cache, storage info, about)
36. Add proper app icon
37. Test on Quest 2 and Quest 3 hardware

---

## DEPENDENCIES (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Architecture
  flutter_bloc: ^8.1.6           # State management (BLoC + Cubit)
  get_it: ^7.7.0                 # Service locator for DI
  injectable: ^2.4.4             # Annotation-based DI generation
  equatable: ^2.0.5              # Value equality for BLoC states

  # Networking
  dio: ^5.7.0                    # HTTP client with progress, resume, cancellation

  # Functional Programming / Error Handling
  fpdart: ^1.1.0                 # Either<Failure, T> for type-safe errors

  # Code Generation (Models)
  freezed_annotation: ^2.4.6     # Sealed classes, copyWith, pattern matching
  json_annotation: ^4.9.0        # JSON serialization annotations

  # Local Storage
  hive: ^2.2.3                   # Fast NoSQL cache for game catalog
  hive_flutter: ^1.1.0           # Hive Flutter integration
  shared_preferences: ^2.3.0     # Simple key-value settings

  # Utilities
  crypto: ^3.0.5                 # MD5 hashing for game IDs
  path_provider: ^2.1.4          # App directories
  path: ^1.9.0                   # Path manipulation
  permission_handler: ^11.3.1    # Runtime permissions
  cached_network_image: ^3.4.1   # Thumbnail caching

dev_dependencies:
  flutter_test:
    sdk: flutter
  very_good_analysis: ^6.0.0     # Lint rules
  build_runner: ^2.4.13          # Code generation runner
  freezed: ^2.5.7                # Sealed class code gen
  json_serializable: ^6.8.0      # JSON code gen
  injectable_generator: ^2.6.2   # DI code gen
  hive_generator: ^2.0.1         # Hive adapter code gen
  bloc_test: ^9.1.7              # BLoC testing utilities
  mocktail: ^1.0.4               # Mocking for tests
```

---

## BUILD CONFIG (android/app/build.gradle)

```groovy
android {
    compileSdkVersion 33
    ndkVersion "25.1.8937393"

    defaultConfig {
        applicationId "com.questgamemanager.app"
        minSdkVersion 29
        targetSdkVersion 32
        versionCode 1
        versionName "1.0.0"

        // Only build for ARM64 (Quest hardware)
        ndk {
            abiFilters 'arm64-v8a'
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug  // Use debug for sideloading
            minifyEnabled false                  // Don't minify — not needed for sideloaded app
        }
    }
}
```

---

## BUNDLING THE 7ZA BINARY

1. Download the official `p7zip` or `7-zip` ARM64 Linux static binary
2. Place it at `android/app/src/main/assets/bin/7za`
3. On first app launch, copy it to `getApplicationInfo().nativeLibraryDir` or `context.filesDir`
4. Make it executable: `File(path).setExecutable(true)` (via platform channel or Process.run chmod)

Alternative: place it as `android/app/src/main/jniLibs/arm64-v8a/lib7za.so` — Android will automatically extract it to the native lib directory. Despite the `.so` extension, any executable works.

---

## CRITICAL GOTCHAS

1. **User-Agent MUST be `rclone/v1.65.2`** — the server may reject requests without it
2. **Game ID hash input MUST include trailing newline** — `md5("Beat Saber v1.35.0\n")` not `md5("Beat Saber v1.35.0")`
3. **7z password comes from vrp-public.json, base64-decoded** — NOT used as-is
4. **Archives are split**: `{id}.7z.001`, `{id}.7z.002`, etc. — pass only `.7z.001` to 7za, it finds the rest automatically
5. **OBB directory**: must be `/sdcard/Android/obb/{package_name}/` exactly. Create the package subdirectory if it doesn't exist
6. **Quest panel apps** show up under "Unknown Sources" in the Quest app library — this is normal for sideloaded apps
7. **Flutter on Quest**: build with `flutter build apk --release --target-platform android-arm64` — do NOT use app bundles
8. **PackageInstaller** requires `STATUS_PENDING_USER_ACTION` handling — when Android needs user confirmation, you receive this status and must launch the embedded confirmation intent
9. **Storage**: Quest has no SD card. All storage is internal. Always check `StatFs` before large downloads
10. **No Google Play Services** on Quest — don't depend on any GMS APIs

---

## FIRST PROMPT TO START CODING

Use this as your first message to the AI:

> Create a new Flutter project called `quest_game_manager` following the architecture defined in CLAUDE.md / .cursorrules. Start with Phase 1: set up the project, configure the Android manifest for Meta Quest (panel size 1024x640, supported devices, install permissions), set up the dark Material 3 theme optimized for VR readability, configure build.gradle for arm64-v8a only with minSdk 29 / targetSdk 32, and create the basic app shell with a bottom navigation bar (Browse, Downloads, Settings tabs). Make sure the app compiles and the folder structure matches the specification.

Then for each subsequent phase, prompt:

> Continue to Phase 2. Implement the data layer: fetch vrp-public.json, download and extract meta.7z, parse the game catalog from VRP-GameList.txt. Follow the exact protocol specified in the rules file.

And so on through Phase 6.
