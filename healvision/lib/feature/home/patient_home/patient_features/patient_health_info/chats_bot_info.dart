import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:readmore/readmore.dart';

import '../../../../../utilis/constants/colors.dart';
import '../controller/chat_bot_controller.dart';


class ChatBotDetailsPage extends StatelessWidget {
  final String userId;

  const ChatBotDetailsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatBotController());

    // Fetch messages for the specific user ID when the page is built
    controller.fetchMessages(userId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: WColors.white,
        centerTitle: true,
        title: Text(
          'Chat Bot Details',
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Obx(() {
        final chatsData = controller.messages;

        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (chatsData.isEmpty) {
          return const Center(
            child: Text("No Chats data found."),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView.builder(
            itemCount: chatsData.length,
            itemBuilder: (context, index) {
              final message = chatsData[index];

              return _defaultMessageRow(message, controller);
            },
          ),
        );
      }),
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
            if (!isGemini)
              Text(
                ' ${message.customProperties?['prediction'] ?? ''}',
                style: TextStyle(
                  
                  color: isGemini ? Colors.black : Colors.white,
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
