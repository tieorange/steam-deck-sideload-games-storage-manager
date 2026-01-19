import 'package:game_size_manager/core/error/failures.dart';
import 'package:game_size_manager/features/settings/domain/entities/settings_entity.dart';

/// Repository interface for settings operations
abstract class SettingsRepository {
  /// Load settings from storage
  Future<Result<Settings>> loadSettings();

  /// Save settings to storage
  Future<Result<void>> saveSettings(Settings settings);
}
