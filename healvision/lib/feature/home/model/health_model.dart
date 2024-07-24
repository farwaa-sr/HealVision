import 'package:cloud_firestore/cloud_firestore.dart';

class HealthAssessmentDataModel {
  final Map<String, dynamic> moodAssessment;
  final Map<String, dynamic> physicalDistressAssessment;
  final Map<String, dynamic> sleepQualityAssessment;
  final Map<String, dynamic> stressLevelAssessment;
  final SubstanceUseDataModel substanceUseData;
  final Timestamp timestamp;

  HealthAssessmentDataModel({
    required this.moodAssessment,
    required this.physicalDistressAssessment,
    required this.sleepQualityAssessment,
    required this.stressLevelAssessment,
    required this.substanceUseData,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'moodAssessment': moodAssessment,
      'physicalDistressAssessment': physicalDistressAssessment,
      'sleepQualityAssessment': sleepQualityAssessment,
      'stressLevelAssessment': stressLevelAssessment,
      'substanceUseData': substanceUseData.toJson(),
      'timestamp': timestamp,
    };
  }

  factory HealthAssessmentDataModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return HealthAssessmentDataModel(
      moodAssessment: data['moodAssessment'] ?? {},
      physicalDistressAssessment: data['physicalDistressAssessment'] ?? {},
      sleepQualityAssessment: data['sleepQualityAssessment'] ?? {},
      stressLevelAssessment: data['stressLevelAssessment'] ?? {},
      substanceUseData:
          SubstanceUseDataModel.fromJson(data['substanceUseData'] ?? {}),
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}

class SubstanceUseDataModel {
  final List<Map<String, dynamic>> substances;

  SubstanceUseDataModel({required this.substances});

  Map<String, dynamic> toJson() {
    return {
      'substances': substances,
    };
  }

  factory SubstanceUseDataModel.fromJson(Map<String, dynamic> json) {
    return SubstanceUseDataModel(
      substances: List<Map<String, dynamic>>.from(json['substances'] ?? []),
    );
  }
}
