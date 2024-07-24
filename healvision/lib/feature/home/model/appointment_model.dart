import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  String? id;
  String therapistId;
  String therapistName;
  String therapistSpecialty;
  String therapistEmail;
  String therapistPhoneNumber;
  String therapistlocation;
  DateTime date;
  String time;
  String userId;
  String userName;
  String userEmail;
  String userPhoneNumber;
  String appointmentstatus;
  AppointmentModel({
    this.id,
    required this.therapistId,
    required this.therapistName,
    required this.therapistSpecialty,
    required this.therapistEmail,
    required this.therapistPhoneNumber,
    required this.therapistlocation,
    required this.date,
    required this.time,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhoneNumber,
    this.appointmentstatus = 'Pending',
  });

  Map<String, dynamic> toJson() {
    return {
      'therapistId': therapistId,
      'therapistName': therapistName,
      'therapistSpecialty': therapistSpecialty,
      'therapistEmail': therapistEmail,
      'therapistPhoneNumber': therapistPhoneNumber,
      'therapistlocation': therapistlocation,
      'date': date.toIso8601String().split('T').first,
      'time': time,
      'userid': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhoneNumber': userPhoneNumber,
      'appointmentstatus': appointmentstatus,
    };
  }

  factory AppointmentModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return AppointmentModel(
      id: snapshot.id,
      therapistId: data['therapistId'],
      therapistName: data['therapistName'],
      therapistSpecialty: data['therapistSpecialty'],
      therapistEmail: data['therapistEmail'],
      therapistPhoneNumber: data['therapistPhoneNumber'],
      therapistlocation: data['therapistlocation'],
      userId: data['userid'],
      userEmail: data['userEmail'],
      userName: data['userName'],
      userPhoneNumber: data['userPhoneNumber'],
      time: data['time'],
      date: DateTime.parse(data['date']), // Parse date string to DateTime
      appointmentstatus: data['appointmentstatus'],
    );
  }
}
