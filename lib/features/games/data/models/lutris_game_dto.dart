import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';

/// DTO for Lutris games from SQLite pga.db
class LutrisGameDto {
  final String id;
  final String name;
  final String slug;
  final String? directory;

  const LutrisGameDto({required this.id, required this.name, required this.slug, this.directory});

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

  Game toEntity() {
    final safeSlug = slug.isNotEmpty ? slug : id;

    return Game(
      id: 'lutris_$safeSlug',
      title: name,
      source: GameSource.lutris,
      installPath: directory ?? '',
      sizeBytes: 0,
    );
  }
}
