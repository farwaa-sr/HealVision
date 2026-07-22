import '../../../data/local/database.dart';

/// Who said it.
enum ChatRole { user, assistant }

/// A single decrypted message in the companion conversation, plus a little
/// transient UI state ([streaming]/[failed]) that is never persisted.
class CompanionMessage {
  const CompanionMessage({
    required this.role,
    required this.text,
    required this.createdAt,
    this.id,
    this.crisis = false,
    this.streaming = false,
    this.failed = false,
  });

  final int? id;
  final ChatRole role;
  final String text;
  final DateTime createdAt;

  /// Set on an assistant turn the backend (or the local net) flagged as crisis.
  final bool crisis;

  /// True while an assistant reply is still streaming in.
  final bool streaming;

  /// True when the send failed — lets the UI offer a gentle retry.
  final bool failed;

  bool get isUser => role == ChatRole.user;

  CompanionMessage copyWith({
    int? id,
    String? text,
    bool? crisis,
    bool? streaming,
    bool? failed,
  }) {
    return CompanionMessage(
      id: id ?? this.id,
      role: role,
      text: text ?? this.text,
      createdAt: createdAt,
      crisis: crisis ?? this.crisis,
      streaming: streaming ?? this.streaming,
      failed: failed ?? this.failed,
    );
  }

  /// Build from a stored (still-encrypted) row plus its decrypted [text].
  factory CompanionMessage.fromRow(ChatMessage row, String text) {
    return CompanionMessage(
      id: row.id,
      role: row.role == ChatRole.assistant.name
          ? ChatRole.assistant
          : ChatRole.user,
      text: text,
      createdAt: row.createdAt,
      crisis: row.crisis,
    );
  }

  /// The shape the backend proxy expects for each turn (system prompt is added
  /// server-side and is never sent from the client).
  Map<String, String> toWire() => {'role': role.name, 'content': text};
}

/// Where the app should reach the backend proxy, and whether it's ready.
class CompanionConfig {
  const CompanionConfig({required this.baseUrl, required this.token});

  final String baseUrl;
  final String token;

  /// Both pieces present → the companion can talk to the proxy.
  bool get isConfigured => baseUrl.trim().isNotEmpty && token.trim().isNotEmpty;

  static const empty = CompanionConfig(baseUrl: '', token: '');
}

/// Full state of the chat screen.
class ChatState {
  const ChatState({
    required this.messages,
    required this.config,
    this.sending = false,
    this.showCrisis = false,
    this.error,
  });

  final List<CompanionMessage> messages;
  final CompanionConfig config;

  /// A reply is in flight.
  final bool sending;

  /// The crisis resources should be surfaced prominently right now.
  final bool showCrisis;

  /// A non-fatal, human-readable error to surface (e.g. rate limited).
  final String? error;

  ChatState copyWith({
    List<CompanionMessage>? messages,
    CompanionConfig? config,
    bool? sending,
    bool? showCrisis,
    Object? error = _sentinel,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      config: config ?? this.config,
      sending: sending ?? this.sending,
      showCrisis: showCrisis ?? this.showCrisis,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }

  static const _sentinel = Object();
}
