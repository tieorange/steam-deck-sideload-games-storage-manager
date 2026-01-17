import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:game_size_manager/core/constants.dart';

part 'game_entity.freezed.dart';
part 'game_entity.g.dart';

/// Game entity representing an installed game
@freezed
class Game with _$Game {
  const factory Game({
    /// Unique identifier (app name, slug, or appid)
    required String id,
    
    /// Display title
    required String title,
    
    /// Source launcher
    required GameSource source,
    
    /// Full path to installation directory
    required String installPath,
    
    /// Size in bytes (0 if not yet calculated)
    required int sizeBytes,
    
    /// Path to game icon (optional)
    String? iconPath,
    
    /// Whether this game is selected for batch operations
    @Default(false) bool isSelected,
  }) = _Game;
  
  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
}

/// Extension methods for Game
extension GameExtensions on Game {
  /// Copy with toggled selection
  Game toggleSelected() => copyWith(isSelected: !isSelected);
}

/// Extension for list of games
extension GameListExtensions on List<Game> {
  /// Get total size of all games
  int get totalSizeBytes => fold(0, (sum, game) => sum + game.sizeBytes);
  
  /// Get only selected games
  List<Game> get selectedGames => where((g) => g.isSelected).toList();
  
  /// Get total size of selected games
  int get selectedSizeBytes => selectedGames.totalSizeBytes;
  
  /// Sort by size descending
  List<Game> sortedBySize() {
    final sorted = List<Game>.from(this);
    sorted.sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
    return sorted;
  }
  
  /// Filter by source
  List<Game> filterBySource(GameSource? source) {
    if (source == null) return this;
    return where((g) => g.source == source).toList();
  }
}
