import 'package:game_size_manager/features/settings/domain/entities/settings_entity.dart';

/// Repository interface for settings operations
abstract class SettingsRepository {
  /// Load settings from storage
  Future<Settings> loadSettings();
  
  /// Save settings to storage
  Future<void> saveSettings(Settings settings);
}
