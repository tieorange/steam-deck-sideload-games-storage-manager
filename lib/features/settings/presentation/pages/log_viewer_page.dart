import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_size_manager/core/logging/logger_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class LogViewerPage extends StatefulWidget {
  const LogViewerPage({super.key});

  @override
  State<LogViewerPage> createState() => _LogViewerPageState();
}

class _LogViewerPageState extends State<LogViewerPage> {
  // Store lines instead of monolithic string to avoid O(N) splitting on every frame
  List<String> _logLines = [];
  bool _isLoading = true;
  double _loadingProgress = 0.0;
  final ScrollController _scrollController = ScrollController();

  // Cache formatted text styles to avoid recreating them
  late final TextStyle _baseStyle;
  late final TextStyle _errorStyle;
  late final TextStyle _warningStyle;
  late final TextStyle _infoStyle;
  late final TextStyle _debugStyle;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize styles once based on theme
    final theme = Theme.of(context);
    _baseStyle = TextStyle(
      fontFamily: 'monospace',
      fontSize: 13,
      color: theme.colorScheme.onSurface,
    );
    _errorStyle = _baseStyle.copyWith(color: theme.colorScheme.error, fontWeight: FontWeight.bold);
    _warningStyle = _baseStyle.copyWith(color: Colors.orange);
    _infoStyle = _baseStyle.copyWith(color: theme.colorScheme.primary);
    _debugStyle = _baseStyle.copyWith(color: theme.colorScheme.secondary);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadLogs() async {
    if (!mounted) return;

    // Reset state
    setState(() {
      _isLoading = true;
      _loadingProgress = 0.0;
      _logLines = [];
    });

    try {
      final logPath = await LoggerService.instance.getLogFilePath();
      if (logPath == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final file = File(logPath);
      if (!await file.exists()) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final len = await file.length();
      if (len == 0) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      int bytesRead = 0;
      final lines = <String>[];

      // Stream read to avoid blocking UI with large string allocation
      await file
          .openRead()
          .map((chunk) {
            bytesRead += chunk.length;
            if (len > 0) {
              final progress = bytesRead / len;
              // Throttle UI updates to avoid lag
              if ((progress - _loadingProgress).abs() > 0.05 || progress == 1.0) {
                // Determine if we should update state (async gap safety handled by mounted check below)
                _updateProgress(progress);
              }
            }
            return chunk;
          })
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .forEach((line) {
            lines.add(line);
          });

      if (mounted) {
        setState(() {
          _logLines = lines;
          _isLoading = false;
          _loadingProgress = 1.0;
        });

        // Scroll to bottom after frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load logs: $e')));
      }
    }
  }

  void _updateProgress(double progress) {
    // Only update state if mounted
    if (mounted) {
      // Use microtask to avoid building during build? No, setState is fine.
      // But we need to be careful about calling setState too often.
      // The throttle check above handles it partially, but we can't call setState from the stream listener synchronously if it's running on main isolate?
      // openRead streams are async, so it's fine.
      setState(() {
        _loadingProgress = progress;
      });
    }
  }

  Future<void> _copyLogs() async {
    if (_logLines.isEmpty) return;

    // Join might be heavy, show loading indicator for this too if huge?
    // For now, standard behavior.
    final content = _logLines.join('\n');
    await Clipboard.setData(ClipboardData(text: content));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logs copied to clipboard'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _clearLogs() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Logs?'),
        content: const Text(
          'This will permanently delete the current log file. This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await LoggerService.instance.clearLogs();
      if (mounted) {
        setState(() {
          _logLines = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logs cleared')));
      }
    }
  }

  Future<void> _exportLogs() async {
    try {
      Directory? downloadDir;
      if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
        downloadDir = await getDownloadsDirectory();
      }

      // Fallback if null (e.g. mobile or unsupported)
      downloadDir ??= await getApplicationDocumentsDirectory();

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File(p.join(downloadDir.path, 'game_size_manager_logs_$timestamp.txt'));

      // Efficiently write lines
      final sink = file.openWrite();
      for (final line in _logLines) {
        sink.writeln(line);
      }
      await sink.close();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logs saved to ${file.path}'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Open Folder',
              onPressed: () {
                // Determine OS commands to open folder?
                // For simplified scope, just let user know path.
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export logs: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // If loading, show progress bar
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading Logs...')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(value: _loadingProgress),
              const SizedBox(height: 16),
              Text(
                '${(_loadingProgress * 100).toStringAsFixed(0)}%',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text('Parsing log file...', style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Log Viewer (${_logLines.length} lines)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: _logLines.isEmpty ? null : _clearLogs,
            tooltip: 'Clear logs',
            color: theme.colorScheme.error,
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadLogs, tooltip: 'Refresh'),
          IconButton(icon: const Icon(Icons.copy), onPressed: _copyLogs, tooltip: 'Copy all'),
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: _exportLogs,
            tooltip: 'Export to file',
          ),
        ],
      ),
      body: SelectionArea(
        child: Container(
          color: theme.colorScheme.surfaceContainerHighest,
          child: _logLines.isEmpty
              ? const Center(child: Text('No logs found.'))
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _logLines.length,
                  itemBuilder: (context, index) {
                    return _buildLogLine(_logLines[index]);
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildLogLine(String line) {
    if (line.isEmpty) return const SizedBox.shrink();

    TextStyle style = _baseStyle;

    // Fast caching based on content
    if (line.contains('ERROR') || line.contains('[ERROR]')) {
      style = _errorStyle;
    } else if (line.contains('WARNING') || line.contains('[WARNING]')) {
      style = _warningStyle;
    } else if (line.contains('INFO') || line.contains('[INFO]')) {
      style = _infoStyle;
    } else if (line.contains('DEBUG') || line.contains('[DEBUG]')) {
      style = _debugStyle;
    }

    // Try to preserve monospaced look
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(line, style: style),
    );
  }
}
