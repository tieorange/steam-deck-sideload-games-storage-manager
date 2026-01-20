import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';

/// DTO for Lutris games from SQLite pga.db
class LutrisGameDto {
  final String id;
  final String name;
  final String slug;
  final String? directory;
  final String? gamePath;
  final String? iconPath;

  const LutrisGameDto({
    required this.id,
    required this.name,
    required this.slug,
    this.directory,
    this.gamePath,
    this.iconPath,
  });

  factory LutrisGameDto.fromMap(Map<String, Object?> map) {
    return LutrisGameDto(
      id: map['id']?.toString() ?? '',
      name: map['name'] as String? ?? 'Unknown',
      slug:
          map['slug'] as String? ??
          '', // default to empty if null, fallback logic in toEntity if needed
      directory: map['directory'] as String?,
    );
  }

  /// Create a copy with updated fields
  LutrisGameDto copyWith({String? gamePath, String? iconPath}) {
    return LutrisGameDto(
      id: id,
      name: name,
      slug: slug,
      directory: directory,
      gamePath: gamePath ?? this.gamePath,
      iconPath: iconPath ?? this.iconPath,
    );
  }

  Game toEntity() {
    final safeSlug = slug.isNotEmpty ? slug : id;

    // gamePath comes from YAML config, directory comes from pga.db (usually prefix)
    final installPath = gamePath ?? directory ?? '';

    return Game(
      id: 'lutris_$safeSlug',
      title: name,
      source: GameSource.lutris,
      installPath: installPath,
      sizeBytes: 0,
      iconPath: iconPath,
    );
  }
}
