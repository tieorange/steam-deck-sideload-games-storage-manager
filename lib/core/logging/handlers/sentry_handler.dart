import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/core/logging/logger_service.dart';

/// Handler for Sentry Crash Reporting and Monitoring
class SentryLogHandler extends LogHandler {
  bool _initialized = false;

  @override
  Future<void> init() async {
    if (AppConstants.sentryDsn.isEmpty) {
      return;
    }

    try {
      await SentryFlutter.init((options) {
        options.dsn = AppConstants.sentryDsn;
        options.tracesSampleRate = 1.0;
        options.enableAutoPerformanceTracing = true;
        // Linux native crash reporting is enabled by default in recent versions
      });
      _initialized = true;
    } catch (e) {
      // Fallback for console logging if Sentry fails
      // ignore: avoid_print
      print(
        'Failed to initialize Sentry: $e',
      ); // Keeping print as fallback, or use developer log if imported
    }
  }

  @override
  void log(String level, String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (!_initialized) return;

    final prefix = tag != null ? '[$tag]' : '';

    if (level == 'ERROR') {
      Sentry.captureException(
        error ?? message,
        stackTrace: stackTrace,
        hint: Hint.withMap({'message': message, 'tag': tag}),
      );
    } else {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: '$prefix $message',
          level: _mapLevel(level),
          category: tag,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  SentryLevel _mapLevel(String level) {
    switch (level) {
      case 'DEBUG':
        return SentryLevel.debug;
      case 'INFO':
        return SentryLevel.info;
      case 'WARNING':
        return SentryLevel.warning;
      case 'ERROR':
        return SentryLevel.error;
      default:
        return SentryLevel.info;
    }
  }

  @override
  Future<void> dispose() async {
    await Sentry.close();
  }
}
