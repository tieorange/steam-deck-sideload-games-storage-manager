import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';

/// DTO for OGI games
class OgiGameDto {
  static const String keyName = 'name';
  static const String keyAppId = 'appID';
  static const String keyInstallLocation = 'installLocation';
  static const String keyTitleImage = 'titleImage';

  final String name;
  final String appId;
  final String? installLocation;
  final String? titleImage;

  const OgiGameDto({
    required this.name,
    required this.appId,
    this.installLocation,
    this.titleImage,
  });

  factory OgiGameDto.fromJson(Map<String, dynamic> json, String fallbackAppId) {
    return OgiGameDto(
      name: json[keyName] as String? ?? 'Unknown',
      appId: json[keyAppId] as String? ?? fallbackAppId,
      installLocation: json[keyInstallLocation] as String?,
      titleImage: json[keyTitleImage] as String?,
    );
  }

  Game toEntity() {
    return Game(
      id: 'ogi_$appId',
      title: name,
      source: GameSource.ogi,
      installPath: installLocation ?? '',
      sizeBytes: 0,
      iconPath: titleImage,
    );
  }
}
