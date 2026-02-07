# Quest Game Manager — Flutter App Architecture & Feasibility

## Executive Summary

**Verdict: YES, it is technically feasible** to create a standalone Flutter app for Meta Quest 2/3/3S that replicates Rookie Sideloader functionality — browsing, downloading, and installing Quest games directly from the headset without a PC. The app will be built with **Flutter + Clean Architecture + flutter_bloc** and run as a 2D panel app on Meta Horizon OS.

This document defines the complete architecture, every layer, every BLoC, every data flow, and every Flutter-specific technical decision.

---

## 1. Why Flutter Works on Quest

| Concern | Answer |
|---------|--------|
| Does Flutter run on Quest? | **Yes.** Quest runs Android (Horizon OS). Flutter compiles to native ARM64 APK. The app appears as a 2D panel under "Unknown Sources." |
| Official Meta support? | Meta docs mention Flutter alongside Java, Kotlin, and React Native for 2D panel apps. Meta's Spatial Simulator supports Flutter. |
| Known issues? | Flutter GitHub #103234 (IDE deploy hang) is fixed. Build with `flutter build apk --release --target-platform android-arm64`. |
| VR SDK needed? | **No.** This is a 2D panel app. No OpenXR, no VR rendering. Standard Material widgets. |
| Controller input? | Quest pointer works like a mouse. Standard `GestureDetector`, `InkWell`, etc. work. |

### Quest Panel Sizing
- Default: **1024dp wide x 640dp tall** (landscape)
- Minimum: 384dp x 500dp
- Set via Android Manifest `<meta-data>` tags

---

## 2. Tech Stack

| Layer | Technology | Why |
|-------|-----------|-----|
| **Language** | Dart 3.5+ / Flutter 3.24+ | Cross-platform, hot reload, strong async support |
| **Architecture** | Clean Architecture (3-layer) | Separation of concerns, testable, scalable |
| **State Management** | `flutter_bloc` (BLoC + Cubit) | Event-driven for complex flows, Cubit for simple ones |
| **DI** | `get_it` + `injectable` | Auto-wired dependency injection across layers |
| **HTTP** | `dio` | Download progress, HTTP Range resume, interceptors, cancellation |
| **Error Handling** | `fpdart` (`Either<Failure, T>`) | Type-safe errors, no exception swallowing, self-documenting code |
| **Immutable Models** | `freezed` + `json_serializable` | Sealed union states, copyWith, pattern matching |
| **Local DB** | `hive` | Fast NoSQL cache for game catalog + download queue persistence |
| **Settings** | `shared_preferences` | Simple key-value settings |
| **Crypto** | `crypto` | MD5 hashing for game IDs |
| **Permissions** | `permission_handler` | Runtime permission management |
| **Images** | `cached_network_image` | Thumbnail caching with placeholder |
| **APK Install** | Custom Kotlin platform channel | `PackageInstaller` API — more reliable on Quest than pub.dev packages |
| **7z Extraction** | Bundled `7za` ARM64 binary | Native performance via `Process.run()` |
| **Build target** | `arm64-v8a` only | Quest is ARM64. No x86 waste. |

### pubspec.yaml Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Architecture
  flutter_bloc: ^8.1.6
  get_it: ^7.7.0
  injectable: ^2.4.4
  equatable: ^2.0.5

  # Networking
  dio: ^5.7.0

  # Functional Programming / Error Handling
  fpdart: ^1.1.0

  # Code Generation (Models)
  freezed_annotation: ^2.4.6
  json_annotation: ^4.9.0

  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shared_preferences: ^2.3.0

  # Utilities
  crypto: ^3.0.5
  path_provider: ^2.1.4
  path: ^1.9.0
  permission_handler: ^11.3.1
  cached_network_image: ^3.4.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  very_good_analysis: ^6.0.0
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  injectable_generator: ^2.6.2
  hive_generator: ^2.0.1
  bloc_test: ^9.1.7
  mocktail: ^1.0.4
```

---

## 3. Clean Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION                          │
│  Screens, Widgets, BLoCs/Cubits                         │
│  Depends on: Domain only                                │
├─────────────────────────────────────────────────────────┤
│                      DOMAIN                              │
│  Entities, Use Cases, Repository Interfaces (abstract)   │
│  Depends on: Nothing (pure Dart, zero Flutter imports)   │
├─────────────────────────────────────────────────────────┤
│                       DATA                               │
│  Models, Repository Impls, Data Sources (remote/local)   │
│  Depends on: Domain (implements interfaces)              │
└─────────────────────────────────────────────────────────┘
```

### Dependency Rule
**Dependencies always point inward:** Presentation → Domain ← Data

- **Domain** has ZERO external dependencies. Pure Dart.
- **Data** implements domain interfaces. Depends on `dio`, `hive`, platform channels.
- **Presentation** consumes domain use cases via BLoCs. Depends on `flutter_bloc`.

---

## 4. Folder Structure (Feature-First)

