import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../utilis/constants/colors.dart';
import '../../model/appointment_model.dart';
import '../../patient_home/patient_features/patient_health_info/chats_bot_info.dart';
import '../../patient_home/patient_features/patient_health_info/health_assessment_details.dart';
import '../../patient_home/patient_features/patient_health_info/health_tracker_details.dart';
import '../../patient_home/patient_features/view_appointment.dart';
import '../controller/monitiring_process_controller.dart';

class MonitiringProgress extends StatelessWidget {
  const MonitiringProgress({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MonitiringProcessController());
    controller.fetchConfrimAppointments();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: WColors.white,
        centerTitle: true,
        title: Text(
          'Monitoring Progress',
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CustomTextLabel(
              label: 'Keep track of your sessions, patients and more',
              fontsize: 16,
              textalign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // Search Bar
            TextField(
              onChanged: (query) => controller.searchPatients(query),
              decoration: InputDecoration(
                hintText: 'Search Patients',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: WColors.confirm),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: WColors.confirm),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: WColors.darkGrey),
                ),
                filled: true,
                fillColor: WColors.white,
              ),
            ),
            const SizedBox(height: 10),
            Obx(() {
              if (controller.isLoading.value) {
                return const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (controller.filteredappointment.isEmpty) {
                return const Expanded(
                  child: Center(
                    child: Text(
                      'No patient records found.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              } else {
                return Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 20,
                    ),
                    itemCount: controller.filteredappointment.length,
                    itemBuilder: (context, index) {
                      AppointmentModel appointment =
                          controller.filteredappointment[index];

                      return PatientRecordCard(
                        appointment: appointment,
                        userid: appointment.userId,
                      );
                    },
                  ),
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}

class PatientRecordCard extends StatelessWidget {
  const PatientRecordCard({
    super.key,
    required this.appointment,
    required this.userid,
  });
  final String userid;
  final AppointmentModel appointment;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: WColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextLabel(
                    label: appointment.userName,
                    fontweight: FontWeight.bold,
                    fontsize: 18.0,
                    textcolor: WColors.white,
                  ),
                  CustomTextLabel(
                    label: appointment.userEmail,
                    textcolor: WColors.white,
                  ),
                  CustomTextLabel(
                    label: appointment.userPhoneNumber,
                    textcolor: WColors.white,
                  ),
                  CustomTextLabel(
                    label:
                        'Apponitment Date: ${appointment.date.toIso8601String().split('T').first}',
                    textcolor: WColors.white,
                  ),
                  CustomTextLabel(
                    label: 'Apponitment Time: ${appointment.time}',
                    textcolor: WColors.white,
                  ),
                  CustomTextLabel(
                    label: 'Status: ${appointment.appointmentstatus}',
                    textcolor: WColors.white,
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomCardIcon(
                        icon: Icons.health_and_safety,
                        onpressed: () {
                          Get.to(HealthTrackerDetailsPage(userId: userid));
                        },
                      ),
                      const SizedBox(width: 10),
                      CustomCardIcon(
                        icon: Icons.text_snippet,
                        onpressed: () {
                          Get.to(HealthAssessmentDetailsPage(userId: userid));
                        },
                      ),
                      const SizedBox(width: 10),
                      CustomCardIcon(
                        icon: Icons.chat,
                        onpressed: () {
                          Get.to(ChatBotDetailsPage(
                            userId: userid,
                          ));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
