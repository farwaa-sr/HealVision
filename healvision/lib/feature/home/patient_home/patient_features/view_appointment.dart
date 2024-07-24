import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../utilis/constants/colors.dart';
import '../../controller/patient_controller.dart';
import '../../model/appointment_model.dart';

class ViewAppointments extends StatelessWidget {
  const ViewAppointments({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PatientController());
    controller.fetchUserAppointments();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          iconTheme: const IconThemeData(color: WColors.white),
          backgroundColor: WColors.primary,
          title: Text(
            'Appointments',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          bottom: TabBar(
            tabs: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: const Center(child: Tab(text: 'Pending')),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: const Center(child: Tab(text: 'Confirm')),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: const Center(child: Tab(text: 'Complete')),
              ),
            ],
            indicatorWeight: 5,
            labelColor: WColors.confirm,
            unselectedLabelColor: Colors.white,
            indicatorPadding: const EdgeInsets.symmetric(vertical: 8),
            indicator: BoxDecoration(
              color: WColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Obx(
            () => TabBarView(
              children: [
                buildAppointmentList(controller.appointments, 'Pending'),
                buildAppointmentList(controller.appointments, 'Confirm'),
                buildAppointmentList(controller.appointments, 'Completed'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAppointmentList(
      RxList<AppointmentModel> appointments, String status) {
    List<AppointmentModel> filteredAppointments = appointments
        .where((appointment) => appointment.appointmentstatus == status)
        .toList();

    return filteredAppointments.isEmpty
        ? Center(
            child: Text(
              'No $status appointments found',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          )
        : ListView.separated(
            shrinkWrap: true,
            separatorBuilder: (context, index) => const SizedBox(height: 20),
            itemCount: filteredAppointments.length,
            itemBuilder: (context, index) {
              AppointmentModel appointment = filteredAppointments[index];
              return AppointmentTherapistCard(
                appointment: appointment,
                controller: Get.put(PatientController()),
              );
            },
          );
  }
}

class AppointmentTherapistCard extends StatelessWidget {
  const AppointmentTherapistCard(
      {super.key, required this.appointment, required this.controller});
  final AppointmentModel appointment;
  final PatientController controller;

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
      backgroundColor = WColors.confirm;
      textColor = WColors.white;
      break;
    case 'Pending':
      backgroundColor = WColors.pending;
      textColor = WColors.black;
      break;
    case 'Cancel':
      backgroundColor = WColors.cancelled;
      textColor = WColors.white;
      break;
    case 'Completed':
      backgroundColor = WColors.completed;
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

class CustomCardIcon extends StatelessWidget {
  const CustomCardIcon({
    super.key,
    required this.icon,
    required this.onpressed,
  });
  final IconData icon;
  final VoidCallback onpressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WColors.white,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 2,
            spreadRadius: 1,
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onpressed,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 26,
          ),
        ),
      ),
    );
  }
}

class CustomTextLabel extends StatelessWidget {
  const CustomTextLabel({
    super.key,
    required this.label,
    this.fontsize = 14,
    this.fontweight = FontWeight.w400,
    this.textalign = TextAlign.start,
    this.textcolor = WColors.textcolor,
  });
  final String label;
  final double fontsize;
  final FontWeight fontweight;
  final TextAlign textalign;
  final Color textcolor;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: textalign,
      style: GoogleFonts.outfit(
        fontSize: fontsize,
        fontWeight: fontweight,
        color: textcolor,
      ),
    );
  }
}
