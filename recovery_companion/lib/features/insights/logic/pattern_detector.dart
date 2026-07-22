import 'package:flutter/material.dart';

import '../../../data/local/database.dart';
import '../model/insight.dart';
import '../model/risk_window.dart';

/// On-device pattern detection. Turns the user's own check-ins, triggers, and
/// slips into a few gentle, supportive heads-ups. Deliberately conservative —
/// it only speaks up when there's enough data and a clear-enough signal, so it
/// never over-claims or feels like surveillance.
class PatternDetector {
  const PatternDetector();

  static const _minCheckIns = 5;
  static const _cravingDelta = 1.5; // on a 0–10 scale

  static const _weekdays = [
    'Mondays',
    'Tuesdays',
    'Wednesdays',
    'Thursdays',
    'Fridays',
    'Saturdays',
    'Sundays',
  ];

  List<Insight> analyze({
    required List<CheckIn> checkIns,
    List<Relapse> relapses = const [],
    List<TriggerLog> triggers = const [],
  }) {
    if (checkIns.length < _minCheckIns) return const [];

    final candidates = <Insight>[
      ..._eveningAfterLowSleep(checkIns),
      ..._lowSleep(checkIns),
      ..._evening(checkIns),
      ..._highStress(checkIns),
      ..._weekdayRisk(checkIns, relapses, triggers),
    ]..sort((a, b) => b.strength.compareTo(a.strength));

    // Avoid saying the same thing twice (e.g. plain low-sleep + evening-low-sleep).
    final seen = <String>{};
    final result = <Insight>[];
    for (final c in candidates) {
      if (seen.add(c.title)) result.add(c);
      if (result.length == 3) break;
    }
    return result;
  }

  /// Structured version of the same signals, for *timing* a supportive nudge
  /// just before a typically-harder stretch. Conservative by design: returns at
  /// most a couple of windows, and only when the evidence is clear.
  List<RiskWindow> riskWindows({
    required List<CheckIn> checkIns,
    List<Relapse> relapses = const [],
    List<TriggerLog> triggers = const [],
  }) {
    if (checkIns.length < _minCheckIns) return const [];
    final windows = <RiskWindow>[];

    // A general "evenings are tougher" pattern → every-day evening window.
    final evening = checkIns.where((x) => x.createdAt.hour >= 18).toList();
    final earlier = checkIns.where((x) => x.createdAt.hour < 18).toList();
    if (evening.length >= 2 &&
        earlier.length >= 2 &&
        _avgCraving(evening) - _avgCraving(earlier) >= _cravingDelta) {
      windows.add(const RiskWindow(hour: 18));
    }

    // A specific higher-risk weekday → that weekday's evening.
    final byDay = <int, List<int>>{};
    for (final x in checkIns) {
      byDay.putIfAbsent(x.createdAt.weekday, () => []).add(x.cravingLevel);
    }
    final overall = _avgCraving(checkIns);
    var bestDay = -1;
    var bestDelta = 0.0;
    byDay.forEach((day, list) {
      if (list.length < 2) return;
      final avg = list.reduce((a, b) => a + b) / list.length;
      final delta = avg - overall;
      if (delta > bestDelta) {
        bestDelta = delta;
        bestDay = day;
      }
    });
    if (bestDay >= 1 && bestDelta >= _cravingDelta) {
      windows.add(RiskWindow(hour: 18, weekday: bestDay));
    }

    return windows;
  }

  double _avgCraving(Iterable<CheckIn> xs) {
    final list = xs.toList();
    if (list.isEmpty) return 0;
    return list.map((c) => c.cravingLevel).reduce((a, b) => a + b) / list.length;
  }

  List<Insight> _lowSleep(List<CheckIn> c) {
    final low = c.where((x) => x.sleepQuality <= 2).toList();
    final rest = c.where((x) => x.sleepQuality > 2).toList();
    if (low.length < 2 || rest.length < 2) return const [];
    final delta = _avgCraving(low) - _avgCraving(rest);
    if (delta < _cravingDelta) return const [];
    return [
      Insight(
        icon: Icons.bedtime_outlined,
        title: 'Sleep and cravings',
        body: 'On days after a poor night\'s sleep, your cravings tend to run '
            'higher. Being extra gentle with yourself on those days can help.',
        action: InsightAction.planActivity,
        strength: delta,
      ),
    ];
  }

