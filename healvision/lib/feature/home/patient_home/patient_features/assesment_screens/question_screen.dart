import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../utilis/constants/colors.dart';
import '../../../../../utilis/constants/size.dart';
import '../controller/assesment_controller.dart';
import '../view_appointment.dart';
import '../widgets/assesment_widget.dart';

class QuestionScreen extends StatelessWidget {
  final int questionIndex;

  const QuestionScreen({super.key, required this.questionIndex});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AssessmentController());

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
        actions: [
          Obx(() => CustomCountContainer(
                pagenumber: '${controller.currentQuestionIndex.value + 1}',
              )),
          const SizedBox(
            width: 15,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
          child: Obx(() {
            final question =
                controller.questions[controller.currentQuestionIndex.value];
            final options = question['options'];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                CustomTextLabel(
                  label: question['question'],
                  fontsize: 18,
                  fontweight: FontWeight.bold,
                  textalign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Column(
                  children: List.generate(options.length, (index) {
                    return OptionButton(
                      title: options[index]['text'],
                      align: index % 2 == 0
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      isSelected: controller.selectedOption.value == index,
                      onPressed: () => controller.selectOption(index),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                CustomNextButton(
                  onpressed: controller.nextPage,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
