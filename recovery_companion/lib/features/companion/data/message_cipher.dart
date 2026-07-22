import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import '../../../data/local/secure_store.dart';

/// Encrypts companion messages before they touch SQLite, so chat history is
/// unreadable at rest. Uses AES-256-GCM (authenticated encryption). The key is
/// generated once and stored only in the platform keystore (Keychain /
/// Android Keystore) via [SecureStore] — never in the database, never in a
/// backup of the app's documents.
///
/// Ciphertext format (base64): `nonce (12B) | ciphertext | MAC (16B)`.
class MessageCipher {
  MessageCipher(this._store);

  final SecureStore _store;
  final AesGcm _algorithm = AesGcm.with256bits();

  static const _keyStorageId = 'companion.msgKey.v1';
  static const int _nonceLength = 12;
  static const int _macLength = 16;

  SecretKey? _cachedKey;

  Future<SecretKey> _key() async {
    final cached = _cachedKey;
    if (cached != null) return cached;

    final stored = await _store.read(_keyStorageId);
    if (stored != null && stored.isNotEmpty) {
      return _cachedKey = SecretKey(base64Decode(stored));
    }

    // First run on this device — mint and persist a fresh key.
    final key = await _algorithm.newSecretKey();
    final bytes = await key.extractBytes();
    await _store.write(_keyStorageId, base64Encode(bytes));
    return _cachedKey = SecretKey(bytes);
  }

  /// Encrypts [plainText] → base64 payload safe to store in SQLite.
  Future<String> encrypt(String plainText) async {
    final secretBox = await _algorithm.encrypt(
      utf8.encode(plainText),
      secretKey: await _key(),
    );
    return base64Encode(secretBox.concatenation());
  }

  /// Decrypts a payload produced by [encrypt]. Returns a gentle placeholder
  /// rather than throwing if a row can't be read (e.g. key was reset).
  Future<String> decrypt(String payload) async {
    try {
      final secretBox = SecretBox.fromConcatenation(
        base64Decode(payload),
        nonceLength: _nonceLength,
        macLength: _macLength,
      );
      final clear = await _algorithm.decrypt(
        secretBox,
        secretKey: await _key(),
      );
      return utf8.decode(clear);
    } catch (_) {
      return '[message could not be read]';
    }
  }
}
