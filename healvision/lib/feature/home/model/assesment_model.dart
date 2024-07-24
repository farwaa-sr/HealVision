import 'package:cloud_firestore/cloud_firestore.dart';

class AssessmentModel {
  final String question;
  final String selectedOption;
  final int score;

  AssessmentModel({
    required this.question,
    required this.selectedOption,
    required this.score,
  });

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'selectedOption': selectedOption,
      'score': score,
    };
  }

  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    return AssessmentModel(
      question: json['question'] ?? '',
      selectedOption: json['selectedOption'] ?? '',
      score: json['score'] ?? 0,
    );
  }
}

class AssessmentResult {
  final int totalScore;
  final List<AssessmentModel> answers;
  final Timestamp timestamp;

  AssessmentResult({
    required this.totalScore,
    required this.answers,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalScore': totalScore,
      'answers': answers.map((answer) => answer.toJson()).toList(),
      'timestamp': timestamp,
    };
  }

  factory AssessmentResult.fromJson(Map<String, dynamic> json) {
    return AssessmentResult(
      totalScore: json['totalScore'] ?? 0,
      answers: (json['answers'] as List<dynamic>)
          .map((answer) => AssessmentModel.fromJson(answer))
          .toList(),
      timestamp: json['timestamp'] ?? Timestamp.now(),
    );
  }

  factory AssessmentResult.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return AssessmentResult(
      totalScore: data['totalScore'] ?? 0,
      answers: (data['answers'] as List<dynamic>)
          .map((answer) => AssessmentModel.fromJson(answer))
          .toList(),
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

}
