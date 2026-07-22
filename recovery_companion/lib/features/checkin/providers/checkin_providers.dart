import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/database_provider.dart';
import '../../../data/local/database.dart';
import '../../insights/logic/pattern_detector.dart';
import '../../insights/model/insight.dart';
import '../data/checkin_repository.dart';

part 'checkin_providers.g.dart';

@riverpod
CheckInRepository checkInRepository(CheckInRepositoryRef ref) {
  return CheckInRepository(ref.watch(appDatabaseProvider));
}

@riverpod
Stream<bool> checkedInToday(CheckedInTodayRef ref) {
  return ref.watch(checkInRepositoryProvider).watchCheckedInToday();
}

@riverpod
Stream<List<CheckIn>> recentCheckIns(RecentCheckInsRef ref) {
  return ref.watch(checkInRepositoryProvider).watchCheckIns();
}

@riverpod
Stream<List<TriggerLog>> recentTriggers(RecentTriggersRef ref) {
  return ref.watch(checkInRepositoryProvider).watchTriggers();
}

@riverpod
Stream<List<Relapse>> recentRelapses(RecentRelapsesRef ref) {
  return ref.watch(checkInRepositoryProvider).watchRelapses();
}

/// On-device insights, recomputed reactively as new data arrives.
@riverpod
List<Insight> insights(InsightsRef ref) {
  final checkIns = ref.watch(recentCheckInsProvider).valueOrNull ?? const [];
  final triggers = ref.watch(recentTriggersProvider).valueOrNull ?? const [];
  final relapses = ref.watch(recentRelapsesProvider).valueOrNull ?? const [];
  return const PatternDetector()
      .analyze(checkIns: checkIns, triggers: triggers, relapses: relapses);
}
