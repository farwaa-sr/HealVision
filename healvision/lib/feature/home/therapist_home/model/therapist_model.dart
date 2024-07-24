import 'package:cloud_firestore/cloud_firestore.dart';

class TherapistModel {
  final String id; // Therapist ID (can be the same as UserModel ID)
  String doctorName;
  String specialty;
  String image;
  String location;
  int experience;
  String aboutMe;
  String workingTime;
  String email;
  String phoneNumber;
  List<String> timeSlots;

  TherapistModel({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.image,
    required this.location,
    required this.experience,
    required this.aboutMe,
    required this.workingTime,
    required this.email,
    required this.phoneNumber,
    required this.timeSlots,
  });

  // Convert model to JSON structure for storing data in Firebase
  Map<String, dynamic> toJson() {
    return {
      'doctorName': doctorName,
      'specialty': specialty,
      'image': image,
      'location': location,
      'totalPatientsExperience': experience,
      'aboutMe': aboutMe,
      'workingTime': workingTime,
      'email': email,
      'phoneNumber': phoneNumber,
      'timeSlots': timeSlots,
    };
  }

  // Factory method to create a TherapistModel from a Firebase document snapshot.
  factory TherapistModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return TherapistModel(
      id: document.id,
      doctorName: data['doctorName'] ?? '',
      specialty: data['specialty'] ?? '',
      image: data['image'] ?? '',
      location: data['location'] ?? '',
      experience: data['totalPatientsExperience'] ?? 0,
      aboutMe: data['aboutMe'] ?? '',
      workingTime: data['workingTime'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      timeSlots: List<String>.from(data['timeSlots'] ?? []),
    );
  }
}
