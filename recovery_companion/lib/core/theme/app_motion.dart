import 'package:flutter/material.dart';

/// Subtle, never-flashy motion. All durations respect the OS "reduce motion"
/// accessibility setting — when enabled, animations collapse to zero so the
/// app stays calm for users who need stillness.
abstract class AppMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 260);
  static const Duration slow = Duration(milliseconds: 450);

  static const Curve curve = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;

  /// True when the user has asked the OS to reduce motion.
  static bool reduced(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  /// Returns [d], or [Duration.zero] if reduced motion is on.
  static Duration duration(BuildContext context, Duration d) =>
      reduced(context) ? Duration.zero : d;
}
