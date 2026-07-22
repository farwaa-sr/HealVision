import 'package:cloud_functions/cloud_functions.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:get/get.dart';

import '../../../../../data/repositories/chatbot/chat_bot_repoistory.dart';
import '../../../../personalization/controllers/user_controller.dart';
import '../../../model/chat_bot_model.dart';

/// Recovery chatbot backed by Claude via the `claudeChat` Firebase Cloud
/// Function. The Anthropic API key stays server-side — never in the app.
class ChatBotController extends GetxController {
  static ChatBotController get to => Get.find();

  final userController = Get.put(UserController());
  final chatrepository = Get.put(ChatBotRepository());
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'us-central1');

  RxBool isLoading = false.obs;

  late String userId;
  late String userName;

  // Getter and setter for hideUserName
  final _hideUserName = false.obs;
  bool get hideUserName => _hideUserName.value;
  set hideUserName(bool value) => _hideUserName.value = value;

  late ChatUser currentUser;
  ChatUser healUser = ChatUser(
    id: "1",
    firstName: "HealVision",
  );

  RxList<ChatMessage> messages = RxList<ChatMessage>();

  @override
  void onInit() {
    userId = userController.user.value.id;
    userName = userController.user.value.fullname;
    currentUser = ChatUser(id: userId, firstName: userName);
    fetchMessages(userId);
    super.onInit();
  }

  void fetchMessages(String userId) {
    isLoading.value = true;
    chatrepository.fetchUserChatMessages(userId).listen((fetchedMessages) {
      messages.assignAll(fetchedMessages
          .map((msg) => ChatMessage(
                user: msg.senderId == userId ? currentUser : healUser,
                createdAt: msg.createdAt,
                text: msg.text,
                customProperties: {'id': msg.id},
              ))
          .toList());
      isLoading.value = false;
      update();
    });
  }

  // Send a message: persist it, ask Claude, persist and show the reply.
  void sendMessage(ChatMessage chatMessage) async {
    messages.insert(0, chatMessage);
    update();

    // Save the user message to Firestore.
    final ChatBotMessage userMessage = ChatBotMessage(
      id: chatMessage.customProperties?['id'] ?? UniqueKey().toString(),
      senderId: chatMessage.user.id,
      text: chatMessage.text,
      predication: '',
      createdAt: chatMessage.createdAt,
    );
    await chatrepository.saveChatMessage(userId, userMessage);

    // Placeholder while we wait for Claude.
    ChatMessage loadingMessage = ChatMessage(
      user: healUser,
      createdAt: DateTime.now(),
      text: '...',
      customProperties: {'id': UniqueKey().toString()},
    );
    messages.insert(0, loadingMessage);
    update();

    try {
      final reply = await _askClaude(chatMessage.text);

      messages.removeAt(0); // remove the placeholder

      final ChatMessage newMessage = ChatMessage(
        user: healUser,
        createdAt: DateTime.now(),
        text: reply,
        customProperties: {'id': UniqueKey().toString()},
      );
      messages.insert(0, newMessage);
      update();

      final ChatBotMessage botMessage = ChatBotMessage(
        id: newMessage.customProperties?['id'] ?? UniqueKey().toString(),
        senderId: newMessage.user.id,
        text: newMessage.text,
        predication: '',
        createdAt: newMessage.createdAt,
      );
      await chatrepository.saveChatMessage(userId, botMessage);
    } catch (e) {
      messages.removeAt(0); // remove the placeholder
      messages.insert(
        0,
        ChatMessage(
          user: healUser,
          createdAt: DateTime.now(),
          text: "I'm having trouble responding right now. Please try again.",
          customProperties: {'id': UniqueKey().toString()},
        ),
      );
      update();
    }
  }

  // Calls the `claudeChat` callable, sending recent history for context.
  Future<String> _askClaude(String message) async {
    // Build history (oldest first), excluding the just-inserted user message
    // and any placeholder, capped to the last ~12 turns for context.
    final history = messages
        .where((m) => m.text != '...' && m.text != message)
        .toList()
        .reversed
        .map((m) => {
              'role': m.user.id == userId ? 'user' : 'assistant',
              'text': m.text,
            })
        .toList();
    final recent =
        history.length > 12 ? history.sublist(history.length - 12) : history;

    final callable = _functions.httpsCallable('claudeChat');
    final result = await callable.call<Map<String, dynamic>>({
      'message': message,
      'history': recent,
    });
    final reply = (result.data['reply'] as String?)?.trim() ?? '';
    return reply.isEmpty ? "I'm here with you. Tell me more." : reply;
  }
}
