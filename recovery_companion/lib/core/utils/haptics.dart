import 'package:flutter/services.dart';

/// Light, purposeful haptic feedback for key actions. Kept gentle — feedback
/// should feel reassuring, not jarring.
abstract class Haptics {
  /// A single tap / press confirmation.
  static Future<void> tap() => HapticFeedback.lightImpact();

  /// Moving between options (mood selection, chips).
  static Future<void> selection() => HapticFeedback.selectionClick();

  /// A meaningful positive moment (milestone, saved check-in).
  static Future<void> success() => HapticFeedback.mediumImpact();
}
