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
  String _logs = '';
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    final content = await LoggerService.instance.getLogContent();
    if (mounted) {
      setState(() {
        _logs = content ?? 'No logs found.';
        _isLoading = false;
      });
      // Scroll to bottom after frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  Future<void> _copyLogs() async {
    await Clipboard.setData(ClipboardData(text: _logs));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logs copied to clipboard'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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

      await file.writeAsString(_logs);

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
                // Or implementing Open Folder logic if time permits.
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Viewer'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadLogs, tooltip: 'Refresh'),
          IconButton(icon: const Icon(Icons.copy), onPressed: _copyLogs, tooltip: 'Copy all'),
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: _exportLogs,
            tooltip: 'Export to file',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SelectionArea(
              child: Container(
                color: theme
                    .colorScheme
                    .surfaceContainerHighest, // specific "terminal-like" bg? Or just theme?
                // Let's keep it theme consistent but maybe slightly distinct
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _logs.isEmpty ? 1 : _logs.split('\n').length,
                  itemBuilder: (context, index) {
                    if (_logs.isEmpty) return const Text('No logs.');

                    final lines = _logs.split('\n');
                    if (index >= lines.length) return null;

                    final line = lines[index];
                    if (line.isEmpty) return const SizedBox.shrink();

                    return _buildLogLine(line, theme);
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildLogLine(String line, ThemeData theme) {
    Color color = theme.colorScheme.onSurface;
    FontWeight weight = FontWeight.normal;

    // Simple heuristic for coloring
    if (line.contains('ERROR') || line.contains('[ERROR]')) {
      color = theme.colorScheme.error;
      weight = FontWeight.bold;
    } else if (line.contains('WARNING') || line.contains('[WARNING]')) {
      color = Colors.orange; // specific color often readable in dark/light
    } else if (line.contains('INFO') || line.contains('[INFO]')) {
      color = theme.colorScheme.primary;
    } else if (line.contains('DEBUG') || line.contains('[DEBUG]')) {
      color = theme.colorScheme.secondary;
    }

    // Try to preserve monospaced look
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        line,
        style: TextStyle(fontFamily: 'monospace', fontSize: 13, color: color, fontWeight: weight),
      ),
    );
  }
}
