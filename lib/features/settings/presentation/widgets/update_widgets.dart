import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:game_size_manager/core/services/update_service.dart';

/// Widget that shows update notification banner
class UpdateBanner extends StatefulWidget {
  const UpdateBanner({super.key, required this.child});
  
  final Widget child;

  @override
  State<UpdateBanner> createState() => _UpdateBannerState();
}

class _UpdateBannerState extends State<UpdateBanner> {
  UpdateStatus? _status;
  bool _dismissed = false;
  bool _isChecking = false;
  
  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }
  
  Future<void> _checkForUpdates() async {
    if (_isChecking) return;
    
    setState(() => _isChecking = true);
    
    // Small delay to not block app startup
    await Future.delayed(const Duration(seconds: 2));
    
    final status = await UpdateService.instance.checkForUpdate();
    
    if (mounted) {
      setState(() {
        _status = status;
        _isChecking = false;
      });
    }
  }
  
  Future<void> _openDownload() async {
    final url = _status?.downloadUrl;
    if (url != null) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_status?.isUpdateAvailable == true && !_dismissed)
          _buildBanner(context),
        Expanded(child: widget.child),
      ],
    );
  }
  
  Widget _buildBanner(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.system_update_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Update Available',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Version ${_status?.latestVersion} is ready',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _dismissed = true),
              child: const Text('Later'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: _openDownload,
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Update checker dialog
class UpdateCheckDialog extends StatefulWidget {
  const UpdateCheckDialog({super.key});

  @override
  State<UpdateCheckDialog> createState() => _UpdateCheckDialogState();
}

class _UpdateCheckDialogState extends State<UpdateCheckDialog> {
  UpdateStatus? _status;
  bool _isChecking = true;
  
  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }
  
  Future<void> _checkForUpdates() async {
    final status = await UpdateService.instance.checkForUpdate();
    if (mounted) {
      setState(() {
        _status = status;
        _isChecking = false;
      });
    }
  }
  
  Future<void> _openDownload() async {
    final url = _status?.downloadUrl;
    if (url != null) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.system_update_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          const Text('Check for Updates'),
        ],
      ),
      content: _isChecking
        ? const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          )
        : _buildContent(theme),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        if (_status?.isUpdateAvailable == true)
          FilledButton.icon(
            onPressed: _openDownload,
            icon: const Icon(Icons.download_rounded),
            label: const Text('Download'),
          ),
      ],
    );
  }
  
  Widget _buildContent(ThemeData theme) {
    if (_status?.hasError == true) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text('Failed to check for updates', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            _status?.error ?? 'Unknown error',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    
    if (_status?.isUpdateAvailable == true) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.new_releases_rounded, color: theme.colorScheme.primary, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Version Available!',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_status?.currentVersion} → ${_status?.latestVersion}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_status?.releaseNotes.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            Text('What\'s New', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              child: SingleChildScrollView(
                child: Text(
                  _status!.releaseNotes,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ],
      );
    }
    
    // Up to date
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded, size: 48, color: Colors.green),
        ),
        const SizedBox(height: 16),
        Text('You\'re up to date!', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          'Version ${_status?.currentVersion}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
