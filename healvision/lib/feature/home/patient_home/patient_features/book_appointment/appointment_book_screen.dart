import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../../utilis/constants/colors.dart';
import '../../../controller/patient_controller.dart';
import '../../../therapist_home/model/therapist_model.dart';
import '../widgets/assesment_widget.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key, required this.doctor});
  final TherapistModel doctor;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PatientController());
    controller.setTimeSlots(doctor.timeSlots);
    controller.fetchAvailableTimeSlots(doctor.id);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: WColors.white,
        centerTitle: true,
        title: Text(
          'Book Appointment',
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Obx(() {
        return controller.isLoadingslot.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => TableCalendar(
                            calendarStyle: CalendarStyle(
                              tablePadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              tableBorder: TableBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            firstDay: DateTime.now(),
                            lastDay: DateTime(DateTime.now().year + 1),
                            focusedDay: controller.focusedDay.value,
                            selectedDayPredicate: (day) {
                              return isSameDay(
                                  controller.selectedDay.value, day);
                            },
                            onDaySelected: (selectedDay, focusedDay) {
                              controller.updateSelectedDay(
                                  selectedDay, focusedDay);
                              controller.fetchAvailableTimeSlots(doctor.id);
                            },
                            calendarFormat: CalendarFormat.month,
                            startingDayOfWeek: StartingDayOfWeek.sunday,
                            headerStyle: const HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                            ),
                          )),
                      const SizedBox(height: 16.0),
                      const Text(
                        'Select Hour',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Obx(() => Wrap(
                            spacing: 8.0,
                            runSpacing: 5.0,
                            children: controller.timeSlots.map((time) {
                              return ChoiceChip(
                                label: Text(time),
                                showCheckmark: false,
                                selected:
                                    controller.selectedTimeSlot.value == time,
                                onSelected: (selected) {
                                  controller.updateSelectedTimeSlot(time);
                                },
                                selectedColor: Colors.green,
                                backgroundColor: Colors.grey[200],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  side: const BorderSide(
                                    color: Colors.green,
                                  ),
                                ),
                                labelStyle: TextStyle(
                                  color:
                                      controller.selectedTimeSlot.value == time
                                          ? Colors.white
                                          : Colors.black,
                                ),
                              );
                            }).toList(),
                          )),
                      const SizedBox(
                          height: 16.0), // Added SizedBox for spacing
                      CustomButtonNext(
                        title: 'Confirm Appointment',
                        visble: false,
                        onpressed: () {
                          controller.bookAppointment(doctor);
                        },
                      ),
                      const SizedBox(
                          height: 10.0), // Added SizedBox for spacing
                    ],
                  ),
                ),
              );
      }),
    );
  }
}
