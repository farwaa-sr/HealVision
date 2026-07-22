import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/database_provider.dart';
import '../data/craving_repository.dart';

part 'sos_providers.g.dart';

@riverpod
CravingRepository cravingRepository(CravingRepositoryRef ref) {
  return CravingRepository(ref.watch(appDatabaseProvider));
}

/// The user's saved reasons for recovery (shown in the SOS "Reasons" tool).
@riverpod
Future<List<String>> reasons(ReasonsRef ref) {
  return ref.watch(cravingRepositoryProvider).getReasons();
}

/// The user's trusted support contact, if saved.
@riverpod
Future<SupportContact?> supportContact(SupportContactRef ref) {
  return ref.watch(cravingRepositoryProvider).getContact();
}

/// The user's own saved crisis/helpline number, if any. Shared with the
/// companion's crisis resources so it appears there too.
@riverpod
Future<String?> crisisLine(CrisisLineRef ref) {
  return ref.watch(cravingRepositoryProvider).getCrisisLine();
}
