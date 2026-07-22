import 'package:flutter/material.dart';

/// A suggested next step attached to an insight.
enum InsightAction { none, planActivity, setReminder }

/// A gentle, supportive pattern surfaced to the user — a heads-up, never a
/// warning or a judgment. This is their mirror, not a scoreboard.
@immutable
class Insight {
  const Insight({
    required this.icon,
    required this.title,
    required this.body,
    this.action = InsightAction.none,
    this.strength = 0,
  });

  final IconData icon;
  final String title;
  final String body;
  final InsightAction action;

  /// Internal ranking signal (larger = more salient). Not shown to the user.
  final double strength;
}