```
lib/
├── main.dart                              ← Entry point
├── app.dart                               ← MaterialApp, theme, router
├── injection.dart                         ← get_it + injectable setup
│
├── core/
│   ├── constants/
│   │   └── app_constants.dart             ← URLs, User-Agent, timeouts
│   ├── error/
│   │   ├── failures.dart                  ← Failure sealed class (NetworkFailure, StorageFailure, etc.)
│   │   └── exceptions.dart                ← Custom exception types
│   ├── usecases/
│   │   └── usecase.dart                   ← Abstract UseCase<Type, Params> base class
│   ├── platform/
│   │   ├── package_installer_channel.dart ← Dart side of APK install platform channel
│   │   └── archive_extractor.dart         ← 7za process wrapper
│   ├── theme/
│   │   └── app_theme.dart                 ← Dark Material 3 theme for Quest VR
│   └── utils/
│       ├── hash_utils.dart                ← MD5 game ID computation
│       ├── file_utils.dart                ← Storage space checks, file ops
│       └── directory_listing_parser.dart  ← HTML <pre> tag regex parser
│
├── features/
│   ├── config/                            ← Feature: App config / mirror management
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── public_config_model.dart      ← JSON model with fromJson
│   │   │   ├── datasources/
│   │   │   │   └── config_remote_datasource.dart  ← Fetches vrp-public.json
│   │   │   └── repositories/
│   │   │       └── config_repository_impl.dart
│   │   └── domain/
│   │       ├── entities/
│   │       │   └── public_config.dart             ← Pure entity: baseUri + password
│   │       ├── repositories/
│   │       │   └── config_repository.dart         ← Abstract interface
│   │       └── usecases/
│   │           └── fetch_config.dart              ← FetchConfig use case
│   │
│   ├── catalog/                           ← Feature: Game catalog browsing
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── game_info_model.dart           ← Semicolon-delimited parser + Hive adapter
│   │   │   ├── datasources/
│   │   │   │   ├── catalog_remote_datasource.dart ← Downloads meta.7z, parses VRP-GameList.txt
│   │   │   │   └── catalog_local_datasource.dart  ← Hive cache for game list + thumbnails
│   │   │   └── repositories/
│   │   │       └── catalog_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── game.dart                      ← Pure entity: name, releaseName, packageName, etc.
│   │   │   ├── repositories/
│   │   │   │   └── catalog_repository.dart        ← Abstract
│   │   │   └── usecases/
│   │   │       ├── get_game_catalog.dart           ← Fetches & caches full catalog
│   │   │       ├── search_games.dart               ← Filters by query string
│   │   │       └── get_game_thumbnail.dart         ← Returns thumbnail file path
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── catalog_bloc.dart
│   │       │   ├── catalog_event.dart             ← LoadCatalog, RefreshCatalog, SearchGames, FilterByStatus
│   │       │   └── catalog_state.dart             ← CatalogInitial, CatalogLoading, CatalogLoaded, CatalogError
│   │       ├── pages/
│   │       │   └── catalog_page.dart              ← Main browse screen
│   │       └── widgets/
│   │           ├── game_card.dart                 ← Gallery grid tile
│   │           ├── game_list_tile.dart            ← List view row
│   │           ├── search_bar_widget.dart
│   │           └── storage_indicator.dart         ← Shows free space
│   │
│   ├── download/                          ← Feature: Download engine
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── download_task_model.dart       ← Hive-persisted download state
│   │   │   ├── datasources/
│   │   │   │   ├── download_remote_datasource.dart ← dio downloads with Range resume
│   │   │   │   └── download_local_datasource.dart  ← Queue persistence in Hive
│   │   │   └── repositories/
│   │   │       └── download_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── download_task.dart             ← Entity: gameId, progress, status, filePaths
│   │   │   ├── repositories/
│   │   │   │   └── download_repository.dart       ← Abstract
│   │   │   └── usecases/
│   │   │       ├── download_game.dart              ← Full pipeline: list dir → download parts → track progress
│   │   │       ├── cancel_download.dart
│   │   │       └── get_download_queue.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── download_bloc.dart
│   │       │   ├── download_event.dart            ← StartDownload, CancelDownload, RetryDownload
│   │       │   └── download_state.dart            ← DownloadIdle, DownloadInProgress, DownloadCompleted, DownloadFailed
│   │       ├── pages/
│   │       │   └── downloads_page.dart            ← Active/queued/completed downloads
│   │       └── widgets/
│   │           ├── download_progress_tile.dart
│   │           └── download_queue_list.dart
│   │
│   ├── installer/                         ← Feature: Extract + Install + OBB
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── extractor_datasource.dart      ← 7za ARM64 binary invocation
│   │   │   │   ├── apk_installer_datasource.dart  ← Platform channel to Kotlin PackageInstaller
│   │   │   │   └── obb_manager_datasource.dart    ← File copy to /sdcard/Android/obb/
│   │   │   └── repositories/
│   │   │       └── installer_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── install_result.dart            ← Success/Failure with message
│   │   │   ├── repositories/
│   │   │   │   └── installer_repository.dart      ← Abstract
│   │   │   └── usecases/
│   │   │       ├── extract_game.dart               ← 7za extraction
│   │   │       ├── install_apk.dart                ← PackageInstaller flow
│   │   │       ├── copy_obb_files.dart             ← OBB placement
│   │   │       └── full_install_pipeline.dart      ← Orchestrates: extract → install → copy OBB → cleanup
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── installer_bloc.dart
│   │       │   ├── installer_event.dart           ← InstallGame, CancelInstall
│   │       │   └── installer_state.dart           ← Extracting, Installing, CopyingObb, InstallSuccess, InstallFailed
│   │       └── widgets/
│   │           └── install_progress_dialog.dart
│   │
│   ├── game_detail/                       ← Feature: Single game detail view
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── game_detail_bloc.dart
│   │       │   ├── game_detail_event.dart
│   │       │   └── game_detail_state.dart
│   │       ├── pages/
│   │       │   └── game_detail_page.dart
│   │       └── widgets/
│   │           └── game_info_card.dart
│   │
│   └── settings/                          ← Feature: App settings
│       └── presentation/
│           ├── cubit/
│           │   ├── settings_cubit.dart            ← Cubit (not Bloc) — simple state
│           │   └── settings_state.dart
│           ├── pages/
│           │   └── settings_page.dart
│           └── widgets/
│               └── storage_details_card.dart
│
└── android/
    └── app/src/main/
        ├── AndroidManifest.xml
        ├── kotlin/com/questgamemanager/app/
        │   ├── MainActivity.kt
        │   ├── PackageInstallerChannel.kt     ← Platform channel: Kotlin PackageInstaller API
        │   └── InstallResultReceiver.kt       ← BroadcastReceiver for install callbacks
        └── assets/bin/
            └── 7za                             ← ARM64 Linux static binary
```

