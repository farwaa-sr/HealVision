import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healvision/feature/home/patient_home/patient_features/widgets/assesment_widget.dart';

import '../../../../../utilis/constants/colors.dart';
import '../view_appointment.dart';
import 'all_doctors_screen.dart';


class BookAppointmentIntroScreen extends StatelessWidget {
  const BookAppointmentIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WColors.white,
      appBar: AppBar(
        backgroundColor: WColors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Image.asset(
              'assets/home/img_AIBot.png',
              height: 400,
              width: double.infinity,
            ),
            const CustomTextLabel(
              label: 'Schedule a Session',
              fontsize: 26,
              textalign: TextAlign.center,
              fontweight: FontWeight.bold,
            ),
            const SizedBox(
              height: 10,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 35.0),
              child: CustomTextLabel(
                label: 'Talk to a professional for guidance to recovery',
                fontsize: 16,
                textalign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            CustomNextButton(
              onpressed: () {
                Get.to(const AllDoctorsScreen());
              },
              alignment: Alignment.center,
            )
          ],
        ),
      ),
    );
  }
}
