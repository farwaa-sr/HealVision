import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';

import '../../../../../utilis/constants/colors.dart';
import '../controller/chat_bot_controller.dart';

class ChatBotScreen extends StatelessWidget {
  const ChatBotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatBotController());
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: WColors.primary,
        title: Text(
          'Chat Bot',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: _buildUI(controller),
    );
  }

  Widget _buildUI(ChatBotController controller) {
    return GetBuilder<ChatBotController>(
      builder: (controller) {
        return Stack(
          children: [
            DashChat(
              inputOptions: InputOptions(
                alwaysShowSend: true,
                autocorrect: true,
                sendButtonBuilder: (void Function() send) {
                  return IconButton(
                    icon: const Icon(Icons.send, color: WColors.primary),
                    onPressed: send,
                  );
                },
                inputTextStyle: const TextStyle(color: WColors.textPrimary),
                inputDecoration: const InputDecoration(
                  hintText: 'Enter Message here...',
                  hintStyle: TextStyle(color: WColors.darkGrey, fontSize: 14),
                ),
              ),
              messageOptions: MessageOptions(
                currentUserTextColor: Colors.white,
                currentUserContainerColor: WColors.primary,
                showTime: true,
                timeFormat: DateFormat('hh:mm a'),
                userNameBuilder: (ChatUser user) {
                  return Text(
                    user.firstName.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: user.id == controller.currentUser.id
                          ? Colors.grey[600]
                          : Colors.grey[800],
                    ),
                  );
                },
                messageRowBuilder: (ChatMessage message,
                    ChatMessage? previousMessage,
                    ChatMessage? nextMessage,
                    bool isAfterDateSeparator,
                    bool isBeforeDateSeparator) {
                  if (message.text == '...' && message.user.id == '1') {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 10),
                          Text("healvision is typing..."),
                        ],
                      ),
                    );
                  }
                  // Default message row widget
                  return _defaultMessageRow(message, controller);
                },
              ),
              currentUser: controller.currentUser,
              onSend: controller.sendMessage,
              messages: controller.messages,
            ),
          ],
        );
      },
    );
  }

  Widget _defaultMessageRow(ChatMessage message, ChatBotController controller) {
    final isGemini = message.user.id == controller.geminiUser.id;
    final alignment =
        isGemini ? CrossAxisAlignment.start : CrossAxisAlignment.end;
    final backgroundColor = isGemini ? Colors.grey.shade200 : WColors.primary;
    return Align(
      alignment: isGemini ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: alignment,
          children: [
            Visibility(
              visible: !controller.hideUserName && isGemini,
              child: Text(
                message.user.firstName!,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 5),
            ReadMoreText(
              message.text,
              style: TextStyle(
                color: isGemini ? Colors.black : Colors.white,
              ),
              trimLines: 4,
              trimMode: TrimMode.Line,
              trimCollapsedText: 'View More',
              trimExpandedText: 'Less',
              moreStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              lessStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              DateFormat('hh:mm a').format(message.createdAt),
              style: TextStyle(
                fontSize: 10,
                color: isGemini ? Colors.black : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
