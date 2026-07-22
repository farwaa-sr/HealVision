import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart' show OperatingSystem, open;
import 'package:sqlite3/sqlite3.dart' show sqlite3;

import '../../../core/constants/app_constants.dart';

/// Opens the local database through SQLCipher, so the whole file is encrypted
/// at rest with a 256-bit key that lives only in the platform keystore. Even a
/// full copy of the app's storage reveals nothing without the device's key.
///
/// Opened on the current isolate (not a background one) on purpose: the
/// SQLCipher `open` override must be registered on the same isolate that opens
/// the file, which the background variant can't guarantee.
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, AppConstants.dbFileName));

    if (Platform.isAndroid) {
      open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
      // Some Android builds need a writable temp dir for SQLite.
      sqlite3.tempDirectory = (await getTemporaryDirectory()).path;
    }

    final key = await _databaseKey();
    return NativeDatabase(
      file,
      setup: (raw) {
        // Unlock the encrypted database before any other statement runs.
        raw.execute("PRAGMA key = '$key';");
        // In debug, confirm SQLCipher (not plain SQLite) is actually linked.
        assert(
          raw.select('PRAGMA cipher_version;').isNotEmpty,
          'SQLCipher is not available — the database would be unencrypted.',
        );
      },
    );
  });
}

/// The database encryption key: generated once, then kept only in secure
/// storage (Keychain / Android Keystore). Hex so it's safe to inline in PRAGMA.
Future<String> _databaseKey() async {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  const keyName = 'db.encryption.key.v1';
  final existing = await storage.read(key: keyName);
  if (existing != null && existing.length == 64) return existing;

  final rnd = Random.secure();
  final key = List<int>.generate(32, (_) => rnd.nextInt(256))
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();
  await storage.write(key: keyName, value: key);
  return key;
}
