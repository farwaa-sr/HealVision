/// Themes let us gently match a message to how the user is feeling.
enum QuoteTheme {
  hope('Hope'),
  strength('Strength'),
  selfCompassion('Self-compassion'),
  oneDay('One day at a time'),
  honesty('Honesty'),
  connection('Connection');

  const QuoteTheme(this.label);
  final String label;
}

class Quote {
  const Quote(this.id, this.text, this.theme);
  final String id;
  final String text;
  final QuoteTheme theme;
}
