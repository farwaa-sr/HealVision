import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';

import '../../../data/local/database.dart';
import '../../../data/local/secure_store.dart';
import '../model/companion_message.dart';
import 'companion_api_client.dart';
import 'message_cipher.dart';

/// Optional build-time defaults, e.g.
/// `flutter run --dart-define=COMPANION_BASE_URL=https://… --dart-define=COMPANION_TOKEN=…`
const _envBaseUrl = String.fromEnvironment('COMPANION_BASE_URL');
const _envToken = String.fromEnvironment('COMPANION_TOKEN');

/// Ties together the local (encrypted) history, the device identity used for
/// per-user rate limiting, the proxy connection settings, and the API client.
///
/// Nothing here ever calls Anthropic directly — every request goes to the
/// user's own backend proxy, which owns the API key and the system prompt.
class CompanionRepository {
  CompanionRepository({
    required AppDatabase db,
    required SecureStore store,
    required MessageCipher cipher,
    required CompanionApiClient client,
  })  : _db = db,
        _store = store,
        _cipher = cipher,
        _client = client;

  final AppDatabase _db;
  final SecureStore _store;
  final MessageCipher _cipher;
  final CompanionApiClient _client;

  // Base URL is not secret; the access token is.
  static const _kBaseUrl = 'companion.baseUrl';
  static const _kToken = 'companion.token';
  static const _kUserId = 'companion.userId';

  /// How many recent turns to send as context (keeps token cost bounded).
  static const _historyWindow = 24;

  // --- Configuration -------------------------------------------------------

  Future<CompanionConfig> loadConfig() async {
    final row = await (_db.select(_db.appSettings)
          ..where((s) => s.key.equals(_kBaseUrl)))
        .getSingleOrNull();
    final baseUrl = (row?.value.isNotEmpty ?? false) ? row!.value : _envBaseUrl;
    final token = await _store.read(_kToken) ?? _envToken;
    return CompanionConfig(baseUrl: baseUrl, token: token);
  }

  Future<void> saveConfig({required String baseUrl, required String token}) async {
    await _db.into(_db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(key: _kBaseUrl, value: baseUrl.trim()),
        );
    final t = token.trim();
    if (t.isEmpty) {
      await _store.delete(_kToken);
    } else {
      await _store.write(_kToken, t);
    }
  }

  /// A stable, random per-install id used only for the backend's rate limiting.
  /// It identifies the device, not the person, and never leaves for anywhere
  /// but the user's own proxy.
  Future<String> userId() async {
    final existing = await _store.read(_kUserId);
    if (existing != null && existing.isNotEmpty) return existing;
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    final id = base64Url.encode(bytes).replaceAll('=', '');
    await _store.write(_kUserId, id);
    return id;
  }

  // --- History (encrypted at rest) -----------------------------------------

  Future<List<CompanionMessage>> loadHistory() async {
    final rows = await (_db.select(_db.chatMessages)
          ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
        .get();
    return Future.wait(
      rows.map((r) async => CompanionMessage.fromRow(r, await _cipher.decrypt(r.contentEnc))),
    );
  }

  Future<CompanionMessage> persist(
    CompanionMessage message,
  ) async {
    final id = await _db.into(_db.chatMessages).insert(
          ChatMessagesCompanion.insert(
            role: message.role.name,
            contentEnc: await _cipher.encrypt(message.text),
            createdAt: message.createdAt,
            crisis: Value(message.crisis),
          ),
        );
    return message.copyWith(id: id);
  }

  Future<void> clearHistory() => _db.delete(_db.chatMessages).go();

  // --- Talking to the proxy ------------------------------------------------

  /// Streams a reply for [userText], given the prior [history] (already
  /// excluding the in-flight turn). System prompt is added server-side.
  Stream<CompanionEvent> send({
    required CompanionConfig config,
    required List<CompanionMessage> history,
    required String userText,
  }) async* {
    final turns = <CompanionMessage>[
      ...history,
      CompanionMessage(
        role: ChatRole.user,
        text: userText,
        createdAt: DateTime.now(),
      ),
    ];
    final windowed = turns.length > _historyWindow
        ? turns.sublist(turns.length - _historyWindow)
        : turns;

    yield* _client.send(
      baseUrl: config.baseUrl,
      token: config.token,
      userId: await userId(),
      messages: _normalize(windowed),
    );
  }

  /// Coerces the turns into what the Messages API requires: a list that starts
  /// with a user turn and strictly alternates user/assistant. Consecutive
  /// same-role turns (which can happen after a failed send left a dangling user
  /// message) are merged rather than dropped, so no context is lost.
  List<Map<String, String>> _normalize(List<CompanionMessage> turns) {
    final out = <Map<String, String>>[];
    for (final m in turns) {
      if (m.text.trim().isEmpty) continue;
      final role = m.role.name;
      if (out.isNotEmpty && out.last['role'] == role) {
        out.last['content'] = '${out.last['content']}\n\n${m.text}';
      } else {
        out.add({'role': role, 'content': m.text});
      }
    }
    while (out.isNotEmpty && out.first['role'] != ChatRole.user.name) {
      out.removeAt(0);
    }
    return out;
  }
}
