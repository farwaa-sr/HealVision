import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/dashboard_data.dart';

part 'dashboard_providers.g.dart';

/// Loads and holds the Home dashboard snapshot. Uses mock data with a short
/// simulated latency for now; a later step swaps `_load` for real repository
/// reads (sober tracker, activities, goals, check-ins) without touching the UI.
@riverpod
class DashboardController extends _$DashboardController {
  @override
  Future<DashboardData> build() => _load();

  Future<DashboardData> _load() async {
    // Simulate a brief fetch so skeletons and pull-to-refresh are visible.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return DashboardData.mock();
  }

  /// Pull-to-refresh.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  /// Optimistically toggle a "Today" item's done state.
  void toggleTodayItem(String id) {
    final data = state.valueOrNull;
    if (data == null) return;
    final updated = [
      for (final item in data.today)
        if (item.id == id) item.copyWith(done: !item.done) else item,
    ];
    state = AsyncData(data.copyWith(today: updated));
  }
}
