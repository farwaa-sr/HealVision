import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/database_provider.dart';
import '../../checkin/providers/checkin_providers.dart';
import '../data/motivation_repository.dart';
import '../model/quote.dart';
import '../model/quote_library.dart';

part 'motivation_providers.g.dart';

@riverpod
MotivationRepository motivationRepository(MotivationRepositoryRef ref) {
  return MotivationRepository(ref.watch(appDatabaseProvider));
}

@riverpod
Future<Set<String>> favoriteQuoteIds(FavoriteQuoteIdsRef ref) {
  return ref.watch(motivationRepositoryProvider).getFavorites();
}

/// Picks a grounded message for a given day, gently biased toward how the user
/// seems to be feeling (from their most recent check-in).
Quote pickQuote({required int dayIndex, int? mood}) {
  var pool = kQuotes;
  if (mood != null) {
    final Set<QuoteTheme> themes = mood <= 2
        ? {QuoteTheme.selfCompassion, QuoteTheme.oneDay, QuoteTheme.hope}
        : mood == 3
            ? {QuoteTheme.hope, QuoteTheme.strength, QuoteTheme.honesty}
            : {QuoteTheme.strength, QuoteTheme.connection, QuoteTheme.hope};
    final filtered = kQuotes.where((q) => themes.contains(q.theme)).toList();
    if (filtered.isNotEmpty) pool = filtered;
  }
  return pool[dayIndex % pool.length];
}

/// The daily rotating message, mood-matched where possible.
@riverpod
Quote dailyQuote(DailyQuoteRef ref) {
  final checkIns = ref.watch(recentCheckInsProvider).valueOrNull;
  final mood =
      (checkIns != null && checkIns.isNotEmpty) ? checkIns.last.mood : null;
  final now = DateTime.now();
  final dayIndex = now.difference(DateTime(now.year)).inDays;
  return pickQuote(dayIndex: dayIndex, mood: mood);
}
