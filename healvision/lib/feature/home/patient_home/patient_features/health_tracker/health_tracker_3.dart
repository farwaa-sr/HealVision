import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healvision/feature/home/patient_home/patient_features/view_appointment.dart';
import 'package:healvision/utilis/constants/colors.dart';
import 'package:healvision/utilis/constants/size.dart';

import '../controller/health_tracker_controller.dart';
import '../widgets/assesment_widget.dart';
import 'health_tracker_4.dart';

class SleepQualityScreen extends StatelessWidget {
  const SleepQualityScreen({super.key});

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
            pagenumber: '3',
            endingpage: '5',
          ),
          SizedBox(
            width: 15,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'How would you rate your sleep quality?',
              textAlign: TextAlign.center,
              style: GoogleFonts.urbanist(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: TSizes.defaultSpace),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SleepTimeWidget(
                            title: 'Excellent', subtitle: '7-9 HOURS'),
                        SleepTimeWidget(title: 'Good', subtitle: '6-7 HOURS'),
                        SleepTimeWidget(title: 'Fair', subtitle: '5 HOURS'),
                        SleepTimeWidget(title: 'Poor', subtitle: '3-4 HOURS'),
                        SleepTimeWidget(title: 'Worst', subtitle: '<3 HOURS'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Obx(
                      ()=> SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 20,
                            activeTickMarkColor: const Color(0xFFAA5500),
                            inactiveTickMarkColor: Colors.grey[300],
                            activeTrackColor: const Color(0xFFAA5500),
                            inactiveTrackColor: Colors.grey[300],
                            thumbColor: WColors.primary,
                            overlayColor: Colors.orange.withAlpha(32),
                            valueIndicatorColor: Colors.grey[300],
                            thumbShape: CustomThumbShape(),
                          ),
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: Slider(
                              value: controller.sleepQualitySliderValue.value.toDouble(),
                              min: 0,
                              max: 4,
                              divisions: 4,
                              onChanged: (value) {
                                controller.setSleepQualitySliderValue(value.toInt());
                              },
                            ),
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: TSizes.defaultSpace),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset('assets/images/mood/overjoyed.png'),
                        Image.asset('assets/images/mood/happy.png'),
                        Image.asset('assets/images/mood/neutral.png'),
                        Image.asset('assets/images/mood/sad.png'),
                        Image.asset('assets/images/mood/depressed.png'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            CustomButtonNext(
              title: 'Continue',
              onpressed: () {
                Get.to(const StressLevelScreen());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SleepTimeWidget extends StatelessWidget {
  const SleepTimeWidget(
      {super.key, required this.title, required this.subtitle});
  final String title, subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextLabel(
          label: title,
          fontsize: 18,
          fontweight: FontWeight.bold,
        ),
        Row(
          children: [
            Icon(
              Icons.access_time_filled,
              color: Colors.grey[400],
            ),
            const SizedBox(
              width: 5,
            ),
            CustomTextLabel(
              label: subtitle,
              fontweight: FontWeight.w500,
            ),
          ],
        )
      ],
    );
  }
}

class CustomThumbShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(30.0, 30.0); // Set the size of the thumb
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final Paint paint = Paint()
      ..color = sliderTheme.thumbColor!
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 25.0, paint);

    const icon = Icons.bedtime; // Choose an appropriate icon
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 30.0,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }
}
