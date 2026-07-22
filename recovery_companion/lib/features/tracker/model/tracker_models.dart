import 'package:flutter/foundation.dart';

/// A quietly-celebrated milestone on the journey.
@immutable
class Milestone {
  const Milestone(this.label, this.threshold);
  final String label;
  final Duration threshold;
}

/// The milestone ladder. Reaching one is celebrated gently (apricot accent,
/// soft animation + haptic) — never gamified or pressured.
const List<Milestone> kMilestones = [
  Milestone('24 hours', Duration(hours: 24)),
  Milestone('3 days', Duration(days: 3)),
  Milestone('1 week', Duration(days: 7)),
  Milestone('30 days', Duration(days: 30)),
  Milestone('90 days', Duration(days: 90)),
  Milestone('6 months', Duration(days: 182)),
  Milestone('1 year', Duration(days: 365)),
];

/// Computed progress for one substance. All durations are relative to "now",
/// recomputed on read. Effort is never erased: [totalCleanDays] and
/// [attemptsMade] persist across every attempt.
@immutable
class SubstanceProgress {
  const SubstanceProgress({
    required this.id,
    required this.name,
    required this.dailyCost,
    required this.celebratedMilestoneIndex,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCleanDays,
    required this.attemptsMade,
    required this.relapses,
  });

  final int id;
  final String name;
  final double dailyCost;
  final int celebratedMilestoneIndex;

  final Duration currentStreak;
  final Duration longestStreak;

  /// Cumulative clean days across all attempts — honors all effort made.
  final int totalCleanDays;
  final int attemptsMade;
  final int relapses;

  int get currentDays => currentStreak.inDays;
  int get currentHours => currentStreak.inHours % 24;
  int get longestDays => longestStreak.inDays;

  /// Money saved is based on total clean days, so it never resets.
  double get moneySaved => dailyCost * totalCleanDays;

  /// Index of the highest milestone the *current* streak has reached (-1 none).
  int get currentReachedIndex {
    var reached = -1;
    for (var i = 0; i < kMilestones.length; i++) {
      if (currentStreak >= kMilestones[i].threshold) reached = i;
    }
    return reached;
  }

  /// How many milestones have ever been reached (by the longest streak).
  int get milestonesEverReached {
    var count = 0;
    for (final m in kMilestones) {
      if (longestStreak >= m.threshold) count++;
    }
    return count;
  }

  /// The next milestone the current streak is working toward (null if all done).
  Milestone? get nextMilestone {
    for (final m in kMilestones) {
      if (currentStreak < m.threshold) return m;
    }
    return null;
  }

  /// Progress (0–1) from the previously reached milestone to the next one.
  double get progressToNext {
    final next = nextMilestone;
    if (next == null) return 1;
    final prev = currentReachedIndex >= 0
        ? kMilestones[currentReachedIndex].threshold
        : Duration.zero;
    final span = next.threshold - prev;
    if (span <= Duration.zero) return 1;
    final done = currentStreak - prev;
    return (done.inSeconds / span.inSeconds).clamp(0.0, 1.0);
  }
}

/// One entry on the calm history timeline.
enum TimelineKind { started, slip }

@immutable
class TimelineEntry {
  const TimelineEntry({
    required this.kind,
    required this.date,
    this.trigger,
    this.feeling,
    this.situation,
    this.learning,
  });

  final TimelineKind kind;
  final DateTime date;

  // Populated for slips (all optional).
  final String? trigger;
  final String? feeling;
  final String? situation;
  final String? learning;

  bool get hasReflection =>
      (trigger?.isNotEmpty ?? false) ||
      (feeling?.isNotEmpty ?? false) ||
      (situation?.isNotEmpty ?? false) ||
      (learning?.isNotEmpty ?? false);
}
