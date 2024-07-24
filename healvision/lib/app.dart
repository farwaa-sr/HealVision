import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healvision/utilis/constants/colors.dart';
import 'bindings/general_bindings.dart';
import 'utilis/theme/theme.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      themeMode: ThemeMode.light,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.drakTheme,
      initialBinding: GeneralBindings(),
      // show loader or circular progress Indicator meanwhile Authentication Repository is deciding to show releveant screen
      home: const Scaffold(
        backgroundColor: WColors.primary,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}