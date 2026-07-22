import 'dart:convert';

import '../../../data/local/database.dart';
import '../model/notification_settings.dart';

const _kSettings = 'notifications.settings';

/// Loads and saves [NotificationSettings] in the local key/value store.
class NotificationSettingsRepository {
  NotificationSettingsRepository(this._db);

  final AppDatabase _db;

  Future<NotificationSettings> load() async {
    final row = await (_db.select(_db.appSettings)
          ..where((s) => s.key.equals(_kSettings)))
        .getSingleOrNull();
    if (row == null || row.value.isEmpty) {
      return NotificationSettings.defaults();
    }
    try {
      return NotificationSettings.fromJson(
        jsonDecode(row.value) as Map<String, dynamic>,
      );
    } catch (_) {
      return NotificationSettings.defaults();
    }
  }

  Future<void> save(NotificationSettings settings) async {
    await _db.into(_db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: _kSettings,
            value: jsonEncode(settings.toJson()),
          ),
        );
  }
}
