import 'package:drift/drift.dart';

import '../../../data/local/database.dart';
import '../model/tracker_models.dart';

/// Drift-backed persistence for the sober journey. Attempts are never deleted,
/// so total effort stays visible across every attempt.
class SoberTrackerRepository {
  SoberTrackerRepository(this._db);

  final AppDatabase _db;

  /// Start tracking a new substance — creates it plus its first ongoing attempt.
  Future<int> addSubstance({required String name, double dailyCost = 0}) async {
    final now = DateTime.now();
    return _db.transaction(() async {
      final id = await _db.into(_db.substances).insert(
            SubstancesCompanion.insert(
              name: name,
              dailyCost: Value(dailyCost),
              createdAt: now,
            ),
          );
      await _db.into(_db.attempts).insert(
            AttemptsCompanion.insert(substanceId: id, startAt: now),
          );
      return id;
    });
  }

  Future<void> deleteSubstance(int substanceId) async {
    await (_db.delete(_db.substances)..where((s) => s.id.equals(substanceId)))
        .go();
  }

  Future<void> setCelebratedIndex(int substanceId, int index) async {
    await (_db.update(_db.substances)..where((s) => s.id.equals(substanceId)))
        .write(SubstancesCompanion(celebratedMilestoneIndex: Value(index)));
  }

  /// Log a slip: end the current attempt, record the (optional) reflection, and
  /// immediately begin a fresh attempt so clean time restarts from now.
  Future<void> logRelapse({
    required int substanceId,
    DateTime? occurredAt,
    String? trigger,
    String? feeling,
    String? situation,
    String? learning,
  }) async {
    final when = occurredAt ?? DateTime.now();
    await _db.transaction(() async {
      final current = await (_db.select(_db.attempts)
            ..where((a) => a.substanceId.equals(substanceId) & a.endAt.isNull()))
          .getSingleOrNull();

      if (current != null) {
        await (_db.update(_db.attempts)..where((a) => a.id.equals(current.id)))
            .write(AttemptsCompanion(endAt: Value(when)));
      }

      await _db.into(_db.relapses).insert(
            RelapsesCompanion.insert(
              substanceId: substanceId,
              occurredAt: when,
              attemptId: Value(current?.id),
              trigger: Value(trigger),
              feeling: Value(feeling),
              situation: Value(situation),
              learning: Value(learning),
            ),
          );

      // Fresh start, right away.
      await _db.into(_db.attempts).insert(
            AttemptsCompanion.insert(substanceId: substanceId, startAt: when),
          );
    });
  }

  /// Live progress for every tracked substance, recomputed against "now".
  Stream<List<SubstanceProgress>> watchProgress() {
    final query = _db.select(_db.substances).join([
      leftOuterJoin(
        _db.attempts,
        _db.attempts.substanceId.equalsExp(_db.substances.id),
      ),
    ])
      ..where(_db.substances.archived.equals(false));

    return query.watch().map((rows) {
      final bySubstance = <int, List<Attempt>>{};
      final substanceById = <int, Substance>{};

      for (final row in rows) {
        final sub = row.readTable(_db.substances);
        substanceById[sub.id] = sub;
        final attempt = row.readTableOrNull(_db.attempts);
        if (attempt != null) {
          bySubstance.putIfAbsent(sub.id, () => []).add(attempt);
        }
      }

      final now = DateTime.now();
      final result = <SubstanceProgress>[];

      for (final sub in substanceById.values) {
        final attempts = bySubstance[sub.id] ?? const <Attempt>[];

        Duration current = Duration.zero;
        Duration longest = Duration.zero;
        Duration total = Duration.zero;
        var relapses = 0;

        for (final a in attempts) {
          final end = a.endAt ?? now;
          final dur = end.difference(a.startAt);
          total += dur;
          if (dur > longest) longest = dur;
          if (a.endAt == null) {
            current = dur;
          } else {
            relapses++;
          }
        }

        result.add(
          SubstanceProgress(
            id: sub.id,
            name: sub.name,
            dailyCost: sub.dailyCost,
            celebratedMilestoneIndex: sub.celebratedMilestoneIndex,
            currentStreak: current,
            longestStreak: longest,
            totalCleanDays: total.inDays,
            attemptsMade: attempts.length,
            relapses: relapses,
          ),
        );
      }

      result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return result;
    });
  }

  /// Calm history timeline for one substance (newest first).
  Stream<List<TimelineEntry>> watchTimeline(int substanceId) {
    final relapseQuery = _db.select(_db.relapses)
      ..where((r) => r.substanceId.equals(substanceId));

    return relapseQuery.watch().asyncMap((relapseRows) async {
      final attempts = await (_db.select(_db.attempts)
            ..where((a) => a.substanceId.equals(substanceId)))
          .get();

      final entries = <TimelineEntry>[
        for (final a in attempts)
          TimelineEntry(kind: TimelineKind.started, date: a.startAt),
        for (final r in relapseRows)
          TimelineEntry(
            kind: TimelineKind.slip,
            date: r.occurredAt,
            trigger: r.trigger,
            feeling: r.feeling,
            situation: r.situation,
            learning: r.learning,
          ),
      ]..sort((a, b) => b.date.compareTo(a.date));

      return entries;
    });
  }
}
