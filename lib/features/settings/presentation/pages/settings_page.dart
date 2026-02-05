import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:game_size_manager/core/di/injection.dart';
import 'package:game_size_manager/core/extensions/size_formatter.dart';
import 'package:game_size_manager/core/services/game_export_service.dart';
import 'package:game_size_manager/core/services/orphaned_data_service.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';
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
    // Use allGames (unfiltered) so we don't false-flag filtered-out games as orphaned
    final games = context.read<GamesCubit>().state.allGames;
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
                      subtitle: const Text('Scan compatdata & shader caches across all drives'),
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

/// Dialog that scans for and displays orphaned data with selective cleanup
class _OrphanedDataDialog extends StatefulWidget {
  const _OrphanedDataDialog({
    required this.games,
    required this.orphanedDataService,
  });

  final List<Game> games;
  final OrphanedDataService orphanedDataService;

  @override
  State<_OrphanedDataDialog> createState() => _OrphanedDataDialogState();
}

enum _DialogPhase { scanning, results, confirming, cleaning, done, error }

class _OrphanedDataDialogState extends State<_OrphanedDataDialog> {
  _DialogPhase _phase = _DialogPhase.scanning;
  List<OrphanedData> _orphanedData = [];
  final Set<int> _selectedIndices = {};
  String? _error;
  CleanupResult? _cleanupResult;

  @override
  void initState() {
    super.initState();
    _scan();
  }

  Future<void> _scan() async {
    try {
      final results = await widget.orphanedDataService.scan(widget.games);
      if (mounted) {
        setState(() {
          _orphanedData = results;
          // Select all non-symlink entries by default
          _selectedIndices.clear();
          for (var i = 0; i < results.length; i++) {
            if (!results[i].isSymlink) _selectedIndices.add(i);
          }
          _phase = _DialogPhase.results;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _phase = _DialogPhase.error;
        });
      }
    }
  }

  List<OrphanedData> get _selectedItems =>
      _selectedIndices.map((i) => _orphanedData[i]).toList();

  int get _selectedSize =>
      _selectedItems.fold<int>(0, (sum, item) => sum + item.sizeBytes);

  bool get _hasCompatDataSelected =>
      _selectedItems.any((item) => item.hasSaveDataRisk);

  Future<void> _cleanup() async {
    setState(() => _phase = _DialogPhase.cleaning);
    try {
      final result = await widget.orphanedDataService.cleanup(_selectedItems);
      if (mounted) {
        setState(() {
          _cleanupResult = result;
          _phase = _DialogPhase.done;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _phase = _DialogPhase.error;
        });
      }
    }
  }

  void _showConfirmation() {
    setState(() => _phase = _DialogPhase.confirming);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return switch (_phase) {
      _DialogPhase.scanning => _buildScanningDialog(theme),
      _DialogPhase.results => _buildResultsDialog(theme),
      _DialogPhase.confirming => _buildConfirmationDialog(theme),
      _DialogPhase.cleaning => _buildCleaningDialog(theme),
      _DialogPhase.done => _buildDoneDialog(theme),
      _DialogPhase.error => _buildErrorDialog(theme),
    };
  }

