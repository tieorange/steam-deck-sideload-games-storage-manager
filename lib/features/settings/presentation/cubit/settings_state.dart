import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:game_size_manager/features/settings/domain/entities/settings_entity.dart';

part 'settings_state.freezed.dart';

/// State for the Settings feature
@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState.initial() = SettingsInitial;
  const factory SettingsState.loading() = SettingsLoading;
  const factory SettingsState.loaded(Settings settings) = SettingsLoaded;
  const factory SettingsState.error(String message) = SettingsError;
}
