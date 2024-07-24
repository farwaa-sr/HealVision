import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/sucess_screen.dart/success_screen.dart';
import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../utilis/constants/image_strings.dart';
import '../../../../utilis/constants/text_string.dart';
import '../../../../utilis/loaders/loaders.dart';

class VerifyEmailController extends GetxController {
  static VerifyEmailController get instance => Get.find();

  // Send Email Whenever Verify Screen apperars & Set Timer for auto redirect.
  @override
  void onInit() {
    sendEmailVerification();
    setTimerForAutoRedirect();
    super.onInit();
  }

  // send Email Verification link
  sendEmailVerification() async {
    try {
      await AuthenticationRepository.instance.sendEmailVerification();
      TLoaders.successSnackBar(
          title: 'Email Sent',
          message: 'please Check your inbox and verify your email');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Opps1', message: e.toString());
    }
  }

  // Timer to automatically redirect on Email Verification
  setTimerForAutoRedirect() {
    Timer.periodic(
      const Duration(seconds: 1),
      (timer) async {
        await FirebaseAuth.instance.currentUser?.reload();
        final user = FirebaseAuth.instance.currentUser;
        if (user?.emailVerified ?? false) {
          timer.cancel();
          Get.offAll(
            () => SuccessScreen(
              image: WImages.successfullyRegisterAnimation,
              title: WTexts.yourAccountCreatedSubTitle,
              subtitile: WTexts.yourAccountCreatedSubTitle,
              onpressed: () =>
                  AuthenticationRepository.instance.screenRedirect(),
            ),
          );
        }
      },
    );
  }

  // Manually Check if Email Verified
  checkEmailVerificationStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.emailVerified) {
      Get.offAll(
        () => SuccessScreen(
          image: WImages.successfullyRegisterAnimation,
          title: WTexts.yourAccountCreatedSubTitle,
          subtitile: WTexts.yourAccountCreatedSubTitle,
          onpressed: () => AuthenticationRepository.instance.screenRedirect(),
        ),
      );
    }
  }
}
