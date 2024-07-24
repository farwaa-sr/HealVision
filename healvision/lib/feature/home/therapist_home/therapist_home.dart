import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/widgets/containers/primary_header_container.dart';
import '../../../common/widgets/text/section_heading.dart';
import '../../../utilis/constants/colors.dart';
import '../../../utilis/constants/size.dart';

import '../../personalization/screens/setting/settings.dart';
import '../model/appointment_model.dart';
import '../patient_home/patient_features/view_appointment.dart';
import 'controller/monitiring_process_controller.dart';
import 'home_app_bar.dart';
import 'therapist_features/patient_appointment.dart';

class TherapistHome extends StatelessWidget {
  const TherapistHome({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MonitiringProcessController());
    controller.fetchConfrimAppointments();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: WColors.primary,
        title: Text(
          'Home',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(const SettingScreen());
            },
            icon: const Icon(
              Icons.settings,
              size: 30,
              color: WColors.white,
            ),
          ),
          const SizedBox(
            width: 10,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TPrimaryHeaderContainer(
              child: Column(
                children: [
                  // AppBar
                  const HomeAppBar(),
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      onChanged: (query) => controller.searchPatients(query),
                      decoration: InputDecoration(
                        hintText: 'Search appointments',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: TSizes.spaceBtwSections,
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
              child: Column(
                children: [
                  SectionHeading(
                    title: "Next Appointment",
                    onpressed: () {
                      Get.to(const PatientAppointment());
                    },
                  ),
                  Obx(
                    () => controller.filteredappointment.isEmpty
                        ? const Center(
                            child: Text('No Appointments Found'),
                          )
                        : SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: ListView.separated(
                              shrinkWrap: true,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(
                                height: 20,
                              ),
                              itemCount: controller.filteredappointment.length,
                              itemBuilder: (context, index) {
                                AppointmentModel appointment =
                                    controller.filteredappointment[index];

                                return AppointmentTherapistHomeCard(
                                  controller: controller,
                                  appointment: appointment,
                                );
                              },
                            ),
                          ),
                  ),
                  const SizedBox(
                    height: TSizes.spaceBtwSections,
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

class AppointmentTherapistHomeCard extends StatelessWidget {
  final AppointmentModel appointment;
  final MonitiringProcessController controller;

  const AppointmentTherapistHomeCard(
      {super.key, required this.appointment, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: double.infinity,
        height: 380,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.userName,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const CustomTextLabel(label: 'Patient'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.email),
                      const SizedBox(width: 10),
                      CustomTextLabel(label: appointment.userEmail),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.phone),
                      const SizedBox(width: 10),
                      CustomTextLabel(label: appointment.userPhoneNumber),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CustomTextLabel(
                            label: 'Date',
                            fontweight: FontWeight.w600,
                          ),
                          const SizedBox(height: 5),
                          CustomTextLabel(
                            label: appointment.date
                                .toIso8601String()
                                .split('T')
                                .first,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CustomTextLabel(
                            label: 'Time',
                            fontweight: FontWeight.w600,
                          ),
                          const SizedBox(height: 5),
                          CustomTextLabel(label: appointment.time),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const CustomTextLabel(
                    label: 'Address',
                    fontsize: 16,
                    fontweight: FontWeight.w600,
                  ),
                  const SizedBox(height: 5),
                  CustomTextLabel(
                    label: appointment.therapistlocation,
                    fontsize: 16,
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomCardIcon(
                        icon: Icons.email_outlined,
                        onpressed: () async {
                          Uri emailUri = Uri(
                            scheme: 'mailto',
                            path: appointment.userEmail,
                          );
                          await launchUrl(emailUri);
                        },
                      ),
                      const SizedBox(width: 10),
                      CustomCardIcon(
                        icon: Icons.phone,
                        onpressed: () async {
                          Uri dialnumber = Uri(
                              scheme: 'tel', path: appointment.userPhoneNumber);
                          await launchUrl(dialnumber);
                        },
                      ),
                      const SizedBox(width: 10),
                      CustomCardIcon(
                        icon: Icons.check,
                        onpressed: () {
                          _showUpdateStatusPopup(
                              context, controller, appointment.id.toString());
                        },
                      ),
                    ],
                  ),
                ],
              ),
              _buildStatusBadge(appointment.appointmentstatus),
            ],
          ),
        ),
      ),
    );
  }
}

Positioned _buildStatusBadge(String status) {
  Color backgroundColor;
  Color textColor;

  switch (status) {
    case 'Confirm':
      backgroundColor = WColors.confirm; // Adjust this color
      textColor = WColors.white;
      break;
    case 'Pending':
      backgroundColor = WColors.pending; // Adjust this color
      textColor = WColors.black;
      break;
    case 'Cancel':
      backgroundColor = WColors.cancelled; // Adjust this color
      textColor = WColors.white;
      break;
    case 'Completed':
      backgroundColor = WColors.completed; // Adjust this color
      textColor = WColors.white;
      break;
    default:
      backgroundColor = WColors.darkGrey;
      textColor = WColors.white;
  }

  return Positioned(
    top: 0,
    right: 0,
    child: Container(
      width: 100,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(22)),
      ),
      child: Center(
        child: Text(
          status,
          style: TextStyle(color: textColor),
        ),
      ),
    ),
  );
}

void _showUpdateStatusPopup(BuildContext context,
    MonitiringProcessController controller, String taskId) {
  Get.defaultDialog(
    title: 'Appointment status',
    content: Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                side: const BorderSide(color: WColors.pending),
                backgroundColor: WColors.pending,
                foregroundColor: WColors.black),
            onPressed: () {
              controller.updateTaskStatus(taskId, 'Pending');
              Get.back();
            },
            child: const Text('Pending'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              side: const BorderSide(color: WColors.completed),
              backgroundColor: WColors.completed,
            ),
            onPressed: () {
              controller.updateTaskStatus(taskId, 'Completed');
              Get.back();
            },
            child: const Text('Completed'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              side: const BorderSide(color: WColors.confirm),
              backgroundColor: WColors.confirm,
            ),
            onPressed: () {
              controller.updateTaskStatus(taskId, 'Confirm');
              Get.back();
            },
            child: const Text('Confrim'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              side: const BorderSide(color: WColors.error),
              backgroundColor: WColors.error,
            ),
            onPressed: () {
              controller.updateTaskStatus(taskId, 'Cancel');
              Get.back();
            },
            child: const Text('Cancel'),
          ),
        ),
      ],
    ),
  );
}
