import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../data/local/database.dart';

/// A trusted person the user can reach in a hard moment.
class SupportContact {
  const SupportContact({required this.name, required this.phone});
  final String name;
  final String phone;

  Map<String, dynamic> toJson() => {'name': name, 'phone': phone};
  factory SupportContact.fromJson(Map<String, dynamic> j) => SupportContact(
        name: j['name'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
      );
}

const _kReasons = 'sos.reasons';
const _kContact = 'sos.contact';
const _kCrisis = 'sos.crisisLine';

/// Persistence for the SOS toolkit: craving events (for pattern insights) plus
/// the user's reasons, trusted contact, and crisis line (stored locally so the
/// toolkit works fully offline).
class CravingRepository {
  CravingRepository(this._db);

  final AppDatabase _db;

  Future<void> logCraving({
    required DateTime startedAt,
    DateTime? resolvedAt,
    int? intensity,
    String? moodAfter,
    List<String>? helped,
    bool gotThrough = true,
  }) async {
    await _db.into(_db.cravings).insert(
          CravingsCompanion.insert(
            startedAt: startedAt,
            resolvedAt: Value(resolvedAt ?? DateTime.now()),
            intensity: Value(intensity),
            moodAfter: Value(moodAfter),
            helped: Value(
              (helped == null || helped.isEmpty) ? null : helped.join(', '),
            ),
            gotThrough: Value(gotThrough),
          ),
        );
  }

  // --- Key/value helpers over AppSettings ---
  Future<String?> _read(String key) async {
    final row = await (_db.select(_db.appSettings)
          ..where((s) => s.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> _write(String key, String value) async {
    await _db.into(_db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(key: key, value: value),
        );
  }

  Future<List<String>> getReasons() async {
    final raw = await _read(_kReasons);
    if (raw == null || raw.isEmpty) return const [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => e.toString()).toList();
  }

  Future<void> saveReasons(List<String> reasons) =>
      _write(_kReasons, jsonEncode(reasons));

  Future<SupportContact?> getContact() async {
    final raw = await _read(_kContact);
    if (raw == null || raw.isEmpty) return null;
    return SupportContact.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveContact(SupportContact contact) =>
      _write(_kContact, jsonEncode(contact.toJson()));

  Future<String?> getCrisisLine() => _read(_kCrisis);

  Future<void> saveCrisisLine(String number) => _write(_kCrisis, number);
}
