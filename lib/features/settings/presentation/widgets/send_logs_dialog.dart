import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:game_size_manager/core/logging/logger_service.dart';
import 'package:game_size_manager/core/services/log_share_service.dart';

/// A modern, Steam Deck-friendly dialog for sending logs to the developer
class SendLogsDialog extends StatefulWidget {
  const SendLogsDialog({super.key});

  @override
  State<SendLogsDialog> createState() => _SendLogsDialogState();
}

class _SendLogsDialogState extends State<SendLogsDialog> {
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  bool _isSent = false;
  LogShareResult? _result;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _sendLogs() async {
    setState(() {
      _isLoading = true;
    });

    final result = await LogShareService.instance.shareLogsWithDeveloper(
      userDescription: _descriptionController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _result = result;
        _isSent = true;
      });
    }
  }

  Future<void> _clearLogs() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Logs?'),
        content: const Text('This will delete all log files. This action cannot be undone.'),
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

    if (confirmed == true && mounted) {
      final success = await LoggerService.instance.clearLogs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Logs cleared!' : 'Failed to clear logs'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _openLogFolder() async {
    final logPath = await LoggerService.instance.getLogFilePath();
    if (logPath != null) {
      final dir = Directory(logPath).parent;
      await launchUrl(Uri.directory(dir.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: _isSent ? _buildResultView(theme) : _buildFormView(theme),
      ),
    );
  }

  Widget _buildFormView(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.3),
                    theme.colorScheme.tertiary.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.bug_report_rounded, color: theme.colorScheme.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Send Logs to Developer',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Help us fix bugs by sharing your logs',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Description field
        Text('Describe the issue (optional)', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: 'What happened? What were you doing?',
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Info box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your logs will be attached to an email sent to the developer.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Actions
        Row(
          children: [
            // Log management buttons
            IconButton(
              onPressed: _isLoading ? null : _openLogFolder,
              icon: const Icon(Icons.folder_open_rounded),
              tooltip: 'Open Log Folder',
            ),
            IconButton(
              onPressed: _isLoading ? null : _clearLogs,
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Clear Logs',
            ),
            const Spacer(),
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: _isLoading ? null : _sendLogs,
              icon: _isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(_isLoading ? 'Sending...' : 'Send Logs'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultView(ThemeData theme) {
    final success = _result?.success ?? false;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: success ? theme.colorScheme.primaryContainer : theme.colorScheme.errorContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            success ? Icons.check_rounded : Icons.error_outline_rounded,
            color: success
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onErrorContainer,
            size: 48,
          ),
        ),
        const SizedBox(height: 24),

        // Title
        Text(
          success ? 'Logs Sent!' : 'Something Went Wrong',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Message
        Text(
          success
              ? 'Thanks for helping us improve the app. We\'ll look into it!'
              : _result?.errorMessage ?? 'An unknown error occurred.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),

        // Show URL if available
        // Show URL if available (Legacy/Fallback)
        if (_result?.dpasteUrl != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _result!.dpasteUrl!,
                    style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _result!.dpasteUrl!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('URL copied to clipboard'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  tooltip: 'Copy URL',
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Close button
        FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
      ],
    );
  }
}
