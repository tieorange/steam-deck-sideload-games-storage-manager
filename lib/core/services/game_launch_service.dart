import 'dart:io';

import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/core/logging/logger_service.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';

/// Service for launching games via their respective launchers
class GameLaunchService {
  final _logger = LoggerService.instance;

  /// Get the launch URI for a game
  String? getLaunchUri(Game game) {
    switch (game.source) {
      case GameSource.steam:
        final appId = game.id.replaceAll('steam_', '');
        return 'steam://rungameid/$appId';
      case GameSource.heroic:
        return 'heroic://launch/${game.id}';
      case GameSource.lutris:
        return 'lutris:rungame/${game.id}';
      case GameSource.ogi:
        return null; // OGI doesn't have a URI scheme
    }
  }

  /// Launch a game
  Future<bool> launch(Game game) async {
    final uri = getLaunchUri(game);
    if (uri == null) {
      _logger.warning('No launch URI for ${game.title} (${game.source.name})', tag: 'Launch');
      return false;
    }

    _logger.info('Launching ${game.title} via $uri', tag: 'Launch');

    try {
      if (Platform.isLinux) {
        final result = await Process.run('xdg-open', [uri]);
        return result.exitCode == 0;
      } else if (Platform.isMacOS) {
        final result = await Process.run('open', [uri]);
        return result.exitCode == 0;
      }
      return false;
    } catch (e) {
      _logger.error('Failed to launch ${game.title}: $e', tag: 'Launch');
      return false;
    }
  }

  /// Check if a game can be launched
  bool canLaunch(Game game) {
    return getLaunchUri(game) != null;
  }
}
