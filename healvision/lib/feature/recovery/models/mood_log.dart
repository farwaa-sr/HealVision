import 'package:cloud_firestore/cloud_firestore.dart';

/// A single daily mood + craving check-in entry.
class MoodLog {
  final String id;
  final String mood; // 'Great' | 'Okay' | 'Low' | 'Struggling'
  final int craving; // 0 (none) .. 10 (intense)
  final String note;
  final DateTime createdAt;

  MoodLog({
    this.id = '',
    required this.mood,
    required this.craving,
    this.note = '',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'mood': mood,
        'craving': craving,
        'note': note,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory MoodLog.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return MoodLog(
      id: doc.id,
      mood: data['mood'] ?? 'Okay',
      craving: (data['craving'] ?? 0) as int,
      note: data['note'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
