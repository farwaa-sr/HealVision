import 'package:flutter/material.dart';

import '../../../data/local/database.dart';

/// Recovery goals go well beyond abstinence — health, relationships, money,
/// sleep, and personal growth all count.
enum GoalCategory {
  staySober('Staying free', Icons.shield_outlined),
  health('Health', Icons.favorite_outline),
  fitness('Fitness', Icons.directions_run),
  relationships('Relationships', Icons.people_outline),
  money('Money', Icons.savings_outlined),
  sleep('Sleep', Icons.bedtime_outlined),
  growth('Growth', Icons.eco_outlined),
  other('Other', Icons.flag_outlined);

  const GoalCategory(this.label, this.icon);
  final String label;
  final IconData icon;

  static GoalCategory fromName(String name) {
    for (final c in GoalCategory.values) {
      if (c.name == name) return c;
    }
    return GoalCategory.other;
  }
}

/// A goal plus its sub-step counts, for progress display.
class GoalProgress {
  const GoalProgress({
    required this.goal,
    required this.doneSteps,
    required this.totalSteps,
  });

  final Goal goal;
  final int doneSteps;
  final int totalSteps;

  bool get isComplete => goal.completedAt != null;

  /// 0–1. Steps drive it; a stepless goal is 0 until marked complete.
  double get progress {
    if (isComplete) return 1;
    if (totalSteps == 0) return 0;
    return doneSteps / totalSteps;
  }
}
