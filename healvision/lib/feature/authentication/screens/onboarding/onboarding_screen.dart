import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utilis/constants/image_strings.dart';
import '../../../../utilis/constants/text_string.dart';
import '../../controllers/onboarding/onboard_controller.dart';
import 'widgets/onboarding_widget.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());
    return Scaffold(
      body: Stack(
        children: [
          // Horizontal Scrollable Pages
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: const [
              Onboardingpage(
                image: WImages.onBoardingImage1,
                title: WTexts.onBoardingTitle1,
                subtitle: WTexts.onBoardingSubTitle1,
              ),
              Onboardingpage(
                image: WImages.onBoardingImage2,
                title: WTexts.onBoardingTitle2,
                subtitle: WTexts.onBoardingSubTitle2,
              ),
              Onboardingpage(
                image: WImages.onBoardingImage3,
                title: WTexts.onBoardingTitle3,
                subtitle: WTexts.onBoardingSubTitle3,
              ),
            ],
          ),
          // Skip Button
          const OnBoardingSkip(),
          // Dot Navigation SmoothpageIndicator
          const OnBoardingDotNavigation(),
          //Circular Button
          const OnBoardingNextButton()
        ],
      ),
    );
  }
}