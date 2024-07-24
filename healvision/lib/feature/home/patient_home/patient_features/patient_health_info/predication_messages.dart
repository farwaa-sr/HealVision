// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';

// import '../../../../../utilis/constants/colors.dart';
// import '../../../model/predication_model.dart';
// import '../controller/chat_bot_controller.dart';

// class PredictionMessagesPage extends StatelessWidget {
//   final String userId;

//   const PredictionMessagesPage({super.key, required this.userId});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(ChatBotController());

//     // Fetch prediction messages for the specific user ID when the page is built
//     controller.fetchPredictionMessages(userId);

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: WColors.white,
//         centerTitle: true,
//         title: Text(
//           'Prediction Messages',
//           style: GoogleFonts.urbanist(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//       ),
//       body: Obx(() {
//         final predictionData = controller.predictionMessages;

//         if (controller.isLoadingpredication.value) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (predictionData.isEmpty) {
//           return const Center(
//             child: Text("No Prediction data found."),
//           );
//         }

//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: ListView.builder(
//             itemCount: predictionData.length,
//             itemBuilder: (context, index) {
//               final message = predictionData[index];

//               return _predictionMessageRow(message);
//             },
//           ),
//         );
//       }),
//     );
//   }

//   Widget _predictionMessageRow(PredictionMessage message) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: Colors.grey.shade200,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               message.text,
//               style: const TextStyle(
//                 color: Colors.black,
//               ),
//             ),
//             const SizedBox(height: 5),
//             Text(
//               'Emotion: ${message.emotion}',
//               style: const TextStyle(
//                 color: Colors.black,
//               ),
//             ),
//             const SizedBox(height: 5),
//             Text(
//               DateFormat('hh:mm a').format(message.createdAt),
//               style: const TextStyle(
//                 fontSize: 10,
//                 color: Colors.black,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