---

## 5. Domain Layer — Entities

### `Game` Entity (Pure Dart, no dependencies)

```dart
class Game extends Equatable {
  const Game({
    required this.name,
    required this.releaseName,
    required this.packageName,
    required this.versionCode,
    required this.lastUpdated,
    required this.sizeMb,
  });

  final String name;          // "Beat Saber"
  final String releaseName;   // "Beat Saber v1.35.0 +2OBBs"
  final String packageName;   // "com.beatgames.beatsaber"
  final String versionCode;   // "1350"
  final String lastUpdated;   // "2024-01-15"
  final String sizeMb;        // "2048"

  @override
  List<Object?> get props => [releaseName, packageName, versionCode];
}
```

### `PublicConfig` Entity

```dart
class PublicConfig extends Equatable {
  const PublicConfig({required this.baseUri, required this.password});

  final String baseUri;    // HTTP base URL for downloads
  final String password;   // Decoded 7z archive password

  @override
  List<Object?> get props => [baseUri];
}
```

### `DownloadTask` Entity

```dart
class DownloadTask extends Equatable {
  const DownloadTask({
    required this.game,
    required this.gameId,
    required this.status,
    required this.progress,
    this.bytesReceived = 0,
    this.totalBytes = 0,
  });

  final Game game;
  final String gameId;         // MD5 hash
  final DownloadStatus status;
  final double progress;       // 0.0 to 1.0
  final int bytesReceived;
  final int totalBytes;

  @override
  List<Object?> get props => [gameId, status, progress];
}

enum DownloadStatus { queued, downloading, paused, completed, failed }
```

---

## 6. Domain Layer — Repository Interfaces (Abstract)

```dart
// config_repository.dart
abstract class ConfigRepository {
  Future<Either<Failure, PublicConfig>> fetchConfig();
}

// catalog_repository.dart
abstract class CatalogRepository {
  Future<Either<Failure, List<Game>>> getGameCatalog(PublicConfig config);
  Future<Either<Failure, List<Game>>> getCachedCatalog();
  Future<Either<Failure, String>> getGameThumbnailPath(String packageName);
}

// download_repository.dart
abstract class DownloadRepository {
  Future<Either<Failure, List<(String filename, int sizeBytes)>>> listGameFiles(
    String baseUri, String gameId,
  );
  Stream<DownloadTask> downloadGame(
    String baseUri, String gameId, List<(String, int)> files,
  );
  Future<Either<Failure, void>> cancelDownload(String gameId);
  Future<Either<Failure, List<DownloadTask>>> getSavedQueue();
}

// installer_repository.dart
abstract class InstallerRepository {
  Future<Either<Failure, String>> extractGame(
    String archivePath, String outputDir, String password,
  );
  Future<Either<Failure, bool>> installApk(String apkPath);
  Future<Either<Failure, void>> copyObbFiles(
    String sourceDir, String packageName,
  );
  Future<Either<Failure, void>> cleanup(String cacheDir);
}
```

---

## 7. Domain Layer — Use Cases

Every use case follows this base class pattern:

```dart
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
```

### Key Use Cases

```dart
// Fetch public config (with fallback URL)
@injectable
class FetchConfig implements UseCase<PublicConfig, NoParams> {
  FetchConfig(this._repository);
  final ConfigRepository _repository;

  @override
  Future<Either<Failure, PublicConfig>> call(NoParams params) =>
      _repository.fetchConfig();
}

// Download full game (orchestrates directory listing + multi-file download)
@injectable
class DownloadGame {
  DownloadGame(this._downloadRepo, this._catalogRepo);
  final DownloadRepository _downloadRepo;
  final CatalogRepository _catalogRepo;

  Stream<DownloadTask> call(DownloadGameParams params) async* {
    final filesResult = await _downloadRepo.listGameFiles(
      params.baseUri, params.gameId,
    );
    yield* filesResult.fold(
      (failure) => Stream.value(DownloadTask(/* ... failed state */)),
      (files) => _downloadRepo.downloadGame(params.baseUri, params.gameId, files),
    );
  }
}

// Full install pipeline: extract → install APK → copy OBB → cleanup
@injectable
class FullInstallPipeline {
  FullInstallPipeline(this._installerRepo);
  final InstallerRepository _installerRepo;

  Stream<InstallStage> call(InstallParams params) async* {
    yield InstallStage.extracting;
    final extractResult = await _installerRepo.extractGame(
      params.archivePath, params.outputDir, params.password,
    );
    if (extractResult.isLeft()) { yield InstallStage.failed; return; }

    yield InstallStage.installing;
    final installResult = await _installerRepo.installApk(params.apkPath);
    if (installResult.isLeft()) { yield InstallStage.failed; return; }

    yield InstallStage.copyingObb;
    await _installerRepo.copyObbFiles(params.extractedDir, params.packageName);

    yield InstallStage.cleaning;
    await _installerRepo.cleanup(params.cacheDir);

    yield InstallStage.completed;
  }
}
```

