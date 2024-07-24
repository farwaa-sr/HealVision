import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healvision/feature/home/patient_home/patient_features/view_appointment.dart';
import 'package:healvision/utilis/constants/colors.dart';
import 'package:intl/intl.dart';

import '../../../therapist_home/controller/monitiring_process_controller.dart';

class HealthAssessmentDetailsPage extends StatelessWidget {
  final String userId;

  const HealthAssessmentDetailsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MonitiringProcessController());
    controller.fetchAssessmentResults(userId);
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: Colors.green[50],
        title: Text(
          'Health Assessment Details',
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Obx(() {
        final assessmentResults = controller.assessmentResults.value;

        if (controller.isLoadingassesment.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (assessmentResults.answers.isEmpty) {
          return const Center(child: Text("No assessment results found."));
        }

        final formattedDate = DateFormat('dd-MM-yyyy')
            .format(assessmentResults.timestamp.toDate());
        final formattedTime =
            DateFormat('hh:mm a').format(assessmentResults.timestamp.toDate());

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CustomTextLabel(
                label: 'Total Score',
                textalign: TextAlign.center,
                fontsize: 26,
                fontweight: FontWeight.bold,
              ),
              CustomTextLabel(
                label: assessmentResults.totalScore.toString(),
                textalign: TextAlign.center,
                fontsize: 24,
                fontweight: FontWeight.bold,
              ),
              const SizedBox(height: 10),
              CustomTextLabel(
                label: 'Date: $formattedDate at $formattedTime',
                textalign: TextAlign.center,
                fontweight: FontWeight.bold,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: assessmentResults.answers.length,
                  itemBuilder: (context, index) {
                    final answer = assessmentResults.answers[index];
                    return Card(
                      elevation: 5,
                      color: WColors.primary,
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
                              label: 'Q${index + 1}: ${answer.question}',
                              fontsize: 16,
                              textcolor: WColors.white,
                              fontweight: FontWeight.w500,
                            ),
                            const SizedBox(height: 10),
                            CustomTextLabel(
                              label: 'Answer: ${answer.selectedOption}',
                              textcolor: WColors.white,
                              fontweight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
