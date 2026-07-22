import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/database_provider.dart';
import '../data/sober_tracker_repository.dart';
import '../model/tracker_models.dart';

part 'tracker_providers.g.dart';

@riverpod
SoberTrackerRepository soberTrackerRepository(SoberTrackerRepositoryRef ref) {
  return SoberTrackerRepository(ref.watch(appDatabaseProvider));
}

/// Live progress for every tracked substance.
@riverpod
Stream<List<SubstanceProgress>> substanceProgress(SubstanceProgressRef ref) {
  return ref.watch(soberTrackerRepositoryProvider).watchProgress();
}

/// Calm history timeline for one substance.
@riverpod
Stream<List<TimelineEntry>> substanceTimeline(
  SubstanceTimelineRef ref,
  int substanceId,
) {
  return ref.watch(soberTrackerRepositoryProvider).watchTimeline(substanceId);
}
