import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/database_provider.dart';
import '../../../core/providers/secure_store_provider.dart';
import '../../companion/providers/companion_providers.dart';
import '../data/data_export_service.dart';

part 'privacy_providers.g.dart';

@Riverpod(keepAlive: true)
DataExportService dataExportService(DataExportServiceRef ref) {
  return DataExportService(
    db: ref.watch(appDatabaseProvider),
    cipher: ref.watch(messageCipherProvider),
    store: ref.watch(secureStoreProvider),
  );
}
