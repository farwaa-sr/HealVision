/// App-wide constants. Kept intentionally small — feature-specific values live
/// with their features.
abstract class AppConstants {
  static const String appName = 'Onward';

  /// Local SQLite database file name (Drift).
  static const String dbFileName = 'recovery_companion.sqlite';

  /// Standard spacing scale (a fuller design system arrives in the next step).
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
}
