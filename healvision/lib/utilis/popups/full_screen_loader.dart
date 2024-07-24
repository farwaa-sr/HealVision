import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/colors.dart';
import '../helpers/helper_function.dart';
import '../loaders/animation_loader.dart';



class TFullScreenLoader {
  // Open a full screen loading dialog with a given text and animation
  // This method does't return anything

  // Parameters
  // - text: the text to be displayed in the loading dialog
  // -animation: The Lottie animation to be shown
  static void openLoadingDialogue(String text, String animation) {
    showDialog(
      context: Get.overlayContext!,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Container(
          color: THelperFunctions.isDarkMode(Get.context!)
              ? WColors.dark
              : WColors.white,
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              const SizedBox(
                height: 250,
              ),
              TAnimationLoaderWidget(
                text: text,
                animation: animation,
              ),
            ],
          ),
        ),
      ),
    );
  }
  // Stop the currently open loading dialogue
  // This method does't return anything

  static stopLoading() {
    Navigator.of(Get.overlayContext!).pop();
  }
}
