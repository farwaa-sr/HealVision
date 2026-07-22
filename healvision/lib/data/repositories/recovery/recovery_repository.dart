import 'package:cloud_firestore/cloud_firestore.dart';

import '../../feature/recovery/models/mood_log.dart';
import '../../feature/recovery/models/recovery_profile.dart';

/// Firestore access for the recovery dashboard:
///   Recovery/{uid}                      -> quit date + reasons
///   Recovery/{uid}/moods/{autoId}       -> mood/craving check-ins
class RecoveryRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('Recovery').doc(uid);

  Future<RecoveryProfile> fetchProfile(String uid) async {
    final snap = await _doc(uid).get();
    return RecoveryProfile.fromSnapshot(snap);
  }

  Future<void> saveProfile(String uid, RecoveryProfile profile) async {
    await _doc(uid).set(profile.toJson(), SetOptions(merge: true));
  }

  Future<void> addMood(String uid, MoodLog log) async {
    await _doc(uid).collection('moods').add(log.toJson());
  }

  Stream<List<MoodLog>> streamMoods(String uid, {int limit = 30}) {
    return _doc(uid)
        .collection('moods')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map((d) => MoodLog.fromSnapshot(d)).toList());
  }
}
