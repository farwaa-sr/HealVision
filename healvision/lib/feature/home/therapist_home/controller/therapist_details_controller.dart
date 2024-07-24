import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healvision/utilis/loaders/loaders.dart';

import '../../../../data/therapist_repositories/therapist_repositories.dart';
import '../../../personalization/controllers/user_controller.dart';
import '../model/therapist_model.dart';

class TherapistDetailsController extends GetxController {
  static TherapistDetailsController get instance => Get.find();

  final _therapistRepository = Get.put(TherapistRepository());
  final userController = Get.put(UserController());

  final specialtyController = TextEditingController();
  final locationController = TextEditingController();
  final experienceController = TextEditingController();
  final aboutMeController = TextEditingController();
  final workingTimeController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final nameController = TextEditingController();
  RxBool isLoading = false.obs;

  RxList<String> timeSlots = <String>[].obs;
  final List<String> availableTimeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '11:30 AM',
    '03:00 PM',
    '04:00 PM',
    '04:30 PM',
    '05:30 PM',
  ];

  // Load existing therapist details if needed
  Future<void> loadTherapistDetails(String therapistId) async {
    isLoading.value = true;
    try {
      TherapistModel therapist =
          await _therapistRepository.fetchTherapistById(therapistId);
      specialtyController.text = therapist.specialty;
      locationController.text = therapist.location;
      experienceController.text = therapist.experience.toString();
      aboutMeController.text = therapist.aboutMe;
      workingTimeController.text = therapist.workingTime;
      emailController.text = therapist.email;
      phoneNumberController.text = therapist.phoneNumber;
      nameController.text = therapist.doctorName;
      timeSlots.value = therapist.timeSlots;
    } catch (e) {
      TLoaders.errorSnackBar(
          title: 'Error', message: "Error loading therapist details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Save or update therapist details
  Future<void> saveOrUpdateTherapistDetails(String therapistId) async {
    try {
      String name = userController.user.value.fullname;
      String email = userController.user.value.email;
      String mobile = userController.user.value.phoneNumber;
      String imageurl = userController.user.value.profilePicture;

      TherapistModel therapist = TherapistModel(
        id: therapistId,
        doctorName: name,
        specialty: specialtyController.text,
        image: imageurl,
        location: locationController.text,
        experience: int.parse(experienceController.text),
        aboutMe: aboutMeController.text,
        workingTime: workingTimeController.text,
        email: email,
        phoneNumber: mobile,
        timeSlots:
            List<String>.from(timeSlots), // Convert RxList to regular List
      );

      await _therapistRepository.addOrUpdateTherapistDetails(therapist);
      TLoaders.successSnackBar(
          title: 'Success', message: 'Your Record Updated Successfully');
    } catch (e) {
      TLoaders.errorSnackBar(
          title: 'Error',
          message: 'Error saving/updating therapist details $e');
    }
  }

  @override
  void onClose() {
    specialtyController.dispose();
    locationController.dispose();
    experienceController.dispose();
    aboutMeController.dispose();
    workingTimeController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    super.onClose();
  }
}
