import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healvision/utilis/constants/colors.dart';
import 'package:healvision/utilis/constants/size.dart';

import '../controller/health_tracker_controller.dart';
import '../view_appointment.dart';
import '../widgets/assesment_widget.dart';
import 'health_tracker_3.dart';


class HealthAssessmentScreenTwo extends StatelessWidget {
  const HealthAssessmentScreenTwo({super.key});

  @override
  Widget build(BuildContext context) {
    final HealthAssessmentController controller = Get.put(HealthAssessmentController());

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
            pagenumber: '2',
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
            const CustomTextLabel(
              label: 'Are you experiencing any physical distress?',
              fontsize: 24,
              textalign: TextAlign.center,
              fontweight: FontWeight.bold,
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Obx(
                ()=> ListView(
                  children: [
                    OptionCard(
                      title: 'Yes, one or multiple',
                      description:
                          'I’m experiencing physical pain in different place over my body.',
                      isSelected: controller.physicalDistressSelectedIndex.value == 0,
                      onTap: () => controller.setPhysicalDistressSelectedIndex(0),
                    ),
                    OptionCard(
                      title: 'No Physical Pain At All',
                      description:
                          'I’m not experiencing any physical pain in my body at all :)',
                      isSelected: controller.physicalDistressSelectedIndex.value == 1,
                      onTap: () => controller.setPhysicalDistressSelectedIndex(1),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomButtonNext(
              title: 'Continue',
              onpressed: () {
                Get.to(const SleepQualityScreen());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class OptionCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const OptionCard({
    super.key,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: Colors.green, width: 2) : null,
        ),
        child: Center(
          child: ListTile(
            leading: Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? Colors.white : Colors.red,
              size: 30,
            ),
            title: Text(
              title,
              style: GoogleFonts.urbanist(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? WColors.white : Colors.black,
              ),
            ),
            subtitle: Text(
              description,
              style: GoogleFonts.urbanist(
                fontSize: 14,
                color: isSelected ? WColors.white : Colors.black,
              ),
            ),
            trailing: Radio(
              value: isSelected,
              groupValue: true,
              onChanged: (value) {
                onTap();
              },
              activeColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}