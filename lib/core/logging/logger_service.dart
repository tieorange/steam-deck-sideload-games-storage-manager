import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:developer' as developer;
import 'package:game_size_manager/core/logging/handlers/sentry_handler.dart';

/// Abstract handler for log outputs
abstract class LogHandler {
  Future<void> init();
  void log(String level, String message, {String? tag, Object? error, StackTrace? stackTrace});
  Future<void> dispose();
}

/// Handler for console logging using colored print for better visibility
class ConsoleLogHandler extends LogHandler {
  @override
  Future<void> init() async {}

  @override
  void log(String level, String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    // Human readable timestamp (HH:mm:ss)
    final timestamp = DateTime.now().toIso8601String().split('T')[1].split('.')[0];
    final prefix = tag != null ? '[$tag]' : '';

    String emoji = '';
    String colorCode = '';

    switch (level) {
      case 'DEBUG':
        emoji = '🐛';
        colorCode = '\x1B[36m'; // Cyan
        break;
      case 'INFO':
        emoji = 'ℹ️';
        colorCode = '\x1B[32m'; // Green
        break;
      case 'WARNING':
        emoji = '⚠️';
        colorCode = '\x1B[33m'; // Yellow
        break;
      case 'ERROR':
        emoji = '🚨';
        colorCode = '\x1B[31m'; // Red
        break;
      default:
        colorCode = '\x1B[0m';
    }

    const resetColor = '\x1B[0m';
    final logMessage = '$colorCode$emoji [$timestamp] $level $prefix $message$resetColor';

    // ignore: avoid_print
    print(logMessage);
    if (error != null) {
      // ignore: avoid_print
      print('$colorCode$error$resetColor');
    }
    if (stackTrace != null) {
      // ignore: avoid_print
      print('$colorCode$stackTrace$resetColor');
    }
  }

  @override
  Future<void> dispose() async {}
}

/// Handler for file logging
class FileLogHandler extends LogHandler {
  File? _logFile;
  IOSink? _sink;
  bool _initialized = false;

  @override
  Future<void> init() async {
    if (_initialized) return;

    try {
      final dir = await getApplicationSupportDirectory();
      final logDir = Directory(p.join(dir.path, 'logs'));
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      _logFile = File(p.join(logDir.path, 'app.log'));
      _sink = _logFile!.openWrite(mode: FileMode.append);

      _initialized = true;
    } catch (e) {
      developer.log('Failed to initialize file logger: $e');
    }
  }

  @override
  void log(String level, String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (!_initialized || _sink == null) return;

    try {
      final timestamp = DateTime.now().toIso8601String();
      final prefix = tag != null ? '[$tag]' : '';
      final logMessage = '[$timestamp] [$level] $prefix $message';

      _sink!.writeln(logMessage);
      if (error != null) _sink!.writeln(error.toString());
      if (stackTrace != null) _sink!.writeln(stackTrace.toString());
    } catch (e) {
      // Ignore file log errors
    }
  }

  String? get logFilePath => _logFile?.path;

  String? get logDirectoryPath => _logFile?.parent.path;

  Future<String?> getLogContent() async {
    if (_logFile == null) return null;

    try {
      await _sink?.flush();
      if (!await _logFile!.exists()) return null;
      return await _logFile!.readAsString();
    } catch (e) {
      developer.log('Failed to read log file: $e');
      return null;
    }
  }

  Future<bool> clearLogs() async {
    try {
      if (_logFile == null) return false;
      await _sink?.close();
      if (await _logFile!.exists()) await _logFile!.delete();
      _sink = _logFile!.openWrite(mode: FileMode.append);
      return true;
    } catch (e) {
      developer.log('Failed to clear logs: $e');
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    await _sink?.close();
  }
}

/// Extensible Service for logging
class LoggerService {
  LoggerService._();
  static final LoggerService instance = LoggerService._();

  final List<LogHandler> _handlers = [];
  FileLogHandler? _fileHandler;

  bool _initialized = false;

  /// Initialize all registered handlers
  Future<void> init() async {
    if (_initialized) return;

    // Add default handlers
    _handlers.add(ConsoleLogHandler());

    _fileHandler = FileLogHandler();
    _handlers.add(_fileHandler!); // Add file handler by default

    // Add Sentry handler (will be silent if DSN not configured)
    _handlers.add(SentryLogHandler());

    // Initialize all
    for (final handler in _handlers) {
      await handler.init();
    }

    _initialized = true;
    info('LoggerService initialized with ${_handlers.length} handlers', tag: 'LoggerService');
  }

  /// Register a new log handler (e.g. Firebase Crashlytics)
  Future<void> registerHandler(LogHandler handler) async {
    _handlers.add(handler);
    if (_initialized) {
      await handler.init();
    }
  }

  // Proxy methods for FileLogHandler
  Future<String?> getLogFilePath() async => _fileHandler?.logFilePath;
  Future<String?> getLogDirectoryPath() async => _fileHandler?.logDirectoryPath;
  Future<String?> getLogContent() async => _fileHandler?.getLogContent();
  Future<bool> clearLogs() async {
    final result = await _fileHandler?.clearLogs();
    if (result == true) {
      info('Logs cleared via FileHandler', tag: 'LoggerService');
    }
    return result ?? false;
  }

  // Standard logging methods
  void debug(String message, {String? tag}) => _log('DEBUG', message, tag: tag);
  void info(String message, {String? tag}) => _log('INFO', message, tag: tag);
  void warning(String message, {String? tag}) => _log('WARNING', message, tag: tag);
  void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) =>
      _log('ERROR', message, tag: tag, error: error, stackTrace: stackTrace);

  void _log(String level, String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    for (final handler in _handlers) {
      try {
        handler.log(level, message, tag: tag, error: error, stackTrace: stackTrace);
      } catch (e) {
        developer.log('Error in log handler: $e');
      }
    }
  }

  Future<void> dispose() async {
    for (final handler in _handlers) {
      await handler.dispose();
    }
  }
}
