import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../utilis/constants/image_strings.dart';
import '../../../../utilis/helpers/network_manager.dart';
import '../../../../utilis/loaders/loaders.dart';
import '../../../../utilis/popups/full_screen_loader.dart';
import '../../../personalization/controllers/user_controller.dart';

class LoginController extends GetxController {
  // Varibles
  final rememberMe = false.obs;
  final hidePassword = true.obs;
  final localStorage = GetStorage();
  final email = TextEditingController();
  final password = TextEditingController();
  GlobalKey<FormState> loginFormkey = GlobalKey<FormState>();
  final userController = Get.put(UserController());

  @override
  void onInit() {
    final rememberMeEmail = localStorage.read('Remember_me_email');
    if (rememberMeEmail != null) {
      email.text = rememberMeEmail;
    }

    final rememberMebox = localStorage.read('remberme');
    if (rememberMebox != null) {
      rememberMe.value = rememberMebox;
    }

    final rememberMePassword = localStorage.read('Remember_me_password');
    if (rememberMePassword != null) {
      password.text = rememberMePassword;
    }
    super.onInit();
  }

  // Signin Email and password
  Future<void> emailAndPasswordSignIn() async {
    try {
      // start loading
      TFullScreenLoader.openLoadingDialogue(
        'Logging you in...',
        WImages.docerAnimation,
      );

      // check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!loginFormkey.currentState!.validate()) {
        // Remove Loader
        TFullScreenLoader.stopLoading();
        return;
      }

      // Remember Me Check

      if (rememberMe.value) {
        localStorage.write('Remember_me_email', email.text.trim());
        localStorage.write('Remember_me_password', password.text.trim());
        localStorage.write('remberme', rememberMe.value);
      }

      // Login user in the Firebase Authentication & Save user data in the Firbase
      await AuthenticationRepository.instance
          .loginWithEmailandPassword(email.text.trim(), password.text.trim());

      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Move to Home screen
      AuthenticationRepository.instance.screenRedirect();
    } catch (e) {
      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Show some Generic Error to the user
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  // Google Signin Authentication
  Future<void> googleSignIn() async {
    try {
      // start loading
      TFullScreenLoader.openLoadingDialogue(
        'Logging you in...',
        WImages.docerAnimation,
      );

      // check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Login user in the Firebase Authentication & Save user data in the Firbase
      final userCredentials =
          await AuthenticationRepository.instance.signinWithGoogle();

      // Save Record
      await userController.saveuserRecord(userCredentials);

      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Redirect
      AuthenticationRepository.instance.screenRedirect();
    } catch (e) {
      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Show some Generic Error to the user
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }
}
