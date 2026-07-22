import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

/// Thin, defensive wrapper over local_auth. Every call swallows platform
/// exceptions and returns a safe default, so biometrics can never crash the
/// lock screen — the PIN is always the reliable fallback.
class BiometricAuth {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isAvailable() async {
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return supported && canCheck;
    } catch (e) {
      debugPrint('Biometric availability check failed: $e');
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Unlock Onward',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (e) {
      debugPrint('Biometric authentication failed: $e');
      return false;
    }
  }
}
