import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Web preview connection. Runs SQLite compiled to WebAssembly, persisting to
/// the browser (OPFS / IndexedDB). NOTE: this path is NOT encrypted — it exists
/// only so the UI can be previewed in a browser. The real app uses the native,
/// SQLCipher-encrypted connection.
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'onward_db',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return result.resolvedExecutor;
  });
}
