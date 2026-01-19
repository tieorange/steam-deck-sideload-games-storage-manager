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

import 'package:game_size_manager/core/utils/game_utils.dart';

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

  @override
  Widget build(BuildContext context) {
    final game = widget.game; // Local convenience
    final theme = Theme.of(context);
    final sourceColor = _getSourceColor(game.source);

    // Calculate paths
    final compatDataPath = GameUtils.getCompatDataPath(game);
    final shaderCachePath = GameUtils.getShaderCachePath(game);
    final hasExtraData = compatDataPath != null || shaderCachePath != null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
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
                        const SizedBox(height: 16),

                        // Action Buttons Row
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (GameUtils.getProtonDbUrl(game) != null)
                                _ActionButton(
                                  icon: Icons.public,
                                  label: 'ProtonDB',
                                  onTap: () =>
                                      GameUtils.launchUrlString(GameUtils.getProtonDbUrl(game)!),
                                  color: theme.colorScheme.primary,
                                ),
                              const SizedBox(width: 8),
                              _ActionButton(
                                icon: Icons.folder_open,
                                label: 'Files',
                                onTap: () => GameUtils.openFileExplorer(game.installPath),
                                color: theme.colorScheme.secondary,
                              ),
                              const SizedBox(width: 8),
                              _ActionButton(
                                icon: Icons.info_outline,
                                label: 'Wiki',
                                onTap: () =>
                                    GameUtils.launchUrlString(GameUtils.getPcGamingWikiUrl(game)),
                                color: theme.colorScheme.tertiary,
                              ),
                              if (GameUtils.getSteamStoreUrl(game) != null) ...[
                                const SizedBox(width: 8),
                                _ActionButton(
                                  icon: Icons.shopping_bag_outlined,
                                  label: 'Store',
                                  onTap: () =>
                                      GameUtils.launchUrlString(GameUtils.getSteamStoreUrl(game)!),
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  useSurfaceColor: true,
                                ),
                              ],
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

                  // Data & Cache Section (New)
                  if (hasExtraData) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Data & Cache',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (compatDataPath != null)
                      _PathCard(
                        title: 'Compat Data (Prefix)',
                        path: compatDataPath,
                        icon: Icons.wine_bar,
                        color: theme.colorScheme.tertiary,
                        onOpen: () => GameUtils.openFileExplorer(compatDataPath),
                        sizeBytes: _compatDataSize,
                      ),
                    if (shaderCachePath != null) ...[
                      const SizedBox(height: 8),
                      _PathCard(
                        title: 'Shader Cache',
                        path: shaderCachePath,
                        icon: Icons.memory,
                        color: theme.colorScheme.secondary,
                        onOpen: () => GameUtils.openFileExplorer(shaderCachePath),
                        sizeBytes: _shaderCacheSize,
                      ),
                    ],
                  ],

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

                  // Metadata Section (AppID)
                  const SizedBox(height: 24),
                  // Metadata Section (AppID, Launch Options, Proton)
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // IDs Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ID: ${game.id}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontFamily: 'monospace',
                              ),
                            ),
                            if (GameUtils.getSteamAppId(game) != null)
                              Text(
                                'AppID: ${GameUtils.getSteamAppId(game)}',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),

                        // Proton Version
                        if (game.protonVersion != null && game.protonVersion!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Divider(height: 16, thickness: 0.5),
                          Row(
                            children: [
                              Icon(Icons.science, size: 16, color: theme.colorScheme.secondary),
                              const SizedBox(width: 8),
                              Text(
                                'Proton: ',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  game.protonVersion!,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],

                        // Launch Options
                        if (game.launchOptions != null && game.launchOptions!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Divider(height: 16, thickness: 0.5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.terminal, size: 16, color: theme.colorScheme.tertiary),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Launch Options:',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: SelectableText(
                                  game.launchOptions!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontFamily: 'monospace',
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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
      tag: 'game_icon_${widget.game.id}',
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
          child: widget.game.iconPath != null
              ? Image.file(
                  File(widget.game.iconPath!),
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
      builder: (context) => UninstallConfirmDialog(games: [widget.game]),
    );

    if (confirmed == true && context.mounted) {
      context.read<GamesCubit>().uninstallGame(widget.game);
      context.pop(); // Go back to list
    }
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    this.useSurfaceColor = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool useSurfaceColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: useSurfaceColor ? color : color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: useSurfaceColor
                  ? theme.colorScheme.outline.withValues(alpha: 0.1)
                  : color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: useSurfaceColor ? theme.colorScheme.onSurface : color),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: useSurfaceColor ? theme.colorScheme.onSurface : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PathCard extends StatelessWidget {
  const _PathCard({
    required this.title,
    required this.path,
    required this.icon,
    required this.color,
    required this.onOpen,
    this.sizeBytes,
  });

  final String title;
  final String path;
  final IconData icon;
  final Color color;
  final VoidCallback onOpen;
  final int? sizeBytes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (sizeBytes != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          sizeBytes!.toHumanReadableSize(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  path,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onOpen,
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            tooltip: 'Open Folder',
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
