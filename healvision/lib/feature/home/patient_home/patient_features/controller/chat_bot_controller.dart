import 'dart:convert';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:http/http.dart' as http;

import '../../../../../data/repositories/chatbot/chat_bot_repoistory.dart';
import '../../../../personalization/controllers/user_controller.dart';
import '../../../model/chat_bot_model.dart';


class ChatBotController extends GetxController {
  static ChatBotController get to => Get.find();

  final userController = Get.put(UserController());
  final chatrepository = Get.put(ChatBotRepository());
  final Gemini gemini = Gemini.instance;
  RxBool isLoading = false.obs;
  //RxBool isLoadingpredication = false.obs;
  final String baseUrl = 'https://3d66-111-68-97-146.ngrok-free.app';

  late String userId;
  late String userName;

  // Getter and setter for hideUserName
  final _hideUserName = false.obs;
  bool get hideUserName => _hideUserName.value;
  set hideUserName(bool value) => _hideUserName.value = value;

  late ChatUser currentUser;
  ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "healvision",
    profileImage:
        "https://seeklogo.com/images/G/google-gemini-logo-A5787B2669-seeklogo.com.png",
  );

  RxList<ChatMessage> messages = RxList<ChatMessage>();
  //RxList<PredictionMessage> predictionMessages = RxList<PredictionMessage>();

  @override
  void onInit() {
    // Initialize userId and userName from UserController
    userId = userController.user.value.id;
    userName = userController.user.value.fullname;

    // Initialize currentUser after getting userId and userName
    currentUser = ChatUser(id: userId, firstName: userName);

    // Fetch previous chat messages
    fetchMessages(userId);

    super.onInit();
  }


  void fetchMessages(String userId) {
    isLoading.value = true;
    chatrepository.fetchUserChatMessages(userId).listen((fetchedMessages) {
      messages.assignAll(fetchedMessages
          .map((msg) => ChatMessage(
                user: msg.senderId == userId ? currentUser : geminiUser,
                createdAt: msg.createdAt,
                text: msg.text,
                customProperties: {'id': msg.id,'prediction': msg.predication,},
              ))
          .toList());
      isLoading.value = false;
      update();
    });
  }

  // Function to send a message
  void sendMessage(ChatMessage chatMessage) async {
    messages.insert(0, chatMessage);
    update();

    // Predict emotion and await the response
    String emotion = await predictMessage(chatMessage.text);

    // Save the user message to Firestore
    final ChatBotMessage userMessage = ChatBotMessage(
      id: chatMessage.customProperties?['id'] ?? UniqueKey().toString(),
      senderId: chatMessage.user.id,
      text: chatMessage.text,
      predication: emotion,
      createdAt: chatMessage.createdAt,
    );

    await chatrepository.saveChatMessage(userId, userMessage);

    try {
      // Add a placeholder message with a loading indicator
      ChatMessage loadingMessage = ChatMessage(
        user: geminiUser,
        createdAt: DateTime.now(),
        text: '...', // Placeholder text for loading
        customProperties: {'id': UniqueKey().toString()},
      );
      messages.insert(0, loadingMessage);
      update();

      String question = chatMessage.text;

      gemini.text(question).then((value) async {
        String response = value!.content?.parts?.fold(
                "", (previous, current) => "$previous ${current.text}") ??
            "";

        response = _removeMarkdown(response);

        // Remove the loading message
        messages.removeAt(0);

        ChatMessage newMessage = ChatMessage(
          user: geminiUser,
          createdAt: DateTime.now(),
          text: response,
          customProperties: {'id': UniqueKey().toString()},
        );
        messages.insert(0, newMessage);
        update();

        // Save the new Gemini message to Firestore
        final ChatBotMessage newFirestoreMessage = ChatBotMessage(
          id: newMessage.customProperties?['id'] ?? UniqueKey().toString(),
          senderId: newMessage.user.id,
          text: newMessage.text,
          predication: '',
          createdAt: newMessage.createdAt,
        );
        await chatrepository.saveChatMessage(userId, newFirestoreMessage);
      });
    } catch (e) {
      //print('Error sending message: $e');
    }
  }

  // Function to remove markdown formatting (**text**)
  String _removeMarkdown(String text) {
    return text.replaceAll(RegExp(r'\*\*'), ''); // Remove ** from the text
  }

  Future<String> predictMessage(String message) async {
    final url = Uri.parse('$baseUrl/predict-emotion');
    try {
      final response = await http.post(
        url,
        body: jsonEncode({'text': message}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['emotion'];
      } else {
        //print('Failed with status code: ${response.statusCode}');
        //print('Failed with body: ${response.body}');
        throw Exception(
            'Failed to get prediction from API: Status code ${response.statusCode}');
      }
    } catch (e) {
      //print('Exception caught: $e');
      throw Exception('Failed to connect to API: $e');
    }
  }
}
 