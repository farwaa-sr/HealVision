import 'package:cloud_firestore/cloud_firestore.dart';

/// Per-user recovery profile: when they quit and why.
class RecoveryProfile {
  final DateTime? quitDate;
  final String reasons;

  RecoveryProfile({this.quitDate, this.reasons = ''});

  /// Whole days since the quit date (0 if not set).
  int get streakDays {
    if (quitDate == null) return 0;
    final now = DateTime.now();
    final start = DateTime(quitDate!.year, quitDate!.month, quitDate!.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(start).inDays;
    return diff < 0 ? 0 : diff;
  }

  Map<String, dynamic> toJson() => {
        'QuitDate': quitDate != null ? Timestamp.fromDate(quitDate!) : null,
        'Reasons': reasons,
      };

  factory RecoveryProfile.empty() => RecoveryProfile();

  factory RecoveryProfile.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    if (!doc.exists || doc.data() == null) return RecoveryProfile.empty();
    final data = doc.data()!;
    return RecoveryProfile(
      quitDate: (data['QuitDate'] as Timestamp?)?.toDate(),
      reasons: data['Reasons'] ?? '',
    );
  }
}
