import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healvision/feature/home/patient_home/patient_features/widgets/assesment_widget.dart';

import '../../../../../utilis/constants/colors.dart';
import '../view_appointment.dart';
import 'question_screen.dart';



class AssesmentIntroScreen extends StatelessWidget {
  const AssesmentIntroScreen({super.key});

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
              'assets/home/img_happy.png',
              height: 400,
              width: double.infinity,
            ),
            const CustomTextLabel(
              label: 'Test Yourself',
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
                label: 'check your new Level to see how far you have come!',
                fontsize: 16,
                textalign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            CustomNextButton(
              onpressed: () {
                Get.to(const QuestionScreen(questionIndex: 0),);
              },
              alignment: Alignment.center,
            )
          ],
        ),
      ),
    );
  }
}
