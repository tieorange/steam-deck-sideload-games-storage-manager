import 'package:steam_deck_games_detector/steam_deck_games_detector.dart' as pkg;
import 'package:game_size_manager/core/logging/logger_service.dart' as app;

/// Bridges logs from the [steam_deck_games_detector] package to the app's [LoggerService].
class BridgeLogger extends pkg.LogHandler {
  final app.LoggerService _appLogger;

  BridgeLogger(this._appLogger);

  @override
  Future<void> init() async {}

  @override
  void log(String level, String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    // Forward to App Logger
    // Map string levels if necessary, but strings likely match (DEBUG, INFO, WARNING, ERROR)
    switch (level) {
      case 'DEBUG':
        _appLogger.debug(message, tag: tag);
        break;
      case 'INFO':
        _appLogger.info(message, tag: tag);
        break;
      case 'WARNING':
        _appLogger.warning(message, tag: tag);
        break;
      case 'ERROR':
        _appLogger.error(message, error: error, stackTrace: stackTrace, tag: tag);
        break;
      default:
        _appLogger.info('[$level] $message', tag: tag);
    }
  }

  @override
  Future<void> dispose() async {}
}