---

## 8. Data Layer — Models (freezed)

```dart
@freezed
class PublicConfigModel with _$PublicConfigModel {
  const factory PublicConfigModel({
    required String baseUri,
    required String password,  // base64-encoded in JSON
  }) = _PublicConfigModel;

  factory PublicConfigModel.fromJson(Map<String, dynamic> json) =>
      _$PublicConfigModelFromJson(json);

  /// Decode password and convert to domain entity
  PublicConfig toEntity() => PublicConfig(
    baseUri: baseUri,
    password: utf8.decode(base64Decode(password)),
  );
}
```

```dart
// GameInfoModel — parsed from semicolon-delimited VRP-GameList.txt (NOT JSON)
@HiveType(typeId: 0)
class GameInfoModel extends HiveObject {
  @HiveField(0) final String name;
  @HiveField(1) final String releaseName;
  @HiveField(2) final String packageName;
  @HiveField(3) final String versionCode;
  @HiveField(4) final String lastUpdated;
  @HiveField(5) final String sizeMb;

  GameInfoModel({
    required this.name,
    required this.releaseName,
    required this.packageName,
    required this.versionCode,
    required this.lastUpdated,
    required this.sizeMb,
  });

  /// Parse a single line from VRP-GameList.txt
  factory GameInfoModel.fromCsvLine(String line) {
    final parts = line.split(';');
    if (parts.length < 6) throw const FormatException('Invalid game list line');
    return GameInfoModel(
      name: parts[0],
      releaseName: parts[1],
      packageName: parts[2],
      versionCode: parts[3],
      lastUpdated: parts[4],
      sizeMb: parts[5],
    );
  }

  Game toEntity() => Game(
    name: name,
    releaseName: releaseName,
    packageName: packageName,
    versionCode: versionCode,
    lastUpdated: lastUpdated,
    sizeMb: sizeMb,
  );
}
```

---

## 9. Data Layer — Remote Data Sources

### Config Remote Data Source

```dart
@lazySingleton
class ConfigRemoteDatasource {
  ConfigRemoteDatasource(this._dio);
  final Dio _dio;

  static const _primaryUrl =
      'https://raw.githubusercontent.com/vrpyou/quest/main/vrp-public.json';
  static const _fallbackUrl =
      'https://vrpirates.wiki/downloads/vrp-public.json';

  Future<PublicConfigModel> fetchConfig() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(_primaryUrl);
      return PublicConfigModel.fromJson(response.data!);
    } catch (_) {
      final response = await _dio.get<Map<String, dynamic>>(_fallbackUrl);
      return PublicConfigModel.fromJson(response.data!);
    }
  }
}
```

### Catalog Remote Data Source

```dart
@lazySingleton
class CatalogRemoteDatasource {
  CatalogRemoteDatasource(this._dio, this._archiveExtractor);
  final Dio _dio;
  final ArchiveExtractor _archiveExtractor;

  /// Download meta.7z, extract it, parse VRP-GameList.txt
  Future<List<GameInfoModel>> fetchCatalog(PublicConfig config) async {
    final cacheDir = await _getCacheDir();
    final metaPath = '$cacheDir/meta.7z';

    // Download meta.7z with rclone User-Agent
    await _dio.download(
      '${config.baseUri}/meta.7z',
      metaPath,
      options: Options(headers: {'User-Agent': 'rclone/v1.65.2'}),
    );

    // Extract with password
    final dataDir = await _getDataDir();
    await _archiveExtractor.extract(
      archivePath: metaPath,
      outputDir: dataDir,
      password: config.password,
    );

    // Parse game list
    final gameListFile = File('$dataDir/VRP-GameList.txt');
    final lines = await gameListFile.readAsLines();

    return lines
        .skip(1) // skip header
        .where((line) => line.trim().isNotEmpty)
        .map((line) {
          try { return GameInfoModel.fromCsvLine(line); }
          catch (_) { return null; }
        })
        .whereType<GameInfoModel>()
        .toList();
  }
}
```

### Download Remote Data Source

