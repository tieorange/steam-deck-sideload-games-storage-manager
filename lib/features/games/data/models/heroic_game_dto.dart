import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';

/// DTO for Epic games from Legendary's installed.json
class EpicGameDto {
  final String appName;
  final String? title;
  final String? installPath;
  final int? installSize;
  final String? iconPath;

  const EpicGameDto({
    required this.appName,
    this.title,
    this.installPath,
    this.installSize,
    this.iconPath,
  });

  factory EpicGameDto.fromJson(Map<String, dynamic> json, String key) {
    return EpicGameDto(
      appName: json['app_name'] as String? ?? key,
      title: json['title'] as String?,
      installPath: json['install_path'] as String?,
      installSize: json['install_size'] as int?,
    );
  }

  /// Create copy with icon path
  EpicGameDto copyWith({String? iconPath}) {
    return EpicGameDto(
      appName: appName,
      title: title,
      installPath: installPath,
      installSize: installSize,
      iconPath: iconPath ?? this.iconPath,
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
      iconPath: iconPath,
    );
  }
}

/// DTO for GOG games from library cache
class GogGameDto {
  final String appName;
  final String? title;
  final String? installPath;
  final bool isInstalled;
  final String? iconPath;

  const GogGameDto({
    required this.appName,
    required this.isInstalled,
    this.title,
    this.installPath,
    this.iconPath,
  });

  factory GogGameDto.fromJson(Map<String, dynamic> json) {
    return GogGameDto(
      appName: json['app_name'] as String? ?? '',
      isInstalled: json['is_installed'] as bool? ?? false,
      title: json['title'] as String?,
      installPath: json['install_path'] as String?,
    );
  }

  /// Create copy with icon path
  GogGameDto copyWith({String? iconPath}) {
    return GogGameDto(
      appName: appName,
      isInstalled: isInstalled,
      title: title,
      installPath: installPath,
      iconPath: iconPath ?? this.iconPath,
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
      iconPath: iconPath,
    );
  }
}
