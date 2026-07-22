import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// An event streamed back from a companion request.
sealed class CompanionEvent {
  const CompanionEvent();
}

/// A chunk of assistant text to append.
class CompanionDelta extends CompanionEvent {
  const CompanionDelta(this.text);
  final String text;
}

/// The reply finished. [crisis] mirrors the backend's crisis flag.
class CompanionDone extends CompanionEvent {
  const CompanionDone({required this.crisis});
  final bool crisis;
}

/// Something went wrong. [message] is safe, human-readable (never raw content).
class CompanionError extends CompanionEvent {
  const CompanionError(this.message);
  final String message;
}

/// Talks to OUR backend proxy only — never directly to Anthropic. The proxy
/// holds the API key, injects the system prompt, rate-limits, and runs the
/// authoritative crisis check. This client just forwards the conversation and
/// renders whatever the proxy streams back.
///
/// It accepts either response style, so it works against a range of backends:
///   • `text/event-stream` — Server-Sent Events, streamed token by token.
///     Understands our simple `{"text": "..."}` / `{"crisis": bool}` events and
///     a raw Anthropic passthrough (`content_block_delta` / `message_stop`).
///   • `application/json` — a single `{"text": "...", "crisis": bool}` body,
///     revealed progressively for a calm, human feel.
class CompanionApiClient {
  CompanionApiClient([http.Client? client]) : _client = client ?? http.Client();

  final http.Client _client;

  Stream<CompanionEvent> send({
    required String baseUrl,
    required String token,
    required String userId,
    required List<Map<String, String>> messages,
  }) async* {
    final http.StreamedResponse response;
    try {
      final request = http.Request('POST', _endpoint(baseUrl))
        ..headers['authorization'] = 'Bearer $token'
        ..headers['content-type'] = 'application/json'
        ..headers['accept'] = 'text/event-stream'
        ..body = jsonEncode({'userId': userId, 'messages': messages});
      response = await _client.send(request);
    } catch (_) {
      yield const CompanionError(
        "I couldn't reach the server. Check your connection and try again.",
      );
      return;
    }

    final status = response.statusCode;
    if (status == 401 || status == 403) {
      await response.stream.drain<void>();
      yield const CompanionError(
        'The companion is not authorized. Check the access token in settings.',
      );
      return;
    }
    if (status == 429) {
      await response.stream.drain<void>();
      yield const CompanionError(
        "We've been chatting a lot — let's take a short breather and try again "
        'in a minute.',
      );
      return;
    }
    if (status >= 400) {
      await response.stream.drain<void>();
      yield const CompanionError(
        'The server had trouble responding. Please try again shortly.',
      );
      return;
    }

    final contentType = (response.headers['content-type'] ?? '').toLowerCase();

    if (contentType.contains('application/json') &&
        !contentType.contains('event-stream')) {
      yield* _handleJson(response);
    } else {
      yield* _handleSse(response);
    }
  }

  // --- JSON: one body, revealed progressively for a gentle "typing" feel. ---
  Stream<CompanionEvent> _handleJson(http.StreamedResponse response) async* {
    final body = await response.stream.bytesToString();
    Map<String, dynamic> json;
    try {
      json = jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      yield const CompanionError(
        'The server sent something unexpected. Please try again.',
      );
      return;
    }
    final text = (json['text'] ?? json['reply'] ?? json['content'] ?? '')
        .toString();
    final crisis = json['crisis'] == true;

    for (final chunk in _wordChunks(text)) {
      yield CompanionDelta(chunk);
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
    yield CompanionDone(crisis: crisis);
  }

  // --- SSE: stream text as it arrives. ---
  Stream<CompanionEvent> _handleSse(http.StreamedResponse response) async* {
    var crisis = false;
    var currentEvent = '';

    final lines = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in lines) {
      if (line.isEmpty) {
        currentEvent = '';
        continue;
      }
      if (line.startsWith('event:')) {
        currentEvent = line.substring(6).trim();
        continue;
      }
      if (!line.startsWith('data:')) continue;

      final payload = line.substring(5).trim();
      if (payload.isEmpty) continue;
      if (payload == '[DONE]') {
        yield CompanionDone(crisis: crisis);
        return;
      }

      Map<String, dynamic>? data;
      try {
        data = jsonDecode(payload) as Map<String, dynamic>;
      } catch (_) {
        data = null;
      }
      if (data == null) continue;

      if (data['crisis'] is bool) crisis = data['crisis'] as bool;

      if (currentEvent == 'error') {
        yield CompanionError(
          (data['message'] ?? 'The server reported an error.').toString(),
        );
        return;
      }

      final type = data['type'];
      if (type == 'content_block_delta') {
        // Raw Anthropic passthrough.
        final delta = data['delta'];
        final text = delta is Map ? delta['text'] : null;
        if (text is String && text.isNotEmpty) yield CompanionDelta(text);
        continue;
      }
      if (type == 'message_stop' || currentEvent == 'done') {
        yield CompanionDone(crisis: crisis);
        return;
      }
      if (data['text'] is String) {
        final text = data['text'] as String;
        if (text.isNotEmpty) yield CompanionDelta(text);
      }
    }

    // Stream closed without an explicit done — treat as finished.
    yield CompanionDone(crisis: crisis);
  }

  Uri _endpoint(String baseUrl) {
    var base = baseUrl.trim();
    while (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    // Let the user paste either the root or the full /chat URL.
    if (!base.endsWith('/chat')) base = '$base/chat';
    return Uri.parse(base);
  }

  /// Splits text into small chunks (keeping trailing spaces) for a progressive
  /// reveal that reads like natural typing.
  Iterable<String> _wordChunks(String text) sync* {
    if (text.isEmpty) return;
    final matches = RegExp(r'\S+\s*').allMatches(text);
    if (matches.isEmpty) {
      yield text;
      return;
    }
    for (final m in matches) {
      yield m.group(0)!;
    }
  }

  void dispose() => _client.close();
}
