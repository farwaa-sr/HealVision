import 'package:drift/drift.dart';

import '../../../data/local/database.dart';
import '../model/goal_meta.dart';

class GoalsRepository {
  GoalsRepository(this._db);

  final AppDatabase _db;

  Future<int> addGoal({
    required String title,
    required GoalCategory category,
    String? why,
    DateTime? targetDate,
    List<String> steps = const [],
  }) async {
    return _db.transaction(() async {
      final id = await _db.into(_db.goals).insert(
            GoalsCompanion.insert(
              title: title,
              category: category.name,
              why: Value(why),
              targetDate: Value(targetDate),
              createdAt: DateTime.now(),
            ),
          );
      for (var i = 0; i < steps.length; i++) {
        await _db.into(_db.goalSteps).insert(
              GoalStepsCompanion.insert(
                goalId: id,
                title: steps[i],
                orderIndex: Value(i),
                createdAt: DateTime.now(),
              ),
            );
      }
      return id;
    });
  }

  Future<void> deleteGoal(int id) async {
    await (_db.delete(_db.goals)..where((g) => g.id.equals(id))).go();
  }

  Future<void> setCompleted(int id, bool completed) async {
    await (_db.update(_db.goals)..where((g) => g.id.equals(id))).write(
      GoalsCompanion(
        completedAt: Value(completed ? DateTime.now() : null),
      ),
    );
  }

  // --- Steps ---
  Future<void> addStep(int goalId, String title) async {
    await _db.into(_db.goalSteps).insert(
          GoalStepsCompanion.insert(
            goalId: goalId,
            title: title,
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> toggleStep(int stepId, bool done) async {
    await (_db.update(_db.goalSteps)..where((s) => s.id.equals(stepId)))
        .write(GoalStepsCompanion(done: Value(done)));
  }

  Future<void> deleteStep(int stepId) async {
    await (_db.delete(_db.goalSteps)..where((s) => s.id.equals(stepId))).go();
  }

  Stream<List<GoalStep>> watchSteps(int goalId) {
    return (_db.select(_db.goalSteps)
          ..where((s) => s.goalId.equals(goalId))
          ..orderBy([(s) => OrderingTerm.asc(s.orderIndex)]))
        .watch();
  }

  Stream<Goal?> watchGoal(int goalId) {
    return (_db.select(_db.goals)..where((g) => g.id.equals(goalId)))
        .watchSingleOrNull();
  }

  /// Active (not archived) goals with their step counts. Completed goals sink
  /// to the bottom; soonest target dates rise to the top.
  Stream<List<GoalProgress>> watchGoals({bool includeCompleted = true}) {
    final query = _db.select(_db.goals).join([
      leftOuterJoin(
        _db.goalSteps,
        _db.goalSteps.goalId.equalsExp(_db.goals.id),
      ),
    ])
      ..where(_db.goals.archived.equals(false));

    return query.watch().map((rows) {
      final steps = <int, List<GoalStep>>{};
      final goalsById = <int, Goal>{};
      for (final row in rows) {
        final goal = row.readTable(_db.goals);
        goalsById[goal.id] = goal;
        final step = row.readTableOrNull(_db.goalSteps);
        if (step != null) steps.putIfAbsent(goal.id, () => []).add(step);
      }

      final list = goalsById.values.map((g) {
        final gs = steps[g.id] ?? const <GoalStep>[];
        return GoalProgress(
          goal: g,
          doneSteps: gs.where((s) => s.done).length,
          totalSteps: gs.length,
        );
      }).where((gp) => includeCompleted || !gp.isComplete).toList();

      list.sort((a, b) {
        // Incomplete first.
        if (a.isComplete != b.isComplete) return a.isComplete ? 1 : -1;
        // Then soonest target date.
        final at = a.goal.targetDate;
        final bt = b.goal.targetDate;
        if (at != null && bt != null) return at.compareTo(bt);
        if (at != null) return -1;
        if (bt != null) return 1;
        return b.goal.createdAt.compareTo(a.goal.createdAt);
      });
      return list;
    });
  }
}
