import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/database_provider.dart';
import '../../../core/providers/secure_store_provider.dart';
import '../data/companion_api_client.dart';
import '../data/companion_repository.dart';
import '../data/message_cipher.dart';
import '../logic/crisis_terms.dart';
import '../model/companion_message.dart';

part 'companion_providers.g.dart';

@Riverpod(keepAlive: true)
MessageCipher messageCipher(MessageCipherRef ref) {
  return MessageCipher(ref.watch(secureStoreProvider));
}

@Riverpod(keepAlive: true)
CompanionApiClient companionApiClient(CompanionApiClientRef ref) {
  final client = CompanionApiClient();
  ref.onDispose(client.dispose);
  return client;
}

@Riverpod(keepAlive: true)
CompanionRepository companionRepository(CompanionRepositoryRef ref) {
  return CompanionRepository(
    db: ref.watch(appDatabaseProvider),
    store: ref.watch(secureStoreProvider),
    cipher: ref.watch(messageCipherProvider),
    client: ref.watch(companionApiClientProvider),
  );
}

/// The chat screen's state + the single entry point for sending a message.
///
/// Streaming updates are applied in place so the reply appears to type itself;
/// the user's turn is persisted immediately, and the finished assistant turn is
/// persisted (encrypted) once complete. Errors degrade to a gentle, retryable
/// bubble rather than throwing.
@riverpod
class Chat extends _$Chat {
  @override
  Future<ChatState> build() async {
    final repo = ref.watch(companionRepositoryProvider);
    final config = await repo.loadConfig();
    final history = await repo.loadHistory();
    return ChatState(messages: history, config: config);
  }

  CompanionRepository get _repo => ref.read(companionRepositoryProvider);

  /// Re-read backend settings after the user edits them.
  Future<void> reloadConfig() async {
    final current = state.valueOrNull;
    if (current == null) return;
    final config = await _repo.loadConfig();
    state = AsyncData(current.copyWith(config: config));
  }

  Future<void> clearConversation() async {
    await _repo.clearHistory();
    final current = state.valueOrNull;
    state = AsyncData(
      ChatState(
        messages: const [],
        config: current?.config ?? CompanionConfig.empty,
      ),
    );
  }

  void dismissCrisis() {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(showCrisis: false));
  }

  Future<void> send(String rawText) async {
    final text = rawText.trim();
    final current = state.valueOrNull;
    if (text.isEmpty || current == null || current.sending) return;
    if (!current.config.isConfigured) return;

    final priorHistory = current.messages;
    final userMsg = await _repo.persist(
      CompanionMessage(
        role: ChatRole.user,
        text: text,
        createdAt: DateTime.now(),
      ),
    );

    await _run(
      priorHistory: priorHistory,
      userMsg: userMsg,
      config: current.config,
    );
  }

  /// Re-runs the last turn after a failed send, without duplicating the user's
  /// message — the failed assistant bubble is dropped and the request retried.
  Future<void> retryLast() async {
    final current = state.valueOrNull;
    if (current == null || current.sending) return;
    final msgs = current.messages;
    if (msgs.length < 2) return;
    final last = msgs.last;
    if (last.role != ChatRole.assistant || !last.failed) return;
    final userMsg = msgs[msgs.length - 2];
    if (userMsg.role != ChatRole.user) return;

    final priorHistory = msgs.sublist(0, msgs.length - 2);
    state = AsyncData(
      current.copyWith(messages: [...priorHistory, userMsg]),
    );
    await _run(
      priorHistory: priorHistory,
      userMsg: userMsg,
      config: current.config,
    );
  }

  Future<void> _run({
    required List<CompanionMessage> priorHistory,
    required CompanionMessage userMsg,
    required CompanionConfig config,
  }) async {
    // Belt-and-suspenders: surface resources on the user's own words too.
    final localCrisis = looksLikeCrisis(userMsg.text);

    final placeholder = CompanionMessage(
      role: ChatRole.assistant,
      text: '',
      createdAt: DateTime.now(),
      streaming: true,
    );

    var working = state.valueOrNull!.copyWith(
      messages: [...priorHistory, userMsg, placeholder],
      sending: true,
      showCrisis: state.valueOrNull!.showCrisis || localCrisis,
      error: null,
    );
    state = AsyncData(working);

    final buffer = StringBuffer();
    var sawCrisis = localCrisis;

    try {
      await for (final event in _repo.send(
        config: config,
        history: priorHistory,
        userText: userMsg.text,
      )) {
        switch (event) {
          case CompanionDelta(:final text):
            buffer.write(text);
            working = working.copyWith(
              messages: _updateLast(
                working.messages,
                (m) => m.copyWith(text: buffer.toString()),
              ),
            );
            state = AsyncData(working);
          case CompanionDone(:final crisis):
            sawCrisis = sawCrisis || crisis;
          case CompanionError(:final message):
            working = working.copyWith(
              messages: _updateLast(
                working.messages,
                (m) => m.copyWith(
                  text: message,
                  streaming: false,
                  failed: true,
                ),
              ),
              sending: false,
              showCrisis: working.showCrisis || sawCrisis,
            );
            state = AsyncData(working);
            return;
        }
      }
    } catch (_) {
      working = working.copyWith(
        messages: _updateLast(
          working.messages,
          (m) => m.copyWith(
            text: 'Something interrupted that. You can try again.',
            streaming: false,
            failed: true,
          ),
        ),
        sending: false,
      );
      state = AsyncData(working);
      return;
    }

    final finalText = buffer.toString().trim();
    if (finalText.isEmpty) {
      working = working.copyWith(
        messages: _updateLast(
          working.messages,
          (m) => m.copyWith(
            text: "I'm here, but I didn't quite catch a reply. Try again?",
            streaming: false,
            failed: true,
          ),
        ),
        sending: false,
        showCrisis: working.showCrisis || sawCrisis,
      );
      state = AsyncData(working);
      return;
    }

    final persisted = await _repo.persist(
      CompanionMessage(
        role: ChatRole.assistant,
        text: finalText,
        createdAt: DateTime.now(),
        crisis: sawCrisis,
      ),
    );
    working = working.copyWith(
      messages: _updateLast(working.messages, (_) => persisted),
      sending: false,
      showCrisis: working.showCrisis || sawCrisis,
    );
    state = AsyncData(working);
  }

  List<CompanionMessage> _updateLast(
    List<CompanionMessage> list,
    CompanionMessage Function(CompanionMessage) update,
  ) {
    if (list.isEmpty) return list;
    final copy = [...list];
    copy[copy.length - 1] = update(copy.last);
    return copy;
  }
}
