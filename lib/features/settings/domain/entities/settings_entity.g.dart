// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SettingsImpl _$$SettingsImplFromJson(Map<String, dynamic> json) =>
    _$SettingsImpl(
      themeMode:
          $enumDecodeNullable(_$ThemeModeEnumMap, json['themeMode']) ??
          ThemeMode.dark,
      heroicConfigPath: json['heroicConfigPath'] as String?,
      lutrisDbPath: json['lutrisDbPath'] as String?,
      steamPath: json['steamPath'] as String?,
      ogiLibraryPath: json['ogiLibraryPath'] as String?,
      confirmBeforeUninstall: json['confirmBeforeUninstall'] as bool? ?? true,
      sortBySizeDescending: json['sortBySizeDescending'] as bool? ?? true,
      defaultViewMode: json['defaultViewMode'] as String? ?? 'list',
    );

Map<String, dynamic> _$$SettingsImplToJson(_$SettingsImpl instance) =>
    <String, dynamic>{
      'themeMode': _$ThemeModeEnumMap[instance.themeMode]!,
      'heroicConfigPath': instance.heroicConfigPath,
      'lutrisDbPath': instance.lutrisDbPath,
      'steamPath': instance.steamPath,
      'ogiLibraryPath': instance.ogiLibraryPath,
      'confirmBeforeUninstall': instance.confirmBeforeUninstall,
      'sortBySizeDescending': instance.sortBySizeDescending,
      'defaultViewMode': instance.defaultViewMode,
    };

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};
