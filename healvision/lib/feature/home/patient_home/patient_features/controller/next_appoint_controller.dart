import 'package:get/get.dart';
import '../../../../../data/therapist_repositories/therapist_repositories.dart';
import '../../../../../utilis/loaders/loaders.dart';
import '../../../../personalization/controllers/user_controller.dart';
import '../../../model/appointment_model.dart';

class NextAppointmentController extends GetxController {
  static NextAppointmentController get instance => Get.find();
  
  // Variables
  final therapistrepository = Get.put(TherapistRepository());
  final usercontroller = Get.put(UserController());
  var searchappoints = ''.obs;
  RxBool isLoadingAppointment = false.obs;
  RxList<AppointmentModel> appointments = <AppointmentModel>[].obs;
  RxList<AppointmentModel> filteredappointment = <AppointmentModel>[].obs;

  void searchappointments(String query) {
    searchappoints.value = query;
    if (query.isEmpty) {
      filteredappointment.value = appointments;
    } else {
      filteredappointment.value = appointments.where((appointment) {
        return appointment.therapistName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  Future<void> fetchConfrimAppointments() async {
    try {
      isLoadingAppointment.value = true; // Start loading

      String userId = usercontroller.user.value.id;
      
      appointments.value = await therapistrepository
          .fetchPatientConfrimAppointments(userId, 'Confirm');
      // Sort appointments by date
      appointments.sort((a, b) => a.date.compareTo(b.date));

      filteredappointment.value = appointments;
      isLoadingAppointment.value = false; // Stop loading
    } catch (e) {
      isLoadingAppointment.value = false; // Stop loading on error
      TLoaders.errorSnackBar(
          title: 'Error', message: 'Failed to fetch appointments: $e');
    }
  }


}
