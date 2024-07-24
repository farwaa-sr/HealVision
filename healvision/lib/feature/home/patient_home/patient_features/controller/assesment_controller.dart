import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../../../data/assesment_repsitories/assesment_repsitory.dart';
import '../../../../../utilis/loaders/loaders.dart';
import '../../../../personalization/controllers/user_controller.dart';
import '../../../model/assesment_model.dart';
import '../assesment_screens/assesment_result_page.dart';

class AssessmentController extends GetxController {
  static AssessmentController get instance => Get.find();

  final controller = Get.put(UserController());
  final assrepository = Get.put(AssessmentRepository());

  var currentQuestionIndex = 0.obs;
  var selectedOption = 0.obs;
  var totalScore = 0.obs;

  List<Map<String, dynamic>> questions = [
    {
      'question': 'What made you consider this app?',
      'options': [
        {'text': 'I need help', 'score': 5},
        {'text': 'A friend', 'score': 3},
        {'text': 'Just luck', 'score': 1},
        {'text': 'Lost control', 'score': 4},
      ],
    },
    {
      'question': 'How often do you use the substance?',
      'options': [
        {'text': 'Daily', 'score': 5},
        {'text': 'Several times a week', 'score': 4},
        {'text': 'Once a week', 'score': 3},
        {'text': 'Sometimes', 'score': 2},
        {'text': 'Rarely', 'score': 1},
      ],
    },
    {
      'question': 'In what way does substance use affect your life?',
      'options': [
        {'text': 'It doesn\'t affect me', 'score': 1},
        {'text': 'It has a minor impact', 'score': 2},
        {'text': 'It interferes with my responsibilities', 'score': 3},
        {'text': 'It significantly disrupts my life', 'score': 4},
        {'text': 'I can\'t function without it', 'score': 5},
      ],
    },
    {
      'question': 'Have you tried to cut down or quit using the substance?',
      'options': [
        {'text': 'No, I haven\'t felt the need', 'score': 1},
        {'text': 'Yes, but unsuccessfully', 'score': 2},
        {'text': 'Yes, and successfully for a short period', 'score': 3},
        {'text': 'Yes, and successfully for a significant period', 'score': 4},
        {'text': 'I haven\'t tried, but I want to', 'score': 5},
      ],
    },
    {
      'question': 'How often do you experience cravings for the substance?',
      'options': [
        {'text': 'Never', 'score': 1},
        {'text': 'Rarely', 'score': 2},
        {'text': 'Occasionally', 'score': 3},
        {'text': 'Frequently', 'score': 4},
        {'text': 'Always', 'score': 5},
      ],
    },
    {
      'question': 'Have you withdrawn from social activities due to substance use?',
      'options': [
        {'text': 'No, not at all', 'score': 1},
        {'text': 'Occasionally', 'score': 2},
        {'text': 'Frequently', 'score': 3},
        {'text': 'Most of the time', 'score': 4},
        {'text': 'Always', 'score': 5},
      ],
    },
    {
      'question': 'Have you noticed an increase in the amount of substance needed to achieve the same effect?',
      'options': [
        {'text': 'No', 'score': 1},
        {'text': 'Yes, minor consequences', 'score': 2},
        {'text': 'Yes, a moderate increase', 'score': 3},
        {'text': 'Yes, severe consequences', 'score': 4},
        {'text': 'I prefer not to say', 'score': 5},
      ],
    },
    {
      'question': 'Have you experienced negative consequences (health, legal, financial) due to substance use?',
      'options': [
        {'text': 'No', 'score': 1},
        {'text': 'Mild symptoms', 'score': 2},
        {'text': 'Moderate symptoms', 'score': 3},
        {'text': 'Severe symptoms', 'score': 4},
        {'text': 'I haven\'t tried to stop', 'score': 5},
      ],
    },
    {
      'question': 'Have you experienced physical or psychological withdrawal symptoms when not using the substance?',
      'options': [
        {'text': 'I\'m not aware', 'score': 1},
        {'text': 'I\'m aware but not concerned', 'score': 2},
        {'text': 'I\'m somewhat concerned', 'score': 3},
        {'text': 'I\'m very concerned', 'score': 4},
        {'text': 'I\'m extremely concerned', 'score': 5},
      ],
    },
    {
      'question': 'Are you interested in seeking help or support for your substance use?',
      'options': [
        {'text': 'No', 'score': 1},
        {'text': 'Maybe in the future', 'score': 2},
        {'text': 'Yes, considering it', 'score': 3},
        {'text': 'Yes, actively seeking help', 'score': 4},
        {'text': 'I\'m already in treatment', 'score': 5},
      ],
    },
  ];

  List<AssessmentModel> answers = [];

  void selectOption(int index) {
    selectedOption.value = index;
  }

  void nextPage() {
    // Store the current answer
    final currentQuestion = questions[currentQuestionIndex.value];
    final selectedAnswer = currentQuestion['options'][selectedOption.value];
    answers.add(
      AssessmentModel(
        question: currentQuestion['question'],
        selectedOption: selectedAnswer['text'],
        score: selectedAnswer['score'],
      ),
    );

    // Update total score
    totalScore.value += selectedAnswer['score'] as int;

    // Move to the next question
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      selectedOption.value = 0; // Reset the selected option for the next question
    } else {
      saveResults();
      // Navigate to the result screen
      Get.to(const AssessmentResultScrenn());
      TLoaders.successSnackBar(title:'Success',message: 'Your Assessment Data Upload Successfully');
    }
  }
  
  void saveResults() async {
    try {
      String userId = controller.user.value.id; 
      final result = AssessmentResult(
        totalScore: totalScore.value,
        answers: answers,
        timestamp: Timestamp.now(),
      );
      await assrepository.saveAssessmentResults(userId,result , totalScore.value);
    } catch (e) {
      // Handle errors if necessary
      TLoaders.errorSnackBar(title:'Error',message: 'Error saving assessment results: $e');
    }
  }
}
