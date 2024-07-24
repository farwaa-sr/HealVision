import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../feature/home/model/appointment_model.dart';
import '../../feature/home/therapist_home/model/therapist_model.dart';
import '../../utilis/exceptions/firebase_exceptions.dart';
import '../../utilis/exceptions/format_exceptions.dart';
import '../../utilis/exceptions/platform_exceptions.dart';

class TherapistRepository extends GetxController {
  static TherapistRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add or update therapist details
  Future<void> addOrUpdateTherapistDetails(TherapistModel therapist) async {
    try {
      await _db
          .collection("therapists")
          .doc(therapist.id)
          .set(therapist.toJson());
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

  // Fetch all therapists
  Future<List<TherapistModel>> fetchAllTherapists() async {
    try {
      final snapshot = await _db.collection('therapists').get();
      final result =
          snapshot.docs.map((e) => TherapistModel.fromSnapshot(e)).toList();
      return result;
    } catch (e) {
      throw Exception('Failed to fetch therapists: $e');
    }
  }

  // Fetch therapist by ID
  Future<TherapistModel> fetchTherapistById(String therapistId) async {
    try {
      var snapshot = await _db.collection('therapists').doc(therapistId).get();
      return TherapistModel.fromSnapshot(snapshot);
    } catch (e) {
      throw Exception('Failed to fetch therapist details: $e');
    }
  }

  // Fetch time slots for a therapist
  Future<List<String>> fetchTimeSlots(String therapistId) async {
    try {
      var snapshot = await _db.collection('therapists').doc(therapistId).get();
      if (snapshot.exists) {
        List<dynamic> slots = snapshot.data()!['timeSlots'];
        return List<String>.from(slots);
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to fetch time slots: $e');
    }
  }

  // Fetch available time slots for a specific date
  Future<List<String>> fetchAvailableSlots(
      String therapistId, DateTime date) async {
    try {
      var snapshot = await _db
          .collection('appointments')
          .where('therapistId', isEqualTo: therapistId)
          .where('date',
              isEqualTo: date
                  .toIso8601String()
                  .split('T')
                  .first) // Format date to match stored format
          .get();

      List<String> bookedSlots =
          snapshot.docs.map((doc) => doc['time'] as String).toList();

      // Fetch all time slots of the therapist
      List<String> allSlots = await fetchTimeSlots(therapistId);

      // Filter out the booked slots
      List<String> availableSlots =
          allSlots.where((slot) => !bookedSlots.contains(slot)).toList();

      return availableSlots;
    } catch (e) {
      throw Exception('Failed to fetch available slots: $e');
    }
  }

  // Delete therapist details
  Future<void> deleteTherapistDetails(String therapistId) async {
    try {
      await _db.collection("therapists").doc(therapistId).delete();
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

  // Add appointment for therapist
  Future<void> addAppointment(AppointmentModel appointment) async {
    try {
      await _db.collection('appointments').doc().set(appointment.toJson());
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

  // Update appointment for therapist
  Future<void> updateAppointment(
      String therapistId, AppointmentModel appointment) async {
    try {
      await _db
          .collection('appointments')
          .doc(therapistId)
          .update(appointment.toJson());
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

  // Delete appointment for therapist
  Future<void> deleteAppointment(String therapistId) async {
    try {
      await _db.collection('appointments').doc(therapistId).delete();
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

  // Fetch Specfic User Appointments
  Future<List<AppointmentModel>> fetchUserAppointments(String userId) async {
    try {
      var snapshot = await _db
          .collection('appointments')
          .where('userid', isEqualTo: userId)
          .get();

      List<AppointmentModel> userAppointments = snapshot.docs
          .map((doc) => AppointmentModel.fromSnapshot(doc))
          .toList();

      return userAppointments;
    } catch (e) {
      throw Exception('Failed to fetch user appointments: $e');
    }
  }

  // Fetch Specfic Therapist Appointments
  Future<List<AppointmentModel>> fetchtherspistAppointments(
      String therapistId) async {
    try {
      var snapshot = await _db
          .collection('appointments')
          .where('therapistId', isEqualTo: therapistId)
          .get();

      List<AppointmentModel> therapistAppointments = snapshot.docs
          .map((doc) => AppointmentModel.fromSnapshot(doc))
          .toList();

      return therapistAppointments;
    } catch (e) {
      throw Exception('Failed to fetch user appointments: $e');
    }
  }

  // Fetch Specfic Therapist Appointments by Status
  Future<List<AppointmentModel>> fetchTherspistConfrimAppointments(
      String therapistId,String stauts) async {
    try {
      var snapshot = await _db
          .collection('appointments')
          .where('therapistId', isEqualTo: therapistId)
          .where('appointmentstatus', isEqualTo: stauts)
          .get();

      List<AppointmentModel> therapistAppointments = snapshot.docs
          .map((doc) => AppointmentModel.fromSnapshot(doc))
          .toList();

      return therapistAppointments;
    } catch (e) {
      throw Exception('Failed to fetch user appointments: $e');
    }
  }

  // Fetch Specfic Patients Appointments by Status
  Future<List<AppointmentModel>> fetchPatientConfrimAppointments(
      String therapistId,String stauts) async {
    try {
      var snapshot = await _db
          .collection('appointments')
          .where('userid', isEqualTo: therapistId)
          .where('appointmentstatus', isEqualTo: stauts)
          .get();

      List<AppointmentModel> therapistAppointments = snapshot.docs
          .map((doc) => AppointmentModel.fromSnapshot(doc))
          .toList();

      return therapistAppointments;
    } catch (e) {
      throw Exception('Failed to fetch user appointments: $e');
    }
  }

  // Update Status of Appointments
  Future<void> updateTaskStatus(String appointmentid, String newStatus) async {
    try {
      await _db
          .collection('appointments')
          .doc(appointmentid)
          .update({'appointmentstatus': newStatus});
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
}
