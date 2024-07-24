import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:healvision/utilis/constants/size.dart';
import 'package:list_wheel_scroll_view_nls/list_wheel_scroll_view_nls.dart';

import '../../../../../utilis/constants/colors.dart';
import '../controller/health_tracker_controller.dart';
import '../view_appointment.dart';
import '../widgets/assesment_widget.dart';
import 'health_tracker_2.dart';

class HealthAssessmentScreenOne extends StatelessWidget {
  const HealthAssessmentScreenOne({super.key});

  @override
  Widget build(BuildContext context) {
    final HealthAssessmentController controller =
        Get.put(HealthAssessmentController());
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
            pagenumber: '1',
            endingpage: '5',
          ),
          SizedBox(
            width: 15,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            const CustomTextLabel(
              label: 'How would you describe your mood?',
              fontsize: 28,
              textalign: TextAlign.center,
              fontweight: FontWeight.bold,
            ),
            const SizedBox(height: 16),
            Obx(() => CustomTextLabel(
                  label: controller
                      .moodDescriptions[controller.moodSelectedIndex.value],
                  fontsize: 18,
                )),
            const SizedBox(height: 40),
            Obx(() =>
                controller.moodImages[controller.moodSelectedIndex.value]),
            const SizedBox(height: 20),
            MoodWheel(),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomButtonNext(
                title: 'Continue',
                onpressed: () {
                  Get.to(const HealthAssessmentScreenTwo());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MoodWheel extends StatelessWidget {
  final controller = Get.find<HealthAssessmentController>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 250,
          child: ListWheelScrollViewX(
            controller: controller.scrollController,
            scrollDirection: Axis.horizontal,
            itemExtent: 100,
            diameterRatio: 2,
            onSelectedItemChanged: (index) {
              controller.setMoodSelectedIndex(index);
            },
            physics: const FixedExtentScrollPhysics(),
            children: List.generate(
              controller.moodDescriptions.length,
              (index) =>
                  _buildMoodItem(context, controller.moodImages[index], index),
            ),
          ),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width / 2.2,
          bottom: 30,
          child: Center(
            child: Image.asset(
              'assets/images/mood/indicator.png',
              height: 50,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildMoodItem(BuildContext context, Image image, int index) {
    return GestureDetector(
      onTap: () {
        controller.setMoodSelectedIndex(index);
      },
      child: Transform.scale(
        scale: index == controller.moodSelectedIndex.value ? 0.7 : 0.6,
        child: Opacity(
          opacity: index == controller.moodSelectedIndex.value ? 1.0 : 0.9,
          child: image,
        ),
      ),
    );
  }
}
