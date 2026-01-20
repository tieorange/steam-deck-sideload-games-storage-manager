import 'dart:io';

import 'package:dartz/dartz.dart';

import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/core/error/failures.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';
import 'package:game_size_manager/features/games/domain/repositories/game_repository.dart';

/// Mock repository for macOS development and testing
class MockGameRepository implements GameRepository {
  MockGameRepository();

  String get _mockIconPath =>
      '${Directory.current.path}/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png';

  // Sample game data for testing UI
  late final List<Game> _mockGames = [
    Game(
      id: 'heroic_epic_cyberpunk',
      title: 'Cyberpunk 2077',
      source: GameSource.heroic,
      installPath: '/home/deck/Games/Heroic/Cyberpunk2077',
      sizeBytes: 75 * 1024 * 1024 * 1024, // 75 GB
      iconPath: _mockIconPath,
    ),
    Game(
      id: 'steam_1245620',
      title: 'Elden Ring',
      source: GameSource.steam,
      installPath: '/home/deck/.steam/steam/steamapps/common/ELDEN RING',
      sizeBytes: 49 * 1024 * 1024 * 1024, // 49 GB
      iconPath: _mockIconPath,
    ),
    Game(
      id: 'heroic_gog_witcher3',
      title: 'The Witcher 3: Wild Hunt',
      source: GameSource.heroic,
      installPath: '/home/deck/Games/Heroic/TheWitcher3',
      sizeBytes: 50 * 1024 * 1024 * 1024, // 50 GB
      iconPath: _mockIconPath,
    ),
    Game(
      id: 'steam_292030',
      title: 'The Witcher 3: Wild Hunt (Steam)',
      source: GameSource.steam,
      installPath: '/home/deck/.steam/steam/steamapps/common/The Witcher 3',
      sizeBytes: 50 * 1024 * 1024 * 1024, // 50 GB
      iconPath: _mockIconPath,
    ),
    Game(
      id: 'ogi_hogwartslegacy',
      title: 'Hogwarts Legacy',
      source: GameSource.ogi,
      installPath: '/home/deck/Games/OGI/HogwartsLegacy',
      sizeBytes: 85 * 1024 * 1024 * 1024, // 85 GB
      iconPath: _mockIconPath,
    ),
    Game(
      id: 'lutris_baldursgate3',
      title: "Baldur's Gate 3",
      source: GameSource.lutris,
      installPath: '/home/deck/Games/lutris/baldursgate3',
      sizeBytes: 122 * 1024 * 1024 * 1024, // 122 GB
      iconPath: _mockIconPath,
    ),
    Game(
      id: 'steam_1174180',
      title: 'Red Dead Redemption 2',
      source: GameSource.steam,
      installPath: '/home/deck/.steam/steam/steamapps/common/Red Dead Redemption 2',
      sizeBytes: 116 * 1024 * 1024 * 1024, // 116 GB
      iconPath: _mockIconPath,
    ),
    Game(
      id: 'heroic_epic_gta5',
      title: 'Grand Theft Auto V',
      source: GameSource.heroic,
      installPath: '/home/deck/Games/Heroic/GTAV',
      sizeBytes: 95 * 1024 * 1024 * 1024, // 95 GB
      iconPath: _mockIconPath,
    ),
    Game(
      id: 'steam_730',
      title: 'Counter-Strike 2',
      source: GameSource.steam,
      installPath: '/home/deck/.steam/steam/steamapps/common/Counter-Strike Global Offensive',
      sizeBytes: 35 * 1024 * 1024 * 1024, // 35 GB
      iconPath: _mockIconPath,
    ),
    Game(
      id: 'ogi_starfield',
      title: 'Starfield',
      source: GameSource.ogi,
      installPath: '/home/deck/Games/OGI/Starfield',
      sizeBytes: 140 * 1024 * 1024 * 1024, // 140 GB
      iconPath: _mockIconPath,
    ),
    Game(
      id: 'lutris_ff16',
      title: 'Final Fantasy XVI',
      source: GameSource.lutris,
      installPath: '/home/deck/Games/lutris/ff16',
      sizeBytes: 90 * 1024 * 1024 * 1024, // 90 GB
      iconPath: _mockIconPath,
    ),
    Game(
      id: 'steam_570',
      title: 'Dota 2',
      source: GameSource.steam,
      installPath: '/home/deck/.steam/steam/steamapps/common/dota 2 beta',
      sizeBytes: 30 * 1024 * 1024 * 1024, // 30 GB
      iconPath: _mockIconPath,
    ),
  ];

  @override
  Future<Result<List<Game>>> getGames() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return Right(_mockGames);
  }

  @override
  Future<Result<List<Game>>> getGamesBySource(GameSource source) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return Right(_mockGames.where((g) => g.source == source).toList());
  }

  @override
  Future<Result<Game>> calculateGameSize(Game game) async {
    // Mock games already have sizes
    await Future.delayed(const Duration(milliseconds: 100));
    return Right(game);
  }

  @override
  Future<Result<void>> uninstallGame(Game game) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockGames.removeWhere((g) => g.id == game.id);
    return const Right(null);
  }

  @override
  Future<Result<List<Game>>> refreshGames({void Function(String, double)? onProgress}) async {
    // Simulate realistic progress
    if (onProgress != null) {
      onProgress('Scanning launchers...', 0.2);
      await Future.delayed(const Duration(milliseconds: 400));
      onProgress('Processing games...', 0.5);
      await Future.delayed(const Duration(milliseconds: 400));
      onProgress('Calculating sizes...', 0.8);
      await Future.delayed(const Duration(milliseconds: 400));
      onProgress('Complete!', 1.0);
    }
    return getGames();
  }
}
