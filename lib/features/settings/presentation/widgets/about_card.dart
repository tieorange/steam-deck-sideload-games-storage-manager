import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/core/router/app_router.dart';
import 'package:game_size_manager/features/settings/presentation/widgets/send_logs_dialog.dart';
import 'package:game_size_manager/features/settings/presentation/widgets/update_widgets.dart';

/// About section card with app info and links
class AboutCard extends StatelessWidget {
  const AboutCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // App Header
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.3),
                    theme.colorScheme.secondary.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.games_rounded, color: theme.colorScheme.primary),
            ),
            title: Text(
              'Game Size Manager',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Version ${AppConstants.appVersion}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
          _buildDivider(theme),

          // Source Code
          _AboutListTile(
            icon: Icons.code_rounded,
            iconColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            iconBackgroundColor: theme.colorScheme.surfaceContainerHighest,
            title: 'Source Code',
            subtitle: 'View on GitHub',
            onTap: () async {
              final uri = Uri.parse(
                'https://github.com/${AppConstants.githubOwner}/${AppConstants.githubRepo}',
              );
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
          _buildDivider(theme),

          // Check for Updates
          _AboutListTile(
            icon: Icons.system_update_rounded,
            iconColor: theme.colorScheme.primary,
            iconBackgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
            title: 'Check for Updates',
            subtitle: 'Version ${AppConstants.appVersion}',
            onTap: () {
              showDialog(context: context, builder: (_) => const UpdateCheckDialog());
            },
          ),
          _buildDivider(theme),

          // View Logs
          _AboutListTile(
            icon: Icons.terminal_rounded,
            iconColor: theme.colorScheme.secondary,
            iconBackgroundColor: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
            title: 'View Logs',
            subtitle: 'Debug application issues',
            onTap: () => context.pushNamed(AppRoutes.logsName),
          ),
          _buildDivider(theme),

          // Send Logs
          _AboutListTile(
            icon: Icons.bug_report_rounded,
            iconColor: theme.colorScheme.tertiary,
            iconBackgroundColor: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
            title: 'Send Logs to Developer',
            subtitle: 'Help us fix bugs by sharing logs',
            onTap: () {
              showDialog(context: context, builder: (_) => const SendLogsDialog());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: theme.colorScheme.outline.withValues(alpha: 0.1),
    );
  }
}

class _AboutListTile extends StatelessWidget {
  const _AboutListTile({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconBackgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
      ),
      onTap: onTap,
    );
  }
}
