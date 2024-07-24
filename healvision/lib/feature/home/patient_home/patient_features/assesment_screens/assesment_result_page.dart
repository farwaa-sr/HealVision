import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:healvision/feature/home/patient_home/patient_features/view_appointment.dart';
import 'package:healvision/utilis/constants/colors.dart';

import '../../../therapist_home/navigation_menu.dart';
import '../controller/assesment_controller.dart';

class AssessmentResultScrenn extends StatelessWidget {
  const AssessmentResultScrenn({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AssessmentController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const CustomTextLabel(
                  label: 'Congrats!',
                  fontsize: 28,
                  fontweight: FontWeight.bold,
                ),
                const SizedBox(height: 8),
                const CustomTextLabel(
                  label: 'You’ve completed the first step towards recovery.',
                  fontsize: 16,
                  textalign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: WColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: WColors.customcontainer,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Obx(() => CustomTextLabel(
                          label: controller.totalScore.value.toString(),
                          fontsize: 48,
                          fontweight: FontWeight.bold,
                        )),
                  ],
                ),
                const SizedBox(height: 40),
                const CustomTextLabel(
                  label:
                      'Your responses indicate a mild risk of addiction, with possible early signs.',
                  textalign: TextAlign.center,
                  fontsize: 16,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Consider monitoring your substance use and seeking support if needed.\n\nEarly intervention can make a significant difference.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black45,
                  ),
                ),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: () {
                    Get.offAll(const NavigationMenuPatient());
                  },
                  child: Container(
                    width: 150,
                    height: 50,
                    decoration: const BoxDecoration(
                        color: WColors.primary,
                        borderRadius: BorderRadius.all(Radius.circular(22))),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
