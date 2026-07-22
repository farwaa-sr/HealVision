import 'package:drift/drift.dart';

/// Fallback for platforms that have neither dart:io nor web support.
QueryExecutor openConnection() {
  throw UnsupportedError(
    'No database implementation is available for this platform.',
  );
}
