/// Item shown in the dashboard "Today" section — a scheduled replacement
/// activity or a goal due today, with a quick check-off.
enum TodayItemType { activity, goal }

class TodayItem {
  const TodayItem({
    required this.id,
    required this.title,
    required this.type,
    this.time,
    this.done = false,
  });

  final String id;
  final String title;
  final TodayItemType type;
  final String? time;
  final bool done;

  TodayItem copyWith({bool? done}) => TodayItem(
        id: id,
        title: title,
        type: type,
        time: time,
        done: done ?? this.done,
      );
}

/// Everything the Home dashboard needs, in one immutable snapshot. Backed by
/// mock data until the individual feature repositories are built.
class DashboardData {
  const DashboardData({
    required this.userName,
    required this.soberSince,
    required this.moneySaved,
    required this.wellbeing,
    required this.moodTrend,
    required this.today,
    required this.motivation,
    required this.checkinDoneToday,
  });

  final String userName;
  final DateTime soberSince;
  final double moneySaved;

  /// 0–100 wellbeing indicator.
  final int wellbeing;

  /// Last 7 days of mood, each 1 (struggling) … 5 (great).
  final List<int> moodTrend;

  final List<TodayItem> today;
  final String motivation;
  final bool checkinDoneToday;

  Duration get soberDuration => DateTime.now().difference(soberSince);
  int get soberDays => soberDuration.inDays;
  int get soberHours => soberDuration.inHours % 24;

  /// Progress toward the next 30-day milestone (for the centerpiece ring).
  double get milestoneProgress => (soberDays % 30) / 30;

  DashboardData copyWith({List<TodayItem>? today}) => DashboardData(
        userName: userName,
        soberSince: soberSince,
        moneySaved: moneySaved,
        wellbeing: wellbeing,
        moodTrend: moodTrend,
        today: today ?? this.today,
        motivation: motivation,
        checkinDoneToday: checkinDoneToday,
      );

  /// Sensible mock until repositories land.
  factory DashboardData.mock() {
    const motivations = [
      'You showed up today. That counts, even on the ordinary days.',
      'Cravings are waves — they rise, crest, and pass. You don\'t have to fight the ocean, just ride this one out.',
      'Progress isn\'t a straight line. Being here, still trying, is the work.',
      'You\'ve gotten through every hard day so far. That\'s a real track record.',
      'Small steady choices add up to a life. You\'re making them.',
      'Rest is part of recovery, not a break from it.',
      'Whatever today holds, you don\'t have to face it alone.',
    ];
    final now = DateTime.now();
    final motivation =
        motivations[now.difference(DateTime(now.year)).inDays % motivations.length];

    return DashboardData(
      userName: 'Sam',
      soberSince: now.subtract(const Duration(days: 12, hours: 7)),
      moneySaved: 384,
      wellbeing: 72,
      moodTrend: const [3, 4, 3, 2, 4, 5, 4],
      today: const [
        TodayItem(
          id: 't1',
          title: 'Morning walk',
          type: TodayItemType.activity,
          time: '8:00 AM',
        ),
        TodayItem(
          id: 't2',
          title: 'Call a support person',
          type: TodayItemType.activity,
          time: '1:00 PM',
          done: true,
        ),
        TodayItem(
          id: 't3',
          title: 'Journal for 10 minutes',
          type: TodayItemType.goal,
          time: 'Evening',
        ),
      ],
      motivation: motivation,
      checkinDoneToday: false,
    );
  }
}
