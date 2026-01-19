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

    try {
      final settings = await _repository.loadSettings();
      emit(SettingsState.loaded(settings));
    } catch (e, s) {
      _logger.error('Failed to load settings', error: e, stackTrace: s);
      emit(SettingsState.error(e.toString()));
    }
  }

  /// Update theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    final currentSettings = state.maybeWhen(
      loaded: (settings) => settings,
      orElse: () => const Settings(),
    );

    final newSettings = currentSettings.copyWith(themeMode: mode);
    await _saveSettings(newSettings);
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
    try {
      await _repository.saveSettings(settings);
      emit(SettingsState.loaded(settings));
    } catch (e, s) {
      _logger.error('Failed to save settings', error: e, stackTrace: s);
    }
  }
}
