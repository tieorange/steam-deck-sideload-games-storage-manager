import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';

import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/core/error/failures.dart';
import 'package:game_size_manager/core/logging/logger_service.dart';
import 'package:game_size_manager/core/services/game_source_service.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';

/// Android/Quest implementation of GameSourceService.
/// Uses MethodChannel to call native Kotlin code for StorageStatsManager.
class QuestGameSource implements GameSourceService {
  static const _channel = MethodChannel('com.tieorange.game_size_manager/games');
  final LoggerService _logger;

  QuestGameSource({LoggerService? logger}) : _logger = logger ?? LoggerService.instance;

  @override
  Future<Result<List<Game>>> getGames() async {
    try {
      _logger.info('Fetching installed apps via MethodChannel...', tag: 'QuestGameSource');

      final String? jsonResult = await _channel.invokeMethod<String>('getInstalledApps');

      if (jsonResult == null || jsonResult.isEmpty) {
        _logger.warning('No apps returned from native layer', tag: 'QuestGameSource');
        return const Right([]);
      }

      final List<dynamic> appsJson = json.decode(jsonResult) as List<dynamic>;
      final games = appsJson.map((appJson) {
        final map = appJson as Map<String, dynamic>;

        // Convert base64 icon to data URI if available
        final iconBase64 = map['iconBase64'] as String?;
        final iconPath = iconBase64 != null ? 'data:image/png;base64,$iconBase64' : null;

        return Game(
          id: map['packageName'] as String,
          title: map['appName'] as String,
          source: _mapSource(map['source'] as String?),
          installPath: map['packageName'] as String, // Android uses packageName as "path"
          sizeBytes: (map['totalBytes'] as int?) ?? 0,
          iconPath: iconPath,
        );
      }).toList();

      _logger.info('Loaded ${games.length} apps from Android', tag: 'QuestGameSource');
      return Right(games);
    } on PlatformException catch (e, s) {
      _logger.error(
        'PlatformException fetching apps: ${e.message}',
        error: e,
        stackTrace: s,
        tag: 'QuestGameSource',
      );
      return Left(UnexpectedFailure('Failed to fetch apps: ${e.message}', s));
    } catch (e, s) {
      _logger.error(
        'Unexpected error fetching apps: $e',
        error: e,
        stackTrace: s,
        tag: 'QuestGameSource',
      );
      return Left(UnexpectedFailure('Unexpected error: $e', s));
    }
  }

  @override
  bool get supportsUninstall => true; // Android can launch uninstall dialog

  /// Launch the Android uninstall dialog for the given package
  @override
  Future<Result<void>> uninstallGame(String gameId) async {
    try {
      _logger.info('Requesting uninstall for: $gameId', tag: 'QuestGameSource');
      await _channel.invokeMethod('uninstallApp', {'packageName': gameId});
      return const Right(null);
    } on PlatformException catch (e, s) {
      _logger.error(
        'Failed to uninstall: ${e.message}',
        error: e,
        stackTrace: s,
        tag: 'QuestGameSource',
      );
      return Left(UnexpectedFailure('Uninstall failed: ${e.message}', s));
    }
  }

  GameSource _mapSource(String? source) {
    switch (source) {
      case 'META_STORE':
        return GameSource.steam; // Reuse enum; could add GameSource.metaStore later
      case 'SIDELOADED':
        return GameSource.heroic; // Reuse enum for "sideloaded"
      default:
        return GameSource.ogi; // Fallback
    }
  }
}
