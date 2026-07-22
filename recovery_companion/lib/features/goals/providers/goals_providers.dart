import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/database_provider.dart';
import '../../../data/local/database.dart';
import '../data/goals_repository.dart';
import '../model/goal_meta.dart';

part 'goals_providers.g.dart';

@riverpod
GoalsRepository goalsRepository(GoalsRepositoryRef ref) {
  return GoalsRepository(ref.watch(appDatabaseProvider));
}

@riverpod
Stream<List<GoalProgress>> goals(GoalsRef ref) {
  return ref.watch(goalsRepositoryProvider).watchGoals();
}

/// Active (incomplete) goals only — surfaced on the dashboard "this week".
@riverpod
List<GoalProgress> activeGoals(ActiveGoalsRef ref) {
  final all = ref.watch(goalsProvider).valueOrNull ?? const <GoalProgress>[];
  return all.where((g) => !g.isComplete).toList();
}

@riverpod
Stream<Goal?> goal(GoalRef ref, int goalId) {
  return ref.watch(goalsRepositoryProvider).watchGoal(goalId);
}

@riverpod
Stream<List<GoalStep>> goalSteps(GoalStepsRef ref, int goalId) {
  return ref.watch(goalsRepositoryProvider).watchSteps(goalId);
}
