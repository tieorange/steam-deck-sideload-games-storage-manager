import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/core/extensions/size_formatter.dart';

import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';
import 'package:game_size_manager/features/games/presentation/cubit/games_cubit.dart';
import 'package:game_size_manager/features/games/presentation/widgets/uninstall_confirm_dialog.dart';

/// Detailed view of a single game
class GameDetailsPage extends StatelessWidget {
  const GameDetailsPage({super.key, required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sourceColor = _getSourceColor(game.source);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Large App Bar with Hero Icon
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Blended background
                  if (game.iconPath != null)
                    Image.file(
                      File(game.iconPath!),
                      fit: BoxFit.cover,
                      color: theme.colorScheme.surface.withValues(alpha: 0.85),
                      colorBlendMode: BlendMode.srcOver,
                    )
                  else
                    Container(color: sourceColor.withValues(alpha: 0.1)),

                  // Gradient overlay
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, theme.colorScheme.surface],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),

                  // Center Content
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 48), // Padding for status bar
                        _buildGameIcon(sourceColor),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Source
                  Center(
                    child: Column(
                      children: [
                        Text(
                          game.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: sourceColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getSourceIcon(game.source), size: 16, color: sourceColor),
                              const SizedBox(width: 8),
                              Text(
                                game.source.displayName,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: sourceColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Install Path Card
                  Text(
                    'Installation',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.folder_open_rounded,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Path on Disk',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: game.installPath));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Path copied to clipboard'),
                                    behavior: SnackBarBehavior.floating,
                                    width: 280,
                                    backgroundColor: theme.colorScheme.inverseSurface,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.copy_rounded, size: 20),
                              tooltip: 'Copy path',
                              style: IconButton.styleFrom(
                                backgroundColor: theme.colorScheme.surface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            game.installPath,
                            style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Size Card
                  Text(
                    'Storage',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.sd_storage_rounded, color: theme.colorScheme.primary),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Size',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              game.sizeBytes.toHumanReadableSize(),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Actions
                  FilledButton.icon(
                    onPressed: () => _showUninstallConfirmation(context),
                    icon: const Icon(Icons.delete_forever_rounded),
                    label: const Text('Uninstall Game'),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                      minimumSize: const Size(double.infinity, 56),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameIcon(Color sourceColor) {
    return Hero(
      tag: 'game_icon_${game.id}',
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: game.iconPath != null
              ? Image.file(
                  File(game.iconPath!),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildFallbackIcon(sourceColor),
                )
              : _buildFallbackIcon(sourceColor),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon(Color color) {
    return Container(
      color: color.withValues(alpha: 0.1),
      child: Icon(Icons.videogame_asset, size: 48, color: color),
    );
  }

  IconData _getSourceIcon(GameSource source) {
    switch (source) {
      case GameSource.heroic:
        return Icons.storefront_rounded;
      case GameSource.ogi:
        return Icons.apps_rounded;
      case GameSource.lutris:
        return Icons.sports_esports_rounded;
      case GameSource.steam:
        return Icons.gamepad_rounded;
    }
  }

  Color _getSourceColor(GameSource source) {
    switch (source) {
      case GameSource.heroic:
        return const Color(0xFFE91E63);
      case GameSource.ogi:
        return const Color(0xFF9C27B0);
      case GameSource.lutris:
        return const Color(0xFFFF9800);
      case GameSource.steam:
        return const Color(0xFF2196F3);
    }
  }

  Future<void> _showUninstallConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => UninstallConfirmDialog(games: [game]),
    );

    if (confirmed == true && context.mounted) {
      context.read<GamesCubit>().uninstallGame(game);
      context.pop(); // Go back to list
    }
  }
}
