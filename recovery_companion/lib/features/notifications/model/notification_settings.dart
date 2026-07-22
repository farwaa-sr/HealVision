import 'package:flutter/material.dart';

/// The categories of supportive notification the user can turn on or off
/// independently. Nothing here is ever urgent or shaming.
enum NotifCategory { checkIn, activities, riskNudges, milestones, motivation }

extension NotifCategoryX on NotifCategory {
  String get label => switch (this) {
        NotifCategory.checkIn => 'Daily check-in',
        NotifCategory.activities => 'Activity reminders',
        NotifCategory.riskNudges => 'Supportive nudges',
        NotifCategory.milestones => 'Milestone celebrations',
        NotifCategory.motivation => 'Daily motivation',
      };

  String get blurb => switch (this) {
        NotifCategory.checkIn =>
          'A gentle prompt to check in with yourself, at a time you choose.',
        NotifCategory.activities =>
          'A heads-up shortly before an activity you’ve planned.',
        NotifCategory.riskNudges =>
          'A warm note before times that tend to be harder for you.',
        NotifCategory.milestones =>
          'A quiet celebration when you reach clean-time milestones.',
        NotifCategory.motivation =>
          'One grounded, encouraging thought to start the day.',
      };
}

/// Minutes since midnight ↔ [TimeOfDay] helpers for compact JSON storage.
int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;
TimeOfDay _fromMinutes(int m) => TimeOfDay(hour: (m ~/ 60) % 24, minute: m % 60);

/// All notification preferences. Local-only, user-owned, fully granular.
@immutable
class NotificationSettings {
  const NotificationSettings({
    required this.masterEnabled,
    required this.checkInEnabled,
    required this.checkInTime,
    required this.activitiesEnabled,
    required this.activityLeadMinutes,
    required this.riskNudgesEnabled,
    required this.milestonesEnabled,
    required this.motivationEnabled,
    required this.motivationTime,
    required this.quietHoursEnabled,
    required this.quietStart,
    required this.quietEnd,
    this.pausedUntil,
  });

  final bool masterEnabled;

  /// When set and still in the future, everything is snoozed until this moment
  /// (settings are kept — this is a temporary pause, not turning things off).
  final DateTime? pausedUntil;

  final bool checkInEnabled;
  final TimeOfDay checkInTime;

  final bool activitiesEnabled;

  /// How many minutes before a planned activity the reminder arrives.
  final int activityLeadMinutes;

  final bool riskNudgesEnabled;
  final bool milestonesEnabled;

  final bool motivationEnabled;
  final TimeOfDay motivationTime;

  /// A window the app promises never to notify inside of.
  final bool quietHoursEnabled;
  final TimeOfDay quietStart;
  final TimeOfDay quietEnd;

  /// Calm, sensible starting point: evening check-in, quiet overnight, daily
  /// motivation left off (opt-in), everything supportive rather than pushy.
  factory NotificationSettings.defaults() => const NotificationSettings(
        masterEnabled: true,
        checkInEnabled: true,
        checkInTime: TimeOfDay(hour: 20, minute: 0),
        activitiesEnabled: true,
        activityLeadMinutes: 30,
        riskNudgesEnabled: true,
        milestonesEnabled: true,
        motivationEnabled: false,
        motivationTime: TimeOfDay(hour: 9, minute: 0),
        quietHoursEnabled: true,
        quietStart: TimeOfDay(hour: 22, minute: 0),
        quietEnd: TimeOfDay(hour: 7, minute: 0),
      );

  bool isPausedAt(DateTime now) =>
      pausedUntil != null && pausedUntil!.isAfter(now);

  bool isCategoryOn(NotifCategory c) => switch (c) {
        NotifCategory.checkIn => checkInEnabled,
        NotifCategory.activities => activitiesEnabled,
        NotifCategory.riskNudges => riskNudgesEnabled,
        NotifCategory.milestones => milestonesEnabled,
        NotifCategory.motivation => motivationEnabled,
      };

