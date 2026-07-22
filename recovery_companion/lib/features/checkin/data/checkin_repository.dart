import 'package:drift/drift.dart';

import '../../../data/local/database.dart';

/// Persistence for daily check-ins and at-any-time trigger logs.
class CheckInRepository {
  CheckInRepository(this._db);

  final AppDatabase _db;

  Future<void> saveCheckIn({
    required int mood,
    required int energy,
    required int sleepQuality,
    required int cravingLevel,
    int? stressLevel,
    String? note,
    String? company,
    String? place,
  }) async {
    await _db.into(_db.checkIns).insert(
          CheckInsCompanion.insert(
            createdAt: DateTime.now(),
            mood: mood,
            energy: energy,
            sleepQuality: sleepQuality,
            cravingLevel: cravingLevel,
            stressLevel: Value(stressLevel),
            note: Value(note),
            company: Value(company),
            place: Value(place),
          ),
        );
  }

  Future<void> logTrigger({
    required int intensity,
    String? trigger,
    String? note,
    bool actedOn = false,
  }) async {
    await _db.into(_db.triggerLogs).insert(
          TriggerLogsCompanion.insert(
            createdAt: DateTime.now(),
            intensity: intensity,
            trigger: Value(trigger),
            note: Value(note),
            actedOn: Value(actedOn),
          ),
        );
  }

  Future<bool> hasCheckedInToday() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final row = await (_db.select(_db.checkIns)
          ..where((c) => c.createdAt.isBiggerOrEqualValue(start))
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  Stream<bool> watchCheckedInToday() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return (_db.select(_db.checkIns)
          ..where((c) => c.createdAt.isBiggerOrEqualValue(start))
          ..limit(1))
        .watch()
        .map((rows) => rows.isNotEmpty);
  }

  Stream<List<CheckIn>> watchCheckIns({int days = 45}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return (_db.select(_db.checkIns)
          ..where((c) => c.createdAt.isBiggerOrEqualValue(cutoff))
          ..orderBy([(c) => OrderingTerm.asc(c.createdAt)]))
        .watch();
  }

  Stream<List<TriggerLog>> watchTriggers({int days = 60}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return (_db.select(_db.triggerLogs)
          ..where((t) => t.createdAt.isBiggerOrEqualValue(cutoff)))
        .watch();
  }

  Stream<List<Relapse>> watchRelapses({int days = 60}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return (_db.select(_db.relapses)
          ..where((r) => r.occurredAt.isBiggerOrEqualValue(cutoff)))
        .watch();
  }
}
