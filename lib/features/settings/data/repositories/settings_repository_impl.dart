import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:game_size_manager/core/error/failures.dart';

import 'package:game_size_manager/features/settings/domain/entities/settings_entity.dart';
import 'package:game_size_manager/features/settings/domain/repositories/settings_repository.dart';

/// Implementation of SettingsRepository using SharedPreferences
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  static const _keyThemeMode = 'theme_mode';
  static const _keyAppThemeMode = 'app_theme_mode';
  static const _keyHeroicPath = 'heroic_config_path';
  static const _keyLutrisPath = 'lutris_db_path';
  static const _keySteamPath = 'steam_path';
  static const _keyOgiPath = 'ogi_library_path';
  static const _keyConfirmUninstall = 'confirm_before_uninstall';
  static const _keySortBySize = 'sort_by_size_descending';

  @override
  Future<Result<Settings>> loadSettings() async {
    try {
      final themeModeIndex = _prefs.getInt(_keyThemeMode) ?? ThemeMode.dark.index;
      final appThemeModeStr = _prefs.getString(_keyAppThemeMode);
      final appThemeMode = appThemeModeStr != null
          ? AppThemeMode.values.firstWhere(
              (e) => e.name == appThemeModeStr,
              orElse: () => AppThemeMode.dark,
            )
          : _migrateThemeMode(ThemeMode.values[themeModeIndex]);

      final settings = Settings(
        themeMode: appThemeMode.toThemeMode,
        appThemeMode: appThemeMode,
        heroicConfigPath: _prefs.getString(_keyHeroicPath),
        lutrisDbPath: _prefs.getString(_keyLutrisPath),
        steamPath: _prefs.getString(_keySteamPath),
        ogiLibraryPath: _prefs.getString(_keyOgiPath),
        confirmBeforeUninstall: _prefs.getBool(_keyConfirmUninstall) ?? true,
        sortBySizeDescending: _prefs.getBool(_keySortBySize) ?? true,
      );

      return Right(settings);
    } catch (e, s) {
      return Left(StorageFailure('Failed to load settings: $e', s));
    }
  }

  /// Migrate old ThemeMode to new AppThemeMode
  AppThemeMode _migrateThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return AppThemeMode.system;
      case ThemeMode.light:
        return AppThemeMode.light;
      case ThemeMode.dark:
        return AppThemeMode.dark;
    }
  }

  @override
  Future<Result<void>> saveSettings(Settings settings) async {
    try {
      await _prefs.setInt(_keyThemeMode, settings.themeMode.index);
      await _prefs.setString(_keyAppThemeMode, settings.appThemeMode.name);

      if (settings.heroicConfigPath != null) {
        await _prefs.setString(_keyHeroicPath, settings.heroicConfigPath!);
      } else {
        await _prefs.remove(_keyHeroicPath);
      }

      if (settings.lutrisDbPath != null) {
        await _prefs.setString(_keyLutrisPath, settings.lutrisDbPath!);
      } else {
        await _prefs.remove(_keyLutrisPath);
      }

      if (settings.steamPath != null) {
        await _prefs.setString(_keySteamPath, settings.steamPath!);
      } else {
        await _prefs.remove(_keySteamPath);
      }

      if (settings.ogiLibraryPath != null) {
        await _prefs.setString(_keyOgiPath, settings.ogiLibraryPath!);
      } else {
        await _prefs.remove(_keyOgiPath);
      }

      await _prefs.setBool(_keyConfirmUninstall, settings.confirmBeforeUninstall);
      await _prefs.setBool(_keySortBySize, settings.sortBySizeDescending);

      return const Right(null);
    } catch (e, s) {
      return Left(StorageFailure('Failed to save settings: $e', s));
    }
  }
}
