import 'package:flutter/material.dart';
import 'package:game_size_manager/core/logging/logger_service.dart';

/// Catches uncaught Flutter errors and shows a friendly UI.
class GlobalErrorBoundary extends StatefulWidget {
  const GlobalErrorBoundary({super.key, required this.child});

  final Widget child;

  @override
  State<GlobalErrorBoundary> createState() => _GlobalErrorBoundaryState();
}

class _GlobalErrorBoundaryState extends State<GlobalErrorBoundary> {
  final _logger = LoggerService.instance;
  bool _hasError = false;
  FlutterErrorDetails? _errorDetails;
  void Function(FlutterErrorDetails)? _previousErrorHandler;

  @override
  void initState() {
    super.initState();
    // Catch errors from the framework
    _previousErrorHandler = FlutterError.onError;
    FlutterError.onError = _handleFlutterError;
  }

  @override
  void dispose() {
    // Restore previous handler to avoid leaks (especially in tests)
    FlutterError.onError = _previousErrorHandler;
    super.dispose();
  }

  void _handleFlutterError(FlutterErrorDetails details) {
    _logger.error('Uncaught Flutter Error', error: details.exception, stackTrace: details.stack);

    // In dev, let standard logging happen too
    FlutterError.presentError(details);

    if (mounted) {
      setState(() {
        _hasError = true;
        _errorDetails = details;
      });
    }
  }

  // Also catch async errors if we wrap the app correctly,
  // though runZonedGuarded is usually done in main.dart.
  // This widget primarily handles widget build errors.

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorApp(context);
    }

    // Custom error widget for build errors that occur below this widget
    ErrorWidget.builder = (FlutterErrorDetails details) {
      _logger.error('Build Error', error: details.exception, stackTrace: details.stack);
      return Material(child: _buildErrorScreen(details));
    };

    return widget.child;
  }

  Widget _buildErrorApp(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: _buildErrorScreen(_errorDetails!)),
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _buildErrorScreen(FlutterErrorDetails details) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
            const SizedBox(height: 24),
            const Text(
              'Oops! Something went wrong.',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'We encountered an unexpected error. Please restart the app.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                // Hard restart or just reset state?
                // For now, reset error state
                setState(() {
                  _hasError = false;
                  _errorDetails = null;
                });
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
            const SizedBox(height: 24),
            if (details.exceptionAsString().isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  details.exceptionAsString(),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
