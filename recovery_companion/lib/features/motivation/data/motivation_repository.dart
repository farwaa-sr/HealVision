import 'dart:convert';


import '../../../data/local/database.dart';

const _kFavorites = 'motivation.favorites';

/// Stores which curated quotes the user has saved as favorites (locally).
class MotivationRepository {
  MotivationRepository(this._db);

  final AppDatabase _db;

  Future<Set<String>> getFavorites() async {
    final row = await (_db.select(_db.appSettings)
          ..where((s) => s.key.equals(_kFavorites)))
        .getSingleOrNull();
    if (row == null || row.value.isEmpty) return {};
    return (jsonDecode(row.value) as List<dynamic>)
        .map((e) => e.toString())
        .toSet();
  }

  Future<void> toggleFavorite(String id) async {
    final favorites = await getFavorites();
    if (!favorites.add(id)) favorites.remove(id);
    await _db.into(_db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: _kFavorites,
            value: jsonEncode(favorites.toList()),
          ),
        );
  }
}
