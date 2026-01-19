// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameImpl _$$GameImplFromJson(Map<String, dynamic> json) => _$GameImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  source: $enumDecode(_$GameSourceEnumMap, json['source']),
  installPath: json['installPath'] as String,
  sizeBytes: (json['sizeBytes'] as num).toInt(),
  iconPath: json['iconPath'] as String?,
  launchOptions: json['launchOptions'] as String?,
  protonVersion: json['protonVersion'] as String?,
  storageLocation:
      $enumDecodeNullable(_$StorageLocationEnumMap, json['storageLocation']) ??
      StorageLocation.internal,
  isSelected: json['isSelected'] as bool? ?? false,
);

Map<String, dynamic> _$$GameImplToJson(_$GameImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'source': _$GameSourceEnumMap[instance.source]!,
      'installPath': instance.installPath,
      'sizeBytes': instance.sizeBytes,
      'iconPath': instance.iconPath,
      'launchOptions': instance.launchOptions,
      'protonVersion': instance.protonVersion,
      'storageLocation': _$StorageLocationEnumMap[instance.storageLocation]!,
      'isSelected': instance.isSelected,
    };

const _$GameSourceEnumMap = {
  GameSource.heroic: 'heroic',
  GameSource.ogi: 'ogi',
  GameSource.lutris: 'lutris',
  GameSource.steam: 'steam',
};

const _$StorageLocationEnumMap = {
  StorageLocation.internal: 'internal',
  StorageLocation.sdCard: 'sdCard',
  StorageLocation.external: 'external',
  StorageLocation.unknown: 'unknown',
};
