import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/core/extensions/size_formatter.dart';
import 'package:game_size_manager/core/utils/game_utils.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';
import 'package:game_size_manager/features/games/presentation/widgets/action_button.dart';
import 'package:game_size_manager/features/games/presentation/widgets/path_card.dart';

/// Header section for game details page containing the app bar, icon, title, and actions
class GameDetailsHeader extends StatelessWidget {
  const GameDetailsHeader({super.key, required this.game, required this.sourceColor});

  final Game game;
  final Color sourceColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
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
                  const SizedBox(height: 48),
                  _GameIcon(game: game, sourceColor: sourceColor),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Game icon with Hero animation
class _GameIcon extends StatelessWidget {
  const _GameIcon({required this.game, required this.sourceColor});

  final Game game;
  final Color sourceColor;

  @override
  Widget build(BuildContext context) {
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
                  errorBuilder: (_, __, ___) => _FallbackIcon(color: sourceColor),
                )
              : _FallbackIcon(color: sourceColor),
        ),
      ),
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  const _FallbackIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withValues(alpha: 0.1),
      child: Icon(Icons.videogame_asset, size: 48, color: color),
    );
  }
}

/// Title section with source badge and action buttons
class GameTitleSection extends StatelessWidget {
  const GameTitleSection({super.key, required this.game, required this.sourceColor});

  final Game game;
  final Color sourceColor;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        children: [
          Text(
            game.title,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Source badge
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
          _ActionButtonsRow(game: game),
        ],
      ),
    );
  }
}

class _ActionButtonsRow extends StatelessWidget {
  const _ActionButtonsRow({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (GameUtils.getProtonDbUrl(game) != null)
            ActionButton(
              icon: Icons.public,
              label: 'ProtonDB',
              onTap: () => GameUtils.launchUrlString(GameUtils.getProtonDbUrl(game)!),
              color: theme.colorScheme.primary,
            ),
          const SizedBox(width: 8),
          ActionButton(
            icon: Icons.folder_open,
            label: 'Files',
            onTap: () => GameUtils.openFileExplorer(game.installPath),
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(width: 8),
          ActionButton(
            icon: Icons.info_outline,
            label: 'Wiki',
            onTap: () => GameUtils.launchUrlString(GameUtils.getPcGamingWikiUrl(game)),
            color: theme.colorScheme.tertiary,
          ),
          if (GameUtils.getSteamStoreUrl(game) != null) ...[
            const SizedBox(width: 8),
            ActionButton(
              icon: Icons.shopping_bag_outlined,
              label: 'Store',
              onTap: () => GameUtils.launchUrlString(GameUtils.getSteamStoreUrl(game)!),
              color: theme.colorScheme.surfaceContainerHighest,
              useSurfaceColor: true,
            ),
          ],
        ],
      ),
    );
  }
}

/// Installation path section with copy functionality
class InstallationSection extends StatelessWidget {
  const InstallationSection({super.key, required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  Icon(Icons.folder_open_rounded, size: 20, color: theme.colorScheme.primary),
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
                    style: IconButton.styleFrom(backgroundColor: theme.colorScheme.surface),
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
      ],
    );
  }
}

/// Data & Cache section showing compat data and shader cache paths
class DataCacheSection extends StatelessWidget {
  const DataCacheSection({
    super.key,
    required this.game,
    this.compatDataSize,
    this.shaderCacheSize,
  });

  final Game game;
  final int? compatDataSize;
  final int? shaderCacheSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compatDataPath = GameUtils.getCompatDataPath(game);
    final shaderCachePath = GameUtils.getShaderCachePath(game);

    if (compatDataPath == null && shaderCachePath == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Data & Cache',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (compatDataPath != null)
          PathCard(
            title: 'Compat Data (Prefix)',
            path: compatDataPath,
            icon: Icons.wine_bar,
            color: theme.colorScheme.tertiary,
            onOpen: () => GameUtils.openFileExplorer(compatDataPath),
            sizeBytes: compatDataSize,
          ),
        if (shaderCachePath != null) ...[
          const SizedBox(height: 8),
          PathCard(
            title: 'Shader Cache',
            path: shaderCachePath,
            icon: Icons.memory,
            color: theme.colorScheme.secondary,
            onOpen: () => GameUtils.openFileExplorer(shaderCachePath),
            sizeBytes: shaderCacheSize,
          ),
        ],
      ],
    );
  }
}

/// Storage section showing total game size
class StorageSection extends StatelessWidget {
  const StorageSection({super.key, required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text('Storage', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
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
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Metadata section showing ID, AppID, Proton version, and launch options
class MetadataSection extends StatelessWidget {
  const MetadataSection({super.key, required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
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
                    style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
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
    );
  }
}
