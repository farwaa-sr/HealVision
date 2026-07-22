import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../data/local/database.dart';
import '../../../data/local/secure_store.dart';
import '../../companion/data/message_cipher.dart';

/// Builds the "export my data" payload and performs "delete everything".
///
/// Export decrypts the chat so the user gets their *own* words back in plain
/// text — it's their data. Delete wipes every table and app-level secret, while
/// keeping the database encryption key and onboarding flag so the app still
/// opens cleanly afterward.
class DataExportService {
  DataExportService({
    required AppDatabase db,
    required MessageCipher cipher,
    required SecureStore store,
  })  : _db = db,
        _cipher = cipher,
        _store = store;

  final AppDatabase _db;
  final MessageCipher _cipher;
  final SecureStore _store;

  Future<String> buildJson() async {
    Future<List<Map<String, dynamic>>> rows<T extends Table, R extends DataClass>(
      TableInfo<T, R> table,
    ) async {
      final result = await _db.select(table).get();
      return result.map((r) => r.toJson()).toList();
    }

    final chat = <Map<String, dynamic>>[];
    for (final m in await _db.select(_db.chatMessages).get()) {
      chat.add({
        'role': m.role,
        'text': await _cipher.decrypt(m.contentEnc),
        'createdAt': m.createdAt.toIso8601String(),
        'crisis': m.crisis,
      });
    }

    final data = <String, dynamic>{
      'app': 'Onward',
      'exportedAt': DateTime.now().toIso8601String(),
      'note':
          'This is a full copy of your data, decrypted for you. Keep it safe.',
      'substances': await rows(_db.substances),
      'attempts': await rows(_db.attempts),
      'relapses': await rows(_db.relapses),
      'cravings': await rows(_db.cravings),
      'checkIns': await rows(_db.checkIns),
      'triggerLogs': await rows(_db.triggerLogs),
      'activities': await rows(_db.activities),
      'scheduledActivities': await rows(_db.scheduledActivities),
      'activityLogs': await rows(_db.activityLogs),
      'goals': await rows(_db.goals),
      'goalSteps': await rows(_db.goalSteps),
      'supportContacts': await rows(_db.supportContacts),
      'settings': await rows(_db.appSettings),
      'chat': chat,
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<void> deleteEverything() async {
    await _db.transaction(() async {
      // Children first, then parents (also covered by cascade, but explicit).
      await _db.delete(_db.chatMessages).go();
      await _db.delete(_db.goalSteps).go();
      await _db.delete(_db.goals).go();
      await _db.delete(_db.activityLogs).go();
      await _db.delete(_db.scheduledActivities).go();
      await _db.delete(_db.activities).go();
      await _db.delete(_db.triggerLogs).go();
      await _db.delete(_db.checkIns).go();
      await _db.delete(_db.cravings).go();
      await _db.delete(_db.relapses).go();
      await _db.delete(_db.attempts).go();
      await _db.delete(_db.substances).go();
      await _db.delete(_db.supportContacts).go();
      await _db.delete(_db.appSettings).go();
    });

    // App-level secrets (leave the DB key + onboarding flag intact).
    for (final key in const [
      'companion.token',
      'companion.userId',
      'companion.msgKey.v1',
      'lock.enabled',
      'lock.biometrics',
      'lock.pin.salt',
      'lock.pin.hash',
    ]) {
      await _store.delete(key);
    }
  }
}
