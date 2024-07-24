import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../../data/repositories/user/user_repoistory.dart';
import '../../../utilis/constants/image_strings.dart';
import '../../../utilis/helpers/network_manager.dart';


import '../../../utilis/loaders/loaders.dart';
import '../../../utilis/popups/full_screen_loader.dart';
import '../screens/profile/profile.dart';
import 'user_controller.dart';



class UpdateNameController extends GetxController {
  static UpdateNameController get instance => Get.find();

  final firstname = TextEditingController();
  final lastname = TextEditingController();
  final userController = UserController.instance;
  final userRespository = Get.put(UserRepository());
  GlobalKey<FormState> updateUserNameFormKey = GlobalKey<FormState>();

  /// init user data when Home Screen appears
  @override
  void onInit() {
    initializeName();
    super.onInit();
  }

  // Fetch user Record
  Future<void> initializeName() async {
    firstname.text = userController.user.value.firstname;
    lastname.text = userController.user.value.lastname;
  }

  Future<void> updateUserName() async {
    try {
      // start loading
      TFullScreenLoader.openLoadingDialogue(
        'We are updating your information...',
        WImages.docerAnimation,
      );

      // check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!updateUserNameFormKey.currentState!.validate()) {
        // Remove Loader
        TFullScreenLoader.stopLoading();
        return;
      }
      // update user's first and last name in the Firebase Firestore
      Map<String, dynamic> name = {
        'FirstName': firstname.text.trim(),
        'LastName': lastname.text.trim(),
      };
      await userRespository.updateSingleField(name);

      // update the Rx User Value
      userController.user.value.firstname = firstname.text.trim();
      userController.user.value.lastname =  lastname.text.trim();

      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Show Success Message
      TLoaders.successSnackBar(
          title: 'Success', message: 'Your name has been changed!');

      // Move to Profile Screen
      Get.off(() => const UserProfile());
    } catch (e) {
      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Show some Generic Error to the user
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }
}
