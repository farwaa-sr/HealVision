import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:healvision/feature/personalization/controllers/user_controller.dart';
import 'package:healvision/utilis/loaders/loaders.dart';

import '../../../../data/assesment_repsitories/assesment_repsitory.dart';
import '../../../../data/therapist_repositories/therapist_repositories.dart';
import '../../../../utilis/constants/image_strings.dart';
import '../../../../utilis/popups/full_screen_loader.dart';
import '../../model/appointment_model.dart';
import '../../model/health_model.dart';
import '../../model/assesment_model.dart';

class MonitiringProcessController extends GetxController {
  static MonitiringProcessController get instance => Get.find();

  // Variables
  final therapistrepository = Get.put(TherapistRepository());
  final assesmentsrepository = Get.put(AssessmentRepository());
  final usercontroller = Get.put(UserController());
  RxList<AppointmentModel> appointments = <AppointmentModel>[].obs;
  RxList<AppointmentModel> filteredappointment = <AppointmentModel>[].obs;
  var searchQuery = ''.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadinghealth = false.obs;
  RxBool isLoadingassesment = false.obs;

  var healthAssessmentData = HealthAssessmentDataModel(
    moodAssessment: {},
    physicalDistressAssessment: {},
    sleepQualityAssessment: {},
    stressLevelAssessment: {},
    substanceUseData: SubstanceUseDataModel(substances: []),
    timestamp: Timestamp.now(),
  ).obs;

  var assessmentResults = AssessmentResult(
    totalScore: 0,
    answers: [],
    timestamp: Timestamp.now(),
  ).obs;

  @override
  void onInit() {
    super.onInit();
    fetchConfrimAppointments();
  }

  void searchPatients(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredappointment.value = appointments;
    } else {
      filteredappointment.value = appointments.where((appointment) {
        return appointment.userName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  Future<void> fetchConfrimAppointments() async {
    try {
      isLoading.value = true; // Start loading

      String userId = usercontroller.user.value.id;
      appointments.value = await therapistrepository
          .fetchTherspistConfrimAppointments(userId, 'Confirm');
      // Sort appointments by date
      appointments.sort((a, b) => a.date.compareTo(b.date));

      filteredappointment.value = appointments;
      isLoading.value = false; // Stop loading
    } catch (e) {
      isLoading.value = false; // Stop loading on error
      TLoaders.errorSnackBar(
          title: 'Error', message: 'Failed to fetch appointments: $e');
    }
  }

  void updateTaskStatus(String appointmentid, String newStatus) async {
    try {
      TFullScreenLoader.openLoadingDialogue(
        'Updating Appointments status...',
        WImages.loaderAnimation,
      );

      await therapistrepository.updateTaskStatus(appointmentid, newStatus);
      fetchConfrimAppointments();
      TFullScreenLoader.stopLoading();

      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Appointments status has been updated successfully.',
      );
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> fetchHealthAssessmentData(String userId) async {
    try {
      isLoadinghealth.value = true; // Start loading
      // Clear existing health assessment data
      healthAssessmentData.value = HealthAssessmentDataModel(
        moodAssessment: {},
        physicalDistressAssessment: {},
        sleepQualityAssessment: {},
        stressLevelAssessment: {},
        substanceUseData: SubstanceUseDataModel(substances: []),
        timestamp: Timestamp.now(),
      );

      healthAssessmentData.value =
          await assesmentsrepository.fetchHealthAssessmentData(userId);

      isLoadinghealth.value = false;
    } catch (e) {
      isLoadinghealth.value = false;
    }
  }

  Future<void> fetchAssessmentResults(String userId) async {
    try {
      isLoadingassesment.value = true;

      assessmentResults.value = AssessmentResult(
        answers: [],
        totalScore: 0,
        timestamp: Timestamp.now(),
      );

      assessmentResults.value =
          await assesmentsrepository.fetchAssessmentResults(userId);
      isLoadingassesment.value = false;
    } catch (e) {
      isLoadingassesment.value = false;
    }
  }
}
