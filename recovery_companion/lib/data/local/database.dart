import 'package:drift/drift.dart';

import 'connection/connection.dart';

part 'database.g.dart';

/// Simple key/value store for app preferences and lightweight state.
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// A substance the user is recovering from. Multiple are allowed.
class Substances extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 60)();

  /// Optional daily cost used to estimate money saved.
  RealColumn get dailyCost => real().withDefault(const Constant(0))();

  /// Highest milestone index already celebrated (so we don't repeat it).
  IntColumn get celebratedMilestoneIndex =>
      integer().withDefault(const Constant(-1))();

  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
}

/// One clean-time attempt (streak). The attempt with a null [endAt] is the
/// current, ongoing one. Attempts are never deleted — total effort stays
/// visible across every attempt.
class Attempts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get substanceId =>
      integer().references(Substances, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get startAt => dateTime()();
  DateTimeColumn get endAt => dateTime().nullable()();
}

/// A logged slip. All reflective fields are optional and skippable — they feed
/// the trigger insights later, but there is never any pressure to fill them in.
class Relapses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get substanceId =>
      integer().references(Substances, #id, onDelete: KeyAction.cascade)();
  IntColumn get attemptId => integer().nullable()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get trigger => text().nullable()();
  TextColumn get feeling => text().nullable()();
  TextColumn get situation => text().nullable()();
  TextColumn get learning => text().nullable()();
}

/// A craving episode the user worked through with the SOS toolkit. Logged so
/// patterns can build over time. All reflective fields are optional.
class Cravings extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get resolvedAt => dateTime().nullable()();

  /// Optional 1–10 intensity.
  IntColumn get intensity => integer().nullable()();

  /// Mood label captured in the "how are you now?" check.
  TextColumn get moodAfter => text().nullable()();

  /// Which tool(s) helped, comma-separated.
  TextColumn get helped => text().nullable()();

  BoolColumn get gotThrough => boolean().withDefault(const Constant(true))();
}

/// A fast daily check-in — the backbone of the app's pattern awareness.
/// Only mood/energy/sleep/craving are core; the rest is optional context.
class CheckIns extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get mood => integer()(); // 1..5
  IntColumn get energy => integer()(); // 1..5
  IntColumn get sleepQuality => integer()(); // 1..5
  IntColumn get cravingLevel => integer()(); // 0..10
  IntColumn get stressLevel => integer().nullable()(); // 0..10
  TextColumn get note => text().nullable()();
  TextColumn get company => text().nullable()(); // who you were with
  TextColumn get place => text().nullable()();
}

/// A craving or trigger logged at any time (not only during a check-in).
class TriggerLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get intensity => integer()(); // 0..10
  TextColumn get trigger => text().nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get actedOn => boolean().withDefault(const Constant(false))();
}

/// A replacement activity in the user's library (built-in or their own).
class Activities extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 80)();
  TextColumn get category => text()(); // ActivityCategory.name
  TextColumn get reason => text().withDefault(const Constant(''))();
  TextColumn get needTags => text().withDefault(const Constant(''))(); // csv
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}

/// An activity the user has planned into their week.
class ScheduledActivities extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get activityId =>
      integer().references(Activities, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get scheduledFor => dateTime()();
  TextColumn get note => text().nullable()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}

/// A completed activity with the mood-before / mood-after feedback that powers
/// personalized "what actually works for me" recommendations.
class ActivityLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get activityId =>
      integer().references(Activities, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get completedAt => dateTime()();
  IntColumn get moodBefore => integer()(); // 1..5
  IntColumn get moodAfter => integer()(); // 1..5
  TextColumn get note => text().nullable()();
}

/// A recovery-oriented goal (abstinence and beyond). Progress comes from its
/// sub-steps; goals with no steps can be completed directly.
class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 120)();
  TextColumn get why => text().nullable()(); // why it matters
  TextColumn get category => text()(); // GoalCategory.name
  DateTimeColumn get targetDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
}

/// A small, achievable sub-step of a goal — small wins build momentum.
class GoalSteps extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get goalId =>
      integer().references(Goals, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
}

/// A trusted person the user can reach in one tap — a sponsor, a friend,
/// family. Surfaced on the SOS screen and in the crisis resources sheet.
/// Multiple are supported; [orderIndex] keeps the user's preferred order.
@DataClassName('SupportContactRow')
class SupportContacts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get phone => text()();

  /// e.g. "Sponsor", "Sister", "Best friend" — optional, shown as a label.
  TextColumn get relationship => text().nullable()();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
}

/// One message in the AI companion conversation. The message body is stored
/// ENCRYPTED at rest ([contentEnc] holds an AES-GCM ciphertext, base64), so a
/// dump of the SQLite file never reveals what was said. Only the app, holding
/// the key in the platform keystore, can read it. See MessageCipher.
class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 'user' or 'assistant' (ChatRole.name).
  TextColumn get role => text()();

  /// AES-GCM ciphertext of the message text, base64-encoded.
  TextColumn get contentEnc => text()();

  DateTimeColumn get createdAt => dateTime()();

  /// True when this assistant turn was flagged by the crisis check.
  BoolColumn get crisis => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [
  AppSettings,
  Substances,
  Attempts,
  Relapses,
  Cravings,
  CheckIns,
  TriggerLogs,
  Activities,
  ScheduledActivities,
  ActivityLogs,
  Goals,
  GoalSteps,
  ChatMessages,
  SupportContacts,
],)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  /// Test/injection constructor.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(substances);
            await m.createTable(attempts);
            await m.createTable(relapses);
          }
          if (from < 3) {
            await m.createTable(cravings);
          }
          if (from < 4) {
            await m.createTable(checkIns);
            await m.createTable(triggerLogs);
          }
          if (from < 5) {
            await m.createTable(activities);
            await m.createTable(scheduledActivities);
            await m.createTable(activityLogs);
          }
          if (from < 6) {
            await m.createTable(goals);
            await m.createTable(goalSteps);
          }
          if (from < 7) {
            await m.createTable(chatMessages);
          }
          if (from < 8) {
            await m.createTable(supportContacts);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
