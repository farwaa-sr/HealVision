// import 'package:cloud_firestore/cloud_firestore.dart';

// class PredictionMessage {
//   final String id;
//   final String userId;
//   final String text;
//   final String emotion;
//   final DateTime createdAt;

//   PredictionMessage({
//     required this.id,
//     required this.userId,
//     required this.text,
//     required this.emotion,
//     required this.createdAt,
//   });

//   factory PredictionMessage.fromJson(Map<String, dynamic> json) {
//     return PredictionMessage(
//       id: json['id'],
//       userId: json['userId'],
//       text: json['text'],
//       emotion: json['emotion'],
//       createdAt: (json['createdAt'] as Timestamp).toDate(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'userId': userId,
//       'text': text,
//       'emotion': emotion,
//       'createdAt': Timestamp.fromDate(createdAt),
//     };
//   }

//   // Factory method to create a ChatMessage from a Firestore document snapshot
//   factory PredictionMessage.fromSnapshot(
//       DocumentSnapshot<Map<String, dynamic>> snapshot) {
//     final data = snapshot.data()!;
//     return PredictionMessage(
//       id: snapshot.id,
//       userId: data['userId'],
//       text: data['text'],
//       emotion: data['emotion'],
//       createdAt: (data['createdAt'] as Timestamp).toDate(),
//     );
//   }
// }
