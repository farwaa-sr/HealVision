import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healvision/utilis/constants/colors.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting

import '../../../therapist_home/controller/monitiring_process_controller.dart';
import '../view_appointment.dart';

class HealthTrackerDetailsPage extends StatelessWidget {
  final String userId;

  const HealthTrackerDetailsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MonitiringProcessController());
    controller.fetchHealthAssessmentData(userId);

    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: Colors.green[50],
        title: Text(
          'Health Tracker Details',
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Obx(() {
        final healthData = controller.healthAssessmentData.value;

        if (controller.isLoadinghealth.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (healthData.moodAssessment.isEmpty) {
          return const Center(
            child: Text("No health tracker data found."),
          );
        }

        final formattedDate =
            DateFormat('dd-MM-yyyy').format(healthData.timestamp.toDate());
        final formattedTime =
            DateFormat('hh:mm a').format(healthData.timestamp.toDate());

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomTextLabel(
                label: 'Date: $formattedDate at $formattedTime',
                textalign: TextAlign.center,
                fontweight: FontWeight.bold,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _buildCard('Mood Assessment', healthData.moodAssessment),
                    _buildCard('Physical Distress Assessment',
                        healthData.physicalDistressAssessment),
                    _buildCard('Sleep Quality Assessment',
                        healthData.sleepQualityAssessment),
                    _buildCard('Stress Level Assessment',
                        healthData.stressLevelAssessment),
                    _buildSubstanceUseDataCard('Substance Use Data',
                        healthData.substanceUseData.substances),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Card _buildCard(String title, Map<String, dynamic> data) {
    // Extract question and answer from the map
    String question = data['question'] ?? '';
    String answer = data['answer'] ?? '';

    return Card(
      color: WColors.primary,
      elevation: 5,
      shadowColor: Colors.grey.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextLabel(
              label: title,
              textcolor: WColors.white,
              fontsize: 18,
              fontweight: FontWeight.bold,
            ),
            const SizedBox(height: 10),
            CustomTextLabel(
              label: 'Q: $question', // Display question prefixed with 'Q:'
              textcolor: WColors.white,
              fontweight: FontWeight.w500,
              fontsize: 16,
            ),
            const SizedBox(height: 10),
            CustomTextLabel(
              label: 'Answer: $answer', // Display answer prefixed with 'A:'
              textcolor: WColors.white,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Card _buildSubstanceUseDataCard(
      String title, List<Map<String, dynamic>> substances) {
    return Card(
      color: WColors.primary,
      elevation: 5,
      shadowColor: Colors.grey.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextLabel(
              label: title,
              textcolor: WColors.white,
              fontsize: 18,
              fontweight: FontWeight.bold,
            ),
            const SizedBox(height: 10),
            ...substances.map((substance) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextLabel(
                    label: 'Substance: ${substance['name']}',
                    textcolor: WColors.white,
                    fontsize: 16,
                  ),
                  CustomTextLabel(
                    label: 'Amount: ${substance['amount']}',
                    textcolor: WColors.white,
                    fontsize: 16,
                  ),
                  CustomTextLabel(
                    label: 'Date: ${substance['date']}',
                    textcolor: WColors.white,
                    fontsize: 16,
                  ),
                  CustomTextLabel(
                    label: 'Time: ${substance['time']}',
                    textcolor: WColors.white,
                    fontsize: 16,
                  ),
                  CustomTextLabel(
                    label: 'Reason: ${substance['reason']}',
                    textcolor: WColors.white,
                    fontsize: 16,
                  ),
                  const SizedBox(height: 10),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
