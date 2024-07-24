import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:healvision/feature/home/patient_home/patient_features/view_appointment.dart';
import 'package:healvision/utilis/constants/colors.dart';

import 'package:readmore/readmore.dart';

import '../../../therapist_home/model/therapist_model.dart';
import '../widgets/assesment_widget.dart';
import 'appointment_book_screen.dart';

class DoctorDetailsScreen extends StatelessWidget {
  const DoctorDetailsScreen({super.key, required this.doctor});
  final TherapistModel doctor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: WColors.white,
        centerTitle: true,
        title: Text(
          'Doctor Details',
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Card(
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          doctor.image,
                          height: 70,
                          width: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextLabel(
                              label: doctor.doctorName,
                              fontweight: FontWeight.bold,
                              fontsize: 18.0,
                              textcolor: WColors.white,
                            ),
                            CustomTextLabel(
                              label: doctor.specialty,
                              textcolor: WColors.white,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.location_on,
                                    size: 16, color: Colors.white),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: CustomTextLabel(
                                    label: doctor.location,
                                    textcolor: WColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Column(
                  children: [
                    Icon(
                      Icons.groups,
                      color: Colors.black,
                      size: 40,
                    ),
                    SizedBox(height: 8.0),
                    CustomTextLabel(
                      label: '200+ Patients',
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Icon(
                      Icons.timelapse_outlined,
                      color: Colors.black,
                      size: 40,
                    ),
                    const SizedBox(height: 8.0),
                    CustomTextLabel(
                      label: '${doctor.experience} year experience',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            const CustomTextLabel(
              label: 'About me',
              fontweight: FontWeight.bold,
              fontsize: 20.0,
            ),
            const SizedBox(height: 8.0),
            ReadMoreText(
              doctor.aboutMe,
              trimLines: 2,
              trimMode: TrimMode.Line,
              trimCollapsedText: 'View More',
              trimExpandedText: 'Less',
              moreStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
              lessStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10.0),
            const CustomTextLabel(
              label: 'Working Time',
              fontweight: FontWeight.bold,
              fontsize: 20.0,
            ),
            const SizedBox(height: 8.0),
            CustomTextLabel(
              label: doctor.workingTime,
            ),
            const Spacer(),
            CustomButtonNext(
              title: 'Book Appointment',
              visble: false,
              onpressed: () {
                Get.to(BookingScreen(doctor: doctor,));
              },
            ),
            const SizedBox(height: 18.0),
          ],
        ),
      ),
    );
  }
}
