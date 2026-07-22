import 'package:drift/drift.dart';

import '../../../data/local/database.dart';
import '../model/activity_library.dart';
import '../model/activity_meta.dart';

/// Per-activity outcome from the mood-before/after feedback loop.
class ActivityStat {
  const ActivityStat({required this.count, required this.avgMoodDelta});
  final int count;
  final double avgMoodDelta;
}

/// A scheduled activity joined with its library entry.
class ScheduledEntry {
  const ScheduledEntry({required this.scheduled, required this.activity});
  final ScheduledActivity scheduled;
  final Activity activity;
}

const _kNeeds = 'activities.needs';

class ActivitiesRepository {
  ActivitiesRepository(this._db);

  final AppDatabase _db;

  /// Seed the built-in library once, on first use.
  Future<void> seedIfEmpty() async {
    final existing =
        await (_db.select(_db.activities)..limit(1)).getSingleOrNull();
    if (existing != null) return;
    await _db.batch((b) {
      b.insertAll(
        _db.activities,
        [
          for (final a in kActivityLibrary)
            ActivitiesCompanion.insert(
              title: a.title,
              category: a.category.name,
              reason: Value(a.reason),
              needTags: Value(needsToCsv(a.needs)),
              createdAt: DateTime.now(),
            ),
        ],
      );
    });
  }

  // --- Needs (personalization) ---
  Future<List<Need>> getNeeds() async {
    final row = await (_db.select(_db.appSettings)
          ..where((s) => s.key.equals(_kNeeds)))
        .getSingleOrNull();
    return needsFromCsv(row?.value);
  }

  Future<void> saveNeeds(List<Need> needs) async {
    await _db.into(_db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(key: _kNeeds, value: needsToCsv(needs)),
        );
  }

  // --- Library ---
  Stream<List<Activity>> watchActivities() {
    return (_db.select(_db.activities)
          ..where((a) => a.archived.equals(false))
          ..orderBy([(a) => OrderingTerm.asc(a.title)]))
        .watch();
  }

  Future<void> addCustom({
    required String title,
    required ActivityCategory category,
    String reason = '',
    List<Need> needs = const [],
  }) async {
    await _db.into(_db.activities).insert(
          ActivitiesCompanion.insert(
            title: title,
            category: category.name,
            reason: Value(reason),
            needTags: Value(needsToCsv(needs)),
            isCustom: const Value(true),
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> archiveActivity(int id) async {
    await (_db.update(_db.activities)..where((a) => a.id.equals(id)))
        .write(const ActivitiesCompanion(archived: Value(true)));
  }

  // --- Scheduling ---
  Future<void> schedule(int activityId, DateTime when, {String? note}) async {
    await _db.into(_db.scheduledActivities).insert(
          ScheduledActivitiesCompanion.insert(
            activityId: activityId,
            scheduledFor: when,
            note: Value(note),
            createdAt: DateTime.now(),
          ),
        );
  }

  Stream<List<ScheduledEntry>> watchUpcoming() {
    final q = _db.select(_db.scheduledActivities).join([
      innerJoin(
        _db.activities,
        _db.activities.id.equalsExp(_db.scheduledActivities.activityId),
      ),
    ])
      ..where(_db.scheduledActivities.done.equals(false))
      ..orderBy([OrderingTerm.asc(_db.scheduledActivities.scheduledFor)]);

    return q.watch().map(
          (rows) => rows
              .map((r) => ScheduledEntry(
                    scheduled: r.readTable(_db.scheduledActivities),
                    activity: r.readTable(_db.activities),
                  ),)
              .toList(),
        );
  }

  Future<void> markScheduledDone(int id) async {
    await (_db.update(_db.scheduledActivities)..where((s) => s.id.equals(id)))
        .write(const ScheduledActivitiesCompanion(done: Value(true)));
  }

  Future<void> deleteScheduled(int id) async {
    await (_db.delete(_db.scheduledActivities)..where((s) => s.id.equals(id)))
        .go();
  }

  // --- Feedback loop ---
  Future<void> logActivity({
    required int activityId,
    required int moodBefore,
    required int moodAfter,
    String? note,
  }) async {
    await _db.into(_db.activityLogs).insert(
          ActivityLogsCompanion.insert(
            activityId: activityId,
            completedAt: DateTime.now(),
            moodBefore: moodBefore,
            moodAfter: moodAfter,
            note: Value(note),
          ),
        );
  }

  /// Per-activity average mood lift and how many times it's been logged.
  Stream<Map<int, ActivityStat>> watchStats() {
    return _db.select(_db.activityLogs).watch().map((logs) {
      final byActivity = <int, List<int>>{};
      for (final l in logs) {
        byActivity
            .putIfAbsent(l.activityId, () => [])
            .add(l.moodAfter - l.moodBefore);
      }
      return {
        for (final entry in byActivity.entries)
          entry.key: ActivityStat(
            count: entry.value.length,
            avgMoodDelta:
                entry.value.reduce((a, b) => a + b) / entry.value.length,
          ),
      };
    });
  }
}
