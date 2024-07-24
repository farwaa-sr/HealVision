import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healvision/feature/home/patient_home/patient_features/view_appointment.dart';
import 'package:healvision/utilis/constants/colors.dart';

import '../controller/health_tracker_controller.dart';
import '../widgets/assesment_widget.dart';
import 'health_tracker_5.dart';

class StressLevelScreen extends StatelessWidget {
  const StressLevelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HealthAssessmentController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: WColors.white,
        title: Text(
          'Assessment',
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: const [
          CustomCountContainer(
            pagenumber: '4',
            endingpage: '5',
          ),
          SizedBox(
            width: 15,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            const CustomTextLabel(
              label: 'How would you rate your stress level?',
              fontsize: 30,
              textalign: TextAlign.center,
              fontweight: FontWeight.bold,
            ),
            const SizedBox(height: 40),
            Obx(() => CustomTextLabel(
                  label: '${controller.stressLevelSliderValue.value}',
                  fontsize: 180,
                  fontweight: FontWeight.bold,
                )),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    controller.setStressLevelSliderValue(index + 1);
                  },
                  child: Obx(() => CircleAvatar(
                        radius: 25,
                        backgroundColor:
                            controller.stressLevelSliderValue.value == index + 1
                                ? const Color(0xFFED7E1C)
                                : WColors.softGrey,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 18,
                            color: controller.stressLevelSliderValue.value ==
                                    index + 1
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                );
              }),
            ),
            const SizedBox(height: 20),
            Obx(() => Text(
                  controller.stressMessages[
                      controller.stressLevelSliderValue.value - 1],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                )),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomButtonNext(
                title: 'Continue',
                onpressed: () {
                  Get.to(const SubstanceUseDataScreen());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
