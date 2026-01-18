/// View mode for games display
enum GameViewMode { list, grid }

/// Steam Deck UI constants for touch and gamepad optimization
class SteamDeckConstants {
  SteamDeckConstants._();

  // Touch targets (Steam Deck has 7" 1280x800 touchscreen)
  static const double minTouchTarget = 48.0;
  static const double preferredTouchTarget = 64.0;

  // Game list item (standard mode)
  static const double gameListItemHeight = 72.0;
  static const double gameIconSize = 48.0;

  // Compact mode - optimized for more visible content
  static const double compactListItemHeight = 48.0;
  static const double compactGameIconSize = 32.0;
  static const double compactFilterHeight = 40.0;
  static const double compactStatsBarHeight = 32.0;

  // Grid view
  static const double gridTileWidth = 180.0;
  static const double gridTileHeight = 80.0;
  static const int gridColumnCount = 2;

  // Spacing
  static const double pagePadding = 16.0;
  static const double compactPadding = 12.0;
  static const double elementGap = 12.0;
  static const double compactGap = 8.0;
  static const double sectionGap = 24.0;

  // Navigation
  static const double navBarHeight = 80.0;
  static const double compactNavBarHeight = 64.0;

  // Cards and buttons
  static const double cardRadius = 16.0;
  static const double buttonRadius = 12.0;
  static const double buttonMinHeight = 52.0;

  // Font sizes (larger for handheld)
  static const double fontSizeBody = 16.0;
  static const double fontSizeSmall = 14.0;
  static const double fontSizeHeading = 20.0;
  static const double fontSizeTitle = 24.0;
}
