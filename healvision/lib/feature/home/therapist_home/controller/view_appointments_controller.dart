import 'package:get/get.dart';
import '../../../../data/therapist_repositories/therapist_repositories.dart';
import '../../../../utilis/constants/image_strings.dart';
import '../../../../utilis/loaders/loaders.dart';
import '../../../../utilis/popups/full_screen_loader.dart';
import '../../../personalization/controllers/user_controller.dart';
import '../../model/appointment_model.dart';

class ViewTherapistAppointmentController extends GetxController {
  static ViewTherapistAppointmentController get instance => Get.find();

  final therapistrepository = Get.put(TherapistRepository());
  final usercontroller = Get.put(UserController());

  RxList<AppointmentModel> appointments = <AppointmentModel>[].obs;
  RxList<AppointmentModel> filteredAppointments = <AppointmentModel>[].obs;
  RxString selectedStatus = 'Pending'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserAppointments();
  }

  Future<void> fetchUserAppointments() async {
    try {
      String userId = usercontroller.user.value.id;
      var fetchedAppointments = await therapistrepository.fetchtherspistAppointments(userId);
      fetchedAppointments.sort((a, b) => a.date.compareTo(b.date));
      appointments.value = fetchedAppointments;
      filterAppointmentsByStatus(selectedStatus.value);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: 'Failed to fetch appointments: $e');
    }
  }

  void filterAppointmentsByStatus(String status) {
    selectedStatus.value = status;
    filteredAppointments.value = appointments.where((appointment) => appointment.appointmentstatus == status).toList();
  }

  void updateTaskStatus(String appointmentid, String newStatus) async {
    try {
      TFullScreenLoader.openLoadingDialogue('Updating Appointments status...', WImages.loaderAnimation);
      await therapistrepository.updateTaskStatus(appointmentid, newStatus);
      fetchUserAppointments();
      TFullScreenLoader.stopLoading();
      TLoaders.successSnackBar(title: 'Success', message: 'Appointments status has been updated successfully.');
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
}
