import 'package:get/get.dart';
import 'package:healvision/feature/home/patient_home/patient_home.dart';
import 'package:healvision/feature/personalization/controllers/user_controller.dart';
import 'package:healvision/utilis/loaders/loaders.dart';
import '../../../data/therapist_repositories/therapist_repositories.dart';
import '../model/appointment_model.dart';
import '../therapist_home/model/therapist_model.dart';

class PatientController extends GetxController {
  static PatientController get instance => Get.find();

  // Variables
  final therapistrepository = Get.put(TherapistRepository());
  final usercontroller = Get.put(UserController());
  RxList<TherapistModel> therapists = <TherapistModel>[].obs;
  RxList<TherapistModel> filteredTherapists = <TherapistModel>[].obs;

  var searchQuery = ''.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingslot = false.obs;
  RxString selectedStatus = 'Pending'.obs;

  var selectedDay = DateTime.now().obs;
  var focusedDay = DateTime.now().obs;
  var selectedTimeSlot = ''.obs;
  var timeSlots = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllTherapists();
  }

  void setTimeSlots(List<String> slots) {
    timeSlots.value = slots;
    if (timeSlots.isNotEmpty) {
      selectedTimeSlot.value = timeSlots[0];
    }
  }

  void updateSelectedDay(DateTime newSelectedDay, DateTime newFocusedDay) {
    selectedDay.value = newSelectedDay;
    focusedDay.value = newFocusedDay;
  }

  void updateSelectedTimeSlot(String time) {
    selectedTimeSlot.value = time;
  }

  Future<void> fetchAllTherapists() async {
    isLoading.value = true;
    try {
      therapists.value = await therapistrepository.fetchAllTherapists();
      filteredTherapists.value = therapists;
    } catch (e) {
      TLoaders.errorSnackBar(
          title: 'Error', message: 'Error to fetch Doctors Details!');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAvailableTimeSlots(String therapistid) async {
    isLoadingslot.value = true;
    try {
      List<String> availableSlots = await therapistrepository
          .fetchAvailableSlots(therapistid, selectedDay.value);
      setTimeSlots(availableSlots);
    } catch (e) {
      TLoaders.errorSnackBar(
          title: 'Error', message: 'Error fetching available time slots!');
    } finally {
      isLoadingslot.value = false;
    }
  }

  void bookAppointment(TherapistModel doctor) async {
    String userid = usercontroller.user.value.id;
    String username = usercontroller.user.value.fullname;
    String useremail = usercontroller.user.value.email;
    String userphone = usercontroller.user.value.phoneNumber;

    final appointment = AppointmentModel(
      therapistId: doctor.id,
      therapistName: doctor.doctorName,
      therapistSpecialty: doctor.specialty,
      therapistEmail: doctor.email,
      therapistPhoneNumber: doctor.phoneNumber,
      therapistlocation: doctor.location,
      date: selectedDay.value,
      time: selectedTimeSlot.value,
      userId: userid,
      userName: username,
      userEmail: useremail,
      userPhoneNumber: userphone,
    );

    // Show confirmation dialog
    Get.defaultDialog(
      title: 'Appointment Confirmation',
      middleText: 'Are you sure you want to confirm Appointment',
      onConfirm: () async {
        await therapistrepository.addAppointment(appointment);
        TLoaders.successSnackBar(
            title: 'Congrats!',
            message: 'Your appointment has been sent for therapist approval.');
        Get.offAll(const PatientHome());
      },
      onCancel: () => Get.back(),
    );
  }

  void searchDoctors(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredTherapists.value = therapists;
    } else {
      filteredTherapists.value = therapists.where((therapist) {
        return therapist.doctorName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  RxList<AppointmentModel> appointments = <AppointmentModel>[].obs;
  RxList<AppointmentModel> filteredAppointments = <AppointmentModel>[].obs;

  Future<void> fetchUserAppointments() async {
    try {
      String userId = usercontroller.user.value.id;
      appointments.value =
          await therapistrepository.fetchUserAppointments(userId);
    } catch (e) {
      TLoaders.errorSnackBar(
          title: 'Error', message: 'Failed to fetch appointments: $e');
    }
  }

  void filterAppointmentsByStatus(String status) {
    selectedStatus.value = status;
    filteredAppointments.value = appointments.where((appointment) => appointment.appointmentstatus == status).toList();
  }
}
