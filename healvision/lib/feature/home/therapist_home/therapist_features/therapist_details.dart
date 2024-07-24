import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healvision/feature/personalization/controllers/user_controller.dart';

import '../../../../common/widgets/image/t_circular_image.dart';
import '../../../../utilis/constants/colors.dart';
import '../../../../utilis/constants/image_strings.dart';
import '../controller/therapist_details_controller.dart';


class TherapistDetailsScreen extends StatelessWidget {
  const TherapistDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TherapistDetailsController());
    final usercontroller = Get.put(UserController());
    controller.loadTherapistDetails(controller.userController.user.value.id);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Therapist Details',
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              controller.saveOrUpdateTherapistDetails(
                  controller.userController.user.value.id);
            },
            icon: const Icon(
              Icons.save,
              color: WColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final networkImage = usercontroller.user.value.profilePicture;
            final image =
                networkImage.isNotEmpty ? networkImage : WImages.user;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TCircularimage(
                    image: image,
                    width: 90,
                    height: 90,
                    isNetwork: networkImage.isNotEmpty,
                  ),
                  TextButton(
                    onPressed: () {
                      usercontroller.uploadUserProfilePicture();
                    },
                    child: const Text(
                      'Change Profile Picture',
                      style: TextStyle(
                        color: WColors.black,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: controller.nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: controller.phoneNumberController,
                    decoration:
                        const InputDecoration(labelText: 'Mobile Number'),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: controller.specialtyController,
                    decoration: const InputDecoration(labelText: 'Specialty'),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: controller.locationController,
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: controller.experienceController,
                    decoration: const InputDecoration(
                        labelText: 'Experience (in years)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: controller.aboutMeController,
                    decoration: const InputDecoration(labelText: 'About Me'),
                    maxLines: 3,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: controller.workingTimeController,
                    decoration:
                        const InputDecoration(labelText: 'Working Time'),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Obx(
                    () => Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: controller.availableTimeSlots.map((time) {
                        return ChoiceChip(
                          label: Text(time),
                          showCheckmark: false,
                          selected: controller.timeSlots.contains(time),
                          onSelected: (selected) {
                            if (selected) {
                              controller.timeSlots.add(time);
                            } else {
                              controller.timeSlots.remove(time);
                            }
                          },
                          selectedColor: WColors.primary,
                          backgroundColor: Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                16.0), // Adjust the radius as needed
                            side: const BorderSide(
                              color: WColors.light,
                            ), // Optional border side
                          ),
                          labelStyle: TextStyle(
                            color: controller.timeSlots.contains(time)
                                ? Colors.white
                                : Colors.black,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                ],
              ),
            );
          }
        }),
      ),
    );
  }
}