```dart
@lazySingleton
class DownloadRemoteDatasource {
  DownloadRemoteDatasource(this._dio);
  final Dio _dio;

  /// Fetch HTML directory listing and parse file list
  Future<List<(String filename, int sizeBytes)>> listGameFiles(
    String baseUri, String gameId,
  ) async {
    final response = await _dio.get<String>(
      '$baseUri/$gameId/',
      options: Options(headers: {'User-Agent': 'rclone/v1.65.2'}),
    );
    return DirectoryListingParser.parse(response.data!);
  }

  /// Download a single file with resume support
  Stream<(int received, int total)> downloadFile(
    String url, String savePath,
  ) async* {
    int offset = 0;
    final tmpPath = '$savePath.tmp';
    final tmpFile = File(tmpPath);
    if (await tmpFile.exists()) {
      offset = await tmpFile.length();
    }

    await _dio.download(
      url,
      tmpPath,
      options: Options(
        headers: {
          'User-Agent': 'rclone/v1.65.2',
          if (offset > 0) 'Range': 'bytes=$offset-',
        },
      ),
      onReceiveProgress: (received, total) {
        // Progress callback handled by dio
      },
      deleteOnError: false, // Keep partial for resume
    );

    // Rename .tmp to final
    await File(tmpPath).rename(savePath);
  }
}
```

---

## 10. Presentation Layer — BLoC Definitions

### When to Use BLoC vs Cubit

| Feature | Pattern | Why |
|---------|---------|-----|
| **Catalog browsing** | **BLoC** | Multiple events (Load, Refresh, Search, Filter, Sort), event transformers for debounced search |
| **Download manager** | **BLoC** | Complex: Start, Cancel, Retry, Resume events. Progress streams. Queue management. |
| **Installer** | **BLoC** | Multi-stage pipeline (extract → install → OBB → cleanup) with cancellation |
| **Game detail** | **Cubit** | Simple: load game info, check installed status |
| **Settings** | **Cubit** | Simple: get/set preferences |

### Catalog BLoC (freezed sealed states)

```dart
// catalog_event.dart
@freezed
sealed class CatalogEvent with _$CatalogEvent {
  const factory CatalogEvent.load() = CatalogLoad;
  const factory CatalogEvent.refresh() = CatalogRefresh;
  const factory CatalogEvent.search(String query) = CatalogSearch;
  const factory CatalogEvent.filterByStatus(GameStatusFilter filter) = CatalogFilterByStatus;
  const factory CatalogEvent.sortBy(SortType sortType) = CatalogSortBy;
}

// catalog_state.dart
@freezed
sealed class CatalogState with _$CatalogState {
  const factory CatalogState.initial() = CatalogInitial;
  const factory CatalogState.loading() = CatalogLoading;
  const factory CatalogState.loaded({
    required List<Game> games,
    required List<Game> filteredGames,
    required String searchQuery,
    required SortType sortType,
    required GameStatusFilter filter,
    required int freeSpaceMb,
  }) = CatalogLoaded;
  const factory CatalogState.error(Failure failure) = CatalogError;
}

// catalog_bloc.dart
@injectable
class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc(this._fetchConfig, this._getGameCatalog, this._searchGames)
      : super(const CatalogState.initial()) {
    on<CatalogLoad>(_onLoad);
    on<CatalogRefresh>(_onRefresh);
    on<CatalogSearch>(_onSearch, transformer: debounce(300.ms));
    on<CatalogFilterByStatus>(_onFilter);
    on<CatalogSortBy>(_onSort);
  }

  final FetchConfig _fetchConfig;
  final GetGameCatalog _getGameCatalog;
  final SearchGames _searchGames;

  Future<void> _onLoad(CatalogLoad event, Emitter<CatalogState> emit) async {
    emit(const CatalogState.loading());

    final configResult = await _fetchConfig(NoParams());
    await configResult.fold(
      (failure) async => emit(CatalogState.error(failure)),
      (config) async {
        final catalogResult = await _getGameCatalog(config);
        catalogResult.fold(
          (failure) => emit(CatalogState.error(failure)),
          (games) => emit(CatalogState.loaded(
            games: games,
            filteredGames: games,
            searchQuery: '',
            sortType: SortType.lastUpdated,
            filter: GameStatusFilter.all,
            freeSpaceMb: FileUtils.getFreeSpaceMb(),
          )),
        );
      },
    );
  }

  // _onSearch uses debounce transformer — no server spam on keystroke
  Future<void> _onSearch(CatalogSearch event, Emitter<CatalogState> emit) async {
    final currentState = state;
    if (currentState is CatalogLoaded) {
      final filtered = _searchGames(currentState.games, event.query);
      emit(currentState.copyWith(
        filteredGames: filtered,
        searchQuery: event.query,
      ));
    }
  }
}
```

### Download BLoC

```dart
@freezed
sealed class DownloadEvent with _$DownloadEvent {
  const factory DownloadEvent.start(Game game) = DownloadStart;
  const factory DownloadEvent.cancel(String gameId) = DownloadCancel;
  const factory DownloadEvent.retry(String gameId) = DownloadRetry;
  const factory DownloadEvent.loadQueue() = DownloadLoadQueue;
}

@freezed
sealed class DownloadState with _$DownloadState {
  const factory DownloadState.idle({
    @Default([]) List<DownloadTask> queue,
  }) = DownloadIdle;
  const factory DownloadState.downloading({
    required DownloadTask activeTask,
    required List<DownloadTask> queue,
  }) = DownloadDownloading;
  const factory DownloadState.error({
    required Failure failure,
    required List<DownloadTask> queue,
  }) = DownloadError;
}

@injectable
class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  DownloadBloc(this._downloadGame, this._cancelDownload, this._getQueue)
      : super(const DownloadState.idle()) {
    on<DownloadStart>(_onStart);
    on<DownloadCancel>(_onCancel);
    on<DownloadRetry>(_onRetry);
    on<DownloadLoadQueue>(_onLoadQueue);
  }

  final DownloadGame _downloadGame;
  final CancelDownload _cancelDownload;
  final GetDownloadQueue _getQueue;
  StreamSubscription<DownloadTask>? _downloadSub;

  Future<void> _onStart(DownloadStart event, Emitter<DownloadState> emit) async {
    final gameId = HashUtils.computeGameId(event.game.releaseName);
    // ... subscribe to download stream, emit progress updates
  }

  @override
  Future<void> close() {
    _downloadSub?.cancel();
    return super.close();
  }
}
```

