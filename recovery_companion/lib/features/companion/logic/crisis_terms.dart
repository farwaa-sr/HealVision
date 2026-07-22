/// A small, deliberately conservative on-device crisis screen.
///
/// This is a *safety net*, not the primary mechanism — the backend runs the
/// authoritative check and returns a crisis flag. But running a light check on
/// the user's own words too means resources still surface instantly, even if
/// the network is slow, the reply is delayed, or the backend flag is missed.
///
/// It is intentionally tuned to obvious, high-signal phrases to keep false
/// positives low: it only ever *adds* the crisis resources card, and never
/// blocks or alters the conversation.
library;

/// High-signal phrases suggesting suicide, self-harm, overdose, or immediate
/// danger. Matched case-insensitively as substrings of the normalized text.
const List<String> _crisisPhrases = [
  'kill myself',
  'killing myself',
  'end my life',
  'ending my life',
  'end it all',
  'take my life',
  'want to die',
  'wanna die',
  'wish i was dead',
  'wish i were dead',
  'better off dead',
  'suicidal',
  'suicide',
  'self harm',
  'self-harm',
  'hurt myself',
  'harm myself',
  'cut myself',
  'no reason to live',
  "don't want to be here anymore",
  'dont want to be here anymore',
  "can't go on",
  'cant go on',
  'overdose',
  'overdosed',
  'od on',
  'take the whole bottle',
  'want it to stop',
];

/// Returns true if [text] contains an obvious crisis signal.
bool looksLikeCrisis(String text) {
  final t = text.toLowerCase();
  for (final phrase in _crisisPhrases) {
    if (t.contains(phrase)) return true;
  }
  return false;
}
