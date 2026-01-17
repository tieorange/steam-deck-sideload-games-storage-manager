import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'settings_entity.freezed.dart';
part 'settings_entity.g.dart';

/// App settings entity
@freezed
class Settings with _$Settings {
  const factory Settings({
    /// Theme mode
    @Default(ThemeMode.dark) ThemeMode themeMode,
    
    /// Custom Heroic config path (optional override)
    String? heroicConfigPath,
    
    /// Custom Lutris DB path (optional override)
    String? lutrisDbPath,
    
    /// Custom Steam path (optional override)
    String? steamPath,
    
    /// Custom OGI library path (optional override)
    String? ogiLibraryPath,
    
    /// Whether to show confirmation before uninstall
    @Default(true) bool confirmBeforeUninstall,
    
    /// Whether to sort by size descending by default
    @Default(true) bool sortBySizeDescending,
  }) = _Settings;
  
  factory Settings.fromJson(Map<String, dynamic> json) => 
    _$SettingsFromJson(json);
}
