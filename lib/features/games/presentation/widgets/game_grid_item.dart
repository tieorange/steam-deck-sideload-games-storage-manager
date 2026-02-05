import 'dart:io';
import 'package:flutter/material.dart';

import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/core/extensions/size_formatter.dart';
import 'package:game_size_manager/core/theme/game_colors.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';

/// Grid item for game library grid view
class GameGridItem extends StatefulWidget {
  const GameGridItem({
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
  State<GameGridItem> createState() => _GameGridItemState();
}

class _GameGridItemState extends State<GameGridItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  bool _isPressed = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
    final sourceColor = GameColors.forSource(widget.game.source);

    return FocusableActionDetector(
      onShowFocusHighlight: (focused) => setState(() => _isFocused = focused),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _controller.forward();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            transform: Matrix4.diagonal3Values(
              _isPressed ? 0.98 : 1.0,
              _isPressed ? 0.98 : 1.0,
              1.0,
            ),
            decoration: BoxDecoration(
              color: widget.game.isSelected
                  ? colorScheme.primaryContainer.withValues(alpha: 0.4)
                  : (_isFocused
                        ? colorScheme.surfaceContainerHighest
                        : colorScheme.surfaceContainerLow),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.game.isSelected
                    ? colorScheme.primary
                    : (_isFocused
                          ? colorScheme.outline
                          : colorScheme.outline.withValues(alpha: 0.1)),
                width: widget.game.isSelected || _isFocused ? 2 : 1,
              ),
              boxShadow: [
                if (_isFocused)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                onLongPress: widget.onSelect,
                borderRadius: BorderRadius.circular(16),
                splashColor: sourceColor.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: Source badge and Size
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: sourceColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.game.isSelected) ...[
                                  Icon(Icons.check_circle_rounded, size: 12, color: sourceColor),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  widget.game.source.displayName,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: sourceColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (widget.game.storageLocation != StorageLocation.unknown) ...[
                            const SizedBox(width: 4),
                            Icon(
                              _getStorageIcon(widget.game.storageLocation),
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                          Text(
                            widget.game.sizeBytes.toHumanReadableSize(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _getSizeColor(widget.game.sizeBytes, colorScheme),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Bottom row: Icon and Title
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
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
                            ),
                            child: widget.game.iconPath != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(widget.game.iconPath!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Icon(
                                        GameColors.iconForSource(widget.game.source),
                                        size: 18,
                                        color: sourceColor,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    GameColors.iconForSource(widget.game.source),
                                    size: 18,
                                    color: sourceColor,
                                  ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.game.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                height: 1.1,
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
    );
  }

  Color _getSizeColor(int sizeBytes, ColorScheme colorScheme) {
    final gb = sizeBytes / (1024 * 1024 * 1024);
    if (gb > 80) return const Color(0xFFEF4444);
    if (gb > 50) return const Color(0xFFF59E0B);
    if (gb > 30) return const Color(0xFFEAB308);
    return colorScheme.primary;
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
