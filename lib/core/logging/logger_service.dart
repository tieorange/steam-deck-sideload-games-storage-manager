import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:developer' as developer;

/// Simple logging service
class LoggerService {
  LoggerService._();
  static final LoggerService instance = LoggerService._();

  bool _initialized = false;
  File? _logFile;
  IOSink? _sink;

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
      info('LoggerService initialized. Log file: ${_logFile!.path}');
    } catch (e) {
      developer.log('Failed to initialize file logger: $e');
    }
  }

  Future<String?> getLogFilePath() async {
    return _logFile?.path;
  }

  void debug(String message, {String? tag}) {
    _log('DEBUG', message, tag: tag);
  }

  void info(String message, {String? tag}) {
    _log('INFO', message, tag: tag);
  }

  void warning(String message, {String? tag}) {
    _log('WARNING', message, tag: tag);
  }

  void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    _log('ERROR', message, tag: tag, error: error, stackTrace: stackTrace);
  }

  void _log(String level, String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    final timestamp = DateTime.now().toIso8601String();
    final prefix = tag != null ? '[$tag]' : '';
    final logMessage = '[$timestamp] [$level] $prefix $message';

    // Log to console
    developer.log(logMessage, name: 'GameSizeManager', error: error, stackTrace: stackTrace);

    // Log to file
    try {
      if (_sink != null) {
        _sink!.writeln(logMessage);
        if (error != null) _sink!.writeln(error.toString());
        if (stackTrace != null) _sink!.writeln(stackTrace.toString());
      }
    } catch (e) {
      // Ignore file log errors
    }
  }

  void dispose() {
    _sink?.close();
  }
}
