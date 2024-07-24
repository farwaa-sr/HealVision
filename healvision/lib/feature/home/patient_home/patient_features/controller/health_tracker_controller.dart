import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../data/assesment_repsitories/assesment_repsitory.dart';
import '../../../../../utilis/loaders/loaders.dart';
import '../../../../personalization/controllers/user_controller.dart';
import '../../../model/health_model.dart';

class HealthAssessmentController extends GetxController {
  static HealthAssessmentController get instance => Get.find();

  // Varibles
  final usercontroller = Get.put(UserController());
  final assrepository = Get.put(AssessmentRepository());

  var moodSelectedIndex = 2.obs; // Default to "neutral"
  var physicalDistressSelectedIndex = 1.obs; // Default to "No Physical Pain"
  var sleepQualitySliderValue = 2.obs; // Default to "Fair"
  var stressLevelSliderValue = 3.obs; // Default to "Very Stressed"
  GlobalKey<FormState> substanceFormKey = GlobalKey<FormState>();

  // Substance Use Data
  final name = TextEditingController();
  final amount = TextEditingController();
  final reason = TextEditingController();
  var date = ''.obs;
  var time = ''.obs;
  var substanceUseData = SubstanceUseDataModel(substances: []).obs;

  final List<String> moodDescriptions = [
    'I Feel Depressed.',
    'I Feel Sad.',
    'I Feel Neutral.',
    'I Feel Happy.',
    'I Feel Overjoyed.',
  ];

  final List<Image> moodImages = [
    Image.asset(
      'assets/images/mood/depressed.png',
      height: 100,
      fit: BoxFit.cover,
    ),
    Image.asset(
      'assets/images/mood/sad.png',
      height: 100,
      fit: BoxFit.cover,
    ),
    Image.asset(
      'assets/images/mood/neutral.png',
      height: 100,
      fit: BoxFit.cover,
    ),
    Image.asset(
      'assets/images/mood/happy.png',
      height: 100,
      fit: BoxFit.cover,
    ),
    Image.asset(
      'assets/images/mood/overjoyed.png',
      height: 100,
      fit: BoxFit.cover,
    ),
  ];

  final List<String> stressMessages = [
    'You are Completely Relaxed.',
    'You are Slightly Stressed.',
    'You are Moderately Stressed.',
    'You are Very Stressed.',
    'You Are Extremely Stressed Out.',
  ];

  late FixedExtentScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    scrollController =
        FixedExtentScrollController(initialItem: moodSelectedIndex.value);
  }

  void setMoodSelectedIndex(int index) {
    moodSelectedIndex.value = index;
  }

  void setPhysicalDistressSelectedIndex(int index) {
    physicalDistressSelectedIndex.value = index;
  }

  void setSleepQualitySliderValue(int value) {
    sleepQualitySliderValue.value = value;
  }

  void setStressLevelSliderValue(int value) {
    stressLevelSliderValue.value = value;
  }

  void setDate(String dt) {
    date.value = dt;
  }

  void setTime(String tm) {
    time.value = tm;
  }

  void addSubstance(String name, String amount, String date, String time, String reason) {
    Map<String, dynamic> substance = {
      'name': name,
      'amount': amount,
      'date': date,
      'time': time,
      'reason': reason,
    };
    substanceUseData.update((val) {
      val!.substances.add(substance);
    });
  }

  Future<void> saveAssessmentDataToFirestore() async {
    String userId = usercontroller.user.value.id;

    try {
      HealthAssessmentDataModel assessmentData = HealthAssessmentDataModel(
        moodAssessment: {
          'question': 'How would you describe your mood?',
          'answer': moodDescriptions[moodSelectedIndex.value],
          'value': moodSelectedIndex.value
        },
        physicalDistressAssessment: {
          'question': 'Are you experiencing any physical distress?',
          'answer': physicalDistressSelectedIndex.value == 0 ? 'Yes, one or multiple' : 'No Physical Pain At All',
          'value': physicalDistressSelectedIndex.value
        },
        sleepQualityAssessment: {
          'question': 'How would you rate your sleep quality?',
          'answer': [
            'Worst (<3 HOURS)',
            'Poor (3-4 HOURS)',
            'Fair (5 HOURS)',
            'Good (6-7 HOURS)',
            'Excellent (7-9 HOURS)',
          ][sleepQualitySliderValue.value],
          'value': sleepQualitySliderValue.value
        },
        stressLevelAssessment: {
          'question': 'How would you rate your stress level?',
          'answer': stressMessages[stressLevelSliderValue.value - 1],
          'value': stressLevelSliderValue.value
        },
        substanceUseData: substanceUseData.value,
        timestamp: Timestamp.now(),
      );

      await assrepository.saveHealthAssessment(userId, assessmentData);
      TLoaders.successSnackBar(title:'Success',message: 'Your Health Tracker Data Upload Successfully');
    } catch (e) {
      TLoaders.errorSnackBar(title:'Error',message: 'Error saving assessment data: $e');
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
