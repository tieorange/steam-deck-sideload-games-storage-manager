import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';

/// DTO for Steam games from appmanifest
class SteamGameDto {
  // VDF Keys
  static const String keyAppId = 'appid';
  static const String keyName = 'name';
  static const String keyInstallDir = 'installdir';
  static const String keySizeOnDisk = 'SizeOnDisk';

  final String appId;
  final String name;
  final String installDir;
  final int sizeOnDisk;

  const SteamGameDto({
    required this.appId,
    required this.name,
    required this.installDir,
    required this.sizeOnDisk,
  });

  factory SteamGameDto.fromVdfValues(
    String appId,
    String name,
    String installDir,
    String? sizeString,
  ) {
    return SteamGameDto(
      appId: appId,
      name: name,
      installDir: installDir,
      sizeOnDisk: int.tryParse(sizeString ?? '0') ?? 0,
    );
  }

  Game toEntity({required String steamAppsPath, String? launchOptions, String? protonVersion}) {
    final commonDir = '$steamAppsPath/common/$installDir';

    return Game(
      id: 'steam_$appId',
      title: name,
      source: GameSource.steam,
      installPath: commonDir,
      sizeBytes: sizeOnDisk,
      launchOptions: launchOptions,
      protonVersion: protonVersion,
    );
  }
}
