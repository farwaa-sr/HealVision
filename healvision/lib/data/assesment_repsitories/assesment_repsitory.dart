import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../feature/home/model/assesment_model.dart';
import '../../feature/home/model/health_model.dart';
import '../../utilis/exceptions/firebase_exceptions.dart';
import '../../utilis/exceptions/format_exceptions.dart';
import '../../utilis/exceptions/platform_exceptions.dart';

class AssessmentRepository extends GetxController {
  static AssessmentRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveAssessmentResults(String userId, AssessmentResult assModel, int totalScore) async {
    try {
      await _db.collection("Assessments").doc(userId).set(assModel.toJson(), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<void> saveHealthAssessment(String userId, HealthAssessmentDataModel assessmentData) async {
    try {
      await _db.collection("HealthTracker").doc(userId).set(assessmentData.toJson(), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<HealthAssessmentDataModel> fetchHealthAssessmentData(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _db.collection("HealthTracker").doc(userId).get();
      return HealthAssessmentDataModel.fromSnapshot(snapshot);
    } catch (e) {
      throw Exception('Failed to fetch health assessment data: $e');
    }
  }

  Future<AssessmentResult> fetchAssessmentResults(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _db.collection("Assessments").doc(userId).get();
      return AssessmentResult.fromSnapshot(snapshot);
    } catch (e) {
      throw Exception('Failed to fetch assessment results: $e');
    }
  }
}
