import '../model/notification_settings.dart';

/// A ready-to-send notification's text.
class NotifContent {
  const NotifContent(this.title, this.body);
  final String title;
  final String body;
}

/// Warm, human copy for every notification the app sends.
///
/// House rules, enforced by keeping *all* wording here in one place:
/// supportive and hopeful, never nagging, guilt-tripping, or shaming. No
/// "you forgot", no "don't slip", nothing that could land as alarming on a
/// lock screen. Substance names are never mentioned (privacy).
abstract class NotificationCopy {
  static NotifContent _pick(List<NotifContent> pool, int seed) =>
      pool[seed.abs() % pool.length];

  static const _checkIn = [
    NotifContent('A gentle check-in',
        'How are you arriving today? A quiet minute to notice how you feel is plenty. 💛',),
    NotifContent('Checking in',
        'No pressure at all — just a moment for you, whenever it suits.',),
    NotifContent('Here when you are',
        'A quick check-in helps you get to know your own rhythms. Only if you’re up for it.',),
    NotifContent('How’s today feeling?',
        'Whatever the answer is, it’s welcome here. Tap to log a moment for yourself.',),
  ];

  static const _riskNudge = [
    NotifContent('Thinking of you',
        'This can be a tender time of day. Your tools are right here if you want them — and you’re not alone. 💛',),
    NotifContent('A little support',
        'Around now can feel harder. Maybe a walk, a call, or one of your activities? Whatever feels kind.',),
    NotifContent('You’ve got this',
        'A softer stretch might be coming up. However it goes, you’ve made it through before.',),
    NotifContent('Just a warm note',
        'If the next while feels heavy, that’s okay. Be gentle with yourself — support is a tap away.',),
  ];

  static const _milestone = [
    NotifContent('A milestone 🌱',
        'You’ve reached {label} of clean time. That’s real, and it’s yours. Quietly proud of you.',),
    NotifContent('Look how far 🌿',
        '{label} in. That took genuine strength — worth pausing to feel it.',),
  ];

  static const _motivationTitles = [
    'A thought for today',
    'Something to carry with you',
    'A gentle reminder',
  ];

  static NotifContent checkIn(int seed) => _pick(_checkIn, seed);

  static NotifContent riskNudge(int seed) => _pick(_riskNudge, seed);

  static NotifContent activity(String title, {String? note}) {
    final body = (note != null && note.trim().isNotEmpty)
        ? '“$title” is coming up soon — $note'
        : '“$title” is coming up soon. A little pocket of time for you.';
    return NotifContent('Coming up', body);
  }

  static NotifContent milestone(String label, int seed) {
    final t = _pick(_milestone, seed);
    return NotifContent(t.title, t.body.replaceAll('{label}', label));
  }

  static NotifContent motivation(String quote, int seed) =>
      NotifContent(_motivationTitles[seed.abs() % _motivationTitles.length], quote);

  /// A representative sample for the settings-screen preview of each style.
  static NotifContent sampleFor(NotifCategory c) => switch (c) {
        NotifCategory.checkIn => checkIn(0),
        NotifCategory.activities =>
          activity('Evening walk', note: 'you planned this for a reason. 💛'),
        NotifCategory.riskNudges => riskNudge(0),
        NotifCategory.milestones => milestone('1 week', 0),
        NotifCategory.motivation => motivation(
            'A setback is information, not a verdict on who you are. You are not your worst day.',
            0,),
      };
}
