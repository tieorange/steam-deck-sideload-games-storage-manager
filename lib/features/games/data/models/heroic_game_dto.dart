import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';

/// DTO for Epic games from Legendary's installed.json
class EpicGameDto {
  final String appName;
  final String? title;
  final String? installPath;
  final int? installSize;

  const EpicGameDto({required this.appName, this.title, this.installPath, this.installSize});

  factory EpicGameDto.fromJson(Map<String, dynamic> json, String key) {
    return EpicGameDto(
      appName: json['app_name'] as String? ?? key,
      title: json['title'] as String?,
      installPath: json['install_path'] as String?,
      installSize: json['install_size'] as int?,
    );
  }

  Game toEntity() {
    final safeTitle = title ?? appName;
    return Game(
      id: 'heroic_epic_$appName',
      title: safeTitle,
      source: GameSource.heroic,
      installPath: installPath ?? '',
      sizeBytes: installSize ?? 0,
    );
  }
}

/// DTO for GOG games from library cache
class GogGameDto {
  final String appName;
  final String? title;
  final String? installPath;
  final bool isInstalled;

  const GogGameDto({
    required this.appName,
    required this.isInstalled,
    this.title,
    this.installPath,
  });

  factory GogGameDto.fromJson(Map<String, dynamic> json) {
    return GogGameDto(
      appName: json['app_name'] as String? ?? '',
      isInstalled: json['is_installed'] as bool? ?? false,
      title: json['title'] as String?,
      installPath: json['install_path'] as String?,
    );
  }

  Game toEntity() {
    final safeTitle = title ?? appName;
    return Game(
      id: 'heroic_gog_$appName',
      title: safeTitle,
      source: GameSource.heroic,
      installPath: installPath ?? '',
      sizeBytes: 0, // GOG doesn't provide size in cache
    );
  }
}
