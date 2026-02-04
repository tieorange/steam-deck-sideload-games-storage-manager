import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:steam_deck_games_detector/steam_deck_games_detector.dart' as pkg;
import 'package:steam_deck_games_detector/steam_deck_games_detector.dart'
    show GameSource, StorageLocation;

import 'package:game_size_manager/features/games/domain/entities/game_tag.dart';
import 'package:game_size_manager/features/games/domain/entities/sort_option.dart';

part 'game_entity.freezed.dart';
part 'game_entity.g.dart';

/// Game entity representing an installed game
/// (App-specific wrapper extending UI state)
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

    /// Custom launch options (optional)
    String? launchOptions,

    /// Proton version for compatibility (optional)
    String? protonVersion,

    /// Storage location (internal or SD card)
    @Default(StorageLocation.internal) StorageLocation storageLocation,

    /// Whether this game is selected for batch operations
    @Default(false) bool isSelected,

    /// User-assigned tag for categorization
    @JsonKey(includeFromJson: false, includeToJson: false) GameTag? tag,
  }) = _Game;

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);

  /// Create from Package Entity
  factory Game.fromPackage(pkg.Game pkgGame) {
    return Game(
      id: pkgGame.id,
      title: pkgGame.title,
      source: pkgGame.source,
      installPath: pkgGame.installPath,
      sizeBytes: pkgGame.sizeBytes,
      iconPath: pkgGame.iconPath,
      launchOptions: pkgGame.launchOptions,
      protonVersion: pkgGame.protonVersion,
      storageLocation: pkgGame.storageLocation,
      isSelected: false,
    );
  }
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

  /// Sort by the given option
  List<Game> sortedBy(SortOption option) {
    final sorted = List<Game>.from(this);
    switch (option) {
      case SortOption.size:
        sorted.sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
      case SortOption.name:
        sorted.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      case SortOption.source:
        sorted.sort((a, b) => a.source.name.compareTo(b.source.name));
    }
    return sorted;
  }

  /// Filter by source
  List<Game> filterBySource(GameSource? source) {
    if (source == null) return this;
    return where((g) => g.source == source).toList();
  }

  /// Filter by tag
  List<Game> filterByTag(GameTag? tag) {
    if (tag == null) return this;
    return where((g) => g.tag == tag).toList();
  }
}
