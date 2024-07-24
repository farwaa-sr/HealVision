import 'package:cloud_firestore/cloud_firestore.dart';

class ChatBotMessage {
  final String id;
  final String senderId;
  final String text;
  final String predication;
  final DateTime createdAt;

  ChatBotMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.predication,
    required this.createdAt,
  });

  // Convert model to JSON for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'text': text,
      'predication': predication,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Factory method to create a ChatMessage from a Firestore document snapshot
  factory ChatBotMessage.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return ChatBotMessage(
      id: snapshot.id,
      senderId: data['senderId'],
      text: data['text'],
      predication: data['predication'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Factory method to create a ChatMessage from a Firestore JSON
  factory ChatBotMessage.fromJson(Map<String, dynamic> json, String id) {
    return ChatBotMessage(
      id: id,
      senderId: json['senderId'],
      text: json['text'],
      predication: json['predication'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }
}
