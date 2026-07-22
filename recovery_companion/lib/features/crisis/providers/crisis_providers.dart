import 'dart:ui' show PlatformDispatcher;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/database_provider.dart';
import '../../../data/local/database.dart';
import '../data/crisis_resources.dart';
import '../data/support_contacts_repository.dart';

part 'crisis_providers.g.dart';

@Riverpod(keepAlive: true)
SupportContactsRepository supportContactsRepository(
  SupportContactsRepositoryRef ref,
) {
  return SupportContactsRepository(ref.watch(appDatabaseProvider));
}

/// The user's saved support people, live.
@riverpod
Stream<List<SupportContactRow>> supportContacts(SupportContactsRef ref) {
  return ref.watch(supportContactsRepositoryProvider).watch();
}

/// Best-effort device country (ISO code), used to adapt crisis resources.
@riverpod
String? deviceCountry(DeviceCountryRef ref) {
  return PlatformDispatcher.instance.locale.countryCode;
}

/// Region-appropriate crisis resources (falls back to clearly-labelled US).
@riverpod
CrisisRegion crisisRegion(CrisisRegionRef ref) {
  return crisisRegionFor(ref.watch(deviceCountryProvider));
}
