import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper over platform secure storage (Keychain / Keystore) for the
/// few values that should never sit in plain SQLite — e.g. an app-lock PIN or
/// tokens. Structured recovery data lives in Drift; only sensitive secrets
/// belong here.
class SecureStore {
  SecureStore([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<void> delete(String key) => _storage.delete(key: key);
}
