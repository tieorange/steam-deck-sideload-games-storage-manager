// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StorageInfoImpl _$$StorageInfoImplFromJson(Map<String, dynamic> json) =>
    _$StorageInfoImpl(
      path: json['path'] as String,
      usedBytes: (json['usedBytes'] as num).toInt(),
      totalBytes: (json['totalBytes'] as num).toInt(),
      label: json['label'] as String?,
    );

Map<String, dynamic> _$$StorageInfoImplToJson(_$StorageInfoImpl instance) =>
    <String, dynamic>{
      'path': instance.path,
      'usedBytes': instance.usedBytes,
      'totalBytes': instance.totalBytes,
      'label': instance.label,
    };
