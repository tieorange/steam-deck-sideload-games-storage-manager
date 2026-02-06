import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'settings_entity.freezed.dart';
part 'settings_entity.g.dart';

/// Extended theme mode including OLED
enum AppThemeMode {
  system,
  light,
  dark,
  oled;

  ThemeMode get toThemeMode {
    switch (this) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
      case AppThemeMode.oled:
        return ThemeMode.dark;
    }
  }
}

/// App settings entity
@freezed
class Settings with _$Settings {
  const factory Settings({
    /// Theme mode
    @Default(ThemeMode.dark) ThemeMode themeMode,

    /// Extended theme mode (includes OLED)
    @Default(AppThemeMode.dark) AppThemeMode appThemeMode,

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

    /// Default view mode for games list ('list' or 'grid')
    @Default('list') String defaultViewMode,
  }) = _Settings;

  factory Settings.fromJson(Map<String, dynamic> json) => _$SettingsFromJson(json);
}
