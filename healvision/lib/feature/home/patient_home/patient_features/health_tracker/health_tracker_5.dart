import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healvision/utilis/constants/colors.dart';

import '../../../../../utilis/validations/validation.dart';
import '../../../therapist_home/navigation_menu.dart';

import '../controller/health_tracker_controller.dart';
import '../view_appointment.dart';
import '../widgets/assesment_widget.dart';

class SubstanceUseDataScreen extends StatelessWidget {
  const SubstanceUseDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HealthAssessmentController());

    // Default date and time values
    DateTime defaultDate = DateTime.now();
    TimeOfDay defaultTime = TimeOfDay.now(); // Current time

    // Controllers for date and time fields
    TextEditingController dateController = TextEditingController(
      text: '${defaultDate.day}-${defaultDate.month}-${defaultDate.year}',
    );
    TextEditingController timeController = TextEditingController(
      text: defaultTime.format(context),
    );

    // Set initial values in the controller
    controller
        .setDate('${defaultDate.day}-${defaultDate.month}-${defaultDate.year}');
    controller.setTime(
        '${defaultTime.hour}:${defaultTime.minute} ${defaultTime.period == DayPeriod.am ? 'AM' : 'PM'}');

    Future<void> selectDate(BuildContext context) async {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: defaultDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (pickedDate != null) {
        String formattedDate =
            '${pickedDate.day}-${pickedDate.month}-${pickedDate.year}';
        dateController.text = formattedDate;
        controller.setDate(formattedDate); // Update controller value
      }
    }

    Future<void> selectTime(BuildContext context) async {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: defaultTime,
      );
      if (pickedTime != null) {
        String formattedTime =
            '${pickedTime.hour}:${pickedTime.minute} ${pickedTime.period == DayPeriod.am ? 'AM' : 'PM'}';
        timeController.text = formattedTime;
        controller.setTime(formattedTime); // Update controller value
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: WColors.white,
        title: Text(
          'Assessment',
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: const [
          CustomCountContainer(
            pagenumber: '5',
            endingpage: '5',
          ),
          SizedBox(
            width: 15,
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: controller.substanceFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CustomTextLabel(
                    label: 'Substance Use Data',
                    fontsize: 30,
                    fontweight: FontWeight.bold,
                  ),
                  const SizedBox(height: 10),
                  const CustomTextLabel(
                    label:
                        'Enter the substance, amount, date, time, and reason when used',
                    textalign: TextAlign.center,
                    fontsize: 16,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: controller.name,
                    validator: (value) =>
                        TValidator.vaildationEmptyText('Name', value),
                    decoration: InputDecoration(
                      labelText: '(weed, alcohol)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: controller.amount,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        TValidator.vaildationEmptyText('Amount', value),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () => selectDate(context),
                    child: IgnorePointer(
                      child: TextField(
                        controller: dateController,
                        decoration: InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () => selectTime(context),
                    child: IgnorePointer(
                      child: TextField(
                        controller: timeController,
                        decoration: InputDecoration(
                          labelText: 'Time',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: controller.reason,
                    validator: (value) =>
                        TValidator.vaildationEmptyText('Reason', value),
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Reason',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButtonNext(
                    title: 'Submit',
                    onpressed: () {
                      if (controller.substanceFormKey.currentState!
                          .validate()) {
                        controller.addSubstance(
                          controller.name.text,
                          controller.amount.text,
                          controller.date.value,
                          controller.time.value,
                          controller.reason.text,
                        );
                        controller.saveAssessmentDataToFirestore();
                        Get.offAll(const NavigationMenuPatient());
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
