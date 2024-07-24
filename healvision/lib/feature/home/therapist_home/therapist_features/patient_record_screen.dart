import 'package:flutter/material.dart';

import '../../../../utilis/constants/colors.dart';
import '../../../../utilis/constants/size.dart';
import '../../patient_home/patient_features/view_appointment.dart';

class PatientRecords extends StatelessWidget {
  const PatientRecords({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WColors.white,
      appBar: AppBar(
        backgroundColor: WColors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CustomTextLabel(
              label: 'Patient Records',
              fontsize: 26,
              fontweight: FontWeight.bold,
            ),
            const SizedBox(height: 16),
            const CustomTextLabel(
              label: 'Keep track of your sessions, patients and more ',
              fontsize: 16,
              textalign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Expanded(
              // Wrap the ListView.builder with Expanded
              child: ListView.builder(
                itemCount: 8,
                itemBuilder: (_, __) {
                  return const PatientRecordCard();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PatientRecordCard extends StatelessWidget {
  const PatientRecordCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: WColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4.0,
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextLabel(
                    label: 'Ali Hamza',
                    fontweight: FontWeight.bold,
                    fontsize: 18.0,
                    textcolor: WColors.white,
                  ),
                  CustomTextLabel(
                    label: 'Addiction Level: 40',
                    textcolor: WColors.white,
                  ),
                  CustomTextLabel(
                    label: '03406014047',
                    textcolor: WColors.white,
                  ),
                  CustomTextLabel(
                    label: 'alihamxa300@gmail.com',
                    textcolor: WColors.white,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
