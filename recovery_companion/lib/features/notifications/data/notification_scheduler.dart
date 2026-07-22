import 'package:flutter/material.dart';

import '../../../data/local/database.dart';
import '../../activities/data/activities_repository.dart';
import '../../checkin/data/checkin_repository.dart';
import '../../insights/logic/pattern_detector.dart';
import '../../insights/model/risk_window.dart';
import '../../motivation/providers/motivation_providers.dart' show pickQuote;
import '../../tracker/data/sober_tracker_repository.dart';
import '../../tracker/model/tracker_models.dart';
import '../logic/notification_copy.dart';
import '../model/notification_settings.dart';
import 'notification_service.dart';
import 'notification_settings_repository.dart';

/// Turns the user's real, on-device data — planned activities, detected
/// high-risk windows, streak milestones, mood — into a rolling plan of gentle,
/// well-timed notifications. Re-run on app start, after settings change, and
/// after planning an activity.
///
/// Design choices that keep it kind and predictable:
///  • Everything is cancelled and rebuilt each run, so stale reminders vanish.
///  • Quiet hours are a hard wall — anything landing inside them is skipped.
///  • Today's check-in is skipped if you've already checked in.
///  • A ~2-week horizon is scheduled ahead, refreshed whenever the app opens.
class NotificationScheduler {
  NotificationScheduler({
    required NotificationService service,
    required NotificationSettingsRepository settingsRepo,
    required CheckInRepository checkInRepo,
    required ActivitiesRepository activitiesRepo,
    required SoberTrackerRepository trackerRepo,
  })  : _service = service,
        _settingsRepo = settingsRepo,
        _checkIn = checkInRepo,
        _activities = activitiesRepo,
        _tracker = trackerRepo;

  final NotificationService _service;
  final NotificationSettingsRepository _settingsRepo;
  final CheckInRepository _checkIn;
  final ActivitiesRepository _activities;
  final SoberTrackerRepository _tracker;

  static const int _horizonDays = 14;
  static const Duration _nudgeLead = Duration(minutes: 45);

  Future<void> rescheduleAll() async {
    await _service.cancelAll();

    final settings = await _settingsRepo.load();
    if (!settings.masterEnabled || !_service.isReady) return;

    final now = DateTime.now();
    var id = 1; // unique within this batch — cancelAll() ran first

    final checkedInToday =
        await _safe(() => _checkIn.watchCheckedInToday().first, false);
    final checkIns =
        await _safe(() => _checkIn.watchCheckIns().first, const <CheckIn>[]);
    final relapses =
        await _safe(() => _checkIn.watchRelapses().first, const <Relapse>[]);
    final triggers =
        await _safe(() => _checkIn.watchTriggers().first, const <TriggerLog>[]);
    final upcoming = await _safe(
        () => _activities.watchUpcoming().first, const <ScheduledEntry>[],);
    final progress = await _safe(
        () => _tracker.watchProgress().first, const <SubstanceProgress>[],);

    final windows = settings.riskNudgesEnabled
        ? const PatternDetector().riskWindows(
            checkIns: checkIns,
            relapses: relapses,
            triggers: triggers,
          )
        : const <RiskWindow>[];

    // --- Daily items across the horizon ---
    for (var d = 0; d < _horizonDays; d++) {
      final day = DateTime(now.year, now.month, now.day).add(Duration(days: d));
      final seed = _dayOfYear(day);

      if (settings.checkInEnabled && !(d == 0 && checkedInToday)) {
        id = await _put(id, settings, NotifCategory.checkIn,
            _at(day, settings.checkInTime), () => NotificationCopy.checkIn(seed),);
      }

      if (settings.motivationEnabled) {
        id = await _put(id, settings, NotifCategory.motivation,
            _at(day, settings.motivationTime), () {
          final mood = checkIns.isNotEmpty ? checkIns.last.mood : null;
          final quote = pickQuote(dayIndex: seed, mood: mood);
          return NotificationCopy.motivation(quote.text, seed);
        });
      }

      final window = _earliestWindowFor(windows, day);
      if (window != null) {
        final when = _at(day, TimeOfDay(hour: window.hour, minute: 0))
            .subtract(_nudgeLead);
        id = await _put(id, settings, NotifCategory.riskNudges, when,
            () => NotificationCopy.riskNudge(seed),);
      }
    }

    // --- Activity reminders (event-based) ---
    if (settings.activitiesEnabled) {
      for (final e in upcoming) {
        final when = e.scheduled.scheduledFor
            .subtract(Duration(minutes: settings.activityLeadMinutes));
        final content =
            NotificationCopy.activity(e.activity.title, note: e.scheduled.note);
        id = await _put(id, settings, NotifCategory.activities, when,
            () => content,);
      }
    }

    // --- Milestone celebrations (next one per substance) ---
    if (settings.milestonesEnabled) {
      for (final p in progress) {
        final next = p.nextMilestone;
        if (next == null) continue;
        final when = now.add(next.threshold - p.currentStreak);
        final content = NotificationCopy.milestone(next.label, p.id);
        id = await _put(id, settings, NotifCategory.milestones, when,
            () => content,);
      }
    }
  }

  RiskWindow? _earliestWindowFor(List<RiskWindow> windows, DateTime day) {
    RiskWindow? best;
    for (final w in windows) {
      if (!w.appliesTo(day)) continue;
      if (best == null || w.hour < best.hour) best = w;
    }
    return best;
  }

  /// Schedules [build]'s content at [when] unless it's in the past or inside
  /// quiet hours. Returns the next id to use.
  Future<int> _put(
    int id,
    NotificationSettings settings,
    NotifCategory category,
    DateTime when,
    NotifContent Function() build,
  ) async {
    if (when.isBefore(DateTime.now())) return id;
    if (settings.isPausedAt(when)) return id; // snoozed
    if (settings.isQuiet(when.hour * 60 + when.minute)) return id;
    final content = build();
    await _service.schedule(
      id: id,
      category: category,
      title: content.title,
      body: content.body,
      when: when,
    );
    return id + 1;
  }

  DateTime _at(DateTime day, TimeOfDay t) =>
      DateTime(day.year, day.month, day.day, t.hour, t.minute);

  int _dayOfYear(DateTime d) => d.difference(DateTime(d.year)).inDays;

  Future<T> _safe<T>(Future<T> Function() read, T fallback) async {
    try {
      return await read();
    } catch (_) {
      return fallback;
    }
  }
}