### Installer BLoC

```dart
@freezed
sealed class InstallerState with _$InstallerState {
  const factory InstallerState.idle() = InstallerIdle;
  const factory InstallerState.extracting({required double progress}) = InstallerExtracting;
  const factory InstallerState.installing({required String gameName}) = InstallerInstalling;
  const factory InstallerState.copyingObb({required String gameName}) = InstallerCopyingObb;
  const factory InstallerState.success({required String gameName}) = InstallerSuccess;
  const factory InstallerState.failed({required Failure failure}) = InstallerFailed;
}
```

---

## 11. Error Handling Strategy

### Failure Sealed Class

```dart
@freezed
sealed class Failure with _$Failure {
  const factory Failure.network({required String message}) = NetworkFailure;
  const factory Failure.server({required int statusCode, required String message}) = ServerFailure;
  const factory Failure.storage({required String message}) = StorageFailure;
  const factory Failure.extraction({required String message}) = ExtractionFailure;
  const factory Failure.installation({required String message}) = InstallationFailure;
  const factory Failure.permission({required String permission}) = PermissionFailure;
  const factory Failure.insufficientSpace({required int requiredMb, required int availableMb}) = InsufficientSpaceFailure;
  const factory Failure.unknown({required String message}) = UnknownFailure;
}
```

### Pattern: Repository Returns `Either<Failure, T>`

```dart
@Injectable(as: ConfigRepository)
class ConfigRepositoryImpl implements ConfigRepository {
  ConfigRepositoryImpl(this._remoteDatasource);
  final ConfigRemoteDatasource _remoteDatasource;

  @override
  Future<Either<Failure, PublicConfig>> fetchConfig() async {
    try {
      final model = await _remoteDatasource.fetchConfig();
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(Failure.network(message: e.message ?? 'Network error'));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }
}
```

### Pattern: BLoC Consumes Either via fold()

```dart
final result = await _fetchConfig(NoParams());
result.fold(
  (failure) => emit(CatalogState.error(failure)),
  (config) => emit(CatalogState.loaded(/* ... */)),
);
```

### Pattern: UI Uses Dart 3 Pattern Matching

```dart
BlocBuilder<CatalogBloc, CatalogState>(
  builder: (context, state) => switch (state) {
    CatalogInitial() => const SizedBox.shrink(),
    CatalogLoading() => const Center(child: CircularProgressIndicator()),
    CatalogLoaded(:final filteredGames) => GameGrid(games: filteredGames),
    CatalogError(:final failure) => ErrorWidget(failure: failure),
  },
)
```

---

## 12. Dependency Injection Setup

```dart
// injection.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async => getIt.init();

// Register third-party deps that can't be annotated
@module
abstract class RegisterModule {
  @lazySingleton
  Dio get dio => Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(minutes: 10),
  ));
}
```

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  await Hive.initFlutter();
  Hive.registerAdapter(GameInfoModelAdapter());
  runApp(const QuestGameManagerApp());
}
```

```dart
// app.dart
class QuestGameManagerApp extends StatelessWidget {
  const QuestGameManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<CatalogBloc>()..add(const CatalogEvent.load())),
        BlocProvider(create: (_) => getIt<DownloadBloc>()..add(const DownloadEvent.loadQueue())),
        BlocProvider(create: (_) => getIt<InstallerBloc>()),
      ],
      child: MaterialApp(
        title: 'Quest Game Manager',
        theme: AppTheme.dark, // OLED dark theme optimized for VR
        home: const MainNavigation(),
      ),
    );
  }
}
```

---

## 13. Quest-Specific Android Configuration

### AndroidManifest.xml

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.questgamemanager.app">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />

    <application
        android:label="Quest Game Manager"
        android:requestLegacyExternalStorage="true"
        android:largeHeap="true">

        <meta-data android:name="com.oculus.supportedDevices"
                   android:value="quest2|questpro|quest3|quest3s" />

        <activity android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

            <meta-data android:name="com.oculus.display_width" android:value="1024" />
            <meta-data android:name="com.oculus.display_height" android:value="640" />

            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <receiver android:name=".InstallResultReceiver" android:exported="false" />
    </application>
</manifest>
```

### build.gradle

```groovy
android {
    compileSdkVersion 33
    defaultConfig {
        applicationId "com.questgamemanager.app"
        minSdkVersion 29
        targetSdkVersion 32
        versionCode 1
        versionName "1.0.0"
        ndk { abiFilters 'arm64-v8a' }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.debug
            minifyEnabled false
        }
    }
}
```

### Build Command
```bash
flutter build apk --release --target-platform android-arm64
# NOT flutter build appbundle — Quest needs plain APK
```

---

## 14. UI Design Principles for Quest VR

