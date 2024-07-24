import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../screens/sign_in/sign_in.dart';



class OnBoardingController extends GetxController {
  static OnBoardingController get instance => Get.find();

  // Variable
  final pageController = PageController();
  Rx<int> currentIndex = 0.obs;

  //update Current Index when Page Scroll
  void updatePageIndicator(index) {
    currentIndex.value = index;
  }

  // Jump to the specific dot selected page
  void dotNavigationClick(index) {
    currentIndex.value = index;
    pageController.jumpToPage(index);
  }

  // Update Current Index & jump to next page
  void nextpage() {
    if (currentIndex.value == 2) {
      final storage = GetStorage();
      storage.write('IsFirstTime', false);
      Get.offAll(const SignInScreen());
    } else {
      int page = currentIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }

  // Update Current Index & jump to Last Page
  void skipPage() {
    currentIndex.value = 2;
    pageController.jumpToPage(2);
  }
}
