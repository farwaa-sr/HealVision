import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/local/database.dart';

part 'database_provider.g.dart';

/// App-wide Drift database, kept alive for the app's lifetime and closed on
/// dispose. Feature repositories read this provider.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}
