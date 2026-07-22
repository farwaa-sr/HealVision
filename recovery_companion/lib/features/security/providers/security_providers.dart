import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/secure_store_provider.dart';
import '../data/app_lock_repository.dart';
import '../data/biometric_auth.dart';

part 'security_providers.g.dart';

@Riverpod(keepAlive: true)
AppLockRepository appLockRepository(AppLockRepositoryRef ref) {
  return AppLockRepository(ref.watch(secureStoreProvider));
}

@Riverpod(keepAlive: true)
BiometricAuth biometricAuth(BiometricAuthRef ref) => BiometricAuth();

/// Current app-lock configuration (enabled / biometrics / has-PIN).
@riverpod
Future<AppLockConfig> appLockConfig(AppLockConfigRef ref) {
  return ref.watch(appLockRepositoryProvider).load();
}

/// Whether this device can do biometric auth at all.
@riverpod
Future<bool> biometricAvailable(BiometricAvailableRef ref) {
  return ref.watch(biometricAuthProvider).isAvailable();
}
