// Export enums from package to avoid breaking changes in the app
export 'package:steam_deck_games_detector/steam_deck_games_detector.dart'
    show GameSource, StorageLocation;

/// App-wide constants
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Game Size Manager';

  // GitHub repo for auto-update
  // GitHub repo for auto-update
  static const String githubOwner = 'tieorange';
  static const String githubRepo = 'steam-deck-sideload-games-storage-manager';
  static const String appVersion = '1.0.5';

  // Log sharing (Resend API)
  static const String resendApiKey = 're_5S81xRmR_NFmfNUzh5qbyRw9qF5KEtxqb';
  static const String developerEmail = 'tieorange@gmail.com';

  // Crash reporting
  static const String sentryDsn =
      'https://984eb702e23a74e3ffda2d06ae15c555@o490335.ingest.us.sentry.io/4510734785249280';

  // Storage thresholds (percentage)
  static const double storageWarningThreshold = 70.0;
  static const double storageCriticalThreshold = 90.0;

  // Size formatting
  static const List<String> sizeUnits = ['B', 'KB', 'MB', 'GB', 'TB'];
}
