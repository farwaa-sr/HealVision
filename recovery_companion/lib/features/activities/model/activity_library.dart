import 'activity_meta.dart';

/// A built-in activity seeded into the library on first launch.
class SeedActivity {
  const SeedActivity(this.title, this.category, this.reason, this.needs);
  final String title;
  final ActivityCategory category;
  final String reason;
  final List<Need> needs;
}

/// The starter library — behavioral activation across every category, each
/// with a short "why this helps". Users can add their own on top of these.
const List<SeedActivity> kActivityLibrary = [
  // Energy / stimulation
  SeedActivity('Go for a run', ActivityCategory.physical,
      'Burns restless energy and floods you with natural endorphins.',
      [Need.energy],),
  SeedActivity('Quick home workout', ActivityCategory.physical,
      'A short burst of movement resets both body and mind.',
      [Need.energy, Need.numbing],),
  SeedActivity('Dance to loud music', ActivityCategory.physical,
      'Moving to music lifts your mood fast — no skill required.',
      [Need.energy, Need.calm],),
  SeedActivity('Cold shower', ActivityCategory.selfCare,
      'A jolt of cold sharpens focus and breaks the craving spell.',
      [Need.energy],),
  SeedActivity('Brisk walk outside', ActivityCategory.nature,
      'Movement plus fresh air is one of the most reliable mood-lifters.',
      [Need.energy, Need.calm, Need.boredom],),

  // Calm / relief
  SeedActivity('Breathwork', ActivityCategory.mindfulness,
      'Slow breathing tells your nervous system that you are safe.',
      [Need.calm],),
  SeedActivity('Gentle yoga', ActivityCategory.physical,
      'Releases the tension your body has been holding.',
      [Need.calm],),
  SeedActivity('Warm bath or shower', ActivityCategory.selfCare,
      'Warmth is soothing and gently signals wind-down.',
      [Need.calm, Need.numbing],),
  SeedActivity('Nature walk', ActivityCategory.nature,
      'Time in green space measurably lowers stress.',
      [Need.calm, Need.boredom],),
  SeedActivity('Mindful body scan', ActivityCategory.mindfulness,
      'Anchors you in the present, away from the urge.',
      [Need.calm],),
  SeedActivity('Journaling', ActivityCategory.creative,
      'Getting it onto paper makes big feelings smaller.',
      [Need.calm, Need.numbing],),

  // Social / connection
  SeedActivity('Call a friend', ActivityCategory.connection,
      'Connection is one of the strongest protectors in recovery.',
      [Need.social, Need.numbing],),
  SeedActivity('Text someone you trust', ActivityCategory.connection,
      'A quick message breaks the isolation a craving thrives on.',
      [Need.social],),
  SeedActivity('Go to a meeting or group', ActivityCategory.social,
      'Being around people who get it makes it lighter.',
      [Need.social, Need.numbing],),
  SeedActivity('Find a sober meetup', ActivityCategory.social,
      'New sober social ties replace the old routines.',
      [Need.social, Need.boredom],),

  // Boredom / creative / productive
  SeedActivity('Start a creative project', ActivityCategory.creative,
      'Making something absorbing fills the space use used to take.',
      [Need.boredom],),
  SeedActivity('Learn something new', ActivityCategory.productive,
      'Curiosity is a surprisingly strong craving distraction.',
      [Need.boredom],),
  SeedActivity('Play an absorbing game', ActivityCategory.creative,
      'A short, immersive game helps you ride out the urge.',
      [Need.boredom],),
  SeedActivity('Cook a proper meal', ActivityCategory.selfCare,
      'Nourishing yourself is both distraction and care.',
      [Need.boredom, Need.numbing],),
  SeedActivity('Tidy one small space', ActivityCategory.productive,
      'A tiny win shifts your whole state.',
      [Need.boredom, Need.energy],),

  // Pain / numbing → gentle care & support
  SeedActivity('A gentle self-care ritual', ActivityCategory.selfCare,
      'Kindness to yourself, where you used to reach for numbing.',
      [Need.numbing, Need.calm],),
  SeedActivity('Reach out for support', ActivityCategory.connection,
      "You don't have to carry hard feelings alone.",
      [Need.numbing],),
  SeedActivity('Rest without guilt', ActivityCategory.selfCare,
      'Sometimes the bravest, most healing thing is simply to rest.',
      [Need.numbing, Need.calm],),
  SeedActivity('Write to your future self', ActivityCategory.creative,
      'Reminds you, in your own words, why this matters.',
      [Need.numbing],),
];
