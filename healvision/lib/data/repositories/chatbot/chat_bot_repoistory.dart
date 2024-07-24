import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../../../feature/home/model/chat_bot_model.dart';
import '../../../utilis/exceptions/firebase_exceptions.dart';
import '../../../utilis/exceptions/format_exceptions.dart';
import '../../../utilis/exceptions/platform_exceptions.dart';

class ChatBotRepository {
  static ChatBotRepository get instance => ChatBotRepository();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Function to save a chat message to Firestore
  Future<void> saveChatMessage(String userId, ChatBotMessage message) async {
    try {
      await _db
          .collection("chats")
          .doc(userId)
          .collection("messages")
          .add(message.toJson());
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Function to save a Predication message to Firestore
  // Future<void> savePredictionMessage(
  //     String userId, PredictionMessage message) async {
  //   try {
  //     await _db
  //         .collection("chats")
  //         .doc(userId)
  //         .collection("predication")
  //         .add(message.toJson());
  //   } on FirebaseException catch (e) {
  //     throw TFirebaseException(e.code).message;
  //   } on FormatException catch (_) {
  //     throw const TFormatException();
  //   } on PlatformException catch (e) {
  //     throw TPlatformException(e.code).message;
  //   } catch (e) {
  //     throw 'Something went wrong. Please try again';
  //   }
  // }

  // Function to fetch chat messages for a specific user
  Stream<List<ChatBotMessage>> fetchUserChatMessages(String userId) {
    try {
      return _db
          .collection("chats")
          .doc(userId)
          .collection("messages")
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ChatBotMessage.fromSnapshot(doc))
              .toList());
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Function to fetch chat messages for a specific user
  // Stream<List<PredictionMessage>> fetchPredicationMessages(String userId) {
  //   try {
  //     return _db
  //         .collection("chats")
  //         .doc(userId)
  //         .collection("predication")
  //         .orderBy('createdAt', descending: true)
  //         .snapshots()
  //         .map((snapshot) => snapshot.docs
  //             .map((doc) => PredictionMessage.fromSnapshot(doc))
  //             .toList());
  //   } on FirebaseException catch (e) {
  //     throw TFirebaseException(e.code).message;
  //   } on FormatException catch (_) {
  //     throw const TFormatException();
  //   } on PlatformException catch (e) {
  //     throw TPlatformException(e.code).message;
  //   } catch (e) {
  //     throw 'Something went wrong. Please try again';
  //   }
  // }
}