  /// True if [minutesOfDay] falls inside the (possibly overnight) quiet window.
  bool isQuiet(int minutesOfDay) {
    if (!quietHoursEnabled) return false;
    final start = _toMinutes(quietStart);
    final end = _toMinutes(quietEnd);
    if (start == end) return false;
    if (start < end) return minutesOfDay >= start && minutesOfDay < end;
    // Overnight window (e.g. 22:00 → 07:00).
    return minutesOfDay >= start || minutesOfDay < end;
  }

  NotificationSettings copyWith({
    bool? masterEnabled,
    bool? checkInEnabled,
    TimeOfDay? checkInTime,
    bool? activitiesEnabled,
    int? activityLeadMinutes,
    bool? riskNudgesEnabled,
    bool? milestonesEnabled,
    bool? motivationEnabled,
    TimeOfDay? motivationTime,
    bool? quietHoursEnabled,
    TimeOfDay? quietStart,
    TimeOfDay? quietEnd,
    Object? pausedUntil = _keep,
  }) {
    return NotificationSettings(
      masterEnabled: masterEnabled ?? this.masterEnabled,
      checkInEnabled: checkInEnabled ?? this.checkInEnabled,
      checkInTime: checkInTime ?? this.checkInTime,
      activitiesEnabled: activitiesEnabled ?? this.activitiesEnabled,
      activityLeadMinutes: activityLeadMinutes ?? this.activityLeadMinutes,
      riskNudgesEnabled: riskNudgesEnabled ?? this.riskNudgesEnabled,
      milestonesEnabled: milestonesEnabled ?? this.milestonesEnabled,
      motivationEnabled: motivationEnabled ?? this.motivationEnabled,
      motivationTime: motivationTime ?? this.motivationTime,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietStart: quietStart ?? this.quietStart,
      quietEnd: quietEnd ?? this.quietEnd,
      pausedUntil: identical(pausedUntil, _keep)
          ? this.pausedUntil
          : pausedUntil as DateTime?,
    );
  }

  static const _keep = Object();

  Map<String, dynamic> toJson() => {
        'master': masterEnabled,
        'checkIn': checkInEnabled,
        'checkInTime': _toMinutes(checkInTime),
        'activities': activitiesEnabled,
        'activityLead': activityLeadMinutes,
        'riskNudges': riskNudgesEnabled,
        'milestones': milestonesEnabled,
        'motivation': motivationEnabled,
        'motivationTime': _toMinutes(motivationTime),
        'quiet': quietHoursEnabled,
        'quietStart': _toMinutes(quietStart),
        'quietEnd': _toMinutes(quietEnd),
        'pausedUntil': pausedUntil?.millisecondsSinceEpoch,
      };

  factory NotificationSettings.fromJson(Map<String, dynamic> j) {
    final d = NotificationSettings.defaults();
    T pick<T>(String key, T fallback) => (j[key] as T?) ?? fallback;
    return NotificationSettings(
      masterEnabled: pick('master', d.masterEnabled),
      checkInEnabled: pick('checkIn', d.checkInEnabled),
      checkInTime: j['checkInTime'] is int
          ? _fromMinutes(j['checkInTime'] as int)
          : d.checkInTime,
      activitiesEnabled: pick('activities', d.activitiesEnabled),
      activityLeadMinutes: pick('activityLead', d.activityLeadMinutes),
      riskNudgesEnabled: pick('riskNudges', d.riskNudgesEnabled),
      milestonesEnabled: pick('milestones', d.milestonesEnabled),
      motivationEnabled: pick('motivation', d.motivationEnabled),
      motivationTime: j['motivationTime'] is int
          ? _fromMinutes(j['motivationTime'] as int)
          : d.motivationTime,
      quietHoursEnabled: pick('quiet', d.quietHoursEnabled),
      quietStart: j['quietStart'] is int
          ? _fromMinutes(j['quietStart'] as int)
          : d.quietStart,
      quietEnd:
          j['quietEnd'] is int ? _fromMinutes(j['quietEnd'] as int) : d.quietEnd,
      pausedUntil: j['pausedUntil'] is int
          ? DateTime.fromMillisecondsSinceEpoch(j['pausedUntil'] as int)
          : null,
    );
  }
}
