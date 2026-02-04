import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:game_size_manager/core/logging/logger_service.dart';
import 'package:game_size_manager/features/settings/domain/entities/settings_entity.dart';
import 'package:game_size_manager/features/settings/domain/repositories/settings_repository.dart';
import 'package:game_size_manager/features/settings/presentation/cubit/settings_state.dart';

/// Cubit for managing app settings
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository) : super(const SettingsState.initial());

  final SettingsRepository _repository;
  final _logger = LoggerService.instance;

  /// Load settings from storage
  Future<void> loadSettings() async {
    emit(const SettingsState.loading());

    final result = await _repository.loadSettings();

    result.fold((failure) {
      _logger.error('Failed to load settings', error: failure);
      emit(SettingsState.error(failure.message));
    }, (settings) => emit(SettingsState.loaded(settings)));
  }

  /// Update app theme mode (supports OLED)
  Future<void> setAppThemeMode(AppThemeMode mode) async {
    final currentSettings = state.maybeWhen(
      loaded: (settings) => settings,
      orElse: () => const Settings(),
    );

    final newSettings = currentSettings.copyWith(
      appThemeMode: mode,
      themeMode: mode.toThemeMode,
    );
    await _saveSettings(newSettings);
  }

  /// Update theme mode (legacy)
  Future<void> setThemeMode(ThemeMode mode) async {
    final appMode = mode == ThemeMode.system
        ? AppThemeMode.system
        : mode == ThemeMode.light
            ? AppThemeMode.light
            : AppThemeMode.dark;
    await setAppThemeMode(appMode);
  }

  /// Toggle uninstall confirmation
  Future<void> toggleConfirmBeforeUninstall() async {
    final currentSettings = state.maybeWhen(
      loaded: (settings) => settings,
      orElse: () => const Settings(),
    );

    final newSettings = currentSettings.copyWith(
      confirmBeforeUninstall: !currentSettings.confirmBeforeUninstall,
    );
    await _saveSettings(newSettings);
  }

  /// Toggle default sort direction
  Future<void> toggleSortBySizeDescending() async {
    final currentSettings = state.maybeWhen(
      loaded: (settings) => settings,
      orElse: () => const Settings(),
    );

    final newSettings = currentSettings.copyWith(
      sortBySizeDescending: !currentSettings.sortBySizeDescending,
    );
    await _saveSettings(newSettings);
  }

  /// Set the default view mode ('list' or 'grid')
  Future<void> setViewMode(String mode) async {
    final currentSettings = state.maybeWhen(
      loaded: (settings) => settings,
      orElse: () => const Settings(),
    );

    final newSettings = currentSettings.copyWith(defaultViewMode: mode);
    await _saveSettings(newSettings);
  }

  /// Update custom launcher path
  Future<void> updateHeroicPath(String? path) async {
    final currentSettings = state.maybeWhen(
      loaded: (settings) => settings,
      orElse: () => const Settings(),
    );

    final newSettings = currentSettings.copyWith(heroicConfigPath: path);
    await _saveSettings(newSettings);
  }

  Future<void> _saveSettings(Settings settings) async {
    final result = await _repository.saveSettings(settings);

    result.fold((failure) {
      _logger.error('Failed to save settings', error: failure);
    }, (_) => emit(SettingsState.loaded(settings)));
  }
}
