/// App-wide constants
class AppConstants {
  AppConstants._();
  
  // App info
  static const String appName = 'Game Size Manager';
  static const String appVersion = '1.0.0';
  
  // GitHub repo for auto-update
  static const String githubOwner = 'anduser';
  static const String githubRepo = 'game-size-manager';
  
  // Storage thresholds (percentage)
  static const double storageWarningThreshold = 70.0;
  static const double storageCriticalThreshold = 90.0;
  
  // Size formatting
  static const List<String> sizeUnits = ['B', 'KB', 'MB', 'GB', 'TB'];
}

/// Game sources supported by the app
enum GameSource {
  heroic('Heroic', 'Epic/GOG games'),
  ogi('OGI', 'OpenGameInstaller'),
  lutris('Lutris', 'Lutris games'),
  steam('Steam', 'Native Steam games');

  const GameSource(this.displayName, this.description);
  final String displayName;
  final String description;
}
