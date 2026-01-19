import 'dart:io';
import 'package:flutter/material.dart';

import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/core/extensions/size_formatter.dart';
import 'package:game_size_manager/core/theme/steam_deck_constants.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';

/// Single game item in the list with animations
/// Optimized for Steam Deck touch with 72px height
class GameListItem extends StatefulWidget {
  const GameListItem({
    super.key,
    required this.game,
    required this.onTap,
    required this.onSelect,
    this.index = 0,
  });

  final Game game;
  final VoidCallback onTap;
  final VoidCallback onSelect;
  final int index;

  @override
  State<GameListItem> createState() => _GameListItemState();
}

class _GameListItemState extends State<GameListItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool _isPressed = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);

    // Staggered animation based on index
    final delay = (widget.index * 0.05).clamp(0.0, 0.3);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(delay, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(delay, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(delay, 1.0, curve: Curves.easeOut),
      ),
    );

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
    final colorScheme = theme.colorScheme;
    final sourceColor = _getSourceColor(widget.game.source);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(scale: _scaleAnimation, child: child),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: FocusableActionDetector(
          onShowFocusHighlight: (focused) => setState(() => _isFocused = focused),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              transform: Matrix4.diagonal3Values(
                _isPressed ? 0.98 : (_isFocused ? 1.01 : 1.0),
                _isPressed ? 0.98 : (_isFocused ? 1.01 : 1.0),
                1.0,
              ),
              child: Material(
                color: widget.game.isSelected
                    ? colorScheme.primaryContainer.withValues(alpha: 0.4)
                    : (_isFocused ? colorScheme.surfaceContainerHighest : Colors.transparent),
                borderRadius: BorderRadius.circular(10),
                elevation: _isFocused ? 2 : 0,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(10),
                  splashColor: sourceColor.withValues(alpha: 0.1),
                  highlightColor: sourceColor.withValues(alpha: 0.05),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: SteamDeckConstants.compactListItemHeight,
                    padding: const EdgeInsets.symmetric(
                      horizontal: SteamDeckConstants.compactPadding,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: widget.game.isSelected
                          ? Border.all(color: colorScheme.primary.withValues(alpha: 0.5), width: 2)
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Compact checkbox
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: Checkbox(
                            value: widget.game.isSelected,
                            onChanged: (_) => widget.onSelect(),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                        ),

                        const SizedBox(width: 4),

                        // Compact game icon
                        Container(
                          width: SteamDeckConstants.compactGameIconSize,
                          height: SteamDeckConstants.compactGameIconSize,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                sourceColor.withValues(alpha: 0.3),
                                sourceColor.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: sourceColor.withValues(alpha: 0.3), width: 1),
                          ),
                          child: widget.game.iconPath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(7),
                                  child: Image.file(
                                    File(widget.game.iconPath!),
                                    width: SteamDeckConstants.compactGameIconSize,
                                    height: SteamDeckConstants.compactGameIconSize,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildFallbackIcon(sourceColor),
                                  ),
                                )
                              : _buildFallbackIcon(sourceColor),
                        ),

                        const SizedBox(width: 10),

                        // Source badge + Title (single row, compact)
                        Expanded(
                          child: Row(
                            children: [
                              // Source badge inline
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: sourceColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  widget.game.source.displayName,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: sourceColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Storage Icon
                              if (widget.game.storageLocation != StorageLocation.unknown) ...[
                                Icon(
                                  _getStorageIcon(widget.game.storageLocation),
                                  size: 14,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 8),
                              ],
                              Expanded(
                                child: Text(
                                  widget.game.title,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Size with visual indicator (compact)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.game.sizeBytes.toHumanReadableSize(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _getSizeColor(widget.game.sizeBytes, colorScheme),
                              ),
                            ),
                            const SizedBox(height: 2),
                            // Compact size bar
                            Container(
                              width: 48,
                              height: 3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: colorScheme.surfaceContainerHighest,
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: _getSizePercent(widget.game.sizeBytes),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    gradient: LinearGradient(
                                      colors: [
                                        _getSizeColor(widget.game.sizeBytes, colorScheme),
                                        _getSizeColor(
                                          widget.game.sizeBytes,
                                          colorScheme,
                                        ).withValues(alpha: 0.6),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon(Color color) {
    return Icon(_getSourceIcon(widget.game.source), color: color, size: 24);
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
        return const Color(0xFFE91E63); // Pink for Epic/GOG
      case GameSource.ogi:
        return const Color(0xFF9C27B0); // Purple
      case GameSource.lutris:
        return const Color(0xFFFF9800); // Orange
      case GameSource.steam:
        return const Color(0xFF2196F3); // Blue
    }
  }

  Color _getSizeColor(int sizeBytes, ColorScheme colorScheme) {
    final gb = sizeBytes / (1024 * 1024 * 1024);
    if (gb > 80) return const Color(0xFFEF4444); // Red for huge games
    if (gb > 50) return const Color(0xFFF59E0B); // Orange for large games
    if (gb > 30) return const Color(0xFFEAB308); // Yellow for medium
    return colorScheme.primary; // Default for small
  }

  double _getSizePercent(int sizeBytes) {
    // Normalize to 150GB max for visual representation
    final gb = sizeBytes / (1024 * 1024 * 1024);
    return (gb / 150).clamp(0.1, 1.0);
  }

  IconData _getStorageIcon(StorageLocation location) {
    switch (location) {
      case StorageLocation.internal:
        return Icons.storage_rounded;
      case StorageLocation.sdCard:
        return Icons.sd_card_rounded;
      case StorageLocation.external:
        return Icons.usb_rounded;
      case StorageLocation.unknown:
        return Icons.help_outline_rounded;
    }
  }
}
