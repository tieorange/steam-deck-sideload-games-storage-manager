import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:game_size_manager/core/di/injection.dart';
import 'package:game_size_manager/core/extensions/size_formatter.dart';
import 'package:game_size_manager/core/services/game_export_service.dart';
import 'package:game_size_manager/core/services/orphaned_data_service.dart';
import 'package:game_size_manager/core/theme/steam_deck_constants.dart';
import 'package:game_size_manager/core/widgets/animated_card.dart';
import 'package:game_size_manager/features/games/presentation/cubit/games_cubit.dart';
import 'package:game_size_manager/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:game_size_manager/features/settings/presentation/cubit/settings_state.dart';
import 'package:game_size_manager/features/settings/presentation/widgets/about_card.dart';
import 'package:game_size_manager/features/settings/presentation/widgets/behavior_card.dart';
import 'package:game_size_manager/features/settings/presentation/widgets/section_header.dart';
import 'package:game_size_manager/features/settings/presentation/widgets/theme_card.dart';

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

  void _showExportDialog(BuildContext context) {
    final theme = Theme.of(context);
    final exportService = sl<GameExportService>();
    final games = context.read<GamesCubit>().state.displayedGames;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Export Game List'),
        content: const Text('Choose an export format:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final file = await exportService.exportToJson(games);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Exported to ${file.path}')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Export failed: $e')),
                  );
                }
              }
            },
            child: const Text('JSON'),
          ),
          FilledButton.tonal(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final file = await exportService.exportToCsv(games);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Exported to ${file.path}')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Export failed: $e')),
                  );
                }
              }
            },
            child: const Text('CSV'),
          ),
        ],
      ),
    );
  }

  void _showOrphanedDataDialog(BuildContext context) {
    final games = context.read<GamesCubit>().state.displayedGames;
    final orphanedDataService = sl<OrphanedDataService>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _OrphanedDataDialog(
        games: games,
        orphanedDataService: orphanedDataService,
      ),
    );
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
                  child: const SectionHeader(icon: Icons.palette_rounded, title: 'Appearance'),
                ),
                const SizedBox(height: 12),
                AnimatedCard(
                  controller: _controller,
                  delay: 0.1,
                  slideOffset: const Offset(0.05, 0),
                  child: ThemeCard(currentMode: settings.appThemeMode),
                ),

                const SizedBox(height: SteamDeckConstants.sectionGap),

                // Behavior Section
                AnimatedCard(
                  controller: _controller,
                  delay: 0.15,
                  slideOffset: const Offset(0.05, 0),
                  child: const SectionHeader(icon: Icons.tune_rounded, title: 'Behavior'),
                ),
                const SizedBox(height: 12),
                AnimatedCard(
                  controller: _controller,
                  delay: 0.2,
                  slideOffset: const Offset(0.05, 0),
                  child: BehaviorCard(
                    confirmBeforeUninstall: settings.confirmBeforeUninstall,
                    sortBySizeDescending: settings.sortBySizeDescending,
                  ),
                ),

                const SizedBox(height: SteamDeckConstants.sectionGap),

                // Export Section
                AnimatedCard(
                  controller: _controller,
                  delay: 0.25,
                  slideOffset: const Offset(0.05, 0),
                  child: const SectionHeader(icon: Icons.upload_file_rounded, title: 'Export'),
                ),
                const SizedBox(height: 12),
                AnimatedCard(
                  controller: _controller,
                  delay: 0.3,
                  slideOffset: const Offset(0.05, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.list_alt_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      title: const Text('Export Game List'),
                      subtitle: const Text('Save your game list as JSON or CSV'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onTap: () => _showExportDialog(context),
                    ),
                  ),
                ),

                const SizedBox(height: SteamDeckConstants.sectionGap),

                // Data Management Section
                AnimatedCard(
                  controller: _controller,
                  delay: 0.35,
                  slideOffset: const Offset(0.05, 0),
                  child: const SectionHeader(icon: Icons.cleaning_services_rounded, title: 'Data Management'),
                ),
                const SizedBox(height: 12),
                AnimatedCard(
                  controller: _controller,
                  delay: 0.4,
                  slideOffset: const Offset(0.05, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.delete_sweep_rounded,
                        color: const Color(0xFFF59E0B),
                      ),
                      title: const Text('Clean Orphaned Data'),
                      subtitle: const Text('Remove leftover data from uninstalled games'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onTap: () => _showOrphanedDataDialog(context),
                    ),
                  ),
                ),

                const SizedBox(height: SteamDeckConstants.sectionGap),

                // About Section
                AnimatedCard(
                  controller: _controller,
                  delay: 0.45,
                  slideOffset: const Offset(0.05, 0),
                  child: const SectionHeader(icon: Icons.info_rounded, title: 'About'),
                ),
                const SizedBox(height: 12),
                AnimatedCard(
                  controller: _controller,
                  delay: 0.5,
                  slideOffset: const Offset(0.05, 0),
                  child: const AboutCard(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Dialog that scans for and displays orphaned data with cleanup option
class _OrphanedDataDialog extends StatefulWidget {
  const _OrphanedDataDialog({
    required this.games,
    required this.orphanedDataService,
  });

  final List<dynamic> games;
  final OrphanedDataService orphanedDataService;

  @override
  State<_OrphanedDataDialog> createState() => _OrphanedDataDialogState();
}

class _OrphanedDataDialogState extends State<_OrphanedDataDialog> {
  bool _scanning = true;
  bool _cleaning = false;
  List<OrphanedData> _orphanedData = [];
  String? _error;
  int? _freedBytes;

  @override
  void initState() {
    super.initState();
    _scan();
  }

  Future<void> _scan() async {
    try {
      final results = await widget.orphanedDataService.scan(widget.games.cast());
      if (mounted) {
        setState(() {
          _orphanedData = results;
          _scanning = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _scanning = false;
        });
      }
    }
  }

  Future<void> _cleanup() async {
    setState(() => _cleaning = true);
    try {
      final freed = await widget.orphanedDataService.cleanup(_orphanedData);
      if (mounted) {
        setState(() {
          _freedBytes = freed;
          _cleaning = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _cleaning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_scanning) {
      return AlertDialog(
        title: const Text('Orphaned Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Scanning for orphaned data...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return AlertDialog(
        title: const Text('Orphaned Data'),
        content: Text('An error occurred: $_error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      );
    }

    if (_freedBytes != null) {
      return AlertDialog(
        title: const Text('Cleanup Complete'),
        content: Text('Freed ${_freedBytes!.toHumanReadableSize()} of disk space.'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      );
    }

    if (_orphanedData.isEmpty) {
      return AlertDialog(
        title: const Text('Orphaned Data'),
        content: const Text('No orphaned data found. Your system is clean!'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Great'),
          ),
        ],
      );
    }

    final totalSize = _orphanedData.fold<int>(0, (sum, item) => sum + item.sizeBytes);

    return AlertDialog(
      title: const Text('Orphaned Data'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Found ${_orphanedData.length} orphaned entries '
              'totaling ${totalSize.toHumanReadableSize()}.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _orphanedData.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = _orphanedData[index];
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      item.type == OrphanedDataType.compatData
                          ? Icons.folder_rounded
                          : Icons.gradient_rounded,
                      size: 20,
                      color: theme.colorScheme.secondary,
                    ),
                    title: Text(item.label),
                    subtitle: Text(item.type.label),
                    trailing: Text(
                      item.sizeBytes.toHumanReadableSize(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _cleaning ? null : _cleanup,
          child: _cleaning
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Clean Up (${totalSize.toHumanReadableSize()})'),
        ),
      ],
    );
  }
}
