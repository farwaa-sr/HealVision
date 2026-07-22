import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../data/local/database.dart';

/// Local store for the user's personal support people (sponsor, trusted friend,
/// family). Kept on-device only; reachable in one tap from SOS and the crisis
/// sheet. Multiple contacts, in the user's own order.
class SupportContactsRepository {
  SupportContactsRepository(this._db);

  final AppDatabase _db;

  Stream<List<SupportContactRow>> watch() {
    return (_db.select(_db.supportContacts)
          ..orderBy([
            (c) => OrderingTerm.asc(c.orderIndex),
            (c) => OrderingTerm.asc(c.id),
          ]))
        .watch();
  }

  Future<List<SupportContactRow>> getAll() {
    return (_db.select(_db.supportContacts)
          ..orderBy([
            (c) => OrderingTerm.asc(c.orderIndex),
            (c) => OrderingTerm.asc(c.id),
          ]))
        .get();
  }

  Future<void> add({
    required String name,
    required String phone,
    String? relationship,
  }) async {
    final all = await getAll();
    await _db.into(_db.supportContacts).insert(
          SupportContactsCompanion.insert(
            name: name,
            phone: phone,
            relationship: Value(relationship),
            orderIndex: Value(all.length),
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> updateContact({
    required int id,
    required String name,
    required String phone,
    String? relationship,
  }) async {
    await (_db.update(_db.supportContacts)..where((c) => c.id.equals(id))).write(
      SupportContactsCompanion(
        name: Value(name),
        phone: Value(phone),
        relationship: Value(relationship),
      ),
    );
  }

  Future<void> remove(int id) async {
    await (_db.delete(_db.supportContacts)..where((c) => c.id.equals(id))).go();
  }

  /// One-time lift of any legacy single SOS contact (Prompt 5) into the table,
  /// so no one loses the person they'd already saved.
  Future<void> migrateLegacyIfNeeded() async {
    final existing =
        await (_db.select(_db.supportContacts)..limit(1)).getSingleOrNull();
    if (existing != null) return;

    final row = await (_db.select(_db.appSettings)
          ..where((s) => s.key.equals('sos.contact')))
        .getSingleOrNull();
    if (row == null || row.value.isEmpty) return;

    try {
      final j = jsonDecode(row.value) as Map<String, dynamic>;
      final name = (j['name'] ?? '').toString().trim();
      final phone = (j['phone'] ?? '').toString().trim();
      if (name.isNotEmpty && phone.isNotEmpty) {
        await add(name: name, phone: phone);
      }
    } catch (_) {
      // Ignore malformed legacy data.
    }
  }
}
