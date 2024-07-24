import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healvision/feature/home/patient_home/patient_features/view_appointment.dart';
import 'package:healvision/utilis/constants/colors.dart';

import '../../../../../common/widgets/image/t_circular_image.dart';
import '../../../controller/patient_controller.dart';
import '../../../therapist_home/model/therapist_model.dart';
import 'doctor_details_screen.dart';

class AllDoctorsScreen extends StatelessWidget {
  const AllDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patientController = Get.put(PatientController());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: WColors.white,
        centerTitle: true,
        title: Text(
          'All Therapists',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              onChanged: (query) => patientController.searchDoctors(query),
              decoration: InputDecoration(
                hintText: 'Search doctors',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: WColors.white,
              ),
            ),
            const SizedBox(height: 16),
            // Doctors List
            Expanded(
              child: Obx(() {
                if (patientController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return ListView.builder(
                    itemCount: patientController.filteredTherapists.length,
                    itemBuilder: (context, index) {
                      return DoctorCard(
                          doctor: patientController.filteredTherapists[index]);
                    },
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final TherapistModel doctor;

  const DoctorCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(DoctorDetailsScreen(doctor: doctor));
      },
      child: Card(
        color: WColors.primary,
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 5,
        shadowColor: Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              TCircularimage(
                image: doctor.image,
                width: 90,
                height: 90,
                radius: 16,
                padding: 0,
                isNetwork: true,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextLabel(
                      label: doctor.doctorName,
                      fontsize: 18,
                      textcolor: WColors.white,
                      fontweight: FontWeight.bold,
                    ),
                    CustomTextLabel(
                      label: doctor.specialty,
                      textcolor: WColors.white,
                      fontweight: FontWeight.w400,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.white),
                        const SizedBox(width: 4),
                        Expanded(
                          child: CustomTextLabel(
                            label: doctor.location,
                            textcolor: WColors.white,
                            fontweight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