  Widget _buildScanningDialog(ThemeData theme) {
    return AlertDialog(
      title: const Text('Scanning for Orphaned Data'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Checking all Steam library folders for\n'
            'leftover compatdata and shader caches...',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsDialog(ThemeData theme) {
    if (_orphanedData.isEmpty) {
      return AlertDialog(
        icon: Icon(Icons.check_circle_outline, color: Colors.green[400], size: 48),
        title: const Text('All Clean'),
        content: const Text(
          'No orphaned data found. All compatdata and shader '
          'cache directories belong to installed games.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      );
    }

    final totalSize = _orphanedData.fold<int>(0, (sum, e) => sum + e.sizeBytes);
    final compatCount = _orphanedData.where((e) => e.type == OrphanedDataType.compatData).length;
    final shaderCount = _orphanedData.where((e) => e.type == OrphanedDataType.shaderCache).length;
    final symlinkCount = _orphanedData.where((e) => e.isSymlink).length;

    return AlertDialog(
      title: const Text('Orphaned Data Found'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary chips
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _SummaryChip(
                  icon: Icons.folder_rounded,
                  label: '$compatCount prefix${compatCount != 1 ? 'es' : ''}',
                  color: theme.colorScheme.tertiary,
                ),
                _SummaryChip(
                  icon: Icons.gradient_rounded,
                  label: '$shaderCount cache${shaderCount != 1 ? 's' : ''}',
                  color: theme.colorScheme.secondary,
                ),
                _SummaryChip(
                  icon: Icons.data_usage_rounded,
                  label: totalSize.toHumanReadableSize(),
                  color: theme.colorScheme.error,
                ),
                if (symlinkCount > 0)
                  _SummaryChip(
                    icon: Icons.link_rounded,
                    label: '$symlinkCount symlink${symlinkCount != 1 ? 's' : ''} (skipped)',
                    color: theme.colorScheme.outline,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Select all / none
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => setState(() {
                    _selectedIndices.clear();
                    for (var i = 0; i < _orphanedData.length; i++) {
                      if (!_orphanedData[i].isSymlink) _selectedIndices.add(i);
                    }
                  }),
                  icon: const Icon(Icons.select_all, size: 18),
                  label: const Text('All'),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _selectedIndices.clear()),
                  icon: const Icon(Icons.deselect, size: 18),
                  label: const Text('None'),
                ),
                const Spacer(),
                Text(
                  '${_selectedIndices.length} selected',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const Divider(height: 1),
            // Items list
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _orphanedData.length,
                itemBuilder: (context, index) {
                  final item = _orphanedData[index];
                  final isSelected = _selectedIndices.contains(index);
                  final isCompat = item.type == OrphanedDataType.compatData;

                  return CheckboxListTile(
                    dense: true,
                    value: isSelected,
                    enabled: !item.isSymlink,
                    onChanged: item.isSymlink ? null : (val) {
                      setState(() {
                        if (val == true) {
                          _selectedIndices.add(index);
                        } else {
                          _selectedIndices.remove(index);
                        }
                      });
                    },
                    secondary: Icon(
                      item.isSymlink
                          ? Icons.link_rounded
                          : isCompat
                              ? Icons.folder_rounded
                              : Icons.gradient_rounded,
                      size: 20,
                      color: item.isSymlink
                          ? theme.colorScheme.outline
                          : isCompat
                              ? theme.colorScheme.tertiary
                              : theme.colorScheme.secondary,
                    ),
                    title: Text(
                      item.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: item.isSymlink
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                            : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      item.isSymlink
                          ? 'Symlink (managed externally)'
                          : '${item.type.label} - ${item.sizeBytes.toHumanReadableSize()}'
                              '${item.isNonSteamShortcut ? ' - Non-Steam' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
          onPressed: _selectedIndices.isEmpty ? null : _showConfirmation,
          child: Text(
            _selectedIndices.isEmpty
                ? 'Select items'
                : 'Clean Up (${_selectedSize.toHumanReadableSize()})',
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationDialog(ThemeData theme) {
    return AlertDialog(
      icon: Icon(Icons.warning_amber_rounded, color: Colors.orange[400], size: 48),
      title: const Text('Confirm Cleanup'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You are about to permanently delete '
            '${_selectedIndices.length} item${_selectedIndices.length != 1 ? 's' : ''} '
            '(${_selectedSize.toHumanReadableSize()}).',
            style: theme.textTheme.bodyMedium,
          ),
          if (_hasCompatDataSelected) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_rounded, size: 20, color: theme.colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Some selected items are Proton prefixes (compatdata). '
                      'These may contain save files that are not backed up to '
                      'Steam Cloud. Deleting them will permanently remove '
                      'those saves.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Shader caches will regenerate automatically. '
            'This action cannot be undone.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() => _phase = _DialogPhase.results),
          child: const Text('Go Back'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          onPressed: _cleanup,
          child: const Text('Delete Permanently'),
        ),
      ],
    );
  }

  Widget _buildCleaningDialog(ThemeData theme) {
    return AlertDialog(
      title: const Text('Cleaning Up'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Deleting ${_selectedIndices.length} orphaned '
            'item${_selectedIndices.length != 1 ? 's' : ''}...',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoneDialog(ThemeData theme) {
    final result = _cleanupResult!;
    return AlertDialog(
      icon: Icon(
        result.failureCount == 0
            ? Icons.check_circle_outline
            : Icons.info_outline,
        color: result.failureCount == 0 ? Colors.green[400] : Colors.orange[400],
        size: 48,
      ),
      title: const Text('Cleanup Complete'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Freed ${result.freedBytes.toHumanReadableSize()} of disk space.',
            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (result.failureCount > 0) ...[
            const SizedBox(height: 8),
            Text(
              '${result.successCount} deleted, '
              '${result.failureCount} failed.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            ...result.errors.take(3).map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    e,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
          ],
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }

  Widget _buildErrorDialog(ThemeData theme) {
    return AlertDialog(
      icon: Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
      title: const Text('Error'),
      content: Text('An error occurred:\n$_error'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

/// Small summary chip for the orphaned data dialog
class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      labelStyle: Theme.of(context).textTheme.labelSmall,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.zero,
    );
  }
}
