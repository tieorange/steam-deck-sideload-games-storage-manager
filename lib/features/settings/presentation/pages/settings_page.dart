import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/core/logging/logger_service.dart';
import 'package:game_size_manager/core/theme/steam_deck_constants.dart';
import 'package:game_size_manager/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:game_size_manager/features/settings/presentation/cubit/settings_state.dart';
import 'package:game_size_manager/features/settings/presentation/widgets/update_widgets.dart';

import 'package:game_size_manager/core/widgets/animated_card.dart';

/// Settings page for app configuration with animations
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (message) => Center(child: Text('Error: $message')),
            loaded: (settings) => ListView(
              padding: const EdgeInsets.all(SteamDeckConstants.pagePadding),
              children: [
                // Theme Section
                AnimatedCard(
                  controller: _controller,
                  delay: 0.0,
                  slideOffset: const Offset(0.05, 0),
                  child: _buildSectionHeader(theme, Icons.palette_rounded, 'Appearance'),
                ),
                const SizedBox(height: 12),
                AnimatedCard(
                  controller: _controller,
                  delay: 0.1,
                  slideOffset: const Offset(0.05, 0),
                  child: _buildThemeCard(context, settings, theme),
                ),

                const SizedBox(height: SteamDeckConstants.sectionGap),

                // Behavior Section
                AnimatedCard(
                  controller: _controller,
                  delay: 0.15,
                  slideOffset: const Offset(0.05, 0),
                  child: _buildSectionHeader(theme, Icons.tune_rounded, 'Behavior'),
                ),
                const SizedBox(height: 12),
                AnimatedCard(
                  controller: _controller,
                  delay: 0.2,
                  slideOffset: const Offset(0.05, 0),
                  child: _buildBehaviorCard(context, settings, theme),
                ),

                const SizedBox(height: SteamDeckConstants.sectionGap),

                // About Section
                AnimatedCard(
                  controller: _controller,
                  delay: 0.25,
                  slideOffset: const Offset(0.05, 0),
                  child: _buildSectionHeader(theme, Icons.info_rounded, 'About'),
                ),
                const SizedBox(height: 12),
                AnimatedCard(
                  controller: _controller,
                  delay: 0.3,
                  slideOffset: const Offset(0.05, 0),
                  child: _buildAboutCard(context, theme),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 22),
        const SizedBox(width: 8),
        Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildThemeCard(BuildContext context, settings, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.brightness_6_rounded, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Theme', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        _getThemeModeName(settings.themeMode),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                _buildThemeButton(
                  context,
                  Icons.settings_suggest_rounded,
                  'System',
                  ThemeMode.system,
                  settings.themeMode,
                  theme,
                ),
                const SizedBox(width: 12),
                _buildThemeButton(
                  context,
                  Icons.light_mode_rounded,
                  'Light',
                  ThemeMode.light,
                  settings.themeMode,
                  theme,
                ),
                const SizedBox(width: 12),
                _buildThemeButton(
                  context,
                  Icons.dark_mode_rounded,
                  'Dark',
                  ThemeMode.dark,
                  settings.themeMode,
                  theme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeButton(
    BuildContext context,
    IconData icon,
    String label,
    ThemeMode mode,
    ThemeMode currentMode,
    ThemeData theme,
  ) {
    final isSelected = mode == currentMode;

    return Expanded(
      child: Material(
        color: isSelected
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => context.read<SettingsCubit>().setThemeMode(mode),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: isSelected ? Border.all(color: theme.colorScheme.primary, width: 2) : null,
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBehaviorCard(BuildContext context, settings, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            context,
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFF59E0B),
            title: 'Confirm before uninstall',
            subtitle: 'Show confirmation dialog before deleting games',
            value: settings.confirmBeforeUninstall,
            onChanged: (_) => context.read<SettingsCubit>().toggleConfirmBeforeUninstall(),
            theme: theme,
          ),
          Divider(height: 1, indent: 72, color: theme.colorScheme.outline.withValues(alpha: 0.1)),
          _buildSwitchTile(
            context,
            icon: Icons.sort_rounded,
            iconColor: theme.colorScheme.secondary,
            title: 'Sort largest first',
            subtitle: 'Show biggest games at the top of the list',
            value: settings.sortBySizeDescending,
            onChanged: (_) => context.read<SettingsCubit>().toggleSortBySizeDescending(),
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
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
                'Version 1.0.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.code_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            title: const Text('Source Code'),
            subtitle: const Text('View on GitHub'),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            onTap: () async {
              final uri = Uri.parse(
                'https://github.com/${AppConstants.githubOwner}/${AppConstants.githubRepo}',
              );
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.system_update_rounded, color: theme.colorScheme.primary),
            ),
            title: const Text('Check for Updates'),
            subtitle: const Text('Version 1.0.0'),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            onTap: () {
              showDialog(context: context, builder: (_) => const UpdateCheckDialog());
            },
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.bug_report_rounded, color: theme.colorScheme.tertiary),
            ),
            title: const Text('Export Logs'),
            subtitle: const Text('View logs for debugging'),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            onTap: () async {
              final logPath = await LoggerService.instance.getLogFilePath();
              if (context.mounted) {
                if (logPath != null) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Application Logs'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Logs are stored at:'),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              logPath,
                              style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                        FilledButton.icon(
                          onPressed: () async {
                            // Open parent folder
                            final dir = Directory(
                              logPath,
                            ).parent; // Actually just get directory of file, assuming imports
                            // Since we didn't import path package here yet, let's fix imports first or use simple string manipulation or io
                            // Let's rely on imports added in Instruction
                            // Wait, I can't assume imports are added unless I add them.
                            // I will use String manipulation if p.dirname is not available easily without import,
                            // BUT I WILL ADD IMPORTS in the tool.

                            // Using launchUrl for directory
                            // Uri.directory is available in dart:core/io
                            await launchUrl(Uri.directory(dir.path));
                          },
                          icon: const Icon(Icons.folder_open),
                          label: const Text('Open Folder'),
                        ),
                      ],
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('No log file found')));
                }
              }
            },
          ),
        ],
      ),
    );
  }

  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Following system preference';
      case ThemeMode.light:
        return 'Always light';
      case ThemeMode.dark:
        return 'Always dark';
    }
  }
}
