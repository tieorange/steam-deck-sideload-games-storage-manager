import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:game_size_manager/core/router/app_router.dart';
import 'package:game_size_manager/core/services/update_service.dart';
import 'package:game_size_manager/features/settings/presentation/cubit/update_cubit.dart';
import 'package:game_size_manager/features/settings/presentation/cubit/update_state.dart';

/// Widget that shows update notification banner
class UpdateBanner extends StatefulWidget {
  const UpdateBanner({super.key, required this.child});

  final Widget child;

  @override
  State<UpdateBanner> createState() => _UpdateBannerState();
}

class _UpdateBannerState extends State<UpdateBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<UpdateCubit, UpdateState>(
          builder: (context, state) {
            return state.maybeWhen(
              available: (info) =>
                  !_dismissed ? _buildBanner(context, info) : const SizedBox.shrink(),
              orElse: () => const SizedBox.shrink(),
            );
          },
        ),
        Expanded(child: widget.child),
      ],
    );
  }

  Widget _buildBanner(BuildContext context, UpdateInfo info) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: theme.colorScheme.primaryContainer),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Icon(
              Icons.system_update_rounded,
              color: theme.colorScheme.onPrimaryContainer,
              size: 24,
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
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    'Version ${info.latestVersion} is ready',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _dismissed = true),
              child: Text('Later', style: TextStyle(color: theme.colorScheme.onPrimaryContainer)),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: () {
                final navContext = AppRouter.router.routerDelegate.navigatorKey.currentContext;
                if (navContext != null) {
                  showDialog(context: navContext, builder: (_) => const UpdateCheckDialog());
                }
              },
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
class UpdateCheckDialog extends StatelessWidget {
  const UpdateCheckDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // We assume UpdateCubit is provided globally now (in Main)
    // But if we want to ensure checks happen on open, we might want to call check if unrelated?
    // Actually, GLOBAL check happens on startup.
    // When opening this dialog manually from Settings, we might want to FORCE check?
    // Let's assume the user wants to see current status or force check.
    // We can trigger check on init.

    return _UpdateCheckDialogContent();
  }
}

class _UpdateCheckDialogContent extends StatefulWidget {
  @override
  State<_UpdateCheckDialogContent> createState() => _UpdateCheckDialogContentState();
}

class _UpdateCheckDialogContentState extends State<_UpdateCheckDialogContent> {
  @override
  void initState() {
    super.initState();
    // Refresh check when opening dialog manually
    context.read<UpdateCubit>().checkForUpdates();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<UpdateCubit, UpdateState>(
      listener: (context, state) {
        // Optional: result handling
      },
      builder: (context, state) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.system_update_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              const Text('Check for Updates'),
            ],
          ),
          content: _buildContent(context, state, theme),
          actions: _buildActions(context, state),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, UpdateState state, ThemeData theme) {
    return state.when(
      initial: () => const SizedBox(height: 50),
      checking: () =>
          const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
      available: (info) => Column(
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
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'v${info.latestVersion} is ready',
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
          if (info.changelog.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('What\'s New', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              child: SingleChildScrollView(
                child: Text(info.changelog, style: theme.textTheme.bodySmall),
              ),
            ),
          ],
        ],
      ),
      downloading: (progress) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 16),
          Text(
            'Downloading... ${(progress * 100).toStringAsFixed(0)}%',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
      installing: (message, progress) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 16),
          Text(message, style: theme.textTheme.bodyMedium),
        ],
      ),
      readyToInstall: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, size: 48, color: Colors.green),
          const SizedBox(height: 16),
          const Text('Update Downloaded!'),
          const SizedBox(height: 8),
          const Text('The app will restart to apply the update.'),
        ],
      ),
      error: (message) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text('Failed to update', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context, UpdateState state) {
    return state.maybeWhen(
      available: (info) => [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Later')),
        FilledButton.icon(
          onPressed: () => context.read<UpdateCubit>().downloadUpdate(info.downloadUrl),
          icon: const Icon(Icons.download_rounded),
          label: const Text('Download'),
        ),
      ],
      readyToInstall: (file) => [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton.icon(
          onPressed: () => context.read<UpdateCubit>().applyUpdate(file),
          icon: const Icon(Icons.restart_alt_rounded),
          label: const Text('Restart & Install'),
        ),
      ],
      downloading: (_) => [],
      checking: () => [],
      orElse: () => [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
      ],
    );
  }
}
