import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../utilis/constants/image_strings.dart';
import '../../../../utilis/helpers/network_manager.dart';
import '../../../../utilis/loaders/loaders.dart';
import '../../../../utilis/popups/full_screen_loader.dart';
import '../../screens/forget_password/resetpassword.dart';


class ForgetPasswordController extends GetxController {
  static ForgetPasswordController get instance => Get.find();

  // Variables
  final email = TextEditingController();
  GlobalKey<FormState> forgetPasswordFormKey = GlobalKey<FormState>();

  // Send Reset Password Email
  sendPasswordResetEmail() async {
    try {
      // start loading
      TFullScreenLoader.openLoadingDialogue(
        'Processign Your request...',
        WImages.docerAnimation,
      );

      // check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!forgetPasswordFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Send Email to Reset Password
      await AuthenticationRepository.instance
          .sendPasswordResetEmail(email.text.trim());

      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Show Sucess Screen
      TLoaders.successSnackBar(
          title: 'Email sent',
          message: 'Email link sent to Reset your Password');

      // Redirect
      Get.to(
        ResetPassword(
          email: email.text.trim(),
        ),
      );
    } catch (e) {
      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Show some Generic Error to the user
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  reSendPasswordResetEmail(String email) async {
    try {
      // start loading
      TFullScreenLoader.openLoadingDialogue(
        'Processign Your request...',
        WImages.docerAnimation,
      );

      // check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Send Email to Reset Password
      await AuthenticationRepository.instance
          .sendPasswordResetEmail(email);

      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Show Sucess Screen
      TLoaders.successSnackBar(
          title: 'Email sent',
          message: 'Email link sent to Reset your Password');

    } catch (e) {
      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Show some Generic Error to the user
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }
}
