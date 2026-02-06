/// Centralized opacity constants used throughout the app.
/// Replaces scattered .withValues(alpha: X) magic numbers.
class AppOpacity {
  AppOpacity._();

  /// Very subtle background tints (source color backgrounds, hover overlays)
  static const double subtle = 0.1;

  /// Slightly visible (disabled states, light borders)
  static const double light = 0.2;

  /// Muted text and icons (secondary/inactive elements)
  static const double muted = 0.5;

  /// Semi-transparent overlays (modals, progress overlays)
  static const double overlay = 0.6;

  /// Slightly transparent (selected states, container backgrounds)
  static const double elevated = 0.7;

  /// Nearly opaque (active nav items, prominent backgrounds)
  static const double prominent = 0.8;

  /// Shadow opacity
  static const double shadow = 0.15;
}