  List<Insight> _evening(List<CheckIn> c) {
    final evening = c.where((x) => x.createdAt.hour >= 18).toList();
    final earlier = c.where((x) => x.createdAt.hour < 18).toList();
    if (evening.length < 2 || earlier.length < 2) return const [];
    final delta = _avgCraving(evening) - _avgCraving(earlier);
    if (delta < _cravingDelta) return const [];
    return [
      Insight(
        icon: Icons.nightlight_outlined,
        title: 'Evenings',
        body: 'Evenings seem to be a little tougher for you — cravings run '
            'higher later in the day. A plan for those hours can make a real '
            'difference.',
        action: InsightAction.setReminder,
        strength: delta,
      ),
    ];
  }

  List<Insight> _eveningAfterLowSleep(List<CheckIn> c) {
    final both =
        c.where((x) => x.createdAt.hour >= 18 && x.sleepQuality <= 2).toList();
    final rest =
        c.where((x) => !(x.createdAt.hour >= 18 && x.sleepQuality <= 2)).toList();
    if (both.length < 2 || rest.length < 2) return const [];
    final delta = _avgCraving(both) - _avgCraving(rest);
    if (delta < _cravingDelta + 0.5) return const [];
    return [
      Insight(
        icon: Icons.insights_outlined,
        title: 'Evenings after low sleep',
        body: 'Your cravings tend to be higher on evenings after low sleep. '
            'That\'s a really useful thing to know — you can plan a little '
            'support for those times.',
        action: InsightAction.planActivity,
        strength: delta + 1, // combined signal is the most useful; rank it high
      ),
    ];
  }

  List<Insight> _highStress(List<CheckIn> c) {
    final withStress = c.where((x) => x.stressLevel != null).toList();
    if (withStress.length < 4) return const [];
    final high = withStress.where((x) => (x.stressLevel ?? 0) >= 6).toList();
    final low = withStress.where((x) => (x.stressLevel ?? 0) < 6).toList();
    if (high.length < 2 || low.length < 2) return const [];
    final delta = _avgCraving(high) - _avgCraving(low);
    if (delta < _cravingDelta) return const [];
    return [
      Insight(
        icon: Icons.bolt_outlined,
        title: 'Stress and cravings',
        body: 'Higher-stress days seem to bring stronger cravings. On stressful '
            'days, an early wind-down or a check-in with someone can help.',
        action: InsightAction.planActivity,
        strength: delta,
      ),
    ];
  }

  List<Insight> _weekdayRisk(
    List<CheckIn> c,
    List<Relapse> relapses,
    List<TriggerLog> triggers,
  ) {
    // Average craving by weekday from check-ins.
    final byDay = <int, List<int>>{};
    for (final x in c) {
      byDay.putIfAbsent(x.createdAt.weekday, () => []).add(x.cravingLevel);
    }
    final overall = _avgCraving(c);

    var bestDay = -1;
    var bestDelta = 0.0;
    byDay.forEach((day, list) {
      if (list.length < 2) return;
      final avg = list.reduce((a, b) => a + b) / list.length;
      final delta = avg - overall;
      if (delta > bestDelta) {
        bestDelta = delta;
        bestDay = day;
      }
    });

    if (bestDay < 1 || bestDelta < _cravingDelta) return const [];
    final name = _weekdays[bestDay - 1];
    return [
      Insight(
        icon: Icons.event_outlined,
        title: '$name tend to be higher-risk',
        body: '$name seem to be a higher-risk time for you. It might help to '
            'plan a replacement activity ahead of time, so you\'re ready.',
        action: InsightAction.planActivity,
        strength: bestDelta,
      ),
    ];
  }
}
