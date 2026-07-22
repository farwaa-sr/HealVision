import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../utilis/constants/colors.dart';
import '../../utilis/helpers/helper_function.dart';
import 'patient_home/patient_features/assesment_screens/assesment_intro_screen.dart';
import 'patient_home/patient_features/chat_bot/chat_bot_screen.dart';
import 'patient_home/patient_features/health_tracker/health_tracker_intro.dart';
import 'patient_home/patient_home.dart';

/// Single-user recovery companion navigation shell.
/// (Therapist role and appointment booking have been removed.)
class NavigationMenuPatient extends StatelessWidget {
  const NavigationMenuPatient({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PatientNavigationController());
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: dark ? WColors.black : WColors.primary,
            indicatorColor: dark
                ? WColors.white.withOpacity(0.1)
                : WColors.black.withOpacity(0.1),
            labelTextStyle: WidgetStateProperty.all(
              const TextStyle(color: Colors.white, fontSize: 12),
            ),
            iconTheme: WidgetStateProperty.all(
              const IconThemeData(color: Colors.white),
            ),
          ),
          child: NavigationBar(
            height: 80,
            elevation: 0,
            selectedIndex: controller.selectedIndex.value,
            onDestinationSelected: (index) =>
                controller.selectedIndex.value = index,
            destinations: const [
              NavigationDestination(
                icon: Icon(Iconsax.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Iconsax.health),
                label: 'Health',
              ),
              NavigationDestination(
                icon: Icon(Iconsax.document),
                label: 'Test Me',
              ),
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline_outlined),
                label: 'Chat Bot',
              ),
            ],
          ),
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class PatientNavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = const [
    PatientHome(),
    HealthTrackerIntroScreen(),
    AssesmentIntroScreen(),
    ChatBotScreen(),
  ];
}
