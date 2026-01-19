import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/core/utils/game_utils.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';
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
    final sourceColor = _getSourceColor(game.source);

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
