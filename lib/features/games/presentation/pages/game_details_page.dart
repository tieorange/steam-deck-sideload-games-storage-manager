import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/core/di/injection.dart';
import 'package:game_size_manager/core/services/game_launch_service.dart';
import 'package:game_size_manager/core/theme/game_colors.dart';
import 'package:game_size_manager/core/theme/app_opacity.dart';
import 'package:game_size_manager/core/utils/game_utils.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';
import 'package:game_size_manager/features/games/domain/entities/game_tag.dart';
import 'package:game_size_manager/features/games/presentation/cubit/games_cubit.dart';
import 'package:game_size_manager/features/games/presentation/widgets/game_details_widgets.dart';
import 'package:game_size_manager/features/games/presentation/widgets/uninstall_confirm_dialog.dart';

/// Game details page showing comprehensive information about a single game
class GameDetailsPage extends StatefulWidget {
  const GameDetailsPage({super.key, required this.game});

  final Game game;

  @override
  State<GameDetailsPage> createState() => _GameDetailsPageState();
}

class _GameDetailsPageState extends State<GameDetailsPage> {
  int? _compatDataSize;
  int? _shaderCacheSize;

  @override
  void initState() {
    super.initState();
    _loadSizes();
  }

  Future<void> _loadSizes() async {
    final compatPath = GameUtils.getCompatDataPath(widget.game);
    final shaderPath = GameUtils.getShaderCachePath(widget.game);

    if (compatPath != null) {
      GameUtils.getDirectorySize(compatPath).then((size) {
        if (mounted) setState(() => _compatDataSize = size);
      });
    }

    if (shaderPath != null) {
      GameUtils.getDirectorySize(shaderPath).then((size) {
        if (mounted) setState(() => _shaderCacheSize = size);
      });
    }
  }

  Future<void> _showUninstallConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => UninstallConfirmDialog(games: [widget.game]),
    );

    if (confirmed == true && context.mounted) {
      context.read<GamesCubit>().uninstallGame(widget.game);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final theme = Theme.of(context);
    final sourceColor = GameColors.forSource(game.source);
    final launchService = sl<GameLaunchService>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          GameDetailsHeader(game: game, sourceColor: sourceColor),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Actions
                  GameTitleSection(game: game, sourceColor: sourceColor),

                  // Play Button
                  if (launchService.canLaunch(game)) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () async {
                          final success = await launchService.launch(game);
                          if (!success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to launch game')),
                            );
                          }
                        },
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Play'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 52),
                          backgroundColor: sourceColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],

                  // Tag Section
                  const SizedBox(height: 24),
                  _TagSection(game: game),

                  const SizedBox(height: 32),

                  // Installation Path
                  InstallationSection(game: game),

                  // Data & Cache (if applicable)
                  DataCacheSection(
                    game: game,
                    compatDataSize: _compatDataSize,
                    shaderCacheSize: _shaderCacheSize,
                  ),

                  // Storage Info
                  StorageSection(game: game),

                  // Metadata
                  const SizedBox(height: 24),
                  const SizedBox(height: 24),
                  MetadataSection(game: game),

                  const SizedBox(height: 48),

                  // Uninstall Button
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
}

/// Tag selector section for categorizing games
class _TagSection extends StatelessWidget {
  const _TagSection({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tag',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.muted),
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: 'Game tag selector',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: GameTag.values.map((tag) {
              final isSelected = game.tag == tag;
              return FilterChip(
                selected: isSelected,
                label: Text(tag.label),
                avatar: Icon(tag.icon, size: 18, color: isSelected ? Colors.white : tag.color),
                selectedColor: tag.color,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
                onSelected: (_) {
                  context.read<GamesCubit>().setGameTag(
                    game.id,
                    isSelected ? null : tag,
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