| Rule | Value | Reason |
|------|-------|--------|
| Body text size | **16sp minimum** | Readable at arm's length in VR headset |
| Title text size | **20sp+** | Visual hierarchy in lower-resolution panel |
| Tap target size | **56dp minimum** | Pointer precision in VR is lower than touch |
| Background | **OLED black (#000000)** | Quest panels look best with dark themes |
| Surface color | **Dark grey (#1F2229)** | Subtle contrast against black |
| Accent | **Bright blue/purple** | High visibility in dark VR environment |
| Panel size | **1024 x 640 dp** | Default Quest 2D panel dimensions (landscape) |
| Progress indicators | **Always show %**, **MB/s**, **ETA** | Large downloads need clear feedback |
| Storage bar | **Always visible** | Quest has limited internal storage |

---

## 15. Data Flow Diagram — Full Pipeline

```
User taps "Download & Install" on a game card
    │
    ▼
┌──────────────────────────────────────────────────┐
│  CatalogBloc dispatches DownloadStart(game)       │
│  to DownloadBloc via context.read<DownloadBloc>() │
└──────────────┬───────────────────────────────────┘
               ▼
┌──────────────────────────────────────────┐
│  DownloadBloc._onStart()                  │
│  1. Compute gameId = MD5(releaseName+\n)  │
│  2. Check free space (>= sizeMb * 2.5)    │
│  3. Call DownloadGame use case             │
└──────────────┬───────────────────────────┘
               ▼
┌──────────────────────────────────────────────────────────┐
│  DownloadGame use case                                    │
│  1. listGameFiles(baseUri, gameId) → GET {baseUri}/{id}/  │
│  2. Parse HTML → [(filename, size), ...]                  │
│  3. For each file:                                        │
│     GET {baseUri}/{id}/{filename}                         │
│     Headers: User-Agent: rclone/v1.65.2                   │
│              Range: bytes={offset}- (if resuming)         │
│  4. Yield DownloadTask with progress updates              │
└──────────────┬───────────────────────────────────────────┘
               ▼
┌──────────────────────────────────────────────────────────┐
│  DownloadBloc emits DownloadDownloading(progress: 0.73)   │
│  UI updates progress bar via BlocBuilder                  │
└──────────────┬───────────────────────────────────────────┘
               ▼ (download complete)
┌──────────────────────────────────────────────────────────┐
│  DownloadBloc dispatches InstallGame to InstallerBloc     │
└──────────────┬───────────────────────────────────────────┘
               ▼
┌──────────────────────────────────────────────────────────┐
│  InstallerBloc._onInstall() → FullInstallPipeline         │
│                                                           │
│  Stage 1: EXTRACT                                         │
│    7za x {cache}/{id}/{id}.7z.001 -aoa -o{data} -p{pw}   │
│    emit InstallerExtracting(progress: 0.45)               │
│                                                           │
│  Stage 2: INSTALL APK                                     │
│    Platform channel → Kotlin PackageInstaller API          │
│    User sees Android confirmation dialog in Quest          │
│    emit InstallerInstalling(gameName: "Beat Saber")        │
│                                                           │
│  Stage 3: COPY OBB                                        │
│    File.copy() to /sdcard/Android/obb/{pkg}/              │
│    emit InstallerCopyingObb(gameName: "Beat Saber")        │
│                                                           │
│  Stage 4: CLEANUP                                         │
│    Delete {cache}/{id}/ directory                          │
│    emit InstallerSuccess(gameName: "Beat Saber")           │
└──────────────────────────────────────────────────────────┘
               ▼
┌──────────────────────────────────────────┐
│  UI shows success snackbar               │
│  Game appears with "Installed" badge     │
│  Storage indicator updates               │
└──────────────────────────────────────────┘
```

---

## 16. Existing Precedents (Proof It Works)

| Tool | What It Proves |
|------|---------------|
| **[Quest APK Installer](https://anagan79.itch.io/quest-apk-installer)** | APK + OBB installation from headset via PackageInstaller. Works on firmware v74+. |
| **[QRookie](https://github.com/glaumar/QRookie)** | VRP mirror protocol consumed without rclone from non-Windows client. |
| **[RCX](https://github.com/x0b/rcx) / [Round-Sync](https://github.com/newhinton/Round-Sync)** | rclone runs on Android ARM64 (backup option). |
| **SideQuest In-Headset** | Full app store running natively on Quest as 2D panel. |
| **ManageXR** | Enterprise MDM confirms OBB file placement works on Quest. |
| **[QuestSide](https://github.com/HAX05/QuestSide---APK-OBB-Installer-for-Mobile)** | APK + OBB install from Android app. |

---

## 17. Challenges and Mitigations

| Challenge | Impact | Mitigation |
|-----------|--------|------------|
| **Storage (2x temp space)** | HIGH | Check space before download. Delete archives immediately after extraction. Show warnings. |
| **Scoped Storage (Android 12L)** | MEDIUM | `MANAGE_EXTERNAL_STORAGE` + `requestLegacyExternalStorage`. Confirmed working on Quest firmware v74. |
| **Meta firmware updates** | LOW | Would break ALL sideloading (SideQuest, etc.) — unlikely to happen. |
| **7z extraction speed** | MEDIUM | Use native ARM64 7za binary, not Java. Background isolate. XR2 Gen 2 is capable. |
| **Flutter Quest compatibility** | LOW | Confirmed working. Build APK, not AAB. Meta Spatial Simulator mentions Flutter. |
| **Download interruption (sleep)** | MEDIUM | `WAKE_LOCK` + foreground service with notification. Resume via HTTP Range. |
| **No Google Play Services** | LOW | Don't depend on any GMS APIs. Use `dio` not `googleapis`. |

---

## 18. Implementation Phases

### Phase 1: Foundation
- `flutter create`, pubspec, build.gradle for Quest ARM64
- Android manifest with panel size + permissions
- Dark Material 3 theme (VR-optimized)
- get_it + injectable DI setup
- App shell with 3-tab BottomNavigationBar (Browse, Downloads, Settings)

### Phase 2: Config + Catalog
- ConfigRepository: fetch vrp-public.json with fallback
- CatalogRepository: download meta.7z, extract, parse VRP-GameList.txt
- Bundle 7za ARM64 binary, copy to writable dir on first launch
- Hive cache for game list
- CatalogBloc with Load, Search, Filter, Sort events
- Game grid UI with thumbnails

### Phase 3: Download Engine
- DownloadRepository: directory listing parse, multi-file download with dio
- HTTP Range resume support
- Download queue persistence in Hive
- DownloadBloc with Start, Cancel, Retry events
- Downloads page with progress bars

### Phase 4: Installation Pipeline
- Kotlin PackageInstaller platform channel
- ArchiveExtractor: Process.run() for 7za binary
- OBB file copy to /sdcard/Android/obb/
- InstallerBloc with full pipeline stages
- Permission flows (REQUEST_INSTALL_PACKAGES, MANAGE_EXTERNAL_STORAGE)

### Phase 5: Polish
- Installed game detection (query installed packages via platform channel)
- Settings page (clear cache, storage info, about)
- Error retry logic for all network operations
- App icon
- Test on Quest 2 + Quest 3 hardware

---

## Sources & References

### Project References
- [VRPirates/rookie source code](https://github.com/VRPirates/rookie)
- [QRookie - cross-platform alternative](https://github.com/glaumar/QRookie)
- [Quest APK Installer by Anagan79](https://anagan79.itch.io/quest-apk-installer)
- [QuestSide - APK/OBB Installer](https://github.com/HAX05/QuestSide---APK-OBB-Installer-for-Mobile)
- [RCX - Rclone for Android](https://github.com/x0b/rcx)

### Flutter Architecture
- [Flutter Official App Architecture Guide](https://docs.flutter.dev/app-architecture/guide)
- [Flutter 3.38 Clean Architecture: Modern Project Structure 2025](https://medium.com/@flutter-app/flutter-3-38-clean-architecture-project-structure-for-2025-f6155ac40d87)
- [Flutter BLoC Architecture That Actually Scales (2025)](https://medium.com/@alaxhenry0121/the-ultimate-flutter-bloc-architecture-guide-build-production-ready-apps-like-a-pro-be722ed5f4a5)
- [Scalable Folder Structure: Clean Architecture + BLoC/Cubit](https://dev.to/alaminkarno/building-a-scalable-folder-structure-in-flutter-using-clean-architecture-bloccubit-530c)
- [flutter-bloc-clean-architecture-boilerplate](https://github.com/V0-MVP/flutter-bloc-clean-architecture-boilerplate)

### Flutter BLoC & State Management
- [flutter_bloc package](https://pub.dev/packages/flutter_bloc)
- [BLoC Concepts (official docs)](https://bloclibrary.dev/bloc-concepts/)
- [Flutter BLoC Tutorial 2026](https://www.zignuts.com/blog/flutter-bloc-tutorial)
- [Bloc vs Cubit: When Should You Use Each?](https://medium.com/@wassimsakri/bloc-vs-cubit-in-flutter-when-should-you-use-each-5dc21c20c053)
- [Bloc + Freezed: A Match Made in Heaven](https://dev.to/ptrbrynt/why-bloc-freezed-is-a-match-made-in-heaven-29ai)
- [Stop Using Freezed map/when, Use Sealed Class Pattern Matching](https://tomasrepcik.dev/blog/2024/2024-03-27-freezed-pattern-matching/)

### Error Handling
- [Functional Error Handling with Either and fpdart](https://codewithandrea.com/articles/functional-error-handling-either-fpdart/)
- [fpdart package](https://pub.dev/packages/fpdart)

### Dependency Injection
- [Why Clean Flutter Apps Use DI](https://dev.to/alaminkarno/why-clean-flutter-apps-use-dependency-injection-and-yours-should-too-3668)
- [Advanced DI with get_it and injectable](https://vibe-studio.ai/insights/advanced-dependency-injection-with-get-it-and-injectable-in-flutter)
- [Clean Architecture with DI Using GetIt](https://medium.com/@chandru1918g/flutter-clean-architecture-with-dependency-injection-using-getit-e1f1ad81a5ca)

### Meta Quest Platform
- [Android Apps on Meta Horizon OS](https://developers.meta.com/horizon/documentation/android-apps/horizon-os-apps/)
- [Panel Sizing](https://developers.meta.com/horizon/documentation/android-apps/panel-sizing/)
- [Android Manifest Settings](https://developers.meta.com/horizon/documentation/native/android/mobile-native-manifest/)
- [Meta Quest Apps Must Target Android 12L](https://developers.meta.com/horizon/blog/meta-quest-apps-android-12l-june-30/)
- [Android PackageInstaller API](https://developer.android.com/reference/android/content/pm/PackageInstaller)
