import 'dart:developer' as developer;

/// Simple logging service
class LoggerService {
  LoggerService._();
  static final LoggerService instance = LoggerService._();
  
  bool _initialized = false;
  
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    info('LoggerService initialized');
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
  
  void _log(
    String level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final prefix = tag != null ? '[$tag]' : '';
    final logMessage = '[$timestamp] [$level] $prefix $message';
    
    developer.log(
      logMessage,
      name: 'GameSizeManager',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
