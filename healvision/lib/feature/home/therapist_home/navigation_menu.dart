import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../utilis/constants/colors.dart';
import '../../../utilis/helpers/helper_function.dart';
import '../patient_home/patient_features/assesment_screens/assesment_intro_screen.dart';
import '../patient_home/patient_features/book_appointment/book_appointment_intro.dart';
import '../patient_home/patient_features/chat_bot/chat_bot_screen.dart';
import '../patient_home/patient_features/health_tracker/health_tracker_intro.dart';
import '../patient_home/patient_home.dart';
import 'therapist_features/monitoring_progress.dart';
import 'therapist_features/patient_appointment.dart';
import 'therapist_features/therapist_details.dart';
import 'therapist_home.dart';

class NavigationMenuTherapist extends StatelessWidget {
  const NavigationMenuTherapist({super.key});

  @override
  Widget build(BuildContext context) {
    final controlller = Get.put(TherapistNavigationController());
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
              const TextStyle(color: Colors.white,fontSize: 12),
            ),
            iconTheme: WidgetStateProperty.all(
              const IconThemeData(color: Colors.white),
            ),
          ),
          child:  NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: controlller.selectedIndex.value,
          onDestinationSelected: (index) =>
              controlller.selectedIndex.value = index,
          destinations: const [
            NavigationDestination(icon: Icon(Iconsax.home), label: 'Home'),
            NavigationDestination(
                icon: Icon(Iconsax.document), label: 'Appointments'),
            NavigationDestination(
                icon: Icon(Iconsax.monitor), label: 'Monitoring'),
            NavigationDestination(icon: Icon(Iconsax.user), label: 'Profile'),
          ],
        ),
      ),
      ),
      body: Obx(() => controlller.screens[controlller.selectedIndex.value]),
    );
  }
}

class TherapistNavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = const [
    TherapistHome(),
    PatientAppointment(),
    MonitiringProgress(),
    TherapistDetailsScreen()
  ];
}

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
              const TextStyle(color: Colors.white,fontSize: 12),
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
                icon: Icon(Iconsax.search_favorite),
                label: 'Therapists',
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
    BookAppointmentIntroScreen(),
    HealthTrackerIntroScreen(),
    AssesmentIntroScreen(),
    ChatBotScreen(),
  ];
}
