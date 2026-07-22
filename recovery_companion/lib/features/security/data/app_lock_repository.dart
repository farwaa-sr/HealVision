import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

import '../../../data/local/secure_store.dart';

/// A snapshot of the app-lock configuration.
class AppLockConfig {
  const AppLockConfig({
    required this.enabled,
    required this.biometrics,
    required this.hasPin,
  });

  final bool enabled;
  final bool biometrics;
  final bool hasPin;

  static const off =
      AppLockConfig(enabled: false, biometrics: false, hasPin: false);
}

/// Stores the optional app-lock settings and the PIN — as a salted PBKDF2 hash,
/// never in the clear — entirely in the platform keystore via [SecureStore].
class AppLockRepository {
  AppLockRepository(this._store);

  final SecureStore _store;

  static const _kEnabled = 'lock.enabled';
  static const _kBiometrics = 'lock.biometrics';
  static const _kSalt = 'lock.pin.salt';
  static const _kHash = 'lock.pin.hash';

  final _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 120000,
    bits: 256,
  );

  Future<AppLockConfig> load() async {
    final enabled = (await _store.read(_kEnabled)) == 'true';
    final biometrics = (await _store.read(_kBiometrics)) == 'true';
    final hasPin = (await _store.read(_kHash))?.isNotEmpty ?? false;
    return AppLockConfig(
      enabled: enabled,
      biometrics: biometrics,
      hasPin: hasPin,
    );
  }

  Future<void> setBiometrics(bool value) =>
      _store.write(_kBiometrics, value ? 'true' : 'false');

  /// Turns the lock on with a freshly-set PIN.
  Future<void> enableWithPin(String pin, {required bool biometrics}) async {
    await _setPin(pin);
    await _store.write(_kBiometrics, biometrics ? 'true' : 'false');
    await _store.write(_kEnabled, 'true');
  }

  /// Turns the lock off and forgets the PIN entirely.
  Future<void> disable() async {
    await _store.write(_kEnabled, 'false');
    await _store.delete(_kSalt);
    await _store.delete(_kHash);
    await _store.delete(_kBiometrics);
  }

  Future<void> changePin(String pin) => _setPin(pin);

  Future<bool> verifyPin(String pin) async {
    final saltB64 = await _store.read(_kSalt);
    final expected = await _store.read(_kHash);
    if (saltB64 == null || expected == null) return false;
    final computed = await _hash(pin, base64Decode(saltB64));
    return _constantTimeEquals(computed, expected);
  }

  Future<void> _setPin(String pin) async {
    final salt = _randomBytes(16);
    final hash = await _hash(pin, salt);
    await _store.write(_kSalt, base64Encode(salt));
    await _store.write(_kHash, hash);
  }

  Future<String> _hash(String pin, List<int> salt) async {
    final key = await _pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: salt,
    );
    return base64Encode(await key.extractBytes());
  }

  List<int> _randomBytes(int n) {
    final rnd = Random.secure();
    return List<int>.generate(n, (_) => rnd.nextInt(256));
  }

  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}
