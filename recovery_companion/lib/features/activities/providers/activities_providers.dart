import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/database_provider.dart';
import '../../../data/local/database.dart';
import '../data/activities_repository.dart';
import '../model/activity_meta.dart';

part 'activities_providers.g.dart';

@riverpod
ActivitiesRepository activitiesRepository(ActivitiesRepositoryRef ref) {
  return ActivitiesRepository(ref.watch(appDatabaseProvider));
}

/// Seeds the built-in library on first use.
@riverpod
Future<void> ensureSeeded(EnsureSeededRef ref) {
  return ref.watch(activitiesRepositoryProvider).seedIfEmpty();
}

@riverpod
Future<List<Need>> savedNeeds(SavedNeedsRef ref) {
  return ref.watch(activitiesRepositoryProvider).getNeeds();
}

@riverpod
Stream<List<Activity>> activitiesList(ActivitiesListRef ref) {
  return ref.watch(activitiesRepositoryProvider).watchActivities();
}

@riverpod
Stream<Map<int, ActivityStat>> activityStats(ActivityStatsRef ref) {
  return ref.watch(activitiesRepositoryProvider).watchStats();
}

@riverpod
Stream<List<ScheduledEntry>> upcomingSchedule(UpcomingScheduleRef ref) {
  return ref.watch(activitiesRepositoryProvider).watchUpcoming();
}

/// Personalized recommendations: matched to what the substance did for the
/// user, then re-ranked by what has actually lifted their mood over time.
@riverpod
List<Activity> recommendedActivities(RecommendedActivitiesRef ref) {
  final needs = ref.watch(savedNeedsProvider).valueOrNull ?? const <Need>[];
  final activities =
      ref.watch(activitiesListProvider).valueOrNull ?? const <Activity>[];
  final stats = ref.watch(activityStatsProvider).valueOrNull ??
      const <int, ActivityStat>{};

  double score(Activity a) {
    final aNeeds = needsFromCsv(a.needTags).toSet();
    final match = aNeeds.intersection(needs.toSet()).length.toDouble();
    final stat = stats[a.id];
    final lift = (stat != null && stat.count > 0) ? stat.avgMoodDelta * 1.5 : 0;
    return match + lift;
  }

  final ranked = [...activities]..sort((a, b) {
      final s = score(b).compareTo(score(a));
      return s != 0 ? s : a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
  return ranked.take(6).toList();
}
