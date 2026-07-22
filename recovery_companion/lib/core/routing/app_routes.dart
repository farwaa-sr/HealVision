/// Named routes for the app. Primary branches live in the bottom nav; the
/// rest are pushed on top (e.g. SOS, daily check-in).
enum AppRoute {
  // Bottom-nav branches
  dashboard('/dashboard'),
  activities('/activities'),
  companion('/companion'),
  progress('/progress'),
  me('/me'),

  // Pushed routes
  sos('/sos'),
  checkin('/checkin'),
  goals('/goals'),
  motivation('/motivation'),
  insights('/insights'),
  notifications('/notifications'),
  privacy('/privacy'),
  substanceDetail('/substance'),
  goalDetail('/goal'),
  styleGuide('/styleguide'),

  // Full-screen, outside the shell
  onboarding('/onboarding');

  const AppRoute(this.path);

  final String path;

  /// Route name == enum name (used with context.goNamed / pushNamed).
  String get routeName => name;
}
